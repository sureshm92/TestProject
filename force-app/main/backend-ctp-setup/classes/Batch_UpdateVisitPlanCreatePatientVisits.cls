/**
 * Created to assign Visit Plans to Participant Enrollments and create Patient Visit records.
 * Used on the Visit Config tab on CTP backend
 */ 
public class Batch_UpdateVisitPlanCreatePatientVisits implements Database.Batchable<sObject>{
	public Map<String,Object> studySiteVisitPlan;
    public Id ctpId;
    public Batch_UpdateVisitPlanCreatePatientVisits(Map<String,Object> in_studySiteVisitPlan, Id in_ctpId){
        studySiteVisitPlan = in_studySiteVisitPlan;
        ctpId = in_ctpId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> ssIds= studySiteVisitPlan.keySet();
        List<String> peStatuses = PEStatusState.PE_STATUS_GROUP_POST_ENROLLMENT_VISIT_RELATED;
        return Database.getQueryLocator('SELECT ID,Study_Site__c,Visit_Plan__c,Clinical_Trial_Profile__c FROM Participant_Enrollment__c WHERE Visit_Plan__c = NULL AND Participant_Status__c IN:peStatuses AND Study_Site__c IN:ssIds AND Clinical_Trial_Profile__c =:ctpId');
    }
    
    public void execute(Database.BatchableContext bc,List<Participant_Enrollment__c> peList){
        List<Id> peIds = new List<Id>();
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        for(Participant_Enrollment__c peToUpdate: peList){
            peIds.add(peToUpdate.Id);
            peToUpdate.Visit_Plan__c = (Id)studySiteVisitPlan.get(peToUpdate.Study_Site__c);
        }
        update peList;
        if(!peIds.isEmpty()){
            createVisitsSchedule(peIds);
        }
    }
    private static void createVisitsSchedule(
        List<Id> peIds
    ) {
        List<Participant_Enrollment__c> enrollments = [SELECT Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,Visit_Plan__c,Participant_Status__c FROM Participant_Enrollment__c WHERE Id IN:peIds];         
        List<Participant_Enrollment__c> peEnrollSuccessWithParticipating = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : enrollments) {
                if (
                    (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) &&
                    pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                ) {
                    peEnrollSuccessWithParticipating.add(pe);
                }
            
        }
        Set<Id> ctpIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peEnrollSuccessWithParticipating)
            ctpIds.add(pe.Clinical_Trial_Profile__c);
        List<Clinical_Trial_Profile__c> ctps = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id IN : ctpIds];
        
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : ctps) {
            ctpMap.put(ctp.Id, ctp);
        }
        Set<Id> visitPlanIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : ctpMap.values())
            visitPlanIds.add(ctp.Visit_Plan__c);
        for (Participant_Enrollment__c pe : enrollments)
            visitPlanIds.add(pe.Visit_Plan__c);
        Map<Id, Visit_Plan__c> visitPlansMap = new Map<Id, Visit_Plan__c>(
            [
                SELECT
                    Id,
                    (
                        SELECT Id, Name, Visit_Number__c, Visit_Schedule__c, Patient_Portal_Name__c
                        FROM Visits__r
                    )
                FROM Visit_Plan__c
                WHERE Id IN :visitPlanIds
            ]
        );

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        for (Participant_Enrollment__c pe : peEnrollSuccessWithParticipating) {
            Clinical_Trial_Profile__c ctp = ctpMap.get(pe.Clinical_Trial_Profile__c);
            Id vpId = pe.Visit_Plan__c;
            if (vpId == null)
                vpId = ctp.Visit_Plan__c;
            if (vpId == null)
                continue;
            Visit_Plan__c vp = visitPlansMap.get(vpId);
            if (vp == null)
                continue;
            for (Visit__c visit : vp.Visits__r) {
                patientVisits.add(PatientVisitService.createPatientVisit(visit, pe.Id));
            }
        }
        if (patientVisits.size() > 0)
            insert patientVisits;
 
    }
    public void finish(Database.BatchableContext bc){
        if(studySiteVisitPlan != null && !studySiteVisitPlan.isEmpty() && ctpId !=null){
            
            List<Study_Site__c> ssList = new List<Study_Site__c>();
            for(String ssId:studySiteVisitPlan.keySet()){
                Study_Site__c ss = new Study_Site__c();
                ss.Id = Id.valueOf(ssId);
                ss.Is_Patient_Visit_Batch_Running__c = false;
                ssList.add(ss);
            }
            if(!ssList.isEmpty()){
                update ssList;
            }
            
        }
    }
}