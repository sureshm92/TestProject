@IsTest
public class Test_BookingBatchDeletion {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testBoookingBatchDel_False() {
        List<Booking__c> bookLst= new List<Booking__c>();
        List<Patient_Visit__c> visitPLst = new list<Patient_Visit__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Patient_Visit__c visit = new Patient_Visit__c();
            visit.Name = 'New Visit';
            visit.Completed_Date__c = Date.today();
            visit.Participant_Enrollment__c = peRec.Id;
            visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
            visitPLst.add(visit);
        }
        insert visitPLst;
        Booking__c bookTest1= new Booking__c(Participant_Enrollment__c=peRecs[0].Id,Patient_Visit__c=visitPLst[0].Id,Status__c='Confirmed',Title__c='test1');
        bookLst.add(bookTest1);
        Booking__c bookTest2= new Booking__c(Participant_Enrollment__c=peRecs[1].Id,Patient_Visit__c=visitPLst[1].Id,Status__c='Confirmed',Title__c='test1');
        bookLst.add(bookTest2);
        insert bookLst;
        Test.startTest();
		Database.executeBatch(new BookingBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Booking__c> bookingsLst=[SELECT Id from Booking__c where Title__c='test1' limit 10];
        System.assertEquals(2,bookingsLst.size());
    }
    @IsTest
    static void testBoookingBatchDel_True() {
        List<Booking__c> bookLst= new List<Booking__c>();
        List<Patient_Visit__c> visitPLst = new list<Patient_Visit__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Patient_Visit__c visit = new Patient_Visit__c();
            visit.Name = 'New Visit';
            visit.Completed_Date__c = Date.today();
            visit.Participant_Enrollment__c = peRec.Id;
            visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
            visitPLst.add(visit);
        }
        insert visitPLst;
        Booking__c bookTest1= new Booking__c(Participant_Enrollment__c=peRecs[0].Id,Patient_Visit__c=visitPLst[0].Id,Status__c='Confirmed',Title__c='test1');
        bookLst.add(bookTest1);
        Booking__c bookTest2= new Booking__c(Participant_Enrollment__c=peRecs[1].Id,Patient_Visit__c=visitPLst[1].Id,Status__c='Confirmed',Title__c='test1');
        bookLst.add(bookTest2);
        insert bookLst;
        Test.startTest();
		Database.executeBatch(new BookingBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Booking__c> bookingsLst=[SELECT Id from Booking__c where Title__c='test1' limit 10];
        System.assertEquals(0,bookingsLst.size());
    }
}