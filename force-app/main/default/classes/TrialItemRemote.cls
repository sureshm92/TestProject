/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialItemRemote {

    @AuraEnabled
    public static void createCaseToStudy(Participant__c participant,Clinical_Trial_Profile__c ctp, Boolean isDelegate) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(TrialSearchHelper.class);
            helper.createCaseAndSendNotification(participant, ctp);
            if (participant.Id != null && !isDelegate) {
                System.debug('For Me....');
                update participant;
            } else {
                System.debug('Some else....');
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

    }
}