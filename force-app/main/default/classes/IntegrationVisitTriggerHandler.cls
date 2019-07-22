/**
 * Created by Denis Z on 20-Jun-19.
 */

public with sharing class IntegrationVisitTriggerHandler{


    public class UpdateVisits extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            updateVisits(JSON.serialize(newList));
        }

    }

    @future
    private static void updateVisits(String jsonString){
        List<Integration_Visit__c> visits = (List<Integration_Visit__c>) JSON.deserialize(jsonString, List<Integration_Visit__c>.class);
        Set<String> externalKeys = new Set<String>();
        Map<String, List<Patient_Visit__c>> patientVisitMap = new Map<String, List<Patient_Visit__c>>();
        for(Integration_Visit__c visit : visits){
            externalKeys.add(visit.USUBJID__c);
            visit.Work_Status__c = 'Failed';
            patientVisitMap.put(visit.USUBJID__c, new List<Patient_Visit__c>());
        }
        List<Patient_Visit__c> patientVisits = [
            SELECT
                    Id,
                    Visit__r.Name,
                    Participant_Study_Enrollment__r.External_Key__c,
                    Status__c,
                    Visit__r.Visit_Number__c,
                    Visit_Number__c,
                    Name
            FROM    Patient_Visit__c
            WHERE   Participant_Study_Enrollment__r.External_Key__c IN : externalKeys
            ORDER BY Visit_Number__c
            DESC
        ];
        //Not sure
        List<Participant_Study_Enrollment__c> pseList = [
            SELECT
                    Id,
                    External_Key__c
            FROM    Participant_Study_Enrollment__c
            WHERE   External_Key__c IN : externalKeys
        ];
        Map<String, Id> pseIdsMap = new Map<String, Id>();
        for(Participant_Study_Enrollment__c pse : pseList){
            pseIdsMap.put(pse.External_Key__c, pse.Id);
        }
        //
        for(Patient_Visit__c visit : patientVisits){
            patientVisitMap.get(visit.Participant_Study_Enrollment__r.External_Key__c).add(visit);
        }
        List<Patient_Visit__c> newVisits = new List<Patient_Visit__c>();
        for(Integration_Visit__c externalVisit : visits) {
            if(patientVisitMap.containsKey(externalVisit.USUBJID__c)){
                Boolean matchFound = false;
                for(Patient_Visit__c visit : patientVisitMap.get(externalVisit.USUBJID__c)){
                    if(matchFoundByName(externalVisit, visit) || matchFoundByNumber(externalVisit, visit)){
                        matchFound = true;
                        continue;
                    }
                }
                if(!matchFound){
                    newVisits.add(createAdhockVisit(externalVisit, pseIdsMap));
                }
                externalVisit.Work_Status__c = 'Success';
            }
        }
        update patientVisits;
        insert newVisits;
        update visits;
    }

    private static Boolean matchFoundByName(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        if(externalVisit.VISIT__c != null){
            if(externalVisit.VISIT__c == visit.Name){
                updatePatientVisit(externalVisit, visit);
                return true;
            }
        }
        return false;
    }

    private static Boolean matchFoundByNumber(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        if(externalVisit.VISITNUM__c != null){
            if(externalVisit.VISITNUM__c == visit.Visit_Number__c){
                updatePatientVisit(externalVisit, visit);
                return true;
            }
        }
        return false;
    }

    private static Patient_Visit__c createAdhockVisit(Integration_Visit__c externalVisit, Map<String, Id> pseIdsMap){
        Patient_Visit__c newVisit = new Patient_Visit__c();
        newVisit.Is_Adhoc__c = true;
        newVisit.Name = externalVisit.Visit__c;
        newVisit.Status__c = 'Completed';
        newVisit.Completed_Date__c = externalVisit.SVSTDTC__c;
        newVisit.Visit_Number__c = externalVisit.VISITNUM__c;
        newVisit.Participant_Study_Enrollment__c = pseIdsMap.get(externalVisit.USUBJID__c);
        return newVisit;
    }

    private static void updatePatientVisit(Integration_Visit__c externalVisit, Patient_Visit__c visit){
        visit.Status__c = 'Completed';
        visit.Completed_Date__c = externalVisit.SVSTDTC__c;
    }

}