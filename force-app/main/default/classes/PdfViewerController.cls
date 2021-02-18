public without sharing  class PdfViewerController {
    
    
     @AuraEnabled
    public static String getBase64Resource( String resourceId,String language)
    {
           ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(
            ContentDocumentLinkService.class
        );
        ContentDocumentLink cdl = contentDocumentLinkService.getCDLForResource(
            resourceId,
            language
        );
        if (cdl != null) {
            //this.fileName = [SELECT Id, Title__c FROM Resource__c WHERE Id = :resourceId].Title__c;
            return EncodingUtil.base64Encode(
                cdl.ContentDocument.LatestPublishedVersion.VersionData
            );
           
        }
        return null;
    }
}