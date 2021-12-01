/**
 * Created by Leonid Bartenev
 */

public without sharing class VisitTriggerHandler {
    public class DeletePatientVisitOnVisitDeletionHandler extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            List<Patient_Visit__c> patientVisits = [
                SELECT Id
                FROM Patient_Visit__c
                WHERE Visit__c IN :oldList AND Status__c = 'Pending'
            ];
            if (patientVisits.size() > 0)
                delete patientVisits;
        }
    }

    public class InsertPatientVisitOnVisitInsertionHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<Visit__c> newVisits = (List<Visit__c>) newList;
            Set<Id> visitPlanIds = new Set<Id>();
            for (Visit__c visit : newVisits)
                visitPlanIds.add(visit.Visit_Plan__c);
            List<Participant_Enrollment__c> peList = [
                SELECT Id, Visit_Plan__c
                FROM Participant_Enrollment__c
                WHERE Visit_Plan__c IN :visitPlanIds
                /*PEH-525*/
                AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c=true 
                AND Participant_Status__c IN: PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS
            ];
            Map<Id, List<Participant_Enrollment__c>> peListByVisitPlanIdMap = new Map<Id, List<Participant_Enrollment__c>>();
            for (Participant_Enrollment__c pe : peList) {
                List<Participant_Enrollment__c> vpPeList = peListByVisitPlanIdMap.get(
                    pe.Visit_Plan__c
                );
                if (vpPeList == null)
                    vpPeList = new List<Participant_Enrollment__c>();
                vpPeList.add(pe);
                peListByVisitPlanIdMap.put(pe.Visit_Plan__c, vpPeList);
            }
            List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
            for (Visit__c visit : newVisits) {
                List<Participant_Enrollment__c> vpPEList = peListByVisitPlanIdMap.get(
                    visit.Visit_Plan__c
                );
                if (vpPEList == null)
                    continue;
                for (Participant_Enrollment__c pe : vpPEList) {
                    patientVisits.add(PatientVisitService.createPatientVisit(visit, pe.Id));
                }
            }
            if (patientVisits.size() > 0)
                insert patientVisits;
        }
    }

    public class UpdateExistingPatientVisits extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<Visit__c> visits = (List<Visit__c>) newList;
            Map<Id, Visit__c> visitMap = new Map<Id, Visit__c>();
            for (Visit__c v : visits)
                visitMap.put(v.Id, v);

            List<Patient_Visit__c> patientVisits = [
                SELECT Id, Portal_Name__c, Visit__c, Visit_Number__c, Visit_Schedule__c
                FROM Patient_Visit__c
                WHERE Visit__c IN :visits AND Is_Adhoc__c = FALSE
            ];
            for (Patient_Visit__c pv : patientVisits) {
                Visit__c visit = visitMap.get(pv.Visit__c);
                pv.Portal_Name__c = visit.Patient_Portal_Name__c;
                pv.Visit_Number__c = visit.Visit_Number__c;
                pv.Visit_Schedule__c = visit.Visit_Schedule__c;
            }

            update patientVisits;
        }
    }
}
