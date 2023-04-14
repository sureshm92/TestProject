public without sharing class ppStatusDescConfigController {

    @AuraEnabled
    public static List<Study_status_description_motivation__c> fetchStatusConfig(Id recId){
        try {
            Clinical_Trial_Profile__c ctp = [select Id,CommunityTemplate__c,Status_Milestone_Available__c from Clinical_Trial_Profile__c where Id=:recId];
            if(ctp.CommunityTemplate__c != 'PatientPortal' || (ctp.CommunityTemplate__c == 'PatientPortal' && !ctp.Status_Milestone_Available__c)){
                return null;
            }
            List<Study_status_description_motivation__c> studyDescConfigList = [SELECT Status_Name__c,Study__c,Status_Description__c,Status_Motivational_Message__c FROM Study_status_description_motivation__c WHERE Study__c  =:recId ];
            List<String> existingStatusList = new List<String>();

            for(Study_status_description_motivation__c stdStatus : studyDescConfigList ){

                existingStatusList.add(stdStatus.Status_Name__c);
             }
             List<Study_status_description_motivation__c> studyDescConfigListToInsert = new List<Study_status_description_motivation__c>();

             for(Study_status_desc_and_motivational_msg__mdt studyMdt : [SELECT PER_Participant_Status__c,Status_order__c 
                                                from Study_status_desc_and_motivational_msg__mdt Order by Status_order__c asc]){
                                                    if(!existingStatusList.contains(studyMdt.PER_Participant_Status__c)){
                                                        Study_status_description_motivation__c studyDescConfig = new Study_status_description_motivation__c();
                                                        studyDescConfig.Study__c = recId;
                                                        studyDescConfig.Status_Name__c =studyMdt.PER_Participant_Status__c ;
                                                        
                                                        studyDescConfigListToInsert.add(studyDescConfig);
                                                    }

             }
             if(studyDescConfigListToInsert.size() >0){
                insert studyDescConfigListToInsert;
                studyDescConfigList.addAll(studyDescConfigListToInsert);
             }             

            return studyDescConfigList;
        } catch (Exception ex) {
            return null;
        }

        
    }

    @AuraEnabled
    public static boolean updateStatusConfig(List<Study_status_description_motivation__c> recs){
        try{
            update recs;
            return true;
        }
        catch (Exception ex) {
            return false;
        }
    }
}