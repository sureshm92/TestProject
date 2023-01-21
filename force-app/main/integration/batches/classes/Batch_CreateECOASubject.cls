/**
 * Created by Sandeep on 10/1/2022. 
 */
public without sharing class Batch_CreateECOASubject extends Batch_ScheduledAbstract implements Database.AllowsCallouts, Database.Stateful {
    public List<Participant_Enrollment__c> perlist = new List<Participant_Enrollment__c>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> peEnrollmentStatus = new List<String>{
            PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            PEStatusState.PE_STATUS_FOLLOW_UP_PERIOD_STARTED,
            PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
        };
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Participant__c,
                    Subject_GUID__c,
                    Participant_Contact__c,
                    Participant__r.Email__c,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.Study_Version_GUID__c,
                    Clinical_Trial_Profile__r.Study_GUID__c,
                    Study_Site__r.ECOA_Site_Guid__c
                FROM Participant_Enrollment__c
                WHERE
                    Subject_GUID__c = NULL
                    AND Clinical_Trial_Profile__r.ECOA_Is_Avaialble__c = TRUE
                    AND Participant_Status__c IN :peEnrollmentStatus
                    AND Clinical_Trial_Profile__r.Study_GUID__c != NULL
                    AND Clinical_Trial_Profile__r.Study_Version_GUID__c != NULL
                    AND Study_Site__r.ECOA_Site_Guid__c != NULL
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> pelist) {
        ECOAService.createSubject(pelist);
        perlist.addAll(pelist);
    }

    public override void finalAction() {
        system.debug('perlist----->' + perlist);
        set<ID> peId = new Set<ID>();
        for (Participant_Enrollment__c pe : perlist) {
            peId.add(pe.id);
        }
        //System.enqueueJob(new Queueable_CreateECOASubject(peId));
        Batch_CreateECOASubjectEvents objBatch = new Batch_CreateECOASubjectEvents(peId);
        Database.executeBatch(objBatch, 200);
    }

    public override Type getType() {
        return Batch_CreateECOASubject.class;
    }

    public override virtual String getBatchDescription() {
        return 'Create Subjects in ECOA Platform';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 5;
    }

    public override Integer getRecommendedScopeSize() {
        return 50;
    }
}
