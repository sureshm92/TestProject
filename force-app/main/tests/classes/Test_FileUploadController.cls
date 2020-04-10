/**
 * Created by Yulia Yakushenkova on 26.03.2020.
 */

@IsTest
private class Test_FileUploadController {

    @IsTest
    static void test_createFilesWrapper() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);

        Test.startTest();
        FileUploadController.getResourceFiles(accountId);
        Test.stopTest();
    }

    @IsTest
    static void test_updateContentDocument() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);

        Test.startTest();
        FileUploadController.updateContentDocument(documentId, 'Code Value', accountId);
        Test.stopTest();

        ContentDocument updatedDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :documentId];
        System.assertEquals('Code Value', updatedDocument.Title);
    }

    @IsTest
    static void test_deleteContentDocument() {
        Id accountId = getAccountId();
        Id documentId = createDocumentLinkAndGetId(accountId);

        Test.startTest();
        FileUploadController.deleteContentDocument(documentId, accountId);
        Test.stopTest();

        List<ContentDocument> deletedDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assert(deletedDocument.isEmpty());
    }

    // ---------------------------------------------------------------------------------------------------------

    static Id getAccountId () {
        Account account = new Account(Name='TEST_ACCT');
        insert account;

        createContentVersion();
        return account.Id;
    }

    static Id createDocumentLinkAndGetId(Id accountId) {
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

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