/**
 * Created by Yehor Dobrovolskyi
 */
trigger ResStudyTrigger on Res_study__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete
) {
    TriggerHandlerExecutor.execute(ResStudyTriggerHandler.PlatformEventProcessor.class);
    TriggerHandlerExecutor.execute(ResStudyTriggerHandler.CertificateResourceProcessor.class);
}