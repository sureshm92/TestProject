/**
 * Created by Leonid Bartenev
 */

public class VisitTriggerHandler {
    
    public class DeletePatientVisitOnVisitDeletionHandler extends TriggerHandler {
        
        public override void beforeDelete(List<SObject> oldList) {
            List<Patient_Visit__c> patientVisits = [
                    SELECT Id
                    FROM Patient_Visit__c
                    WHERE Visit__c IN: oldList AND Status__c = 'Pending'
            ];
            if(patientVisits.size() > 0) delete patientVisits;
        }
    
    }
    
    
    public class InsertPatientVisitOnVisitInsertionHandler extends TriggerHandler {
        
        public override void afterInsert(List<SObject> newList) {
            List<Visit__c> newVisits = (List<Visit__c>)newList;
            Set<Id> visitPlanIds = new Set<Id>();
            for(Visit__c visit : newVisits) visitPlanIds.add(visit.Visit_Plan__c);
            List<Clinical_Trial_Profile__c> clinicalTrialProfiles = [
                    SELECT Id
                    FROM Clinical_Trial_Profile__c
                    WHERE Visit_Plan__c IN: visitPlanIds
            ];
            List<Participant_Study_Enrollment__c> pseList = [
                    SELECT Id, Clinical_Trial_Profile__r.Visit_Plan__c
                    FROM Participant_Study_Enrollment__c
                    WHERE Clinical_Trial_Profile__c IN: clinicalTrialProfiles
            ];
            Map<Id, List<Participant_Study_Enrollment__c>> pseListByVisitPlanIdMap = new Map<Id, List<Participant_Study_Enrollment__c>>();
            for(Participant_Study_Enrollment__c pse : pseList){
                List<Participant_Study_Enrollment__c> vpPseList = pseListByVisitPlanIdMap.get(pse.Clinical_Trial_Profile__r.Visit_Plan__c);
                if(vpPseList == null) vpPseList = new List<Participant_Study_Enrollment__c>();
                pseListByVisitPlanIdMap.put(pse.Clinical_Trial_Profile__r.Visit_Plan__c, vpPseList);
            }
            List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
            for(Visit__c visit : newVisits){
                List<Participant_Study_Enrollment__c> vpPseList = pseListByVisitPlanIdMap.get(visit.Visit_Plan__c);
                if(vpPseList == null) continue;
                for(Participant_Study_Enrollment__c pse : vpPseList){
                    patientVisits.add(VisitService.createPatientVisit(visit, pse.Id));
                }
            }
            if(patientVisits.size() > 0) insert patientVisits;
        }
    
    }


}