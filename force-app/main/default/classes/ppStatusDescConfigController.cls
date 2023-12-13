public without sharing class ppStatusDescConfigController {
    
    @AuraEnabled
    public static List<List<Study_status_description_motivation__c>> fetchStatusConfig(Id recId){
        try {
            Clinical_Trial_Profile__c ctp = [select Id,PPTemplate__c,Is_Program__c,Participant_Workflow_Final_Step__c,Initial_Visit_Required__c,CommunityTemplate__c,Status_Milestone_Available__c,Visit_Schedule_Is_Available__c,Pre_Trial_Status_Config__c from Clinical_Trial_Profile__c where Id=:recId];
            if((ctp.CommunityTemplate__c != 'PatientPortal' || (ctp.CommunityTemplate__c == 'PatientPortal' && !ctp.Status_Milestone_Available__c))
                && (ctp.PPTemplate__c != 'PP 2.0' || ((ctp.CommunityTemplate__c != 'Janssen' || (ctp.CommunityTemplate__c == 'Janssen' && !ctp.Status_Milestone_Available__c))))){
                return null;
            }
            List<Study_status_description_motivation__c> studyDescConfigList = [SELECT Status_Name__c,Status_Label__c,Study__c,Status_Description__c,Status_Motivational_Message__c,Status_Developer_Name__c FROM Study_status_description_motivation__c WHERE Study__c  =:recId ];
            List<Study_status_desc_and_motivational_msg__mdt> configurationMetadata = [SELECT Label,PER_Participant_Status__c,Status_order__c,DeveloperName from Study_status_desc_and_motivational_msg__mdt   Order by Status_order__c asc];
            List<String> existingStatusList = new List<String>();
            Map<String,Study_status_description_motivation__c> statusConfiguration = new Map<String,Study_status_description_motivation__c>();
            List<Study_status_description_motivation__c> statusTitleConfiguration = new List<Study_status_description_motivation__c> ();
            List<List<Study_status_description_motivation__c>> configurations = new List<List<Study_status_description_motivation__c>>{new List<Study_status_description_motivation__c>(), new List<Study_status_description_motivation__c>(), new List<Study_status_description_motivation__c>()};
                for(Study_status_description_motivation__c stdStatus : studyDescConfigList ){
                    if(String.isEmpty(stdStatus.Status_Developer_Name__c)){
                        existingStatusList.add(stdStatus.Status_Name__c);
                    } else {
                        existingStatusList.add(stdStatus.Status_Developer_Name__c);
                    }
                }
            List<Study_status_description_motivation__c> studyDescConfigListToInsert = new List<Study_status_description_motivation__c>();
            
            for( Study_status_desc_and_motivational_msg__mdt studyMdt : configurationMetadata ){
                if(!existingStatusList.contains(studyMdt.DeveloperName)){
                    Study_status_description_motivation__c studyDescConfig = new Study_status_description_motivation__c();
                    studyDescConfig.Study__c = recId;
                    studyDescConfig.Status_Name__c =studyMdt.PER_Participant_Status__c ;
                    studyDescConfig.Status_Developer_Name__c =studyMdt.DeveloperName ;
                    studyDescConfig.Status_Label__c =studyMdt.Label ;
                    studyDescConfigListToInsert.add(studyDescConfig);
                }
                
            }
            if( studyDescConfigListToInsert.size() >0 ){
                insert studyDescConfigListToInsert;
                studyDescConfigList.addAll(studyDescConfigListToInsert);
            }      
            
            for( Study_status_description_motivation__c stdStatus : studyDescConfigList ){
                
                if(String.isEmpty(stdStatus.Status_Developer_Name__c)){
                    statusConfiguration.put(stdStatus.Status_Name__c,stdStatus);
                } else {
                    statusConfiguration.put(stdStatus.Status_Developer_Name__c,stdStatus);
                }
            }
            
            if(ctp.Initial_Visit_Required__c){
                statusConfiguration.remove('Eligibility');
                statusConfiguration.remove('Eligibility1');
            }else{
                statusConfiguration.remove('Initial_Visit');
                statusConfiguration.remove('Initial_Visit1');
            }
            
            if(ctp.Participant_Workflow_Final_Step__c=='Enrollment'){
                statusConfiguration.remove('Randomization1');
            }else{
                statusConfiguration.remove('Enrollment1');
            }
            
            for( Study_status_desc_and_motivational_msg__mdt studyMdt : configurationMetadata ){
                system.debug('Inside qery');
                                 
                if(statusConfiguration.containsKey(studyMdt.DeveloperName)){
                        if( studyMdt.Status_order__c>=1 && studyMdt.Status_order__c<2){
                            configurations[0].add(statusConfiguration.get(studyMdt.DeveloperName));
                        }
                } 
                
                if( studyMdt.Status_order__c>=2 && studyMdt.Status_order__c<3){  
                    configurations[1].add(statusConfiguration.get(studyMdt.DeveloperName));
                }
                if( studyMdt.Status_order__c>=3 && studyMdt.Status_order__c<4 ){
                    configurations[2].add(statusConfiguration.get(studyMdt.DeveloperName));
                }
            }
        
        
        //return studyDescConfigList;
        return configurations;
    } catch (Exception ex) {
        system.debug(ex.getMessage());
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