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
            TrialMatchContainer trialMatchContainer = helper.getInitTrialMatchContainer(peId);
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
    public static String getBase64TrialMatchData(String peId) {
        try {
            PageReference page = Page.TrialMatchData;
            page.getParameters().put('id', peId);
            Blob content = !Test.isRunningTest() ? page.getContent() : Blob.valueOf('Fake content');
            String encoded = EncodingUtil.base64Encode(content);
            return encoded;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
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
