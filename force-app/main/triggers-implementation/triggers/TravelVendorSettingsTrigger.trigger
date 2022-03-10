trigger TravelVendorSettingsTrigger on TravelVendorSettings__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(
        TravelVendorSettingsTriggerHandler.CreatePreEnrollmentVisits.class
    );
}
