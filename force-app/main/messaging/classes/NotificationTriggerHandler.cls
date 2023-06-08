/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

public without sharing class NotificationTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckFieldsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkFieldsForNotification(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            //Start Change:RH-8945
            List<Notification__c> bellNotification = new List<Notification__c>();
            List<Notification__c> emailSMSPushNotification = new List<Notification__c>();
            for (Notification__c eachRec : (List<Notification__c>) newList) {
                if (eachRec.Notification_Type__c.startsWith('BELL_')) {
                    bellNotification.add(eachRec);
                } else {
                    emailSMSPushNotification.add(eachRec);
                }
            }

            if (bellNotification.size() > 0) {
                sendBellNotificationToRecipients(bellNotification);
            }

            if (emailSMSPushNotification.size() > 0) {
                sendNotificationToRecipient(emailSMSPushNotification);
            }
            //End Change:RH-8945
        }
    }

    public class UpdateNotificationHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            processUpdateNotification(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            processUpdateNotification(newList);
        }
        public void processUpdateNotification(List<SObject> newList) {
            List<Id> recipIds = new List<Id>();
            List<Id> whatIds = new List<Id>();
            Map<String, Notification__c> mapwhatIdOfIds = new Map<String, Notification__c>();
            List<String> notificationsTypeList = new List<String>();
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED);
            for (Notification__c notificationObj : [
                SELECT Id, WhatId__c, Target_Record_Ids__c, Recipient__c, Notification_Type__c
                FROM Notification__c
                WHERE
                    Id = :newList
                    AND Notification_Type__c IN :notificationsTypeList
                    AND Status__c != 'Processed'
            ]) {
                recipIds.add(notificationObj.Recipient__c);
                whatIds.add(notificationObj.WhatId__c);
            }
            List<Notification__c> deleteNoti = new List<Notification__c>();
            notificationsTypeList.clear();
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED);
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED);

            for (Notification__c notificationObj : [
                SELECT Id, Target_Record_Ids__c, Recipient__c, WhatId__c, Notification_Type__c
                FROM Notification__c
                WHERE
                    Notification_Type__c IN :notificationsTypeList
                    AND Status__c != 'Processed'
                    AND Recipient__c IN :recipIds
                    AND WhatId__c IN :whatIds
            ]) {
                String notifyType = '';
                if (
                    notificationObj.Notification_Type__c ==
                    NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED
                ) {
                    notifyType = 'Rescheduled';
                }
                if (
                    notificationObj.Notification_Type__c ==
                    NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED
                ) {
                    notifyType = 'Canceled';
                }
                if (
                    notificationObj.Notification_Type__c ==
                    NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED
                ) {
                    notifyType = 'Scheduled';
                }
                mapwhatIdOfIds.put(
                    notificationObj.WhatId__c +
                    ':' +
                    notificationObj.Recipient__c +
                    ':' +
                    notifyType,
                    notificationObj
                );
            }
            notificationsTypeList.clear();
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
            notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED);
            for (Notification__c notificationObj : [
                SELECT Id, WhatId__c, Target_Record_Ids__c, Recipient__c, Notification_Type__c
                FROM Notification__c
                WHERE
                    Id = :newList
                    AND Notification_Type__c IN :notificationsTypeList
                    AND Status__c != 'Processed'
            ]) {
                Boolean toDelete = true;
                List<Id> newtargetRecordIds = notificationObj.Target_Record_Ids__c.split(',');
                Set<Id> newtargetRecordIdSet = new Set<Id>(newtargetRecordIds);
                Set<Id> oldNotificationTargetSet = new Set<Id>();
                Notification__c scheduledObj = mapwhatIdOfIds.get(
                    notificationObj.WhatId__c +
                    ':' +
                    notificationObj.Recipient__c +
                    ':Scheduled'
                );
                Notification__c canceledObj = mapwhatIdOfIds.get(
                    notificationObj.WhatId__c +
                    ':' +
                    notificationObj.Recipient__c +
                    ':Canceled'
                );

                Notification__c rescheduledObj = mapwhatIdOfIds.get(
                    notificationObj.WhatId__c +
                    ':' +
                    notificationObj.Recipient__c +
                    ':Rescheduled'
                );
                if (
                    notificationObj.Notification_Type__c ==
                    NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED
                ) {
                    Set<Id> rescheduledNotificationTargetSet = new Set<Id>(
                        (List<Id>) (notificationObj.Target_Record_Ids__c.split(','))
                    );

                    oldNotificationTargetSet = scheduledObj != null
                        ? new Set<Id>((List<Id>) scheduledObj.Target_Record_Ids__c.split(','))
                        : new Set<Id>();
                    Set<Id> oldCanceledTargetSet = canceledObj != null
                        ? new Set<Id>((List<Id>) canceledObj.Target_Record_Ids__c.split(','))
                        : new Set<Id>();
                    newtargetRecordIdSet.addAll(oldCanceledTargetSet);
                    if (newtargetRecordIdSet.containsAll(oldNotificationTargetSet)) {
                        if (scheduledObj != null) {
                            scheduledObj.Status__c = 'Processed';
                            deleteNoti.add(scheduledObj);
                        }
                    }
                }

                if (
                    notificationObj.Notification_Type__c ==
                    NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED
                ) {
                    Set<Id> canceledNotificationTargetSet = new Set<Id>(
                        (List<Id>) (notificationObj.Target_Record_Ids__c.split(','))
                    );

                    oldNotificationTargetSet = rescheduledObj != null
                        ? new Set<Id>((List<Id>) rescheduledObj.Target_Record_Ids__c.split(','))
                        : new Set<Id>();

                    if (canceledNotificationTargetSet.containsAll(oldNotificationTargetSet)) {
                        if (rescheduledObj != null) {
                            rescheduledObj.Status__c = 'Processed';
                            deleteNoti.add(rescheduledObj);
                        }
                    }

                    Set<Id> scheduledTargetIdslist = scheduledObj != null
                        ? new Set<Id>((List<Id>) scheduledObj.Target_Record_Ids__c.split(','))
                        : new Set<Id>();

                    Set<Id> rescheduledTargetIdslist = rescheduledObj != null
                        ? new Set<Id>((List<Id>) rescheduledObj.Target_Record_Ids__c.split(','))
                        : new Set<Id>();

                    Set<Id> canceledRescheduledId = new Set<Id>();
                    canceledRescheduledId.addAll(canceledNotificationTargetSet);
                    canceledRescheduledId.addAll(rescheduledTargetIdslist);
                    if (canceledRescheduledId.containsAll(scheduledTargetIdslist)) {
                        if (scheduledObj != null) {
                            scheduledObj.Status__c = 'Processed';
                            deleteNoti.add(scheduledObj);
                        }
                    }
                }
            }

            if (!deleteNoti.isEmpty()) {
                update deleteNoti;
            }
        }
    }

    // Logic: -----------------------------------------------------------------------------------------------------------

    private static void checkFieldsForNotification(List<Notification__c> newList) {
        for (Notification__c n : newList) {
            Notification_Type__mdt notificationType = NotificationService.getNotificationType(
                n.Notification_Type__c
            );

            if (notificationType == null) {
                n.addError('Wrong type of Notification ' + n.Notification_Type__c);
            }
            //Start Change:RH-8945
            if (n.Notification_Type__c.startsWith('BELL_')) {
                if (notificationType != null && n.Recipient__c == null) {
                    n.addError('Recipient can not be null' + n.Notification_Type__c);
                }
            } else if (notificationType.Parameters_Provider__c != null && n.WhatId__c == null) {
                //End Change:RH-8945
                n.addError(
                    'WhatId can not be null. WhatId must be Id of type: ' +
                    notificationType.Parameters_Provider__r.Source_Object_Type__c
                );
            } else if (notificationType.Parameters_Provider__c != null && n.WhatId__c != null) {
                try {
                    Id sourceType = n.WhatId__c;
                    if (
                        (sourceType.getSobjectType() + '').toLowerCase() !=
                        notificationType.Parameters_Provider__r.Source_Object_Type__c.toLowerCase()
                    ) {
                        n.addError(
                            'WhatId must be Id of type: ' +
                            notificationType.Parameters_Provider__r.Source_Object_Type__c +
                            '. Found: ' +
                            sourceType.getSobjectType()
                        );
                    }
                } catch (Exception e) {
                    n.addError('WhatId is not correct');
                }
            }
            if (n.Recipient__c == null && n.Topic__c == null && n.Email__c == null) {
                n.addError(
                    'Recipient can not be null while Topic or Email is null ' +
                    n.Notification_Type__c
                );
            }
            if (n.Email__c != null && n.Recipient__c != null) {
                n.addError(
                    'Recipient can not be not null while Email is not null ' +
                    n.Notification_Type__c
                );
            }
        }
    }

    @TestVisible
    private static void sendNotificationToRecipient(List<Notification__c> newList) {
        List<Notification__c> notificationsForMassEmail = new List<Notification__c>();
        List<Notification__c> recipientNotifications = new List<Notification__c>();
        for (Notification__c n : newList) {
            if (!NotificationService.instantNotificationTypes.contains(n.Notification_Type__c)) {
                if (n.Recipient__c == null && n.Topic__c != null) {
                    notificationsForMassEmail.add(n);
                } else if (!System.isBatch()) {
                    recipientNotifications.add(n);
                }
            }
        }
        //recipient notifications:
        if (!System.isBatch() && !System.isFuture() && recipientNotifications.size() > 0)
            NotificationService.sendNotificationsAsync(JSON.serialize(recipientNotifications));
        //topic notifications:
        if (notificationsForMassEmail.size() > 0) {
            for (Notification__c n : notificationsForMassEmail) {
                Database.executeBatch(new Batch_MassEmailPatient(n));
            }
        }
    }
    /*
     * @description: this method generates Send Result records asynchronously, post creation of notification records
     * @param: newList - newly inserted notification records
     */
    //Start Change:RH-8945
    public static void sendBellNotificationToRecipients(List<Notification__c> newList) {
        if (!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
            Id jobId = System.enqueueJob(new BellNotificationQueueable(newList));
        }
    }
    //End Change:RH-8945
}
