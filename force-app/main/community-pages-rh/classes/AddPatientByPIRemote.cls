/**
 * Created by Leonid Bartenev
 */

public without sharing class AddPatientByPIRemote {

    //TODO:update
    public static final List<String> PE_STATUSES = new List<String>{
            PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
            PEStatusState.PE_STATUS_ELIGIBILITY_PASSED,
            PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS,
            PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
    };
    
    public class FormData {
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled public List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        @AuraEnabled public List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
        @AuraEnabled public List<LabelValueItem> referredByLVList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Referred_By__c);
        @AuraEnabled public List<LabelValueItem> peStatusLVList;
        @AuraEnabled public List<LabelValueItem> visitPlansLVList;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Study_Site__c ss;
        
        public FormData() {
            peStatusLVList = new List<LabelValueItem>();
            for (String status : PE_STATUSES) {
                peStatusLVList.add(
                        new LabelValueItem(
                                TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c, status),
                                status
                        )
                );
            }
        }
    }
    
    @AuraEnabled
    public static FormData getInitData(Id ssId) {
        try {
            FormData initData = new FormData();
            if(ssId != null) {
                initData.ss =  StudySiteService.getStudySiteForPIById(ssId);
                initData.ctp = TrialService.getTrial(initData.ss.Clinical_Trial_Profile__c);
                initData.visitPlansLVList = StudySiteService.getVisitPlansLVList(ssId);
            }
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }
    //TODO:Review
    @AuraEnabled
    public static void saveParticipant(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            String enrollmentStatus = pe.Participant_Status__c;
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI;
            PEStatusState currentState = PEStatusState.STATUSES_MAP.get(pe.Participant_Status__c);
            pe.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
            pe.Referral_Source__c = 'PI';
            ParticipantService.createParticipantAndUpdatePE(participant, pe);

            List<Participant_Enrollment_Status_History__c> statusHistories = new List<Participant_Enrollment_Status_History__c>();
            for(PEStatusState.StatusStep step : PEStatusState.STATUS_STEPS_TABLE){
                if(step.name == PEStatusState.PE_ST_REFERRED) continue;
                statusHistories.add(new Participant_Enrollment_Status_History__c(
                        Notes__c = pe.Last_Status_Changed_Notes__c,
                        Date__c = Datetime.now(),
                        ParticipantEnrollment__c = pe.Id,
                        Status__c = step.name == currentState.name ? enrollmentStatus : step.states.get(PEStatusState.STATUS_STATE_SUCCESS)[0]
                ));
                if(step.name == currentState.name) break;
            }
            insert statusHistories;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            update pe;
            update participant;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
}