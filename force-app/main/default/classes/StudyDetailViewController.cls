/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {


    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode){
        try {
            return getTrialDetail(trialId, userMode, null);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId) {
        try {
            System.debug('getTrialDetail');
            TrialDetail td = TrialFactory.getTrial(userMode, trialId, delegateId);
            return JSON.serialize(td);

        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }

    }

}