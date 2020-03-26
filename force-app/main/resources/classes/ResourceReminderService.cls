/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourceReminderService {
    final List<Type> reminders = new List<Type>{
            PlatformTAnoTAReminder.class,
            X3rdPartyNoTaReminder.class,
            StudySpecificAndPlatformTAnoImageReminder.class,
            StudySpecificNoStudyReminder.class,
            StudyDocumentNoStudyReminder.class,
            StudyDocumentTypeDocumentNoFileReminder.class
    };

    public List<Reminder> getActiveReminders(Id resId) {
        List<Reminder> activeReminders = new List<Reminder>();
        List<Reminder> allReminders = this.getAllReminder();
        System.debug('allReminders: ' + allReminders);
        Set<String> fieldsQuery = this.getFields(allReminders);
        String queryResource = this.buildQuery(resId, fieldsQuery);
        Resource__c resource = this.getResource(queryResource);
        if (resource != null) {
            for (Reminder reminder : allReminders) {
                if (reminder.isActive(resource)) {
                    activeReminders.add(reminder);
                }
            }
        }
        return activeReminders;
    }

    private Resource__c getResource(String queryResource) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Resource__c> resources = (List<Resource__c>) databaseProxy.query(queryResource);
        System.debug('resources: ' + resources);
        if (!resources.isEmpty()) {
            return resources[0];
        }
        return null;
    }

    private List<Reminder> getAllReminder() {
        List<Reminder> allReminders = new List<Reminder>();
        for (Type typeObj : reminders) {
            allReminders.add((Reminder) typeObj.newInstance());
        }
        return allReminders;
    }

    private Set<String> getFields(List<Reminder> allReminders) {
        Set<String> fieldsQuery = new Set<String>();
        for (Reminder reminder : allReminders) {
            fieldsQuery.addAll(reminder.resourceFields);
        }
        return fieldsQuery;
    }

    private String buildQuery(Id resId, Set<String> fieldsQuery) {
        return 'SELECT ' + String.join(new List<String>(fieldsQuery), ', ') + ' FROM Resource__c ' + 'WHERE Id = \'' + resId + '\'';
    }

    public abstract class Reminder {
        @AuraEnabled
        public String reminderLabel;
        @AuraEnabled
        public List<String> resourceFields;
        @AuraEnabled
        public String cssColor = 'red-text';
        public abstract Boolean isActive(Resource__c resource);
    }

    class PlatformTAnoTAReminder extends Reminder {
        public PlatformTAnoTAReminder() {
            reminderLabel = Label.Reminder_PlatformTA_No_TA;
            resourceFields = new List<String>{
                    'Content_Class__c',
                    '(SELECT Id FROM Therapeutic_Area_Assignments__r)'
            };
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.Content_Class__c)
                    && ResourceService.RESOURCE_SOURCE_PLATFORM.equalsIgnoreCase(resource.Content_Class__c)
                    && (resource.Therapeutic_Area_Assignments__r == null || resource.Therapeutic_Area_Assignments__r.isEmpty())) {
                isActive = true;
            }
            return isActive;
        }
    }

    class X3rdPartyNoTaReminder extends Reminder {
        public X3rdPartyNoTaReminder() {
            reminderLabel = Label.Reminder_3rd_Party_No_TA;
            resourceFields = new List<String>{
                    'Content_Class__c',
                    '(SELECT Id FROM Therapeutic_Area_Assignments__r)'
            };
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.Content_Class__c)
                    && ResourceService.RESOURCE_SOURCE_THIRD_PARTY.equalsIgnoreCase(resource.Content_Class__c)
                    && (resource.Therapeutic_Area_Assignments__r == null || resource.Therapeutic_Area_Assignments__r.isEmpty())) {
                isActive = true;
            }
            return isActive;
        }
    }

    class StudySpecificAndPlatformTAnoImageReminder extends Reminder {
        public StudySpecificAndPlatformTAnoImageReminder() {
            reminderLabel = Label.Reminder_Study_Specific_And_PlatformTA_No_Image;
            resourceFields = new List<String>{
                    'Content_Class__c',
                    'Image__c'
            };
            cssColor = 'orange-text';
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.Content_Class__c)
                    && (ResourceService.RESOURCE_SOURCE_STUDY.equalsIgnoreCase(resource.Content_Class__c) || ResourceService.RESOURCE_SOURCE_PLATFORM.equalsIgnoreCase(resource.Content_Class__c))
                    && String.isBlank(resource.Image__c)) {
                isActive = true;
            }
            return isActive;
        }
    }

    class StudySpecificNoStudyReminder extends Reminder {
        public StudySpecificNoStudyReminder() {
            reminderLabel = Label.Reminder_Study_Specific_No_Study;
            resourceFields = new List<String>{
                    'Content_Class__c',
                    '(SELECT Id FROM Study__r)'
            };
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.Content_Class__c)
                    && ResourceService.RESOURCE_SOURCE_STUDY.equalsIgnoreCase(resource.Content_Class__c)
                    && (resource.Study__r == null || resource.Study__r.isEmpty())) {
                isActive = true;
            }
            return isActive;
        }
    }

    class StudyDocumentNoStudyReminder extends Reminder {
        public StudyDocumentNoStudyReminder() {
            reminderLabel = Label.Reminder_Study_Document_No_Study;
            resourceFields = new List<String>{
                    'RecordType.DeveloperName',
                    '(SELECT Id FROM Study__r)'
            };
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.RecordType.DeveloperName)
                    && ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT.equalsIgnoreCase(resource.RecordType.DeveloperName)
                    && (resource.Study__r == null || resource.Study__r.isEmpty())) {
                isActive = true;
            }
            return isActive;
        }
    }

    class StudyDocumentTypeDocumentNoFileReminder extends Reminder {
        public StudyDocumentTypeDocumentNoFileReminder() {
            reminderLabel = Label.Reminder_Study_Document_Type_Document_No_File;
            resourceFields = new List<String>{
                    'RecordType.DeveloperName',
                    'document_type__c',
                    '(SELECT ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks)'
            };
            cssColor = 'orange-text';
        }
        public override Boolean isActive(Resource__c resource) {
            Boolean isActive = false;
            if (String.isNotBlank(resource.RecordType.DeveloperName)
                    && ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT.equalsIgnoreCase(resource.RecordType.DeveloperName)
                    && String.isNotBlank(resource.document_type__c)
                    && ResourceService.RESOURCE_TYPE_DOCUMENT.equalsIgnoreCase(resource.document_type__c)
                    && (resource.ContentDocumentLinks == null || resource.ContentDocumentLinks.isEmpty())) {
                isActive = true;
            }
            return isActive;
        }
    }
}