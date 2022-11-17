@IsTest
public class SiteCalendarController_Test {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @Istest
    public static void testDataForIntandTele(){ 
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            TelevisitTriggerHandler.TelevisitEventTrigger.class
        );
        TriggerHandlerExecutor.bypassHandler(
            TelevisitTriggerHandler.NotifyAttendees.class
        );
        Participant_Enrollment__c pRec = [Select Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c 
                                          From Participant_Enrollment__c LIMIT 1];
        pRec.Initial_visit_scheduled_date__c = Date.newInstance(2022, 4, 29);
        pRec.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        update pRec;
        Televisit__c visit = new Televisit__c();
        visit.Title__c = 'Test Class Meet';
        visit.Duration__c = '15 minutes';
        visit.Source_Community__c = 'IQVIA Referral Hub';
        visit.Visit_Date_Time__c = Datetime.newInstance(2022,4, 29, 12, 30, 2);
        visit.Visit_End_Date_Time__c = Datetime.now().addMinutes(15);
        visit.Participant_Enrollment__c = testData.pe.Id;
        visit.Status__c = 'Scheduled';
        insert visit;
        Televisit_Attendee__c attendee = new Televisit_Attendee__c ();
        attendee.Attendee_Type__c = 'PI';
        attendee.Televisit__c = visit.Id;
        attendee.User__c = UserInfo.getUserId();

        Televisit_Attendee__c attendee2 = new Televisit_Attendee__c ();
        attendee2.Attendee_Type__c = 'Participant';
        attendee2.Televisit__c = visit.Id;
        attendee2.Attendee_Email__c = 'test452@test.com';
        attendee2.Contact__c = testData.participant.Contact__c;

        List<Televisit_Attendee__c> attendeeLst = new List<Televisit_Attendee__c>();
        attendeeLst.add(attendee);
        attendeeLst.add(attendee2);
        insert attendeeLst;

        
        Test.startTest();
        System.runAs(testData.piUser) {
         
        Date myDate = Date.newInstance(2022, 4, 29);        
   
        SiteCalendarController.filterWrapper fl = new SiteCalendarController.filterWrapper();
        fl.calendarDate = mydate;
        List<String> study = new List<String>();
        study.add(testData.ctp.Id);
        List<String> studyListSite = new List<String>();
        studyListSite.add(testData.ss.Id);
        fl.study = study;
        fl.studySite = studyListSite;
        string flw = JSON.serialize(fl);
        
        
        SiteCalendarController.recordsOfTeleAndInitialVisit(flw);
        }
        Test.stopTest(); 
    }
    
}