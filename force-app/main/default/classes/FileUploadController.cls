public without sharing class FileUploadController {
    public static final String FU_DEFAULT_LANGUAGE = 'English';

    public static Map<String, String> getSelectValues(){
        Map<String, String> mapOfPicklistValues = new Map<String, String>();
        if (mapOfPicklistValues == null || mapOfPicklistValues.isEmpty()) {
            Schema.DescribeFieldResult fieldResult = Resource__c.Language__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry fieldValue : picklistEntries){
                mapOfPicklistValues.put(fieldValue.getLabel(), fieldValue.getValue());
            }
        }
        return mapOfPicklistValues;
    }

    @AuraEnabled
    public static FileWrapper getResourceFiles(String resourceId){
        List<String> languagePicklistValues = new List<String>();
        List<String> validLanguages = new List<String>();
        List<ContentDocumentLink> listOfFiles = new List<ContentDocumentLink>();
        for(String fieldValue : getSelectValues().keySet()){
            languagePicklistValues.add(fieldValue);
        }

        if(resourceId != '' && resourceId != null){
            listOfFiles = [
                SELECT  ContentDocument.Title,
                		ContentDocument.FileType
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: resourceId
            ];
        }
        for(ContentDocumentLink contentLink : listOfFiles){
            contentLink.ContentDocument.Title = TranslateHelper.getPickListLabel(Contact.Language__c, contentLink.ContentDocument.Title);
            for(Integer i=0; i<languagePicklistValues.size(); i++){
                if(languagePicklistValues[i] == contentLink.ContentDocument.Title){
                    languagePicklistValues.remove(i);
                    break;
                }
            }
        }
        FileWrapper fileWrapperObject = new FileWrapper(listOfFiles, languagePicklistValues);
        return fileWrapperObject;
    }

    @AuraEnabled
    public static FileWrapper deleteContentDocument(String documentId, String resourceId){
        FileWrapper fileWrapperObj;
        delete [SELECT Id,Title,FileType FROM ContentDocument WHERE id=: documentId ];
        fileWrapperObj = getResourceFiles(resourceId);
        return fileWrapperObj;
    }

    @AuraEnabled
    public static FileWrapper updateContentDocument(String documentId, String codeValue, String resourceId){
        FileWrapper fileWrapperObj;
        ContentDocument contentDoc = [
                SELECT Id,Title,FileType
                FROM ContentDocument
                WHERE Id=: documentId
        ];
        if(getSelectValues().get(codeValue) == null){
            codeValue = FU_DEFAULT_LANGUAGE;
        }
        contentDoc.Title = getSelectValues().get(codeValue);
        update contentDoc;
        fileWrapperObj = getResourceFiles(resourceId);
        return fileWrapperObj;
    }

    public class FileWrapper{
        @AuraEnabled public List<ContentDocumentLink> listOfFiles;
        @AuraEnabled public List<String> listOfLanguages;

        public FileWrapper(List<ContentDocumentLink> listOfFiles, List<String> listOfLanguages){
            this.listOfFiles = listOfFiles;
            this.listOfLanguages = listOfLanguages;
        }
    }
}