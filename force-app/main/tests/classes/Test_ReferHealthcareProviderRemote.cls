/**
 * Created by user on 04-Feb-20.
 */

@IsTest
private class Test_ReferHealthcareProviderRemote {
    @IsTest
    static void testShowOrHideProvider() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Test.startTest();
        ReferHealthcareProviderRemote.showOrHideProvider(partEnroll.Id);
        Test.stopTest();
        Participant_Enrollment__c partEnroll2 = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            WHERE Id = :partEnroll.Id
        ];
        System.assert(
            partEnroll.Show_Referring_Provider__c != partEnroll2.Show_Referring_Provider__c
        );
    }

    @IsTest
    static void testGetContactsDelegates() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        ReferHealthcareProviderRemote.InitData result;
        Test.startTest();
        
        TestData testData = new TestData();
        System.runAs(testData.participantUser) {
        Contact parDelegateContact = new Contact(
            FirstName = 'PADelTD',
            LastName = 'PADelTD',
            Email = 'pa_delegate@emil.com'
        );
        insert parDelegateContact;
        Participant__c participantDelegate = new Participant__c( Adult__c = true,
                                                                Contact__c = parDelegateContact.Id,
                                                                First_Name__c = parDelegateContact.FirstName,
                                                                Last_Name__c = parDelegateContact.LastName,
                                                                Email__c = parDelegateContact.Email,
                                                                Phone__c = '98723333');
        insert participantDelegate;
        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = partEnroll.Participant__c;
        deleg.Contact__c = parDelegateContact.Id;
         deleg.Status__c = 'Disconnected';
        insert deleg;
        result = ReferHealthcareProviderRemote.getInitData(
            partEnroll.Id,
            partEnroll.Participant__c
        );
        }
        Test.stopTest();
        System.assert(!result.listWrapp.isEmpty());
    }
	
    @IsTest
    static void testDuplicatePDelegatesQeryFormedCorrectly() {
        Test.startTest();
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,'<fname>','<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,null,null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,'<fname>',null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,null,'<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>',null,null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>',null,'<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>','<fname>',null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>','<fname>','<lname>');
        Test.stopTest();
    }
	
}