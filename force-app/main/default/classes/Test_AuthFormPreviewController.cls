@IsTest
public class Test_AuthFormPreviewController {
 @TestSetup
    public static void setup() {
        Resource__c singleResource = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType(),
            new Map<String, Object>{
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                    ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                    Resource__c.getSObjectType()
                )
            }
        );
        insert singleResource;
        ContentVersion singleVersion = (ContentVersion) TestDataFactory.getSObject(
            ContentVersion.getSObjectType()
        );
        insert singleVersion;
        singleVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :singleVersion.Id
        ];
        ContentDocumentLink singleLink = (ContentDocumentLink) TestDataFactory.getSObject(
            ContentDocumentLink.getSObjectType(),
            new Map<String, Object>{
                'LinkedEntityId' => singleResource.Id,
                'ContentDocumentId' => singleVersion.ContentDocumentId
            }
        );
        insert singleLink;
    }

    @IsTest
    public static void initData_Positive_Test() {
        List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c];
        System.assertEquals(1, resources.size());
        List<ContentVersion> versions = [SELECT Id, Title, VersionData FROM ContentVersion];
        System.assertEquals(1, versions.size());

        PageReference singlePage = Page.SignedAuthorizationFormPreview;
        Test.setCurrentPage(singlePage);
        AuthFormPreviewController controller = new AuthFormPreviewController();
        ApexPages.currentPage().getParameters().put('resourceId', resources[0].Id);

        Test.startTest();
        controller.initData();
        Test.stopTest();
    }
}