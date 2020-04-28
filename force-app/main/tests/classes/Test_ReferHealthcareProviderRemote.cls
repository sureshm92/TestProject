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
        Participant_Enrollment__c partEnroll = [SELECT Id, Participant__c, Show_Referring_Provider__c FROM Participant_Enrollment__c LIMIT 1];
        Participant__c part = new Participant__c(
                First_Name__c = 'Test1FirstName',
                Last_Name__c = 'Test1LastName',
                Email__c = 'Test1Email'
        );
        Test.startTest();
        Contact parDelegateContact = new Contact(
                FirstName = 'PADelTD',
                LastName = 'PADelTD',
                Email = 'pa_delegate@emil.com'
        );
        Participant__c part2 = new Participant__c(
                First_Name__c = 'Test1FirstName',
                Last_Name__c = 'Test1LastName',
                Email__c = 'Test1Email',
                Contact__c = parDelegateContact.Id
        );
        insert parDelegateContact;

        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = partEnroll.Participant__c;
        deleg.Contact__c = parDelegateContact.Id;
        insert deleg;
        List<ReferHealthcareProviderRemote.PDWrapper> result = ReferHealthcareProviderRemote.getInitData(partEnroll.Id, partEnroll.Participant__c).listWrapp;
        Test.stopTest();
        //System.assertEquals(part2.Email__c, result[0].email);
    }

}