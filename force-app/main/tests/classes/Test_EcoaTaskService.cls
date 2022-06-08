@IsTest
public class Test_EcoaTaskService {
    public class ECOAServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"siteGuid":"test","ecoaResponseID":"1233"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class ECOAServiceStub implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            /*if (stubbedMethodName == 'execute') {
                return null;
            }*/
            return null;
        }
    }
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testBehavior() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        Participant_Enrollment__c pe = [
            SELECT id, Subject_GUID__c, Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c = :ctp.id
            LIMIT 1
        ];
        pe.Subject_GUID__c = null;
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;
        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;
        List<Participant_Enrollment__c> peList = [
            SELECT Id, Study_Site__c, Clinical_Trial_Profile__c, Participant_Status__c
            FROM Participant_Enrollment__c
        ];
        Participant_Enrollment__c per = new Participant_Enrollment__c();
        if (!peList.isEmpty()) {
            //pesh.Date__c = DateTime.now();
            per.Id = peList[0].Id;
            per.Participant_Status__c = 'Enrollment Success';
            update per;
        }
        Ecoa_Task_Configuration__c etc = new Ecoa_Task_Configuration__c();
        etc.Diary_Name__c = 'Test Diary';
        etc.Participant_Enrollment__c = per.Id;
        etc.Window_Begin__c = Datetime.now().addDays(1);
        etc.Window_End__c = Datetime.now().addDays(2);
        etc.Diary_Start_Date__c = Datetime.now().addDays(1);
        etc.Diary_End_Date__c = Datetime.now().addDays(2);
        etc.Reminder_config__c = 12;
        insert etc;

        Batch_CreateEcoaTasks obj = new Batch_CreateEcoaTasks();
        DataBase.executeBatch(obj);

        obj.getBatchDescription();
        obj.getType();
        obj.getRecommendedRelaunchInterval();
        obj.getRecommendedScopeSize();
        Test.stopTest();
    }
    @IsTest
    static void testCompleteTaskBatch() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        Participant_Enrollment__c pe = [
            SELECT
                id,
                Subject_GUID__c,
                Participant_Status__c,
                Participant__c,
                Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c = :ctp.id
            LIMIT 1
        ];
        pe.Subject_GUID__c = null;
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;
        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;
        List<Participant_Enrollment__c> peList = [
            SELECT Id, Study_Site__c, Clinical_Trial_Profile__c, Participant_Status__c
            FROM Participant_Enrollment__c
        ];
        Participant_Enrollment__c per = new Participant_Enrollment__c();
        if (!peList.isEmpty()) {
            //pesh.Date__c = DateTime.now();
            per.Id = peList[0].Id;
            per.Participant_Status__c = 'Enrollment Success';
            update per;
        }
        Ecoa_Task_Configuration__c etc = new Ecoa_Task_Configuration__c();
        etc.Diary_Name__c = 'Test Diary';
        etc.Participant_Enrollment__c = per.Id;
        etc.Window_Begin__c = Datetime.now().addDays(1);
        etc.Window_End__c = Datetime.now().addDays(2);
        etc.Diary_Start_Date__c = Datetime.now().addDays(1);
        etc.Diary_End_Date__c = Datetime.now().addDays(2);
        etc.Reminder_config__c = 12;
        etc.IsProcessed__c = true;
        insert etc;

        Task t = new Task();
        t.Subject = 'Ediary';
        t.Priority = 'Normal';
        t.Start_Date__c = date.newinstance(
            Datetime.now().year(),
            Datetime.now().month(),
            Datetime.now().day()
        );
        t.Ecoa_Task_Configuration_del__c = etc.Id;
        t.WhatId = pe.Participant__c; // Participant id
        t.WhoId = pe.Participant_Contact__c; // contact id
        t.Task_Type__c = TaskService.TASK_TYPE_ECOA;
        insert t;

        Batch_CompleteEcoaTasks obj = new Batch_CompleteEcoaTasks();
        DataBase.executeBatch(obj);

        obj.getBatchDescription();
        obj.getType();
        obj.getRecommendedRelaunchInterval();
        obj.getRecommendedScopeSize();
        Test.stopTest();
    }
    @IsTest
    static void testBehaviorCompletedTask() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        Participant_Enrollment__c pe = [
            SELECT
                id,
                Subject_GUID__c,
                Participant_Status__c,
                Participant__c,
                Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c = :ctp.id
            LIMIT 1
        ];
        pe.Subject_GUID__c = null;
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;
        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;
        List<Participant_Enrollment__c> peList = [
            SELECT Id, Study_Site__c, Clinical_Trial_Profile__c, Participant_Status__c
            FROM Participant_Enrollment__c
        ];
        Participant_Enrollment__c per = new Participant_Enrollment__c();
        if (!peList.isEmpty()) {
            //pesh.Date__c = DateTime.now();
            per.Id = peList[0].Id;
            per.Participant_Status__c = 'Enrollment Success';
            update per;
        }
        Ecoa_Task_Configuration__c etc = new Ecoa_Task_Configuration__c();
        etc.Diary_Name__c = 'Test Diary';
        etc.Participant_Enrollment__c = per.Id;
        etc.Window_Begin__c = Datetime.now().addDays(1);
        etc.Window_End__c = Datetime.now().addDays(2);
        etc.Diary_Start_Date__c = Datetime.now().addDays(1);
        etc.Diary_End_Date__c = Datetime.now().addDays(2);
        etc.Reminder_config__c = 12;
        etc.IsProcessed__c = true;
        insert etc;

        Task t = new Task();
        t.Subject = 'Ediary';
        t.Priority = 'Normal';
        t.Start_Date__c = date.newinstance(
            Datetime.now().year(),
            Datetime.now().month(),
            Datetime.now().day()
        );
        t.Ecoa_Task_Configuration_del__c = etc.Id;
        t.WhatId = pe.Participant__c; // Participant id
        t.WhoId = pe.Participant_Contact__c; // contact id
        insert t;

        etc.Diary_Status__c = 'completed';
        update etc;
        Test.stopTest();
    }
    @IsTest
    static void patientVisitCompletion() {
        Test.startTest();
        ECOAService.setMock(new ECOAServiceStub());
        TestData testData = new TestData();
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        Visit__c visit = new Visit__c(Visit_Plan__c = vp.Id);
        insert visit;

        Patient_Visit__c patientVisit = new Patient_Visit__c(
            Participant_Enrollment__c = testData.pe.Id,
            Visit__c = visit.Id,
            Visit_Number__c = 1,
            SDH_Key__c = '1~2~3' + 'New Visit' + Date.today()
        );
        insert patientVisit;
        patientVisit.Status__c = 'Completed';
        patientVisit.Completed_Date__c = Date.today();
        update patientVisit;
        Test.stopTest();
    }
}