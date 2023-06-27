public  without sharing class StudySiteItemRemote {
    @AuraEnabled
    public static CountAndProgram totalPEs(Id ssId, Id ctpId){
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
        Boolean isProgram = false;
        if(ctpId!=null){
            List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,Is_Program__c FROM Clinical_Trial_Profile__c WHERE id=:ctpId];
            if(ctpList.size()>0){
                isProgram =  ctpList[0].Is_Program__c;
            }
        }
        CountAndProgram cnl = new CountAndProgram();
        cnl.count = count;
        cnl.isProgram = isProgram;
        return cnl;
    }
    @TestVisible
    class CountAndProgram {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public Boolean isProgram;
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