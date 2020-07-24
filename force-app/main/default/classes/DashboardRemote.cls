/**
 * Created by Leonid Bartenev
 */

public without sharing class DashboardRemote {

    public static final String INITIAL_VISIT_SCHEDULED = 'Initial Visit Scheduled';
    
    //Participant Enrollment Status History - Status constants - Added by Sumit Surve
    public static final String PE_STATUS_SUCCESSFULLY_CONTACTED = 'Successfully Contacted';
    public static final String STATUS_SCREENING_PASSED = 'Screening Passed';
    public static final String PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD = 'Screening Passed - Wash Out Period';
    public static final String STATUS_IN_WASH_OUT_PERIOD = 'In Wash Out Period';
    public static final String STATUS_SCREENING_IN_PROGRESS_WASH_OUT = 'Screening In Progress - Wash Out Period';
    public static final String PE_STATUS_SCREENING_FAILED = 'Screening Failed';
    public static final String STATUS_ENROLLMENT_SUCCESS = 'Enrollment Success';
    public static final String STATUS_RANDOMIZATION_SUCCESS = 'Randomization Success';
    public static final String PE_STATUS_ENROLLED = 'Enrolled';
    public static final String PE_STATUS_RANDOMIZED = 'Randomized';
    public static final String PARTICIPANT_WORKFLOW_FINAL_STEP_ENROLLMENT = 'Enrollment';
    public static final String PARTICIPANT_WORKFLOW_FINAL_STEP_RANDOMIZATION = 'Randomization';
    public static final String STATUS_CONTACTED_NOT_SUITABLE = 'Contacted - Not Suitable';
    public static final String STATUS_RECEIVED = 'Received';
    public static final String STATUS_REFERRAL_ACCEPTED = 'Referral Accepted';
    public static final String STATUS_REFERRAL_ON_HOLD = 'Referral On Hold';
    public static final String STATUS_REFERRAL_DECLINED = 'Referral Declined';
    public static final String STATUS_CONTACT_ATTEMPTED = 'Contact Attempted';
    public static final String STATUS_SCREENING_IN_PROGRESS = 'Screening In Progress';
    public static final String STATUS_UNABLE_TO_SCREEN = 'Unable to Screen';
    public static final String STATUS_ENROLLMENT_FAILED = 'Enrollment Failed';
    public static final String STATUS_RANDOMIZATION_FAILED = 'Randomization Failed';
	public static final String STATUS_TREATMENT_PERIOD_STARTED = 'Treatment Period Started';
    public static final String STATUS_FOLLOW_UP_PERIOD_STARTED = 'Follow-Up Period Started';
    public static final String STATUS_PARTICIPATION_COMPLETE = 'Participation Complete';
    public static final String STATUS_TRIAL_COMPLETE = 'Trial Complete';
    public static final String STATUS_DROP_OUT = 'Drop Out';
    public static final String STATUS_DECEASED = 'Deceased';
    public static final String STATUS_READY_TO_SCREEN = 'Ready to Screen';
    public static final String STATUS_DECLINED_FINAL_CONSENT = 'Declined Final Consent';
    public static final String STATUS_DECLINED_CONSENT = 'Declined Consent';
    public static final String STATUS_WITHDREW_CONSENT = 'Withdrew Consent';
    public static final String STATUS_WITHDREW_CONSENT_AFTER_SCREENING = 'Withdrew Consent After Screening';
            
    class PIData {
        List<DonutItem> referralsReceived = new List<DonutItem>();
        List<FunnelData> funnelData;

        Integer waitingToBeContacted;
        List<ListItem> waitingToBeContactedList;
        List<DonutItem> referralsApproved = new List<DonutItem>();

        Integer physiciansWaitingForApproval;
        List<ListItem> physiciansWaitingForApprovalList = new List<ListItem>();
        List<DonutItem> siteRequests = new List<DonutItem>();

        List<BarItem> waitingTimeToContact = new List<BarItem>();

        Integer participantsWaitingContact;
        List<WaitingContactItem> awaitingToContact = new List<WaitingContactItem>();
        
        List<SSRankWrapper> studySiteRank = new List<SSRankWrapper>(); //Added by Sumit Surve 
        List<SSRankWrapper> piStudySiteRank = new List<SSRankWrapper>(); //Added by Sumit Surve

        List<LabelValueItem> delegatePIsPicklist = new List<LabelValueItem>();
        Id selectedPi;

        String selectedPiName;
        
        List<LabelValueItem> piCTPPicklist = new List<LabelValueItem>();
        Id selectedCTP;
        String selectedCTPName;
        Integer currentStudySitesCount;

        Map<String,Map<Id,String>> ContactedParticipantDataList = new Map<String,Map<Id,String>>();
    }

    class FunnelData {
        String statusLabel;
        Integer peInStatus;
        String funnelColor;

        FunnelData(String statusLabel, Integer peInStatus, String funnelColor) {
            this.statusLabel = statusLabel;
            this.peInStatus = peInStatus;
            this.funnelColor = funnelColor;
        }
    }

    class HCPData {
        Integer waitingToBeReferred;
        List<ListItem> waitingToBeReferredList;
        List<DonutItem> referringStatus = new List<DonutItem>();
        List<DonutItem> acceptenceStatus = new List<DonutItem>();
        List<DonutItem> enrollmentStatus = new List<DonutItem>();
    }

    class ListItem {
        Object data;
        Map<String, StudyActions.Action> actions;
        StudyActions.Action action;

        ListItem(Object data, Map<String, StudyActions.Action> actions) {
            this.data = data;
            this.actions = actions;
        }

        ListItem(Object data, StudyActions.Action action) {
            this.data = data;
            this.action = action;
        }
    }

    private static String LEESS_5_DAYS = '<5 Days';
    private static String FROM_6_TO_10_DAYS = '6-10 Days';
    private static String FROM_11_TO_15_DAYS = '11-15 Days';
    private static String FROM_16_TO_20_DAYS = '16-20 Days';
    private static String GREATER_20_DAYS = '>20 Days';

    private static Map<String, String> BarTitleLabelsMap = new Map<String, String>{
            LEESS_5_DAYS => 'PG_DBPI_Days_Less_5',
            FROM_6_TO_10_DAYS => 'PG_DBPI_Days_6_To_10',
            FROM_11_TO_15_DAYS => 'PG_DBPI_Days_11_To_15',
            FROM_16_TO_20_DAYS => 'PG_DBPI_Days_16_To_20',
            GREATER_20_DAYS => 'PG_DBPI_Days_Greater_20'
    };

    class BarItem {
        String color;
        String width;
        String title;
        String count;

        BarItem(String color, String width, String title, String count) {
            this.color = color;
            this.width = width;
            this.title = title;
            this.count = count;
        }
    }

    class WaitingContactItem implements Comparable{
        String Id;
        String name;
        String source;
        String studyName;
        String studyId;
        Integer daysAdded;
        Boolean isAbleToEdit;

        WaitingContactItem(String Id, String name, String source, String studyName, String studyId, Integer daysAdded, Boolean isAbleToEdit) {
            this.Id = Id;
            this.name = name;
            this.source = source;
            this.studyName = studyName;
            this.studyId = studyId;
            this.daysAdded = daysAdded;
            this.isAbleToEdit = isAbleToEdit;
        }

        public Integer compareTo(Object compareTo) {
            WaitingContactItem wci = (WaitingContactItem) compareTo;
            if(daysAdded == wci.daysAdded) return 0;
            if(daysAdded > wci.daysAdded) return -1;
            return 1;
        }
    }
    
    //START added by sumit
    public static Clinical_Trial_Profile__c getCurrentStudy(Id ct) {
        Study_Site__c ss = [Select Id, Name, Principal_Investigator__c, Clinical_Trial_Profile__r.Id, Clinical_Trial_Profile__r.Name , Clinical_Trial_Profile__r.Study_Code_Name__c From Study_Site__c Where Principal_Investigator__c =: ct LIMIT 1];
        return ss.Clinical_Trial_Profile__r;
    }

    
    @AuraEnabled
    public static string getPEEnrollmentsByPI(String eId)
    {
        String filter = ' Participant__c = \'' + eId + '\'';
        List<Participant_Enrollment__c> peList = DatabaseService.query(
                ParticipantEnrollmentService.PE_COMMON_FIELDS,
                Participant_Enrollment__c.getSObjectType(),
                filter
        );
        return JSON.serialize(peList[0]);
    }


    @AuraEnabled
    public static Map<String,Map<Id,String>> getContactedParticipantsData(String principalInvestigatorId,String studyId)
    {
		List<Clinical_Trial_Profile__c> ctp = [SELECT Id,Initial_Visit_Required__c FROM Clinical_Trial_Profile__c WHERE Id=:studyId];
        if(ctp != null && ctp[0].Initial_Visit_Required__c == false)
        { 
            return null;
        }
        else
        {
        	List<Participant_Enrollment__c> pel =[SELECT Id,Initial_visit_scheduled_date__c,(SELECT Id,Status__c,CreatedDate,Date__c  
                                                                                         FROM Participant_Enrollment_Status_History__r 
                                                                                         ORDER BY Name DESC),
                                              Participant_Status__c,PI_Contact__c,Clinical_Trial_Profile__r.Study_Title__c,Participant__c, Participant__r.Full_Name__c
                                              FROM Participant_Enrollment__c WHERE PI_Contact__c = :principalInvestigatorId AND Clinical_Trial_Profile__c =:studyId];
        
            String FROM_1_TO_3_DAYS = '1-3 Days';
            String FROM_4_TO_7_DAYS = '4-7 Days';
            String FROM_8_TO_10_DAYS = '8-10 Days';
            String FROM_11_TO_21_DAYS = '11-21 Days';
            String GREATER_21_DAYS = '>21 Days';
            
            Map<String,Map<Id,String>> daysPatientsStudies = new Map<String,Map<Id,String>>();
            daysPatientsStudies.put(FROM_1_TO_3_DAYS,new Map<Id,String>());
            daysPatientsStudies.put(FROM_4_TO_7_DAYS,new Map<Id,String>());
            daysPatientsStudies.put(FROM_8_TO_10_DAYS,new Map<Id,String>());
            daysPatientsStudies.put(FROM_11_TO_21_DAYS,new Map<Id,String>());
            daysPatientsStudies.put(GREATER_21_DAYS,new Map<Id,String>());
            
            for(Participant_Enrollment__c pe : pel)
            {
                Date today = system.Today();
                Boolean containsSuccessfullyContacted = false;
                Date createdDateforSuccessfullyContacted;
                for(Participant_Enrollment_Status_History__c pesh: pe.Participant_Enrollment_Status_History__r){
                    if(pesh.Status__c == PE_STATUS_SUCCESSFULLY_CONTACTED){
                        containsSuccessfullyContacted = true;
                        createdDateforSuccessfullyContacted = Date.valueOf(pesh.Date__c);
                    }
                }
                if(pe.Participant_Enrollment_Status_History__r.size()>0
                   && (pe.Participant_Enrollment_Status_History__r[0].Status__c == PE_STATUS_SUCCESSFULLY_CONTACTED
                       ||(pe.Participant_Enrollment_Status_History__r[0].Status__c == STATUS_CONTACT_ATTEMPTED
                          && containsSuccessfullyContacted == true
                          ))&& pe.Initial_visit_scheduled_date__c == NULL){
                              Integer daysBetween = 0;
                              if(pe.Participant_Enrollment_Status_History__r[0].Status__c =='Successfully Contacted'){
                                  createdDateforSuccessfullyContacted = Date.valueOf(pe.Participant_Enrollment_Status_History__r[0].Date__c);
                              }
                              daysBetween = createdDateforSuccessfullyContacted.daysBetween(today);
                              
                              String days = null;
                              if (daysBetween <= 3) {
                                  days = FROM_1_TO_3_DAYS;
                              } else if (daysBetween >= 4 && daysBetween <= 7) {
                                  days = FROM_4_TO_7_DAYS;
                              } else if (daysBetween >= 8 && daysBetween <= 10) {
                                  days = FROM_8_TO_10_DAYS;
                              } else if (daysBetween >= 11 && daysBetween <= 21) {
                                  days = FROM_11_TO_21_DAYS;
                              } else if (daysBetween > 21) {
                                  days = GREATER_21_DAYS;
                              }
                              if(days!=null && !daysPatientsStudies.get(days).containsKey(pe.Participant__c)){
                                  if(pe.Participant__c!=null && pe.Participant__r.Full_Name__c !=null)
                                      daysPatientsStudies.get(days).put(pe.Participant__c,pe.Participant__r.Full_Name__c);
                              }
                          }
            }    
            return daysPatientsStudies;
    	}
    }
    
    //TODO Review
    @AuraEnabled
    public static String getInitData(String userMode, String sponsorName, String delegateId, Id piId, Id ctpId, String action) {
        try {
            System.debug('userMode---> :' + userMode + ' delegateId---> : ' + delegateId  + ' piId----> : ' + piId + ' ctpId---> : ' + ctpId);
            if (userMode == CommunityService.USER_MODE_PI) {
                List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
                Contact currentContact = CommunityService.getUserContact();
                System.debug('currentContact---> : '+ currentContact);
                Id currentContactId = currentContact.Id;
                String currentContactName = currentContact.FirstName + ' ' + currentContact.LastName ;
				Map<Id, String> delegatePIsMap = new Map<Id, String>();
			
                PIData piData = new PIData();
                if (![
                        SELECT Id
                        FROM Study_Site__c
                        WHERE Principal_Investigator__c = :currentContactId
                ].isEmpty()) {
                    delegatePIsMap.put(currentContactId, 'Self');

                    if (piId == null) {
                        piData.selectedPi = currentContactId;
                        piData.selectedPiName = currentContactName;
                        piId = currentContactId;
                    }
                }
                
				for (Site_Staff__c sStaff : [
                        SELECT Id,
                                Study_Site__r.Principal_Investigator__c,
                                Study_Site__r.Principal_Investigator__r.Name
                        FROM Site_Staff__c
                        WHERE Site_Contact__c = :currentContactId
                ]) {
                    delegatePIsMap.put(sStaff.Study_Site__r.Principal_Investigator__c, sStaff.Study_Site__r.Principal_Investigator__r.Name);
                }
                System.debug('delegatePIsMap----> ' + delegatePIsMap);
				
				Id pi_Id;
                if(action == 'Init'){
                    if(!delegatePIsMap.isEmpty()){
                        pi_Id = new List<Id>(delegatePIsMap.keySet())[0];
                    }else{
                        pi_Id = piId;
                    }
                }

                if(action == 'PIChange'){
                    pi_Id = piId;
                }    

                //START added by Sumit Surve
                List<Clinical_Trial_Profile__c> related_CTP = new List<Clinical_Trial_Profile__c>();

                // START REF-1903 by Evgenii Prytkov
                //List<Study_Site__c> related_site_sites = [Select Id, Name, Clinical_Trial_Profile__r.Id, Clinical_Trial_Profile__r.Name, Principal_Investigator__c from Study_Site__c WHERE  Principal_Investigator__c =: pi_Id];
                List<Study_Site__c> related_site_sites = [Select Id,
                                                                Name,
                                                                Clinical_Trial_Profile__r.Id,
                                                                Clinical_Trial_Profile__r.Name,
                                                                Clinical_Trial_Profile__r.Study_Sponsor__c,
                                                                Principal_Investigator__c
                                                        from Study_Site__c
                                                        WHERE  Principal_Investigator__c =: pi_Id];
                // END REF-1903 by Evgenii Prytkov

                Set<Id> related_StudyIds = new set<Id>();

                for(Study_Site__c ss : related_site_sites){
                    // START REF-1903 by Evgenii Prytkov
//                    related_StudyIds.add(ss.Clinical_Trial_Profile__r.Id);
                    if(sponsorName == 'Janssen') {
                        if(ss.Clinical_Trial_Profile__r.Study_Sponsor__c == 'Janssen') related_StudyIds.add(ss.Clinical_Trial_Profile__r.Id);
                    } else {
                        if(ss.Clinical_Trial_Profile__r.Study_Sponsor__c != 'Janssen') related_StudyIds.add(ss.Clinical_Trial_Profile__r.Id);
                    }
                    // END REF-1903 by Evgenii Prytkov
                }
                Map<Id, String> piCTPMap = new Map<Id, String>();

                for(Clinical_Trial_Profile__c ctp : [Select Id, Name, Study_Code_Name__c  From Clinical_Trial_Profile__c WHERE Id IN : related_StudyIds ORDER BY Study_Code_Name__c ASC]){
                    piCTPMap.put(ctp.Id, ctp.Study_Code_Name__c);
                } 
                System.debug('piCTPMap : ' +piCTPMap);
                for (Id ctp_Id : piCTPMap.keySet()) {
                    piData.piCTPPicklist.add(new LabelValueItem(piCTPMap.get(ctp_Id), ctp_Id));
                }

                for (Id pId : delegatePIsMap.keySet()) {
                    piData.delegatePIsPicklist.add(new LabelValueItem(delegatePIsMap.get(pId), pId));
                }

                // REF-1903 by Evgenii Prytkov: Added related_StudyIds.size() check
                if (related_StudyIds.size() > 0) {
                    if (ctpId == Null) {
                        piData.selectedCTP = new List<Id>(piCTPMap.keySet())[0];
                        //piData.selectedPiName = currentContactName;
                        ctpId = new List<Id>(piCTPMap.keySet())[0];
                    } else {
                        piData.selectedCTP = ctpId;
                    }

                    for (Site_Staff__c sStaff : [
                            SELECT Id,
                                    Study_Site__r.Principal_Investigator__c,
                                    Study_Site__r.Principal_Investigator__r.Name
                            FROM Site_Staff__c
                            WHERE Site_Contact__c = :currentContactId
                    ]) {
                        delegatePIsMap.put(sStaff.Study_Site__r.Principal_Investigator__c, sStaff.Study_Site__r.Principal_Investigator__r.Name);
                    }

                    if (!delegatePIsMap.isEmpty()) {
                        if (piId == null) {
                            piData.studySiteRank = getStudySiteDetails(new List<Id>(delegatePIsMap.keySet())[0], ctpId);
                            piData.ContactedParticipantDataList = getContactedParticipantsData(new List<Id>(delegatePIsMap.keySet())[0], ctpId);
                            piData.selectedPi = new List<Id>(delegatePIsMap.keySet())[0];
                            piId = piData.selectedPi;
                        } else {
                            piData.studySiteRank = getStudySiteDetails(piId, ctpId);
                            piData.ContactedParticipantDataList = getContactedParticipantsData(piId, ctpId);
                            piData.selectedPi = piId;
                        }
                    } else {
                        if (piId != null) {
                            piData.studySiteRank = getStudySiteDetails(piId, ctpId);
                            piData.ContactedParticipantDataList = getContactedParticipantsData(piId, ctpId);
                            piData.selectedPi = piId;
                        } else {
                            piData.selectedPi = currentContactId;
                            piId = currentContactId;
                        }
                    }

                    piData.currentStudySitesCount = [
                            Select count()
                            FROM Study_Site__c
                            WHERE Clinical_Trial_Profile__r.Id = :ctpId
                    ];

                    peList = ParticipantEnrollmentService.getPEEnrollmentsByPI(userMode, currentContactId);

                    if (peList.isEmpty() && !delegatePIsMap.isEmpty()) {
                        if (piId == null) {
                            peList = ParticipantEnrollmentService.getPEEnrollmentsByPI(userMode, new List<Id>(delegatePIsMap.keySet())[0]);
                            piData.selectedPi = new List<Id>(delegatePIsMap.keySet())[0];
                            piId = piData.selectedPi;
                        } else {
                            peList = ParticipantEnrollmentService.getPEEnrollmentsByPI(userMode, piId);
                            piData.selectedPi = piId;
                        }
                    } else {
                        if (piId != null) {
                            peList = ParticipantEnrollmentService.getPEEnrollmentsByPI(userMode, piId);
                            piData.selectedPi = piId;
                        } else {
                            piData.selectedPi = currentContactId;
                            piId = currentContactId;
                        }
                    }


                    Integer piAccepted = 0;
                    Integer piSuccessContacted = 0;
                    Integer piOnHoldContacted = 0;
                    Integer piDeclineContacted = 0;
                    List<Participant_Enrollment__c> waitingToBeContactedPeList = new List<Participant_Enrollment__c>();
                    List<Participant_Enrollment__c> contactAtemptedList = new List<Participant_Enrollment__c>();
                    for (Participant_Enrollment__c pe : peList) {
                        if (PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS).contains(pe.Participant_Status__c)) {
                            piAccepted += 1;
                        }
                        if (PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS).contains(pe.Participant_Status__c)) {
                            piSuccessContacted += 1;
                        }
                        if (PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS).contains(pe.Participant_Status__c)) {
                            piOnHoldContacted += 1;
                        }
                        if (PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE).contains(pe.Participant_Status__c)) {
                            piDeclineContacted += 1;
                        }
                        if (PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS).contains(pe.Participant_Status__c)) {
                            if (waitingToBeContactedPeList.size() < 4) {
                                waitingToBeContactedPeList.add(pe);
                            }
                        }
                        if (pe.Participant_Status__c == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED || pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                            contactAtemptedList.add(pe);
                        }
                    }
