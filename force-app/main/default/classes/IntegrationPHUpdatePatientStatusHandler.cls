/**
 * Created by user on 30-May-19.
 */

public with sharing class IntegrationPHUpdatePatientStatusHandler {

    public class UpdatePatientsHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            updatePatientStatuses(newList);
        }

    }

    private static void updatePatientStatuses(List<Integration_PH_Update_Patient_Status__c> externalList){
        Set<String> protocolIds = new Set<String>();
        Set<String> siteNumbers = new Set<String>();
        Set<String> subjectIds = new Set<String>();
        for(Integration_PH_Update_Patient_Status__c externalObject : externalList){
            protocolIds.add(externalObject.Protocol_ID__c);
            siteNumbers.add(externalObject.Study_Site_Number__c);
            subjectIds.add(externalObject.Subject_ID__c);
        }
        List<Participant_Study_Enrollment__c> pseList = [
            SELECT
                    Id,
                    Status__c,
                    Clinical_Trial_Profile__r.Protocol_ID__c,
                    Study_Site__r.Study_Site_Number__c,
                    Participant_Enrollment__r.Screening_ID__c
            FROM    Participant_Study_Enrollment__c
            WHERE   Clinical_Trial_Profile__r.Protocol_ID__c IN :protocolIds
            AND     Study_Site__r.Study_Site_Number__c IN :siteNumbers
            AND     Participant_Enrollment__r.Screening_ID__c IN :subjectIds
            LIMIT   10000
        ];
        Map<String, Participant_Study_Enrollment__c> pseMap = new Map<String, Participant_Study_Enrollment__c>();
        for(Participant_Study_Enrollment__c pse : pseList){
            String key = pse.Clinical_Trial_Profile__r.Protocol_ID__c + pse.Study_Site__r.Study_Site_Number__c + pse.Participant_Enrollment__r.Screening_ID__c;
            pseMap.put(key, pse);
        }
        for(Integration_PH_Update_Patient_Status__c externalObject : externalList){
            String key = '' + externalObject.Protocol_ID__c + externalObject.Study_Site_Number__c + externalObject.Subject_ID__c;
            if(pseMap.containsKey(key)){
                pseMap.get(key).Status__c = externalObject.PSE_Status__c;
            }
        }
        update pseMap.values();
    }
}