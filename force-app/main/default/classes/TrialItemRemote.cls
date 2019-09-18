/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TrialItemRemote {

    @AuraEnabled
    public static void createCaseToStudy(Participant__c participant, Boolean isDelegate) {
        if (participant.Id != null && !isDelegate) {
            System.debug('For Me....');
            update participant;
        } else {
            System.debug('Some else....');
        }
        System.debug('participant ===> ' + participant);
    }
}