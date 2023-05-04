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
            List<Id> targetRecordIds = new List<Id>();
            Map<String, String> mapwhatIdOfIds = new Map<String, String>();
            for (Notification__c notificationObj : [
                SELECT Id, WhatId__c, Target_Record_Ids__c, Recipient__c
                FROM Notification__c
                WHERE Id = :newList AND Notification_Type__c = 'Update_to_PT_Televisit_Rescheduled'
            ]) {
                List<Id> targetIds = (List<Id>) notificationObj.Target_Record_Ids__c.split(',');
                if (!targetIds.isEmpty()) {
                    targetRecordIds.addAll(targetIds);
                }
                mapwhatIdOfIds.put(
                    notificationObj.WhatId__c +
                    ':' +
                    notificationObj.Recipient__c,
                    notificationObj.Target_Record_Ids__c
                );
            }
            if (!targetRecordIds.isEmpty()) {
                String query = 'Select Id,Target_Record_Ids__c,Recipient__c,WhatId__c from Notification__c  where  Notification_Type__c = \'Update_to_PT_Televisit_Scheduled\' and Status__c!=\'Processed\' ';

                Integer counter = 0;
                for (Id recordId : targetRecordIds) {
                    query = query + 'AND Target_Record_Ids__c LIKE \'%' + recordId + '%\'';
                    counter++;
                    if (counter == targetRecordIds.size())
                        break;
                    else {
                        query = query + ' ';
                    }
                }
                List<Notification__c> records = Database.query(query);
                List<Notification__c> deleteNoti = new List<Notification__c>();
                for (Notification__c notificationObj : records) {
                    Boolean toDelete = true;

                    List<Id> currenttargetRecordIds = notificationObj.Target_Record_Ids__c.split(
                        ','
                    );
                    for (Id rId : currenttargetRecordIds) {
                        if (
                            mapwhatIdOfIds.get(
                                notificationObj.WhatId__c +
                                ':' +
                                notificationObj.Recipient__c
                            ) != null &&
                            !mapwhatIdOfIds.get(
                                    notificationObj.WhatId__c +
                                    ':' +
                                    notificationObj.Recipient__c
                                )
                                .contains(rId)
                        ) {
                            toDelete = false;
                        }
                    }
                    if (toDelete) {
                        deleteNoti.add(notificationObj);
                    }
                }

                if (!deleteNoti.isEmpty()) {
                    delete deleteNoti;
                }
            }
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

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
