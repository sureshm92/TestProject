/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {
    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode) {
        try {
            return getTrialDetail(trialId, userMode, null, false);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, Boolean isNewPP) {
        try {
            return getTrialDetail(trialId, userMode, null, isNewPP);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId) {
        try {
            return JSON.serialize(TrialFactory.getTrial(userMode, trialId, delegateId));
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId, Boolean isNewPP) {
        try {
            return JSON.serialize(TrialFactory.getTrial(userMode, trialId, delegateId, isNewPP));
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }    

    @AuraEnabled
    public static Map<String, Map<String, List<String>>> visitResultSharingByGroupAndMode() {
        return VisitResultSharingService.visitResultSharingByGroupAndMode();
    }
}
