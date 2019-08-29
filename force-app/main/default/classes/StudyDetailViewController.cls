/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {


    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode){
        return getTrialDetail(trialId, userMode, null);
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode, String delegateId) {
        try {
            System.debug('getTrialDetail');
            TrialDetail td = TrialFactory.getTrial(userMode, trialId, delegateId);
            return JSON.serialize(td);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

    }

}