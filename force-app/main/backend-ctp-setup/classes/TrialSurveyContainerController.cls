/**
 * @description       :
 * @author            : Sravani
 * @group             :
 * @last modified on  : 01-21-2022
 **/
public without sharing class TrialSurveyContainerController {
    @AuraEnabled
    public static String getRecordTypeNameById(String recordTypeId) {
        Schema.SObjectType sObjectType = Trial_Survey__c.getSObjectType();
        return SchemaUtil.getRecordTypeInfoById(recordTypeId, sObjectType).getName();
    }

    @AuraEnabled
    public static Trial_Survey__c getTrialSurveyRecords(String tsRecordId) {
        Trial_Survey__c trialSurvey = [
            SELECT
                Id,
                RecordtypeId,
                RecordType.name,
                Is_Recurrence_Survey__c,
                Survey_start_date__c,
                Survey_end_date__c,
                Last_Occurrence_Date__c,
                Recurrence_Frequency__c,
                Status__c
            FROM Trial_Survey__c
            WHERE Id = :tsRecordId
        ];
        return trialSurvey;
    }
}
