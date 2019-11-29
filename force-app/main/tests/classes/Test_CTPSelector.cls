@IsTest
public with sharing class Test_CTPSelector {

    @TestSetup
    static void setup() {
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test 0');
        insert visitPlan;

        Clinical_Trial_Profile__c ctpList = (new Clinical_Trial_Profile__c(Protocol_ID__c = '11111111111', Study_Title__c = 'test',
                Visit_Plan__c = visitPlan.Id, Synch_with_TMDH__c = true));
        insert ctpList;

        List<Visit__c> visits = new List<Visit__c>();
        for (Integer i = 0; i < 2; i++) {
            visits.add(new Visit__c(Name = 'Test -' + i, Visit_Plan__c = visitPlan.Id));
        }
        insert visits;

        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        for (Integer i = 0; i < 2; i++) {
            iconDetails.add(new Icon_Details__c(Name = 'Test -' + i, Visit_Plan__c = visitPlan.Id, Label__c = 'test'));
        }
        insert iconDetails;
    }

    @IsTest
    static void getVisitsByCtp() {
        Clinical_Trial_Profile__c ctp = getCtp();
        Visit_Plan__c visitPlan = getVisitPlan(ctp.Id);
        CTPSelector selector = new CTPSelector();

        List<Visit__c> visits =
                selector.getVisitsByCtpId(visitPlan.Id);
        System.assertEquals(2, visits.size());
    }

    @IsTest
    static void getCtpById() {
        CTPSelector selector = new CTPSelector();
        Id ctpId = getCtp().Id;
        List<Clinical_Trial_Profile__c> ctp = selector.getCtpById(ctpId);
        System.assertEquals(1, ctp.size());
    }

    private static Clinical_Trial_Profile__c getCtp() {
        return [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c LIMIT 1];
    }

    private static Visit_Plan__c getVisitPlan(Id ctpId) {
        return [
                SELECT Id
                FROM Visit_Plan__c
                WHERE Id IN (SELECT Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id = :ctpId)
                LIMIT 1
        ];
    }

    @IsTest
    static void getIconDetailsByVisitPlanInCTP_test() {
        CTPSelector selector = new CTPSelector();
        Clinical_Trial_Profile__c ctp = getCtp();
        List<Icon_Details__c> iconDetails = selector.getIconDetailsByVisitPlanInCTP(ctp.Visit_Plan__c);
        System.assertEquals(2, iconDetails.size());
    }
}