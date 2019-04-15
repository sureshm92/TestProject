/**
 * Created by Yehor Dobrovolskyi
 */

public with sharing class SearchConditionsOfInterestRemote {

    @AuraEnabled
    public static List<ConditionOfInterestRemote.CAWrapper> searchConditionOfInterest(String nameTA) {
        try {
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            List<ConditionOfInterestRemote.CAWrapper> caWrappers = new List<ConditionOfInterestRemote.CAWrapper>();
            CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
            String participantId = cService.getParticipantId();
            String tAQuery =
                    'SELECT Id, ' +
                            'Name ' +
                            'FROM Therapeutic_Area__c ' +
                            'WHERE RecordType.DeveloperName = \'' + ConditionOfInterestRemote.COI + '\' ' +
                            'AND Name LIKE \'%' + String.escapeSingleQuotes(nameTA) + '%\' ' +
                            'LIMIT 5';
            System.debug(tAQuery);
            List<Therapeutic_Area__c> therapeuticAreas = (List<Therapeutic_Area__c>) databaseProxy.query(tAQuery);
            if (!therapeuticAreas.isEmpty()) {
                for (Therapeutic_Area__c areaPatient : therapeuticAreas) {
                    ConditionOfInterestRemote.CAWrapper caWrapper = new ConditionOfInterestRemote.CAWrapper ();
                    caWrapper.isSelected = false;
                    caWrapper.coi = new Therapeutic_Area_Patient__c(
                            Participant__c = participantId,
                            Therapeutic_Area__c = areaPatient.Id,
                            Therapeutic_Area__r = areaPatient,
                            Condition_Of_Interest_Order__c = 100
                    );
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
    public static void deleteCOI(List<Id> coiIds) {
        try {
            Database.delete(coiIds);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}