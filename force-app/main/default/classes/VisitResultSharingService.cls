/**
 * Created by Igor Malyuta on 24.06.2019.
 */

public without sharing class VisitResultSharingService {

    public static List<Visit_Result__c> processResults(List<Visit_Result__c> visitResults) {
        List<Visit_Result__c> visitResultList = [
                SELECT
                        Actual_Value__c,
                        Max_Value__c,
                        Measurement__c,
                        Min_Value__c,
                        Patient_Visit__c,
                        Patient_Visit__r.Participant_Study_Enrollment__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.Clinical_Trial_Profile__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.Participant_Contact__r.Visit_Results_Opt_In__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.Study_Site__r.Visit_Results_Sharing__c,
                        Patient_Visit__r.Participant_Study_Enrollment__r.Status__c,
                        Patient_Visit__r.Visit__c,
                        Patient_Visit__r.Visit__r.Order__c,
                        Result_Type__c
                FROM Visit_Result__c
                WHERE Id IN:visitResults
        ];

        Set<Id> ctpIds = new Set<Id>();
        for (Visit_Result__c vr : visitResultList) {
            ctpIds.add(vr.Patient_Visit__r.Participant_Study_Enrollment__r.Clinical_Trial_Profile__c);
        }

        Map<Id, Clinical_Trial_Profile__c> trialProfileMap = new Map<Id, Clinical_Trial_Profile__c>([
                SELECT
                        Id,
                        Shareback_Availability_Status__c,
                        Shareback_Availability_Timing__c,
                        Visit_Data_Shareback__c, (
                        SELECT Id, Type__c, Sharing_Countries__c
                        FROM Visit_Result_Type_Sharings__r
                )
                FROM Clinical_Trial_Profile__c
                WHERE Id IN:ctpIds
        ]);

        List<Visit_Result__c> filteredResults = new List<Visit_Result__c>();
        for (Visit_Result__c result : visitResultList) {
            Participant_Study_Enrollment__c pse = result.Patient_Visit__r.Participant_Study_Enrollment__r;
            Clinical_Trial_Profile__c ctp = trialProfileMap.get(pse.Clinical_Trial_Profile__c);

            if (!ctp.Visit_Data_Shareback__c || !pse.Study_Site__r.Visit_Results_Sharing__c
                    || !pse.Participant_Contact__r.Visit_Results_Opt_In__c) continue;
            if (result.Patient_Visit__r.Visit__r.Order__c <= ctp.Shareback_Availability_Timing__c) continue;
            if (!ctp.Shareback_Availability_Status__c.contains(pse.Status__c)) continue;

            for(Visit_Result_Type_Sharing__c resultTypeSharing : ctp.Visit_Result_Type_Sharings__r) {
                if(resultTypeSharing.Type__c == result.Result_Type__c) {
                    if(resultTypeSharing.Sharing_Countries__c == 'All' ||
                            resultTypeSharing.Sharing_Countries__c.contains(pse.Participant__r.Mailing_Country_Code__c)) {
                        filteredResults.add(result);
                        break;
                    }
                }
            }
        }

        return filteredResults;
    }
}