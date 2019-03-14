/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaService {

    public static void deleteTherapeuticAreaPatientFromPSE(List<Participant_Study_Enrollment__c> newPSEs,
            Map<Id, Participant_Study_Enrollment__c> oldPSEMap) {
        System.debug('deleteTherapeuticAreaPatientFromPSE');
        List<Participant_Study_Enrollment__c> changeList = new List<Participant_Study_Enrollment__c>();

        for (Participant_Study_Enrollment__c newPSE : newPSEs) {
            if (newPSE.Status__c != oldPSEMap.get(newPSE.Id).Status__c) {
                if (oldPSEMap.get(newPSE.Id).Status__c == 'Enrolled') {
                    changeList.add(newPSE);
                }
            }
        }
        if (!changeList.isEmpty()) {
            Set<Id> participantId = new Set<Id>();
            for (Participant_Study_Enrollment__c newPSE : changeList) {
                participantId.add(newPSE.Participant__c);
            }
            deleteTherapeuticAreaPatient(participantId);
        }
    }

    public static void deleteTherapeuticAreaPatientFromPE(List<Participant_Enrollment__c> newPE,
            Map<Id, Participant_Enrollment__c> oldPEMap) {
        System.debug('deleteTherapeuticAreaPatientFromPE');

        List<Participant_Enrollment__c> changeList = new List<Participant_Enrollment__c>();

        for (Participant_Enrollment__c participantEnrollment : newPE) {
            if (participantEnrollment.Participant_Status__c != oldPEMap.get(participantEnrollment.Id).Participant_Status__c) {
                if (oldPEMap.get(participantEnrollment.Id).Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI ||
                        oldPEMap.get(participantEnrollment.Id).Participant_Status__c == 'Enrollment Success') {
                    if (participantEnrollment.Participant_Status__c != ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI
                            && participantEnrollment.Participant_Status__c != 'Enrollment Success') {
                        changeList.add(participantEnrollment);
                    }
                }
            }
        }
        if (!changeList.isEmpty()) {
            Set<Id> participantId = new Set<Id>();
            for (Participant_Enrollment__c enrollment : changeList) {
                participantId.add(enrollment.Participant__c);
            }
            deleteTherapeuticAreaPatient(participantId);
        }
    }

    public static void validationOnDuplicate(List<Therapeutic_Area_Patient__c> areaPatients) {
        System.debug('validationOnDuplicate count: ' + areaPatients.size());
        Set<Id> newParticipantIdSet = new Set<Id>();
        Set<Id> newTherapeuticAreaId = new Set<Id>();
        List<TherapeuticAreaWrapper> dbWrapper = new List<TherapeuticAreaWrapper>();
        Set<TherapeuticAreaWrapper> newWrapper = new Set<TherapeuticAreaWrapper>();

        for (Therapeutic_Area_Patient__c newAreaPatient : areaPatients) {
            TherapeuticAreaWrapper iKey = new TherapeuticAreaWrapper(newAreaPatient.Participant__c, newAreaPatient.Therapeutic_Area__c);
            if (newWrapper.contains(iKey)) {
                newAreaPatient.addError('Duplicate Therapeutic Area Patient');
            } else {
                newParticipantIdSet.add(newAreaPatient.Participant__c);
                newTherapeuticAreaId.add(newAreaPatient.Therapeutic_Area__c);
                newWrapper.add(iKey);
            }
        }

        System.debug('validationOnDuplicate newWrapper count: ' + newWrapper.size());
        for (Therapeutic_Area_Patient__c dbAreaPatient : [
                SELECT
                        Participant__c,
                        Therapeutic_Area__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c IN :newParticipantIdSet
                AND Therapeutic_Area__c IN :newTherapeuticAreaId
        ]) {
            dbWrapper.add(new TherapeuticAreaWrapper(dbAreaPatient.Participant__c, dbAreaPatient.Therapeutic_Area__c, dbAreaPatient));
        }
        System.debug('validationOnDuplicate dbWrapper count: ' + dbWrapper.size());


        List<SObject> duplicateObjects = new List<SObject>();
        for (Therapeutic_Area_Patient__c newAreaPatient : areaPatients) {
            TherapeuticAreaWrapper iKey = new TherapeuticAreaWrapper(newAreaPatient.Participant__c, newAreaPatient.Therapeutic_Area__c);
            if (dbWrapper.contains(iKey)) {
                duplicateObjects.add(dbWrapper.get(dbWrapper.indexOf(iKey)).areaPatient);
//                newAreaPatient.addError('You are inserting Duplicate Therapeutic Area Patient');
                System.debug('validationOnDuplicate duplicate: ' + newAreaPatient);
            }
        }
        if (!duplicateObjects.isEmpty()) {
            delete duplicateObjects;
        }
    }

    private static void deleteTherapeuticAreaPatient(Set<Id> participantId) {
        System.debug('deleteTherapeuticAreaPatient count:' + participantId.size());
        List<Therapeutic_Area_Patient__c> areaPatients = [
                SELECT Id
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c IN :participantId
                AND IsRelatedToStudy__c = TRUE
        ];
        if (!areaPatients.isEmpty()) {
            delete areaPatients;
        }
    }

    public class TherapeuticAreaWrapper {
        public Id participantId;
        public Id therapeuticAreaId;
        public Therapeutic_Area_Patient__c areaPatient;

        public TherapeuticAreaWrapper(Id participantId, Id therapeuticAreaId) {
            this(participantId, therapeuticAreaId, null);
        }

        public TherapeuticAreaWrapper(Id participantId, Id therapeuticAreaId, Therapeutic_Area_Patient__c areaPatient) {
            this.participantId = participantId;
            this.therapeuticAreaId = therapeuticAreaId;
            this.areaPatient = areaPatient;
        }

        public  Boolean equals(Object obj) {
            if (obj instanceof TherapeuticAreaWrapper) {
                TherapeuticAreaWrapper wrapper = (TherapeuticAreaWrapper) obj;
                return ((participantId == wrapper.participantId) && (therapeuticAreaId == wrapper.therapeuticAreaId));
            }
            return false;
        }

        public override Integer hashCode() {
            return (System.hashCode(String.valueOf(participantId)) * 2) ^ System.hashCode(String.valueOf(therapeuticAreaId));
        }

    }
}