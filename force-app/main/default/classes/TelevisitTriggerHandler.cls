public class TelevisitTriggerHandler {
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

    @TestVisible
    public static void alertAttendees(List<Televisit__c> televisits, Map<Id, Televisit__c> oldMap) {
        List<Id> televisitRecordIdsSet = new List<Id>();
        for (sObject televisitRecord : televisits) {
            Televisit__c teleVisObj = (Televisit__c) televisitRecord;
            televisitRecordIdsSet.add(teleVisObj.Id);
        }
        List<Televisit__c> televisitsList = [
            SELECT
                Id,
                Status__c,
                Visit_Date_Time__c,
                (SELECT Id, Contact__c, Attendee_Type__c FROM Televisit_Attendee__r)
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
        //fetching delegates code
        List<Patient_Delegate__c> patientDelegates = [
            SELECT Participant__r.Contact__c, Contact__c, Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :allContactIds
        ];
        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();
        for (Id conId : allContactIds)
            if (!participantIdsByDelegates.containsKey(conId)) {
                participantIdsByDelegates.put(conId, new List<Patient_Delegate__c>());
            }
        for (Patient_Delegate__c pd : patientDelegates) {
            allContactIds.add(pd.Contact__c);
            participantIdsByDelegates.get(pd.Participant__r.Contact__c).add(pd);
        }

        //end
        List<Id> cancelledContactIds = new List<Id>();
        List<Id> scheduledContactIds = new List<Id>();
        Map<Id, List<Id>> idMap = new Map<Id, List<Id>>();
        List<Notification__c> notificationsList = new List<Notification__c>();
        for (Televisit__c teleObj : televisitsList) {
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
                        Id delegateContactId = getPrimaryDelegateContactId(
                            participantIdsByDelegates,
                            teleAttendee.Contact__c
                        );
                        notificationsList.add(
                            new Notification__c(
                                Recipient__c = teleAttendee.Contact__c,
                                WhatId__c = teleObj.Id,
                                Notification_Type__c = 'Message_to_PT_Televisit_Cancelled_Type'
                            )
                        );
                        if (delegateContactId != null) {
                            notificationsList.add(
                                new Notification__c(
                                    Recipient__c = getPrimaryDelegateContactId(
                                        participantIdsByDelegates,
                                        teleAttendee.Contact__c
                                    ),
                                    WhatId__c = teleObj.Id,
                                    Notification_Type__c = 'Message_to_PT_Televisit_Cancelled_Del_Ty'
                                )
                            );
                        }
                    }
                }
                }
                if (
                    teleObj.Status__c == 'Scheduled' &&
                    oldMap.get(teleObj.Id).Meeting_URL__c != null &&
                    oldMap.get(teleObj.Id).Visit_Date_Time__c != teleObj.Visit_Date_Time__c
                ) {
                    for (Televisit_Attendee__c teleAttendee : teleObj.Televisit_Attendee__r) {
                        if (
                            teleAttendee.Attendee_Type__c != 'Site Staff' &&
                            teleAttendee.Attendee_Type__c != 'PI'
                        ) {
                        Id delegateContactId = getPrimaryDelegateContactId(
                            participantIdsByDelegates,
                            teleAttendee.Contact__c
                        );
                        notificationsList.add(
                            new Notification__c(
                                Recipient__c = teleAttendee.Contact__c,
                                WhatId__c = teleObj.Id,
                                Notification_Type__c = 'Message_to_PT_Televisit_Rescheduled_Type'
                            )
                        );
                        if (delegateContactId != null) {
                            notificationsList.add(
                                new Notification__c(
                                    Recipient__c = getPrimaryDelegateContactId(
                                        participantIdsByDelegates,
                                        teleAttendee.Contact__c
                                    ),
                                    WhatId__c = teleObj.Id,
                                    Notification_Type__c = 'Message_to_PT_Televisit_Rescheduled_Del'
                                )
                            );
                        }
                    }
                }
            }
        }
        }
        if (!notificationsList.isEmpty()) {
            insert notificationsList;
        }
    }

    public static Id getPrimaryDelegateContactId(
        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates,
        Id contactId
    ) {
        if (participantIdsByDelegates.size() > 0) {
            if (participantIdsByDelegates.get(contactId).size() == 1) {
                List<Patient_Delegate__c> pdList = participantIdsByDelegates.get(contactId);
                return pdList[0].Contact__c;
            } else if (participantIdsByDelegates.get(contactId).size() > 1) {
                for (Patient_Delegate__c del : participantIdsByDelegates.get(contactId)) {
                    if (del.Primary_Delegate__c) {
                        return del.Contact__c;
                    }
                }
            }
        }
        return null;
    }
    @Future(callout=true)
    public static Void SendRequestToVonageAPI(list<Id> listTelevisitId) {
        Televisit__c televisitRecord = [SELECT Id FROM Televisit__c WHERE Id = :listTelevisitId[0]];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.opentok.com/session/create');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader(
            'X-OPENTOK-AUTH',
            new OpenTokJWT(
                    'https://api.opentok.com',
                    '47459271',
                    'eb094c1b6355f340f708c92f6151cc8377097f24'
                )
                .getAuthJWTHeader()
        );
        req.setHeader('Accept', 'application/json');
        //req.setBody(null);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());

        TelevisitWrapper wrap = new TelevisitWrapper();
        wrap = (TelevisitWrapper) System.JSON.deserialize(
            res.getBody().substring(1, res.getBody().length() - 1),
            TelevisitWrapper.class
        );
        system.debug('Wrap Session Id :' + wrap.session_id);

        Televisit__c updateTelevisitRecord = new Televisit__c();
        updateTelevisitRecord.Id = televisitRecord.Id;
        updateTelevisitRecord.Televisit_Request__c = String.valueOf(req);
        updateTelevisitRecord.Televisit_Response__c = res.getBody();
        updateTelevisitRecord.Session_Id__c = wrap.session_id;
        updateTelevisitRecord.Meeting_URL__c = '/apex/televisit?sessionId=' + wrap.session_id;
        update updateTelevisitRecord;
    }

    public class TelevisitWrapper {
        public string session_id { get; set; }
    }
}