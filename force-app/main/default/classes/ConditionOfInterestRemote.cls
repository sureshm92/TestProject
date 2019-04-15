/**
 * Created by AlexKetch on 3/21/2019.
 */

public with sharing class ConditionOfInterestRemote {
    public static final String COI = 'Condition_of_Interests';

    @AuraEnabled
    public static List<ConditionOfInterestRemote.CAWrapper> getConditionOfInterest() {
        try {
            Participant__c participant = getParticipant();
            List<ConditionOfInterestRemote.CAWrapper> caWrappers = new List<ConditionOfInterestRemote.CAWrapper>();
            if (!participant.Therapeutic_Area_Patients__r.isEmpty()) {
                for (Therapeutic_Area_Patient__c coi : participant.Therapeutic_Area_Patients__r) {
                    ConditionOfInterestRemote.CAWrapper caWrapper = new ConditionOfInterestRemote.CAWrapper ();
                    caWrapper.isSelected = true;
                    caWrapper.coi = coi;
                    caWrappers.add(caWrapper);
                }
            }
            return caWrappers;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<Therapeutic_Area_Patient__c> upsertListCoi(List<Therapeutic_Area_Patient__c> cois) {
        try {
            upsert cois;
            return cois;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void deleteCOI(List<Id> coiIds) {
        try {
            Database.delete(coiIds);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static Participant__c getParticipant() {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Conditions__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, Therapeutic_Area__r.Name, Therapeutic_Area__r.RecordType.DeveloperName, IsRelatedToStudy__c, Condition_Of_Interest_Order__c ' +
                        'FROM Therapeutic_Area_Patients__r ' +
                        'WHERE Condition_Of_Interest_Order__c > 0 ' +
                        'AND Therapeutic_Area__r.RecordType.DeveloperName = \'' + COI + '\' ' +
                        'ORDER BY Condition_Of_Interest_Order__c) ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        return ((List<Participant__c>) databaseProxy.query(participantQuery))[0];
    }

    public class CAWrapper {
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Therapeutic_Area_Patient__c coi;
    }

}