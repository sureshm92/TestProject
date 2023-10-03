public without sharing class TelevisitTriggerHandler {
    public class NotifyAttendees extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<Id> televisitRecordIdsSet = new List<Id>();
            for (sObject televisitRecord : newList) {
                Televisit__c teleVisObj = (Televisit__c) televisitRecord;

                televisitRecordIdsSet.add(teleVisObj.Id);
            }
            SendRequestToVonageAPI(televisitRecordIdsSet);
            // processSendImmediateEmails(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            alertAttendees((List<Televisit__c>) newList, (Map<Id, Televisit__c>) oldMap);
        }
    }

    public class TelevisitEventTrigger extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            checkForTelevisitEventCreation(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkForTelevisitEventCreation(newList,oldMap);
        }
    }
    public class TelevisitRescheduleTrigger extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkForTelevisitreschedulenotify((List<Televisit__c>) newList, (Map<Id, Televisit__c>) oldMap);
        }
    } 
    
    @TestVisible
    public static void checkForTelevisitreschedulenotify(List<Televisit__c> televisits, Map<Id, Televisit__c> oldMap) {
        List<Id> televisitRecordIdsSet = new List<Id>();
        List<Id> execluderescheemailnotificons = new List<Id>();
        for (Televisit__c televisitRecord : televisits) {
            if(televisitRecord.Visit_Date_Time__c != oldMap.get(televisitRecord.id).Visit_Date_Time__c || televisitRecord.Duration__c != oldMap.get(televisitRecord.id).Duration__c ){
                Televisit__c teleVisObj = (Televisit__c) televisitRecord;
                televisitRecordIdsSet.add(teleVisObj.Id);
                if(televisitRecord.Reshedule_Email_Notification_Check__c != null &&
                   televisitRecord.Reshedule_Email_Notification_Check__c != '' &&
                   televisitRecord.Reshedule_Email_Notification_Check__c.trim() != ''){
                        execluderescheemailnotificons.addAll(televisitRecord.Reshedule_Email_Notification_Check__c.split(';'));
                }
            }
            
        }
        List<Televisit_Attendee__c> listAttendee = [Select id,Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Contact__c,Attendee_Type__c from Televisit_Attendee__c 
                                                    where Televisit__r.Status__c = 'Scheduled' AND Contact__c NOT IN:execluderescheemailnotificons AND Televisit__c IN:televisitRecordIdsSet AND (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff')];
        try{
            List<Notification__c> notifications = new List<Notification__c>();
            for(Televisit_Attendee__c attendee:listAttendee){
                Notification__c notification = new Notification__c();
                notification.Recipient__c = attendee.Contact__c;
                notification.WhatId__c = attendee.Id;
                if(attendee.Televisit__c != null && attendee.Televisit__r.Participant_Enrollment__c != null && 
                   attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                    if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Resche_Janssen';
                    }else{
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Reschedule';
                    }

                }
                notifications.add(notification);
            }
            if(!notifications.isEmpty()){
                insert notifications;
            }

        }catch(exception ex){
            system.debug('++++++++++++++++'+ex.getMessage());
        }

    }

    @TestVisible
    public static void alertAttendees(List<Televisit__c> televisits, Map<Id, Televisit__c> oldMap) {
        List<Id> televisitRecordIdsSet = new List<Id>();
        Map<Id, TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper> updateTelevisitMap = new Map<Id, TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper>();
        for (sObject televisitRecord : televisits) {
            Televisit__c teleVisObj = (Televisit__c) televisitRecord;
            televisitRecordIdsSet.add(teleVisObj.Id);
        }
        List<Televisit__c> televisitsList = [
            SELECT
                Id,
                Status__c,
                Visit_Date_Time__c,Reshedule_Email_Notification_Check__c,
                (
                    SELECT
                        Id,
                        Contact__c,
                        Televisit__c,
                        Attendee_Type__c,
                        Televisit__r.Participant_Enrollment__c,
                        Televisit__r.Participant_Enrollment__r.Participant__c,
                        Televisit__r.Participant_Enrollment__r.Participant__r.Contact__c,
                        Televisit__r.Participant_Enrollment__r.Participant__r.Has_Studies_In_Progress__c
                    FROM Televisit_Attendee__r
                )
            FROM Televisit__c
            WHERE Id IN :televisitRecordIdsSet
        ];
        List<Id> allContactIds = new List<Id>();
        for (Televisit__c teleObj : televisitsList) {
            for (Televisit_Attendee__c teleAttendee : teleObj.Televisit_Attendee__r) {
                if (teleObj.Status__c == 'Cancelled' || teleObj.Status__c == 'Scheduled') {
                    allContactIds.add(teleAttendee.Contact__c);
                }
            }
        }

        //end
        List<Id> cancelledContactIds = new List<Id>();
        List<Id> scheduledContactIds = new List<Id>();
        Map<Id, List<Id>> idMap = new Map<Id, List<Id>>();
        List<Notification__c> notificationsList = new List<Notification__c>();
        List<Televisit_Attendee__c> taList = new List<Televisit_Attendee__c>();
        for (Televisit__c teleObj : televisitsList) {
            list<Id> consetnew ;
            if(teleObj.Reshedule_Email_Notification_Check__c != null &&
               teleObj.Reshedule_Email_Notification_Check__c != '' &&
               teleObj.Reshedule_Email_Notification_Check__c.trim() != ''){
                consetnew = teleObj.Reshedule_Email_Notification_Check__c.split(';');
            }
            if (oldMap != null & oldMap.containsKey(teleObj.Id)) {
                if (
                    oldMap.get(teleObj.Id).Status__c != teleObj.Status__c &
                    teleObj.Status__c == 'Cancelled'
                ) {
                    for (Televisit_Attendee__c teleAttendee : teleObj.Televisit_Attendee__r) {
                        if (
                            teleAttendee.Attendee_Type__c != 'Site Staff' &&
                            teleAttendee.Attendee_Type__c != 'PI'
                        ) {
                            Boolean isdelegate = false;
                            if(teleAttendee.Attendee_Type__c == 'Participant Delegate'){
                                isdelegate = true;
                            }
                            TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper teleVisitWrapperObj = new TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper();
                            teleVisitWrapperObj.notificationType = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED;
                            teleVisitWrapperObj.televisitAttendee = teleAttendee;
                            updateTelevisitMap.put(teleAttendee.Contact__c, teleVisitWrapperObj);
                        notificationsList.add(
                            new Notification__c(
                                Recipient__c = teleAttendee.Contact__c,
                                WhatId__c = teleObj.Id,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_CANCELLED_TYPE,
                                IsDelegate__c = isdelegate
                            )
                        );
                    }
                }
                }
                if (
                    teleObj.Status__c == 'Scheduled' &&
                    //oldMap.get(teleObj.Id).Meeting_URL__c != null &&
                    oldMap.get(teleObj.Id).Visit_Date_Time__c != teleObj.Visit_Date_Time__c
                ) {
                    for (Televisit_Attendee__c teleAttendee : teleObj.Televisit_Attendee__r) {
                        if (
                            teleAttendee.Attendee_Type__c != 'Site Staff' &&
                            teleAttendee.Attendee_Type__c != 'PI' &&
                            (consetnew == null || (consetnew != null && !consetnew.contains(teleAttendee.Contact__c)))
                        ) {
                            Boolean isdelegate = false;
                            if(teleAttendee.Attendee_Type__c == 'Participant Delegate'){
                                isdelegate = true;
                            }
                            TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper teleVisitWrapperObj = new TelevisitAttendeeTriggerHandler.TelevisitUpdateWrapper();
                            teleVisitWrapperObj.notificationType = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED;
                            teleVisitWrapperObj.televisitAttendee = teleAttendee;
                            updateTelevisitMap.put(teleAttendee.Contact__c, teleVisitWrapperObj);
                        notificationsList.add(
                            new Notification__c(
                                Recipient__c = teleAttendee.Contact__c,
                                WhatId__c = teleObj.Id,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_RESCHEDULED_TYPE,
                                IsDelegate__c = isdelegate

                            )
                        );
                        teleAttendee.Is_First_Reminder_Sent__c = false;
                        teleAttendee.Is_Second_Reminder_Sent__c = false;
                        taList.add(teleAttendee);
                    }
                        if (
                            teleAttendee.Attendee_Type__c == 'Site Staff' ||
                            teleAttendee.Attendee_Type__c == 'PI'
                        ) {
                            teleAttendee.Is_First_Reminder_Sent__c = false;
                            teleAttendee.Is_Second_Reminder_Sent__c = false;
                            taList.add(teleAttendee);
                        }
                    
                        
                }
            }
        }
    }
        List<Notification__c> updateRescheduledNotificationsList = TelevisitAttendeeTriggerHandler.getUpdateNotifications(
            updateTelevisitMap
        );
        if (!updateRescheduledNotificationsList.isEmpty()) {
            notificationsList.addAll(updateRescheduledNotificationsList);
        }
        List<SObject> sObjectsList = new List<SObject>();
        if (!taList.isEmpty()) {
            sObjectsList.addAll(taList);
        }
        if (!notificationsList.isEmpty()) {
            sObjectsList.addAll(notificationsList);
        }
        if (sObjectsList.size() > 0) {
            sObjectsList.sort();
            Database.upsert(sObjectsList, false);
        }
    }

    @Future(callout=true)
    public static Void SendRequestToVonageAPI(list<Id> listTelevisitId) {
        TokBoxSettings2__c tokbox = TokBoxSettings2__c.getOrgDefaults();
        List<Televisit__c> televisitRecord = new List<Televisit__c>([SELECT Id,Participant_Enrollment__r.Clinical_Trial_Profile__c,Participant_Enrollment__r.Study_Site__c FROM Televisit__c WHERE Id = :listTelevisitId[0]]);
        String ctpId = televisitRecord[0].Participant_Enrollment__r.Clinical_Trial_Profile__c;
        String studtStiteId = televisitRecord[0].Participant_Enrollment__r.Study_Site__c;
        //List<Televisit_Record_Vendor__c> lstTRV = new List<Televisit_Record_Vendor__c>([SELECT Id,Name,Description__c,API_Key__c, API_Secret__c, Televisit_Vendor__c,Clinical_Trial_Profile__c FROM Televisit_Record_Vendor__c WHERE Clinical_Trial_Profile__c =:ctpId ]);
        List<TelevisitVendorSettings__c> lstTVS = new List<TelevisitVendorSettings__c>([SELECT Id,Televisit_Record_Vendor__c,Televisit_Record_Vendor__r.Clinical_Trial_Profile__c,Televisit_Record_Vendor__r.Name,Televisit_Record_Vendor__r.API_Key__c, Televisit_Record_Vendor__r.API_Secret__c, Study_Site__c from TelevisitVendorSettings__c WHERE Study_Site__c =:studtStiteId AND Televisit_Record_Vendor__r.Clinical_Trial_Profile__c =:ctpId AND isEnable__c = true]);
        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.opentok.com/session/create');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        /*
        req.setHeader(
            'X-OPENTOK-AUTH',
            new OpenTokJWT(
                    tokbox.API_URL__c,
                    tokbox.API_Key__c,
                    tokbox.API_Secret__c
                )
                .getAuthJWTHeader()
        );
        */
        req.setHeader(
            'X-OPENTOK-AUTH',
            new OpenTokJWT(
                    '',
                    lstTVS[0].Televisit_Record_Vendor__r.API_Key__c,
                    lstTVS[0].Televisit_Record_Vendor__r.API_Secret__c
                )
                .getAuthJWTHeader()
        );
        req.setHeader('Accept', 'application/json');
        //req.setBody(null);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        Boolean UnauthorizedToken = res.getBody().contains('Unauthorized token');

        if(!UnauthorizedToken){
            TelevisitWrapper wrap = new TelevisitWrapper();
            wrap = (TelevisitWrapper) System.JSON.deserialize(
                res.getBody().substring(1, res.getBody().length() - 1),
                TelevisitWrapper.class
            );
            system.debug('Wrap Session Id :' + wrap.session_id);
    
            Televisit__c updateTelevisitRecord = new Televisit__c();
            updateTelevisitRecord.Id = televisitRecord[0].Id;
            updateTelevisitRecord.Televisit_Record_Vendor__c = lstTVS[0].Televisit_Record_Vendor__c;
            updateTelevisitRecord.Televisit_Request__c = String.valueOf(req);
            updateTelevisitRecord.Televisit_Response__c = res.getBody();
            updateTelevisitRecord.Session_Id__c = wrap.session_id;
            updateTelevisitRecord.Meeting_URL__c = '/apex/televisit?sessionId=' + wrap.session_id;
            update updateTelevisitRecord;
        }else{
            Televisit__c updateTelevisitRecord = new Televisit__c();
            updateTelevisitRecord.Id = televisitRecord[0].Id;
            updateTelevisitRecord.Televisit_Record_Vendor__c = lstTVS[0].Televisit_Record_Vendor__c;
            updateTelevisitRecord.Televisit_Request__c = String.valueOf(req);
            updateTelevisitRecord.Televisit_Response__c = res.getBody();
            //updateTelevisitRecord.Session_Id__c = wrap.session_id;
            //updateTelevisitRecord.Meeting_URL__c = '/apex/televisit?sessionId=' + wrap.session_id;
            update updateTelevisitRecord;
        }
        
    }

    public static void checkForTelevisitEventCreation(List<SObject> newList){
        datetime currentTime = datetime.now();
        datetime twoDaysAhead = datetime.now().addDays(2);
        Set<Id> televisitIds = new Set<Id>();
        //twoDaysAhead.addDays(2);
        for(sObject televisitRecord : newList){
            Televisit__c teleVisit = (Televisit__c) televisitRecord;
            if(teleVisit.Visit_Link_Activation_End_Time__c >= currentTime && teleVisit.Visit_Link_Activation_End_Time__c <= twoDaysAhead){
                televisitIds.add(teleVisit.Id);
            }
        }
        if(televisitIds.size()>0)
            createTelevisitEvent(televisitIds);
    }
        
    public static void checkForTelevisitEventCreation(List<SObject> newList, Map<Id, SObject> oldMap){
        datetime currentTime = datetime.now();
        datetime twoDaysAhead = datetime.now().addDays(2);
        datetime oneDayBehind = datetime.now().addDays(-1);
        Set<Id> televisitIds = new Set<Id>();
        //twoDaysAhead.addDays(2);
        if(oldMap!=null){
        for(sObject televisitRecord : newList){
            Televisit__c teleVisit = (Televisit__c) televisitRecord;
                Televisit__c oldTeleVisit = (Televisit__c) oldMap.get(teleVisit.Id);
                if((teleVisit.Visit_Link_Activation_End_Time__c >= currentTime && teleVisit.Visit_Link_Activation_End_Time__c <= twoDaysAhead)
                   || (oldTeleVisit.Visit_Date_Time__c >= oneDayBehind && oldTeleVisit.Visit_Date_Time__c <= twoDaysAhead) ){
                televisitIds.add(teleVisit.Id);
            }
        }
        if(televisitIds.size()>0)
            createTelevisitEvent(televisitIds);
        }
    }

    public static void createTelevisitEvent(Set<Id> televisitIds){
        Map<String,Set<Id>> televisitAttendees = new Map<String,Set<Id>>();
        List<Televisit_Event__e> televisitEventInsertion = new List<Televisit_Event__e>();
        for(Televisit_Attendee__c relatedAttendees : [select Id,User__c,Televisit__c from Televisit_Attendee__c where Televisit__c IN:televisitIds]){
            if(televisitAttendees.containsKey(relatedAttendees.Televisit__c)){
                Set<Id> attendeeIds = televisitAttendees.get(relatedAttendees.Televisit__c);
                attendeeIds.add(relatedAttendees.User__c);
                televisitAttendees.put(relatedAttendees.Televisit__c,attendeeIds);
            }else{
                televisitAttendees.put(relatedAttendees.Televisit__c,new Set<Id>{relatedAttendees.User__c});
            }
        }
        for(String visitId : televisitIds){
            if(televisitAttendees.containsKey(visitId)){
                Televisit_Event__e teleEvevent = new Televisit_Event__e();
                teleEvevent.payLoad__c = televisitAttendees.get(visitId).toString();
                televisitEventInsertion.add(teleEvevent);
            }
        }
        system.debug(televisitEventInsertion);
        if(televisitEventInsertion.size()>0)
            EventBus.publish(televisitEventInsertion);
    }

    public static void createTelevisitEvent(){
        Televisit_Event__e teleEvevent = new Televisit_Event__e();
        teleEvevent.payLoad__c = 'DELETE';
        EventBus.publish(teleEvevent);
    }

    public class TelevisitWrapper {
        public string session_id { get; set; }
    }
}