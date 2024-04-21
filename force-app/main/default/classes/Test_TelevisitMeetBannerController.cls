@IsTest
public class Test_TelevisitMeetBannerController {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testTelevisitBanner() {
        Participant_Enrollment__c  enroll = [select Id,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        
        Participant__c participant = new Participant__c(id=enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        TriggerHandlerExecutor.bypassHandler(
                                TelevisitTriggerHandler.TelevisitEventTrigger.class
                            );
        TriggerHandlerExecutor.bypassHandler(
                                TelevisitTriggerHandler.NotifyAttendees.class
                            );
        Televisit__c visit = new Televisit__c();
        visit.Title__c = 'Test Class Meet';
        visit.Duration__c = '15 minutes';
        visit.Source_Community__c = 'IQVIA Referral Hub';
        visit.Visit_Date_Time__c = Datetime.now();
        visit.Visit_End_Date_Time__c = Datetime.now().addMinutes(15);
        visit.Participant_Enrollment__c = enroll.Id;
        visit.Status__c = 'Scheduled';
        insert visit;
        Televisit_Attendee__c attendee = new Televisit_Attendee__c ();
        attendee.Attendee_Type__c = 'PI';
        attendee.Televisit__c = visit.Id;
        attendee.User__c = UserInfo.getUserId();
        
        Televisit_Attendee__c attendee2 = new Televisit_Attendee__c ();
        attendee2.Attendee_Type__c = 'Participant';
        attendee2.Televisit__c = visit.Id;
        attendee2.Attendee_Email__c = 'melisha.dsa@iqvia.com';
        attendee2.Contact__c = con.Id;
        
        List<Televisit_Attendee__c> attendeeLst = new List<Televisit_Attendee__c>();
        attendeeLst.add(attendee);
        attendeeLst.add(attendee2);
        insert attendeeLst;
        TelevisitMeetBannerController.getSessionId();
        TelevisitMeetBannerController.getVisits('IQVIA Referral Hub','PI');
    }
}