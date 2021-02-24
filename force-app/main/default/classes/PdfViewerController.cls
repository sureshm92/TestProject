/**
 * Created by Sandeep on 23.02.2021.
 */
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
           
            return EncodingUtil.base64Encode(
                cdl.ContentDocument.LatestPublishedVersion.VersionData
            );
           
        }
        return null;
    }
}