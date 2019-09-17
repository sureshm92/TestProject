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
    public static List<ContentDocumentLink> getResourceFiles(String resourceId){
        List<ContentDocumentLink> listOfFiles = new List<ContentDocumentLink>();
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
        }
        return listOfFiles;
    }

    @AuraEnabled
    public static List<String> prepareListOfLanguages(){
        List<String> languagePicklistValues = new List<String>();
        for(String fieldValue : getSelectValues().keySet()){
            languagePicklistValues.add(fieldValue);
        }
        return languagePicklistValues;
    }

    @AuraEnabled
    public static void deleteContentDocument(String documentId){
        delete [SELECT Id,Title,FileType FROM ContentDocument WHERE id=: documentId ];
    }

    @AuraEnabled
    public static void updateContentDocument(String documentId, String codeValue){
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
    }
}