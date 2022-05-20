@IsTest
public class Test_ParticipantComorbiditiesTrigger {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
   
    @isTest
    static void testUpdatePERafterInsert() {
        TestData testData = new TestData();
        List<Comorbidities__c> comList = new List<Comorbidities__c>();
        List<Participant_Comorbidities__c> pcList = new List<Participant_Comorbidities__c>();
        Comorbidities__c com1 = new Comorbidities__c(Comorbidity_Name__c='Blood Pressure');
        comList.add(com1);
        Comorbidities__c com2 = new Comorbidities__c(Comorbidity_Name__c='Lung Disorder');
        comList.add(com2);

        insert comList;

        Participant_Comorbidities__c pc1 = new Participant_Comorbidities__c(Comorbidities__c = comList[0].Id,Participant__c=testData.participant.Id);
        pcList.add(pc1);
        Participant_Comorbidities__c pc2 = new Participant_Comorbidities__c(Comorbidities__c = comList[1].Id,Participant__c=testData.participant.Id);
        pcList.add(pc2);

        Test.startTest();
        insert pcList;

        delete pcList;
        Test.stopTest();
    }

}