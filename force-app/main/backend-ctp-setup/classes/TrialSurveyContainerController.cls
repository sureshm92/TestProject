/**
 * @description       : 
 * @author            : Sravani
 * @group             : 
 * @last modified on  : 01-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TrialSurveyContainerController {
	
    @AuraEnabled
    public static String getRecordTypeNameById(
        String recordTypeId
    ) {
        Schema.SObjectType sObjectType = Trial_Survey__c.getSObjectType();
        return SchemaUtil.getRecordTypeInfoById(recordTypeId, sObjectType).getName();
    }

    @AuraEnabled
    public static Trial_Survey__c getRecordTypeNameAndId(
        String tsRecordId 
    ) { 
        Trial_Survey__c trialSurvey = [SELECT Id, RecordtypeId, RecordType.name,Is_Recurrence_Survey__c,Survey_start_date__c,Survey_end_date__c,Last_Occurrence_Date__c FROM Trial_Survey__c Where Id=:tsRecordId];
        return trialSurvey;
    }
}