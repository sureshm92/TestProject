/**
 * Created by Nargiz Mamedova on 4/28/2020.
 */

public with sharing class IntegrationTrialMatchTriggerHandler extends TriggerHandler {

    public override void afterInsert(List<SObject> newList) {
        createTrialMatch(newList);
    }

    private static void createTrialMatch(List<Integration_Trial_Match__c> newList) {
        Map<String, Clinical_Trial_Profile__c> ctpByProtId = new Map<String, Clinical_Trial_Profile__c>();
        Map<String, Participant_Enrollment__c> peByExtKey = new Map<String, Participant_Enrollment__c>();
        Map<String, Trial_Match__c> tmByProtIdExtKey = new Map<String, Trial_Match__c>();
        List<Trial_Match__c> tmsToUpsert = new List<Trial_Match__c>();
        List<Trial_Match__c> tmsToDelete = new List<Trial_Match__c>();
        List<String> externalKeys = new List<String>();
        List<String> protocolIds = new List<String>();

        for (Integration_Trial_Match__c integrationTrialMatch : newList) {
            externalKeys.add(integrationTrialMatch.Participant_Enrollment_External_ID__c);
            protocolIds.add(integrationTrialMatch.Protocol_ID__c);
        }

        List<Clinical_Trial_Profile__c> clinicalTrialProfiles = [
                SELECT Id, Protocol_ID__c
                FROM Clinical_Trial_Profile__c
                WHERE Protocol_ID__c IN:protocolIds
        ];
        for (Clinical_Trial_Profile__c ctp : clinicalTrialProfiles) ctpByProtId.put(ctp.Protocol_ID__c, ctp);

        List<Participant_Enrollment__c> participantEnrollments = [
                SELECT Id, External_Key__c
                FROM Participant_Enrollment__c
                WHERE External_Key__c IN:externalKeys
        ];
        for (Participant_Enrollment__c pe : participantEnrollments) peByExtKey.put(pe.External_Key__c, pe);

        List<Trial_Match__c> trialMatches = [
                SELECT Id, Is_Eligible__c, Protocol_Version__c,
                        Matched_Date__c, Matching_Details__c, Matching_Score__c,
                        Clinical_Trial_Profile__r.Protocol_ID__c, Participant_Enrollment__r.External_Key__c
                FROM Trial_Match__c
                WHERE Clinical_Trial_Profile__r.Protocol_ID__c IN:protocolIds
                AND Participant_Enrollment__r.External_Key__c IN:externalKeys
        ];
        for (Trial_Match__c tm : trialMatches) {
            tmByProtIdExtKey.put(tm.Clinical_Trial_Profile__r.Protocol_ID__c + tm.Participant_Enrollment__r.External_Key__c, tm);
        }

        for (Integration_Trial_Match__c itm : newList) {
            if (!ctpByProtId.keySet().contains(itm.Protocol_ID__c)) {
                itm.Protocol_ID__c.addError('No Study with chosen Protocol Id found');
            } else if (!peByExtKey.keySet().contains(itm.Participant_Enrollment_External_ID__c)) {
                itm.Participant_Enrollment_External_ID__c.addError('No PE with chosen External Key found');
            } else {
                if (tmByProtIdExtKey.keySet().contains(itm.Protocol_ID__c + itm.Participant_Enrollment_External_ID__c)) {
                    Trial_Match__c tm = tmByProtIdExtKey.get(itm.Protocol_ID__c + itm.Participant_Enrollment_External_ID__c);
                    if(itm.IsDeleted__c) {
                        tmsToDelete.add(tm);
                    } else {
                        tm.Is_Eligible__c = itm.Is_Eligible__c;
                        tm.Matched_Date__c = itm.Matched_Date__c;
                        tm.Matching_Score__c = itm.Matching_Score__c;
                        tm.Matching_Details__c = itm.Matching_Details__c;
                        tm.Therapeutic_Area__c = itm.Therapeutic_Area__c;
                        tm.Protocol_Version__c = itm.Protocol_Version__c;
                        tmsToUpsert.add(tm);
                    }
                } else {
                    tmsToUpsert.add(new Trial_Match__c(
                            Is_Eligible__c = itm.Is_Eligible__c,
                            Matched_Date__c = itm.Matched_Date__c,
                            Matching_Score__c = itm.Matching_Score__c,
                            Matching_Details__c = itm.Matching_Details__c,
                            Therapeutic_Area__c = itm.Therapeutic_Area__c,
                            Protocol_Version__c = itm.Protocol_Version__c,
                            Clinical_Trial_Profile__c = ctpByProtId.get(itm.Protocol_ID__c).Id,
                            Participant_Enrollment__c = peByExtKey.get(itm.Participant_Enrollment_External_ID__c).Id
                    ));
                }
            }
        }
        upsert tmsToUpsert;
        delete tmsToDelete;
    }
}