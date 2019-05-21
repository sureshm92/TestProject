/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class PlatformEventService {

    public void remindEventFire() {
        Database.SaveResult result = EventBus.publish(new Reminder_Event__e());
    }

    public void remindEventFire(List<Therapeutic_Area_Assignment__c> therapeuticAreaAssignments) {
        List<Reminder_Event__e> reminderEvents = new List<Reminder_Event__e>();
        for (Therapeutic_Area_Assignment__c therapeuticAreaAssignment : therapeuticAreaAssignments) {
            reminderEvents.add(new Reminder_Event__e(
                    ResourceId__c = therapeuticAreaAssignment.Resource__c
            ));
        }
        if (!reminderEvents.isEmpty()) {
            List<Database.SaveResult> result = EventBus.publish(reminderEvents);
        }
    }

    public void remindEventFire(List<ContentDocumentLink> links) {
        List<Reminder_Event__e> reminderEvents = new List<Reminder_Event__e>();
        for (ContentDocumentLink singleLink : links) {
            if (singleLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType()) {
                reminderEvents.add(new Reminder_Event__e(
                        ResourceId__c = singleLink.LinkedEntityId
                ));
            }
        }
        if (!reminderEvents.isEmpty()) {
            List<Database.SaveResult> result = EventBus.publish(reminderEvents);
        }
    }
}