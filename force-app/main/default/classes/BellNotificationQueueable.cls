/*********************************************************************************************************************
* @description: This class handles insertion of Send Result records for the case of Bell Notification type
*
* @created: 13 October 2022

**********************************************************************************************************************
* Modification Log
* Version			Developer		Date			Remarks
*---------------------------------------------------------------------------------------------------------------------
*
**********************************************************************************************************************
*/
public class BellNotificationQueueable implements Queueable, Database.AllowsCallouts {
    private static final string BELL_NOTIFICATION_TARGET_TYPE = 'Bell';
    List<Notification__c> notifications;
    Study_Site__c studySiteDetails;
    String selectedStatus = '';
    String userRoleComm;
    Participant_Enrollment__c perObj;
    private static boolean excecuteOnce = true;

    public BellNotificationQueueable(List<Notification__c> notificationList){
        notifications = notificationList;
    }

    public BellNotificationQueueable(List<Notification__c> notificationList, Study_Site__c studySiteDetails, String selectedStatus, String userRole){
        notifications = notificationList;
        this.studySiteDetails = studySiteDetails;
        this.selectedStatus = selectedStatus;
        userRoleComm = userRole;
    }

    public void execute(QueueableContext context){
        NotificationResultService service = new NotificationResultService(notifications);
		ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
        Map<Id,Notification__c> notificationsMap = new Map<Id,Notification__c>([
                                                        SELECT
                                                            Id,
                                                            Notification_Type__c,
                                                            Recipient__c,
                                                            Recipient__r.Language__c
                                                            FROM Notification__c
                                                        WHERE Id IN : (new Map<Id,Notification__c>(notifications)).keySet()
                                                    ]);

		for(Notification__c notify : notifications){
			Notification_type__mdt nType = NotificationService.getNotificationType(notify.Notification_Type__c);
            //get participant enrollment records
            if(excecuteOnce && notify.WhatId__c != null && notify.WhatId__c.startsWith('a1U') ){
                excecuteOnce = false;
                List<Participant_Enrollment__c> perList = [SELECT Id,Study_Site__c,
                                                                    Name,
                                                                    Participant__r.First_Name__c,
                                                                    Participant__r.Last_Name__c,
                                                                    Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                                                            FROM Participant_Enrollment__c
                                                            WHERE Id = :notify.WhatId__c];
                this.perObj = perList.get(0);
            }
			for(Notification_Target__mdt target : nType.Notification_Targets__r){
				if(BELL_NOTIFICATION_TARGET_TYPE.equalsIgnoreCase(target.Target_Type__c) &&
                    (target.Target_User_Group__c != null && target.Target_User_Group__c.equalsIgnoreCase(notify.Target_User_Group__c) )
                ){
                    parametrizedMessageService.addMessage(
                        notify.Id,
                        target.Message_Body__c,
                        notify.WhatId__c,
                        nType.Parameters_Provider__r?.DeveloperName,
                        notificationsMap.get(notify.Id)?.Recipient__r?.Language__c
                    );
				}
			}
		}
        parametrizedMessageService.processMessages();

        for(Notification__c n : notifications){
            String userRole = '';
            Notification_type__mdt nType = NotificationService.getNotificationType(n.Notification_Type__c);
            String messageBody = parametrizedMessageService.getMessage(n.Id);
            for(Notification_Target__mdt target : nType.Notification_Targets__r){
                if(target.Target_User_Group__c == n.Target_User_Group__c){
                    String redirectTarget = '';
                    if(target.Is_Redirect__c && target.Target_Type__c == 'Bell'){
                        redirectTarget = target.Redirect_URL__c;
                        if(target.DeveloperName == 'Bulk_Import_Success_Bell'){
                            redirectTarget = redirectTarget.replace('{trialId}',studySiteDetails.Clinical_Trial_Profile__c);
                            redirectTarget = redirectTarget.replace('{ssId}',studySiteDetails.Id);
                        }
                        if(target.DeveloperName == 'PI_Bulk_Import_Success_Bell' || target.DeveloperName == 'SS_L1_Bulk_Import_Success_Bell' || target.DeveloperName == 'SS_L2_Bulk_Import_Success_Bell' || target.DeveloperName == 'SS_L3_Bulk_Import_Success_Bell'){
                            redirectTarget = redirectTarget.replace('{sid}',studySiteDetails.Clinical_Trial_Profile__c);
                            redirectTarget = redirectTarget.replace('{ssid}',studySiteDetails.Id);
                            redirectTarget = redirectTarget.replace('{status}',selectedStatus);
                        }
                        if(target.DeveloperName == 'PI_as_Tele_visit_Attendee' ||
                            target.DeveloperName == 'SS_L1_as_Tele_visit_Attendee' ||
                            target.DeveloperName == 'SS_L2_as_Tele_visit_Attendee'||
                            target.DeveloperName == 'SS_L3_as_Tele_visit_Attendee'){

                                redirectTarget = redirectTarget.replace('{perName}',perObj.Name);
                                redirectTarget = redirectTarget.replace('{FName}',perObj.Participant__r.First_Name__c);
                                redirectTarget = redirectTarget.replace('{LName}',perObj.Participant__r.Last_Name__c);
                        }
                    }
                    if(n.Target_User_Group__c == 'Self'){
                        userRole = userRoleComm;
                    }else{
                        if(n.Target_User_Group__c.startsWith('PI') || n.Target_User_Group__c.startsWith('Pi')){
                            userRole = 'PI';
                        }else{
                            userRole = n.Target_User_Group__c;
                        }
                    }

                    if(studySiteDetails != null){
                        service.setSentForBell(n.Id, BELL_NOTIFICATION_TARGET_TYPE , messageBody,target.Is_Redirect__c ? redirectTarget : null, userRole, studySiteDetails.Clinical_Trial_Profile__r.CommunityTemplate__c);
                    }else if(n.Community_Type__c != null){
                        service.setSentForBell(n.Id, BELL_NOTIFICATION_TARGET_TYPE , messageBody,target.Is_Redirect__c ? redirectTarget : null, userRole, n.Community_Type__c);
                    }

                }
            }
        }

        service.updateResults();
    }
}