/**
* @author        Sravani Dasari
* @date          21/05/2020
* @description   This Controller is used in a Aura LC which pulls Clinical_Trial_Profile__c record information to form a pdf. 
Modification Log:
-----------------------------------------------------------------------------------------------------------------
Developer                Date            Description
-----------------------------------------------------------------------------------------------------------------
Pijush Kar       		13/09/2021       Get base64 encoded data for Mobile App
*/
public without sharing class TrialMatchLearnMoreLinkPDF {
    private static final String base64PNG = 'data:image/png;base64,';

    /**
     * @author        Sravani Dasari
     * @date          21/05/2020
     * @description   This method retrives a Image from static resource.
     * @param         String
     * @return        String
     */
    @AuraEnabled
    public static String getLogoFromStatic(String communityname) {
        String reportlogopath = '/resource/ReportBrandingLogos/' + communityname + '.png';
        try {
            PageReference pr = new PageReference(reportlogopath);
            Blob imageLogo = pr.getContent();
            if (imageLogo != null) {
                return base64PNG + EncodingUtil.base64Encode(imageLogo);
            }
            return base64PNG;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    /**
     * @author        Sravani Dasari
     * @date          21/05/2020
     * @description   This method digets ctpId and returns a ctp record.
     * @param         Id
     * @return        Clinical_Trial_Profile__c
     */
    @AuraEnabled
    public static Clinical_Trial_Profile__c fetchCTPLearnMoreDetails(Id ctpId) {
        Clinical_Trial_Profile__c ctpDetails;
        try {
            ctpDetails = [
                SELECT Id, Study_Code_Name__c, CommunityTemplate__c, Study_Content__c //,
                // Detailed_Description__c
                FROM Clinical_Trial_Profile__c
                WHERE Id = :ctpId
            ];
            return ctpDetails;
        } catch (Exception e) {
            return (Clinical_Trial_Profile__c) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getBase64LearnMoreData(String ctpId) {
        try {
            PageReference page = Page.TrialMatchLearnMorePage;
            page.getParameters().put('CTPId', ctpId);
            Blob content = !Test.isRunningTest() ? page.getContent() : Blob.valueOf('Fake content');
            String encoded = EncodingUtil.base64Encode(content);
            return encoded;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}
