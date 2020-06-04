/**
* @author        Enugothula Srinath 
* @date          21/05/2020
* @description   This Controller is used in a Aura LC which pulls Clinical_Trial_Profile__c record information to form a pdf. 
Modification Log:
-----------------------------------------------------------------------------------------------------------------
Developer                Date            Description
-----------------------------------------------------------------------------------------------------------------
Srinath       			21/05/2020      			Initial Version
*/
public class TrialMatchLearnMoreLinkPDF {
    public static final String IQVIA_LOGO = 'IQVIA';
    private static String base64PNG = 'data:image/png;base64,';
    
    /**
* @author        Enugothula Srinath
* @date          21/05/2020
* @description   This method retrives a Image from static resource.
* @param         Id
* @return        String 
*/
    @AuraEnabled
    public static String getLogoFromStatic() {
        try{
            Blob imageLogo = [SELECT Body FROM StaticResource WHERE Name = :IQVIA_LOGO].Body;
            if (imageLogo != null) {
                return base64PNG + EncodingUtil.base64Encode(imageLogo);   
            }
            return base64PNG;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
    
    /**
* @author        Enugothula Srinath
* @date          21/05/2020
* @description   This method digets ctpId and returns a ctp record.
* @param         Id
* @return        Clinical_Trial_Profile__c 
*/
    @AuraEnabled
    public static Clinical_Trial_Profile__c fetchCTPLearnMoreDetails(Id ctpId) {
        Clinical_Trial_Profile__c ctpDetails;
        try {
            ctpDetails = [SELECT Id,Study_Code_Name__c,Detailed_Description__c FROM Clinical_Trial_Profile__c WHERE Id =:ctpId];
            return ctpDetails;
        } catch (Exception e) {
            return (Clinical_Trial_Profile__c) AuraHelper.throwException(e);
        }
    }
}