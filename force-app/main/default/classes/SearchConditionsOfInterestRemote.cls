/**
 * Created by Yehor Dobrovolskyi
 */

public with sharing class SearchConditionsOfInterestRemote {

    @AuraEnabled
    public static List<ConditionOfInterestRemote.CAWrapper> searchConditionOfInterest(String nameTA) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<ConditionOfInterestRemote.CAWrapper> caWrappers = new List<ConditionOfInterestRemote.CAWrapper>();

        String tAQuery =
                'SELECT Id, ' +
                        'Name ' +
                        'FROM Therapeutic_Area__c ' +
                        'WHERE Name LIKE \'%' + String.escapeSingleQuotes(nameTA) + '%\' ' +
                        'LIMIT 5';
        System.debug(tAQuery);
        List<Therapeutic_Area__c> therapeuticAreas = (List<Therapeutic_Area__c>) databaseProxy.query(tAQuery);
        if (!therapeuticAreas.isEmpty()) {
            for (Therapeutic_Area__c areaPatient : therapeuticAreas) {
                ConditionOfInterestRemote.CAWrapper caWrapper = new ConditionOfInterestRemote.CAWrapper ();
                caWrapper.order = 0;
                caWrapper.isSelected = false;
                caWrapper.therArea = areaPatient;
                caWrappers.add(caWrapper);
            }
        }
        return caWrappers;
    }

}