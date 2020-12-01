public without sharing class FileUploadController {
    public class FilesWrapper {
        @AuraEnabled
        public List<FileWrapper> listOfFiles;
        @AuraEnabled
        public List<LabelValueItem> listOfLanguages;
        @AuraEnabled
        public String currentLanguageCode;

        public FilesWrapper(List<FileWrapper> listOfFiles, List<LabelValueItem> listOfLanguages) {
            this.listOfFiles = listOfFiles;
            this.listOfLanguages = listOfLanguages;
            if (listOfLanguages != null && listOfLanguages.size() > 0)
                currentLanguageCode = listOfLanguages[0].value;
        }
    }

    public class FileWrapper {
        @AuraEnabled
        public ContentDocument content;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String language;

        public FileWrapper(ContentDocument content, String fileName, String language) {
            this.content = content;
            this.fileName = fileName;
            this.language = language;
        }
    }

    @AuraEnabled
    public static FilesWrapper getResourceFiles(Id resourceId, List<String> docIds) {
        try {
            return createFilesWrapper(resourceId, docIds);
        } catch (Exception e) {
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static FilesWrapper deleteContentDocument(
        String documentId,
        String fileName,
        String resourceId,
        List<String> docIds
    ) {
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id = :documentId];
            return createFilesWrapper(resourceId, docIds);
        } catch (Exception e) {
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static FilesWrapper updateContentDocument(
        String documentId,
        String codeValue,
        String resourceId,
        List<String> docIds
    ) {
        //String codeValue
        try {
            ContentDocument contentDoc = [
                SELECT Id, LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id = :documentId
            ];
            //contentDoc.Title = codeValue;
            ////update contentDoc;
            ContentVersion conversion = [
                SELECT Id, LanguageCode__c
                FROM ContentVersion
                WHERE Id = :contentDoc.LatestPublishedVersionId
                LIMIT 1
            ];
            conversion.LanguageCode__c = codeValue;
            update conversion;
            return createFilesWrapper(resourceId, docIds);
        } catch (Exception e) {
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }

    private static FilesWrapper createFilesWrapper(Id resourceId, List<String> docIds) {
        Map<String, String> languageMap = new Map<String, String>();
        LabelValueItem objLabelValueItem = new LabelValueItem('None', '');
        List<LabelValueItem> labelValueItemList = new List<LabelValueItem>();
        labelValueItemList.add(objLabelValueItem);
        List<LabelValueItem> allLanguagesLVList = SObjectHelper.getPicklistLabelValueList(
            Contact.Language__c
        );
        for (LabelValueItem objItem : allLanguagesLVList) {
            languageMap.put(objItem.value, objItem.Label);
        }
        labelValueItemList.addAll(allLanguagesLVList);
        List<FileWrapper> listOfFileWrappers = new List<FileWrapper>();
        List<ContentDocumentLink> listOfFiles = new List<ContentDocumentLink>();
        if (resourceId != null) {
            listOfFiles = [
                SELECT
                    ContentDocument.Title,
                    ContentDocument.FileType,
                    ContentDocument.LatestPublishedVersion.LanguageCode__c
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :resourceId
            ];
        } else {
            if (!docIds.isEmpty()) {
                List<Id> contentDocumentIds = (List<Id>) docIds;
                listOfFiles = [
                    SELECT
                        ContentDocument.Title,
                        ContentDocument.FileType,
                        ContentDocument.LatestPublishedVersion.LanguageCode__c
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN :contentDocumentIds
                ];
            }
        }
        Set<String> usedLanguages = new Set<String>();
        List<LabelValueItem> availableLanguagesLVList = new List<LabelValueItem>();
        for (ContentDocumentLink contentLink : listOfFiles) {
            listOfFileWrappers.add(
                new FileWrapper(
                    contentLink.ContentDocument,
                    TranslateHelper.getPickListLabel(
                        Contact.Language__c,
                        contentLink.ContentDocument.Title
                    ),
                    languageMap.get(
                        contentLink.ContentDocument.LatestPublishedVersion.LanguageCode__c
                    )
                )
            );
        }
        return new FilesWrapper(listOfFileWrappers, labelValueItemList);
    }
}
