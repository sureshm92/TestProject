/**
 * Created by Leonid Bartenev
 */

public class PSEStatusHistoryTriggerHandler {
    
    public static void updatePSEStatuses(){
        Set<Id> pseListIds = new Set<Id>();
        List<PSE_Status_History__c> newList = (List<PSE_Status_History__c>)Trigger.new;
        for(PSE_Status_History__c pseStatusHistory : newList){
            pseListIds.add(pseStatusHistory.PSE__c);
        }
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id, (SELECT Id, Status__c FROM PSE_Status_Histories__r ORDER BY Changed_Date__c DESC LIMIT 1)
                FROM Participant_Study_Enrollment__c
                WHERE Id IN: pseListIds
        ];
        for(Participant_Study_Enrollment__c pse : pseList){
            if(pse.PSE_Status_Histories__r.size() > 0){
                pse.Status__c = pse.PSE_Status_Histories__r[0].Status__c;
            }
        }
        update pseList;
    }

}