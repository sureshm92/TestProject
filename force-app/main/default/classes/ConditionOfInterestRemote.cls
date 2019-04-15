/**
 * Created by AlexKetch on 3/21/2019.
 */

public with sharing class ConditionOfInterestRemote {

    @AuraEnabled
    public static List<ConditionOfInterestRemote.CAWrapper> getConditionOfInterest() {
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
    }

    @AuraEnabled
    public static List<Therapeutic_Area_Patient__c> upsertListCoi(List<Therapeutic_Area_Patient__c> cois) {
         upsert cois;
        return cois;
    }

    private static Participant__c getParticipant() {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        String participantQuery =
                'SELECT Id, ' +
                        'Conditions__c, ' +
                        '(SELECT Id, Therapeutic_Area__c, Therapeutic_Area__r.Name, IsRelatedToStudy__c, Condition_Of_Interest_Order__c ' +
                        'FROM Therapeutic_Area_Patients__r ' +
                        'WHERE Condition_Of_Interest_Order__c > 0' +
                        'ORDER BY Condition_Of_Interest_Order__c) ' +
                        'FROM Participant__c ' +
                        'WHERE Id = \'' + participantId + '\'';
        return ((List<Participant__c>) databaseProxy.query(participantQuery))[0];
    }


    public class CAWrapper {
        @auraEnabled
        public Boolean isSelected;
        @auraEnabled
        public Therapeutic_Area_Patient__c coi;
    }

}