/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialItemRemote {
    @AuraEnabled
    public static void createCaseToStudy(
        Participant__c participant,
        Clinical_Trial_Profile__c ctp,
        Boolean isDelegate
    ) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(
                TrialSearchHelper.class
            );
            helper.createCaseAndSendNotification(participant, ctp);
            if (participant.Id != null && !isDelegate) {
                ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .updateRecord(participant, true);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void createSubscribeConnectionEnroll(Id ctpId) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(
                TrialSearchHelper.class
            );
            helper.createSubscribeConnection(ctpId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePreferences(String contactInfo) {
        system.debug('here--' + contactInfo);
        PreferenceManagementController.saveConsent('', contactInfo, 'IQVIA_OUTREACH');
    }
}
