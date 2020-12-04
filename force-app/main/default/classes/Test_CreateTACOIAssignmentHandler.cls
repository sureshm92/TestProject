/**
 * Created By Keyur Shah on 1/12/2020
 */
@isTest
public class Test_CreateTACOIAssignmentHandler {
    @isTest
    public static void test_createTAAsignmentRecords() {
        Id studyDocumentRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Study_Document')
            .getRecordTypeId();
        Resource__c newResource = new Resource__c(
            Title__c = 'Health Highlights: Nov. 20, 2018',
            recordTypeId = studyDocumentRecordTypeId
        );
        insert newResource;

        Therapeutic_Area__c newTA = new Therapeutic_Area__c(Name = 'Cancer');
        insert newTA;

        Id COIRecordTypeId = Schema.SObjectType.Therapeutic_Area__c.getRecordTypeInfosByDeveloperName()
            .get('Condition_of_Interests')
            .getRecordTypeId();
        List<Therapeutic_Area__c> newCOIs = new List<Therapeutic_Area__c>();
        newCOIs.add(
            new Therapeutic_Area__c(Name = 'Metastatic Cancer', recordTypeId = COIRecordTypeId)
        );
        insert newCOIs;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        ContentDocument document = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            LIMIT 1
        ];
        CreateTACOIAssignmentHandler.COIWrapper objCOIWrapper = new CreateTACOIAssignmentHandler.COIWrapper();
        objCOIWrapper.chosenConditions = String.valueof(newCOIs[0].Id);
        objCOIWrapper.resourceId = newResource.Id;
        objCOIWrapper.docIds = String.valueof(document.Id);

        Test.startTest();
        CreateTACOIAssignmentHandler.createTAAsignmentRecords(
            new List<CreateTACOIAssignmentHandler.COIWrapper>{ objCOIWrapper }
        );
        System.assertEquals(1, [SELECT Id FROM Therapeutic_Area_Assignment__c].size());
        System.assertEquals(
            2,
            [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :document.Id].size()
        );
        Test.stopTest();
    }
}
