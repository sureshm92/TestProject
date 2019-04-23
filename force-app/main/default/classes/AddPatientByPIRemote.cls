/**
 * Created by Leonid Bartenev
 */

public class AddPatientByPIRemote {
    
    public static final List<String> PE_STATUSES = new List<String>{
            PEStatusState.PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS,
            PEStatusState.PE_STATUS_CONTACT_SUCCESSFUL,
            PEStatusState.PE_STATUS_ELIGIBILITY_PASSED,
            PEStatusState.PE_STATUS_SCREENING_COMPLETE
    };
    
    public class FormData {
        @AuraEnabled public List<LabelValueItem> statesLVList = CountryStateUtil.getStatesByCountryMap().get('US');
        @AuraEnabled public List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        @AuraEnabled public List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
        @AuraEnabled public List<LabelValueItem> referredByLVList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Referred_By__c);
        @AuraEnabled public List<LabelValueItem> peStatusLVList;
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
    public static FormData getInitData(Id ctpId) {
        try {
            FormData initData = new FormData();
            initData.ctp = TrialService.getTrial(ctpId);
            initData.ss =  StudySiteService.getStudySiteForPIByTrialId(ctpId)[0];
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void saveParticipant(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            String peStatus = pe.Participant_Status__c;
            pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI;
            ParticipantService.createParticipantAndUpdatePE(participant, pe);
            pe.Participant_Status__c = peStatus;
            Database.update(pe);
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }

}