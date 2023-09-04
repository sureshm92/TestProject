/**
 * Created by Gaurav Saxena
 */
@isTest
public class Action_SendPush_Test {
    private static Action action;

    @testSetup
    static void setup() {
        TestData.loadTestData();
        TriggerHandlerExecutor.bypassHandler(
            NotificationTriggerHandler.SendNotificationHandler.class
        );
        Participant_Enrollment__c pe = [
            SELECT Id, Participant__r.Contact__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        Contact con = [SELECT Id FROM Contact WHERE firstname = 'PITD' LIMIT 1];

        Task t = new Task();
        t.WhoId = con.id;
        insert t;

        List<Notification__c> newList = new List<Notification__c>();
        Notification__c notifyForTest = new Notification__c(
            Notification_Type__c = 'PP_RH_Push_Notification',
            Recipient__c = pe.Participant__r.Contact__c,
            WhatId__c = pe.Id
        );
        newList.add(notifyForTest);

        Notification__c notifyForTest1 = new Notification__c(
            Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type',
            Recipient__c = pe.Participant__r.Contact__c,
            Task_Id__c = t.Id,
            WhatId__c = pe.Id
        );
        newList.add(notifyForTest1);

        insert newList;

        Action__c ac = new Action__c();
        ac.Body__c = 'test_Action';
        insert ac;

        Execution_History__c eh = new Execution_History__c();
        eh.Detail__c = 'test_Execution_History';
        eh.Action__c = ac.Id;
        insert eh;
    }

    static testMethod void Action_SendPush_Test() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Action__c ac = [SELECT Id FROM Action__c LIMIT 1];
        Execution_History__c eh = [SELECT Id FROM Execution_History__c LIMIT 1];

        List<Notification__c> notification = [
            SELECT Id
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type'
        ];

        Action_SendPush actionSend = new Action_SendPush(notification);
        actionSend.execute();
        actionSend.getType();
        actionSend.isDMLWithSetupObjects();
        actionSend.postDML(ac, eh);

        NotificationResultService nr = new NotificationResultService(notification);
        nr.setFailed(notification[0].id, 'PT_Task_Reminder_Vis_PUSH', 'errorMessage');
        nr.setSkipped(notification[0].id, 'PT_Task_Reminder_Vis_PUSH');
        nr.setInProgress(notification[0].id, 'PT_Task_Reminder_Vis_PUSH');
        nr.setInProgressPush(
            notification[0].id,
            'PP_RH_Push_Notification',
            'pushTitle',
            'messageBody'
        );

        Test.stopTest();
    }

