public with sharing class PIR_SharingOptionsController {
    public PIR_SharingOptionsController() {

    }

    @AuraEnabled
    public static Participant_Enrollment__c fetchParticipantData(
        String perId 
    ) {

       return([
             SELECT
                  Id,
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
                  Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
            FROM Participant_Enrollment__c
            WHERE Id = :perId LIMIT 1
        ]);
    }
}