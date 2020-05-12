/**
 * Created by Leonid Bartenev
 */

@IsTest
private without sharing class Test_ContactService {


    @IsTest
    private static void defaultPEOnContact() {
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);

        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();

        System.runAs(testData.participantUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();

        }

        //case getCurrentPe:
        Participant_Enrollment__c pe1 = ContactService.getCurrentPE(testData.participantUser.ContactId);
        System.assert(pe1.Id == testData.pe.Id);

        //case applyRelevantNames:
        Contact contact = ContactService.getContact(testData.participantUser.ContactId);
        ContactService.applyRelevantNames(contact);

        pe1.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update pe1;

        System.runAs(testData.participantUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();

        }

        System.runAs(testData.createPatientDelegate()) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();

        }

        //case getPastStudyWrappers:
        List<ContactService.PastStudyWrapper> pastStudyWrappers = new List<ContactService.PastStudyWrapper>();
        Id conId = testData.participantUser.ContactId;
        pastStudyWrappers.addAll(ContactService.getPastStudyWrappers(conId));

        //case getPastEnrollments
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        peList.addAll(ContactService.getPastEnrollments(conId));

        //case NextNotifyDate
        Datetime dt = Datetime.newInstance(2020, 1, 1);
        ContactService.updateNextNotifyDate(conId, dt);
        Contact delCon = [SELECT Id, LastName FROM Contact WHERE LastName = 'Delegate'];
        ContactService.updateNextNotifyDate(delCon.Id, dt);

        Test.stopTest();
    }

}