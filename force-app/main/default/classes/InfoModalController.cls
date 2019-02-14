/**
 * Created by D.Yasinskyi on 01.06.2018
 */
public without sharing class InfoModalController {

    @AuraEnabled
    public static String getHCPEnrollmentHistory(Id HSPEnrollmentId) {

        List<Status_History__c> enrollmentStatusHistories = [
                SELECT Id
                        , Date__c
                        , NewStatus__c
                        , CreatedDate
                        , CreatedBy.FirstName
                        , CreatedBy.LastName
                FROM Status_History__c
                WHERE HCP_Enrollment__c = :HSPEnrollmentId
                ORDER BY CreatedDate DESC
        ];
        for(Status_History__c hist : enrollmentStatusHistories){
            hist.NewStatus__c = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c,hist.NewStatus__c);
        }
        return JSON.serialize(enrollmentStatusHistories);
    }

    @AuraEnabled
    public static String getStudySiteHistory(Id StudySiteId) {

        List<Status_History__c> studySiteStatusHistories = [
                SELECT Id
                        , Date__c
                        , NewStatus__c
                        , CreatedDate
                        , CreatedBy.FirstName
                        , CreatedBy.LastName
                FROM Status_History__c
                WHERE StudySite__c = :StudySiteId
                ORDER BY CreatedDate DESC
        ];

        for(Status_History__c hist : studySiteStatusHistories){
            hist.NewStatus__c = TranslateHelper.getPickListLabel(Study_Site__c.Override_PI_Referral_Status__c,hist.NewStatus__c);
        }

        return JSON.serialize(studySiteStatusHistories);
    }
}