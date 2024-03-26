@isTest
private class Test_Batch_MassEmailDelegate {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void testMassEmailDel() {
        TestData testData = new TestData();
        User pdUser = testData.createPatientDelegate();
        Contact delCon = [SELECT Id,Email,Participant_Opt_In_Status_Emails__c,LastName FROM Contact WHERE Id = :pdUser.ContactId];
        delCon.Participant_Opt_In_Status_Emails__c = true;
        update delCon;
        Patient_Delegate__c Patintdel = [select id,Contact__c,Participant__r.Contact__c from Patient_Delegate__c where Contact__c=:delCon.Id];
        Patient_delegate_enrollment__c patientEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = testData.pe.Id,
            Patient_Delegate__c= Patintdel.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        ); 
        insert patientEnrollment;
        

        List<Id> conIds = new List<Id>();
        conIds.add(Patintdel.Participant__r.Contact__c);
        Notification__c notification = new Notification__c(
                Notification_Type__c = NotificationCatalog.Message_to_PT_New_Study_eRP_VT_Type,
                Recipient__c = delCon.Id,
                WhatId__c = testData.pe.Id
        );
        insert notification;
        Test.startTest();
        DataBase.executeBatch(new Batch_MassEmailDelegate(notification,conIds));
        Test.stopTest();
    }

}