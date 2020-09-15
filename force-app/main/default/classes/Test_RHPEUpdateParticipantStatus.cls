@isTest(SeeAllData=true)
public class Test_RHPEUpdateParticipantStatus {
    
    @isTest
    static void updatePEStatus() {
        
        TestData.loadTestData();
		TestData testDataInstance = new TestData();
        testDataInstance.ss.Study_Site_Type__c = 'Virtual';
        update testDataInstance.ss;
        List<Participant_Enrollment__c> pelist = new List<Participant_Enrollment__c>();
        pelist.add(testDataInstance.pe);
        Test.setMock(HttpCalloutMock.class, new RHPECalloutMock());
        Test.startTest();
        Batch_RHPEUpdateParticipantStatus c = new Batch_RHPEUpdateParticipantStatus();
        Database.executeBatch(c);
        c.getType();
        c.getBatchDescription();
        c.getRecommendedIntervalMode();
        c.getRecommendedRelaunchInterval();
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Batch_RHPEUpdateParticipant_Scheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
    public class RHPECalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            return response;
        }
    }
}