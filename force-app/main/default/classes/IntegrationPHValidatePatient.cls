/**
 * Created by user on 04-Jun-19.
 */

public with sharing class IntegrationPHValidatePatient {

    public class PHValidatePatientHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            //validatePatients(newList);
        }

    }

    /*
    private static void validatePatients(List<Integration_PH_Validate_Patient__c> externalList){
        List<Participant_Study_Enrollment__c> pseList = SdhIntegrationService.getPseList(externalList);
        TODO?
    }
    */
}