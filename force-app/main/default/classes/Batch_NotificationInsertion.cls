/*********************************************************************************************************************
* @description: This batch class is created to handle Notifications of type 'BELL' when records more than 10000
*
* @created: 11 November 2022

**********************************************************************************************************************
* Modification Log
* Version			Developer		Date			Remarks
*---------------------------------------------------------------------------------------------------------------------
*
**********************************************************************************************************************
*/
global class Batch_NotificationInsertion implements Database.Batchable<Notification__c>,Database.Stateful{

   global List<Notification__c> notificationList = new List<Notification__c>();
   global List<Notification__c> allNotificationsList = new List<Notification__c>();
   global List<Id> notificationIds = new List<Id>();

    public Batch_NotificationInsertion(List<Notification__c> allNotificationList) {
        this.allNotificationsList = allNotificationList;        
    }
    public Iterable<Notification__c> start(Database.BatchableContext BC) {
      return allNotificationsList;      
    }

    global void execute(Database.BatchableContext BC, List<Notification__c> notificationsList) {
        try{
            Database.SaveResult[] srList = Database.insert(notificationsList, true);

            for(Integer i = 0; i < srList.size(); i++) {
                Database.SaveResult sr = srList[i];
                Notification__c eachNotify = notificationsList[i];

                if(sr.isSuccess()){
                    if(sr.getId() == eachNotify.Id){
                        notificationList.add(eachNotify);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('==Error Occured=='+ ex.getMessage());
        }
      
    }

    global void finish(Database.BatchableContext BC) {       
       Database.executeBatch(new Batch_SendResultInsert(notificationList));
    }
}