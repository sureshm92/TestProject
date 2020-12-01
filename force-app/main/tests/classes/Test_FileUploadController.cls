/**
 * Created by Yulia Yakushenkova on 26.03.2020.
 */

@IsTest
private class Test_FileUploadController {
    @IsTest
    static void test_createFilesWrapper() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);
        FileUploadController.FilesWrapper filesWrapper;

        Test.startTest();
        filesWrapper = FileUploadController.getResourceFiles(accountId, null);
        System.assertEquals('Penguins', filesWrapper.listOfFiles[0].fileName);
        filesWrapper = FileUploadController.getResourceFiles(
            null,
            new List<String>{ String.valueof(documentId) }
        );
        System.assertEquals('Penguins', filesWrapper.listOfFiles[0].fileName);

        Test.stopTest();
    }

    @IsTest
    static void test_updateContentDocument() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);

        Test.startTest();
        FileUploadController.updateContentDocument(documentId, 'Code Value', accountId, null);
        Test.stopTest();

        ContentDocument updatedDocument = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            WHERE Id = :documentId
        ];
        ContentVersion conversion = [
            SELECT Id, LanguageCode__c
            FROM ContentVersion
            WHERE Id = :updatedDocument.LatestPublishedVersionId
        ];
        System.assertEquals('Code Value', conversion.LanguageCode__c);
    }

    @IsTest
    static void test_deleteContentDocument() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);

        Test.startTest();
        FileUploadController.deleteContentDocument(
            documentId,
            'testDocumentAttach',
            accountId,
            null
        );
        Test.stopTest();

        List<ContentDocument> deletedDocument = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
        ];
        System.assert(deletedDocument.isEmpty());
    }

    // ---------------------------------------------------------------------------------------------------------

    static Id getAccountId() {
        Account account = new Account(Name = 'TEST_ACCT');
        insert account;

        createContentVersion();
        return account.Id;
    }

    static Id createDocumentLinkAndGetId(Id accountId) {
        ContentDocument document = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            LIMIT 1
        ];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = accountId;
        cdl.ContentDocumentId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        return document.Id;
    }

    static void createContentVersion() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
    }
}
