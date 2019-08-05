/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode) {
        try {
            System.debug('getTrialDetail');
            TrialDetail td = TrialFactory.getTrial(userMode, trialId);
            return JSON.serialize(td);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

    }

}