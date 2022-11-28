/**
 * Created by Olga Skrynnikova on 11/28/2019.
 * Modified by Pijush Kar on 8/11/2021
 */

public without sharing class NotificationService {
    public static Set<Id> platfomLevelSMSSet = new Set<Id>();
    public static Set<Id> studyLevelSMSSet = new Set<Id>();
    public static Map<Id, Boolean> skipSMSLevelMap = new Map<Id, Boolean>();
    public static Map<Id, Boolean> awsDetailsAreAvailable = new Map<Id, Boolean>();
    public static Map<Id, Boolean> welcomemsgSent = new Map<Id, Boolean>();
    public static Map<Id, Boolean> welcomemsgDelivered = new Map<Id, Boolean>();
    public static Map<String, Boolean> perIdDelConIdWelcomeMessageSentMap = new Map<String, Boolean>();
    public static Map<String, Boolean> perIdDelConIdWelcomeMessageDeleveredMap = new Map<String, Boolean>();

    static public List<String> participantStatusListForHCP = new List<String>{
        PEStatusState.PE_STATUS_RECEIVED,
        PEStatusState.PE_STATUS_EXCLUDED_FROM_REFERRING,
        PEStatusState.PE_STATUS_FAILED_REFERRAL,
        PEStatusState.PE_STATUS_FAILED_REVIEW
    };

    static public List<String> participantStatusListForPT = new List<String>{
        PEStatusState.PE_STATUS_RECEIVED,
        PEStatusState.PE_STATUS_SUCCESSFULLY_REENGAGED,
        PEStatusState.PE_STATUS_NO_SHOW
    };

    static public List<String> notificationWithoutPermissions = new List<String>{
        NotificationCatalog.MESSAGE_TO_PI_ACCESS_LEVEL_CHANGED_TYPE,
        NotificationCatalog.MESSAGE_TO_PI_ACCEPT_NEW_STUDY_TYPE,
        NotificationCatalog.MESSAGE_TO_HCP_ACCESS_LEVEL_CHANGED_TYPE
    };

    static public List<String> notificationTypeFirstEmail = new List<String>{
        NotificationCatalog.MESSAGE_TO_PT_SOURCE_HCP_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_SOURCE_PI_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_SOURCE_ERP_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ENROLLMENT_SUCCESS_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_DEL_NEW_STUDY_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_DEL_NEW_ASSIGNMENT_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_DEL_NEW_ASSIGNMENT_GSK_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_DEL_REACTIVATED_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_DEL_REACTIVATED_GSK_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_FOLLOWUP
    };

    static public List<String> instantNotificationTypes = new List<String>{
        NotificationCatalog.MESSAGE_TO_PT_TASK_INSTANT_DEL_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_INSTANT_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ECOA_TASK_INSTANT_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ECOA_TASK_INSTANT_DEL_TYPE
    };

    static public List<String> televisitNotificationTypes = new List<String>{
        NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_SCHEDULED_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_REMOVED_ATTENDEE_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ADDED_ATTENDEE_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_RESCHEDULED_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_CANCELLED_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_DAY_REMINDER_TYP,
        NotificationCatalog.MESSAGE_TO_PT_TELEVISIT_HOUR_REMINDER_TY
    };

    static public List<String> taskAndVisitReminderTypes = new List<String>{
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_DEL_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_MED_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_MED_DEL_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_DEL_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ECOA_TASK_INSTANT_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_ECOA_TASK_INSTANT_DEL_TYPE
    };

    static public List<String> taskSurveyReminderTypes = new List<String>{
        NotificationCatalog.MESSAGE_TO_PT_SURVEY_REMINDER_TYPE,
        NotificationCatalog.MESSAGE_TO_PT_SURVEY_FINAL_REMINDER_TYPE
    };
    static public Set<String> welcomemsgNoticationtypes = new Set<String>{
        NotificationCatalog.MESSAGE_TO_PT_STUDY_LEVEL_WELCOME_MSG,
        NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
        NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
        NotificationCatalog.MSG_TO_PT_PLATFORM_LVL_WELCME_MSG
    };

    static public String NOTIFICATION_STATUS_PENDING = 'Pending';
    static public String NOTIFICATION_STATUS_PROCESSED = 'Processed';
    static public String NOTIFICATION_STATUS_FAILED = 'Failed';
    static public String NOTIFICATION_STATUS_IN_PROGRESS = 'In Progress';

    static public String NOTIFICATION_TARGET_TYPE_EMAIL = 'Email';
    static public String NOTIFICATION_TARGET_TYPE_SMS = 'SMS';
    static public String NOTIFICATION_TARGET_TYPE_PUSH = 'Push';

    static public String NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT = 'Participant';
    static public String NOTIFICATION_RECIPIENT_TYPE_HCP = 'HCP';
    static public String NOTIFICATION_RECIPIENT_TYPE_PI = 'PI';
    static public String NOTIFICATION_RECIPIENT_TYPE_EXTERNAL_EMAIL = 'External Email';

    private static Map<String, Notification_Type__mdt> notificationTypeByDevNameMap = new Map<String, Notification_Type__mdt>();

    static {
        List<Notification_Type__mdt> notifTypes = [
            SELECT
                Id,
                IsStudyLevel__c,
                DeveloperName,
                Recipient_Type__c,
                Parameters_Provider__r.Source_Object_Type__c,
                Parameters_Provider__r.Parameters__c,
                Parameters_Provider__r.DeveloperName,
                (
                    SELECT
                        Id,
                        Email_Template__c,
                        Email_Template_Delegate__c,
                        Target_Type__c,
                        Title__c,
                        Message_Body__c,
                        Org_Wide_Email_Address__c
                    FROM Notification_Targets__r
                )
            FROM Notification_Type__mdt
        ];
        for (Notification_Type__mdt noType : notifTypes)
            notificationTypeByDevNameMap.put(noType.DeveloperName, noType);
    }

    public static Notification_Type__mdt getNotificationType(String notificationType) {
        return notificationTypeByDevNameMap.get(notificationType);
    }

    public static Notification_Target__mdt getNotificationTarget(
        String notificationType,
        String notificationTarget
    ) {
        Notification_Type__mdt notificationTypeMDT = notificationTypeByDevNameMap.get(
            notificationType
        );
        if (notificationTypeMDT != null) {
            for (Notification_Target__mdt nt : notificationTypeMDT.Notification_Targets__r) {
                if (nt.Target_Type__c == notificationTarget)
                    return nt;
            }
        }
        return null;
    }

    public static String checkHCPNotificationType(
        Participant_Enrollment__c peForCheck,
        Boolean notContains
    ) {
        if (notContains)
            return NotificationCatalog.MESSAGE_TO_HCP_REFERRAL_STATUS_UPDATE_TYPE;
        //TODO: remove Declined/On Hold/ Accepted
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ACCEPTED) {
            return NotificationCatalog.MESSAGE_TO_HCP_PATIENT_ACCEPTED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return NotificationCatalog.MESSAGE_TO_HCP_PATIENT_DECLINED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return NotificationCatalog.MESSAGE_TO_HCP_PATIENT_ON_HOLD_TYPE;
        }
        return null;
    }

    public static String checkPatientNotificationType(
        Participant_Enrollment__c peForCheck,
        Boolean notContains
    ) {
        if (notContains)
            return NotificationCatalog.MESSAGE_TO_PT_REFERRAL_STATUS_UPDATE_TYPE;
        //TODO: remove Declined/On Hold/ Accepted
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return NotificationCatalog.MESSAGE_TO_PT_PATIENT_DECLINED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return NotificationCatalog.MESSAGE_TO_PT_PATIENT_ON_HOLD_TYPE;
        }
        return null;
    }

    public static String checkPatientNotificationVTType(Participant_Enrollment__c peForCheck) {
        //TODO:remove Declined/On hold
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return NotificationCatalog.MESSAGE_TO_PT_PATIENT_DECLINED_VT_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return NotificationCatalog.MESSAGE_TO_PT_PATIENT_ON_HOLD_VT_TYPE;
        }
        if (
            peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED &&
            peForCheck.Referral_Source__c == 'HCP'
        ) {
            return NotificationCatalog.MESSAGE_TO_PT_NEW_STUDY_HCP_VT_TYPE;
        }
        if (
            (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
            peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) &&
            peForCheck.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
        ) {
            return NotificationCatalog.MESSAGE_TO_PT_ENROLLMENT_SUCCESS_TYPE;
        }
        if (
            peForCheck.Referral_Source__c != 'HCP' &&
            peForCheck.Referral_Source__c != 'PI' &&
            (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED)
        ) {
            return NotificationCatalog.MESSAGE_TO_PT_NEW_STUDY_eRP_VT_TYPE;
        }
        return null;
    }

    public static Topic__c getTopicOrCreateNew(Id ctpId) {
        List<Topic__c> topicList = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c = :ctpId];
        if (topicList.isEmpty()) {
            topicList.add(new Topic__c(TopicId__c = ctpId));
            try {
                insert topicList;
            } catch (DmlException e) {
            }
        }
        return topicList[0];
    }

    public static List<Topic__c> getTopicListOrCreateNewByCOI(
        List<Therapeutic_Area_Patient__c> cois
    ) {
        List<Id> taIds = new List<Id>();
        for (Therapeutic_Area_Patient__c ta : cois)
            taIds.add(ta.Therapeutic_Area__c);
        List<Topic__c> topicList = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c = :taIds];
        List<Id> topicIds = new List<Id>();
        for (Topic__c t : topicList)
            topicIds.add(t.TopicId__c);
        for (Therapeutic_Area_Patient__c tap : cois) {
            if (!topicIds.contains(tap.Therapeutic_Area__c))
                topicList.add(new Topic__c(TopicId__c = tap.Therapeutic_Area__c));
        }
        try {
            insert topicList;
        } catch (DmlException e) {
        }
        return topicList;
    }

    public static List<Topic__c> getTopicListOrCreateNew(List<Clinical_Trial_Profile__c> ctpList) {
        List<Id> taIds = new List<Id>();

        for (Clinical_Trial_Profile__c ctp : ctpList)
            taIds.add(ctp.Therapeutic_Area__c);

        List<Topic__c> topics = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c = :taIds];
        List<Id> topIds = new List<Id>();

        for (Topic__c top : topics)
            topIds.add(top.TopicId__c);

        List<Topic__c> newTopics = new List<Topic__c>();

        for (Clinical_Trial_Profile__c ctp : ctpList) {
            if (ctp.Therapeutic_Area__c != null && !topIds.contains(ctp.Therapeutic_Area__c)) {
                newTopics.add(new Topic__c(TopicId__c = ctp.Therapeutic_Area__c));
            }
        }
        try {
            insert newTopics;
            topics.addAll(newTopics);
        } catch (DmlException e) {
        }

        return topics;
    }

    public static List<Topic__c> getTopicListOrCreateNewByCTPId(
        List<Clinical_Trial_Profile__c> ctpList
    ) {
        List<Id> ctpIds = new List<Id>();

        for (Clinical_Trial_Profile__c ctp : ctpList)
            ctpIds.add(ctp.Id);

        List<Topic__c> topics = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c = :ctpIds];
        List<Id> topIds = new List<Id>();

        for (Topic__c top : topics)
            topIds.add(top.TopicId__c);

        List<Topic__c> newTopics = new List<Topic__c>();

        for (Clinical_Trial_Profile__c ctp : ctpList) {
            if (!topIds.contains(ctp.Id)) {
                newTopics.add(new Topic__c(TopicId__c = ctp.Id));
            }
        }
        try {
            insert newTopics;
            topics.addAll(newTopics);
        } catch (DmlException e) {
        }

        return topics;
    }

    @Future
    public static void createNotificationsAsync(String notificationsJSON) {
        createNotifications(
            (List<Notification__c>) JSON.deserialize(notificationsJSON, List<Notification__c>.class)
        );
    }

    private static void createNotifications(List<Notification__c> notifications) {
        insert notifications;
    }

    @Future(Callout=true)
    public static void sendNotificationsAsync(String notificationsJSON) {
        sendNotifications(
            (List<Notification__c>) JSON.deserialize(notificationsJSON, List<Notification__c>.class)
        );
    }

    public static void sendNotifications(List<Notification__c> notifications) {
        List<Id> whatIds = new List<Id>();
        List<Id> recipientIds = new List<Id>();
        List<Id> taskIds = new List<Id>();
        Map<Id, Task> taskMap;
        Set<Id> welcomeMessageWhatIds = new Set<Id>();
        Set<Id> welcomeMessageRecipientIds = new Set<Id>();
        for (Notification__c n : notifications) {
            whatIds.add(n.WhatId__c);
            recipientIds.add(n.Recipient__c);
            if (!String.isBlank(n.Task_Id__c)) {
                taskIds.add(n.Task_Id__c);
            }
            //for Welcome message functionality for Delgate
            Id whatId = Id.valueOf(n.WhatId__c);
            String objType = String.valueOf(whatId.getSobjectType());
            if (objType == 'Participant_Enrollment__c') {
                welcomeMessageWhatIds.add(n.WhatId__c);
                welcomeMessageRecipientIds.add(n.Recipient__c);
            }
        }
        if (!taskIds.isEmpty()) {
            taskMap = new Map<Id, Task>(
                [
                    SELECT Id, Remind_Using_Email__c, Remind_Using_SMS__c, CreatedByAdmin__c
                    FROM Task
                    WHERE Id IN :taskIds
                ]
            );
        }
        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(
            recipientIds,
            whatIds
        );
        Map<Id, String> orgWideEmailByNotifyMap = new Map<Id, String>();
        List<Notification__c> emailNotifications = new List<Notification__c>();
        List<Notification__c> smsNotifications = new List<Notification__c>();
        List<Notification__c> pushNotifications = new List<Notification__c>();
        NotificationResultService sendResultService = new NotificationResultService(notifications);

        //Check if SMS is applicable to send for Study level notification.
        Action_SendSMS obj = new Action_SendSMS(notifications);
        for (Notification__c n : notifications) {
            //TODO add check contact available time, if not available set status to 'Pending', else set 'Processed'
            //TODO Now 'In Progress'
            /**if (n.StartDate__c != null) {
                datetime gmtDateTime = datetime.now();
                string currentUserDate = gmtDateTime.format('yyyy-MM-dd');
                String userTimeZone = availabilityService.contactLangZoneMap.get(n.Recipient__c);
                if (userTimeZone != null) {
                    string participantDate = gmtDateTime.format('yyyy-MM-dd', userTimeZone);
                    if (currentUserDate != participantDate) {
                        continue;
                    }
                }
            } **/
            if (!availabilityService.compareParticipantTimeZone(n)) {
                continue;
            }
            Notification_Type__mdt notificationType = NotificationService.getNotificationType(
                n.Notification_Type__c
            );

            for (Notification_Target__mdt nt : notificationType.Notification_Targets__r) {
                if (nt.Target_Type__c == NOTIFICATION_TARGET_TYPE_EMAIL) {
                    if (n.Recipient__c != null) {
                        if (
                            !notificationWithoutPermissions.contains(n.Notification_Type__c) &&
                            availabilityService.isDeferNotification(n.Recipient__c, n.WhatId__c) &&
                            (n.StartDate__c == null &&
                            !instantNotificationTypes.contains(n.Notification_Type__c))
                        )
                            continue;
                        if (!notificationTypeFirstEmail.contains(n.Notification_Type__c)) {
                            if (
                                availabilityService.isAvailable(
                                    n.WhatId__c,
                                    notificationType.Recipient_Type__c,
                                    nt.Target_Type__c,
                                    n.Recipient__c,
                                    notificationType,
                                )
                            ) {
                                if (
                                    (taskAndVisitReminderTypes.contains(n.Notification_Type__c)) ||
                                    (taskSurveyReminderTypes.contains(n.Notification_Type__c) &&
                                    !String.isBlank(n.Task_Id__c))
                                ) {
                                    if (
                                        !String.isBlank(n.Task_Id__c) &&
                                        taskMap != null &&
                                        taskMap.containsKey(n.Task_Id__c) &&
                                        (taskMap.get(n.Task_Id__c).Remind_Using_Email__c ||
                                        (instantNotificationTypes.contains(
                                            n.Notification_Type__c
                                        ) && taskMap.get(n.Task_Id__c).CreatedByAdmin__c))
                                    ) {
                                        emailNotifications.add(n);
                                        sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                                    }
                                } else {
                                    emailNotifications.add(n);
                                    sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                                }
                            } else {
                                sendResultService.setSkipped(n.Id, nt.Target_Type__c);
                            }
                        } else {
                            emailNotifications.add(n);
                            sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                        }
                        orgWideEmailByNotifyMap.put(
                            n.Id,
                            availabilityService.getOrgWideEmail(
                                n.Recipient__c,
                                n.WhatId__c,
                                nt.Org_Wide_Email_Address__c
                            )
                        );
                    } else if (n.Recipient__c == null) {
                        emailNotifications.add(n);
                        orgWideEmailByNotifyMap.put(
                            n.Id,
                            availabilityService.getOrgWideEmail(
                                n.From__c,
                                n.WhatId__c,
                                nt.Org_Wide_Email_Address__c
                            )
                        );
                    }
                } else if (nt.Target_Type__c == NOTIFICATION_TARGET_TYPE_SMS) {
                    //check if the SMS notification is eligible to send.
                    Boolean isSMSAEligibleToSend = availabilityService.checkSMSIsEligibleToSkip(
                        n,
                        notificationType.Recipient_Type__c
                    );
                    //Check if skipSMS flag is true then skip the SMS and continue for next iteration.
                    if (!isSMSAEligibleToSend) {
                        if (
                            (taskAndVisitReminderTypes.contains(n.Notification_Type__c)) ||
                            (taskSurveyReminderTypes.contains(n.Notification_Type__c) &&
                            !String.isBlank(n.Task_Id__c))
                        ) {
                            if (
                                !String.isBlank(n.Task_Id__c) &&
                                taskMap != null &&
                                taskMap.containsKey(n.Task_Id__c) &&
                                (taskMap.get(n.Task_Id__c).Remind_Using_SMS__c ||
                                (instantNotificationTypes.contains(n.Notification_Type__c) &&
                                taskMap.get(n.Task_Id__c).CreatedByAdmin__c))
                            ) {
                                smsNotifications.add(n);
                                sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                            }
                        } else {
                            smsNotifications.add(n);
                            sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                        }
                    } else {
                        sendResultService.setSkipped(n.Id, nt.Target_Type__c);
                    }
                } else if (nt.Target_Type__c == NOTIFICATION_TARGET_TYPE_PUSH) {
                    if (availabilityService.isAvailableForPush(n.Id, n.WhatId__c)) {
                        //sendResultService.setInProgress(n.Id, nt.Target_Type__c);
                        pushNotifications.add(n);
                    } else {
                        sendResultService.setSkipped(n.Id, nt.Target_Type__c);
                    }
                } else if (nt.Target_Type__c == NOTIFICATION_RECIPIENT_TYPE_EXTERNAL_EMAIL) {
                    //TODO
                }
            }
        }
        //Push notification revamp
        if (!pushNotifications.isEmpty()) {
            ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
            List<Notification__c> notificationsWithRecipient = [
                SELECT
                    Id,
                    Notification_Type__c,
                    Recipient__c,
                    Recipient__r.Phone,
                    Recipient__r.Language__c,
                    WhatId__c
                FROM Notification__c
                WHERE Id IN :pushNotifications
            ];

            for (Notification__c n : notificationsWithRecipient) {
                Notification_Type__mdt messageType = NotificationService.getNotificationType(
                    n.Notification_Type__c
                );
                Notification_Target__mdt pushTarget = NotificationService.getNotificationTarget(
                    n.Notification_Type__c,
                    NotificationService.NOTIFICATION_TARGET_TYPE_PUSH
                );
                parametrizedMessageService.addMessage(
                    n.Id,
                    pushTarget.Message_Body__c,
                    n.WhatId__c,
                    messageType.Parameters_Provider__r.DeveloperName,
                    n.Recipient__r.Language__c
                );
                parametrizedMessageService.addMessage(
                    n.Id + '_title',
                    pushTarget.Title__c,
                    n.WhatId__c,
                    messageType.Parameters_Provider__r.DeveloperName,
                    n.Recipient__r.Language__c
                );
            }
            parametrizedMessageService.processMessages();

            for (Notification__c n : notificationsWithRecipient) {
                String title = parametrizedMessageService.getMessage(n.Id + '_title');
                String message = parametrizedMessageService.getMessage(n.Id);
                sendResultService.setInProgressPush(n.Id, n.Notification_Type__c, title, message);
            }
        }

        sendResultService.updateResults();
        //Send emails:
        if (!emailNotifications.isEmpty()) {
            EmailService.send(emailNotifications, orgWideEmailByNotifyMap, availabilityService);
        }
        //Async send SMS
        if (!smsNotifications.isEmpty()) {
            SMSService.sendQueueable(smsNotifications);
        }
    }
}
