/**
 * Created by user on 04-Jun-19.
 */

public with sharing class SdhIntegrationService {

    public static List<Participant_Enrollment__c> getPEList(List<SObject> externalList){
        Set<String> protocolIds = new Set<String>();
        Set<String> siteNumbers = new Set<String>();
        Set<String> subjectIds = new Set<String>();
        for(SObject externalObject : externalList){
            protocolIds.add((String) externalObject.get('Protocol_ID__c'));
            siteNumbers.add((String) externalObject.get('Study_Site_Number__c'));
            subjectIds.add((String) externalObject.get('Subject_ID__c'));
        }
        List<Participant_Enrollment__c> enrollments = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__r.Protocol_ID__c,
                        Participant_Status__c,
                        Study_Site__r.Study_Site_Number__c,
                        Screening_ID__c
                FROM    Participant_Enrollment__c
                WHERE   Clinical_Trial_Profile__r.Protocol_ID__c IN :protocolIds
                AND     Study_Site__r.Study_Site_Number__c IN :siteNumbers
                AND     Screening_ID__c IN :subjectIds
                LIMIT   10000
        ];
        return enrollments;
    }
}