//                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                    //Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS));
//                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
//                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
                    piData.referralsReceived.addAll(new List<DonutItem>{
                            new DonutItem(Label.DI_L_Accepted, piAccepted, DonutItem.Type.SUCCSESS)/*,
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Acceptance_pending, piPending , DonutItem.Type.PENDING)*/
                    });

                    //contact attemts data
                    /*piData.waitingToBeContactedList = preparePEList(
                            ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS), 3), userMode,
                            delegateId
                    );*/
                    piData.waitingToBeContactedList = preparePEList(waitingToBeContactedPeList, userMode, delegateId);
                    Integer piPendingContacted = piAccepted;
                    //Integer piSuccessContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_SUCCESS));
                    //Integer piOnHoldContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS));
                    //Integer piDeclineContacted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE));
                    piData.waitingToBeContacted = piPendingContacted;
                    piData.referralsApproved.addAll(new List<DonutItem>{
                            new DonutItem(Label.DI_L_Accepted, piSuccessContacted, DonutItem.Type.SUCCSESS),
                            new DonutItem(Label.DI_L_On_hold, piOnHoldContacted, DonutItem.Type.ON_HOLD),
                            new DonutItem(Label.DI_L_Declined, piDeclineContacted, DonutItem.Type.DECLINED),
                            new DonutItem(Label.DI_L_Not_yet_contacted, piPendingContacted, DonutItem.Type.PENDING)
                    });

                    //referring clinics data
                    List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsByPI(piId);

                    List<HCP_Enrollment__c> physiciansWaitingForApprovalPEList = new List<HCP_Enrollment__c>();

                    Integer phPending = 0;
                    Integer phDeclined = 0;
                    Integer phActivated = 0;
                    Integer phOnHold = 0;

                    for (HCP_Enrollment__c hcpe : hcpEnrollments) {
                        if (HCPEnrollmentService.STATUS_GROUP_PENDING.contains(hcpe.Status__c)) {
                            if (physiciansWaitingForApprovalPEList.size() < 3) {
                                physiciansWaitingForApprovalPEList.add(hcpe);
                            }
                        }
                        if (HCPEnrollmentService.STATUS_GROUP_PENDING.contains(hcpe.Study__c)) {
                            phPending += 1;
                        }
                        if (HCPEnrollmentService.STATUS_GROUP_DECLINED.contains(hcpe.Study__c)) {
                            phDeclined += 1;
                        }
                        if (HCPEnrollmentService.STATUS_GROUP_ACTIVATED.contains(hcpe.Study__c)) {
                            phActivated += 1;
                        }
                        if (HCPEnrollmentService.STATUS_GROUP_ON_HOLD.contains(hcpe.Study__c)) {
                            phOnHold += 1;
                        }
                    }

                    piData.physiciansWaitingForApprovalList = prepareHCPEList(physiciansWaitingForApprovalPEList, userMode, piId);

                    /*Integer phPending = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_PENDING);
                    Integer phDeclined = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_DECLINED);
                    Integer phActivated = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_ACTIVATED);
                    Integer phOnHold = HCPEnrollmentService.getHCPEnrollmentsCountForPI(HCPEnrollmentService.STATUS_GROUP_ON_HOLD);*/
                    piData.physiciansWaitingForApproval = phPending;
                    piData.siteRequests.addAll(new List<DonutItem>{
                            new DonutItem(Label.DI_L_Activated, phActivated, DonutItem.Type.SUCCSESS),
                            new DonutItem(Label.DI_L_On_hold, phOnHold, DonutItem.Type.ON_HOLD),
                            new DonutItem(Label.DI_L_Declined, phDeclined, DonutItem.Type.DECLINED),
                            new DonutItem(Label.DI_L_Pending_approval_activation, phPending, DonutItem.Type.PENDING)
                    });

                    // waiting contact in days
                    piData.waitingTimeToContact = prepareWaitingList(userMode, delegateId, piId, ctpId);

                    // awaiting contact
                    piData.awaitingToContact = prepareAwaitingContactList(userMode, delegateId, contactAtemptedList, piId, ctpId);
                    piData.participantsWaitingContact = piData.awaitingToContact.size();

                    piData.funnelData = prepareDataForFunnelChart(piId, ctpId);

                } else {
                    piData.selectedCTP = null;
                }

                return JSON.serialize(piData);

            } else if (userMode == CommunityService.USER_MODE_HCP) {
                HCPData hcpData = new HCPData();
                hcpData.waitingToBeReferred = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL, delegateId);
                hcpData.waitingToBeReferredList = preparePEList(
                        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{
                                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
                        }, 3, delegateId), userMode,
                        delegateId
                );
                //Referring status:
                Integer passedReviewAndReffered = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String>(PEStatusState.ALL_USED_STATUSES), delegateId);
                Integer passedReviewNotYetReferred = hcpData.waitingToBeReferred;
                Integer failedReview = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW, delegateId);
                hcpData.referringStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Passed_review_and_referred, passedReviewAndReffered, DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_Passed_review_and_not_yet_referred, passedReviewNotYetReferred, DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Failed_review, failedReview, DonutItem.Type.DECLINED)
                });

                //Acceptance statuses
