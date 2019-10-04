/**
 * Created by dmytro.fedchyshyn on 19.08.2019.
 */

@IsTest
public with sharing class Test_ResourceReminderRemote {

    @IsTest
    public static void getActiveRemindersPlatformTAnoTAReminder_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Test.startTest();
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
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
        List<ResourceReminderService.Reminder> reminders =  ResourceReminderRemote.getReminders(resource.Id);
        Test.stopTest();

        System.assert(reminders.isEmpty());
    }

    @IsTest
    static void getRemindersWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceReminderService.class, StubFactory.newInstance(ResourceReminderService.class)
                .when('getActiveReminders')
                .then(new AuraHandledException('exception'))
                .getInstance()
        );
        Test.startTest();
        try {
            ResourceReminderRemote.getReminders(null);

        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

}