public with sharing class TherapeuticAreaPatientService {

    public Therapeutic_Area_Patient__c getRelatedToStudyTherapeuticAreaPatient(Id participantId, Id tAId) {
        return new Therapeutic_Area_Patient__c(
                Participant__c = participantId,
                Therapeutic_Area__c = tAId,
                Condition_Of_Interest_Order__c = 0,
                IsRelatedToStudy__c = true
        );
    }

    public static void deleteTherapeuticAreaPatientFromPSE(List<Participant_Study_Enrollment__c> newPSEs,
            Map<Id, Participant_Study_Enrollment__c> oldPSEMap) {
        List<Participant_Study_Enrollment__c> changeList = new List<Participant_Study_Enrollment__c>();
        for (Participant_Study_Enrollment__c newPSE : newPSEs) {
            if (newPSE.Status__c != oldPSEMap.get(newPSE.Id).Status__c) {
                if (!PSEService.PSE_STATUS_GROUP_COMPLETE.contains(oldPSEMap.get(newPSE.Id).Status__c) &&
                        PSEService.PSE_STATUS_GROUP_COMPLETE.contains(newPSE.Status__c)) {
                    changeList.add(newPSE);
                }
            }
        }
        if (!changeList.isEmpty()) {
            deleteTherapeuticAreaPatientFromPSE(changeList);
        }
    }

    public static void deleteTherapeuticAreaPatientFromPE(List<Participant_Enrollment__c> newPE,
            Map<Id, Participant_Enrollment__c> oldPEMap) {

        List<Participant_Enrollment__c> changeList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c participantEnrollment : newPE) {
            if (participantEnrollment.Participant_Status__c != oldPEMap.get(participantEnrollment.Id).Participant_Status__c) {
                if ((PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(oldPEMap.get(participantEnrollment.Id).Participant_Status__c) || PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS.equalsIgnoreCase(oldPEMap.get(participantEnrollment.Id).Participant_Status__c)) &&
                        (PEStatusState.PE_STATUS_GROUP_FAILED.contains(participantEnrollment.Participant_Status__c))) {
                    changeList.add(participantEnrollment);
                }
            }
        }
        if (!changeList.isEmpty()) {
            deleteTherapeuticAreaPatientFromPE(changeList);
        }
    }

    public static void validationOnDuplicate(List<Therapeutic_Area_Patient__c> areaPatients) {
        Set<Id> newParticipantIdSet = new Set<Id>();
        Set<Id> newTherapeuticAreaId = new Set<Id>();
        List<TherapeuticAreaWrapper> dbWrapper = new List<TherapeuticAreaWrapper>();
        Set<TherapeuticAreaWrapper> newWrapper = new Set<TherapeuticAreaWrapper>();
        for (Therapeutic_Area_Patient__c newAreaPatient : areaPatients) {
            TherapeuticAreaWrapper iKey = new TherapeuticAreaWrapper(newAreaPatient.Participant__c, newAreaPatient.Therapeutic_Area__c, newAreaPatient.IsRelatedToStudy__c);
            if (newWrapper.contains(iKey)) {
                newAreaPatient.addError('Duplicate Therapeutic Area Patient');
            } else {
                newParticipantIdSet.add(newAreaPatient.Participant__c);
                newTherapeuticAreaId.add(newAreaPatient.Therapeutic_Area__c);
                newWrapper.add(iKey);
            }
        }
        for (Therapeutic_Area_Patient__c dbAreaPatient : [
                SELECT
                        Participant__c,
                        Therapeutic_Area__c,
                        IsRelatedToStudy__c,
                        Condition_Of_Interest_Order__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c IN :newParticipantIdSet
                AND Therapeutic_Area__c IN :newTherapeuticAreaId
        ]) {
            dbWrapper.add(new TherapeuticAreaWrapper(dbAreaPatient.Participant__c, dbAreaPatient.Therapeutic_Area__c, dbAreaPatient.IsRelatedToStudy__c, dbAreaPatient));
        }
        List<SObject> duplicateObjects = new List<SObject>();
        for (Therapeutic_Area_Patient__c newAreaPatient : areaPatients) {
            TherapeuticAreaWrapper iKey = new TherapeuticAreaWrapper(newAreaPatient.Participant__c, newAreaPatient.Therapeutic_Area__c, newAreaPatient.IsRelatedToStudy__c);
            if (dbWrapper.contains(iKey)) {
                Therapeutic_Area_Patient__c oldAreaPatient = dbWrapper.get(dbWrapper.indexOf(iKey)).areaPatient;
                if (oldAreaPatient.Condition_Of_Interest_Order__c != newAreaPatient.Condition_Of_Interest_Order__c) {
                    newAreaPatient.Condition_Of_Interest_Order__c = oldAreaPatient.Condition_Of_Interest_Order__c > newAreaPatient.Condition_Of_Interest_Order__c
                            ? newAreaPatient.Condition_Of_Interest_Order__c
                            : oldAreaPatient.Condition_Of_Interest_Order__c;
                }
                duplicateObjects.add(oldAreaPatient);
            }
        }
        if (!duplicateObjects.isEmpty()) {
            delete duplicateObjects;
        }
    }

    public static void createTAP(List<Participant_Enrollment__c> participantEnrollments) {
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = new List<Therapeutic_Area_Patient__c>();
        for (Participant_Enrollment__c pe : TherapeuticAreaPatientService.selectPEnrollmentsByIds(participantEnrollments)) {
            if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(pe.Participant_Status__c) || PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS.equalsIgnoreCase(pe.Participant_Status__c)) {
                if (String.isNotBlank(pe.Participant__c) && String.isNotBlank(pe.Clinical_Trial_Profile__r.Therapeutic_Area__c)) {
                    therapeuticAreaPatients.add(
                            new Therapeutic_Area_Patient__c(
                                    Participant__c = pe.Participant__c,
                                    Therapeutic_Area__c = pe.Clinical_Trial_Profile__r.Therapeutic_Area__c,
                                    Condition_Of_Interest_Order__c = 0,
                                    IsRelatedToStudy__c = true
                            )
                    );
                } else {
                    pe.addError('Clinic Trial Profile not Therapeutic Area or Participant Enrolled not Participant');
                }
            }
        }
        if (!therapeuticAreaPatients.isEmpty()) {
            insert therapeuticAreaPatients;
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

    private static void deleteTherapeuticAreaPatientFromPSE(List<Participant_Study_Enrollment__c> deleteList) {
        Set<Id> participantId = new Set<Id>();
        List<Therapeutic_Area_Patient__c> deleteAreaPatients = new List<Therapeutic_Area_Patient__c>();
        for (Participant_Study_Enrollment__c enrollment : deleteList) {
            participantId.add(enrollment.Participant__c);
        }
        if (!participantId.isEmpty()) {
            List<Therapeutic_Area_Patient__c> areaPatients = TherapeuticAreaPatientService.selectTherapeuticAreaPatientsByIds(participantId);
            if (!areaPatients.isEmpty()) {
                List<Participant_Study_Enrollment__c> participantStudyEnrollments = TherapeuticAreaPatientService.selectPSEnrollmentsByIds(deleteList);
                for (Therapeutic_Area_Patient__c areaPatient : areaPatients) {
                    for (Participant_Study_Enrollment__c participantStudyEnrollment : participantStudyEnrollments) {
                        if (areaPatient.Therapeutic_Area__c == participantStudyEnrollment.Clinical_Trial_Profile__r.Therapeutic_Area__c) {
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

    private static List<Participant_Study_Enrollment__c> selectPSEnrollmentsByIds(List<Participant_Study_Enrollment__c> participantStudyEnrollments) {
        return [
                SELECT
                        Participant__c,
                        Clinical_Trial_Profile__r.Therapeutic_Area__c
                FROM Participant_Study_Enrollment__c
                WHERE Id IN :NEW Map<Id, Participant_Study_Enrollment__c>(participantStudyEnrollments).keySet()
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

    public class TherapeuticAreaWrapper {

        public Id participantId;
        public Id therapeuticAreaId;
        public Boolean isPrimary;
        public Therapeutic_Area_Patient__c areaPatient;

        public TherapeuticAreaWrapper(Id participantId, Id therapeuticAreaId, Boolean isPrimary) {
            this(participantId, therapeuticAreaId, isPrimary, null);
        }

        public TherapeuticAreaWrapper(Id participantId, Id therapeuticAreaId, Boolean isPrimary, Therapeutic_Area_Patient__c areaPatient) {
            this.participantId = participantId;
            this.therapeuticAreaId = therapeuticAreaId;
            this.isPrimary = isPrimary;
            this.areaPatient = areaPatient;
        }

        public Boolean equals(Object obj) {
            if (obj instanceof TherapeuticAreaWrapper) {
                TherapeuticAreaWrapper wrapper = (TherapeuticAreaWrapper) obj;
                return ((participantId == wrapper.participantId) && (therapeuticAreaId == wrapper.therapeuticAreaId) && isPrimary == wrapper.isPrimary);
            }
            return false;
        }

        public override Integer hashCode() {
            Integer hash = (System.hashCode(String.valueOf(participantId)) * (isPrimary ? 2 : 1));
            if(therapeuticAreaId != null) hash = hash ^ System.hashCode(String.valueOf(therapeuticAreaId));
            return hash;
        }
    }
}