/**
 * Created by user on 04-Feb-20.
 */

@IsTest
private class Test_ReferHealthcareProviderRemote {
    @IsTest
    static void testShowOrHideProvider() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [SELECT Id, Show_Referring_Provider__c FROM Participant_Enrollment__c LIMIT 1];
        Test.startTest();
        ReferHealthcareProviderRemote.showOrHideProvider(partEnroll.Id);
        Test.stopTest();
        Participant_Enrollment__c partEnroll2 = [SELECT Id, Show_Referring_Provider__c FROM Participant_Enrollment__c WHERE Id =: partEnroll.Id];
        System.assert(partEnroll.Show_Referring_Provider__c != partEnroll2.Show_Referring_Provider__c);
    }
    @IsTest
    static void testGetContactsDelegates() {
        TestData.loadTestData();
        Contact cont = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];
        Participant_Enrollment__c partEnroll = [SELECT Id, Show_Referring_Provider__c FROM Participant_Enrollment__c LIMIT 1];
        Participant__c par = new Participant__c();
        par.First_Name__c = 'Paul';
        par.Last_Name__c = 'Frekky';
        par.Email__c = 'asfasf@experidite.com';
        par.Contact__c = cont.Id;
        insert par;
        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = par.Id;
        deleg.Participant__r = par;
        deleg.Contact__c = cont.Id;
        deleg.Contact__r = cont;
        insert deleg;
        Test.startTest();
        List<Patient_Delegate__c> result = ReferHealthcareProviderRemote.getInitData(partEnroll.Id, par.Id).listDelegates;
        Test.stopTest();
        System.assertEquals(cont.Email, result[0].Contact__r.Email);
    }

}