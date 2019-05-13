/**
 * Created by Yehor Dobrovolskyi
 */
trigger TherapeuticAreaAssignmentTrigger on Therapeutic_Area_Assignment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(TherapeuticAreaAssignmentTriggerHandler.class);

}