trigger LeadConversionTrigger on Lead (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        LeadConversionHelper.afterLeadsUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}