/**
 * Created by Sravani Dasari
 */
public without sharing class TrialMatchPageRemote {
    static Id participantid;
	@AuraEnabled
    public static TrialMatchContainer getMatchCTPs(String urlid) {
        if(urlid != null)
            participantid = Id.valueOf(urlid);
        else 
            participantid = ParticipantContext.getCurrentParticipantId();
        try {
            TrialMatchHelper helper = (TrialMatchHelper) ClassFactory.newInstance(TrialMatchHelper.class);
            TrialMatchContainer trialMatchContainer = helper.getInitTrialMatchContainer(participantid);
            return trialMatchContainer;
        } catch (Exception e) {
            return (TrialMatchContainer) AuraHelper.throwException(e);
        }
    }

    public class TrialMatchContainer {
        @AuraEnabled public List<TrialMatchCTP> trialmatchctps;
        @AuraEnabled public Id partid;
        
        public TrialMatchContainer() {
            this.trialmatchctps = new List<TrialMatchPageRemote.TrialMatchCTP>();
            partid = participantid;
        }
    }

    public class TrialMatchCTP {
        @AuraEnabled public Clinical_Trial_Profile__c ctp;
        @AuraEnabled public Trial_Match__c trm;
        @AuraEnabled public Boolean isEnrollingCTP;
        @AuraEnabled public String ctpid;
        @AuraEnabled public String TherapeuticArea;
        @AuraEnabled public String StudyCodeName;
        @AuraEnabled public String OfficialTitle;
        @AuraEnabled public String matchDate;
    }
}