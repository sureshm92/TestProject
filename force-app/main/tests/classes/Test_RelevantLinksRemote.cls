/**
 * Created by Nargiz Mamedova on 3/3/2020.
 */

@IsTest
public class Test_RelevantLinksRemote {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    public static void emptyResources_Test() {
        TestData td = new TestData();
        RelevantLinksRemote.InitData initData = new RelevantLinksRemote.InitData();

        Test.startTest();
        System.runAs(td.participantUser) {
            initData = RelevantLinksRemote.getInitData();
        }
        Test.stopTest();
        System.assertEquals('Relevant Link', initData.linksWrappers[0].type.value);
    }

    @IsTest
    public static void visibleResource_Test() {
        TestData td = new TestData();
        RelevantLinksRemote.InitData initData = new RelevantLinksRemote.InitData();
        Resource__c relLink = new Resource__c(
            Content_Type__c = 'Relevant_Link',
            Title__c = 'Test',
            Type__c = 'Helpful Link',
            URL__c = 'https://www.google.com/',
            Languages__c = 'en_US'
        );
        insert relLink;

        List<Resource__c> resources = [
            SELECT Id
            FROM Resource__c
            WHERE Content_Type__c = 'Relevant_Link'
        ];
        Res_study__c resStudy = new Res_study__c(
            Resource__c = resources[0].Id,
            Clinical_Trial_Profile__c = td.ctp.Id,
            Visible_To_Participant__c = true
        );
        insert resStudy;

        Test.startTest();
        System.runAs(td.participantUser) {
            initData = RelevantLinksRemote.getInitData();
        }
        Test.stopTest();
        System.assertEquals('Test', initData.linksWrappers[0].resources[0].resource.Title__c);
    }

    @IsTest
    public static void alumniVisibleResource_Test() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TestData td = new TestData();
        RelevantLinksRemote.InitData initData = new RelevantLinksRemote.InitData();
        Resource__c relLink = new Resource__c(
            Content_Type__c = 'Relevant_Link',
            Title__c = 'Test',
            Type__c = 'Helpful Link',
            URL__c = 'https://www.google.com/',
            Languages__c = 'en_US'
        );
        insert relLink;

        List<Resource__c> resources = [
            SELECT Id
            FROM Resource__c
            WHERE Content_Type__c = 'Relevant_Link'
        ];
        Res_study__c resStudy = new Res_study__c(
            Resource__c = resources[0].Id,
            Clinical_Trial_Profile__c = td.ctp.Id,
            Visible_To_Participant__c = true,
            Visible_In_Alumni__c = true
        );
        insert resStudy;

        td.pe.Participant_Status__c = PEStatusState.PE_STATUS_GROUP_ALUMNI.get(0);
        update td.pe;
        td.participant.Contact__r.Current_Participant_Enrollment__c = null;
        update td.participant.Contact__r;

        Test.startTest();
        System.runAs(td.participantUser) {
            initData = RelevantLinksRemote.getInitData();
        }
        Test.stopTest();
        System.assertEquals('Test', initData.linksWrappers[0].resources[0].resource.Title__c);
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            RelevantLinksRemote.getInitData();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assertEquals(true, isExceptionThrown);
    }
}
