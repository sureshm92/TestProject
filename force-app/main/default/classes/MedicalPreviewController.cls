/**
* @author        Enugothula Srinath 
* @date          08/01/2021
* @description   This Controller is used in MedicalHistoryPreviewVF page. 
-----------------------------------------------------------------------------------------------------------------
Developer                Date            Description
-----------------------------------------------------------------------------------------------------------------
Srinath       			08/01/2021      All File Types are Preview in Front End
*/


public with sharing class  MedicalPreviewController {
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
        String language = parameters.get('language');
        
        List<ContentDocument> cdlList = [ SELECT
                                         ContentDocument.LatestPublishedVersion.Title,
                                         ContentDocument.LatestPublishedVersion.VersionData,
                                         ContentDocument.LatestPublishedVersion.LanguageCode__c,
                                         ContentDocument.LatestPublishedVersion.fileType
                                         FROM ContentDocument WHERE ID = :resourceId];
        this.pdfBlobDataInBase64StringFormat = EncodingUtil.base64Encode(
            cdlList[0].LatestPublishedVersion.VersionData
        );
        this.fileType = cdlList[0].LatestPublishedVersion.fileType;
        
        this.executeJS = true;
        }
}