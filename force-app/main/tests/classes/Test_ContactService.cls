/**
 * Created by Leonid Bartenev
 */

@IsTest
private without sharing class Test_ContactService {
    @IsTest
    private static void defaultPEOnContact() {
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );

        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();

        System.runAs(testData.participantUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }

        //case getCurrentPe:
        Participant_Enrollment__c pe1 = ContactService.getCurrentPE(
            testData.participantUser.ContactId
        );
        System.assertEquals(testData.pe.Id, pe1.Id);

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
        User pdUser = testData.createPatientDelegate();
        System.runAs(pdUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }

        //case getPastStudyWrappers:
        List<ContactService.PastStudyWrapper> pastStudyWrappers = new List<ContactService.PastStudyWrapper>();
        Id conId = testData.participantUser.ContactId;
        pastStudyWrappers.addAll(ContactService.getPastStudyWrappers(conId));
        System.assertEquals(testData.ctp.Id, pastStudyWrappers[0].ctp.Id);

        //case getPastEnrollments
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        peList.addAll(ContactService.getPastEnrollments(conId));
        System.assertEquals(testData.pe.Id, peList[0].Id);

        //case NextNotifyDate
        Datetime dt = Datetime.newInstance(2020, 1, 1);
        ContactService.updateNextNotifyDate(conId, dt);
        Contact delCon = [SELECT Id, LastName FROM Contact WHERE Id = :pdUser.ContactId];
        ContactService.updateNextNotifyDate(delCon.Id, dt);
        Contact testCont = [SELECT Id, Next_Notify_Date__c FROM Contact WHERE Id = :conId];
        Test.stopTest();
        Contact testDelCont = [SELECT Id, Next_Notify_Date__c FROM Contact WHERE Id = :delCon.Id];
        System.assertEquals(Datetime.now().date(), testCont.Next_Notify_Date__c);
        System.assertEquals(null, testDelCont.Next_Notify_Date__c);
    }
}