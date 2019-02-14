/**
 * Created by Leonid Bartenev
 */

public without sharing class ReferringRemote {


    public class InitData{
        public Clinical_Trial_Profile__c trial;
        public HCP_Enrollment__c hcpEnrollment;
        public Participant_Enrollment__c participantEnrollment;
        public List<Participant_Enrollment__c> pendingPEnrollments;
        public List<AccountWrapper> studies;
        public Map<String, StudyActions.Action> actions;
        public List<LabelValueItem> countries;
        public Map<String, List<LabelValueItem>> statesByCountryMap;
    }

    public class AccountWrapper{
        public Account clinic;
        public String name;
        public String addrStreet;
        public String addrCity;
    }

    @AuraEnabled
    public static String getInitData(Id trialId, Id peId, String userMode){
        try{
            InitData initData = new InitData();
            initData.trial = TrialService.getTrial(trialId);
            //localize pes
            if(initData.trial.Link_to_Pre_screening__c != null){
                initData.trial.Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(initData.trial.Link_to_Pre_screening__c);
            }
            initData.hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
            new StudyActionsHCP(initData.hcpEnrollment).checkAction(StudyActions.ACT_REFER_TO_THIS_STUDY);
            initData.actions = new StudyActionsHCP(initData.hcpEnrollment).actions;
            if(peId != null) {
                initData.participantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(peId, userMode);
            }else if (initData.trial.Link_to_Medical_Record_Review__c == null){
                initData.participantEnrollment = ParticipantEnrollmentService.createParticipantEnrollment(initData.trial, initData.hcpEnrollment, null);
            }
            if(initData.trial.Link_to_Medical_Record_Review__c != null) {
                initData.pendingPEnrollments = ParticipantEnrollmentService.getPendingParticipantEnrollments(initData.hcpEnrollment.Id);
            }
            initData.studies = new List<AccountWrapper>();
            Account site = [
                    SELECT Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, Phone,
                            BillingLongitude, BillingLatitude
                    FROM Account
                    WHERE Id =: initData.hcpEnrollment.Study_Site__r.Site__c
            ];
            AccountWrapper aw = new AccountWrapper();
            aw.name = initData.hcpEnrollment.Study_Site__r.Name;
            aw.addrStreet = site.BillingStreet;
            aw.addrCity = getCityString(site);
            aw.clinic = site;
            initData.studies.add(aw);
            initData.countries = CountryStateUtil.getCountries();
            initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
            return JSON.serialize(initData);
        }catch (Exception e){
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void saveParticipant(Id trialId, String pEnrollmentJSON, String participantJSON){
        Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
        HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
        Participant_Enrollment__c participantEnrollment = (Participant_Enrollment__c)JSON.deserialize(pEnrollmentJSON, Participant_Enrollment__c.class);
        participantEnrollment.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI;
        if(participantEnrollment.Pre_screening_Status__c == ParticipantEnrollmentService.PES_STATUS_PENDING){
            participantEnrollment.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_PASS;
        }

        Database.SaveResult saveResult = Database.insert(participant, false);
        if (!saveResult.isSuccess()) {
            System.debug('PARTICIPANT INSERT ERROR');
            for (Database.Error error : saveResult.getErrors()) {
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    List<SObject> duplicateRecords = new List<SObject>();
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        participant = (Participant__c) matchRecord.getRecord();
                        System.debug('FOUND PART DUPLICATE: ' + participant);
                        break;
                    }
                }else{
                    throw new AuraHandledException(error.getMessage());
                }
            }
        }

        if(participant.Id != null){
            participantEnrollment.Participant__c = participant.Id;
            participantEnrollment.HCP__c = hcpEnrollment.Id;
            participantEnrollment.Referral_Completed_by__c = CommunityService.getUserContact().Id;
            if(participantEnrollment.Participant_Name__c == null) participantEnrollment.Participant_Name__c = participant.First_Name__c;
            if(participantEnrollment.Participant_Surname__c == null) participantEnrollment.Participant_Surname__c = participant.Last_Name__c;
            try{
                upsert participantEnrollment;
            }catch (Exception e){
                String errorMsg = e.getMessage();
                if(errorMsg.contains('DUPLICATE')) {
                    errorMsg = 'This patient has already been referred to this study. A patient can only be referred to one trial at a time';
                }
                System.debug('ERROR: ' + errorMsg);
                throw new AuraHandledException(errorMsg);
            }
        }else{
            throw new AuraHandledException('Can not create participant');
        }
    }

    @AuraEnabled
    public static void setfailedReferral(String peJSON, String reason){
        try {
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL;
            if(pe.Pre_screening_Status__c != ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED)
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            pe.Non_Referral_Reason__c = reason;
            if(reason == ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING){
                pe.Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_FAIL;
            }
            upsert pe;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static String getCityString(Account acc){
        List<String> addressList = new List<String>();
        if(acc.BillingCity != null) addressList.add(acc.BillingCity);
        if(acc.BillingState != null) addressList.add(acc.BillingState);
        if(acc.BillingPostalCode != null) addressList.add(acc.BillingPostalCode);
        return String.join(addressList, ', ');
    }
    
    public static final Map<String, List<String>> STATES_MAP = FieldDescribeUtil.getDependentOptionsImpl(
            User.CountryCode,
            User.StateCode
    );
    
    
}