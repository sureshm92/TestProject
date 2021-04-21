/**
 * Created by Sravani Dasari
 */
public without sharing class TrialMatchPageRemote {
    static Id peId;
    @AuraEnabled
    public static TrialMatchContainer getMatchCTPs(String urlid) {
        if (urlid != null)
            peId = Id.valueOf(urlid);
        else
            peId = ParticipantContext.getCurrentPEId();
        try {
            TrialMatchHelper helper = (TrialMatchHelper) ClassFactory.newInstance(
                TrialMatchHelper.class
            );
            TrialMatchContainer trialMatchContainer = helper.getInitTrialMatchContainer(
                peId
            );
            return trialMatchContainer;
        } catch (Exception e) {
            return (TrialMatchContainer) AuraHelper.throwException(e);
        }
    }

    public class TrialMatchContainer {
        @AuraEnabled
        public List<TrialMatchCTP> trialmatchctps;
        @AuraEnabled
        public Id partenrollid;

        public TrialMatchContainer() {
            this.trialmatchctps = new List<TrialMatchPageRemote.TrialMatchCTP>();
            partenrollid = peId;
        }
    }

    @AuraEnabled
    public static String getBase64fromTrialMatchApexPage(String peId)
    {

      //  PageReference page = new PageReference(System.site.getBaseSecureUrl()+'/apex/TrialMatchData');
      //PageReference page = Page.TrialMatchData;
      PageReference page = Page.TrialMatchLearnMorePage;
        page.getParameters().put('CTPId',peId);
        Blob content = page.getContent();
        String encoded = EncodingUtil.base64Encode(content);
        return encoded;
    }

    public class TrialMatchCTP {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public Trial_Match__c trm;
        @AuraEnabled
        public Boolean isEnrollingCTP;
        @AuraEnabled
        public String ctpid;
        @AuraEnabled
        public String TherapeuticArea;
        @AuraEnabled
        public String StudyCodeName;
        @AuraEnabled
        public String OfficialTitle;
        @AuraEnabled
        public String matchDate;
        @AuraEnabled
        public String NCTId;
        @AuraEnabled
        public Date matchedDate;
    }
}
