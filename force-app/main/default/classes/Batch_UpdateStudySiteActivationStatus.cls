/***
* Purpose: To update the site activation field based on override PI referral status field.
* Also to update override PI referral status field based on mapping provided.
* */
global class Batch_UpdateStudySiteActivationStatus implements Database.Batchable<sObject> {
    public List<Id> specificRecordIdList { get; set; }
    Map<String, String> siteActivationStatusMap = new Map<String, String>{
        'On Hold' => 'On Hold',
        'On Hold (Admin)' => 'On Hold',
        'Accepted' => 'Activated',
        'Accepted (Admin)' => 'Activated (Admin)',
        'Deactivated (Admin)' => 'Deactivated (Admin)',
        'Invitation Sent' => Null,
        'Non-Responsive (Admin)' => 'Deactivated',
        'Declined (Acceptance)' => 'Deactivated',
         Null => Null
    };
                
    Map<String, String> overrideStatusMap = new Map<String, String>{
        'On Hold' => 'Accepted',
        'On Hold (Admin)' => 'Accepted',
        'Invitation Sent' => 'Invitation Sent',
        'Accepted' => 'Accepted',
        'Accepted (Admin)' => 'Accepted',
        'Deactivated (Admin)' => 'Deactivated',
        'Non-responsive (Admin)' => 'Deactivated',
        'Declined (Acceptance)' => 'Deactivated',
         null => 'None'
    };
                            
                            
    global Database.QueryLocator start(Database.BatchableContext bc) {
         List<String> statusList = new List<String>{'On Hold', 'On Hold (Admin)','Accepted', 'Accepted (Admin)','None', 'Invitation Sent','Deactivated (Admin)','Non-responsive (Admin)','Declined (Acceptance)',Null};
         String query = 'SELECT Id, Site_Activation_Status__c, Override_PI_Referral_Status__c FROM Study_Site__c WHERE Override_PI_Referral_Status__c IN:statusList and Id IN:specificRecordIdList';
                                
               return Database.getQueryLocator(query);
          }
    
    global void execute(Database.BatchableContext bc, List<Study_Site__c> ssList) {
        
        List<Study_Site__c> recordsToUpdate = new List<Study_Site__c>();
        
        try{
            
            for (Study_Site__c record : ssList) {
                
                String existingOverrideStatus = record.Override_PI_Referral_Status__c;
                if(existingOverrideStatus != null){
                    String newSiteActivationStatus = siteActivationStatusMap.containsKey(existingOverrideStatus) ? siteActivationStatusMap.get(existingOverrideStatus) : null;
                    String newOverrideStatus = overrideStatusMap.containsKey(existingOverrideStatus) ? overrideStatusMap.get(existingOverrideStatus) : null;
                    
                    if (newSiteActivationStatus != null) {
                        record.Site_Activation_Status__c = newSiteActivationStatus;
                    }
                    
                    if (newOverrideStatus != null) {
                        record.Override_PI_Referral_Status__c = newOverrideStatus;
                    }
                }
            }
            
            if(!ssList.isEmpty()){
                TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.StudySiteTriggerHandler.class);
                update ssList;
            }
        }catch(Exception ex){
            system.debug('Error Occured :: '+ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}