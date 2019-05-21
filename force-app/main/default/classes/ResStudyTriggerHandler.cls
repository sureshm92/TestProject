/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResStudyTriggerHandler extends TriggerHandler {

    public override void afterInsert(List<SObject> newList) {
        PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(PlatformEventService.class);
        platformEventService.remindEventFire((List<Res_study__c>) newList);
    }

    public override void afterDelete(List<SObject> oldList) {
        PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(PlatformEventService.class);
        platformEventService.remindEventFire((List<Res_study__c>) oldList);
    }

}