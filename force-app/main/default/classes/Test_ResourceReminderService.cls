/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest(IsParallel=true)
public with sharing class Test_ResourceReminderService {

    @IsTest
    public static void getActiveRemindersPlatformTAnoTAReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void getActiveRemindersX3rdPartyNoTaReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void StudySpecificAndPlatformTAnoImageReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void StudySpecificNoStudyReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void StudyDocumentNoStudyReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void StudyDocumentTypeDocumentNoFileReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType()),
                'document_type__c' => ResourceService.RESOURCE_TYPE_DOCUMENT

        });
        insert resource;
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(!reminders.isEmpty());
    }

    @IsTest
    public static void negativeIdResourceTest() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Id' => TestDataFactory.getFakeId(Resource__c.getSObjectType()),
                'Title__c' => 'R1',
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType()),
                'document_type__c' => ResourceService.RESOURCE_TYPE_DOCUMENT

        });
        Test.startTest();
        ResourceReminderService.Reminder[] reminders = new ResourceReminderService().getActiveReminders(resource.Id);
        Test.stopTest();
        System.assert(reminders.isEmpty());
    }
}