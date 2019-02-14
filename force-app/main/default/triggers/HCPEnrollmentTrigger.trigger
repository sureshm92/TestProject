/**
 * Created by D.Yasinskyi on 23.02.2018
 */
trigger HCPEnrollmentTrigger on HCP_Enrollment__c (before insert, before update, before delete, after insert, after update) {

    if (Trigger.isBefore) {

        if (Trigger.isDelete) {

            HCPEnrollmentTriggerHandler.onBeforeDelete(Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {

            HCPEnrollmentTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {

            HCPEnrollmentTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    
    HCPEnrollmentTriggerHandler.prepareAdditionalFieldsBeforeInsertUpdate();
}