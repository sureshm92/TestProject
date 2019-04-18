public with sharing class RRPDFViewerController {

    public String fileName { get; set; }
    public String pdfBlobDataInBase64StringFormat { get; set; }
    public Boolean executeJS { get; set; } {
        executeJS = false;
    }

    public RRPDFViewerController() {}

    public void initData() {

        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String resourceId = parameters.get('resourceId');
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        List<ContentDocumentLink> documentLinks = contentDocumentLinkService.getContentDocumentLinksByResourcesIds(new Set<String>{resourceId});
        if (!documentLinks.isEmpty()) {
            this.fileName = documentLinks[0].ContentDocument.LatestPublishedVersion.Title;
            this.pdfBlobDataInBase64StringFormat = EncodingUtil.base64Encode(documentLinks[0].ContentDocument.LatestPublishedVersion.VersionData);
            this.executeJS = true;
        }
    }
}