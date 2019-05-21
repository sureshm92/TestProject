/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class PlatformEventService {

    public void remindEventFire() {
        Database.SaveResult result = EventBus.publish(new Reminder_Event__e());
    }

    public void remindEventFire(List<Therapeutic_Area_Assignment__c> therapeuticAreaAssignments) {
        List<Reminder_Event__e> reminderEvents = new List<Reminder_Event__e>();
        Set<Id> resIds = new Set<Id>();
        for (Therapeutic_Area_Assignment__c therapeuticAreaAssignment : therapeuticAreaAssignments) {
            resIds.add(therapeuticAreaAssignment.Resource__c);
        }
        List<Resource__c> resources = this.getResourcesByIds(resIds);
        for (Resource__c resource : resources) {
            if (resource.Therapeutic_Area_Assignments__r == null
                    || resource.Therapeutic_Area_Assignments__r.isEmpty()
                    || resource.Therapeutic_Area_Assignments__r.size() == 1) {
                reminderEvents.add(new Reminder_Event__e(
                        ResourceId__c = resource.Id
                ));
            }
        }
        if (!reminderEvents.isEmpty()) {
            List<Database.SaveResult> result = EventBus.publish(reminderEvents);
        }
    }

    public void remindEventFire(List<ContentDocumentLink> links) {
        List<Reminder_Event__e> reminderEvents = new List<Reminder_Event__e>();
        Set<Id> resIds = new Set<Id>();
        for (ContentDocumentLink contentDocumentLink : links) {
            if (contentDocumentLink.LinkedEntityId.getSobjectType() == Resource__c.getSObjectType()) {
                resIds.add(contentDocumentLink.LinkedEntityId);
            }
        }
        List<Resource__c> resources = this.getResourcesByIds(resIds);
        for (Resource__c resource : resources) {
            if (((String.isNotBlank(resource.Content_Class__c)
                    && (ResourceService.RESOURCE_SOURCE_STUDY.equalsIgnoreCase(resource.Content_Class__c)
                    || ResourceService.RESOURCE_SOURCE_PLATFORM.equalsIgnoreCase(resource.Content_Class__c)))
                        || (String.isNotBlank(resource.document_type__c)
                        && (ResourceService.RESOURCE_TYPE_DOCUMENT.equalsIgnoreCase(resource.document_type__c))))
                            && (resource.ContentDocumentLinks == null
                                || resource.ContentDocumentLinks.isEmpty()
                                || resource.ContentDocumentLinks.size() == 1)) {
                reminderEvents.add(new Reminder_Event__e(
                        ResourceId__c = resource.Id
                ));
            }
        }
        if (!reminderEvents.isEmpty()) {
            List<Database.SaveResult> result = EventBus.publish(reminderEvents);
        }
    }

    public void remindEventFire(List<Res_study__c> resStudies) {
        List<Reminder_Event__e> reminderEvents = new List<Reminder_Event__e>();
        Set<Id> resIds = new Set<Id>();
        for (Res_study__c resStudy : resStudies) {
            resIds.add(resStudy.Resource__c);
        }
        List<Resource__c> resources = this.getResourcesByIds(resIds);
        for (Resource__c resource : resources) {
            if (resource.Study__r == null
                    || resource.Study__r.isEmpty()
                    || resource.Study__r.size() == 1) {
                reminderEvents.add(new Reminder_Event__e(
                        ResourceId__c = resource.Id
                ));
            }
        }
        if (!reminderEvents.isEmpty()) {
            List<Database.SaveResult> result = EventBus.publish(reminderEvents);
        }
    }

    private List<Resource__c> getResourcesByIds(Set<Id> resIds) {
        return [
                SELECT Id,
                        Image__c,
                        document_type__c,
                        Content_Class__c, (SELECT Id FROM ContentDocumentLinks), (SELECT Id FROM Study__r), (SELECT Id FROM Therapeutic_Area_Assignments__r)
                FROM Resource__c
                WHERE Id IN :resIds
        ];
    }
}