@IsTest
public class Test_ContentDocumentLinkTriggerHandler {

    @IsTest
    public static void beforeInsert_Positive_Test() {

        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType())
        }));
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '1TestJPG.JPG'
        }));
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '2TestPDF.pdf'
        }));
        insert versions;
        versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN (:versions[0].Id, :versions[1].Id) ORDER BY PathOnClient];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[0].Id,
                'ContentDocumentId' => versions[0].ContentDocumentId
        }));
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[1].Id,
                'ContentDocumentId' => versions[1].ContentDocumentId
        }));

        Test.startTest();
        insert links;
        Test.stopTest();

        links = [SELECT Id, Visibility, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN (:resources[0].Id, :resources[1].Id)];
        System.assertEquals('I', links[0].ShareType);
        System.assertEquals('I', links[1].ShareType);
        System.assertEquals('AllUsers', links[0].Visibility);
        System.assertEquals('AllUsers', links[1].Visibility);
    }

    @IsTest
    public static void beforeInsert_Incompatible_Types_Test() {

        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType())
        }));
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '1TestJPG.JPG'
        }));
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '2TestPDF.pdf'
        }));
        insert versions;
        versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN (:versions[0].Id, :versions[1].Id) ORDER BY PathOnClient];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[0].Id,
                'ContentDocumentId' => versions[1].ContentDocumentId
        }));
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[1].Id,
                'ContentDocumentId' => versions[0].ContentDocumentId
        }));
        Boolean isExceptionThrown = false;

        Test.startTest();
        try {
            insert links;
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, isExceptionThrown);
    }

    @IsTest
    public static void afterInsert_Positive_Test() {

        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())
        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R2',
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType())
        }));
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '1TestJPG.JPG'
        }));
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '2TestPDF.pdf'
        }));
        insert versions;
        versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN (:versions[0].Id, :versions[1].Id) ORDER BY PathOnClient];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[0].Id,
                'ContentDocumentId' => versions[0].ContentDocumentId
        }));
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[1].Id,
                'ContentDocumentId' => versions[1].ContentDocumentId
        }));

        Test.startTest();
        insert links;
        Test.stopTest();

        resources = [SELECT Id, Image__c FROM Resource__c ORDER BY Title__c];
        System.assertEquals(2, resources.size());
        System.assert(String.isNotBlank(resources[0].Image__c));
        System.assert(resources[0].Image__c.contains(versions[0].Id));
        System.assert(String.isBlank(resources[1].Image__c));
    }
}
