/**
 * Created by Denis Z on 20-Jun-19.
 */

public with sharing class IntegrationVisitTriggerHandler {
    public class CheckProcessedRecordsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setIsProcessed(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setIsProcessed(newList, (Map<Id, Integration_Visit__c>) oldMap);
        }
    }

    public static Set<Id> updateVisits(List<Integration_Visit__c> integrationVisits) {
        Set<String> externalKeys = new Set<String>();
        for (Integration_Visit__c integrationVisit : integrationVisits) {
            if (
                !(integrationVisit.USUBJID__c.endsWith('~') ||
                integrationVisit.USUBJID__c.contains('~~'))
            ) {
                externalKeys.add(integrationVisit.USUBJID__c);
            }
            integrationVisit.Work_Status__c = 'Failed';
        }
        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                External_Key__c,
                (
                    SELECT Id, Status__c, Visit_Number__c, Name, Is_Adhoc__c, Completed_Date__c
                    FROM Patient_Visits__r
                    ORDER BY Visit_Number__c DESC
                )
            FROM Participant_Enrollment__c
            WHERE External_Key_WF__c IN :externalKeys
        ];
        Map<String, Participant_Enrollment__c> peMap = new Map<String, Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : enrollments)
            peMap.put(pe.External_Key__c, pe);

        Map<Id, Patient_Visit__c> visitsToUpdateMap = new Map<Id, Patient_Visit__c>();
        List<Patient_Visit__c> visitsToInsert = new List<Patient_Visit__c>();
        Map<String, Decimal> maxCompletedVisitMap = new Map<String, Decimal>();
        Map<Id, Patient_Visit__c> visitsToDeleteMap = new Map<Id, Patient_Visit__c>();
        set<ID> pvIdsTobeReturned = new Set<ID>();

        for (Integration_Visit__c integrationVisit : integrationVisits) {
            Boolean matchFound = false;
            Participant_Enrollment__c pe = peMap.get(integrationVisit.USUBJID__c);
            if (pe == null)
                continue;

            if (!maxCompletedVisitMap.containsKey(integrationVisit.USUBJID__c)) {
                maxCompletedVisitMap.put(integrationVisit.USUBJID__c, 0);
            }

            for (Patient_Visit__c visit : pe.Patient_Visits__r) {
                if (
                    (integrationVisit.VISIT__c != null &&
                    integrationVisit.VISIT__c == visit.Name) &&
                    (integrationVisit.VISITNUM__c != null &&
                    integrationVisit.VISITNUM__c == visit.Visit_Number__c)
                ) {
                    matchFound = true;
                    if (integrationVisit.IsDeletedInSDH__c == 'N') {
                        visit.Status__c = 'Completed';
                        visit.Completed_Date__c = integrationVisit.SVSTDTC__c;
                        visit.SDH_Key__c =
                            pe.External_Key__c +
                            visit.Name +
                            visit.Completed_Date__c;
                        visitsToUpdateMap.put(visit.Id, visit);
                    } else {
                        if (!visit.Is_Adhoc__c) {
                            visit.Status__c = 'Pending';
                            visit.Completed_Date__c = null;
                            visitsToUpdateMap.put(visit.Id, visit);
                        } else {
                            visit.Status__c = 'Pending';
                            visitsToDeleteMap.put(visit.Id, visit);
                        }
                    }
                }
                if (visit.Status__c == 'Completed') {
                    if (
                        visit.Visit_Number__c != null &&
                        visit.Visit_Number__c >
                        maxCompletedVisitMap.get(integrationVisit.USUBJID__c)
                    ) {
                        maxCompletedVisitMap.put(
                            integrationVisit.USUBJID__c,
                            visit.Visit_Number__c
                        );
                    }
                }
            }
            if (!matchFound) {
                visitsToInsert.add(createAdhockVisit(integrationVisit, pe));
                if (
                    maxCompletedVisitMap.containsKey(integrationVisit.USUBJID__c) &&
                    integrationVisit.VISITNUM__c >
                    maxCompletedVisitMap.get(integrationVisit.USUBJID__c)
                ) {
                    maxCompletedVisitMap.put(
                        integrationVisit.USUBJID__c,
                        integrationVisit.VISITNUM__c
                    );
                }
            }
            integrationVisit.Work_Status__c = 'Success';
            integrationVisit.Processed__c = true;
        }
        for (Participant_Enrollment__c pe : enrollments) {
            for (Patient_Visit__c visit : pe.Patient_Visits__r) {
                if (
                    visit.Visit_Number__c != null &&
                    visit.Visit_Number__c < maxCompletedVisitMap.get(pe.External_Key__c) &&
                    visit.Status__c == 'Pending'
                ) {
                    visit.Status__c = 'Missed';
                    visitsToUpdateMap.put(visit.Id, visit);
                }
            }
        }

        update integrationVisits;
        update visitsToUpdateMap.values();
        delete visitsToDeleteMap.values();
        insert visitsToInsert;

        for (Patient_Visit__c pv : visitsToInsert) {
            pvIdsTobeReturned.add(pv.Id);
        }
        pvIdsTobeReturned.addAll(visitsToUpdateMap.keySet());
        return pvIdsTobeReturned;
    }

    private static Patient_Visit__c createAdhockVisit(
        Integration_Visit__c externalVisit,
        Participant_Enrollment__c pe
    ) {
        Patient_Visit__c newVisit = new Patient_Visit__c();
        newVisit.Is_Adhoc__c = true;
        newVisit.Name = externalVisit.VISIT__c;
        newVisit.Status__c = 'Completed';
        newVisit.Completed_Date__c = externalVisit.SVSTDTC__c;
        newVisit.Visit_Number__c = externalVisit.VISITNUM__c;
        newVisit.Participant_Enrollment__c = pe.Id;
        newVisit.SDH_Key__c = pe.External_Key__c + newVisit.Name + newVisit.Completed_Date__c;
        return newVisit;
    }

    private static void setIsProcessed(
        List<Integration_Visit__c> newList,
        Map<Id, Integration_Visit__c> oldMap
    ) {
        for (Integration_Visit__c visit : newList) {
            if (oldMap == null || visit.MD5_Hash__c != oldMap.get(visit.Id).MD5_Hash__c) {
                visit.Processed__c = false;
            }
        }
    }
}
