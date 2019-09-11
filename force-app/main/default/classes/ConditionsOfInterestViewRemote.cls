/**
 * Created by Vitalii Aheienko on 9/10/2019.
 */

public with sharing class ConditionsOfInterestViewRemote {

    @AuraEnabled
    public static List<Therapeutic_Area__c> searchForConditionOfInterest(String searchText, List<Therapeutic_Area_Patient__c> selectedCois) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            return helper.getFilteredTherapeuticAreas(searchText, selectedCois);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}