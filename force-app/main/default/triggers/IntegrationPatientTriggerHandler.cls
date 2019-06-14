/**
 * Created by Denis Z on 13-Jun-19.
 */

public with sharing class IntegrationPatientTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class UpdatePatientsHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            upsertPatients(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            upsertPatients(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void upsertPatients(List<Integration_Patients__c> newList){
        List<Participant__c> patients = new List<Participant__c>();
        for(Integration_Patients__c patient : newList){
            patients.add(convertToContact(patient));
        }
        upsert patients;
    }

    private static Participant__c convertToContact(Integration_Patients__c patient){
        Participant__c participant = new Participant__c();
        participant.Day_of_Birth__c = patient.BRTHDTC__c;
        participant.Full_Name__c = patient.INVNAM__c;
        if(patient.SEX__c = 'M'){
            participant.Gender__c = 'Male';
        } else {
            participant.Gender__c = 'Female';
        }
        return participant;
    }
}