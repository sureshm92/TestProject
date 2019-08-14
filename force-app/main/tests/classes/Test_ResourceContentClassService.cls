@IsTest(IsParallel=true)
public class Test_ResourceContentClassService {

    @TestSetup
    public static void setup() {

        Id articleRecordType = SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType());
        Id videoRecordType = SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_VIDEO, Resource__c.getSObjectType());
        Id studyDocumentRecordType = SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType());
        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'Resource 1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => articleRecordType
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'Resource 2',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                'RecordTypeId' => videoRecordType
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'Resource 3',
                'Document_Type__c' => 'Document',
                'Version_Date__c' => Date.today(),
                'RecordTypeId' => studyDocumentRecordType
        }));
        insert resources;

        Therapeutic_Area__c therapeuticArea = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert therapeuticArea;

        Clinical_Trial_Profile__c study = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        insert study;

        Therapeutic_Area_Assignment__c tAAssignment = (Therapeutic_Area_Assignment__c) TestDataFactory.getSObject(Therapeutic_Area_Assignment__c.getSObjectType());
        tAAssignment.Therapeutic_Area__c = therapeuticArea.Id;
        tAAssignment.Resource__c = resources[1].Id;
        insert tAAssignment;

        List<Res_study__c> resStudies = new List<Res_study__c>();
        resStudies.add((Res_study__c) TestDataFactory.getSObject(Res_study__c.getSObjectType(), new Map<String, Object> {
                'Resource__c' => resources[0].Id,
                'Clinical_Trial_Profile__c' => study.Id
        }));
        resStudies.add((Res_study__c) TestDataFactory.getSObject(Res_study__c.getSObjectType(), new Map<String, Object> {
                'Resource__c' => resources[2].Id,
                'Clinical_Trial_Profile__c' => study.Id
        }));
        insert resStudies;
    }

    @IsTest
    public static void deleteRelatedObjects_Test() {

        List<Resource__c> newList = [SELECT Id, RecordTypeId, Content_Class__c FROM Resource__c ORDER BY Title__c];
        Map<Id, Resource__c> oldMap = new Map<Id, Resource__c>(newList.deepClone(true));
        newList[0].Content_Class__c = ResourceService.RESOURCE_SOURCE_PLATFORM;
        newList[1].Content_Class__c = ResourceService.RESOURCE_SOURCE_STUDY;
        newList[2].Content_Class__c = ResourceService.RESOURCE_SOURCE_PLATFORM;
        Test.startTest();
        new ResourceContentClassService().deleteRelatedObjects(newList, oldMap);
        Test.stopTest();

        List<Resource__c> resources = [
                SELECT Id,
                        RecordTypeId,
                        Content_Class__c,
                (SELECT Id FROM Study__r),
                (SELECT Id FROM Therapeutic_Area_Assignments__r)
                FROM Resource__c
                ORDER BY Title__c
        ];
        System.assertEquals(3, resources.size());
        System.assertEquals(0, resources[0].Study__r.size());
        System.assertEquals(0, resources[1].Therapeutic_Area_Assignments__r.size());
        System.assertEquals(1, resources[2].Study__r.size());
    }
}