public with sharing class PIR_SharingOptionsController {
    public PIR_SharingOptionsController() {

    }
    public class PeDataWrap {
    @AuraEnabled
    public Participant__c participant;
    @AuraEnabled
    public Boolean isVirtualSite;
    @AuraEnabled
    public Boolean isPPEnabled;
    @AuraEnabled
    public Boolean siteSuppressEmail;
    @AuraEnabled
    public Boolean studySuppressEmail;
    @AuraEnabled
    public Boolean isInvited;
    @AuraEnabled
    public String studySiteId;
    @AuraEnabled
    public List<LabelValueItem> getphoneTypeLVList;
    @AuraEnabled
    public List<LabelValueItem> getGenderList;
    @AuraEnabled
    public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
    @AuraEnabled
    public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    @AuraEnabled
    public String dobconfig;
  }
  
    @AuraEnabled
    public static Participant_Enrollment__c fetchParticipantData(
        String perId 
    ) {

       return([
             SELECT
                  Id,
                  Show_Referring_Provider__c,
                  participant__c,
                  participant__r.Mailing_Country_Code__c,
                  participant__r.Mailing_State_Code__c,
                  participant__r.Adult__c,
                  participant__r.Marketing_Flag__c,
                  participant__r.Emancipation_in_progress__c,
                  participant__r.First_Name__c,
                  participant__r.Last_Name__c,
                  participant__r.Full_Name__c,
                  participant__r.Preferred_Language__c,
                  participant__r.Date_of_Birth__c,
                  participant__r.Gender__c,
                  participant__r.Email__c,
                  participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                  participant__r.Phone__c,
                  participant__r.Phone_Type__c,
                  participant__r.Mailing_Country__c,
                  participant__r.Mailing_State__c,
                  participant__r.Mailing_Zip_Postal_Code__c,
                  participant__r.Conditions__c,
                  participant__r.Contact__c,
                  participant__r.Site__c,
                  Study_Site__c,
                  Study_Site__r.Study_Site_Type__c,
                  Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                  Study_Site__r.Suppress_Participant_Emails__c,
                  Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                  Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                  HCP__c,
                  HCP__r.HCP_Contact__c,
                  HCP__r.HCP_Contact__r.FirstName,
                  HCP__r.HCP_Contact__r.LastName,
                  HCP__r.HCP_Contact__r.Email                  
            FROM Participant_Enrollment__c
            WHERE Id = :perId LIMIT 1
        ]);
    }
    
    @AuraEnabled
    public static List<LabelValueItem> fetchYearOfBirth(){
        try {
            List<LabelValueItem> yearList = RPRecordReviewLogHelper.getYear();
            return yearList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Healthcare_Provider__c> getHCPData(String peId) {
        List<Healthcare_Provider__c> healthcareProviders = [
            SELECT
                Id,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Participant_Enrollment__c,
                HCP_Enrollment__c
            FROM Healthcare_Provider__c
            WHERE Participant_Enrollment__c = :peId
        ];
        return healthcareProviders;
    }
    @AuraEnabled
    public static PeDataWrap getpeData(String peId,String participantId) {
      PeDataWrap dw = new PeDataWrap(); 
        dw.participant = [
                          SELECT
                          Id,
                          Adult__c,
                          Marketing_Flag__c,
                          Emancipation_in_progress__c,
                          First_Name__c,
                          Last_Name__c,
                          Full_Name__c,
                          Middle_Name__c,
                          Suffix__c,
                          Nickname__c,
                          Alternative_Phone_Number__c,
                          Preferred_Language__c,
                          Age__c,
                          Date_of_Birth__c,
                          Birth_Year__c,
                          Birth_Month__c,
                          Birth_Day__c,
                          Gender__c,
                          IsCountry_NOT_Eligible_for_Emails__c,
                          Mailing_State__c,
                          Mailing_State_Code__c,
                          Mailing_Country__c,
                          Mailing_Country_Code__c,
                          Mailing_Zip_Postal_Code__c,
                          Conditions__c,
                          Contact__c,
                          Site__c,
                          Alternative_Phone_Type__c,
                          Phone_Type__c,
                          Phone__c,
                          Email__c                
                    FROM Participant__c
                    WHERE Id = :participantId LIMIT 1
                ];
        Participant_Enrollment__c  per = [Select Id,Is_Virtual_Study_Site__c,Study_Site__c,Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                                          Study_Site__r.Participant_DOB_format__c,Study_Site__r.Suppress_Participant_Emails__c,Invited_To_PP_Date__c,Participant_Contact__r.Is_Patient_User_Created__c,
                                          Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c FROM Participant_Enrollment__c WHERE Id = :peId];        
        dw.isVirtualSite = per.Is_Virtual_Study_Site__c;
        dw.isPPEnabled = per.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
        dw.studySiteId = per.Study_Site__c;
        dw.siteSuppressEmail = per.Study_Site__r.Suppress_Participant_Emails__c;
        dw.studySuppressEmail = per.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c;
        dw.getphoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
        if(per.Participant_Contact__r.Is_Patient_User_Created__c){
           dw.isInvited = true;
        }else{
           dw.isInvited = false;
        }
        dw.getGenderList = getGenderLVList();
        dw.dobconfig = per.Study_Site__r.Participant_DOB_format__c;
        return dw;           
    }
    public static List<LabelValueItem> getGenderLVList() {
        List<LabelValueItem> genders = new List<LabelValueItem>();
        genders.add(new LabelValueItem(Label.Gender_Male, 'Male'));
        genders.add(new LabelValueItem(Label.Gender_Female, 'Female'));
        return genders;
    }
    @AuraEnabled
    public static void updatePerRecord(
        String perId 
    ) {
        try {
            Participant_Enrollment__c per = new Participant_Enrollment__c(id=perId);
            bypassEnrollmentTrigger();
            update per;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void bypassEnrollmentTrigger() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
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
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
		TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
    }
   
}