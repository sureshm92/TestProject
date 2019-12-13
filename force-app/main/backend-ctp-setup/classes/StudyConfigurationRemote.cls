/**
 * Created by Nargiz Mamedova on 12/9/2019.
 */

public with sharing class StudyConfigurationRemote {

    @AuraEnabled
    public static Clinical_Trial_Profile__c getInitData(Id ctpId) {
        try {
            Clinical_Trial_Profile__c ctp = [
                    SELECT Id, Visit_Schedule_Is_Available__c,
                            Study_Documents_Are_Available__c ,
                            Video_And_Articles_Are_Available__c,
                            Travel_Vendor_Is_Available__c,
                            Tasks_Are_Available__c,
                            Relevant_Links_Are_Available__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Id =: ctpId];
            return ctp;
        } catch (Exception e) {
            return (Clinical_Trial_Profile__c) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveChanges(Clinical_Trial_Profile__c ctp){
        try {
            update ctp;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}