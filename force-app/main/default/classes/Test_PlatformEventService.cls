/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest
public with sharing class Test_PlatformEventService {

    @IsTest
    public static void remindEventFireContentDocumentLink_Test() {
        List<Resource__c> resources = new List<Resource__c>();
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        }));
        resources.add((Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R2',
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT, Resource__c.getSObjectType()),
                'document_type__c' => ResourceService.RESOURCE_TYPE_DOCUMENT
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

    @IsTest
    public static void remindEventFireTherapeuticAreaAssignment_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        insert resource;
        Therapeutic_Area__c therapeuticArea = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert therapeuticArea;
        Therapeutic_Area_Assignment__c taa = (Therapeutic_Area_Assignment__c) TestDataFactory.getSObject(Therapeutic_Area_Assignment__c.getSObjectType(),new Map<String, Object> {
                'Resource__c' => resource.Id,
                'Therapeutic_Area__c' => therapeuticArea.Id
        });
        Test.startTest();
        insert taa;
        Test.stopTest();
        List<Resource__c> resources = [SELECT Id, (SELECT Id FROM Therapeutic_Area_Assignments__r) FROM Resource__c];
        System.assertEquals(1, resources[0].Therapeutic_Area_Assignments__r.size());
    }

    @IsTest
    public static void remindEventFireResStudy_Test() {
        Resource__c resource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object> {
                'Title__c' => 'R1',
                'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                'RecordTypeId' => SchemaUtil.getRecordTypeIdByName(ResourceService.RESOURCE_TYPE_ARTICLE, Resource__c.getSObjectType())

        });
        insert resource;
        Clinical_Trial_Profile__c clinicalTrialProfile = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        insert clinicalTrialProfile;
        Res_study__c resStudy = (Res_study__c) TestDataFactory.getSObject(Res_study__c.getSObjectType(),new Map<String, Object> {
                'Resource__c' => resource.Id,
                'Clinical_Trial_Profile__c' => clinicalTrialProfile.Id
        });
        Test.startTest();
        insert resStudy;
        Test.stopTest();
        List<Resource__c> resources = [SELECT Id, (SELECT Id FROM Study__r) FROM Resource__c];
        System.assertEquals(1, resources[0].Study__r.size());
    }
}