/**
 * Created by Yehor Dobrovolskyi
 */
trigger TherapeuticAreaPatientTrigger on Therapeutic_Area_Patient__c (before insert, before update, after insert, after update) {
    TriggerHandlerExecutor.execute(TherapeuticAreaPatientTriggerHandler.class);
}