/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaService {

    public static void validationOnDuplicate(List<Therapeutic_Area_Patient__c> areaPatients) {
        Set<Id> newParticipantIdSet = new Set<Id>();
        Set<Id> newTherapeuticAreaId = new Set<Id>();
        Set<TherapeuticAreaWrapper> dbWrapper = new Set<TherapeuticAreaWrapper>();
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

        for (Therapeutic_Area_Patient__c dbAreaPatient: [
                SELECT
                        Participant__c,
                        Therapeutic_Area__c
                FROM Therapeutic_Area_Patient__c
                WHERE Participant__c IN :newParticipantIdSet
                AND Therapeutic_Area__c IN :newTherapeuticAreaId
        ]) {
            dbWrapper.add(new TherapeuticAreaWrapper(dbAreaPatient.Participant__c, dbAreaPatient.Therapeutic_Area__c));
        }

        for (Therapeutic_Area_Patient__c newAreaPatient : areaPatients) {
            TherapeuticAreaWrapper iKey = new TherapeuticAreaWrapper(newAreaPatient.Participant__c, newAreaPatient.Therapeutic_Area__c);
            if (dbWrapper.contains(iKey)) {
                newAreaPatient.addError('You are inserting Duplicate Therapeutic Area Patient');
            }
        }
    }


    public class TherapeuticAreaWrapper {
        public Id participantId;
        public Id therapeuticAreaId;

        public TherapeuticAreaWrapper(Id participantId, Id therapeuticAreaId) {
            this.participantId = participantId;
            this.therapeuticAreaId = therapeuticAreaId;
        }

        public Boolean equals(Object obj) {
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