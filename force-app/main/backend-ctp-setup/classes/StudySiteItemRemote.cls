public  without sharing class StudySiteItemRemote {
    @AuraEnabled
    public static Integer totalPEs(Id ssId, Id ctpId){
        Integer count = 0;
        if(ssId!=null && ctpId!=null){
            List<AggregateResult> totalParticipants = new List<AggregateResult>();
            
            totalParticipants = [SELECT count(Id) FROM Participant_Enrollment__c 
                                 WHERE Study_Site__c =:ssId AND Clinical_Trial_Profile__c=:ctpId 
                                 AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_POST_ENROLLMENT_VISIT_RELATED 
                                 AND Visit_Plan__c =null];
            if(totalParticipants.size()>0){
                count = Integer.valueOf(totalParticipants[0].get('expr0'));
            }
        }
        return count;
    }
    
    @AuraEnabled
    public static Boolean getLatestBatchStatusForStudySite(Id ssIdWithoutChangetoVisitPlan){
        Boolean isPresent = false;
        List<Study_Site__c> ss = [SELECT Id FROM Study_Site__c WHERE Is_Patient_Visit_Batch_Running__c = true AND Id =:ssIdWithoutChangetoVisitPlan];
        if(!ss.isEmpty()){
            isPresent = true;
        }
        return isPresent;
    }
}