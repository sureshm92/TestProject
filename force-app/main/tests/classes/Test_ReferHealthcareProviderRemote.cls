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
        Contact cont2 = new Contact();
        cont2.LastName = 'Bilbo';
        insert cont2;
        Participant__c par = [SELECT Id, First_Name__c, Last_Name__c, Email__c FROM Participant__c LIMIT 1];
        Participant__c par2 = new Participant__c();
        par2.First_Name__c = 'Paul';
        par2.Last_Name__c = 'Frekky';
        par2.Email__c = 'asfasf@experidite.com';
        par2.Contact__c = cont2.Id;
        insert par2;
        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = par.Id;
        deleg.Participant__r = par;
        deleg.Contact__c = cont2.Id;
        deleg.Contact__r = cont2;
        insert deleg;
        Test.startTest();
        List<Participant__c> result = ReferHealthcareProviderRemote.getContactsDelegates(par.Id);
        Test.stopTest();
        System.assertEquals(par2.Email__c, result[0].Email__c);
    }

    @IsTest
    static void testGetStatusDelegates() {
        TestData.loadTestData();
        Participant__c par = [SELECT Id, First_Name__c, Last_Name__c, Email__c FROM Participant__c LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];

        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = par.Id;
        deleg.Participant__r = par;
        deleg.Contact__c = cont.Id;
        deleg.Contact__r = cont;
        deleg.Status__c = 'Active';

        Patient_Delegate__c deleg2 = new Patient_Delegate__c();
        deleg2.Participant__c = par.Id;
        deleg2.Participant__r = par;
        deleg2.Contact__c = cont.Id;
        deleg2.Contact__r = cont;
        deleg2.Status__c = 'Disconnected';
        insert deleg2;

        Test.startTest();
        List<Patient_Delegate__c> deleget = ReferHealthcareProviderRemote.getStatusDelegates(par.Id);
        Test.stopTest();

        System.assert(deleget.size() == 1);
    }

}