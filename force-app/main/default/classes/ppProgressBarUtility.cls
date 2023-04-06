public without sharing class ppProgressBarUtility {
    public class parentWrapper{
        @AuraEnabled
        public list<progressWrapper> progressWrapperList;   
        @AuraEnabled
        public String message; 
        @AuraEnabled
        public String messageDesc;
        @AuraEnabled
        public String journeyLink;     
        @AuraEnabled
        public Integer currentStatusVal;
        @AuraEnabled
        public Boolean isEvent;  
    }
    
    public class progressWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String description;   
        @AuraEnabled
        public Integer stepVal;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Datetime statusDate; 
        @AuraEnabled
        public String recordId;   
    }
    @AuraEnabled
    public static parentWrapper generateProgressBar(String peId){
        parentWrapper pw = new parentWrapper();
        Participant_Enrollment__c pe = [select id,Participant_Status__c,Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,Clinical_Trial_Profile__r.Is_Program__c,
                Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c,Clinical_Trial_Profile__r.Status_Milestone_Available__c,Clinical_Trial_Profile__c,
                (select id,Status__c, Date__c FROM Participant_Enrollment_Status_History__r order by Date__c asc) 
                FROM Participant_Enrollment__c where id=:peId];
        if([select count() FROM Study_status_desc_and_motivational_msg__mdt where PER_Participant_Status__c =:pe.Participant_Status__c]==0){
            return null;
        }
        Boolean isProgram = pe.Clinical_Trial_Profile__r.Is_Program__c;

        if(isProgram && pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c){
            pw =generateVisitData(peId,pw, isProgram,true,pe);
        }
        else if((!isProgram) && pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c && pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c){
            //left status/milestone and right is visit
            pw =generateVisitData(peId, pw, isProgram,false,pe);
        }
        else if((!isProgram) && pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c && (!pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c)){
            pw =generateVisitData(peId,pw, isProgram,true,pe);
        }
        else if((!isProgram) && pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c && (!pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c)){
            pw = generateStatusBar(pe);
        }
        else{
            return null;
        }
        return pw;
    }
        
    @AuraEnabled
    public static parentWrapper generateData(){
        parentWrapper pw = new parentWrapper();
        pw.progressWrapperList = new list<progressWrapper>(); 
        integer currentSt = 13; //use mods to get this math.mod(7,5) or =5 if greater then 5; might not be used
        Integer count = 1; 
        Integer multiplier = -1;
        for(integer i = 1; i<=20 ; i++){
            progressWrapper prW = new progressWrapper();
            prW.title = i+': Title of treatment period';
            prW.description = 'Brief description of what occurs and what is expected during treatment period. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut enim ad minim veniam. Ut enim ad minim veniam. Charcters: 200';
            if(i == currentSt){
                multiplier = 1;
                count = 0;
            }
            prW.stepVal = count*multiplier;
            count++;
            
            pw.progressWrapperList.add(prW);
        }
        pw.message = 'This message of treatment period. Lorem Ipsum has been the industrys standard dummy. Characters: 100';
        pw.journeyLink = 'test';
        pw.currentStatusVal = currentSt;
        return pw;
    }

    public static parentWrapper generateVisitData(String peId, parentWrapper pw, Boolean isProgram, Boolean setMotivationMsg, Participant_Enrollment__c pe){
        List<Patient_Visit__c> patientVisits = [select Id,Visit__r.Visit_Description__c, Visit__r.Motivational_Message__c,Visit__r.Patient_Portal_Name__c ,Completed_Date__c,Status__c 
                    from Patient_Visit__c where Participant_Enrollment__c =:peId  order by Visit_Number__c ,Visit__r.Visit_Number__c]; 
        
        pw.isEvent = isProgram;
        Integer count = 1; 
        Integer multiplier = -1;
        if(!patientVisits.isEmpty()){
            pw.progressWrapperList = new list<progressWrapper>(); 
            Boolean upComingVisit = false;
            for( Integer i=0; i<patientVisits.size(); i++){
                Patient_Visit__c patientVisit = patientVisits[i];
                progressWrapper prW = new progressWrapper();
                prW.title = patientVisit.Visit__r.Patient_Portal_Name__c;
                prW.description = patientVisit.Visit__r.Visit_Description__c;      
                prW.status = (patientVisit.Status__c == 'Missed' ? 'UNAVAILABLE' : (patientVisit.Status__c == 'Completed' ? 'COMPLETED' : 'FUTURE'));
                prW.statusDate = patientVisit.Completed_Date__c;
                if(((patientVisit.Status__c != 'Completed' && patientVisit.Status__c != 'Missed' ) || (patientVisits.size()-1 == i))
                 && (!upComingVisit)){
                    upComingVisit = true;
                    pw.currentStatusVal = count;                    
                    pw.message = ( setMotivationMsg ? patientVisit.Visit__r.Motivational_message__c : pw.message);
                    multiplier = 1;
                    count = 0;
                    prW.status = (patientVisit.Completed_Date__c == null && patientVisit.Status__c != 'Completed' && patientVisit.Status__c != 'Missed' ? 'UPCOMING' : prW.status );
                }
                if(pw.isEvent){
                    prW.recordId = patientVisit.Id;
                }
                prW.stepVal = count*multiplier;
                
                count++;                
                pw.progressWrapperList.add(prW);
            }
        }
        if(patientVisits.isEmpty() && setMotivationMsg){
            pw = null;
        }
        if(!setMotivationMsg){
            for(Study_status_desc_and_motivational_msg__mdt statusConfig : [select id,MasterLabel,Status_order__c,PER_Participant_Status__c FROM Study_status_desc_and_motivational_msg__mdt where PER_Participant_Status__c =:pe.Participant_Status__c]){
                pw.message =statusConfig.MasterLabel;
            } 
            for(Study_status_description_motivation__c studyDescConfig : [SELECT Status_Description__c FROM Study_status_description_motivation__c WHERE Study__c  =: pe.Clinical_Trial_Profile__c and Status_Name__c =:pe.Participant_Status__c]){
                pw.messageDesc = studyDescConfig.Status_Description__c;
            }
        }
        return pw;
    }

    public static parentWrapper generateStatusBar(Participant_Enrollment__c pe ){
        Map<string,Study_status_description_motivation__c> statusConfigMap = new Map<string,Study_status_description_motivation__c>();
        integer configCount = 0;
        for(Study_status_description_motivation__c studyDescConfig : [SELECT Status_Name__c,Study__c,Status_Description__c,Status_Motivational_Message__c FROM Study_status_description_motivation__c WHERE Study__c  =: pe.Clinical_Trial_Profile__c]){
            statusConfigMap.put(studyDescConfig.Status_Name__c,studyDescConfig);
            configCount++;
        }
        if(configCount==0){
            return null;
        }
        parentWrapper pw = new parentWrapper();
        pw.progressWrapperList = new list<progressWrapper>(); 
        Integer count = 1; 
        Integer multiplier = -1;
        Map<String,Datetime> peshDateMap = new Map<String,Datetime>();
        for(Participant_Enrollment_Status_History__c pesh : pe.Participant_Enrollment_Status_History__r){
            peshDateMap.put(pesh.Status__c,pesh.Date__c);
        }
        for(Study_status_desc_and_motivational_msg__mdt statusConfig : [select id,MasterLabel,Status_order__c,PER_Participant_Status__c FROM Study_status_desc_and_motivational_msg__mdt where Status_order__c>2 order by Status_order__c  asc]){
            if((statusConfig.MasterLabel == 'Randomization' || statusConfig.MasterLabel == 'Enrollment') && pe.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c != statusConfig.MasterLabel){
                continue;
            }
            progressWrapper prW = new progressWrapper();
            prW.title = statusConfig.MasterLabel;
            if(statusConfigMap.containsKey(statusConfig.PER_Participant_Status__c))
                prW.description = statusConfigMap.get(statusConfig.PER_Participant_Status__c).Status_Description__c;
            prW.status = 'FUTURE';
            if(statusConfig.PER_Participant_Status__c == pe.Participant_Status__c){
                pw.currentStatusVal = count;                    
                if(statusConfigMap.containsKey(statusConfig.PER_Participant_Status__c))
                    pw.message = statusConfigMap.get(statusConfig.PER_Participant_Status__c).Status_Motivational_Message__c;
                multiplier = 1;
                count = 0;
                prW.status = 'IN PROGRESS';
            }
            prW.stepVal = count*multiplier;
            
            if(prW.stepVal<0){
                prW.status = 'COMPLETED';
                if(peshDateMap.containsKey(pe.Participant_Status__c)){
                    prW.statusDate = peshDateMap.get(pe.Participant_Status__c);
                }
            }
            count++;                
            pw.progressWrapperList.add(prW);
        }
        pw.journeyLink = ''; 
        return pw;
    }

    @AuraEnabled
    public static String updatePatientVisit(String patientVisitId){
        try {
            PatientVisit pv = new PatientVisit();
            return pv.updatePV(patientVisitId);
        } catch (Exception ex) {
            return 'false';
        }

        
    }

    public without sharing class PatientVisit { 
        public  String updatePV(String patientVisitId){
            try {
                Patient_Visit__c patientVisit = new Patient_Visit__c();
                patientVisit.Id = patientVisitId;
                patientVisit.Completed_Date__c = Date.today();
                patientVisit.Status__c = 'Completed';
                update patientVisit;
                return 'true';
            } catch (Exception ex) {
                return 'false';
            }
            
        }
    }    
}