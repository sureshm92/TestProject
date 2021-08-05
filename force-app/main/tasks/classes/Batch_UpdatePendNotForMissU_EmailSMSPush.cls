
/*
AIQ Steps :
Execue the below step in Developer console

Go to Developer Console --> Open "Open and execute Annonymous window --> paste the script Database.executeBatch(new Batch_UpdatePendingNotForMissU_Email_SMS_Push(), 200); --> Execue 

*/
// This is on Demand batch to find the Pending Notification Records for Miss U email/SMS/Push Notifications created before current day and update it to failed status.
// This batch will only run if Batch_ProcessNotifications job got stopped during deployment and need to restart again. Before restarting the Batch_ProcessNotifications job, we need to clean the pending Miss u email/SMS/Push notifications. 

public class Batch_UpdatePendNotForMissU_EmailSMSPush implements
    Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator(
            [SELECT Id,
					CreatedDate,
					Status__c 
					FROM Notification__c 
					WHERE Notification_Type__c = 'Message_to_PT_has_not_Logged_In_Type' 
					AND Status__c = 'Pending' 
					AND createdDate <= Yesterday]
        );
    }
	
public void execute(Database.BatchableContext bc, List<Notification__c> scope){       
		for(Notification__c n : scope){
				n.Status__c='Failed';
		}

		if(!scope.isEmpty()){
			TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
			update scope;
		}

    }
    public void finish(Database.BatchableContext bc){
        
    }
}