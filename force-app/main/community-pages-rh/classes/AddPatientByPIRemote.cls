/**
 * Created by Leonid Bartenev
 */

public without sharing class AddPatientByPIRemote {

    public class FormData {
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled public List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        @AuraEnabled public List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
        @AuraEnabled public List<LabelValueItem> referredByLVList = SObjectHelper.getPicklistLabelValueList(Participant_Enrollment__c.Referred_By__c);
        @AuraEnabled public List<LabelValueItem> languageLVList = SObjectHelper.getPicklistLabelValueList(Contact.Language__c);
        @AuraEnabled public List<LabelValueItem> peStatusLVList;
        @AuraEnabled public List<LabelValueItem> visitPlansLVList;
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Study_Site__c ss;
        @AuraEnabled public String userLanguage;
        
        public FormData() {}
    }
    
    @AuraEnabled
    public static FormData getInitData(Id ssId) {
        try {
            FormData initData = new FormData();
            if(ssId != null) {
                initData.ss =  StudySiteService.getStudySiteForPIById(ssId);
                initData.ctp = TrialService.getTrial(initData.ss.Clinical_Trial_Profile__c);
                initData.visitPlansLVList = StudySiteService.getVisitPlansLVList(ssId);
                initData.peStatusLVList = PEStatusState.getAddPatientByPIStatusesLV(initData.ctp);
                initData.userLanguage = getUserLanguage();
            }
            return initData;
        } catch (Exception e) {
            return (FormData) AuraHelper.throwException(e);
        }
    }
    //TODO:Review
    @AuraEnabled
    public static void saveParticipant(String participantJSON, String peJSON, String userLanguage, String ssId){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            trimParticipantFields(participant);
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            participant.Secondary_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI;
            PEStatusState currentState = PEStatusState.STATUSES_MAP.get(pe.Participant_Status__c);
            pe.Referral_Source__c = 'PI';
            ParticipantService.createParticipantAndUpdatePE(participant, pe, userLanguage);

            Participant__c newParticipant = [SELECT Id, Contact__c FROM Participant__c WHERE Id = :participant.Id];
            if (newParticipant != null && !String.isBlank(newParticipant.Contact__c) && !String.isBlank(ssId)) {
                Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
                Study_Site__c ss = StudySiteService.getStudySiteForPIById(ssId);
                String permissionSetName = CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
                actionAssignContactPermissions.addPermission(newParticipant.Contact__c, permissionSetName);
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
            //Moved history Creation to Trigger
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON){
        try{
            Participant__c participant = (Participant__c)JSON.deserialize(participantJSON, Participant__c.class);
            if(participant.Contact__r.Email == null && participant.Email__c != null){
                update new Contact(Id = participant.Contact__c, Email = participant.Email__c);
            }
            Participant_Enrollment__c pe = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            update pe;
            update participant;
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static String getUserLanguage() {
        return UserInfo.getLanguage();
    }

    private static void trimParticipantFields(Participant__c participant){
        participant.Phone__c = participant.Phone__c.trim();
        participant.First_Name__c = participant.First_Name__c.trim();
        participant.Last_Name__c = participant.Last_Name__c.trim();
        participant.Email__c = participant.Email__c.trim();
    }
}