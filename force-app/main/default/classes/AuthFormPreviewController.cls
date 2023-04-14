//test
public without sharing class AuthFormPreviewController {
    
   	public String fileName { get; set; }
    public String fileType { get; set; }
    public String pdfBlobDataInBase64StringFormat { get; set; }
    public Boolean executeJS { get; set; }
    {
        executeJS = false;
    }

    public void initData() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String resourceId = parameters.get('resourceId');
        system.debug('resourceId'+resourceId);
        String language = parameters.get('language');
        
        List<ContentDocument> cdlList = [ SELECT
                                         ContentDocument.LatestPublishedVersion.Title,
                                         ContentDocument.LatestPublishedVersion.VersionData,
                                         ContentDocument.LatestPublishedVersion.LanguageCode__c,
                                         ContentDocument.LatestPublishedVersion.fileType
                                         FROM ContentDocument WHERE ID = :resourceId];
        
        if(!cdlList.isEmpty()){
            this.pdfBlobDataInBase64StringFormat = EncodingUtil.base64Encode(
                cdlList[0].LatestPublishedVersion.VersionData
            );
            this.fileType = cdlList[0].LatestPublishedVersion.fileType;
        }
        this.executeJS = true;
        }
}
