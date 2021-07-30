public without sharing class ListViewParticipantController {
    public static final List<String> EXCLUDED_STATUSES_COMMON = new List<String>{
        ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
        ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
        ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
    };
    public static final List<String> EXCLUDED_STATUSES_PI = new List<String>{
        ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
        ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
        ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING,
        ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL
    };
    public static final List<String> EXCLUDED_REASONS = new List<String>{
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED,
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING,
        ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED
    };

    @AuraEnabled
    public static String getInitData(
        Id trialId,
        Id siteId,
        String userMode,
        String delegateId,
        String sponsorName
    ) {
        try {
            InitData initData = new InitData();
            String additionalFilter = getAdditionalFilter(userMode, false, null, sponsorName);
            initData.paginationData = new PaginationData();
            initData.peFilterData = createPEFilterData(
                userMode == 'PI' ? 'Active' : null,
                trialId,
                siteId,
                userMode,
                true,
                delegateId,
                additionalFilter,
                initData.paginationData,
                sponsorName
            );
            initData.peFilter = new ListViewParticipantService.PEFilter(initData.peFilterData);

            initData.peFilter.studySite = siteId;
            initData.peFilter.study = trialId;
            initData.peFilter.activePE = userMode == 'PI' ? 'Active' : null;

            Id ctpId;
            if (!initData.peFilterData.trialIds.isEmpty())
                ctpId = initData.peFilterData.trialIds[0];
            List<Study_Site__c> studySites = getStudySites(ctpId);
            Boolean showEligibilityPassedFilter = (studySites !=null && !studySites.isEmpty())?
                studySites[0].Clinical_Trial_Profile__r.Promote_to_SH__c==false:false;
            if(initData.peFilter.activePE == 'Active'){
                if(showEligibilityPassedFilter){
                    initData.peFilterData.statuses.add(new LabelValueItem(label.Eligibility_Passed, 'Eligibility Passed'));
                }else{
                    initData.peFilterData.statuses.add(new LabelValueItem(label.Sent_to_Study_Hub, 'Sent to Study Hub'));
                }
            }
            initData.peFilterData.studySites = new List<LabelValueItem>();
            initData.peFilterData.studySites.add(
                new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
            );
            for (Study_Site__c ss : studySites)
                initData.peFilterData.studySites.add(new LabelValueItem(ss.Name, ss.Id));

            initData.peFilter.additionalFilter = additionalFilter;
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<Study_Site__c> getStudySites(Id ctpId) {
        String piId = CommunityService.getUserContact().Id;

        return [
            SELECT
                Id,
                Name,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c,
                Clinical_Trial_Profile__r.Initial_Visit_Required__c,
                Principal_Investigator__c,
                Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE
                Clinical_Trial_Profile__c = :ctpId
                AND Override_PI_Referral_Status__c != NULL
                AND (Principal_Investigator__c = :piId
                OR ID IN :DelegateService.getDelegatedStudySiteIds())
        ];
    }

    @AuraEnabled
    public static WrapStudySiteList getSSList(String studyId, String activePE) {
        Id stdId = Id.valueOf(studyId);
        Boolean Promote = false;
        Boolean isInitVisitReqd = false;
        List<Study_Site__c> studySites = getStudySites(stdId);
        WrapStudySiteList SSlist = new WrapStudySiteList();
        SSlist.StudySites = new List<LabelValueItem>();
        SSlist.StudySites.add(
            new LabelValueItem(Label.PG_Report_L_All_study_sites, 'All Study Sites')
        );
        for (Study_Site__c ss : studySites) {
            SSlist.StudySites.add(new LabelValueItem(ss.Name, ss.Id));
            Promote = ss.Clinical_Trial_Profile__r.Promote_to_SH__c;
            isInitVisitReqd = ss.Clinical_Trial_Profile__r.Initial_Visit_Required__c;
        }
        SSlist.isPromoteToSH = Promote;
        SSlist.isInitVisitReqd = isInitVisitReqd;
        SSlist.statusFilterData = getParticipantStatus(activePE, SSlist.isPromoteToSH, SSlist.isInitVisitReqd);
        return SSlist;
    }

    @AuraEnabled
    public static void updateParticipantData(
        List<string> peIdList,
        List<string> yesHighPriorityList,
        List<string> noHighPriorityList
    ) {
        try{
            List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : [
                SELECT Id, Participant_Status__c, High_Priority__c, Initial_visit_scheduled_date__c
                FROM Participant_Enrollment__c
                WHERE Id IN :peIdList
            ]) {
                if (yesHighPriorityList.contains(pe.id)) {
                    pe.High_Priority__c = true;
                } else if (noHighPriorityList.contains(pe.id)) {
                    pe.High_Priority__c = false;
                } else {
                    if (pe.Initial_visit_scheduled_date__c != null) {
                        pe.High_Priority__c = true;
                    } else {
                        pe.High_Priority__c = false;
                    }
                }
                pe.Participant_Status__c = 'Eligibility Passed';
                pe.Participant_Status_Last_Changed_Date__c = DateTime.now();
                PEUpdateList.add(pe);
            }
            if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
                update PEUpdateList;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    //Added for Bulk Action- Status Update
    @AuraEnabled
    public static void updateParticipantStatus(
        List<string> peIdList, 
        String StatusToUpdate,
        String Notes,
        String reason,
        String studyId,
        String oParticipantStatus,
        Boolean finalconsent){ 
            Savepoint sp = Database.setSavepoint();
            try {
                if(StatusToUpdate == 'Sent to Study Hub' || StatusToUpdate == 'Initial Visit'){
                    StatusToUpdate = 'Eligibility Passed';
                }
                if(StatusToUpdate == 'In Wash Out Period'){
                    StatusToUpdate = 'Screening In Progress - Wash Out Period';
                }
                Set<Id> SSId = new Set<Id>(); 
                Set<Id> planIds = new Set<Id>(); 
                Map<ID,ID> MapSitePlan = new Map<ID,ID>(); 
                Map<ID,Incentive_Plan_Task__c> MapPlanTask = new Map<Id,Incentive_Plan_Task__c>();  
                List<Incentive_Plan_Task__c> incentiveTasks = new  List<Incentive_Plan_Task__c>();  
                List<Completed_Incentive_Task__c> lstIncentiveTsk = new List<Completed_Incentive_Task__c>();                    
                List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
                
                List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
                List<Participant_Enrollment__c> PEIncentiveList = new List<Participant_Enrollment__c>();
                List<Id> PeId = new List<Id>();
                List<Participant_Enrollment_Status_History__c> historiestoUpdate = new List<Participant_Enrollment_Status_History__c>();
                List<Participant_Enrollment_Status_History__c> peshUpdate = new List<Participant_Enrollment_Status_History__c>();
                
                for (Participant_Enrollment__c pe : [
                    SELECT Id,
                    Name,
                    Participant_Status__c,
                    Study_Site__c,
                    Last_Status_Changed_Notes__c,
                    Non_Enrollment_Reason__c,
                    Participant_Status_Last_Changed_Date__c,
                    Final_consent__c,
                    Non_Referral_Notes__c,
                    Non_Referral_Reason__c,
                    Initial_visit_scheduled_time__c,
                    Initial_visit_scheduled_date__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN :peIdList
                ]){
                    pe.Participant_Status__c = StatusToUpdate;
                    pe.Non_Referral_Notes__c = Notes;
                    pe.Last_Status_Changed_Notes__c = Notes;
                    pe.Non_Enrollment_Reason__c = reason;
                    pe.Final_consent__c = finalconsent;
                    pe.Participant_Status_Last_Changed_Date__c = system.now();
                    
                    if(pe.Participant_Status__c == PEStatusState.PE_STATUS_UNABLE_TO_REACH ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_PRE_REVIEW_FAILED){
                        pe.Initial_visit_scheduled_date__c = NULL;
                        pe.Initial_visit_scheduled_time__c = NULL;
                    }
                    PEUpdateList.add(pe);
                    PeId.add(pe.Id);
                    if(pe.Participant_Status_Last_Changed_Date__c.date().daysBetween(Date.today()) <= 1)
                    {
                        PEIncentiveList.add(pe);
                    }
                    
                    SSId.add(pe.Study_Site__c);
                    
                   
                    
                    if((oParticipantStatus == PEStatusState.PE_STATUS_READY_TO_SCREEN ||
                        oParticipantStatus == PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS ||
                        oParticipantStatus == PEStatusState.PE_STATUS_DECLINED_CONSENT ||
                        oParticipantStatus == PEStatusState.PE_STATUS_UNABLE_TO_SCREEN ||
                        oParticipantStatus == PEStatusState.PE_STATUS_WITHDREW_CONSENT ||
                        oParticipantStatus == PEStatusState.PE_STATUS_SCREENING_FAILED ||
                        oParticipantStatus == PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD) &&
                       (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS||
                       pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS||
                       pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_FAILED||
                       pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_FAILED||
                       pe.Participant_Status__c == PEStatusState.PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING ||
                       pe.Participant_Status__c == PEStatusState.PE_STATUS_DECLINED_FINAL_CONSENT)){
                           histories.add(
                               new Participant_Enrollment_Status_History__c(
                                   Date__c = pe.Participant_Status_Last_Changed_Date__c,
                                   Status__c = PEStatusState.PE_STATUS_SCREENING_PASSED,
                                   ParticipantEnrollment__c = pe.Id
                               )
                           );
                       }
                    if(pe.Participant_Status__c != PEStatusState.PE_STATUS_RECEIVED &&
                        pe.Participant_Status__c != PEStatusState.PE_STATUS_ELIGIBILITY_PASSED){
                           histories.add(
                               new Participant_Enrollment_Status_History__c(
                                   Date__c = pe.Participant_Status_Last_Changed_Date__c,
                                   Status__c = pe.Participant_Status__c,
                                   Notes__c = Notes,
                                   ParticipantEnrollment__c = pe.Id,
                                   Non_Enrollment_Reason__c = reason
                               )
                           );
                      }
                    
                }
               
                if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
                       TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
                        );
                        
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            PENotificationTriggerHandler.CreateNotificationHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
                        );
                        /* TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
                        );*/
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
                        );
                        update PEUpdateList;
                    } 
                
                if(histories != null && !histories.isEmpty()){
                    insert histories;
                }
                if(PeId != null && !PeId.isEmpty()){
                   if(StatusToUpdate == 'Received'){
                  
                   historiestoUpdate =[select id,Backward_Bulk_Update__c,Status__c,ParticipantEnrollment__c  from Participant_Enrollment_Status_History__c
                                       where ParticipantEnrollment__c  IN:peId and Status__c!=:StatusToUpdate ];              
                       for(Participant_Enrollment_Status_History__c psh:historiestoUpdate){
                           psh.Backward_Bulk_Update__c=true;
                           peshUpdate.add(psh);
                       }                      
                    }
                    if(peshUpdate !=null && !peshUpdate.isEmpty()){
                    
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
                        );
                        
                        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
                        );
                        
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            PENotificationTriggerHandler.CreateNotificationHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
                        );
                         TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
                        );
                        TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
                        );
                         
                         update peshUpdate;
                    }
                }
                
                if (oParticipantStatus == PEStatusState.PE_STATUS_RECEIVED &&
                    (StatusToUpdate == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
                     StatusToUpdate == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED ||
                     StatusToUpdate == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
                     StatusToUpdate == PEStatusState.PE_STATUS_UNABLE_TO_REACH)) 
                {
                    if(PEIncentiveList.size() > 0 ||  !PEIncentiveList.isEmpty())
                    {    ID ContacId = UserContext.getUserContactId();
                     for (Study_Incentive_Plan__c studyIncentivePlan : [
                         SELECT Id, Incentive_Plan__c, Clinical_Trial_Profile__c, Study_Site__c
                         FROM Study_Incentive_Plan__c
                         WHERE
                         Study_Site__c IN:SSId
                         AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != :CommunityTemplateService.TEMPLATE_JANSSEN
                     ]){
                         planIds.add(studyIncentivePlan.Incentive_Plan__c);
                         MapSitePlan.put(studyIncentivePlan.Study_Site__c,studyIncentivePlan.Incentive_Plan__c);
                     }
                     if (!planIds.isEmpty()){
                         incentiveTasks = [
                             SELECT Id, Points__c, Enabled__c, IQVIA_Supported__c,Incentive_Plan__c
                             FROM Incentive_Plan_Task__c
                             WHERE Incentive_Plan__c IN :planIds 
                             AND Enabled__c=TRUE 
                             AND Incentive_Task_Catalog__c = :IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY
                         ];
                         if(!incentiveTasks.isEmpty()){
                             for(Incentive_Plan_Task__c ipt:incentiveTasks){
                                 MapPlanTask.put(ipt.Incentive_Plan__c,ipt);
                             }
                             for(Participant_Enrollment__c per :PEIncentiveList)
                             {
                                 if(MapSitePlan.containsKey(per.Study_Site__c)){
                                     Incentive_Plan_Task__c pt = MapPlanTask.get(MapSitePlan.get(per.Study_Site__c));
                                     Completed_Incentive_Task__c completedIncentiveTask = new Completed_Incentive_Task__c();
                                     completedIncentiveTask.Completed_By__c = ContacId;
                                     completedIncentiveTask.Completed_Date__c = Datetime.now();
                                     completedIncentiveTask.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY;
                                     completedIncentiveTask.Points__c = pt.Points__c;
                                     completedIncentiveTask.Completed_For__c = per.Name;
                                     lstIncentiveTsk.add(completedIncentiveTask);
                                 }
                             }
                             Insert lstIncentiveTsk;
                         } 
                         
                     }
                    }  
                } 
            }catch (Exception e) {
                Database.rollback(sp);
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }
        }

      //Added for Bulk Action- Invite to PP
    @AuraEnabled
    public static void createUserForPatientProtal(List<string> peId, Boolean sendEmails) {
        system.debug('ListSize'+peId.size());
        try {
            List<Participant_Enrollment__c> per = [SELECT Id,
                                                   Participant_Contact__c,
                                                   Participant_Contact__r.Is_Patient_User_Created__c,
                                                   PI_Contact__c,Invited_To_PP_Date__c, 
                                                   HCP_Contact__c,HCP_Contact_HCPEnroll__c,
                                                   Clinical_Trial_Profile__r.CommunityTemplate__c 
                                                   FROM Participant_Enrollment__c 
                                                   WHERE ID IN:peId];
            
            List<Contact> lstContact = new List<Contact>();
            string communityTemplatename='';
            List<User> returnUsers = new List<User>();
            Map<Id, Id> createUsersMap = new Map<Id, Id>();
            Boolean isUpdatePE = false;
            
            for(Participant_Enrollment__c pe: per){
                if (sendEmails) {
                    Contact con = new Contact(id =pe.Participant_Contact__c,Consent_To_Inform_About_Study__c = true);
                    lstContact.add(con);           
                }
                if(communityTemplatename!=null){
                    communityTemplatename = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
                }
                if(pe.Participant_Contact__r.Is_Patient_User_Created__c == false){
                    if (pe.HCP_Contact__c == null) {
                        createUsersMap.put(pe.Participant_Contact__c,pe.PI_Contact__c);
                    }else{
                        createUsersMap.put(pe.Participant_Contact__c,pe.HCP_Contact_HCPEnroll__c);
                    }
                }
                if(pe.Invited_To_PP_Date__c == null){
                    pe.Invited_To_PP_Date__c = DateTime.now();
                    isUpdatePE = true;
                }
            }
            
            if(!lstContact.isEmpty()){
                update lstContact;
            }
            if(isUpdatePE){
                update per;
            }
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(communityTemplatename).permissionSet; 
            
            if (!createUsersMap.isEmpty() && !Test.isRunningTest() ){
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsersBulk(createUsersMap);
            }
            
            
            for(Participant_Enrollment__c p: per)
            { 
                actionAssignContactPermissions.addPermission(
                    p.Participant_Contact__c,
                    permissionSetName
                );
                
            }
            
            if(!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }     
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
   
    //list of available statuses changed for REF-3962
    @AuraEnabled
    public static List<LabelValueItem> getAvailableStatuses(String status, Id StudyId){
        List<String> availableStatusLists = Label.ListView_GroupStatuses.split(',');
        List<String> availableStatusList = new List<String>();
        List<LabelValueItem> StatusList = new List<LabelValueItem>();
        String availableStatus;
        
        Clinical_Trial_Profile__c ctp = [SELECT 
                                         Promote_to_SH__c,
                                         Initial_Visit_Required__c,
                                         Participant_Workflow_Final_Step__c,
                                         Final_Consent_Required__c 
                                         FROM Clinical_Trial_Profile__c 
                                         WHERE Id =: StudyId];
        
        Boolean isPromoteToSH = ctp.Promote_to_SH__c;
        Boolean isInitialVisit = ctp.Initial_Visit_Required__c;
        String finalStep = ctp.Participant_Workflow_Final_Step__c;
        Boolean finalConsent = ctp.Final_Consent_Required__c ;
        
        if(availableStatusLists.contains(status)){
            For(List_View_Status__mdt lvs : [SELECT 
                                             Managed_in_SH__c,
                                             Initial_Visit__c,
                                             Available_Statuses__c
                                             FROM List_View_Status__mdt
                                             WHERE Managed_in_SH__c =: isPromoteToSH 
                                             AND Initial_Visit__c =: isInitialVisit
                                             AND Participant_Status__c =: status])
            {
                availableStatusList=lvs.Available_Statuses__c.split(',');  
            }
            
        } else{
            For(List_View_Status__mdt lvs : [SELECT 
                                             Participant_Workflow_Final_Step__c,
                                             Available_Statuses__c,
                                             Final_Consent__c
                                             FROM List_View_Status__mdt
                                             WHERE Participant_Workflow_Final_Step__c =:finalStep
                                             AND Participant_Status__c =: status
                                            AND Final_Consent__c =: finalConsent])
            {
                availableStatusList=lvs.Available_Statuses__c.split(',');  
            }
        }
        
        StatusList.add(
            new LabelValueItem(Label.ListView_Select_a_Status, 'null'));
        for (String st :  availableStatusList){
            String t = st.replaceAll('[\\s\\-()]', '_');
            if (t == 'Contacted___Not_Suitable'){
                t = 'Contacted_Not_Suitable';
            }
            StatusList.add(
                new LabelValueItem(TranslateHelper.getLabelValue(t) , st));
        }
        return StatusList;
    }
    
   
    //Getting the Reason and Notes for popup
    @AuraEnabled
    public static statusWrapper statusDetail(String newStatus,Id studyId){
        statusWrapper stWrap = new statusWrapper();
        stWrap.notesRequiredMap = new Map<String, Boolean>();
        stWrap.reasonMap = new Map<String, List<LabelValueItem>>();
        List<LabelValueItem> reasonsList = new List<LabelValueItem>();
        For(Participant_Workflow_Outcome__mdt outcome : [
            SELECT 
            Status_Name__c,
            Reasons_List__c,
            Step__c
            FROM Participant_Workflow_Outcome__mdt
            WHERE Status_Name__c =: newStatus
            LIMIT 1]){
                stWrap.Step = outcome.Step__c;
                stWrap.reason = TranslateHelper.getPickListLabel(
                    Participant_Enrollment__c.Non_Enrollment_Reason__c,
                    newStatus
                );
                if(outcome.Reasons_List__c == null) {
                    stWrap.notesRequiredMap.put(outcome.Status_Name__c + ';', false);
                } else {
                    for (String reason : outcome.Reasons_List__c.split(';')) {
                        String reasonNoDecoration = reason.remove('*');
                        reasonsList.add(
                            new LabelValueItem(
                                TranslateHelper.getPickListLabel(
                                    Participant_Enrollment__c.Non_Enrollment_Reason__c,
                                    reasonNoDecoration
                                ),
                                reasonNoDecoration
                            )
                        );
                        stWrap.notesRequiredMap.put(
                            outcome.Status_Name__c +
                            ';' +
                            reasonNoDecoration,
                            reason.contains('*')
                        );
                    }
                }
                stWrap.reasonMap.put(outcome.Status_Name__c, reasonsList);
            }
            
            stWrap.finalConsent = [Select Final_Consent_Required__c 
                                   From Clinical_Trial_Profile__c 
                                   WHERE Id = : studyId].Final_Consent_Required__c;
        return stWrap;
    }
    
    public class statusWrapper{
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public Map<String, List<LabelValueItem>> reasonMap;
        @AuraEnabled
        public Map<String, Boolean> notesRequiredMap;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public Boolean finalConsent;
        @AuraEnabled
        public String Step;
    }
     
    @AuraEnabled
    public static PeDataTableWrapper fetchData(String filterJSON,
                                               String bulkAction,
                                               String statusChangeto) {
        try {
            List<ListWrapper> FilterList = (List<ListWrapper>) JSON.deserialize(
                filterJSON,
                List<ListWrapper>.class
            );
            string res = '';
            string filter = '';
            string filterpp ='';
            String QueryCountPPchk='';
            List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
            List<WrapPageWithSelection> wpws = new List<WrapPageWithSelection>();
            List<Promote_to_SH__mdt> pshList = new List<Promote_to_SH__mdt>();
            List<String> lstSourceType = new List<String>();
            List<String> lstActiveStatus = new List<String>();
            List<String> lstInactiveStatus = new List<String>();
            List<String> pshStatus = new List<String>();
            List<Study_Site__c> Studysites = new List<Study_Site__c>();
            List<Id> siteIds = new List<Id>();
            List<String> lstActive = new List<String>();
            List<String> lstinActive = new List<String>();

            Boolean isChekedSelected = false;
            Boolean isLocked = false;
            Boolean PromotetoSH = false;
            String priorityReferral = 'Yes';
            List<Boolean> PeChecklist = new List<Boolean>();
            set<id> OrgSelectedIds = new Set<id>(FilterList[0].SelectedIds);
            //OrgSelectedIds=FilterList[0].SelectedIds;
            Integer pSize = (Integer) FilterList[0].pageSize;
            Integer pNumber = (Integer) FilterList[0].pageNumber;
            String participantStatus;

            Integer offset = (pNumber - 1) * pSize;
            Integer recordEnd = pSize * pNumber;

            String qCountString = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE';
            String queryString =
                'SELECT Id,Name,PerCounter__c,Initial_visit_scheduled_time__c,Participant_Name__c,Participant_Contact__c,Referral_Source__c,MRN_Id__c,Patient_ID__c,Referral_ID__c,Participant_ID_randomized_ID__c,Screening_ID__c,Study_Hub_Log__c,Study_Hub_Log__r.Response_Status_Code__c,' +
                'Participant__r.Full_Name__c,Participant__r.Present_Age__c,Participant__r.Gender_Technical__c,Participant__r.BMI__c,Study_Site__c,Study_Site__r.Name,Clinical_Trial_Profile__c,Participant__r.Adult__c,Participant__r.Marketing_Flag__c,Study_Site__r.Study_Site_Type__c,Permit_IQVIA_to_contact_about_study__c,Participant__r.IsCountry_NOT_Eligible_for_Emails__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Study_Site__r.Suppress_Participant_Emails__c,Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
                'Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Initial_Visit_Required__c,Clinical_Trial_Profile__r.Promote_to_SH__c,Clinical_Trial_Profile__r.Protocol_ID__c,Participant__r.Ethnicity__c,' +
                'Source_Type__c,Participant_Status__c,HighRisk_Indicator__c,CreatedDate,Referral_Source_ID__c, Participant__r.First_Name__c, Participant__r.Last_Name__c, Participant__r.Email__c, Participant__r.Phone__c, Participant__r.Phone_Type__c, Participant__r.Alternative_Phone_Number__c, Participant__r.Alternative_Phone_Type__c,' +
                'Initial_visit_scheduled_flag__c,Initial_visit_scheduled_date__c,High_Priority__c,Comorbidities__c,(SELECT Id FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1) FROM Participant_Enrollment__c WHERE ';

            String sortBy = ' ORDER BY ';
            if (FilterList[0].Sortby == 'Ascending') {
                sortBy += ' Name ASC';
            } else if (FilterList[0].Sortby == 'Received Date(Oldest First)') {
                sortBy += ' CreatedDate ASC';
            } else if (FilterList[0].Sortby == 'Received Date(Newest First)') {
                sortBy += ' CreatedDate DESC';
            } else {
                sortBy += ' Name DESC';
            }

            filter += ' Clinical_Trial_Profile__c=' + '\'' + FilterList[0].Study + '\'';
            
            //Modified Condition for Bulk Action Status Change
            if (
                !String.isEmpty(FilterList[0].ParticipantStatus) &&
                FilterList[0].ParticipantStatus != 'null' 
            ) {
                participantStatus = FilterList[0].ParticipantStatus;
                if(FilterList[0].ParticipantStatus == 'Sent to Study Hub'){
                    FilterList[0].ParticipantStatus = 'Eligibility Passed';
                }
                filter +=
                    'AND Participant_Status__c =' +
                    '\'' +
                    FilterList[0].ParticipantStatus +
                    '\'';
                    if(participantStatus == 'Eligibility Passed'){
                    filter +=
                        'AND Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = false ' +
                        ' AND Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = false ';
                    
                }else if(participantStatus == 'Sent to Study Hub'){
                    filter +=
                        'AND ( Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = true ' +
                        ' OR Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = true) ';
                }
            } else {
                if (FilterList[0].Status == 'Active') {
                    lstActive.add('Received');
                    lstActive.add('Pre-review Passed');
                    lstActive.add('Contact Attempted');
                    lstActive.add('Successfully Contacted');
                    lstActive.add('Screening In Progress');
                    lstActive.add('Screening In Progress - Wash Out Period');
                    lstActive.add('Screening Passed');
                    lstActive.add('Enrollment Success');
                    lstActive.add('Eligibility Passed');
                    lstActive.add('Ready to Screen');
                    lstActive.add('Randomization Success');
                    filter += ' AND Participant_Status__c  IN: lstActive ';
                } else {
                    lstinActive.add('Pre-review Failed');
                    lstinActive.add('Unable to Reach');
                    lstinActive.add('Contacted - Not Suitable');
                    lstinActive.add('Eligibility Failed');
                    lstinActive.add('Declined Consent');
                    lstinActive.add('Unable to Screen');
                    lstinActive.add('Withdrew Consent');
                    lstinActive.add('Screening Failed');
                    lstinActive.add('Withdrew Consent After Screening');
                    lstinActive.add('Enrollment Failed');
                    lstinActive.add('Randomization Failed');
                    lstinActive.add('Declined Final Consent');
                    filter += ' AND Participant_Status__c  IN: lstinActive  ';
                }
            }
            if (
                !String.isEmpty(FilterList[0].StudySites) &&
                FilterList[0].StudySites != 'All study sites'
            ) {
                filter += 'AND Study_Site__c =' + '\'' + FilterList[0].StudySites + '\'';
            } else {
                String piId = CommunityService.getUserContact().Id;

                Studysites = [
                    SELECT
                        Id,
                        Name,
                        Clinical_Trial_Profile__c,
                        Principal_Investigator__c,
                        Override_PI_Referral_Status__c
                    FROM Study_Site__c
                    WHERE
                        Clinical_Trial_Profile__c = :FilterList[0].Study
                        AND (Principal_Investigator__c = :piId
                        OR ID IN :DelegateService.getDelegatedStudySiteIds())
                ];
                for (Study_Site__c ss : Studysites) {
                    siteIds.add(ss.id);
                }
                filter += ' AND Study_Site__c IN: siteIds ';
            }
            if (!String.isEmpty(FilterList[0].Source) && FilterList[0].Source != 'null') {
                filter += 'AND Source_Type__c=' + '\'' + FilterList[0].Source + '\'';
            } else {
                lstSourceType.add('Referring Provider');
                lstSourceType.add('Principal Investigator');
                lstSourceType.add('Digital Recruitment');
                filter += ' AND Source_Type__c IN: lstSourceType ';
            }

            if (Boolean.valueOf(FilterList[0].isHighRiskOccupation) == true) {
                filter += ' AND HighRisk_Indicator__c= ' + '\'' + 'Yes' + '\'';
            }
            if (Boolean.valueOf(FilterList[0].isComorbidities) == true) {
                filter += ' AND Comorbidities__c= ' + '\'' + 'Yes' + '\'';
            }
            if (Boolean.valueOf(FilterList[0].isInitialVisitScheduled) == true) {
                filter += ' AND Initial_visit_scheduled_date__c !=null ';
            }

            //demographic filters//
            if (!String.isEmpty(FilterList[0].Ethnicity) && FilterList[0].Ethnicity != 'null') {
                filter +=
                    ' AND Participant__r.Ethnicity__c includes (' +
                    '\'' +
                    FilterList[0].Ethnicity +
                    '\')';
            }
            //if (FilterList[0].AgeFrom != '0' || FilterList[0].AgeTo != '100') {
            if (String.isEmpty(FilterList[0].AgeFrom))
                FilterList[0].AgeFrom = '0';
            if (String.isEmpty(FilterList[0].AgeTo))
                FilterList[0].AgeTo = '150';
            if (FilterList[0].AgeFrom == '0' && FilterList[0].AgeTo == '150') {
                filter +=
                    ' AND ((Participant__r.Present_Age__c >=' +
                    FilterList[0].AgeFrom +
                    ' AND Participant__r.Present_Age__c <=' +
                    FilterList[0].AgeTo +
                    ') ';
                String universal = ' OR Participant__r.Present_Age__c = null ) ';
                filter = filter + universal;
            } else {
                filter +=
                    ' AND (Participant__r.Present_Age__c >=' +
                    FilterList[0].AgeFrom +
                    ' AND Participant__r.Present_Age__c <=' +
                    FilterList[0].AgeTo +
                    ')';
            }

            //}
            if (!String.isEmpty(FilterList[0].Sex) && FilterList[0].Sex != 'All') {
                filter +=
                    ' AND Participant__r.Gender_Technical__c=' +
                    '\'' +
                    FilterList[0].Sex +
                    '\'';
            }

            //filters for Bulk Action
            //Invite to PP
            if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
               
                filter += 'AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !=' + '\'' + 'Virtual' + '\'' + 'AND Study_Site__r.Study_Site_Type__c !=' + '\'' + 'Hybrid' + '\'' + ' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE ';
                filter += 'AND Clinical_Trial_Profile__r.CommunityTemplate__c !=' + '\'' + system.Label.Janssen_Community_Template_Name + '\'';
                filter += 'AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE ';
                   
            }else{
                filterpp = filter;
                filterpp += 'AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !=' + '\'' + 'Virtual' + '\'' + 'AND Study_Site__r.Study_Site_Type__c !=' + '\'' + 'Hybrid' + '\'' + ' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE ';
                filterpp += 'AND Clinical_Trial_Profile__r.CommunityTemplate__c !=' + '\'' + system.Label.Janssen_Community_Template_Name + '\'';
                filterpp += 'AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE ';
            }
                            
               system.debug('querystringcount-->' + qCountString + filter);
            
            
            if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
                QueryCountPPchk = qCountString + filter;
            }else{
                QueryCountPPchk = qCountString + filterpp;
            }
            String QueryCount = qCountString + filter;
            Integer totalRecords = Database.countQuery(QueryCount);
            Integer totalRecordCountPP = Database.countQuery(QueryCountPPchk);
            String OffsetLimit;
            if (Boolean.ValueOf(FilterList[0].isExport)) {
                String strTemp =
                    ' AND PerCounter__c >=' +
                    Integer.valueOf(FilterList[0].startPos) +
                    ' AND PerCounter__c <=' +
                    Integer.valueOf(FilterList[0].endPos);
                filter = filter + strTemp;
                sortBy = ' order by PerCounter__c asc';
                OffsetLimit = ' LIMIT 49500';
            } else {
                OffsetLimit = ' LIMIT ' + pSize + ' OFFSET ' + offset;
            }
            
            
            String Query = queryString + filter + sortBy + OffsetLimit;
            peList = Database.query(Query);
      if(peList.size() == 0 && totalRecords != 0)
            {
                     pNumber = pNumber -1;
                      offset = (pNumber - 1) * pSize;
                   recordEnd = pSize * pNumber;
                   peList.clear();
                   Query ='';
                    if (Boolean.ValueOf(FilterList[0].isExport)) {
                    String strTemp =
                        ' AND PerCounter__c >=' +
                        Integer.valueOf(FilterList[0].startPos) +
                        ' AND PerCounter__c <=' +
                        Integer.valueOf(FilterList[0].endPos);
                    filter = filter + strTemp;
                    sortBy = ' order by PerCounter__c asc';
                    OffsetLimit = ' LIMIT 49500';
                } else {
                    OffsetLimit = ' LIMIT ' + pSize + ' OFFSET ' + offset;
                }
                
                Query = queryString + filter + sortBy + OffsetLimit;
                peList = Database.query(Query);
            }

            PeDataTableWrapper objDT = new PeDataTableWrapper();
            objDT.pageSize = pSize;
            objDT.pageNumber = pNumber;
            objDT.recordStart = offset + 1;
            objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            objDT.totalRecords = totalRecords;
            objDT.enablePP = totalRecordCountPP !=0?true:false;

            pshList = [SELECT DeveloperName, status__c FROM Promote_to_SH__mdt];
            for (Promote_to_SH__mdt psl : pshList) {
                pshStatus.add(psl.status__c);
            }
            
            Boolean studySitePSH = false;
            Decimal pshLimit;
            pshLimit = [SELECT DeveloperName, Limit__c FROM Promote_to_SH_Limit__mdt LIMIT 1]
            .Limit__c;
            for (Participant_Enrollment__c pe : peList) {
                if (OrgSelectedIds.size() > 0) {
                    if (OrgSelectedIds.contains(pe.id)) {
                        //PeChecklist.add(true);
                        isChekedSelected = true;
                        Boolean allowedForSH = ifAllowedForSH(pe,pshStatus);    
                        studySitePSH = ifAllowedForSH(pe,pshStatus);    
                        if (allowedForSH) {
                            //isChekedSelected = true;
                            isLocked = false;
                            if (pe.Initial_visit_scheduled_date__c != null) {
                                priorityReferral = 'Yes';
                            } else {
                                priorityReferral = 'No';
                            }
                        } else {
                            //isChekedSelected = false;
                             if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
                              isLocked = false;
                             }else if(bulkAction != Null && bulkAction == 'Change Participant Status'){ 
                               if(statusChangeto =='Randomization Success' && pe.Screening_ID__c  ==null){
                                isLocked = true;
                               }else
                               {isLocked = false;}
                             }else{
                                 isLocked = true;
                             }
                            if (pe.High_Priority__c) {
                                priorityReferral = 'Yes';
                            } else {
                                priorityReferral = 'No';
                            }
                        }
                    } else {
                        //PeChecklist.add(false);
                       Boolean allowedForSH = ifAllowedForSH(pe,pshStatus); 
                        studySitePSH = ifAllowedForSH(pe,pshStatus); 
                        if (allowedForSH) {
                            isChekedSelected = false;
                            isLocked = false;
                            if (pe.Initial_visit_scheduled_date__c != null) {
                                priorityReferral = 'Yes';
                            } else {
                                priorityReferral = 'No';
                            }
                        } else {
                            isChekedSelected = false;
                           if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
                              isLocked = false;
                             }else if(bulkAction != Null && bulkAction == 'Change Participant Status'){ 
                                if(statusChangeto =='Randomization Success' && pe.Screening_ID__c  ==null){
                                isLocked = true;
                               }else
                               {isLocked = false;}
                             }else{
                                 isLocked = true;
                             }
                            if (pe.High_Priority__c) {
                                priorityReferral = 'Yes';
                            } else {
                                priorityReferral = 'No';
                            }
                        }
                    }
                } else {
                    //PeChecklist.add(false);
                    Boolean allowedForSH = ifAllowedForSH(pe,pshStatus);    
                        studySitePSH = ifAllowedForSH(pe,pshStatus); 
                        if (allowedForSH)  {
                        isChekedSelected = false;
                        isLocked = false;
                        if (pe.Initial_visit_scheduled_date__c != null) {
                            priorityReferral = 'Yes';
                        } else {
                            priorityReferral = 'No';
                        }
                    } else {
                        isChekedSelected = false;
                       if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
                              isLocked = false;
                             }else if(bulkAction != Null && bulkAction == 'Change Participant Status'){ 
                                if(statusChangeto =='Randomization Success' && pe.Screening_ID__c  ==null){
                                isLocked = true;
                               }else
                               {isLocked = false;}
                             }else{
                                 isLocked = true;
                             }
                        if (pe.High_Priority__c) {
                            priorityReferral = 'Yes';
                        } else {
                            priorityReferral = 'No';
                        }
                    }
                }
                if (FilterList[0].highPrioritySelected_YesIds.contains(pe.id)) {
                    priorityReferral = 'Yes';
                }
                if (FilterList[0].highPrioritySelected_NoIds.contains(pe.id)) {
                    priorityReferral = 'No';
                }

                String Ethnicity = '';
                if (pe.Participant__r.Ethnicity__c != null) {
                    Ethnicity = pe.Participant__r.Ethnicity__c;
                    List<String> lstString = Ethnicity.split(';');
                    string EC = '';
                    for (string s : lstString) {
                        EC += +s.left(1) + ',';
                    }
                    EC = +EC.removeEnd(',');
                    Ethnicity = EC;
                }
                String initialVisitScheduleTime = String.ValueOf(
                    pe.Initial_visit_scheduled_time__c
                );
                if (initialVisitScheduleTime != '' && initialVisitScheduleTime != null) {
                    initialVisitScheduleTime = initialVisitScheduleTime.replace('.000Z', '');
                }
                //REF-3288- Start
                if(pe.Participant_Status__c== 'Eligibility Passed' && 
                   (pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c == true || pe.Clinical_Trial_Profile__r.Promote_to_SH__c  == true)){
                    pe.Participant_Status__c = 'Sent to Study Hub';
                   }else if(pe.Participant_Status__c== 'Eligibility Passed'){
                       pe.Participant_Status__c= 'Eligibility Passed';
                   }
                //REF-3288- End
                wpws.add(
                    new WrapPageWithSelection(
                        pe,
                        isChekedSelected,
                        isLocked,
                        priorityReferral,
                        Ethnicity,
                        initialVisitScheduleTime
                    )
                );
                PromotetoSH = pe.Clinical_Trial_Profile__r.Promote_to_SH__c;
            }
            
            objDT.bulkStatusUpdate = false;
            //Added for SH studies
            if (
                !String.isEmpty(FilterList[0].ParticipantStatus) &&
                FilterList[0].ParticipantStatus != 'null' 
            ){
                Boolean isPromoteToSH = [SELECT Promote_to_SH__c
                                 FROM Clinical_Trial_Profile__c 
                                 WHERE Id =: FilterList[0].Study].Promote_to_SH__c;
                List<List_View_Status__mdt> metadataList = [SELECT Managed_in_SH__c,Available_Statuses__c
                                         FROM List_View_Status__mdt
                                         WHERE Managed_in_SH__c =: isPromoteToSH 
                                         AND Participant_Status__c =: FilterList[0].ParticipantStatus];
                if(!metadataList.isEmpty()){
                    objDT.bulkStatusUpdate = true;
                }
            }

            //objDT.isChecked =PeChecklist;
            objDT.IsPromoteToSH = PromotetoSH;
            objDT.enableSH = PromotetoSH && studySitePSH ? true : false;
            objDT.OrginalidSelected = OrgSelectedIds;
            objDT.FilterImpacts = wpws;
            objDT.IsPromoteToSHLimit = pshLimit;
            objDT.retainFilter = FilterList[0];

            return objDT;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @TestVisible   
    private static Boolean ifAllowedForSH(  
        Participant_Enrollment__c pe,   
        List<String> pshStatus  
    ){  
        return ifAllowedForSH(pe, pshStatus, false);    
    }   
        
    public static Boolean ifAllowedForSH(   
        Participant_Enrollment__c pe,   
        List<String> pshStatus,Boolean eligibilityStatusPresent 
    ){  
        Boolean isAllowedForSH = false; 
        if(pe!=null){
        Boolean logNotPresentOrFailed = (pe.Study_Hub_Log__c == null    
                                        || (pe.Study_Hub_Log__c != null &&  
                                        pe.Study_Hub_Log__r.Response_Status_Code__c != 201));   
        Boolean eligibilyPassedStatusPresent = (eligibilityStatusPresent== true)?true:pe.Participant_Enrollment_Status_History__r!=null &&  
            !pe.Participant_Enrollment_Status_History__r.isEmpty(); 

        if(pe.Clinical_Trial_Profile__r.Promote_to_SH__c == true && (pe.Study_Site__r.Study_Site_Type__c == 'Hybrid' || pe.Study_Site__r.Study_Site_Type__c == 'Virtual') && pshStatus.contains(pe.Participant_Status__c)         
           && ((pe.Participant_Status__c!='Eligibility Passed' && !eligibilyPassedStatusPresent) || 
               (pe.Participant_Status__c!='Eligibility Passed' && eligibilyPassedStatusPresent && logNotPresentOrFailed))){ 
                   isAllowedForSH = true;   
               }    
        }
        return isAllowedForSH;  
    }
    @TestVisible
    private static String getAdditionalFilter(
        String mode,
        Boolean emancipatedPE,
        Id participantId,
        String sponsorName
    ) {
        String filter =
            ' Participant_Status__c NOT IN ' +
            DatabaseService.listToString(
                (mode != CommunityService.USER_MODE_PI ||
                    participantId != null)
                    ? EXCLUDED_STATUSES_COMMON
                    : EXCLUDED_STATUSES_PI
            );
        if (mode == CommunityService.USER_MODE_HCP && participantId == null) {
            filter +=
                ' AND Non_Referral_Reason__c NOT IN ' +
                DatabaseService.listToString(EXCLUDED_REASONS);
        }
        if (participantId != null) {
            filter += ' AND Participant__c=\'' + participantId + '\'';
        }
        //Added filter janssen
        if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            filter +=
                ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        } else {
            filter +=
                ' AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        }

        return filter;
    }

    // Modified for performance tuning
    // Sabir & Velu 09/04/2020
    @TestVisible
    private static ListViewParticipantService.PEFilterData createPEFilterData(
        String activePE,
        Id trialId,
        Id siteId,
        String mode,
        Boolean restrictTrial,
        String delegateId,
        String additionalFilter,
        PaginationData paginationData,
        String sponsorName
    ) {
        //ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterDataWithExistingPERecords(activePE, trialId, mode, restrictTrial, delegateId, additionalFilter,sponsorName);
        ListViewParticipantService.PEFilterData filterData = ListViewParticipantService.getPEFilterDataWithSponsor(
            mode,
            trialId,
            restrictTrial,
            delegateId,
            sponsorName
        );
        ListViewParticipantService.PEFilter filter = new ListViewParticipantService.PEFilter(
            filterData
        );
        filter.activePE = activePE;
        filter.study = trialId;
        filter.studySite = siteId;
        filter.additionalFilter = additionalFilter;
        filterData.dateField = 'Referred_Date__c';
        filterData.sortVariants.addAll(
            new List<LabelValueItem>{
                new LabelValueItem(
                    SortOrder.ORDER_A_Z,
                    'Alphabetical_ASC,Participant__r.First_Name__c,Participant__r.Last_Name__c'
                ),
                new LabelValueItem(
                    SortOrder.ORDER_Z_A,
                    'Alphabetical_DESC,Participant__r.First_Name__c,Participant__r.Last_Name__c'
                )
            }
        );
        List<LabelValueItem> peSource = new List<LabelValueItem>{
            new LabelValueItem(Label.PG_MRR_L_All_Sources, 'null'),
            new LabelValueItem(Label.Referring_Provider, 'Referring Provider'),
            new LabelValueItem(Label.Principal_Investigator, 'Principal Investigator'),
            new LabelValueItem(Label.Digital_Recruitment, 'Digital Recruitment')
        };
        List<LabelValueItem> pEthnicity = new List<LabelValueItem>{
            new LabelValueItem(Label.All_Ethnicities, 'null'),
            new LabelValueItem(Label.Prefer_not_to_say, '0- Prefer not to say'),
            new LabelValueItem(Label.Hispanic_Latino, '1- Hispanic/Latino'),
            new LabelValueItem(
                Label.American_Indian_Alaskan_Native,
                '2- American Indian/Alaskan Native'
            ),
            new LabelValueItem(Label.Asian, '3- Asian'),
            new LabelValueItem(Label.African_American_Black, '4- African-American/Black'),
            new LabelValueItem(
                Label.Native_Hawaiian_Other_Pacific_Islander,
                '5- Native Hawaiian/Other Pacific Islander'
            ),
            new LabelValueItem(Label.Caucasian_White, '6- Caucasian/White'),
            new LabelValueItem(Label.Two_or_more_races, '7- Two or more races')
        };

        List<LabelValueItem> statusFilterData;
        if (activePE == 'Active') {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, 'null'),
                new LabelValueItem(Label.Received, 'Received'),
                new LabelValueItem(Label.Pre_review_Passed, 'Pre-review Passed'),
                new LabelValueItem(Label.Contact_Attempted, 'Contact Attempted'),
                new LabelValueItem(Label.Successfully_Contacted, 'Successfully Contacted'),
                new LabelValueItem(Label.Screening_In_Progress, 'Screening In Progress'),
                new LabelValueItem(
                    Label.In_Wash_Out_Period,
                    'Screening In Progress - Wash Out Period'
                ),
                new LabelValueItem(Label.Screening_Passed, 'Screening Passed'),
                new LabelValueItem(Label.Enrollment_Success, 'Enrollment Success'),
                //new LabelValueItem(label.Sent_to_Study_Hub, 'Eligibility Passed'),
                //new LabelValueItem(label.Eligibility_Passed, 'Eligibility Passed'),//REF-3288 - for Filter
                new LabelValueItem(Label.Ready_to_Screen, 'Ready to Screen'),
                new LabelValueItem(Label.Randomization_Success, 'Randomization Success')
            };
        } else {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, 'null'),
                new LabelValueItem(Label.Pre_review_Failed, 'Pre-review Failed'),
                new LabelValueItem(Label.Unable_to_Reach, 'Unable to Reach'),
                new LabelValueItem(Label.Contacted_Not_Suitable, 'Contacted - Not Suitable'),
                new LabelValueItem(Label.Eligibility_Failed, 'Eligibility Failed'),
                new LabelValueItem(Label.Declined_Consent, 'Declined Consent'),
                new LabelValueItem(Label.Unable_to_Screen, 'Unable to Screen'),
                new LabelValueItem(Label.Withdrew_Consent, 'Withdrew Consent'),
                new LabelValueItem(Label.Screening_Failed, 'Screening Failed'),
                new LabelValueItem(
                    Label.Withdrew_Consent_After_Screening,
                    'Withdrew Consent After Screening'
                ),
                new LabelValueItem(Label.Enrollment_Failed, 'Enrollment Failed'),
                new LabelValueItem(Label.Randomization_Failed, 'Randomization Failed'),
                new LabelValueItem(Label.Declined_Final_Consent,'Declined Final Consent')
            };
        }
        filterData.statuses = statusFilterData;
        filterData.source = peSource;
        filterData.ethnicity = pEthnicity;
        return filterData;
    }
    
    @AuraEnabled
    public static List<LabelValueItem> getParticipantStatus(String studyId, String activePE){
        List<Clinical_Trial_Profile__c> ctps = new List<Clinical_Trial_Profile__c>();
        Boolean isInitVisitReqd= false;
        Boolean isPromoteToSH=false;
        if(studyId !=null){
            ctps=[SELECT Id,Initial_Visit_Required__c,Promote_to_SH__c FROM Clinical_Trial_Profile__c WHERE Id=:studyId];   
        }
        if(!ctps.isEmpty()){
            isInitVisitReqd = ctps[0].Initial_Visit_Required__c;
            isPromoteToSH = ctps[0].Promote_to_SH__c;
        }
        return getParticipantStatus(activePE, isPromoteToSH, isInitVisitReqd);
    }

    @AuraEnabled
    public static List<LabelValueItem> getParticipantStatus(String activePE, Boolean isPromoteToSH, Boolean isInitVisitReqd) {
        // ListViewParticipantService.PEFilterData filterData = new ListViewParticipantService.PEFilterData();
        List<LabelValueItem> statusFilterData;
        if (activePE == 'Active') {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, 'null'),
                new LabelValueItem(Label.Received, 'Received'),
                new LabelValueItem(Label.Pre_review_Passed, 'Pre-review Passed'),
                new LabelValueItem(Label.Contact_Attempted, 'Contact Attempted'),
                new LabelValueItem(Label.Successfully_Contacted, 'Successfully Contacted'),
                new LabelValueItem(Label.Screening_In_Progress, 'Screening In Progress'),
                new LabelValueItem(
                    Label.In_Wash_Out_Period,
                    'Screening In Progress - Wash Out Period'
                ),
                new LabelValueItem(Label.Screening_Passed, 'Screening Passed'),
                new LabelValueItem(Label.Enrollment_Success, 'Enrollment Success'),
                //new LabelValueItem(Label.Eligibility_Passed, 'Eligibility Passed'),
                //new LabelValueItem(label.Sent_to_Study_Hub, 'Eligibility Passed'), // REF-3288 - for Filter values
                new LabelValueItem(Label.Ready_to_Screen, 'Ready to Screen'),
                new LabelValueItem(Label.Randomization_Success, 'Randomization Success')
            };
            if(isPromoteToSH == false){
                    statusFilterData.add(new LabelValueItem(Label.Eligibility_Passed, 'Eligibility Passed'));
                }else {
                    statusFilterData.add(new LabelValueItem(label.Sent_to_Study_Hub, 'Sent to Study Hub'));
                }
        } else {
            statusFilterData = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRR_L_All_Statuses, 'null'),
                new LabelValueItem(Label.Pre_review_Failed, 'Pre-review Failed'),
                new LabelValueItem(Label.Unable_to_Reach, 'Unable to Reach'),
                new LabelValueItem(Label.Contacted_Not_Suitable, 'Contacted - Not Suitable'),
                new LabelValueItem(Label.Eligibility_Failed, 'Eligibility Failed'),
                new LabelValueItem(Label.Declined_Consent, 'Declined Consent'),
                new LabelValueItem(Label.Unable_to_Screen, 'Unable to Screen'),
                new LabelValueItem(Label.Withdrew_Consent, 'Withdrew Consent'),
                new LabelValueItem(Label.Screening_Failed, 'Screening Failed'),
                new LabelValueItem(
                    Label.Withdrew_Consent_After_Screening,
                    'Withdrew Consent After Screening'
                ),
                new LabelValueItem(Label.Enrollment_Failed, 'Enrollment Failed'),
                new LabelValueItem(Label.Randomization_Failed, 'Randomization Failed'),
                new LabelValueItem(Label.Declined_Final_Consent,'Declined Final Consent')
            };
        }
        // filterData.statuses = statusFilterData;
        return statusFilterData;
    }
    @TestVisible
    private static Boolean labelValueItemsHaveItem(
        List<LabelValueItem> labelValueItems,
        String item
    ) {
        for (LabelValueItem lvi : labelValueItems) {
            if (lvi.value == item) {
                return true;
            }
        }
        return false;
    }
    @TestVisible
    private static void updateSearchResultAccordingItemChanged(
        SearchResult result,
        String changedItem
    ) {
        if (changedItem == 'active' || changedItem == 'emancipation') {
            result.peFilter.study = null;
        }
        if (changedItem == 'active' || changedItem == 'emancipation' || changedItem == 'study') {
            result.peFilter.studySite = null;
        }
        if (
            changedItem == 'active' ||
            changedItem == 'emancipation' ||
            changedItem == 'study' ||
            changedItem == 'site'
        ) {
            result.peFilter.source = null;
            result.peFilter.dateRange = null;
            result.peFilter.participantStatus = null;
            result.peFilter.referringStatus = null;
        }
        if (changedItem != 'pagination') {
            result.paginationData.currentPage = 1;
        }
    }

    @AuraEnabled
    public static String getParticipantData(Id peId, Id contactid) {
        String query;
        //if(!Test.isRunningTest())
        // {
        query =
            'SELECT Invited_To_PP_Date__c,Participant__r.Full_Name__c,Days_After_Referred__c, Participant__c,Participant__r.Phone__c,' +
            ' Participant_Contact__c,HCP_Contact_HCPEnroll__c,Participant__r.Phone_Type__c, Clinical_Trial_Profile__r.Study_Code_Name__c,' +
            ' PI_Contact__r.Name, Study_Site__r.Name,Participant_Contact__r.Name, Participant__r.First_Name__c,' +
            'Participant__r.Last_Name__c,Participant__r.Middle_Name__c,Participant__r.Contact__c,Participant__r.Suffix__c,' +
            'Participant__r.Nickname__c,Participant__r.Date_of_Birth__c,Participant__r.Gender__c,Participant__r.Email__c,' +
            'Participant__r.Mailing_Country_Code__c,Participant__r.Adult__c,Participant__r.Mailing_State_Code__c,' +
            'Participant__r.Emancipation_in_progress__c,Participant__r.Mailing_Zip_Postal_Code__c,Participant_Status__c,' +
            'Participant__r.Alternative_Phone_Number__c,Participant__r.Alternative_Phone_Type__c,Study_Site__r.Study_Site_Phone__c,' +
            'Study_Site__c,Participant__r.Marketing_Flag__c,Study_Site__r.Study_Site_Type__c,' +
            'Participant__r.IsCountry_NOT_Eligible_for_Emails__c, Participant__r.Fphone__c,' + 
            '(SELECT Id FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1) FROM Participant_Enrollment__c ' +
            ' where id=: peId';

        //}
        system.debug('>>query is>>' + query);

        Participant_Enrollment__c pe = Database.query(query);

        Boolean Userexist;
        List<user> lstUser = new List<user>();
        lstUser = [SELECT id, ContactId FROM user WHERE ContactId = :contactid];
        if (lstUser.size() == 0) {
            Userexist = false;
        } else {
            Userexist = true;
        }
        Particpant_Enrollment_detail objParticpantDetails = new Particpant_Enrollment_detail();
        objParticpantDetails.PE = pe;
        objParticpantDetails.isInvited = Userexist;

        return JSON.serialize(objParticpantDetails);
    }

    public class InitData {
        public ListViewParticipantService.PEFilter peFilter;
        public ListViewParticipantService.PEFilterData peFilterData;
        //public List<PEWrapper> currentPageList;
        public PaginationData paginationData;
        public List<Study_Site__c> ssValue;
        public List<Id> trialIds;
        public Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        public List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        public Boolean isInvited;
    }

    public class SearchResult {
        @TestVisible
        List<PEWrapper> peList;
        @TestVisible
        PaginationData paginationData;
        @TestVisible
        ListViewParticipantService.PEFilter peFilter;
        @TestVisible
        ListViewParticipantService.PEFilterData peFilterData;
    }

    public class PEWrapper {
        public boolean isInvited;
        public Boolean hasEmancipatedParticipants;
        public ParticipantItem pItem;
        public Map<String, StudyActions.Action> actions;
        public List<StudyActions.Action> participantCardActions;
        public List<StudyActions.Action> healthcareProviderActions;

        public PEWrapper(Participant_Enrollment__c pe, Map<String, StudyActions.Action> actions) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
        }
        public PEWrapper(
            Participant_Enrollment__c pe,
            Map<String, StudyActions.Action> actions,
            Boolean isInvited
        ) {
            this.pItem = new ParticipantItem(pe);
            this.actions = actions;
            this.isInvited = isInvited;
            this.hasEmancipatedParticipants = pe.Participant__r != null
                ? pe.Participant__r.Emancipation_in_progress__c
                : false;
        }
    }

    public class Particpant_Enrollment_detail {
        @AuraEnabled
        public Participant_Enrollment__c PE;
        @AuraEnabled
        public Boolean isInvited;
    }

    class InitDataForPatientProfile {
        Participant__c participant;
        List<Participant_Enrollment__c> peList;
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Boolean alreadyEnrolled = false;
    }

    public class ListWrapper {
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String Study { get; set; }
        @AuraEnabled
        public String StudySites { get; set; }
        @AuraEnabled
        public String Source { get; set; }
        @AuraEnabled
        public String Sortby { get; set; }
        @AuraEnabled
        public String ParticipantStatus { get; set; }
        @AuraEnabled
        public String isHighRiskOccupation { get; set; }
        @AuraEnabled
        public String isComorbidities { get; set; }
        @AuraEnabled
        public String isInitialVisitScheduled { get; set; }
        @AuraEnabled
        public String AgeFrom { get; set; }
        @AuraEnabled
        public String AgeTo { get; set; }
        @AuraEnabled
        public String Ethnicity { get; set; }
        @AuraEnabled
        public String Sex { get; set; }
        @AuraEnabled
        public Decimal pageNumber { get; set; }
        @AuraEnabled
        public Decimal pageSize { get; set; }
        @AuraEnabled
        public List<id> SelectedIds { get; set; }
        @AuraEnabled
        public List<id> DeselectedIds { get; set; }
        @AuraEnabled
        public List<id> highPrioritySelected_YesIds { get; set; }
        @AuraEnabled
        public List<id> highPrioritySelected_NoIds { get; set; }
        @AuraEnabled
        public String isExport { get; set; }
        @AuraEnabled
        public Integer startPos { get; set; }
        @AuraEnabled
        public Integer endPos { get; set; }
        @AuraEnabled
        public Integer perRecordCount { get; set; }
    }

    public class PeDataTableWrapper {
        @AuraEnabled
        public Integer pageSize { get; set; }
        @AuraEnabled
        public Integer pageNumber { get; set; }
        @AuraEnabled
        public Integer totalRecords { get; set; }
        @AuraEnabled
        public Integer recordStart { get; set; }
        @AuraEnabled
        public Integer recordEnd { get; set; }
        @AuraEnabled
        public List<Boolean> isChecked { get; set; }
        @AuraEnabled
        public Boolean IsPromoteToSH { get; set; }
        @AuraEnabled
        public set<id> OrginalidSelected { get; set; }
        @AuraEnabled
        public List<WrapPageWithSelection> FilterImpacts { get; set; }
        @AuraEnabled
        public Decimal IsPromoteToSHLimit { get; set; }
        @AuraEnabled
        public ListWrapper retainFilter { get; set; }
        @AuraEnabled
        public Boolean enableSH { get; set; }
        @AuraEnabled
        public Boolean enablePP { get; set; }
        @AuraEnabled
        public Boolean bulkStatusUpdate { get; set; }
    }
    public class WrapPageWithSelection {
        @AuraEnabled
        public Participant_Enrollment__c pe { get; set; }
        @AuraEnabled
        public String initialVisitScheduleTime { get; set; }
        @AuraEnabled
        public Boolean isCheckedlatest { get; set; }
        @AuraEnabled
        public Boolean selectionlock { get; set; }
        @AuraEnabled
        public String priorityReferral { get; set; }
        @AuraEnabled
        public String Ethnicity { get; set; }
        public WrapPageWithSelection(
            Participant_Enrollment__c pe,
            Boolean isCheckedlatest,
            Boolean selectionlock,
            String priorityReferral,
            String Ethnicity,
            String initialVisitScheduleTime
        ) {
            this.pe = pe;
            this.isCheckedlatest = isCheckedlatest;
            this.selectionlock = selectionlock;
            this.priorityReferral = priorityReferral;
            this.Ethnicity = Ethnicity;
            this.initialVisitScheduleTime = initialVisitScheduleTime;
        }
    }
    public class WrapStudySiteList {
        @AuraEnabled
        public List<LabelValueItem> StudySites { get; set; }
        @AuraEnabled
        public Boolean isPromoteToSH { get; set; }
        @AuraEnabled
        public Boolean isInitVisitReqd { get; set; }
    @AuraEnabled
        public List<LabelValueItem> statusFilterData { get; set; }
    }
}