    static testMethod void Action_SendSMS_Test_1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Action__c ac = [SELECT Id FROM Action__c LIMIT 1];
        Execution_History__c eh = [SELECT Id FROM Execution_History__c LIMIT 1];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Participant__c pa = [SELECT Id, Alternative_Phone_Type__c FROM Participant__c LIMIT 1];
        pa.Alternative_Phone_Type__c = 'Mobile';
        update pa;

        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c, Recipient__c, isdelegate__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type'
        ];
        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        insert sr;

        Action_SendSMS actionSend = new Action_SendSMS(notification);
        actionSend.execute();
        actionSend.getType();
        actionSend.isDMLWithSetupObjects();
        actionSend.postDML(ac, eh);
        Test.stopTest();
    }

    static testMethod void Action_SendSMS_Test_2() {
        Action__c ac = [SELECT Id FROM Action__c LIMIT 1];
        Execution_History__c eh = [SELECT Id FROM Execution_History__c LIMIT 1];

        Contact con = [
            SELECT Id, firstname, MobilePhone
            FROM Contact
            WHERE firstname = 'PITD'
            LIMIT 1
        ];
        con.MobilePhone = '1234567891';
        update con;
        system.debug('con.id: ' + con.Id);

        Participant__c pa = [
            SELECT Id, Alternative_Phone_Type__c, First_Name__c
            FROM Participant__c
            LIMIT 1
        ];
        pa.Alternative_Phone_Type__c = 'Mobile';
        pa.Contact__c = con.Id;
        //pa.First_Name__c = 'test_Name';
        update pa;

        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c, isdelegate__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type'
            LIMIT 1
        ];
        notification[0].Recipient__c = con.id;
        update notification;

        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        insert sr;
        Test.startTest();
        Action_SendSMS actionSend = new Action_SendSMS(notification);
        Test.setMock(HttpCalloutMock.class, new RemoteCallHttpCalloutMock());
        //actionSend.log = il;
        actionSend.execute();
        actionSend.getType();
        actionSend.isDMLWithSetupObjects();
        actionSend.postDML(ac, eh);
        Test.stopTest();
    }
    static testMethod void Action_SendSMS_Test_3() {
        Action__c ac = [SELECT Id FROM Action__c LIMIT 1];
        Execution_History__c eh = [SELECT Id FROM Execution_History__c LIMIT 1];

        Contact con = [
            SELECT Id, firstname, MobilePhone
            FROM Contact
            WHERE firstname = 'PITD'
            LIMIT 1
        ];
        con.MobilePhone = '1234567891';
        update con;
        system.debug('con.id: ' + con.Id);

        Participant__c pa = [
            SELECT Id, Alternative_Phone_Type__c, First_Name__c
            FROM Participant__c
            LIMIT 1
        ];
        pa.Alternative_Phone_Type__c = 'Mobile';
        pa.Contact__c = con.Id;
        //pa.First_Name__c = 'test_Name';
        update pa;
        Participant_Enrollment__c pe = [
            SELECT Id, Participant__r.Contact__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Task_Type__c = 'Visit';
        task.Visible_For__c = 'Owner;Delegates';
        task.WhatId = pe.Id;
        insert task;

        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c, Recipient__c, isdelegate__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type'
            LIMIT 1
        ];

        notification[0].WhatId__c = task.id;
        notification[0].Recipient__c = con.id;

        update notification;

        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        insert sr;
        Test.startTest();
        Action_SendSMS actionSend = new Action_SendSMS(notification);
        Test.setMock(HttpCalloutMock.class, new RemoteCallHttpCalloutMock());
        //actionSend.log = il;
        actionSend.execute();
        actionSend.getType();
        actionSend.isDMLWithSetupObjects();
        actionSend.postDML(ac, eh);
        Test.stopTest();
    }
    static testMethod void Action_SendSMS_Test4() {
        Action__c ac = [SELECT Id FROM Action__c LIMIT 1];
        Execution_History__c eh = [SELECT Id FROM Execution_History__c LIMIT 1];

        Contact con = [
            SELECT Id, firstname, MobilePhone
            FROM Contact
            WHERE firstname = 'PITD'
            LIMIT 1
        ];
        con.MobilePhone = '1234567891';
        update con;
        system.debug('con.id: ' + con.Id);

        Participant__c pa = [
            SELECT Id, Alternative_Phone_Type__c, First_Name__c
            FROM Participant__c
            LIMIT 1
        ];
        pa.Alternative_Phone_Type__c = 'Mobile';
        pa.Contact__c = con.Id;
        //pa.First_Name__c = 'test_Name';
        update pa;

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ReminderDateTime = Datetime.now();
        task.Task_Type__c = 'Visit';
        task.Visible_For__c = 'Owner;Delegates';
        task.WhatId = pa.Id;
        insert task;

        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c, Recipient__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type'
            LIMIT 1
        ];

        notification[0].WhatId__c = task.id;
        notification[0].Recipient__c = con.id;

        update notification;

        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        insert sr;
        Test.startTest();
        Action_SendSMS actionSend = new Action_SendSMS(notification);
        Test.setMock(HttpCalloutMock.class, new RemoteCallHttpCalloutMock());
        //actionSend.log = il;
        actionSend.execute();
        actionSend.getType();
        actionSend.isDMLWithSetupObjects();
        actionSend.postDML(ac, eh);
        Test.stopTest();
    }
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            string fullJsonNew = '{ "applicationId": "90a75d33b4fb4e2da5ef354fc063d572", "requestId": "03c61dd5-3846-4cfd-8a6d-b7a311967200", "result": [ { "toNumber": "+187893434", "status": { "deliveryStatus": "SUCCESSFUL", "statusCode": 200, "statusMessage": "MessageId: ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0", "messageId": "ut0ehaifvdfkcho0sqff41c6bkvh25oodcnb98g0" } } ] }';
            /*String fullJson = '{"id":"prod_IJuCyGwTYK3MFI","object":"product","active":true,"attributes":[],"created":1604374830,"description":"Clean your home with all green, make-at-home, products.","images":[],"livemode":false,"metadata":{},"name":"Make your Own Scented All-Purpose Cleaner (Author: HotDogMan)","statement_descriptor":"123","unit_label":"abc","updated":1604374831}';   */
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJsonNew);
            res.setStatusCode(200);
            return res;
        }
    }
}
