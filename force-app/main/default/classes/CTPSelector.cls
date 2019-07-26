/**
 * Created by dmytro.fedchyshyn on 24.07.2019.
 */

public without sharing class CTPSelector {
    public List<Clinical_Trial_Profile__c> getCtpById(Id ctpId) {
        return [
                SELECT Visit_Plan__c
                FROM Clinical_Trial_Profile__c
                WHERE Id = :ctpId
        ];
    }

    public List<Visit__c> getVisitsByCtpId(Id visitPlanId){
        return [
                SELECT Id,Name
                        ,Visit_Plan__c
                        ,Visit_Schedule__c
                        ,Visit_Number__c
                        ,icons__c
                FROM Visit__c
                WHERE Visit_Plan__c = :visitPlanId
        ];
    }

    public List<Icon_Details__c> getIconDetailsByVisitPlanInCTP(Clinical_Trial_Profile__c ctp) {
        return [
                SELECT Id
                        ,Name
                        ,Label__c
                        ,Description__c
                        ,Custom_Icon__c
                FROM Icon_Details__c
                WHERE Visit_Plan__c = :ctp.Visit_Plan__c
        ];
    }

}