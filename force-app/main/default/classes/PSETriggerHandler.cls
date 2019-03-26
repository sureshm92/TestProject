/**
 * Created by Leonid Bartenev
 */

public class PSETriggerHandler {
    
    public static void processStatusHistory(){
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            List<PSE_Status_History__c> pseStatusHistories = new List<PSE_Status_History__c>();
            Map<Id, Participant_Study_Enrollment__c> oldMap;
            Map<Id, Participant_Study_Enrollment__c> newMap = (Map<Id, Participant_Study_Enrollment__c>)Trigger.newMap;
            if(Trigger.isUpdate) oldMap = (Map<Id, Participant_Study_Enrollment__c>)Trigger.oldMap;
            for(Participant_Study_Enrollment__c pse : newMap.values()){
                if(Trigger.isInsert || (Trigger.isUpdate && pse.Status__c != oldMap.get(pse.Id).Status__c)){
                    if(pse.Status__c == PSEService.PSE_STATUS_ENROLLED){
                        pseStatusHistories.add(new PSE_Status_History__c(
                                PSE__c = pse.Id,
                                Status__c = pse.Status__c,
                                Changed_Date__c = Datetime.now()
                        ));
                    }
                }
            }
            if(pseStatusHistories.size() > 0) insert pseStatusHistories;
        }
    }

}