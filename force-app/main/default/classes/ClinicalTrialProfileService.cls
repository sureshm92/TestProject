public with sharing class ClinicalTrialProfileService {

    public void deleteRelatedToStudyDocuments(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {
        List<Clinical_Trial_Profile__c> completedTrials = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c t : newList) {
            if (t.Status__c != oldMap.get(t.Id).Status__c) {
                if (t.Status__c == 'Completed') {
                    completedTrials.add(t);
                }
            }
        }
        //todo Complete tests
        ResourceService resService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        resService.deleteRelatedToStudyDocuments(completedTrials);
    }

    public void addTherapeuticAreasToParticipants(List<Clinical_Trial_Profile__c> newList, Map<Id, Clinical_Trial_Profile__c> oldMap) {

        TherapeuticAreaPatientService service = (TherapeuticAreaPatientService) ClassFactory.newInstance(TherapeuticAreaPatientService.class);
        List<Clinical_Trial_Profile__c> cTPsWithChangedTA = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c singleCTP : newList) {
            if (singleCTP.Therapeutic_Area__c != null && singleCTP.Therapeutic_Area__c != oldMap.get(singleCTP.Id).Therapeutic_Area__c) {
                cTPsWithChangedTA.add(singleCTP);
            }
        }
        if (!cTPsWithChangedTA.isEmpty()) {
            this.addTherapeuticAreasToParticipants(cTPsWithChangedTA);
        }
    }

    private void addTherapeuticAreasToParticipants(List<Clinical_Trial_Profile__c> cTPs) {

        TherapeuticAreaPatientService service = (TherapeuticAreaPatientService) ClassFactory.newInstance(TherapeuticAreaPatientService.class);
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);

        String enrollmentsQuery =
                'SELECT Participant__c, ' +
                        'Study_Site__r.Clinical_Trial_Profile__r.Therapeutic_Area__c ' +
                        'FROM Participant_Enrollment__c ' +
                        'WHERE Study_Site__r.Clinical_Trial_Profile__c IN (' +
                        String.join(CollectionUtil.getListOfIdsWrappedInApostrophes(new Map<Id, Clinical_Trial_Profile__c>(cTPs).keySet()), ', ') + ')';
        List<Participant_Enrollment__c> enrollments = databaseProxy.query(enrollmentsQuery);
        Map<Id, Id> tAsByParticipantsIds = new Map<Id, Id>();
        for (Participant_Enrollment__c singlePE : enrollments) {
            tAsByParticipantsIds.put(singlePE.Participant__c, singlePE.Study_Site__r.Clinical_Trial_Profile__r.Therapeutic_Area__c);
        }
        List<Therapeutic_Area_Patient__c> tAPToDelete = new List<Therapeutic_Area_Patient__c>();
        List<Therapeutic_Area_Patient__c> tAPToCreate = new List<Therapeutic_Area_Patient__c>();
        String participantsQuery =
                'SELECT Id, ' +
                        '(SELECT Id FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE) ' +
                'FROM Participant__c ' +
                'WHERE Id IN (' + String.join(CollectionUtil.getListOfIdsWrappedInApostrophes(tAsByParticipantsIds.keySet()), ', ') + ')';
        List<Participant__c> participants = databaseProxy.query(participantsQuery);
        for (Participant__c singleParticipant : participants) {
            tAPToDelete.addAll(singleParticipant.Therapeutic_Area_Patients__r);
            tAPToCreate.add(service.getRelatedToStudyTherapeuticAreaPatient(singleParticipant.Id, tAsByParticipantsIds.get(singleParticipant.Id)));
        }
        delete tAPToDelete;
        insert tAPToCreate;
    }
}