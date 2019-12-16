public with sharing class ClinicalTrialProfileService {

    public static String STATUS_COMPLETED = 'Completed';

    public void deleteRelatedToStudyDocuments(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        List<Clinical_Trial_Profile__c> completedTrials = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c t : newList) {
            if (t.Status__c != oldMap.get(t.Id).Status__c) {
                if (t.Status__c == STATUS_COMPLETED) {
                    completedTrials.add(t);
                }
            }
        }
        //todo Complete tests
        ((ResourceDelegate) ClassFactory.newInstance(ResourceDelegate.class)).deleteRelatedToStudyDocuments(completedTrials);
    }

    public void addDeleteTherapeuticAreasOnParticipants(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {

        List<Clinical_Trial_Profile__c> cTPsWithChangedTA = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c singleCTP : newList) {
            if (singleCTP.Therapeutic_Area__c != oldMap.get(singleCTP.Id).Therapeutic_Area__c) {
                cTPsWithChangedTA.add(singleCTP);
            }
        }
        if (!cTPsWithChangedTA.isEmpty()) {
            this.addDeleteTherapeuticAreasOnParticipants(cTPsWithChangedTA);
        }
    }

    private void addDeleteTherapeuticAreasOnParticipants(List<Clinical_Trial_Profile__c> cTPs) {

        TherapeuticAreaPatientService service = (TherapeuticAreaPatientService) ClassFactory.newInstance(TherapeuticAreaPatientService.class);
        Map<Id, Id> tAsByParticipantsIds = this.getTAsIdsByParticipantsIdsOnCTPs(cTPs);
        if (!tAsByParticipantsIds.isEmpty()) {
            List<Therapeutic_Area_Patient__c> tAPToDelete = new List<Therapeutic_Area_Patient__c>();
            List<Therapeutic_Area_Patient__c> tAPToCreate = new List<Therapeutic_Area_Patient__c>();
            List<Participant__c> participants = this.getParticipantsByIdsSet(tAsByParticipantsIds.keySet());
            for (Participant__c singleParticipant : participants) {
                tAPToDelete.addAll(singleParticipant.Therapeutic_Area_Patients__r);
                if (tAsByParticipantsIds.get(singleParticipant.Id) != null) {
                    tAPToCreate.add(service.getRelatedToStudyTherapeuticAreaPatient(singleParticipant.Id, tAsByParticipantsIds.get(singleParticipant.Id)));
                }
            }
            delete tAPToDelete;
            insert tAPToCreate;
        }
    }

    private Map<Id, Id> getTAsIdsByParticipantsIdsOnCTPs(List<Clinical_Trial_Profile__c> cTPs) {

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String enrollmentsQuery =
                'SELECT Participant__c, ' +
                        'Participant_Status__c, ' +
                        'Study_Site__r.Clinical_Trial_Profile__r.Therapeutic_Area__c ' +
                        'FROM Participant_Enrollment__c ' +
                        'WHERE Study_Site__r.Clinical_Trial_Profile__c IN (' +
                        String.join(CollectionUtil.wrapInApostrophes(new Map<Id, Clinical_Trial_Profile__c>(cTPs).keySet()), ', ') + ')';
        List<Participant_Enrollment__c> enrollments = databaseProxy.query(enrollmentsQuery);
        Map<Id, Id> tAsByParticipantsIds = new Map<Id, Id>();
        for (Participant_Enrollment__c singlePE : enrollments) {
            if (!PEStatusState.PE_STATUS_GROUP_FAILED.contains(singlePE.Participant_Status__c)) {
                if (String.isNotBlank(singlePE.Participant__c) && singlePE.Study_Site__c != null &&
                        singlePE.Study_Site__r.Clinical_Trial_Profile__c != null) {
                    tAsByParticipantsIds.put(singlePE.Participant__c, singlePE.Study_Site__r.Clinical_Trial_Profile__r.Therapeutic_Area__c);
                }
            }
        }
        tAsByParticipantsIds = this.removeAlumniParticipantsFromMap(tAsByParticipantsIds);
        return tAsByParticipantsIds;
    }

    private List<Participant__c> getParticipantsByIdsSet(Set<Id> participantsIds) {

        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String participantsQuery =
                'SELECT Id, ' +
                        '(SELECT Id FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE) ' +
                        'FROM Participant__c ' +
                        'WHERE Id IN (' + String.join(CollectionUtil.wrapInApostrophes(participantsIds), ', ') + ')';
        return (List<Participant__c>) databaseProxy.query(participantsQuery);
    }

    private Map<Id, Id> removeAlumniParticipantsFromMap(Map<Id, Id> tAsByParticipantsIds) {

        if (!tAsByParticipantsIds.isEmpty()) {
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            String pSEQuery =
                    'SELECT Id, ' +
                            'Participant_Status__c, ' +
                            'Participant__c ' +
                            'FROM Participant_Enrollment__c ' +
                            'WHERE Participant__c IN (' + String.join(CollectionUtil.wrapInApostrophes(tAsByParticipantsIds.keySet()), ', ') + ')';
            List<Participant_Enrollment__c> enrollments = (List<Participant_Enrollment__c>) databaseProxy.query(pSEQuery);
            for (Participant_Enrollment__c singlePE : enrollments) {
                if (PEStatusState.PE_STATUS_GROUP_PARTICIPATION_FLOW.contains(singlePE.Participant_Status__c)) {
                    tAsByParticipantsIds.remove(singlePE.Participant__c);
                }
            }
        }
        return tAsByParticipantsIds;
    }
}