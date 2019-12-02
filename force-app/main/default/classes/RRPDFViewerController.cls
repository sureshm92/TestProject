public with sharing class RRPDFViewerController {
    
    public String fileName { get; set; }
    public String pdfBlobDataInBase64StringFormat { get; set; }
    public Boolean executeJS { get; set; } {
        executeJS = false;
    }
    
    public void initData() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String resourceId = parameters.get('resourceId');
        String language = parameters.get('language');
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        ContentDocumentLink cdl = contentDocumentLinkService.getCDLForResource(resourceId, language);
        if (cdl != null) {
            this.fileName = [SELECT Id, Title__c FROM Resource__c WHERE Id =  :resourceId].Title__c;
            this.pdfBlobDataInBase64StringFormat = EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
            this.executeJS = true;
        }
    }
}