//                Integer piPending = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS), delegateId);
                Integer piAccepted = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS), delegateId);
//                Integer piOnHold = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_IN_PROGRESS), delegateId);
//                Integer piDeclined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUS_STEPS_TABLE[1].states.get(PEStatusState.STATUS_STATE_FAILURE), delegateId);
                hcpData.acceptenceStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Accepted, piAccepted, DonutItem.Type.SUCCSESS)/*,
                        new DonutItem(Label.DI_L_On_hold, piOnHold , DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Declined, piDeclined , DonutItem.Type.DECLINED),
                        new DonutItem(Label.DI_L_Approval_pending, piPending , DonutItem.Type.PENDING)*/
                });

                //Enrollment status
                Integer enrolledRandomized = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_ENROLLED, delegateId);
                Integer inProgress = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_IN_PROGRESS, delegateId);
                Integer declined = ParticipantEnrollmentService.getPEnrolmentsCount(userMode, PEStatusState.STATUSES_FAILED, delegateId);
                hcpData.enrollmentStatus.addAll(new List<DonutItem>{
                        new DonutItem(Label.DI_L_Enrolled_randomized, enrolledRandomized, DonutItem.Type.SUCCSESS),
                        new DonutItem(Label.DI_L_In_progress, inProgress, DonutItem.Type.ON_HOLD),
                        new DonutItem(Label.DI_L_Failed_enrollment, declined, DonutItem.Type.DECLINED)
                });

                return JSON.serialize(hcpData);
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String acceptPE(Id peId) {
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Id = peId,
                Participant_Status_Last_Changed_Date__c = Datetime.now(),
                Participant_Status__c = PEStatusState.STATUS_STEPS_TABLE[0].states.get(PEStatusState.STATUS_STATE_SUCCESS)[0]
        );
        upsert pe;
        return getInitData(CommunityService.USER_MODE_PI, null, null, peId, null, 'Init');
    }

    @AuraEnabled
    public static String getParticipantData(String userMode, String delegateId, String participantId) {
        System.debug('participantId => ' + participantId);
        ViewPatientsRemote.InitData initData = new ViewPatientsRemote.InitData();
        initData.peStatusStateMap = PEStatusState.STATUSES_MAP;
        initData.peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        Id participantContactId = [
                SELECT Contact__c
                FROM Participant__c
                WHERE Id = :participantId
        ].Contact__c;
        initData.isInvited = ![
                SELECT Id
                FROM User
                WHERE ContactId = :participantContactId
        ].isEmpty();


        List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{
                                PEStatusState.PE_STATUS_CONTACT_ATTEMPTED, PEStatusState.PE_STATUS_RECEIVED
                        },
                        null,
                        delegateId);
        for (Participant_Enrollment__c pe : pes) {
            if (pe.Participant__c == participantId) {
                initData.currentPageList = new List<ViewPatientsRemote.PEWrapper>{
                        new ViewPatientsRemote.PEWrapper(pe, new StudyActionsPI(pe).actions)
                };
            }
        }
        return JSON.serialize(initData);
    }

    private static List<ListItem> prepareHCPEList(List<HCP_Enrollment__c> hcpeList, String userMode, Id piId) {
        List<ListItem> resList = new List<ListItem>();
        Id currentUserId = CommunityService.getInstance().getCurrentContactId();
        Set<Id> avaliableIds = new Set<Id>();
        if (piId != currentUserId) {
            Set<Id> ssId = new Set<Id>();
            for (HCP_Enrollment__c hcpe : hcpeList) {
                ssId.add(hcpe.Study_Site__c);
            }
            for (Site_Staff__c ssStaff : [
                    SELECT Id,
                            Study_Site__c
                    FROM Site_Staff__c
                    WHERE Study_Site__c IN :ssId AND Site_Contact__c = :currentUserId AND Delegate_Level__c = 'Level 1'
            ]) {
                avaliableIds.add(ssStaff.Study_Site__c);
            }
        }
        for (HCP_Enrollment__c hcpe : hcpeList) {
            if (avaliableIds.isEmpty() && piId == currentUserId) {
                Map<String, StudyActions.Action> actions = new StudyActionsPI(hcpe).actions;
                Set<String> actionIds = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpe.Status__c).keySet();
                for (String actionId : actionIds) {
                    StudyActions.Action action = actions.get(actionId);
                    if (action.cssClass == 'green') {
                        resList.add(new ListItem(hcpe, action));
                        break;
                    }
                }
            } else {
                if (avaliableIds.contains(hcpe.Study_Site__c) && piId != currentUserId) {
                    Map<String, StudyActions.Action> actions = new StudyActionsPI(hcpe).actions;
                    Set<String> actionIds = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpe.Status__c).keySet();
                    for (String actionId : actionIds) {
                        StudyActions.Action action = actions.get(actionId);
                        if (action.cssClass == 'green') {
                            resList.add(new ListItem(hcpe, action));
                            break;
                        }
                    }
                }
            }
        }
        return resList;
    }

    private static List<ListItem> preparePEList(List<Participant_Enrollment__c> peList, String userMode, String delegateId) {
        List<ListItem> resList = new List<ListItem>();
        for (Participant_Enrollment__c pe : peList) {
            StudyActions studyActions;
            if (userMode == CommunityService.USER_MODE_HCP) {
                studyActions = new StudyActionsHCP(pe, delegateId);
            } else {
                studyActions = new StudyActionsPI(pe);
            }
            resList.add(new ListItem(pe, studyActions.actions));
        }
        return resList;
    }

    private static List<BarItem> prepareWaitingList(String userMode, String delegateId, String piId, String ctpId) {
        List<BarItem> resList = new List<BarItem>();

        /*List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{ PEStatusState.PE_STATUS_RECEIVED },
                        null,
                        delegateId);*/
        //Map<Id, Participant_Enrollment__c> peById = new Map<Id, Participant_Enrollment__c>(receivedPE);

        List<Participant_Enrollment_Status_History__c> peSHs = [
                SELECT Id,
                        CreatedDate,
                        Date__c,
                        ParticipantEnrollment__c,
                        Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN (
                        SELECT Id
                        FROM Participant_Enrollment__c
                        WHERE(Study_Site__r.Principal_Investigator__c = :piId
                        AND  Clinical_Trial_Profile__c =: ctpId)
                ) AND
                Status__c IN :(new List<String>{
                        PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED,
                        PEStatusState.PE_STATUS_RECEIVED
                })
                ORDER BY CreatedDate DESC
        ];
        Map<Id, Participant_Enrollment_Status_History__c> receivedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
        Map<Id, Participant_Enrollment_Status_History__c> contactedPESHsByPIId = new Map<Id, Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment_Status_History__c peSH : peSHs) {
            if (peSH.Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                receivedPESHsByPIId.put(peSH.ParticipantEnrollment__c, peSH);
            } else {
                contactedPESHsByPIId.put(peSH.ParticipantEnrollment__c, peSH);
            }
        }

        Integer maxParticipantsInDays = 0;
        String daysMaxParticipantsInDays = null;
        Set<Id> peIdsProcessed = new Set<Id>();
        Map<String, List<Participant_Enrollment_Status_History__c>> peSHByDays = new Map<String, List<Participant_Enrollment_Status_History__c>>{
                LEESS_5_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_6_TO_10_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_11_TO_15_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                FROM_16_TO_20_DAYS => new List<Participant_Enrollment_Status_History__c>(),
                GREATER_20_DAYS => new List<Participant_Enrollment_Status_History__c>()
        };
        for (Participant_Enrollment_Status_History__c peSH : receivedPESHsByPIId.values()) {
            if (!peIdsProcessed.contains(peSH.ParticipantEnrollment__c)) {
                Participant_Enrollment_Status_History__c contactedPESH = contactedPESHsByPIId.get(peSH.ParticipantEnrollment__c);

                if (contactedPESH != null) {
                    Integer daysBetween;
                    if (peSH.Date__c != null && contactedPESH.Date__c != null) {
                        daysBetween = peSH.Date__c.date().daysBetween(contactedPESH.Date__c.date());
                    } else {
                        daysBetween = peSH.CreatedDate.date().daysBetween(contactedPESH.CreatedDate.date());
                    }

                    String days = null;
                    if (daysBetween <= 5) {
                        days = LEESS_5_DAYS;
                    } else if (daysBetween >= 6 && daysBetween <= 10) {
                        days = FROM_6_TO_10_DAYS;
                    } else if (daysBetween >= 11 && daysBetween <= 15) {
                        days = FROM_11_TO_15_DAYS;
                    } else if (daysBetween >= 16 && daysBetween <= 20) {
                        days = FROM_16_TO_20_DAYS;
                    } else if (daysBetween > 20) {
                        days = GREATER_20_DAYS;
                    }

                    List<Participant_Enrollment_Status_History__c> peSHDay = peSHByDays.get(days);
                    if (peSHDay == null) {
                        peSHDay = new List<Participant_Enrollment_Status_History__c>();
                        peSHByDays.put(days, peSHDay);
                    }

                    peSHDay.add(peSH);
                    if (maxParticipantsInDays < peSHDay.size()) {
                        maxParticipantsInDays = peSHDay.size();
                        daysMaxParticipantsInDays = days;
                    }
                }
            }
        }

        // 70% width is maxParticipantsInDays
        resList.add(prepareBarItem('#D8EBF7', LEESS_5_DAYS, peSHByDays.get(LEESS_5_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#B8DDF6', FROM_6_TO_10_DAYS, peSHByDays.get(FROM_6_TO_10_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#83C7F4', FROM_11_TO_15_DAYS, peSHByDays.get(FROM_11_TO_15_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#3D9BD9', FROM_16_TO_20_DAYS, peSHByDays.get(FROM_16_TO_20_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));
        resList.add(prepareBarItem('#136BA6', GREATER_20_DAYS, peSHByDays.get(GREATER_20_DAYS).size(), maxParticipantsInDays, daysMaxParticipantsInDays));

        return resList;
    }

    private static List<FunnelData> prepareDataForFunnelChart(Id piId, Id ctpId) {
        List<FunnelData> returnData = new List<FunnelData>();
        Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>();
        List<Participant_Enrollment__c> peList = (List<Participant_Enrollment__c>) DatabaseService.query(
                ParticipantEnrollmentService.PE_COMMON_FIELDS,
                Participant_Enrollment__c.getSObjectType(),
                ' Study_Site__c != NULL AND Study_Site__r.Principal_Investigator__c = \'' + piId + '\' AND Clinical_Trial_Profile__c = \'' + ctpId + '\''
        );
        /*for(Participant_Enrollment__c pe : (List<Participant_Enrollment__c>) DatabaseService.query(
                ParticipantEnrollmentService.PE_COMMON_FIELDS,
                Participant_Enrollment__c.getSObjectType(),
                ' Study_Site__c != NULL AND PI_Contact__c = \'' + CommunityService.getInstance().getCurrentContactId() +'\''
        )){*/
        for (Participant_Enrollment__c pe : peList) {
            peMap.put(pe.Id, pe);
        }
        List<Participant_Enrollment_Status_History__c> peHostoryList = [
                Select Id,
                        Status__c,
                        ParticipantEnrollment__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN :peMap.keySet()
        ];
        if (!peHostoryList.isEmpty()) {
            Set<Id> receivedStatusSet = new Set<Id>();
            Set<Id> successfullyContactedSet = new Set<Id>();
            Set<Id> initialVisitScheduledSet = new Set<Id>();
            Set<Id> screeningPassedSet = new Set<Id>();
            Set<Id> enrolledOrRandomizedSet = new Set<Id>();
            Set<Id> eligibilityPassedSet = new Set<Id>();

            for (Participant_Enrollment_Status_History__c pesh : peHostoryList) {
                if (pesh.Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                    receivedStatusSet.add(pesh.ParticipantEnrollment__c);
                }
                if (pesh.Status__c == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED) {
                    successfullyContactedSet.add(pesh.ParticipantEnrollment__c);
                }
                if ((peMap.get(pesh.ParticipantEnrollment__c).Initial_visit_scheduled_flag__c || peMap.get(pesh.ParticipantEnrollment__c).Initial_visit_occurred_flag__c) && peMap.get(peHostoryList[0].ParticipantEnrollment__c).Study_Site__r.Study_Site_Type__c != 'Virtual') {
                    initialVisitScheduledSet.add(pesh.ParticipantEnrollment__c);
                } else if (pesh.Status__c == PEStatusState.PE_STATUS_ELIGIBILITY_PASSED && peMap.get(peHostoryList[0].ParticipantEnrollment__c).Study_Site__r.Study_Site_Type__c == 'Virtual') {
                    eligibilityPassedSet.add(pesh.ParticipantEnrollment__c);
                }
                if (pesh.Status__c == PEStatusState.PE_STATUS_SCREENING_PASSED || pesh.Status__c == PEStatusState.PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD) {
                    screeningPassedSet.add(pesh.ParticipantEnrollment__c);
                }
                if (pesh.Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS || pesh.Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) {
                    enrolledOrRandomizedSet.add(pesh.ParticipantEnrollment__c);
                }
            }
            returnData.add(new FunnelData(Label.Received, receivedStatusSet.size(), '#3DC2FA'));
            returnData.add(new FunnelData(Label.Successfully_Contacted, successfullyContactedSet.size(), '#9914E6'));
            returnData.add(new FunnelData(peMap.get(peHostoryList[0].ParticipantEnrollment__c).Study_Site__r.Study_Site_Type__c != 'Virtual' ?
                    Label.Initial_Visit_Scheduled : Label.Eligibility_Passed,
                    peMap.get(peHostoryList[0].ParticipantEnrollment__c).Study_Site__r.Study_Site_Type__c != 'Virtual' ?
                            initialVisitScheduledSet.size() : eligibilityPassedSet.size(), '#D892FF'));
            returnData.add(new FunnelData(Label.Screening_Passed, screeningPassedSet.size(), '#139458'));
            returnData.add(new FunnelData(Label.Enrolled_Or_Randomized, enrolledOrRandomizedSet.size(), '#7AFFD3'));
        }

        return returnData;
    }

    private static BarItem prepareBarItem(String color, String title, Integer count, Integer maxPInD, String maxD) {
        String width = title == maxD ? '70%' : count != 0 ? '' + Math.Round(70 / Math.Round(maxPInD / count)) + '%' : '1%';
        return new BarItem(color, width, TranslateHelper.getLabelValue(BarTitleLabelsMap.get(title)), '' + count);
    }

    private static List<WaitingContactItem> prepareAwaitingContactList(String userMode, String delegateId, List<Participant_Enrollment__c> contactAtemptedList, Id piId, String ctpId) {
        List<WaitingContactItem> resList = new List<WaitingContactItem>();
        Id currentContactId = CommunityService.getInstance().getCurrentContactId();
        List<Participant_Enrollment__c> contactAttempted = new List<Participant_Enrollment__c>();
        Set<Id> avaliableSS = new Set<Id>();
        if (piId != currentContactId) {
            Set<Id> ssId = new Set<Id>();
            
            for (Participant_Enrollment__c pe : contactAtemptedList) {
                    ssId.add(pe.Study_Site__c);
            }
                       
            for (Site_Staff__c sstaff : [
                    SELECT Id,
                            Study_Site__c, 
                            Study_Site__r.Clinical_Trial_Profile__c
                    FROM Site_Staff__c
                    WHERE Study_Site__c IN :ssId AND Site_Contact__c = :currentContactId
            ]) {
                //if(sstaff.Study_Site__r.Clinical_Trial_Profile__c == ctpId){
                    avaliableSS.add(sstaff.Study_Site__c);
                //}    
            }
        }

        /*List<Participant_Enrollment__c> pes =
                ParticipantEnrollmentService.getPEnrolmentsByStatus(
                        userMode,
                        new List<String>{ PEStatusState.PE_STATUS_CONTACT_ATTEMPTED, PEStatusState.PE_STATUS_RECEIVED },
                        null,
                        delegateId);*/
        for (Participant_Enrollment__c pe : contactAtemptedList) {
            if(pe.Study_Site__r.Clinical_Trial_Profile__c == ctpId){
                if(avaliableSS.isEmpty()) {
                    Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                    resList.add(new WaitingContactItem(pe.Participant__c, pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c, TranslateHelper.getPickListLabel(Participant_Enrollment__c.Source_Type__c, pe.Source_Type__c), pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, pe.Study_Site__r.Clinical_Trial_Profile__c, daysAdded, true));
                }else{
                    if(avaliableSS.contains(pe.Study_Site__c)){
                        Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                        resList.add(new WaitingContactItem(pe.Participant__c, pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c, TranslateHelper.getPickListLabel(Participant_Enrollment__c.Source_Type__c, pe.Source_Type__c), pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, pe.Study_Site__r.Clinical_Trial_Profile__c, daysAdded, true));
                    } else {
                        Integer daysAdded = pe.CreatedDate.date().daysBetween(System.today());
                        resList.add(new WaitingContactItem(pe.Participant__c, pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c, TranslateHelper.getPickListLabel(Participant_Enrollment__c.Source_Type__c, pe.Source_Type__c), pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, pe.Study_Site__r.Clinical_Trial_Profile__c, daysAdded, false));
                    }
                }
            }    
        }
    resList.sort();
    return resList;
}


/*SSRankWrapper
Created by : Sumit Surve
Version 1.0
This class is used as a server side controller
SSRankWrapper - Inner class */

    class SSRankWrapper implements Comparable{
        Integer rank;
        String site_Number;
        String site_Name;
        String location;
        Integer initial_Visits_Completed;
        Integer contacted;
        Integer scheduled;
        Integer screened;
        Integer enrolled_randomized;
        String is_enrolled_randomized; 
        String piName;
        String pi_Id;
        String studyName;

        //SSRankWrapper Constructor
        SSRankWrapper(String site_Number, String site_Name, String location, Integer initial_Visits_Completed, Integer contacted, Integer scheduled, Integer screened, Integer enrolled_randomized, String is_enrolled_randomized, String piName, Id pi_Id, String studyName){
            this.site_Number = site_Number;
            this.site_Name = site_Name; 
            this.location = location;
            this.initial_Visits_Completed = initial_Visits_Completed;
            this.contacted = contacted;
            this.scheduled = scheduled;
            this.screened = screened;
            this.enrolled_randomized = enrolled_randomized;
            this.is_enrolled_randomized = is_enrolled_randomized;
            this.piName = piName;
            this.pi_Id = pi_Id;
            this.studyName = studyName;
        }

        public Integer compareTo(Object obj) {
            SSRankWrapper ssSiteRank = (SSRankWrapper) obj;
            if (this.initial_Visits_Completed < ssSiteRank.initial_Visits_Completed) return 1;
            if (this.initial_Visits_Completed == ssSiteRank.initial_Visits_Completed) return 0;
            return -1;
        } 
    }

    //This method is used to set rank for the study sites
    public static List<SSRankWrapper> setRank(List<SSRankWrapper> ssRankWrapperlist) {
        Integer rank = 1;
        List<SSRankWrapper> setRankList =  new List<SSRankWrapper>();
        try{
            if(ssRankWrapperlist!=null && !ssRankWrapperlist.isEmpty()){
                for(SSRankWrapper ssrw : ssRankWrapperlist){
                    ssrw.rank = rank++;
                    setRankList.add(ssrw);
                }
                for(Integer index=0; index<setRankList.size(); index++){
                    if(index<setRankList.size()-1 && (setRankList.get(index).initial_Visits_Completed == setRankList.get(index+1).initial_Visits_Completed)){
                        setRankList.get(index+1).rank = setRankList.get(index).rank;
                    }
                }
            }    
        }catch(Exception e){
             System.debug('The following exception has occurred: ' + e.getMessage());
        }  
        return setRankList;  
    }
        
    //This mesthod is used to get Name of the selected PI
    public static String getPIName(Id pIid){
        Contact c;
        try{
            c = [Select Id, Name From Contact WHERE Id =: pIid LIMIT 1];
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }    
        return c.Name;
    }
    
    //This method used to get name of the selected Study
    public static String getStudyName(Id studyid){
        Clinical_Trial_Profile__c ctp;
        try{
            ctp = [Select Id, Study_Code_Name__c FROM Clinical_Trial_Profile__c WHERE Id =: studyid];
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
        return ctp.Study_Code_Name__c;
    }
    
    //This method is used to fetch study site details
    private static List<SSRankWrapper> getStudySiteDetails(Id pIid, Id studyid)
    {
        List<SSRankWrapper> ssRankWrapperlist = new List<SSRankWrapper>();
        List<SSRankWrapper> result = new List<SSRankWrapper>();
        String piName = getPIName(pIid);
        String studyName = getStudyName(studyid);

        List<Study_Site__c> studySites = [SELECT Id, Study_Site_Number__c, Name, Site__r.BillingCountry, Principal_Investigator__c, Clinical_Trial_Profile__r.Id, Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c FROM Study_Site__c WHERE Clinical_Trial_Profile__r.Id =: studyid ORDER BY Study_Site_Number__c ASC NULLS LAST];
        List<Participant_Enrollment__c> peList =  [SELECT Id, Initial_visit_scheduled_date__c, Participant_Status__c,Name, Initial_visit_scheduled_flag__c, Initial_visit_occurred_flag__c, Study_Site__r.Id, Study_Site__r.Name, Randomized__c, Enrolled__c FROM Participant_Enrollment__c WHERE Study_Site__r.Id IN : studySites];
        
        try{
            if(studySites!=null && !studySites.isEmpty()){
                for(Study_Site__c ss : studySites){
                    Integer rank = 1;
                    String site_Number;
                    String site_Name;
                    String location;
                    Integer initial_Visits_Completed = 0;
                    Integer contacted = 0;
                    Integer scheduled = 0;
                    Integer screened = 0;
                    Integer enrolled_randomized = 0;
                    String is_enrolled_randomized;
                    Integer received = 0;
                    //String piName;
                    Id pi_Id;
                    //String studyName;
                    
                    site_Number = ss.Study_Site_Number__c;
                    site_Name = ss.Name;

                    //piName = getPIName(pIid);
                    pi_Id = ss.Principal_Investigator__c;
                    //studyName = getStudyName(studyid);
                    location = ss.Site__r.BillingCountry;
                    if(peList != null && !peList.isEmpty()){
                        for(Participant_Enrollment__c pe : peList){
                            if(pe.Study_Site__c == ss.Id){
                                if(ss.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == PARTICIPANT_WORKFLOW_FINAL_STEP_ENROLLMENT){
                                    is_enrolled_randomized = PE_STATUS_ENROLLED;
                                }
                                if(ss.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == PARTICIPANT_WORKFLOW_FINAL_STEP_RANDOMIZATION){
                                    is_enrolled_randomized = PE_STATUS_RANDOMIZED;
                                }
                                
                                if(pe.Initial_visit_scheduled_date__c == null &&
                                (pe.Participant_Status__c == PE_STATUS_SUCCESSFULLY_CONTACTED ||
                                pe.Participant_Status__c == STATUS_CONTACTED_NOT_SUITABLE)){
                                    contacted++;
                                }else if(pe.Initial_visit_scheduled_date__c != null &&
                                pe.Initial_visit_occurred_flag__c == FALSE &&
                                (pe.Participant_Status__c == PE_STATUS_SUCCESSFULLY_CONTACTED ||
                                pe.Participant_Status__c == STATUS_CONTACT_ATTEMPTED ||
                                pe.Participant_Status__c == PE_STATUS_SCREENING_FAILED ||
                                pe.Participant_Status__c == STATUS_SCREENING_IN_PROGRESS ||
                                pe.Participant_Status__c == STATUS_UNABLE_TO_SCREEN
                                )){
                                    contacted++;
                                    scheduled++;
                                }
                                
                                if(pe.Initial_visit_occurred_flag__c == TRUE)
                                {
                                    if(pe.Participant_Status__c == PE_STATUS_SUCCESSFULLY_CONTACTED ||
                                        pe.Participant_Status__c == STATUS_CONTACT_ATTEMPTED){
                                        contacted++;
                                        scheduled++;
                                        initial_Visits_Completed++;
                                    }else if(pe.Participant_Status__c == PE_STATUS_SCREENING_FAILED ||
                                        pe.Participant_Status__c == STATUS_SCREENING_IN_PROGRESS ||
                                        pe.Participant_Status__c == STATUS_UNABLE_TO_SCREEN ||
                                        pe.Participant_Status__c == STATUS_READY_TO_SCREEN ||
                                        pe.Participant_Status__c == PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD ||
                                        pe.Participant_Status__c == STATUS_IN_WASH_OUT_PERIOD ||
                                        pe.Participant_Status__c == STATUS_SCREENING_IN_PROGRESS_WASH_OUT ||
                                        pe.Participant_Status__c == STATUS_DECLINED_CONSENT ||
                                        pe.Participant_Status__c == STATUS_WITHDREW_CONSENT){
                                            contacted++;
                                            scheduled++;
                                            initial_Visits_Completed++;
                                    }else if(
                                        pe.Participant_Status__c == STATUS_SCREENING_PASSED ||
                                        pe.Participant_Status__c == STATUS_DECLINED_FINAL_CONSENT ||
                                        pe.Participant_Status__c == STATUS_WITHDREW_CONSENT_AFTER_SCREENING){
                                        contacted++;
                                        scheduled++;
                                        screened++;
                                        initial_Visits_Completed++;
                                    }
                                }
                                
                                if(pe.Participant_Status__c == STATUS_ENROLLMENT_SUCCESS ||
                                pe.Participant_Status__c == STATUS_RANDOMIZATION_SUCCESS ||
                                pe.Participant_Status__c == STATUS_TREATMENT_PERIOD_STARTED ||
                                pe.Participant_Status__c == STATUS_FOLLOW_UP_PERIOD_STARTED ||
                                pe.Participant_Status__c == STATUS_PARTICIPATION_COMPLETE ||
                                pe.Participant_Status__c == STATUS_TRIAL_COMPLETE ||
                                pe.Participant_Status__c == STATUS_DROP_OUT ||
                                pe.Participant_Status__c == STATUS_DECEASED){
                                    contacted++;
                                    scheduled++;
                                    screened++;
                                    initial_Visits_Completed++;
                                    enrolled_randomized++;
                                }else if(pe.Participant_Status__c == STATUS_ENROLLMENT_FAILED ||
                                        pe.Participant_Status__c == STATUS_RANDOMIZATION_FAILED){
                                    contacted++;
                                    scheduled++;
                                    screened++;
                                    initial_Visits_Completed++;
                                }
                                
                                
                                if(pe.Participant_Status__c == STATUS_RECEIVED ||
                                pe.Participant_Status__c == STATUS_REFERRAL_ACCEPTED ||
                                pe.Participant_Status__c == STATUS_REFERRAL_ON_HOLD ||
                                pe.Participant_Status__c == STATUS_REFERRAL_DECLINED){
                                    received++;
                                }

                                /*
                                //Contacted
                                if((pe.Initial_visit_scheduled_flag__c == TRUE &&
                                pe.Initial_visit_occurred_flag__c == TRUE) &&
                                (pehstatus.contains(PE_STATUS_SUCCESSFULLY_CONTACTED) ||
                                pehstatus.contains(STATUS_SCREENING_PASSED) ||
                                pehstatus.contains(PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD) ||
                                pehstatus.contains(PE_STATUS_SCREENING_FAILED) ||
                                (pehstatus.contains(STATUS_ENROLLMENT_SUCCESS) ||
                                pehstatus.contains(STATUS_RANDOMIZATION_SUCCESS)))){
                                    contacted++;
                                }
                                //Scheduled
                                if((pe.Initial_visit_scheduled_flag__c == TRUE &&
                                pe.Initial_visit_occurred_flag__c == TRUE) &&(
                                pehstatus.contains(STATUS_SCREENING_PASSED) ||
                                pehstatus.contains(PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD) ||
                                pehstatus.contains(PE_STATUS_SCREENING_FAILED) ||
                                (pehstatus.contains(STATUS_ENROLLMENT_SUCCESS) ||
                                pehstatus.contains(STATUS_RANDOMIZATION_SUCCESS)))){
                                    scheduled++;
                                }

                                //Initial Visits Completed
                                if((pe.Initial_visit_occurred_flag__c == TRUE) &&
                                (pehstatus.contains(STATUS_SCREENING_PASSED) ||
                                pehstatus.contains(PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD) ||
                                pehstatus.contains(PE_STATUS_SCREENING_FAILED) ||
                                (pehstatus.contains(STATUS_ENROLLMENT_SUCCESS) ||
                                pehstatus.contains(STATUS_RANDOMIZATION_SUCCESS)))){
                                    initial_Visits_Completed++;
                                    System.debug('completed--->' + initial_Visits_Completed);
                                    System.debug('Referal ID---> ' + pe.Name);
                                }

                                //Screened
                                if(pehstatus.contains(STATUS_SCREENING_PASSED) ||
                                pehstatus.contains(PE_STATUS_SCREENING_PASSED_WASH_OUT_PERIOD) ||
                                pehstatus.contains(PE_STATUS_SCREENING_FAILED) ||
                                (pehstatus.contains(STATUS_ENROLLMENT_SUCCESS) ||
                                pehstatus.contains(STATUS_RANDOMIZATION_SUCCESS))){
                                    screened++;
                                }

                                //Enrolled/Randomized
                                if(pehstatus.contains(STATUS_ENROLLMENT_SUCCESS) ||
                                pehstatus.contains(STATUS_RANDOMIZATION_SUCCESS)){
                                    enrolled_randomized++;
                                }
                                */
                            }    
                        }
                    }   
                    ssRankWrapperlist.add(new SSRankWrapper(site_Number, site_Name, location, initial_Visits_Completed, contacted, scheduled, screened, enrolled_randomized, is_enrolled_randomized, piName, pi_Id, studyName));
                }
            }    
            ssRankWrapperlist.sort();
            result = setRank(ssRankWrapperlist);
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }    
        return result;  
    }
}