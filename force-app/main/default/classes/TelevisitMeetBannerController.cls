public without sharing class TelevisitMeetBannerController {
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    @AuraEnabled
    public static String getVisits(String communityMode, String userMode) {
        Datetime currentDateTime = Datetime.now();
        Datetime next24HoursDateTime = Datetime.now().addHours(24);
        List<Televisit_Attendee__c> allVisitis = [
            SELECT
                Televisit__r.Id,
                Televisit__r.Title__c,
                Televisit__r.Visit_Date_Time__c,
                Televisit__r.Visit_Link_Activation_End_Time__c,
                Televisit__r.Visit_Link_Activation_Start_Time__c,
                Televisit__r.Meeting_URL__c,
                Televisit__r.Participant_Enrollment__r.Participant_Name__c,
                Televisit__r.Duration__c,
                Televisit__r.Visit_End_Date_Time__c,
                Attendee_Type__c,
                Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c,
                Televisit__r.Source_Community__c,
                Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Televisit__r.Participant_Enrollment__r.Invited_To_PP_Date__c
            FROM Televisit_Attendee__c
            WHERE
                User__c = :UserInfo.getUserId()
                AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime
                AND Televisit__r.Visit_Link_Activation_End_Time__c <= :next24HoursDateTime
                AND Televisit__r.Status__c = 'Scheduled'
                AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null
                AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated'
                AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated (Admin)'
                AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = 'Accepted'
            ORDER BY Televisit__r.Visit_Date_Time__c
        ];
        List<Televisit_Attendee__c> visits = new List<Televisit_Attendee__c>();
        for (Televisit_Attendee__c attendee : allVisitis) {
            if (
                userMode != 'Participant' &&
                attendee.Televisit__r.Source_Community__c == communityMode &&
                (attendee.Attendee_Type__c != 'Participant' &&
                attendee.Attendee_Type__c != 'Participant Delegate')
            ) {
                visits.add(attendee);
            }
            if (
                userMode == 'Participant' &&
                attendee.Attendee_Type__c == 'Participant' &&
                attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c ==
                true &&
                attendee.Televisit__r.Participant_Enrollment__r.Invited_To_PP_Date__c != null
            ) {
                visits.add(attendee);
            } else if (
                userMode == 'Participant' &&
                attendee.Attendee_Type__c == 'Participant Delegate'
            ) {
                visits.add(attendee);
            }
        }
        return JSON.serialize(visits);
    }
}