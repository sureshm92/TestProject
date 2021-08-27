public with sharing class FileContainer {
    @AuraEnabled( cacheable = true )
    public static List<ContentDocument> getFiles() {
        //return [SELECT ContentDocument.id FROM ContentDocumentLink WHERE LinkedEntityId = '06954000001CAJQAA4' ORDER BY ContentDocument.LastModifiedDate DESC LIMIT 1];
    return [SELECT id, title,filetype,parentid,ownerid from ContentDocument where ownerId='00554000008tlKmAAI'];
    }     
}