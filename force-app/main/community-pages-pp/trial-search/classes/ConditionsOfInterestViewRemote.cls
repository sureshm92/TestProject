/**
 * Created by Vitalii Aheienko on 9/10/2019.
 */

public with sharing class ConditionsOfInterestViewRemote {

    @AuraEnabled
    public static List<Therapeutic_Area__c> searchForConditionOfInterest(String searchText, List<String> selectedCoisIds) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            return helper.searchFilteredTherapeuticAreas(searchText, selectedCoisIds);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}