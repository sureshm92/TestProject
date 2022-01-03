/**
 * Created by Olga Skrynnikova on 12/16/2019.
 * Refactored by Pijush Kar on 09/30/2021
 */

public with sharing class Action_SendSMS implements Action {
    private List<Id> notificationIds;
    private Map<Id, PinpointWrapper> pinPointWrapperMap;
    public static Map<String,String> countrySponsorFromNoMap = new Map<String,String>();

    transient private NotificationResultService sendResultService;
    transient private IntegrationLog__c log;
    public static final String PHONE_TYPE_MOBILE = 'Mobile';
    public static final String PERMISSION_COMMUNITY_DEFAULT_NAME = 'Community_Default';
    public static final String PERMISSION_COMMUNITY_GSK_NAME = 'Community_GSK_Pan_Oncology';

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
        public String countrySponsorKey;
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
        public String studyName;
        public String ctpTemplate;
        public String countrySponsorKey;
    }

    public Action_SendSMS(List<Notification__c> notifications) {
        this.notificationIds = SObjectHelper.toIdsList(notifications);
        this.pinPointWrapperMap = processPlatformLevelCheck(notifications);
    }

    public void execute() {
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
                Notification__r.Notification_Type__c,
                Notification__r.Task_Id__c
            FROM Send_Result__c
            WHERE
                Notification__c IN :notificationIds
                AND Target_Type__c = :NotificationService.NOTIFICATION_TARGET_TYPE_SMS
        ]) {
            String phoneNumber = smsChannel.Notification__r.Recipient__r.MobilePhone;
            //  Boolean isPlatformLevel = true;
            // String pinPoint;
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
                    msgParam.countrySponsorKey= pinPointWrapperObj.countrySponsorKey;
                    String shortCommunityName = '';
                    String url = '';
                    if (
                        pinPointWrapperObj.isPlatformlevel ||
                        pinPointWrapperObj.ctpTemplate == 'Default'
                    ) {
                        shortCommunityName = label.IQVIA_Patient_Portal;
                    } else if (pinPointWrapperObj.ctpTemplate == 'GSK') {
                        shortCommunityName = label.Gather_Share_Know;
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
        List<Id> ctpIdList = new List<Id>();
        List<Id> taskIdList = new List<Id>();
        List<Id> surveyInvitationIdList = new List<Id>();
        List<Id> ownerIdList = new List<Id>();
        Set<String> sponsorNameSet = new Set<String>(); 
        Set<String> countryCodeSet = new Set<String>();

        for (Notification__c notificationObj : notificationsList) {
            if (notificationObj.WhatId__c != null) {
                Id whatId = Id.valueOf(notificationObj.WhatId__c);
                String objType = String.valueOf(whatId.getSobjectType());

                if (objType == 'Participant_Enrollment__c') {
                    peIdList.add(whatId);
                } else if (objType == 'Clinical_Trial_Profile__c') {
                    ctpIdList.add(whatId);
                } else if (objType == 'Task') {
                    taskIdList.add(whatId);
                }
                if (objType == 'SurveyInvitation') {
                    surveyInvitationIdList.add(whatId);
                } else if (objType == 'Task') {
                    taskIdList.add(whatId);
                }
            }
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
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Sponsor_AWS__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_AWS__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Survey_Invitation__r.Participant_Enrollment__r.Study_Site__r.site__r.BillingCountryCode,
                    Survey_Invitation__r.IsTrialSurvey__c
                FROM Task
                WHERE Id IN :taskIdList OR Survey_Invitation__c IN :surveyInvitationIdList
            ]
        );
        for (Task tObj : taskMap.values()) {
            if (tobj.whatId != null) {
                if (String.valueOf(tobj.whatId.getSobjectType()) == 'Participant_Enrollment__c') {
                    peIdList.add(tobj.whatId);
                }
                if (String.valueOf(tobj.whatId.getSobjectType()) == 'Participant__c') {
                    ownerIdList.add(tobj.OwnerId);
                }
            }
            if (tobj.Survey_Invitation__c != null) {
                // if (tobj.Survey_Invitation__r.IsTrialSurvey__c) {
                    peIdList.add(tobj.Survey_Invitation__r.Participant_Enrollment__c);
                // }
            }
        }

        Map<Id, Participant_Enrollment__c> peIdMap = new Map<Id, Participant_Enrollment__c>(
            [
                SELECT
                    Id,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                    Clinical_Trial_Profile__r.Sponsor_AWS__c,
                    Clinical_Trial_Profile__r.Study_AWS__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Study_Site__r.site__r.BillingCountryCode,
                    Participant_contact__c,
                    (
                        SELECT
                            Id,
                            IsTrialSurvey__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Sponsor_AWS__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_AWS__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                            Participant_Enrollment__r.Study_Site__r.site__r.BillingCountryCode
                        FROM Survey_Invitations__r
                        WHERE Id IN :surveyInvitationIdList
                    )
                FROM Participant_Enrollment__c
                WHERE Id IN :peIdList OR Clinical_Trial_Profile__c IN :ctpIdList
            ]
        );
        for (Participant_Enrollment__c peObj : peIdMap.values()) {
            Clinical_Trial_Profile__c ctpObj = new Clinical_Trial_Profile__c();
            ctpObj.Pin_Point_ProjectId__c = peObj.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c;
            ctpObj.Sponsor_AWS__c = peObj.Clinical_Trial_Profile__r.Sponsor_AWS__c;
            ctpObj.Study_AWS__c = peObj.Clinical_Trial_Profile__r.Study_AWS__c;
            ctpObj.CommunityTemplate__c = peObj.Clinical_Trial_Profile__r.CommunityTemplate__c;

            ctpMap.put(peObj.Clinical_Trial_Profile__c, ctpObj);
            
            if (peObj.Survey_Invitations__r.size() > 0) {
                for (SurveyInvitation surveyInvitationObj : peObj.Survey_Invitations__r) {
                    surveyInvitationMap.put(surveyInvitationObj.Id, surveyInvitationObj);
                }
            }
            //populate PER records for each Contact in Map. 
            if(contactIdPERMap.containsKey(peObj.Participant_contact__c)){
				list<Participant_Enrollment__c> perTempList = contactIdPERMap.get(peOBJ.Participant_contact__c);
				perTempList.Add(peOBJ);
				contactIdPERMap.put(peObj.Participant_contact__c,perTempList);
			}else{
				list<Participant_Enrollment__c> perTempList = new list<Participant_Enrollment__c>();
				perTempList.Add(peOBJ);
				contactIdPERMap.put(peObj.Participant_contact__c,perTempList);
			}

            sponsorNameSet.add(peObj.Clinical_Trial_Profile__r.CommunityTemplate__c); 
            countryCodeSet.add(peObj.Study_Site__r.site__r.BillingCountryCode); 
            if(!sponsorNameSet.isEmpty() && !countryCodeSet.isEmpty()){
                createCountrySponsorFromNoMap(countryCodeSet, sponsorNameSet); 
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

        for (Notification__c notObj : notificationsList) {
            if (notObj.WhatId__c != null) {
                Notification_Type__mdt messageType = NotificationService.getNotificationType(
                    notObj.Notification_Type__c
                );
                Boolean isPlatformLevel = true;
                String pinPoint;
                String sponsorName;
                String studyName;
                String ctpTemplateName;
                String countrySponsorKey;
                Id whatId = Id.valueOf(notObj.WhatId__c);

                String objType = String.valueOf(whatId.getSobjectType());

                if (messageType.IsStudyLevel__c) {
                    isPlatformLevel = false;
                    if (objType == 'Participant_Enrollment__c') {
                        Participant_Enrollment__c peOBJ = peIdMap.get(whatId);
                        pinPoint = peOBJ.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c;
                        sponsorName = peOBJ.Clinical_Trial_Profile__r.Sponsor_AWS__c;
                        studyName = peOBJ.Clinical_Trial_Profile__r.Study_AWS__c;
                        ctpTemplateName = peOBJ.Clinical_Trial_Profile__r.CommunityTemplate__c;
                        countrySponsorKey = peObj.Study_Site__r.site__r.BillingCountryCode + '_' + peOBJ.Clinical_Trial_Profile__r.CommunityTemplate__c;
                    } else if (objType == 'Clinical_Trial_Profile__c') {
                        pinPoint = ctpMap.get(whatId).Pin_Point_ProjectId__c;
                        sponsorName = ctpMap.get(whatId).Sponsor_AWS__c;
                        studyName = ctpMap.get(whatId).Study_AWS__c;
                        ctpTemplateName = ctpMap.get(whatId).CommunityTemplate__c;
                        //Iterate over all the PERs for recipient and populate the countrySponsorKey for matching CTP with Notification whatId. 
						for(Participant_Enrollment__c per: contactIdPERMap.get(notObj.recipient__c)){
							if(per.Clinical_Trial_Profile__c == whatId){
								countrySponsorKey = per.Study_Site__r.site__r.BillingCountryCode + '_' + per.Clinical_Trial_Profile__r.CommunityTemplate__c; 
								break;
							}
							
						}
                    } else if (objType == 'Task') {
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant_Enrollment__c'
                        ) {
                            pinPoint = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Pin_Point_ProjectId__c;
                            sponsorName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Sponsor_AWS__c;
                            studyName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Study_AWS__c;
                            ctpTemplateName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.CommunityTemplate__c;
                            String countryCode = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.site__r.BillingCountryCode; 
                            countrySponsorKey = countryCode + '_' + ctpTemplateName; 
                        }
                    }
                } else {
                    if (objType == 'SurveyInvitation') {
                        if (surveyInvitationMap.get(whatId) != null) {
                            if (surveyInvitationMap.get(whatId).IsTrialSurvey__c) {
                            isPlatformLevel = false;
                            pinPoint = surveyInvitationMap.get(whatId)
                                .Participant_Enrollment__r.Clinical_Trial_Profile__r.Pin_Point_ProjectId__c;
                            sponsorName = surveyInvitationMap.get(whatId)
                                .Participant_Enrollment__r.Clinical_Trial_Profile__r.Sponsor_AWS__c;
                            studyName = surveyInvitationMap.get(whatId)
                                .Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_AWS__c;
                            ctpTemplateName = surveyInvitationMap.get(whatId)
                                .Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                            } else {
                                ctpTemplateName = surveyInvitationMap.get(whatId)
                                    .Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                            }
                            String countryCode = surveyInvitationMap.get(whatId)
                            .Participant_Enrollment__r.Study_Site__r.site__r.BillingCountryCode;
                            countrySponsorKey = countryCode + '_' + ctpTemplateName; 
                        }
                    } else if (objType == 'Task') {
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant_Enrollment__c'
                        ) {
                            isPlatformLevel = false;
                            pinPoint = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Pin_Point_ProjectId__c;
                            sponsorName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Sponsor_AWS__c;
                            studyName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.Study_AWS__c;
                            ctpTemplateName = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Clinical_Trial_Profile__r.CommunityTemplate__c;
                            String countryCode = peIdMap.get(taskMap.get(whatId).WhatId)
                                .Study_Site__r.site__r.BillingCountryCode; 
                            countrySponsorKey = countryCode + '_' + ctpTemplateName; 
                        }
                        if (
                            String.valueOf(taskMap.get(whatId).WhatId.getSobjectType()) ==
                            'Participant__c'
                        ) {
                            // System.debug('I am here');
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
                                if (permSetName == PERMISSION_COMMUNITY_DEFAULT_NAME) {
                                    ctpTemplateName = 'Default';
                                } else if (permSetName == PERMISSION_COMMUNITY_GSK_NAME) {
                                    ctpTemplateName = 'GSK';
                                }
                            }
                        }
                    }
                }
                PinpointWrapper pinpointWrapperObj = new PinpointWrapper();
                pinpointWrapperObj.isPlatformlevel = isPlatformLevel;
                pinpointWrapperObj.studyPinpoint = pinPoint;
                pinpointWrapperObj.sponsorName = sponsorName;
                pinpointWrapperObj.studyName = studyName;
                pinpointWrapperObj.ctpTemplate = ctpTemplateName;
                pinpointWrapperObj.countrySponsorKey = countrySponsorKey; 
                pinPointWrapperMapObj.put(notObj.Id, pinpointWrapperObj);
            }
        }
        return pinPointWrapperMapObj;
    }

    //This method creates a map of from number for corresponding sponsor and country combination. 
    public Void createCountrySponsorFromNoMap (Set<String> countryCodeSet, Set<String> sponsorNameSet) {
        for(Sponsor_Country_Code__c scc: [SELECT id,Country__c, Sponsor_Name__c, From_Number__c from Sponsor_Country_Code__c WHERE Country__c IN: countryCodeSet AND Sponsor_Name__c IN: sponsorNameSet]){
            String countrySponsorKey = scc.Country__c + '_' + scc.Sponsor_Name__c;
            countrySponsorFromNoMap.put(countrySponsorKey,scc.From_Number__c);
        }         
    }
}
