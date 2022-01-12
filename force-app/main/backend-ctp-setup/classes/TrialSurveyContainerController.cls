public without sharing class TrialSurveyContainerController {
	
    @AuraEnabled
    public static String getRecordTypeNameById(
        String recordTypeId
    ) {
        Schema.SObjectType sObjectType = Trial_Survey__c.getSObjectType();
        return SchemaUtil.getRecordTypeInfoById(recordTypeId, sObjectType).getName();
    }
}