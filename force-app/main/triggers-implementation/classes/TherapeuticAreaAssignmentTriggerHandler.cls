/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaAssignmentTriggerHandler extends TriggerHandler {

    public override void afterInsert(List<SObject> newList) {
        PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(PlatformEventService.class);
        platformEventService.remindEventFire((List<Therapeutic_Area_Assignment__c>) newList);
    }

    protected override void onAfterDelete(List<SObject> oldList) {
        PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(PlatformEventService.class);
        platformEventService.remindEventFire((List<Therapeutic_Area_Assignment__c>) oldList);
    }


}