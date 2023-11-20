@isTest
private class Test_Batch_UpdateStudySiteActivationS {
    @TestSetup
    static void init() {
         TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.StudySiteTriggerHandler.class
        );
      
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void testBatch() {
        TestData td = new TestData();
          List<String> statusList = new List<String>{'On Hold', 'On Hold (Admin)','Accepted', 'Accepted (Admin)','None', 'Invitation Sent','Deactivated (Admin)','Non-responsive (Admin)','Declined (Acceptance)',Null};
          List<Study_Site__c> studySite = [select id,Override_PI_Referral_Status__c from Study_Site__c where id =: td.ss.id and Override_PI_Referral_Status__c IN: statusList];
       
        Test.startTest();
        Batch_UpdateStudySiteActivationStatus batchClassInstance = new Batch_UpdateStudySiteActivationStatus();
        batchClassInstance.specificRecordIdList = new List<Id>();
        for (Study_Site__c ss : studySite) {
            batchClassInstance.specificRecordIdList.add(ss.Id);
        }
        Database.executeBatch(batchClassInstance);
        Test.stopTest();

        // Verify if the records were updated as expected
        List<Study_Site__c> updatedSites = [SELECT Id, Site_Activation_Status__c, Override_PI_Referral_Status__c FROM Study_Site__c WHERE Id IN :studySite];
        for (Study_Site__c updatedSite : updatedSites) {
            System.assertEquals('Activated (Admin)', updatedSite.Site_Activation_Status__c);
            System.assertEquals('Accepted', updatedSite.Override_PI_Referral_Status__c);
        }
    }
}