public without sharing class TherapeuticAreaPatientService {

    public Therapeutic_Area_Patient__c getRelatedToStudyTherapeuticAreaPatient(Id participantId, Id tAId) {
        return new Therapeutic_Area_Patient__c(
                Participant__c = participantId,
                Therapeutic_Area__c = tAId,
                Condition_Of_Interest_Order__c = 0,
                IsRelatedToStudy__c = true
        );
    }


    public static void deleteTherapeuticAreaPatientFromPE(List<Participant_Enrollment__c> newPE,
            Map<Id, Participant_Enrollment__c> oldPEMap) {

        List<Participant_Enrollment__c> changeList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c participantEnrollment : newPE) {
            if (participantEnrollment.Participant_Status__c != oldPEMap.get(participantEnrollment.Id).Participant_Status__c) {
                if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL.contains(oldPEMap.get(participantEnrollment.Id).Participant_Status__c) &&
                        (PEStatusState.PE_STATUS_GROUP_NOT_IN_PROGRESS_ALL.contains(participantEnrollment.Participant_Status__c))) {
                    changeList.add(participantEnrollment);
                }
            }
        }
        if (!changeList.isEmpty()) {
            deleteTherapeuticAreaPatientFromPE(changeList);
        }
    }

    public static void createTAP(List<Participant_Enrollment__c> participantEnrollments) {
        Set<Therapeutic_Area_Patient__c> therapeuticAreaPatients = new Set<Therapeutic_Area_Patient__c>();
        Set<Id> participantIds = new Set<Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            participantIds.add(pe.Participant__c);
        }
        Map<Id, Participant__c> participantsByIds = TherapeuticAreaPatientService.getParticipantsByIds(participantIds);
        for (Participant_Enrollment__c pe : TherapeuticAreaPatientService.selectPEnrollmentsByIds(participantEnrollments)) {
            if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL.contains(pe.Participant_Status__c)) {
                Participant__c participant = participantsByIds.get(pe.Participant__c);
                if (participant != null
                        && String.isNotBlank(pe.Clinical_Trial_Profile__r.Therapeutic_Area__c)
                        && (participant.Therapeutic_Area_Patients__r == null || participant.Therapeutic_Area_Patients__r.isEmpty())) {
                    therapeuticAreaPatients.add(
                            new Therapeutic_Area_Patient__c(
                                    Participant__c = participant.Id,
                                    Therapeutic_Area__c = pe.Clinical_Trial_Profile__r.Therapeutic_Area__c,
                                    Condition_Of_Interest_Order__c = 0,
                                    IsRelatedToStudy__c = true
                            )
                    );
                }
            }
        }
        if (!therapeuticAreaPatients.isEmpty()) {
            insert new List<Therapeutic_Area_Patient__c>(therapeuticAreaPatients);
        }
    }

    private static void deleteTherapeuticAreaPatientFromPE(List<Participant_Enrollment__c> deleteList) {
        Set<Id> participantId = new Set<Id>();
        List<Therapeutic_Area_Patient__c> deleteAreaPatients = new List<Therapeutic_Area_Patient__c>();
        for (Participant_Enrollment__c enrollment : deleteList) {
            participantId.add(enrollment.Participant__c);
        }
        if (!participantId.isEmpty()) {
            List<Therapeutic_Area_Patient__c> areaPatients = TherapeuticAreaPatientService.selectTherapeuticAreaPatientsByIds(participantId);
            if (!areaPatients.isEmpty()) {
                List<Participant_Enrollment__c> participantEnrollments = TherapeuticAreaPatientService.selectPEnrollmentsByIds(deleteList);
                for (Therapeutic_Area_Patient__c areaPatient : areaPatients) {
                    for (Participant_Enrollment__c participantEnrollment : participantEnrollments) {
                        if (areaPatient.Therapeutic_Area__c == participantEnrollment.Clinical_Trial_Profile__r.Therapeutic_Area__c) {
                            deleteAreaPatients.add(areaPatient);
                        }
                    }
                }
            }
            if (!deleteAreaPatients.isEmpty()) {
                delete deleteAreaPatients;
            }
        }
    }

    private static List<Participant_Enrollment__c> selectPEnrollmentsByIds(List<Participant_Enrollment__c> participantEnrollments) {
        return [
                SELECT
                        Participant_Status__c,
                        Participant__c,
                        Clinical_Trial_Profile__r.Therapeutic_Area__c
                FROM Participant_Enrollment__c
                WHERE Id IN :NEW Map<Id, Participant_Enrollment__c>(participantEnrollments).keySet()
        ];
    }

    private static List<Therapeutic_Area_Patient__c> selectTherapeuticAreaPatientsByIds(Set<Id> tIds) {
        return [
                SELECT Id,
                        Participant__c,
                        Therapeutic_Area__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c IN :tIds
                AND IsRelatedToStudy__c = TRUE
        ];
    }

    private static Map<Id, Participant__c> getParticipantsByIds(Set<Id> participantIds) {
        return new Map<Id, Participant__c>([
                SELECT Id,
                (SELECT Id, Participant__c, Therapeutic_Area__c FROM Therapeutic_Area_Patients__r WHERE IsRelatedToStudy__c = TRUE),
                (SELECT Id, Clinical_Trial_Profile__r.Therapeutic_Area__c FROM Participant_Profile__r)
                FROM Participant__c
                WHERE Id IN :participantIds
        ]);
    }

}