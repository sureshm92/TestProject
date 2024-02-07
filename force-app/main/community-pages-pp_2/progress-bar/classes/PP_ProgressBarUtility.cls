public with sharing class PP_ProgressBarUtility {
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
        @AuraEnabled
        public Boolean isPreTiral;  
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
        @AuraEnabled
            public list<statusWrapper> statusWrapperList; 
        }

    public class statusWrapper{
        @AuraEnabled
        public Datetime statusDate;
        @AuraEnabled
        public String statusName;
    }

    @AuraEnabled
    public static parentWrapper generateProgressBar(String peId){
        parentWrapper pw = new parentWrapper();
        try{
            Set<String> InTrialStatus = new Set<String>{'Enrollment Success','Randomization Success','Treatment Period Started','Follow-Up Period Started','Participation Complete','Trial Complete'};
            Set<String> PreTrialStatus = new Set<String>{'Received','Pre-review Passed','Contact Attempted','Successfully re-engaged','Successfully Contacted','Participant No Show','Eligibility Passed','Ready to Screen','Screening In Progress - Wash Out Period','Screening In Progress','Screening Passed'};
            Participant_Enrollment__c pe = [select id,Participant_Status__c,Initial_Visit_Scheduled_DateTime__c,Initial_visit_scheduled_flag__c,Initial_visit_occurred_flag__c,Informed_Consent__c,Initial_visit_scheduled_date__c,Informed_Consent_Date__c,Initial_visit_occurred_date__c,Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,Clinical_Trial_Profile__r.Is_Program__c,
                    Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c,Clinical_Trial_Profile__r.Initial_Visit_Required__c,Clinical_Trial_Profile__r.Status_Milestone_Available__c,Clinical_Trial_Profile__r.Study_External_URL__c,Clinical_Trial_Profile__c,
                    (select id,Status__c, Date__c FROM Participant_Enrollment_Status_History__r order by Date__c asc) 
                    FROM Participant_Enrollment__c where id=:peId];
            if(([select count() FROM Study_status_desc_and_motivational_msg__mdt where PER_Participant_Status__c =:pe.Participant_Status__c]==0) && pe.Participant_Status__c != 'Participant No Show'){
                return null;
            }
            if(InTrialStatus.contains(pe.Participant_Status__c)){
                pw = generateBarForInTrial(pe,pw,peId);
                return pw;
            }
            else if((PreTrialStatus.contains(pe.Participant_Status__c) && pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c 
            && !pe.Clinical_Trial_Profile__r.Is_Program__c) || pe.Participant_Status__c == 'Participant No Show'){
                pw.isPreTiral = true;
                pw = generateBarForPreTrial(pe,pw,peId);
                return pw;
            }
        }catch(exception ex){
            system.debug('ex:'+ex.getStackTraceString());
        }
        return null;
    }
        
    public static parentWrapper generateBarForInTrial(Participant_Enrollment__c pe, parentWrapper pw,String peId){
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
        pw.journeyLink = pe.Clinical_Trial_Profile__r.Study_External_URL__c;
        return pw;
    }
        
    public static parentWrapper generateVisitData(String peId, parentWrapper pw, Boolean isProgram, Boolean setMotivationMsg, Participant_Enrollment__c pe){
        List<Patient_Visit__c> patientVisits = [select Id,Visit__c,Visit__r.Visit_Description__c,Is_Adhoc__c, Visit__r.Motivational_Message__c,Visit__r.Patient_Portal_Name__c ,Completed_Date__c,Status__c 
                    from Patient_Visit__c where Participant_Enrollment__c =:peId  order by Visit_Number__c ,Visit__r.Visit_Number__c]; 
        
        pw.isEvent = isProgram;
        Integer count = 1; 
        Integer multiplier = -1;
        if(!patientVisits.isEmpty()){
            pw.progressWrapperList = new list<progressWrapper>(); 
            Boolean upComingVisit = false;
            TranslateHelper.translate(patientVisits);
            for( Integer i=0; i<patientVisits.size(); i++){
                Patient_Visit__c patientVisit = patientVisits[i];
                progressWrapper prW = new progressWrapper();
                prW.title = ( patientVisit.Visit__c != null ? patientVisit.Visit__r.Patient_Portal_Name__c : (patientVisit.Is_Adhoc__c ? System.Label.StudyVisit_Unscheduled_Visit : ''));  
                prW.description = ( patientVisit.Visit__c != null ? patientVisit.Visit__r.Visit_Description__c : (patientVisit.Is_Adhoc__c ? System.Label.PP_ProgressBar_No_Visit_Adhoc : ''));      
                prW.status = (patientVisit.Status__c == 'Missed' ? System.Label.UNAVAILABLE : (patientVisit.Status__c == 'Completed' ? System.Label.COMPLETED : System.Label.FUTURE));
                prW.statusDate = patientVisit.Completed_Date__c;
                if(((patientVisit.Status__c != 'Completed' && patientVisit.Status__c != 'Missed' ) || (patientVisits.size()-1 == i))
                 && (!upComingVisit)){
                    upComingVisit = true;
                    pw.currentStatusVal = count;                    
                    pw.message = ( setMotivationMsg ? patientVisit.Visit__r.Motivational_message__c : pw.message);
                    multiplier = 1;
                    count = 0;
                    prW.status = (patientVisit.Completed_Date__c == null && patientVisit.Status__c != 'Completed' && patientVisit.Status__c != 'Missed' ? System.Label.PP_Upcoming_Caps : prW.status );
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
          for(Study_status_desc_and_motivational_msg__mdt statusConfig : [select id,Master_Custom__c,MasterLabel,Status_order__c,PER_Participant_Status__c,PER_Participant_Label__c FROM Study_status_desc_and_motivational_msg__mdt where PER_Participant_Status__c =:pe.Participant_Status__c]){
                pw.message =statusConfig.Master_Custom__c;
            } 
            List<Study_status_description_motivation__c> studyDescConfigs =  [SELECT Status_Description__c FROM Study_status_description_motivation__c WHERE Study__c  =: pe.Clinical_Trial_Profile__c and Status_Name__c =:pe.Participant_Status__c];
            Translatehelper.translate(studyDescConfigs);
            for(Study_status_description_motivation__c studyDescConfig : studyDescConfigs){
                pw.messageDesc = studyDescConfig.Status_Description__c;
            }
        }
        return pw;
    }

    public static parentWrapper generateStatusBar(Participant_Enrollment__c pe ){
        Map<string,Study_status_description_motivation__c> statusConfigMap = new Map<string,Study_status_description_motivation__c>();
        integer configCount = 0;
        List<Study_status_description_motivation__c> studyDescConfigees = [SELECT Status_Name__c,Study__c,Status_Description__c,Status_Motivational_Message__c FROM Study_status_description_motivation__c WHERE Study__c  =: pe.Clinical_Trial_Profile__c];
        Translatehelper.translate(studyDescConfigees);
        for(Study_status_description_motivation__c studyDescConfig : studyDescConfigees){
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
        for(Study_status_desc_and_motivational_msg__mdt statusConfig : [select id,Master_Custom__c,MasterLabel,Status_order__c,PER_Participant_Status__c,PER_Participant_Label__c FROM Study_status_desc_and_motivational_msg__mdt where Status_order__c>2 and Status_order__c<3 order by Status_order__c  asc]){
            if((statusConfig.MasterLabel == 'Randomization' || statusConfig.MasterLabel == 'Enrollment') && pe.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c != statusConfig.MasterLabel){
                continue;
            }
            progressWrapper prW = new progressWrapper();
            prW.title = statusConfig.Master_Custom__c;
            if(statusConfigMap.containsKey(statusConfig.PER_Participant_Status__c))
                prW.description = statusConfigMap.get(statusConfig.PER_Participant_Status__c).Status_Description__c;
            prW.status = System.Label.FUTURE;
            if(statusConfig.PER_Participant_Status__c == pe.Participant_Status__c){
                pw.currentStatusVal = count;                    
                if(statusConfigMap.containsKey(statusConfig.PER_Participant_Status__c))
                    pw.message = statusConfigMap.get(statusConfig.PER_Participant_Status__c).Status_Motivational_Message__c;
                multiplier = 1;
                count = 0;
                prW.status = System.Label.INPROGRESS;
            }
            prW.stepVal = count*multiplier;
            
            if(prW.stepVal<0){
                prW.status = System.Label.COMPLETED;
                if(peshDateMap.containsKey(pe.Participant_Status__c)){
                    prW.statusDate = peshDateMap.get(pe.Participant_Status__c);
                }
            }
            count++;                
            pw.progressWrapperList.add(prW);
        }
        return pw;
    }

    public static parentWrapper generateBarForPreTrial(Participant_Enrollment__c pe, parentWrapper pw,String peId){
        try{
            Boolean isProgram = pe.Clinical_Trial_Profile__r.Is_Program__c;
            Map<String,List<Study_status_desc_and_motivational_msg__mdt>> milestonseStatusMapping = new Map<String,List<Study_status_desc_and_motivational_msg__mdt>>();
            if(pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c){
                Map<string,Study_status_description_motivation__c> statusConfigMap = new Map<string,Study_status_description_motivation__c>();
                integer configCount = 0;
                List<Study_status_description_motivation__c> studyDescConfiges = [SELECT Status_Name__c,Study__c,Status_Description__c,Status_Motivational_Message__c,Status_Developer_Name__c   FROM Study_status_description_motivation__c WHERE Study__c  =: pe.Clinical_Trial_Profile__c];
                Translatehelper.translate(studyDescConfiges);
                for(Study_status_description_motivation__c studyDescConfig : studyDescConfiges){
                    if(studyDescConfig.Status_Developer_Name__c !=null){
                        statusConfigMap.put(studyDescConfig.Status_Developer_Name__c,studyDescConfig);
                    }else{
                        statusConfigMap.put(studyDescConfig.Status_Name__c,studyDescConfig);
                    }
                    configCount++;
                }
                if(configCount==0){
                    return null;
                }
                
                
                milestonseStatusMapping = generateMilestoneStatusMap();

                pw.progressWrapperList = new list<progressWrapper>(); 
                Integer count = 1; 
                Integer multiplier = -1;
                Map<String,Datetime> peshDateMap = new Map<String,Datetime>();
                for(Participant_Enrollment_Status_History__c pesh : pe.Participant_Enrollment_Status_History__r){
                    system.debug(pesh.Status__c +''+pesh.Date__c);
                    peshDateMap.put(pesh.Status__c.toLowerCase(),pesh.Date__c);
               }
               for( String statName : peshDateMap.KeySet()){
            
                system.debug(statName+ ' result ' +peshDateMap.get(statName));
           }
               
               if(pe.Participant_Status__c == 'Participant No Show' && !peshDateMap.containsKey('Successfully Contacted'.toLowerCase())){
                return null;
               }
                if(pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c && pe.Participant_Status__c ==  'Successfully Contacted' && peshDateMap.containsKey('Successfully Contacted'.toLowerCase())){
                    if(pe.Informed_Consent_Date__c != null || pe.Initial_visit_occurred_date__c!=null || pe.Initial_visit_scheduled_flag__c){
                        pe.Participant_Status__c = 'Initial Visit';
                    }
                }
              for(Study_status_desc_and_motivational_msg__mdt milestoneConfig : [select id,Master_Custom__c,MasterLabel,Status_order__c,PER_Participant_Label__c,PER_Participant_Status__c,DeveloperName   FROM Study_status_desc_and_motivational_msg__mdt where Status_order__c>3 and Status_order__c<4 order by Status_order__c  asc]){
                    if((milestoneConfig.MasterLabel == 'Randomization' || milestoneConfig.MasterLabel == 'Enrollment') && pe.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c != milestoneConfig.MasterLabel){
                        continue;
                    }
                    if((pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c && milestoneConfig.MasterLabel == 'Eligibility') || 
                    (!pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c && milestoneConfig.MasterLabel == 'Initial Visit')){
                        continue;
                    }
                    progressWrapper prW = new progressWrapper();
                    prW.title = (statusConfigMap.containsKey(milestoneConfig.DeveloperName) && statusConfigMap.get(milestoneConfig.DeveloperName).Status_Description__c!=null) ?  statusConfigMap.get(milestoneConfig.DeveloperName).Status_Description__c : milestoneConfig.PER_Participant_Label__c;
                    prW.description = statusConfigMap.get(milestoneConfig.DeveloperName).Status_Motivational_Message__c;
                    prW.statusWrapperList = null;
                    prW.status = System.Label.FUTURE;

                    //internim status
                    List<Study_status_desc_and_motivational_msg__mdt> statusLst = milestonseStatusMapping.get(milestoneConfig.PER_Participant_Status__c);
                    List<statusWrapper> sWrpList = new List<statusWrapper>();
                    if(multiplier < 0 ){
                        Map<DateTime, statusWrapper> statusMap = new Map<DateTime, statusWrapper>();
                        List<DateTime> statusDateList = new List<DateTime>();
                        for(Study_status_desc_and_motivational_msg__mdt statusConfig : statusLst){
                            if(peshDateMap.containsKey(statusConfig.PER_Participant_Status__c.toLowerCase())){
                                statusWrapper sWrp = new statusWrapper();
                                sWrp.statusDate = peshDateMap.get(statusConfig.PER_Participant_Status__c.toLowerCase());
                                sWrp.statusName = statusConfig.Master_Custom__c;
                                //sWrpList.add(sWrp);
                                statusMap.put(sWrp.statusDate, sWrp);
                                statusDateList.add(sWrp.statusDate);
                            }
                            if(multiplier < 0 ){
                                prW.title = (statusConfigMap.containsKey(statusConfig.DeveloperName) && statusConfigMap.get(statusConfig.DeveloperName).Status_Description__c!=null) ? statusConfigMap.get(statusConfig.DeveloperName).Status_Description__c : statusConfig.PER_Participant_Label__c;
                                prW.description = (statusConfigMap.containsKey(statusConfig.DeveloperName) ? statusConfigMap.get(statusConfig.DeveloperName).Status_Motivational_Message__c : '');  
                            }
                            if((statusConfig.PER_Participant_Status__c == pe.Participant_Status__c) 
                            || (pe.Participant_Status__c == 'Participant No Show' && statusConfig.PER_Participant_Status__c == 'Successfully Contacted')){
                                pw.currentStatusVal = count;                    
                                multiplier = 1;
                                count = 0;
                                prW.status = System.Label.INPROGRESS; 
                            }
                            
                        }
                        statusDateList.sort();
                        for(Datetime statusDate : statusDateList){
                            if(statusMap.containsKey(statusDate)){
                                sWrpList.add(statusMap.get(statusDate));
                            }
                            
                        }

                        if((pe.Participant_Status__c == 'Initial Visit' 
                        && peshDateMap.containsKey('Successfully Contacted'.toLowerCase())
                        && milestoneConfig.PER_Participant_Status__c == 'Initial Visit') ||
                        (peshDateMap.containsKey('Successfully Contacted'.toLowerCase())
                        && milestoneConfig.PER_Participant_Status__c == 'Initial Visit')
                        ){
                            if(pe.Initial_visit_scheduled_flag__c){
                                statusWrapper sWrp = new statusWrapper();
                                sWrp.statusName = System.Label.PP_Scheduled;
                                sWrp.statusDate = pe.Initial_visit_scheduled_date__c;
                                sWrpList.add(sWrp);
                            }
                            if(pe.Initial_visit_occurred_flag__c){
                                statusWrapper sWrp = new statusWrapper();
                                sWrp.statusName = System.Label.PG_Or_R_Attended;
                                sWrp.statusDate = pe.Initial_visit_occurred_date__c;
                                sWrpList.add(sWrp);
                            }
                            if(pe.Informed_Consent__c){
                                statusWrapper sWrp = new statusWrapper();
                                sWrp.statusName = System.Label.Consented;
                                sWrp.statusDate = pe.Informed_Consent_Date__c;
                                sWrpList.add(sWrp);
                            }
                        }
                        //sWrpList.sort();
                        prW.statusWrapperList = sWrpList;
                    }
                    prW.stepVal = count*multiplier;
                    
                    if(prW.stepVal<0){
                        prW.status = System.Label.COMPLETED; 
                        if(peshDateMap.containsKey(pe.Participant_Status__c.toLowerCase())){
                            prW.statusDate = peshDateMap.get(pe.Participant_Status__c.toLowerCase());
                        }
                    }
                    count++;    
                    pw.progressWrapperList.add(prW);
                }
            }
            else{
                return null;
            }
        }catch(exception ex){
            system.debug('ex:'+ex.getStackTraceString());
        }
        pw.journeyLink = pe.Clinical_Trial_Profile__r.Study_External_URL__c;
        return pw;
    
    }

    public static Map<String,List<Study_status_desc_and_motivational_msg__mdt>>  generateMilestoneStatusMap(){
        Map<String,List<Study_status_desc_and_motivational_msg__mdt>> milestonseStatusMapping = new Map<String,List<Study_status_desc_and_motivational_msg__mdt>>();
       
        try{
         for(Study_status_desc_and_motivational_msg__mdt statusConfig : [select id,Master_Custom__c,MasterLabel,PER_Participant_Label__c,Status_order__c,PER_Participant_Status__c,DeveloperName FROM Study_status_desc_and_motivational_msg__mdt where Status_order__c>=1 and Status_order__c<2 order by Status_order__c  asc]){
            if(statusConfig.DeveloperName == 'Received1'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = (milestonseStatusMapping.containsKey('Recieved') ? milestonseStatusMapping.get('Recieved') : new List<Study_status_desc_and_motivational_msg__mdt>());
                statusList.add(statusConfig);
                milestonseStatusMapping.put('Received',statusList);
            }
            if(statusConfig.DeveloperName == 'Pre_review_Passed' || statusConfig.DeveloperName =='Contact_Attempted' || 
            statusConfig.DeveloperName == 'Successfully_Re_engaged' || 
            statusConfig.DeveloperName == 'Successfully_Contacted'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = (milestonseStatusMapping.containsKey('Contact Attempt') ? milestonseStatusMapping.get('Contact Attempt') : new List<Study_status_desc_and_motivational_msg__mdt>());
                statusList.add(statusConfig);
                milestonseStatusMapping.put('Contact Attempt',statusList);
            }
            if(statusConfig.DeveloperName == 'Eligibility'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = (milestonseStatusMapping.containsKey('Eligibility') ? milestonseStatusMapping.get('Eligibility') : new List<Study_status_desc_and_motivational_msg__mdt>());
                statusList.add(statusConfig);
                milestonseStatusMapping.put('Eligibility',statusList);
            }
            if(statusConfig.DeveloperName == 'Initial_Visit'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = (milestonseStatusMapping.containsKey('Initial Visit') ? milestonseStatusMapping.get('Initial Visit') : new List<Study_status_desc_and_motivational_msg__mdt>());
                statusList.add(statusConfig);
                milestonseStatusMapping.put('Initial Visit',statusList);
            }
            if(statusConfig.DeveloperName == 'In_Wash_Out_Period' ||
            statusConfig.DeveloperName == 'Screening_In_Progress' ||
            statusConfig.DeveloperName == 'Ready_to_Screen' ||
            statusConfig.DeveloperName == 'Screening_Passed'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = (milestonseStatusMapping.containsKey('Screening') ? milestonseStatusMapping.get('Screening') : new List<Study_status_desc_and_motivational_msg__mdt>());
                statusList.add(statusConfig);
                milestonseStatusMapping.put('Screening',statusList);
            }
            if(statusConfig.DeveloperName == 'Enrollment1'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = new List<Study_status_desc_and_motivational_msg__mdt>();
              
                milestonseStatusMapping.put('Enrollment',statusList);
            }
            if(statusConfig.DeveloperName == 'Randomization1'){
                List<Study_status_desc_and_motivational_msg__mdt> statusList = new List<Study_status_desc_and_motivational_msg__mdt>();
              
                milestonseStatusMapping.put('Randomization',statusList);
            }
        }
    }catch(exception ex){
        system.debug('ex:'+ex.getStackTraceString());
    }
        return milestonseStatusMapping;
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
                patientVisit.Status__c = System.Label.COMPLETED;
                update patientVisit;
                return 'true';
            } catch (Exception ex) {
                return 'false';
            }
            
        }
    }    
    @AuraEnabled
    public static boolean showProgress(String peId){
        Participant_Enrollment__c pe = [select id,Participant_Status__c,Clinical_Trial_Profile__r.Is_Program__c,Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c,
                                        Clinical_Trial_Profile__r.Status_Milestone_Available__c FROM Participant_Enrollment__c where id=:peId];
        List<Study_status_desc_and_motivational_msg__mdt> metadtaRec = [select id FROM Study_status_desc_and_motivational_msg__mdt where PER_Participant_Status__c =:pe.Participant_Status__c];
        List<Participant_Enrollment_Status_History__c> pesh = [select Id from Participant_Enrollment_Status_History__c where status__c = 'Successfully Contacted' and  ParticipantEnrollment__c=:pe.Id limit 1];
        if(pe.Participant_Status__c == 'Participant No Show' && pesh!=null && pesh.size()>0){
            return true;
        }

        if(metadtaRec.isEmpty()){
            return false;
        }
        else{
            List<Patient_Visit__c> patientVisits = [select Id from Patient_Visit__c where Participant_Enrollment__c =:peId]; 
            Boolean isProgram = pe.Clinical_Trial_Profile__r.Is_Program__c;
            if((!isProgram) && pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c && pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c){
                if(patientVisits.isEmpty() && metadtaRec.isEmpty()){
                return false;
                }
            }
            else if(patientVisits.isEmpty()){
                return false;
            }
        } 
        if(!pe.Clinical_Trial_Profile__r.Visit_Schedule_Is_Available__c && !pe.Clinical_Trial_Profile__r.Status_Milestone_Available__c){
            return false;
        }
                    
        return true;
    } 
}