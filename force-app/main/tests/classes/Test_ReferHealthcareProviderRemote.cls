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
        Participant__c participant = [SELECT Id
                                      FROM Participant__c
                                      LIMIT 1];
        Contact cont = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];
        Participant__c par = [SELECT Id, First_Name__c, Last_Name__c, Email__c FROM Participant__c LIMIT 1];
        Participant__c par2 = new Participant__c();
        par2.First_Name__c = 'Paul';
        par2.Last_Name__c = 'Frekky';
        par2.Email__c = 'asfasf@experidite.com';
        insert par2;
        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = participant.Id;
        deleg.Participant__r = par;
        deleg.Participant__c = par.Id;
        deleg.Contact__c = cont.Id;
        deleg.Contact__r = cont;
        insert deleg;
        Test.startTest();
        List<Participant__c> result = ReferHealthcareProviderRemote.getContactsDelegates(participant.Id);
        Test.stopTest();
    }

}