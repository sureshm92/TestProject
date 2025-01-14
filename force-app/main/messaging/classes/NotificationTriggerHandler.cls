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
            sendNotificationToRecipient(newList);
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
            } else if (notificationType.Parameters_Provider__c != null && n.WhatId__c == null) {
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
}
