/**
 * Created by Leonid Bartenev
 * Modified by Pijush Kar on 8/11/2021
 */

public without sharing class NotificationResultService {
    public static final String SEND_RESULT_STATUS_SKIPPED = 'Skipped';
    public static final String SEND_RESULT_STATUS_IN_PROGRESS = 'In Progress';
    public static final String SEND_RESULT_STATUS_FAILED = 'Failed';
    public static final String SEND_RESULT_STATUS_SENT = 'Sent';

    private Map<Id, List<Send_Result__c>> sendResultsMap;

    public NotificationResultService(List<Notification__c> notifications) {
        List<Notification__c> notificationsWithResults = [
            SELECT Id, (SELECT Id, Target_Type__c, Status__c FROM Send_Results__r)
            FROM Notification__c
            WHERE Id IN :notifications
        ];
        sendResultsMap = new Map<Id, List<Send_Result__c>>();
        for (Notification__c n : notificationsWithResults) {
            sendResultsMap.put(n.Id, n.Send_Results__r);
        }
    }

    public void setSkipped(Id notificationId, String targetType) {
        setResultStatus(notificationId, targetType, SEND_RESULT_STATUS_SKIPPED, null);
    }

    public void setInProgress(Id notificationId, String targetType) {
        setResultStatus(notificationId, targetType, SEND_RESULT_STATUS_IN_PROGRESS, null);
    }

    public void setInProgressPush(
        Id notificationId,
        String notificationType,
        String pushTitle,
        String messageBody
    ) {
        setResultStatusInProgressPush(notificationId, notificationType, pushTitle, messageBody);
    }

    public void setFailed(Id notificationId, String targetType, String errorMessage) {
        setResultStatus(notificationId, targetType, SEND_RESULT_STATUS_FAILED, errorMessage);
    }

    public void setSent(Id notificationId, String targetType) {
        setResultStatus(notificationId, targetType, SEND_RESULT_STATUS_SENT, null);
    }

    public void setSentForBell(Id notificationId, String targetType, String messageBody, String redirectURL, String userRole, String communityType){
        setResultStatusForBell(notificationId, targetType, SEND_RESULT_STATUS_IN_PROGRESS, messageBody, redirectURL, userRole, communityType);
    }

    public Send_Result__c getSendResult(Id notificationId, String targetType) {
        return getSendResult(notificationId, targetType, null, null, null);
    }

    public Send_Result__c getSendResult(
        Id notificationId,
        String targetType,
        String notificationType,
        String pushTitle,
        String messageBody
    ) {
        List<Send_Result__c> sendResults = sendResultsMap.get(notificationId);
        if (sendResultsMap == null)
            sendResults = new List<Send_Result__c>();
        Send_Result__c result;
        for (Send_Result__c sendResult : sendResults) {
            if (sendResult.Target_Type__c == targetType) {
                result = sendResult;
                break;
            }
        }
        if (result == null) {
            result = new Send_Result__c(
                Notification__c = notificationId,
                Notification_Type__c = notificationType,
                Target_Type__c = targetType,
                Push_Message_Title__c = pushTitle,
                Push_Message_Body__c = messageBody
            );
            sendResults.add(result);
        }
        return result;
    }

    public void updateResults() {
        updateResults(null);
    }

    public void updateResults(IntegrationLog__c log) {
        List<Send_Result__c> results = new List<Send_Result__c>();
        for (List<Send_Result__c> nResults : sendResultsMap.values()) {
            for (Send_Result__c sr : nResults) {
                if (
                    log != null &&
                    sr.Target_Type__c == NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                ) {
                    sr.Integration_Log__c = log.Id;
                }
            }
            if (nResults.size() > 0) {
                results.addAll(nResults);
            }
        }
        if (results.size() > 0) {
            upsert results;
        }

        updateNotificationsStatus();
    }

    public void setAction(Action__c action) {
        List<Send_Result__c> results = new List<Send_Result__c>();
        for (List<Send_Result__c> nResults : sendResultsMap.values()) {
            for (Send_Result__c sr : nResults) {
                sr.Action__c = action.Id;
            }
            results.addAll(nResults);
        }
    }

    private void setResultStatusInProgressPush(
        Id notificationId,
        String notificationType,
        String pushTitle,
        String messageBody
    ) {
        Send_Result__c result = getSendResult(
            notificationId,
            NotificationService.NOTIFICATION_TARGET_TYPE_PUSH,
            notificationType,
            pushTitle,
            messageBody
        );
        result.Status__c = SEND_RESULT_STATUS_IN_PROGRESS;
    }

    private void setResultStatus(
        Id notificationId,
        String targetType,
        String status,
        String errorMessage
    ) {
        Send_Result__c result = getSendResult(notificationId, targetType);
        result.Status__c = status;
        result.Error__c = SObjectHelper.trimForField(errorMessage, Send_Result__c.Error__c);
    }

    private void setResultStatusForBell(
        Id notificationId,
        String targetType,
        String status,
        String messageBody,
        String redirectURL,
        String userRole,
        String communityType
    ){
        Send_Result__c result = getSendResult(
            notificationId,
            targetType,
            null,
            null,
            messageBody

        );        
        result.Status__c = status;
        result.Link_to_Related_Event_or_Object__c = redirectURL;        
        result.Community_Type__c = communityType;
        result.User_Role__c = userRole;
    }

    private void updateNotificationsStatus() {
        List<Notification__c> notifications = [
            SELECT Id, (SELECT Id, Status__c FROM Send_Results__r)
            FROM Notification__c
            WHERE Id IN :sendResultsMap.keySet()
        ];
        for (Notification__c n : notifications) {
            if (n.Send_Results__r.isEmpty())
                continue;

            Boolean hasFailed = false;
            Boolean hasInProgress = false;
            for (Send_Result__c sr : n.Send_Results__r) {
                if (sr.Status__c == SEND_RESULT_STATUS_IN_PROGRESS)
                    hasInProgress = true;
                if (sr.Status__c == SEND_RESULT_STATUS_FAILED)
                    hasFailed = true;
            }
            if (hasFailed) {
                n.Status__c = NotificationService.NOTIFICATION_STATUS_FAILED;
            } else if (hasInProgress) {
                n.Status__c = NotificationService.NOTIFICATION_STATUS_IN_PROGRESS;
            } else {
                n.Status__c = NotificationService.NOTIFICATION_STATUS_PROCESSED;
            }
        }
        update notifications;
    }
}
