@IsTest
public class Test_ContentDocumentTriggerHandler {

    @IsTest
    public static void beforeDelete_Positive_Test() {

        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())
        }));
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add((ContentVersion) TestDataFactory.getSObject(ContentVersion.getSObjectType(), new Map<String, Object> {
                'PathOnClient' => '1TestJPG.JPG'
        }));
        insert versions;
        versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versions[0].Id];
        System.assertEquals(1, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add((ContentDocumentLink) TestDataFactory.getSObject(ContentDocumentLink.getSObjectType(), new Map<String, Object> {
                'LinkedEntityId' => resources[0].Id,
                'ContentDocumentId' => versions[0].ContentDocumentId
        }));
        insert links;

        resources = [SELECT Id, Image__c FROM Resource__c];
        System.assertEquals(1, resources.size());
        System.assert(String.isNotBlank(resources[0].Image__c));

        Test.startTest();
        delete [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : versions[0].Id];
        Test.stopTest();

        resources = [SELECT Id, Image__c FROM Resource__c];
        System.assertEquals(1, resources.size());
        System.assert(String.isBlank(resources[0].Image__c));
    }
}