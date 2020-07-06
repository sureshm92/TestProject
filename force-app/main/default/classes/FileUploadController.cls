public without sharing class FileUploadController {
    
    public class FilesWrapper {
        @AuraEnabled public List<FileWrapper> listOfFiles;
        @AuraEnabled public List<LabelValueItem> listOfLanguages;
        @AuraEnabled public String currentLanguageCode;
        
        public FilesWrapper(List<FileWrapper> listOfFiles, List<LabelValueItem> listOfLanguages){
            this.listOfFiles = listOfFiles;
            this.listOfLanguages = listOfLanguages;
            if(listOfLanguages != null && listOfLanguages.size() > 0) currentLanguageCode = listOfLanguages[0].value;
        }
    }
    
    public class FileWrapper{
        @AuraEnabled public ContentDocument content;
        @AuraEnabled public String fileName;
        
        public FileWrapper(ContentDocument content, String fileName){
            this.content = content;
            this.fileName = fileName;
        }
    }
    
    
    @AuraEnabled
    public static FilesWrapper getResourceFiles(Id resourceId){
        try{
            return createFilesWrapper(resourceId);
        }catch (Exception e){
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static FilesWrapper deleteContentDocument(String documentId,String fileName, String resourceId){
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id =: documentId ];
            return createFilesWrapper(resourceId);
        }catch (Exception e){
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static FilesWrapper updateContentDocument(String documentId, String codeValue, String resourceId){//String codeValue
        try{
            ContentDocument contentDoc = [
                    SELECT Id,LatestPublishedVersionId
                    FROM ContentDocument
                    WHERE Id =: documentId
            ];
            //contentDoc.Title = codeValue;
            ////update contentDoc;
            ContentVersion conversion=  [SELECT Id,LanguageCode__c
                    FROM ContentVersion where Id=: contentDoc.LatestPublishedVersionId limit 1];
            conversion.LanguageCode__c=codeValue;
            update conversion;
            return createFilesWrapper(resourceId);
        }catch (Exception e){
            return (FilesWrapper) AuraHelper.throwException(e);
        }
    }
    
    private static FilesWrapper createFilesWrapper(Id resourceId){
        List<LabelValueItem> allLanguagesLVList = SObjectHelper.getPicklistLabelValueList(Contact.Language__c);
        List<FileWrapper> listOfFileWrappers = new List<FileWrapper>();
        List<ContentDocumentLink> listOfFiles = new List<ContentDocumentLink>();
        if(resourceId != null){
            listOfFiles = [
                    SELECT ContentDocument.Title,
                            ContentDocument.FileType
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :resourceId
            ];
        }
        Set<String> usedLanguages = new Set<String>();
        List<LabelValueItem> availableLanguagesLVList = new List<LabelValueItem>();
        for(ContentDocumentLink contentLink : listOfFiles) {
            usedLanguages.add(contentLink.ContentDocument.Title);
            listOfFileWrappers.add(new FileWrapper(
                    contentLink.ContentDocument,
                    TranslateHelper.getPickListLabel(Contact.Language__c, contentLink.ContentDocument.Title)
            ));
        }
        for(LabelValueItem lvi : allLanguagesLVList){
            if(!usedLanguages.contains(lvi.value)) availableLanguagesLVList.add(lvi);
        }
        return new FilesWrapper(listOfFileWrappers, availableLanguagesLVList);
    }
}