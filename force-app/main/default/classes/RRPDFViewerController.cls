public with sharing class RRPDFViewerController {

    public String fileName { get; set; }
    public String pdfBlobDataInBase64StringFormat { get; set; }
    public Boolean executeJS { get; set; } {
        executeJS = false;
    }

    public RRPDFViewerController() {

        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String resourceId = parameters.get('resourceId');
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String documentLinksQuery =
                'SELECT ContentDocument.LatestPublishedVersion.Title, ' +
                        'ContentDocument.LatestPublishedVersion.VersionData ' +
                        'FROM ContentDocumentLink ' +
                        'WHERE LinkedEntityId = \'' + resourceId + '\' ' +
                        'ORDER BY ContentDocument.CreatedDate DESC';
        List<ContentDocumentLink> documentLinks = (List<ContentDocumentLink>) databaseProxy.query(documentLinksQuery);
        if (!documentLinks.isEmpty()) {
            this.fileName = documentLinks[0].ContentDocument.LatestPublishedVersion.Title;
            this.pdfBlobDataInBase64StringFormat = EncodingUtil.base64Encode(documentLinks[0].ContentDocument.LatestPublishedVersion.VersionData);
            this.executeJS = true;
        }
    }
}