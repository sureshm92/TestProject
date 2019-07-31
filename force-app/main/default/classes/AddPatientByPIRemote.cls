/**
 * Created by Leonid Bartenev
 */

public without sharing class AddPatientByPIRemote {
    
    public static final List<String> PE_STATUSES = new List<String>{
            PEStatusState.PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS,
            PEStatusState.PE_STATUS_ELIGIBILITY_PASSED,
            PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS,
            PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
    };

    public class RecordsData{
        @AuraEnabled public Participant__c participantRecord;
        @AuraEnabled public Participant_Enrollment__c peRecord;
        @AuraEnabled public String participantState;
        @AuraEnabled public String participantPhoneType;
    }
    
    public class FormData {
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
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
    public static FormData getInitData(Id ctpId, Id ssId) {
        try {
            FormData initData = new FormData();
            if(ctpId != null){
                initData.ctp = TrialService.getTrial(ctpId);
            	List<Study_Site__c> studySitesByTrial = StudySiteService.getStudySiteForPIByTrialId(ctpId);
            	if(ssId != null){
                	for(Study_Site__c ss : studySitesByTrial) {
                    	if(ss.Id == ssId) {
                        	initData.ss = ss;
                    	}
                	}
            	}
            	else {
                	initData.ss = StudySiteService.getStudySiteForPIByTrialId(ctpId)[0];
            	}
        	}
            
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }
	
	@AuraEnabled
    public static FormData getInitDataEdit() {
        try {
            FormData initData = new FormData();
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static RecordsData getParticipantRecord(Id participantEnrollmentId){
        


        Participant_Enrollment__c per = [
            SELECT  Id, 
                    Participant__c,
                    Screening_ID__c,
                    MRN_Id__c,
                    Referred_By__c,
                    Participant_Status__c 
            FROM    Participant_Enrollment__c 
            WHERE   Id =:participantEnrollmentId 
        ];
       Participant__c participantRecord =  [
            SELECT  id,
                    First_Name__c,
                    Last_Name__c,
                    Middle_Name__c,
                    Date_of_Birth__c,
                    Gender__c,
                    Phone__c,
                    Phone_Type__c,
                    Email__c,
                    Mailing_Country_Code__c,
                    Mailing_State_Code__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_State__c
            FROM    Participant__c
            WHERE   Id = :per.Participant__c
        ];
        RecordsData data = new RecordsData();
        data.participantRecord = participantRecord;
        data.participantState = participantRecord.Mailing_State_Code__c;
        data.participantPhoneType = participantRecord.Phone_Type__c;
        data.peRecord = per;
        return data;
    }
    
    @AuraEnabled
    public static Id saveParticipant(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            System.debug('pe.Id' + pe.Id);
            if(pe.Id == null){
                String peStatus = pe.Participant_Status__c;
                pe.Participant_Status__c = pe.Id == null ? PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI : pe.Participant_Status__c;
                pe.Referral_Source__c = 'PI';
                ParticipantService.createParticipantAndUpdatePE(participant, pe);
                PEStatusState currentState = PEStatusState.STATUSES_MAP.get(peStatus);
                List<Participant_Enrollment_Status_History__c> statusHistories = new List<Participant_Enrollment_Status_History__c>();
                for(PEStatusState.StatusStep step : PEStatusState.STATUS_STEPS_TABLE){
                    if(step.name == currentState.name) break;
                    if(step.name == PEStatusState.PE_ST_REFERRED) continue;
                    statusHistories.add(new Participant_Enrollment_Status_History__c(
                            Notes__c = pe.Last_Status_Changed_Notes__c,
                            Date__c = Datetime.now(),
                            ParticipantEnrollment__c = pe.Id,
                            NewStatus__c = step.states.get(PEStatusState.STATUS_STATE_SUCCESS)
                    ));
                }
                insert statusHistories;
                pe.Participant_Status__c = peStatus;
            }else{
                String peId = pe.Id;
                String peStatus = pe.Participant_Status__c;
                pe = new Participant_Enrollment__c(Id = peId, Participant_Status__c = peStatus);
            }
            update pe;
            return pe.Id;
        }catch (Exception e){
            System.debug('Stack Trace: ' + e.getStackTraceString());
            AuraHelper.throwException(e);
            return null;
        }
    }

}