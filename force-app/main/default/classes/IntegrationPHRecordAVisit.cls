/**
 * Created by user on 04-Jun-19.
 */

public with sharing class IntegrationPHRecordAVisit {

    public class PHRecordAVisitHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            recordAVisit(newList);
        }

    }

    private static void recordAVisit(List<Integration_PH_Record_A_Visit__c> externalList){
        List<Participant_Study_Enrollment__c> pseList = SdhIntegrationService.getPseList(externalList);
        //TODO?
    }
}