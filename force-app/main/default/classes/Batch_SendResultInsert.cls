global class Batch_SendResultInsert implements Database.Batchable<Notification__c>{
    private static final string BELL_NOTIFICATION_TARGET_TYPE = 'Bell';
    String userRoleComm;
    Participant_Enrollment__c perObj;
    private static boolean excecuteOnce = true;
    List<Notification__c> notificationList = new List<Notification__c>();
 
     public Batch_SendResultInsert(List<Notification__c> allNotificationList) {
         notificationList = allNotificationList;         
     }
     public Iterable<Notification__c> start(Database.BatchableContext BC) {
       return notificationList;
       
     }
  
     global void execute(Database.BatchableContext BC, List<Notification__c> notificationsList) {                  
        try {
            if(notificationsList.size()>0){   
                NotificationResultService service = new NotificationResultService(notificationsList);
                ParametrizedMessageService parametrizedMessageService = new ParametrizedMessageService();
                Map<Id,Notification__c> notificationsMap = new Map<Id,Notification__c>([
                                                        SELECT
                                                            Id,
                                                            Notification_Type__c,
                                                            Recipient__c,
                                                            Recipient__r.Language__c
                                                            FROM Notification__c
                                                        WHERE Id IN : (new Map<Id,Notification__c>(notificationsList)).keySet()
                                                    ]);

                for(Notification__c notify : notificationsList){
                    Notification_type__mdt nType = NotificationService.getNotificationType(notify.Notification_Type__c);
                   
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

                for(Notification__c n : notificationsList){
                    String userRole = '';
                    Notification_type__mdt nType = NotificationService.getNotificationType(n.Notification_Type__c);
                    String messageBody = parametrizedMessageService.getMessage(n.Id);
                    for(Notification_Target__mdt target : nType.Notification_Targets__r){
                        System.debug('🛑🛑 notification user group:'+n.Target_User_Group__c+':: target user group::'+target.Target_User_Group__c);
                        if(target.Target_User_Group__c == n.Target_User_Group__c){
                            String redirectTarget = '';
                            if(target.Is_Redirect__c && target.Target_Type__c == 'Bell'){
                                redirectTarget = target.Redirect_URL__c;
                                System.debug('🛑🛑redirect target after removing placeholders::'+redirectTarget);
                            }
                            if(n.Target_User_Group__c == 'Self'){
                                userRole = userRoleComm;
                            }else{
                                if(n.Target_User_Group__c.startsWith('PI')){
                                    userRole = 'PI';
                                }else{
                                    userRole = n.Target_User_Group__c;
                                }
                            }

                            if(n.Community_Type__c != null){
                                service.setSentForBell(n.Id, BELL_NOTIFICATION_TARGET_TYPE , messageBody,target.Is_Redirect__c ? redirectTarget : null, userRole, n.Community_Type__c);
                            }

                        }
                    }
                }

                service.updateResults();
            }   
        }
        catch (DmlException  e) {
           // System.debug('e.getMessage(): ' + e.getMessage());
            //System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
         }
     }
 
     global void finish(Database.BatchableContext BC) {
        System.debug('In Finish Method');
     }
 }