/**
 * Created by Olga Skrynnikova on 12/16/2019.
 * Refactored by Pijush Kar on 09/30/2021
 */

public without sharing class Action_SendSMS implements Action {
    private List<Id> notificationIds;
    private Map<Id, PinpointWrapper> pinPointWrapperMap;
    public static Map<String, String> studySiteToFromNoMap = new Map<String, String>();
    /*Added by Anitha*/
    public static final String FROM_NUMBER = 'FromNumber';
    public static final String SOURCE_IDENTIFIER = 'SourceIdentifier';
    public static final String API_MULESOFT_SMS = 'MulesoftSMS';
    public static final String PIN_POINT_PROJECT_ID = 'PinpointProjectId';
    public static final String PL_SPONSOR = 'Sponsor';
    public static final String PL_STUDY = 'Study';
    /*Added by Anitha*/

    transient private NotificationResultService sendResultService;
    transient private IntegrationLog__c log;
    public static final String PHONE_TYPE_MOBILE = 'Mobile';

    public class Action_SendSMS_Exception extends Exception {
    }
    public class MessageParameters {
        public String transactionId;
        public List<String> toNumber;
        public String subject;
        public String messageBody;
        public String pinPointProjectId;
        public Boolean isPlatformLevel;
        public String awsSponsorName;
        public String awsStudy;
        public String studySiteId;
        public String MailingCountryCode;
        public string stateCode;
    }
    class MessagegResponseWrapper {
        public string applicationId;
        public string requestId;
        public List<MsgResult> result;
    }
    class MsgResult {
        public String toNumber;
        public MsgStatus status;
    }
    class MsgStatus {
        public String deliveryStatus;
        public String statusCode;
        public String statusMessage;
        public String messageId;
    }
    class DialingCountryConfig {
        public List<String> dialCountryCodeList;
        public Integer characterLimit;
    }
    class PinpointWrapper {
        public String studyPinpoint;
        public Boolean isPlatformlevel;
        public String sponsorName;
        public String sponsorNameSms;
        public String studyName;
        public String ctpTemplate;
        public String studySiteId;
        public String fromNumber; // Added by Anitha
    }

    public Action_SendSMS(List<Notification__c> notifications) {
        system.debug('notifications:::' + notifications);
        this.notificationIds = SObjectHelper.toIdsList(notifications);
        this.pinPointWrapperMap = processPlatformLevelCheck(notifications);
        system.debug('pinPointWrapperMap:::' + pinPointWrapperMap);
        system.debug('notificationIds:::' + notificationIds);
    }

    public void execute() {
        system.debug('excecute:::');
        List<MessageParameters> messageParametersList = new List<MessageParameters>();
        Map<Id, Task> taskMap;
        List<Notification__c> notifications = [
            SELECT
                Id,
                Notification_Type__c,
                Recipient__c,
                Recipient__r.Phone,
                Recipient__r.Language__c,
                WhatId__c,
                Task_Id__c
            FROM Notification__c
            WHERE Id IN :notificationIds
        ];
        sendResultService = new NotificationResultService(notifications);
        // Map<String, List<String>> countryDialCodeMap = new Map<String, List<String>>();
        Map<String, DialingCountryConfig> countryDialCodeMap = new Map<String, DialingCountryConfig>();
        for (Dialing_Country_Code__mdt mdt : [
            SELECT Id, DeveloperName, Dialing_Code__c, Enabled_for_SMS__c, Character_Limit__c
            FROM Dialing_Country_Code__mdt
            WHERE Enabled_for_SMS__c = TRUE
        ]) {
            DialingCountryConfig obj = new DialingCountryConfig();
            obj.dialCountryCodeList = mdt.Dialing_Code__c.split(',');
            obj.characterLimit = mdt.Character_Limit__c == null
                ? 160
                : Integer.valueOf(mdt.Character_Limit__c);
            //countryDialCodeMap.put(mdt.DeveloperName, mdt.Dialing_Code__c.split(','));
            countryDialCodeMap.put(mdt.DeveloperName, obj);
        }
        List<Id> conIds = new List<Id>();
        List<Id> taskIds = new List<Id>();
        for (Notification__c n : notifications) {
            conIds.add(n.Recipient__c);
            if (!String.isBlank(n.Task_Id__c)) {
                taskIds.add(n.Task_Id__c);
            }
        }
        if (!taskIds.isEmpty()) {
            taskMap = new Map<Id, Task>(
                [SELECT Id, Community_Template_Name__c FROM Task WHERE Id IN :taskIds]
            );
        }
        Map<Id, Participant__c> participantMap = new Map<Id, Participant__c>();
        List<Participant__c> participants = [
            SELECT
                Id,
                Contact__c,
                First_Name__c,
                Phone__c,
                Phone_Type__c,
                Alternative_Phone_Number__c,
                Alternative_Phone_Type__c
            FROM Participant__c
            WHERE Contact__c IN :conIds
        ];
        for (Participant__c participant : participants) {
            if (participant.Contact__c != null) {
                participantMap.put(participant.Contact__c, participant);
            }
        }
        ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        for (Notification__c n : notifications) {
            Notification_Type__mdt messageType = NotificationService.getNotificationType(
                n.Notification_Type__c
            );
            Notification_Target__mdt smsTarget = NotificationService.getNotificationTarget(
                n.Notification_Type__c,
                NotificationService.NOTIFICATION_TARGET_TYPE_SMS
            );
            parametrizedMessageService.addMessage(
                n.Id,
                smsTarget.Message_Body__c,
                n.WhatId__c,
                messageType.Parameters_Provider__r.DeveloperName,
                n.Recipient__r.Language__c
            );
        }
        parametrizedMessageService.processMessages();

        for (Send_Result__c smsChannel : [
            SELECT
                Id,
                Target_Type__c,
                Status__c,
                CreatedDate,
                Notification__c,
                Notification__r.WhatId__c,
                Notification__r.Recipient__c,
                Notification__r.Recipient__r.MobilePhone,
                Notification__r.Recipient__r.Language__c,
                Notification__r.Recipient__r.MailingCountryCode,
                Notification__r.Recipient__r.MailingStateCode,
                Notification__r.Notification_Type__c,
                Notification__r.Task_Id__c
            FROM Send_Result__c
            WHERE
                Notification__c IN :notificationIds
                AND Target_Type__c = :NotificationService.NOTIFICATION_TARGET_TYPE_SMS
        ]) {
            String phoneNumber = smsChannel.Notification__r.Recipient__r.MobilePhone;
            String countryCode = smsChannel.Notification__r.Recipient__r.MailingCountryCode;
            String stateCode = smsChannel.Notification__r.Recipient__r.MailingStateCode;
            //  Boolean isPlatformLevel = true;
            // String pinPoint;
            system.debug('participantMap:::' + participantMap);
            system.debug(
                'participantMap:::' + participantMap.get(smsChannel.Notification__r.Recipient__c)
            );
            system.debug('phoneNumber:::' + phoneNumber);
            if (
                phoneNumber == null &&
                participantMap.get(smsChannel.Notification__r.Recipient__c) != null
            ) {
                phoneNumber = participantMap.get(smsChannel.Notification__r.Recipient__c)
                        .Alternative_Phone_Type__c.equals(PHONE_TYPE_MOBILE)
                    ? participantMap.get(smsChannel.Notification__r.Recipient__c)
                          .Alternative_Phone_Number__c
                    : null;
            }
            //Uncomment and set the value in metadata if needed in future.
            /*String title = parametrizedMessageService.getMessage(
                smsChannel.Notification__c + '_title'
            );*/
            system.debug('phoneNumber:::' + phoneNumber);
            String message = parametrizedMessageService.getMessage(smsChannel.Notification__c);
            message = message.replace(
                '##PTFirstName',
                participantMap.get(smsChannel.Notification__r.Recipient__c).First_Name__c
            );
            /**if (
                !String.isBlank(message) &&
                NotificationService.taskAndVisitReminderTypes.contains(
                    smsChannel.Notification__r.Notification_Type__c
                )
            ) {
                if (
                    !String.isBlank(smsChannel.Notification__r.Task_Id__c) &&
                    taskMap.containsKey(smsChannel.Notification__r.Task_Id__c)
                ) {
                    String communityTemaplteName = taskMap.get(
                            smsChannel.Notification__r.Task_Id__c
                        )
                        .Community_Template_Name__c;
                    /** if (String.isBlank(communityTemaplteName)) {
                        communityTemaplteName = 'Default';
                    }
                    String commUrl = CommunityService.getCommunityURLFromTemplateName(
                        communityTemaplteName
                    );
                    message = message.replace('##CommunityURL', commUrl);
                }
            } **/
            /** message = message.replace(
                '##CommunityURL',
                CommunityService.getCommunityURLFromTemplateName('Default')
            );  */

            if (phoneNumber != null) {
                MessageParameters msgParam = new MessageParameters();
                phoneNumber =
                    countryDialCodeMap.get(
                            smsChannel.Notification__r.Recipient__r.MailingCountryCode
                        )
                        .dialCountryCodeList.get(0) + phoneNumber.replaceAll('\\D', '');
                msgParam.transactionId = smsChannel.Id; //Keeping Send_Result__c Id for 32 char limit
                msgParam.toNumber = new List<String>{ phoneNumber };
                msgParam.MailingCountryCode = countryCode;
                msgParam.stateCode = stateCode;
                /**if (
                    message.length() >
                    countryDialCodeMap.get(
                            smsChannel.Notification__r.Recipient__r.MailingCountryCode
                        )
                        .characterLimit
                ) {
                    message = message.substring(
                        0,
                        countryDialCodeMap.get(
                                smsChannel.Notification__r.Recipient__r.MailingCountryCode
                            )
                            .characterLimit
                    );
                } **/
                msgParam.messageBody = message;
                // Pinpoint code Starts
                PinpointWrapper pinPointWrapperObj = pinPointWrapperMap.get(
                    smsChannel.Notification__c
                );
                if (pinPointWrapperObj != null) {
                    msgParam.isPlatformLevel = pinPointWrapperObj.isPlatformlevel;
                    msgParam.pinPointProjectId = pinPointWrapperObj.studyPinpoint;
                    msgParam.awsSponsorName = pinPointWrapperObj.sponsorName;
                    msgParam.awsStudy = pinPointWrapperObj.studyName;
                    msgParam.studySiteId = pinPointWrapperObj.studySiteId;
                    String shortCommunityName = '';
                    String url = '';
                    if (
                        pinPointWrapperObj.isPlatformlevel ||
                        pinPointWrapperObj.ctpTemplate == 'Default'
                    ) {
                        shortCommunityName = pinPointWrapperObj.sponsorNameSms == null
                            ? ''
                            : pinPointWrapperObj.sponsorNameSms; //label.IQVIA_Patient_Portal;
                    } else if (pinPointWrapperObj.ctpTemplate == 'GSK') {
                        //shortCommunityName = label.Gather_Share_Know;
                        shortCommunityName = pinPointWrapperObj.sponsorNameSms == null
                            ? ''
                            : pinPointWrapperObj.sponsorNameSms;
                    }
                    url = CommunityService.getCommunityURLFromTemplateName(
                        pinPointWrapperObj.ctpTemplate
                    );
                    //Replace community Name based on Community Template
                    msgParam.messageBody = msgParam.messageBody.replace(
                        '##ShortCommunityName',
                        shortCommunityName
                    );
                    message = message.replace(
                        '##CommunityURL',
                        CommunityService.getCommunityURLFromTemplateName('Default')
                    );
                    msgParam.messageBody = msgParam.messageBody.replace('##CommunityURL', url);
                    /**  public String awsSponsorName;
                     public String awsStudy; */
                }
                // Pinpoint code Ends

                messageParametersList.add(msgParam);
            }
        }
        if (!messageParametersList.isEmpty()) {
            system.debug('messageParametersList::' + messageParametersList);
            RemoteCall_SendSMS remoteCallSendSMS = new RemoteCall_SendSMS(messageParametersList);
            // remoteCallSendSMS.execute();
            String respBody = (String) remoteCallSendSMS.execute();
            MessagegResponseWrapper respWrapper = parseResponseBody(respBody);
            log = remoteCallSendSMS.log;
            for (Notification__c n : notifications) {
                if (remoteCallSendSMS.log.Success__c) {
                    sendResultService.setSent(
                        n.Id,
                        NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                    );
                    sendResultService.getSendResult(
                            n.Id,
                            NotificationService.NOTIFICATION_TARGET_TYPE_SMS
                        )
                        .Msg_Id__c = respWrapper.result[0].status.messageId;
                } else {
                    sendResultService.setFailed(
                        n.Id,
                        NotificationService.NOTIFICATION_TARGET_TYPE_SMS,
                        remoteCallSendSMS.log.Error_Message__c
                    );
                }
            }

            if (!log.Success__c) {
                throw new Action_SendSMS_Exception(log.Error_Message__c);
            }
        }
    }

    public Type getType() {
        return Action_SendSMS.class;
    }

    public Boolean isDMLWithSetupObjects() {
        return false;
    }

    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
        if (log != null)
            insert log;
        if (executionHistory != null && executionHistory.Id != null && log != null) {
            executionHistory.Integration_Log__c = log.Id;
            update executionHistory;
        }
        sendResultService.setAction(dbAction);
        sendResultService.updateResults(log);
    }

    public MessagegResponseWrapper parseResponseBody(String responseBody) {
        try {
            MessagegResponseWrapper msgResponseWrap = (MessagegResponseWrapper) JSON.deserialize(
                responseBody,
                MessagegResponseWrapper.class
            );
            return msgResponseWrap;
        } catch (JSONException e) {
            return new MessagegResponseWrapper();
        }
    }

    public Map<Id, PinpointWrapper> processPlatformLevelCheck(
        List<Notification__c> notificationsList
    ) {
        Map<Id, PinpointWrapper> pinPointWrapperMapObj = new Map<Id, PinpointWrapper>();
        List<Id> peIdList = new List<Id>();
        List<Id> participantIdList = new List<Id>(); // Added by Anitha
        List<Id> ctpIdList = new List<Id>();
        List<Id> taskIdList = new List<Id>();
        List<Id> surveyInvitationIdList = new List<Id>();
        List<Id> ownerIdList = new List<Id>();
        List<Id> televisitIdList = new List<Id>();
        List<Id> televisitAttendeeIdList = new List<Id>();
        Boolean isPlatFormEvent = SMSOptOutService.isPlatFormEvent;
        Set<Id> recipientIdSet = new Set<Id>();
        for (Notification__c notificationObj : notificationsList) {
            if (notificationObj.WhatId__c != null) {
                Id whatId = Id.valueOf(notificationObj.WhatId__c);
                String objType = String.valueOf(whatId.getSobjectType());
                system.debug('objType:::' + objType);

                if (objType == 'Participant_Enrollment__c') {
                    peIdList.add(whatId);
                    recipientIdSet.Add(notificationObj.recipient__c);
                } else if (objType == 'Clinical_Trial_Profile__c') {
                    ctpIdList.add(whatId);
                } else if (objType == 'Task') {
                    taskIdList.add(whatId);
                } else if (objType == 'Televisit__c') {
                    televisitIdList.add(whatId);
                } else if (objType == 'Televisit_Attendee__c') {
                    televisitAttendeeIdList.add(whatId);
                }

                if (objType == 'SurveyInvitation') {
                    surveyInvitationIdList.add(whatId);
                } else if (objType == 'Task') {
                    taskIdList.add(whatId);
                } else if (objType == 'Participant__c') {
                    // Added by Anitha
                    participantIdList.add(whatId);
                }
            }
        }
        system.debug('peIdList:::' + peIdList + 'ctpIdList::' + ctpIdList);

        //For Welcome Message functionality for Patient Delgate
        if (
            peIdList != null &&
            !peIdList.isEmpty() &&
            recipientIdSet != null &&
            !recipientIdSet.isEmpty()
        ) {
            populateWelcomMessageFlagsForDel(peIdList, recipientIdSet);
        }

        Map<Id, SurveyInvitation> surveyInvitationMap = new Map<Id, SurveyInvitation>();

        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>();
        Map<id, List<Participant_Enrollment__c>> contactIdPERMap = new Map<id, List<Participant_Enrollment__c>>();

        Map<Id, Task> taskMap = new Map<Id, Task>(
            [
                SELECT
                    Id,
                    WhatId,
                    OwnerId,
                    Task_Type__c, //KK
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Sponsor_AWS__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_AWS__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Study_Site__r.site__r.BillingCountryCode,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Survey_Invitation__r.IsTrialSurvey__c,
                    Ecoa_Task_Configuration_del__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Welcome_Message_Sent__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Welcome_Message_Delivered__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Participant_contact__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Study_AWS__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.From_Number__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Task
                WHERE Id IN :taskIdList OR Survey_Invitation__c IN :surveyInvitationIdList
            ]
        );
        system.debug('taskMap:::' + taskMap + 'taskMap::' + taskMap.values());
        for (Task tObj : taskMap.values()) {
            if (tobj.whatId != null) {
                if (String.valueOf(tobj.whatId.getSobjectType()) == 'Participant_Enrollment__c') {
                    peIdList.add(tobj.whatId);
                }
                if (String.valueOf(tobj.whatId.getSobjectType()) == 'Participant__c') {
                    ownerIdList.add(tobj.OwnerId);
                    participantIdList.add(tObj.whatId);
                }
            }
            system.debug('peIdList:::' + peIdList + 'ownerIdList::' + ownerIdList);
            if (tobj.Survey_Invitation__c != null) {
                // if (tobj.Survey_Invitation__r.IsTrialSurvey__c) {
                peIdList.add(tobj.Survey_Invitation__r.Participant_Enrollment__c);
                // }
            }
        }
        system.debug('peIdList:::' + peIdList);
        ///Added by Anitha
        Map<Id, Participant__c> participantMap = new Map<Id, Participant__c>(
            [
                SELECT
                    Id,
                    Contact__c,
                    Contact__r.Welcome_Message_Sent__c,
                    Contact__r.Welcome_Message_Delivered__c
                FROM Participant__c
                WHERE Id IN :participantIdList
            ]
        );
        Map<Id, Patient_Delegate_Enrollment__c> pdelIdMap = new Map<Id, Patient_Delegate_Enrollment__c>(
            [
                SELECT
                    Id,
                        Patient_Delegate__r.Participant__r.Full_Name__c,
                        Patient_Delegate__r.Id,
                        Welcome_Message_Sent__c,
                        Study_Email_Consent__c,
                        Study_SMS_Consent__c,
                        Welcome_Message_Delivered__c,
                        Patient_Delegate__r.Participant__r.Contact__c,
                        Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                        Patient_Delegate__r.Participant__r.First_Name__c,
                        Patient_Delegate__r.Participant__r.Last_Name__c,
                        Patient_Delegate__r.Contact__c,
                        Patient_Delegate__r.Participant__c,   
                        Patient_Delegate__r.Participant_Delegate__r.Id,
                        Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                        Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                        Patient_Delegate__r.Participant_Delegate__r.Email__c,
                        Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                        Status__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                        Participant_Enrollment__r.Name,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Patient_Delegate_Enrollment__c
                WHERE (Participant_Enrollment__c IN : peIdList OR Participant_Enrollment__r.Clinical_Trial_Profile__c IN :ctpIdList)
                AND Patient_Delegate__r.Contact__c IN : recipientIdSet
            ]
        );
        Map<Id, Participant_Enrollment__c> peIdMap = new Map<Id, Participant_Enrollment__c>(
            [
                SELECT
                    Id,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                    Clinical_Trial_Profile__r.Sponsor_AWS__c,
                    Clinical_Trial_Profile__r.Study_AWS__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Study_Site__r.site__r.BillingCountryCode,
                    Participant_contact__c,
                    Welcome_Message_Sent__c,
                    Welcome_Message_Delivered__c,
                    Study_Site__r.Pin_Point_ProjectId__c,
                    Study_Site__r.From_Number__c,
                    Study_Site__c,
                    Study_Site__r.Sponsor_AWS__c,
                    Study_Site__r.Study_AWS__c,
                    Permit_SMS_Text_for_this_study__c,
                    Study_Site__r.SMS_Are_Available__c,
                    (
                        SELECT
                            Id,
                            IsTrialSurvey__c,
                            Participant_Enrollment__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Sponsor_AWS__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_AWS__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                            Participant_Enrollment__r.Study_Site__r.site__r.BillingCountryCode,
                            Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c,
                            Participant_Enrollment__r.Study_Site__r.From_Number__c,
                            Participant_Enrollment__r.Study_Site__c,
                            Participant_Enrollment__r.Welcome_Message_Delivered__c,
                            Participant_Enrollment__r.Welcome_Message_Sent__c,
                            Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c,
                            Participant_Enrollment__r.Study_Site__r.Study_AWS__c,
                            Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c,
                            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c
                        FROM Survey_Invitations__r
                        WHERE Id IN :surveyInvitationIdList
                    )
                FROM Participant_Enrollment__c
                WHERE Id IN :peIdList OR Clinical_Trial_Profile__c IN :ctpIdList
            ]
        );
        Map<Id, Map<Id, Patient_Delegate_Enrollment__c>> delContIdMapOfPerIdPDEnromentMap = new Map<Id, Map<Id, Patient_Delegate_Enrollment__c>>();
        for(Patient_Delegate_Enrollment__c pdelEnrollment : pdelIdMap.values()){  // junction object records
            if (!delContIdMapOfPerIdPDEnromentMap.containskey(pdelEnrollment.Patient_Delegate__r.Contact__c)){
                Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = delContIdMapOfPerIdPDEnromentMap.get(pdelEnrollment.Patient_Delegate__r.Contact__c);
                perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
            }
            else{
                Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = new Map<Id, Patient_Delegate_Enrollment__c>();
                perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
            }
        }
        system.debug('peIdMap:::' + peIdMap);
        for (Participant_Enrollment__c peObj : peIdMap.values()) {
            Clinical_Trial_Profile__c ctpObj = new Clinical_Trial_Profile__c();
            ctpObj.Pin_Point_ProjectId__c = peObj.Study_Site__r.Pin_Point_ProjectId__c;
            ctpObj.Sponsor_AWS__c = peObj.Study_Site__r.Sponsor_AWS__c;
            ctpObj.Study_AWS__c = peObj.Study_Site__r.Study_AWS__c;
            ctpObj.CommunityTemplate__c = peObj.Clinical_Trial_Profile__r.CommunityTemplate__c;
            ctpObj.Study_Sponsor__c = peObj.Clinical_Trial_Profile__r.Study_Sponsor__c; // From Number Is missing Anitha

            ctpMap.put(peObj.Clinical_Trial_Profile__c, ctpObj);

            if (peObj.Survey_Invitations__r.size() > 0) {
                for (SurveyInvitation surveyInvitationObj : peObj.Survey_Invitations__r) {
                    surveyInvitationMap.put(surveyInvitationObj.Id, surveyInvitationObj);
                }
            }
            //populate PER records for each Contact in Map.
            if (contactIdPERMap.containsKey(peObj.Participant_contact__c)) {
                list<Participant_Enrollment__c> perTempList = contactIdPERMap.get(
                    peOBJ.Participant_contact__c
                );
                perTempList.Add(peOBJ);
                contactIdPERMap.put(peObj.Participant_contact__c, perTempList);
            } else {
                list<Participant_Enrollment__c> perTempList = new List<Participant_Enrollment__c>();
                perTempList.Add(peOBJ);
                contactIdPERMap.put(peObj.Participant_contact__c, perTempList);
            }
        }
        Map<Id, User> userIdMap = new Map<Id, User>(
            [
                SELECT
                    Id,
                    (
                        SELECT PermissionSet.Name
                        FROM PermissionSetAssignments
                        WHERE PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets()
                    )
                FROM User
                WHERE Id IN :ownerIdList
            ]
        );
        system.debug('notificationsList:::' + notificationsList);

        Map<Id, Televisit__c> televisitIdMap = new Map<Id, Televisit__c>(
            [
                SELECT
                    Id,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.Study_Site__c,
                    Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c,
                    Participant_Enrollment__r.Study_Site__r.Study_AWS__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c,
                    Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c,
                    Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                    Participant_Enrollment__r.Study_Site__r.From_Number__c,
                    Participant_Enrollment__r.Welcome_Message_Sent__c,
                    Participant_Enrollment__r.Welcome_Message_Delivered__c
                FROM Televisit__c
                WHERE Id IN :televisitIdList
            ]
        );
        Map<Id, Televisit_Attendee__c> televisitAttendeeIdMap = new Map<Id, Televisit_Attendee__c>(
            [
                SELECT
                    Id,
                    Televisit__r.Participant_Enrollment__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__r.Study_AWS__c,
                    Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c,
                    Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c,
                    Televisit__r.Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                    Televisit__r.Participant_Enrollment__r.Study_Site__r.From_Number__c,
                    Televisit__r.Participant_Enrollment__r.Welcome_Message_Sent__c,
                    Televisit__r.Participant_Enrollment__r.Welcome_Message_Delivered__c
                FROM Televisit_Attendee__c
                WHERE Id IN :televisitAttendeeIdList
            ]
        );
        for (Notification__c notObj : notificationsList) {
            Map<Id, String> participantContactSponsorMap = new Map<Id, String>();
            Id peId = null;
            if (notObj.WhatId__c != null) {
                Notification_Type__mdt messageType = NotificationService.getNotificationType(
                    notObj.Notification_Type__c
                );
                system.debug('messageType:::' + messageType);
                Boolean isPlatformLevel = true;
                String pinPoint;
                String sponsorName;
                String sponsorNameSms = 'IQVIA';
                String studyName;
                String ctpTemplateName;
                String studySiteId;
                String fromNumber; // Added by Anitha
                Boolean welcomemsgsent = false; // Added by Anitha
                Boolean welcomemsgDelivered = false; // Added by Anitha
                Id whatId = Id.valueOf(notObj.WhatId__c);
                Boolean isSMSAvailableForPER = false;
                String recipientID = notObj.Recipient__c;
                String objType = String.valueOf(whatId.getSobjectType());
                system.debug('objType:::' + objType + 'whatId:::' + whatId);

                if (messageType.IsStudyLevel__c) {
                    isPlatformLevel = false;
                    if (objType == 'Participant_Enrollment__c') {
                        Participant_Enrollment__c peOBJ = peIdMap.get(whatId);
                        pinPoint = peOBJ.Study_Site__r.Pin_Point_ProjectId__c;
                        sponsorName = peOBJ.Study_Site__r.Sponsor_AWS__c;
                        sponsorNameSms = peOBJ.Clinical_Trial_Profile__r.Study_Sponsor__c;
                        studyName = peOBJ.Study_Site__r.Study_AWS__c;
                        ctpTemplateName = peOBJ.Clinical_Trial_Profile__r.CommunityTemplate__c;
                        studySiteId = peOBJ.Study_Site__c;
                        fromNumber = peOBJ.Study_Site__r.From_Number__c; //Added by Anitha
                        welcomemsgsent = peOBJ.Welcome_Message_Sent__c; //Added by Anitha
                        welcomemsgDelivered = peOBJ.Welcome_Message_Delivered__c; //Added by Anitha
                        if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                            Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(whatId);
                            isSMSAvailableForPER = pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                        }
                        else {
                            isSMSAvailableForPER =
                            peOBJ.Permit_SMS_Text_for_this_study__c &&
                            peOBJ.Study_Site__r.SMS_Are_Available__c;
                        }
                        studySiteToFromNoMap.put(studySiteId, peOBJ.Study_Site__r.From_Number__c);
                        //If this method is called from platform Event
                        if (isPlatFormEvent) {
                            participantContactSponsorMap.put(
                                peOBJ.Participant_contact__c,
                                peOBJ.Clinical_Trial_Profile__r.Study_Sponsor__c
                            );
                            peId = peOBJ.Id;
                        }
                    } else if (objType == 'Clinical_Trial_Profile__c') {
                        sponsorName = ctpMap.get(whatId).Sponsor_AWS__c;
                        sponsorNameSms = ctpMap.get(whatId).Study_Sponsor__c;
                        studyName = ctpMap.get(whatId).Study_AWS__c;
                        ctpTemplateName = ctpMap.get(whatId).CommunityTemplate__c;

                        //Iterate over all the PERs for recipient and populate the countrySponsorKey for matching CTP with Notification whatId.
                        for (
                            Participant_Enrollment__c per : contactIdPERMap.get(notObj.recipient__c)
                        ) {
                            if (per.Clinical_Trial_Profile__c == whatId) {
                                studySiteId = per.Study_Site__c;
                                if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                    Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(per.Id);
                                    isSMSAvailableForPER =  pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c ;
                                }
                                else{
                                    isSMSAvailableForPER =
                                        per.Permit_SMS_Text_for_this_study__c &&
                                        per.Study_Site__r.SMS_Are_Available__c;
                                }
                                studySiteToFromNoMap.put(
                                    studySiteId,
                                    per.Study_Site__r.From_Number__c
                                );
                                pinPoint = per.Study_Site__r.Pin_Point_ProjectId__c;
                                fromNumber = per.Study_Site__r.From_Number__c; //Added by Anitha
                                welcomemsgsent = per.Welcome_Message_Sent__c; //Added by Anitha
                                welcomemsgDelivered = per.Welcome_Message_Delivered__c; //Added by Anitha

                                //If this method is called from platform Event
                                if (isPlatFormEvent) {
                                    participantContactSponsorMap.put(
                                        per.Participant_contact__c,
                                        per.Clinical_Trial_Profile__r.Study_Sponsor__c
                                    );
                                    peId = per.Id;
                                }

                                break;
                            }
                        }
                    } else if (objType == 'Task') {
                        System.debug(
                            '644: ' + String.valueOf(taskMap.get(whatId).WhatId.getSobjectType())
                        ); //String.valueOf(taskMap.get(whatId).Task_Type__c)
                        System.debug('645: ' + String.valueOf(taskMap.get(whatId).Task_Type__c));
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant_Enrollment__c'
                        ) {
                            pinPoint = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Pin_Point_ProjectId__c;
                            sponsorName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Sponsor_AWS__c;
                            sponsorNameSms = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Study_Sponsor__c;
                            studyName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Study_AWS__c;
                            ctpTemplateName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.CommunityTemplate__c;
                            studySiteId = peIdMap.get(taskMap.get(whatId).WhatId).Study_Site__c;
                            fromNumber = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.From_Number__c; //Added by Anitha
                            if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(taskMap.get(whatId).WhatId);
                                isSMSAvailableForPER = pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                            }
                            else{
                                isSMSAvailableForPER =
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                    .Permit_SMS_Text_for_this_study__c &&
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                    .Study_Site__r.SMS_Are_Available__c;
                            }
                            welcomemsgsent = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Welcome_Message_Sent__c; //Added by Anitha
                            welcomemsgDelivered = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Welcome_Message_Delivered__c; //Added by Anitha

                            studySiteToFromNoMap.put(
                                studySiteId,
                                peIdMap.get(taskMap.get(whatId).WhatId).Study_Site__r.From_Number__c
                            );
                            //If this method is called from platform Event
                            if (isPlatFormEvent) {
                                participantContactSponsorMap.put(
                                    peIdMap.get(taskMap.get(whatId).WhatId).Participant_contact__c,
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                        .Clinical_Trial_Profile__r.Study_Sponsor__c
                                );
                                peId = peIdMap.get(taskMap.get(whatId).WhatId).Id;
                            }
                        } else if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant__c' &&
                            String.valueOf(taskMap.get(whatId).Task_Type__c) == 'Ecoa' //TODO: check if Task_Type__c String =  eCOA is correct.
                        ) {
                            /* kk - Start */
                            //Specific for eCOA Task Notification.
                            System.debug('ecoa::' + taskMap);
                            pinPoint = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c;
                            sponsorName = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c;
                            sponsorNameSms = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c;
                            studyName = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Study_AWS__c;
                            ctpTemplateName = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                            studySiteId = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__c;
                            fromNumber = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.From_Number__c;
                            welcomemsgsent = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Welcome_Message_Sent__c;
                            welcomemsgDelivered = taskMap.get(whatId)
                                .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Welcome_Message_Delivered__c;
                            if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(taskMap.get(whatId).Ecoa_Task_Configuration_del__r.Participant_Enrollment__c);
                                isSMSAvailableForPER =  pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c ;
                            }
                            else{
                                isSMSAvailableForPER =
                                    taskMap.get(whatId)
                                    .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r
                                    .Permit_SMS_Text_for_this_study__c &&
                                    taskMap.get(whatId)
                                    .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r
                                    .Study_Site__r.SMS_Are_Available__c;
                            }
                            studySiteToFromNoMap.put(
                                studySiteId,
                                taskMap.get(whatId)
                                    .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.From_Number__c
                            );
                            //If this method is called from platform Event
                            if (isPlatFormEvent) {
                                participantContactSponsorMap.put(
                                    taskMap.get(whatId)
                                        .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Participant_contact__c,
                                    taskMap.get(whatId)
                                        .Ecoa_Task_Configuration_del__r.Participant_Enrollment__r
                                        .Clinical_Trial_Profile__r.Study_Sponsor__c
                                );
                                peId = taskMap.get(whatId)
                                    .Ecoa_Task_Configuration_del__r.Participant_Enrollment__c;
                            }
                        }
                    } else if (objType == 'Televisit__c' || objType == 'Televisit_Attendee__c') {
                        Televisit__c tvOBJ = null;
                        if (objType == 'Televisit__c') {
                            tvOBJ = televisitIdMap.get(whatId);
                        }
                        if (objType == 'Televisit_Attendee__c') {
                            Televisit_Attendee__c tva = televisitAttendeeIdMap.get(whatId);
                            if (tva != null)
                                tvOBJ = tva.Televisit__r;
                        }
                        if (tvOBJ != null) {
                            pinPoint = tvOBJ.Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c;
                            studySiteId = tvOBJ.Participant_Enrollment__r.Study_Site__c;
                            sponsorName = tvOBJ.Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c;
                            sponsorNameSms = tvOBJ.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c;
                            ctpTemplateName = tvOBJ.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                            studyName = tvOBJ.Participant_Enrollment__r.Study_Site__r.Study_AWS__c;
                            if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(tvOBJ.Participant_Enrollment__c);
                                isSMSAvailableForPER = pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c ;
                            }
                            else{
                                isSMSAvailableForPER =
                                    tvOBJ.Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c &&
                                    tvOBJ.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                            }
                            fromNumber = tvOBJ.Participant_Enrollment__r.Study_Site__r.From_Number__c;
                            welcomemsgsent = tvOBJ.Participant_Enrollment__r.Welcome_Message_Sent__c;
                            welcomemsgDelivered = tvOBJ.Participant_Enrollment__r.Welcome_Message_Delivered__c;
                        }
                    }
                } else {
                    if (objType == 'SurveyInvitation') {
                        if (surveyInvitationMap.get(whatId) != null) {
                            if (surveyInvitationMap.get(whatId).IsTrialSurvey__c) {
                                isPlatformLevel = false;
                                pinPoint = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Study_Site__r.Pin_Point_ProjectId__c;
                                fromNumber = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Study_Site__r.From_Number__c; //Added by Anitha
                                sponsorName = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Study_Site__r.Sponsor_AWS__c;
                                sponsorNameSms = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c;
                                studyName = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Study_Site__r.Study_AWS__c;
                                ctpTemplateName = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                                studySiteId = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Study_Site__c;
                                if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                    Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(surveyInvitationMap.get(whatId).Participant_Enrollment__c);
                                    isSMSAvailableForPER = pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                                }
                                else{
                                    isSMSAvailableForPER =
                                        surveyInvitationMap.get(whatId)
                                        .Participant_Enrollment__r.Permit_SMS_Text_for_this_study__c &&
                                        surveyInvitationMap.get(whatId)
                                        .Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                                }
                                welcomemsgsent = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Welcome_Message_Sent__c; //Added by Anitha
                                welcomemsgDelivered = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Welcome_Message_Delivered__c; //Added by Anitha

                                studySiteToFromNoMap.put(
                                    studySiteId,
                                    surveyInvitationMap.get(whatId)
                                        .Participant_Enrollment__r.Study_Site__r.From_Number__c
                                );
                                //If this method is called from platform Event
                                if (isPlatFormEvent) {
                                    participantContactSponsorMap.put(
                                        surveyInvitationMap.get(whatId)
                                            .Participant_Enrollment__r.Participant_contact__c,
                                        surveyInvitationMap.get(whatId)
                                            .Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Sponsor__c
                                    );
                                    peId = surveyInvitationMap.get(whatId)
                                        .Participant_Enrollment__c;
                                }
                            } else {
                                ctpTemplateName = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                            }
                        }
                    } else if (objType == 'Task') {
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant_Enrollment__c'
                        ) {
                            isPlatformLevel = false;
                            pinPoint = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Pin_Point_ProjectId__c;
                            fromNumber = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.From_Number__c; //Added by Anitha
                            sponsorName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Sponsor_AWS__c;
                            sponsorNameSms = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Study_Sponsor__c;
                            studyName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.Study_AWS__c;
                            ctpTemplateName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.CommunityTemplate__c;
                            studySiteId = peIdMap.get(taskMap.get(whatId).WhatId).Study_Site__c;
                            if(notObj.IsDelegate__c && delContIdMapOfPerIdPDEnromentMap.containsKey(recipientID)){
                                Patient_Delegate_Enrollment__c pdelEnrollmentrecrd = DelContIdMapOfPerIdPDEnromentMap.get(recipientID).get(taskMap.get(whatId).WhatId);
                                isSMSAvailableForPER = pdelEnrollmentrecrd.Study_SMS_Consent__c && pdelEnrollmentrecrd.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c;
                            }
                            else{
                                isSMSAvailableForPER =
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                    .Permit_SMS_Text_for_this_study__c &&
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                    .Study_Site__r.SMS_Are_Available__c;
                            }
                            welcomemsgsent = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Welcome_Message_Sent__c; //Added by Anitha
                            welcomemsgDelivered = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Welcome_Message_Delivered__c; //Added by Anitha

                            studySiteToFromNoMap.put(
                                studySiteId,
                                peIdMap.get(taskMap.get(whatId).WhatId).Study_Site__r.From_Number__c
                            );
                            //If this method is called from platform Event
                            if (isPlatFormEvent) {
                                participantContactSponsorMap.put(
                                    peIdMap.get(taskMap.get(whatId).WhatId).Participant_contact__c,
                                    peIdMap.get(taskMap.get(whatId).WhatId)
                                        .Clinical_Trial_Profile__r.Study_Sponsor__c
                                );
                                peId = peIdMap.get(taskMap.get(whatId).WhatId).Id;
                            }
                        }
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant__c'
                        ) {
                            if (participantMap.containsKey(taskMap.get(whatId).WhatId)) {
                                welcomemsgsent = participantMap.get(taskMap.get(whatId).WhatId)
                                    .Contact__r.Welcome_Message_Sent__c;
                                welcomemsgDelivered = participantMap.get(taskMap.get(whatId).WhatId)
                                    .Contact__r.Welcome_Message_Delivered__c;
                            }
                            if (
                                userIdMap.get(taskMap.get(whatId).OwnerId) != null &&
                                userIdMap.get(taskMap.get(whatId).OwnerId)
                                    .PermissionSetAssignments != null &&
                                userIdMap.get(taskMap.get(whatId).OwnerId)
                                    .PermissionSetAssignments.size() > 0
                            ) {
                                String permSetName = userIdMap.get(taskMap.get(whatId).OwnerId)
                                    .PermissionSetAssignments.get(0)
                                    .PermissionSet.Name;
                                Set<String> allPermissionSets = CommunityTemplateService.getAllPermissionSets();
                                for (String permiSet : allPermissionSets) {
                                    if (permiSet == permSetName) {
                                        ctpTemplateName = CommunityTemplateService.getTemplateByPermissionSetName(
                                                permiSet
                                            )
                                            .templateName;
                                    }
                                }
                            }
                        }
                    }
                }

                if (!isPlatformLevel) {
                    //If this method is called from platform Event
                    if (isPlatFormEvent) {
                        SMSOptOutService.notIdMapOfPartContactSponsorMap.put(
                            notObj.Id,
                            participantContactSponsorMap
                        );
                        SMSDeliveryStatusService.StudyLevelnotIdPEIdMap.put(notObj.Id, peId);
                    }
                    system.debug('isSMSAvailableForPER' + isSMSAvailableForPER);
                    if (isSMSAvailableForPER) {
                        //If Notification is Study level and SMS is opt in at PER and Study site both.
                        NotificationService.studyLevelSMSSet.Add(notObj.Id);
                    }
                } else {
                    //If Notification is platform level.
                    NotificationService.platfomLevelSMSSet.Add(notObj.Id);
                }
                ///Added by Anitha for SkipLevel SMS if AWS were not Present
                if (isPlatformLevel) {
                    whatId = Id.valueOf(notObj.WhatId__c);
                    objType = String.valueOf(whatId.getSobjectType());
                    if (objType == 'Participant__c') {
                        welcomemsgsent = participantMap.get(whatId)
                            .Contact__r.Welcome_Message_Sent__c;
                        welcomemsgDelivered = participantMap.get(whatId)
                            .Contact__r.Welcome_Message_Delivered__c;
                    }
                    Map<String, Config_API_Param__mdt> apiParamsMap = new Map<String, Config_API_Param__mdt>();
                    for (Config_API_Param__mdt mdt : [
                        SELECT DeveloperName, ParamValue__c
                        FROM Config_API_Param__mdt
                        WHERE ConfigAPI__r.DeveloperName = :API_MULESOFT_SMS
                    ]) {
                        apiParamsMap.put(mdt.DeveloperName, mdt);
                    }
                    if (!apiParamsMap.isEmpty()) {
                        pinPoint = apiParamsMap.get(PIN_POINT_PROJECT_ID).ParamValue__c;
                        sponsorName = apiParamsMap.get(PL_SPONSOR).ParamValue__c;
                        studyName = apiParamsMap.get(PL_STUDY).ParamValue__c;
                        fromNumber = apiParamsMap.get(FROM_NUMBER).ParamValue__c;
                    }
                } 
                NotificationService.welcomemsgSent.put(notObj.Id, welcomemsgsent);
                NotificationService.welcomemsgDelivered.put(notObj.Id, welcomemsgDelivered);
                if (
                    !String.isBlank(pinPoint) &&
                    !String.isBlank(sponsorName) &&
                    !String.isBlank(studyName) &&
                    !String.isBlank(fromNumber)
                ) {
                    if (!NotificationService.awsDetailsAreAvailable.containskey(notObj.Id)) {
                        NotificationService.awsDetailsAreAvailable.put(notObj.Id, true);
                    }
                } else {
                    if (!NotificationService.awsDetailsAreAvailable.containskey(notObj.Id)) {
                        NotificationService.awsDetailsAreAvailable.put(notObj.Id, false);
                    }
                }
                //If this method is not called from platform Event
                if (!isPlatFormEvent) {
                    PinpointWrapper pinpointWrapperObj = new PinpointWrapper();
                    pinpointWrapperObj.isPlatformlevel = isPlatformLevel;
                    pinpointWrapperObj.studyPinpoint = pinPoint;
                    pinpointWrapperObj.sponsorName = sponsorName;
                    pinpointWrapperObj.sponsorNameSms = sponsorNameSms;
                    pinpointWrapperObj.studyName = studyName;
                    pinpointWrapperObj.ctpTemplate = ctpTemplateName;
                    pinpointWrapperObj.studySiteId = studySiteId;
                    pinpointWrapperObj.fromNumber = fromNumber; // Added by Anitha
                    pinPointWrapperMapObj.put(notObj.Id, pinpointWrapperObj);
                }
            }
        }
        return pinPointWrapperMapObj;
    }

    /**
     * @description: This method populate them Map for WelcomeMessageSend and WelcomeMessageDelivered Flags from junction object betwene Participant Enrollment
     *               and Patient Delegate contact record.
     * @author: Krishna Mahto
     * @param:  peIdList
     * @param:  recipientIdSet
     * @return: Void
     **/
    public static void populateWelcomMessageFlagsForDel(List<Id> peIdList, Set<Id> recipientIdSet) {
        //Get list of ParticipantEnrollmentPatientDelJunction records
        List<Patient_Delegate_Enrollment__c> perDelJunctionRecList = getPERPatientDelJunctionRecords(
            peIdList,
            recipientIdSet
        );

        //Populate the Maps for Welome Message Sent and Welcome Message Delevered flags.
        for (Patient_Delegate_Enrollment__c perPdObj : perDelJunctionRecList) {
            String perIdDelContIdKey =
                perPdObj?.Participant_Enrollment__c +
                '_' +
                perPdObj?.Patient_Delegate__r.Contact__c;
            NotificationService.perIdDelConIdWelcomeMessageSentMap.put(
                perIdDelContIdKey,
                perPdObj.Welcome_Message_Sent__c
            );
            NotificationService.perIdDelConIdWelcomeMessageDeleveredMap.put(
                perIdDelContIdKey,
                perPdObj.Welcome_Message_Delivered__c
            );
        }
    }
    /**
     * @description: This method will return list of ParticipantEnrollmentPatientDelJunction records.
     * @author: Krishna Mahto
     * @param:  peIdList
     * @param:  recipientIdSet
     * @return:  List<Patient_Delegate_Enrollment__c>
     **/
    public static List<Patient_Delegate_Enrollment__c> getPERPatientDelJunctionRecords(
        List<Id> peIdList,
        Set<Id> recipientIdSet
    ) {
        //Query to get the Participant Enrollment and Patient Delegate contact junction record. //kk
        List<Patient_Delegate_Enrollment__c> perDelJunctionRecList = [
            SELECT
            Id,
            Participant_Enrollment__c,
            Patient_Delegate__c,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Participant__c,
            Name,
            Welcome_Message_Sent__c,
            Study_Email_Consent__c,
            Study_SMS_Consent__c,
            Welcome_Message_Delivered__c,
            Status__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.study__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c IN :peIdList
            AND Patient_Delegate__r.Contact__c IN :recipientIdSet
        ];
        return perDelJunctionRecList;
    }
}