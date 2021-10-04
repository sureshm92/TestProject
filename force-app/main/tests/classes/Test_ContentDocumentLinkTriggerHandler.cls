@IsTest
public class Test_ContentDocumentLinkTriggerHandler {
    @IsTest
    public static void beforeInsert_Positive_Test() {
        List<Resource__c> resources = new List<Resource__c>();
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_TYPE_ARTICLE,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '1TestJPG.JPG' }
            )
        );
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '2TestPDF.pdf' }
            )
        );
        insert versions;
        versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN (:versions[0].Id, :versions[1].Id)
            ORDER BY PathOnClient
        ];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[0].Id,
                    'ContentDocumentId' => versions[0].ContentDocumentId
                }
            )
        );
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[1].Id,
                    'ContentDocumentId' => versions[1].ContentDocumentId
                }
            )
        );

        Test.startTest();
        insert links;
        Test.stopTest();

        links = [
            SELECT Id, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (:resources[0].Id, :resources[1].Id)
        ];
        System.assertEquals('I', links[0].ShareType);
        System.assertEquals('I', links[1].ShareType);
        System.assertEquals('AllUsers', links[0].Visibility);
        System.assertEquals('AllUsers', links[1].Visibility);
    }

    @IsTest
    public static void beforeInsert_Incompatible_Types_Test() {
        List<Resource__c> resources = new List<Resource__c>();
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_TYPE_ARTICLE,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '1TestJPG.JPG' }
            )
        );
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '2TestPDF.pdf' }
            )
        );
        insert versions;
        versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN (:versions[0].Id, :versions[1].Id)
            ORDER BY PathOnClient
        ];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<ContentDocumentLink> links1 = new List<ContentDocumentLink>();
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[0].Id,
                    'ContentDocumentId' => versions[1].ContentDocumentId
                }
            )
        );
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[1].Id,
                    'ContentDocumentId' => versions[0].ContentDocumentId
                }
            )
        );

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
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Title__c' => 'R1',
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_TYPE_ARTICLE,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Title__c' => 'R2',
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '1TestJPG.JPG' }
            )
        );
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '2TestPDF.pdf' }
            )
        );
        insert versions;
        versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN (:versions[0].Id, :versions[1].Id)
            ORDER BY PathOnClient
        ];
        System.assertEquals(2, versions.size());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[0].Id,
                    'ContentDocumentId' => versions[0].ContentDocumentId
                }
            )
        );
        links.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => resources[1].Id,
                    'ContentDocumentId' => versions[1].ContentDocumentId
                }
            )
        );

        Test.startTest();
        insert links;

        Test.stopTest();

        resources = [SELECT Id, Image__c FROM Resource__c ORDER BY Title__c];
        System.assertEquals(2, resources.size());
        System.assert(String.isNotBlank(resources[0].Image__c));
        System.assert(resources[0].Image__c.contains(versions[0].Id));
        System.assert(String.isBlank(resources[1].Image__c));
    }
    @isTest
    public static void testRestrictFiles() {
        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
        insert piAccount;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = piAccount.Id
        );
        insert participant;

        List<Resource__c> resources = new List<Resource__c>();
        resources.add(
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                    'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(
                        ResourceService.RESOURCE_TYPE_ARTICLE,
                        Resource__c.getSObjectType()
                    )
                }
            )
        );
        insert resources;
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '1TestJPG.JPG' }
            )
        );
        versions.add(
            (ContentVersion) TestDataFactory.getSObject(
                ContentVersion.getSObjectType(),
                new Map<String, Object>{ 'PathOnClient' => '2TestPDF.pdf' }
            )
        );
        insert versions;

        versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN (:versions[0].Id, :versions[1].Id)
            ORDER BY PathOnClient
        ];

        List<ContentDocumentLink> links1 = new List<ContentDocumentLink>();
        links1.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => participant.Id,
                    'ContentDocumentId' => versions[0].ContentDocumentId
                }
            )
        );
        links1.add(
            (ContentDocumentLink) TestDataFactory.getSObject(
                ContentDocumentLink.getSObjectType(),
                new Map<String, Object>{
                    'LinkedEntityId' => participant.Id,
                    'ContentDocumentId' => versions[1].ContentDocumentId
                }
            )
        );
        insert links1;
        Test.startTest();
        ContentDocumentLinkService objConDocLinkService = ContentDocumentLinkService.getInstance();
        ContentDocument conDoc = new ContentDocument(Id = versions[0].ContentDocumentId);

        List<ContentDocument> conDocList = new List<ContentDocument>();
        conDocList.add(conDoc);

        objConDocLinkService.deleteFileNamesAndCalculateSize(conDocList);
        objConDocLinkService.shareParticipantReportsWithCommunityUsers(links1);
        objConDocLinkService.restrictFiles(links1);
        objConDocLinkService.addFileNamesAndCalculateSize(links1);
        objConDocLinkService.getCDLForResource(participant.Id, 'en_US');
        objConDocLinkService.getContentDocumentLinksByResourcesIds(
            new Set<String>{ participant.Id }
        );
        Test.stopTest();
    }
}
