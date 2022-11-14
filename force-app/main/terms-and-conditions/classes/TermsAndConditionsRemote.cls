/**
 * Created by Leonid Bartenev
 */

public without sharing class TermsAndConditionsRemote {
    class TCData {
        Terms_And_Conditions__c tc;
        Datetime acceptedDate;
        Boolean isAccepted;
        Clinical_Trial_Profile__c trial;
    }

    @AuraEnabled
    public static String getPortalTcData(Boolean useDefaultCommunity) {
        try {
            return JSON.serialize(getTCData(TermsAndConditions.getPortalTC(useDefaultCommunity)));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getTrialTcData(Id ctpId) {
        try {
            TCData tcData = getTCData(TermsAndConditions.getTrialTC(ctpId));
            tcData.trial = StudyTrialService.getFullTrial(ctpId);
            return JSON.serialize(tcData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string generatePDF(Id ppId) {
        Id contId;
        string retUrl;

        try {
            List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
            List<ContentDistribution> contDist = new List<ContentDistribution>();
            cdl = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :ppId
            ];
            // con = [SELECT Id, Title FROM ContentDocument WHERE Id =: cdl.ContentDocumentId];
            if(cdl.size() > 0){
               contId = cdl[0].ContentDocumentId; 
               contDist = [
                SELECT Id, ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentDocumentId = :cdl[0].ContentDocumentId order by createddate DESC
            ];
            }
            if(contDist.size()>0){
                retUrl = contDist[0].ContentDownloadUrl;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        /*string retUrl = URL.getOrgDomainUrl().toExternalForm() +
         '/sfc/servlet.shepherd/document/download/'+ contId +'?operationContext=S1';*/
        return retUrl;
    }

    @AuraEnabled
    public static String getTC(String code, String languageCode, Boolean useDefaultCommunity) {
        System.debug('useDefaultCommunity: ' + useDefaultCommunity);
        try {
            TCData tcData = new TCData();
            if (code == 'PrivacyPolicy') {
                tcData.tc = TermsAndConditions.getOrgDefaultPrivacyTC(useDefaultCommunity);
            } else if (code == 'CookiePolicy') {
                tcData.tc = TermsAndConditions.getCookieTC(useDefaultCommunity);
            } else {
                tcData.tc = TermsAndConditions.getTC(
                    TermsAndConditions.getOrgDefaultTCbyCode(code),
                    languageCode,
                    useDefaultCommunity
                );
            }
            return JSON.serialize(tcData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getPPTC(String code, String languageCode, Boolean useDefaultCommunity, String ctId) {
        try {
            TCData tcData = new TCData();
            if (code == 'PrivacyPolicy') {
                tcData.tc = TermsAndConditions.getOrgDefaultPPTC(useDefaultCommunity, ctId);
            }
            return JSON.serialize(tcData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void acceptTC(Id tcId) {
        try {
            TermsAndConditions.acceptTC(tcId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @auraEnabled
    public static String getCommunityName() {
        String communityName = TranslateHelper.getLabelValue(
            UserContext.getTemplateProperty('CommunityBrandName')
        );
        communityName = communityName.replace('<i>', '');
        communityName = communityName.replace('</i>', '');
        return communityName;
    }
    private static TCData getTCData(Terms_And_Conditions__c tc) {
        TCData tcData = new TCData();
        if (tc != null) {
            tcData.tc = tc;
            Terms_And_Conditions_Acceptance__c tca = TermsAndConditions.getTCA(tc.Id);
            tcData.isAccepted = tca != null;
            if (tca != null)
                tcData.acceptedDate = tca.Accepted_Date__c;
        }
        return tcData;
    }
}