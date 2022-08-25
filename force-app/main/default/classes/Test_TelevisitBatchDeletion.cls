@IsTest
public class Test_TelevisitBatchDeletion {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testTelevisitBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
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
        List<TV_Connection__c> tvConLst = new List<TV_Connection__c>();
        TV_Connection__c tcCon1= new TV_Connection__c(Televisit_Attendee__c=attendee.Id);
        tvConLst.add(tcCon1);
        TV_Connection__c tcCon2= new TV_Connection__c(Televisit_Attendee__c=attendee2.Id);
        tvConLst.add(tcCon2);
        insert tvConLst;
        
		Database.executeBatch(new TelevisitBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Televisit__c> telVisitLst=[SELECT Id from Televisit__c where Participant_Enrollment__c=:enroll.Id limit 10];
        System.assertEquals(1,telVisitLst.size());
        
    }
    @IsTest
    static void testTelevisitBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
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
        List<TV_Connection__c> tvConLst = new List<TV_Connection__c>();
        TV_Connection__c tcCon1= new TV_Connection__c(Televisit_Attendee__c=attendee.Id);
        tvConLst.add(tcCon1);
        TV_Connection__c tcCon2= new TV_Connection__c(Televisit_Attendee__c=attendee2.Id);
        tvConLst.add(tcCon2);
        insert tvConLst;
        
		Database.executeBatch(new TelevisitBatchDeletion(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Televisit__c> telVisitLst=[SELECT Id from Televisit__c where Participant_Enrollment__c=:enroll.Id limit 10];
        System.assertEquals(0,telVisitLst.size());
        
    }
}