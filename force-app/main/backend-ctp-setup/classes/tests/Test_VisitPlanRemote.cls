/**
 * Created by Nargiz Mamedova on 3/23/2020.
 */

@IsTest
private class Test_VisitPlanRemote {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        Visit_Plan__c newPlan = new Visit_Plan__c(Name = 'Test Plan');
        List<Visit__c> deletedVisits = new List<Visit__c>();
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        List<Visit__c> visits = new List<Visit__c>();

        for (Integer i = 1; i < 6; i++) iconDetails.add(new Icon_Details__c(Name = 'Test ' + i));
        for (Integer i = 1; i < 6; i++) visits.add(new Visit__c(Name = 'Test ' + i, Visit_Number__c = i));
        String planId = VisitPlanRemote.upsertVisitPlan(JSON.serialize(newPlan), JSON.serialize(visits), JSON.serialize(deletedVisits), JSON.serialize(iconDetails));

        newPlan = VisitPlanRemote.getVisitPlan(planId);
        deletedVisits = [SELECT Id FROM Visit__c WHERE Name = 'Test 5'];
        VisitPlanRemote.upsertVisitPlan(JSON.serialize(newPlan), JSON.serialize(visits), JSON.serialize(deletedVisits), JSON.serialize(iconDetails));
        VisitPlanRemote.VisitPlanWrapper visitPlanWrapper = (VisitPlanRemote.VisitPlanWrapper) JSON.deserialize(VisitPlanRemote.getVisitPlanWrapper(planId), VisitPlanRemote.VisitPlanWrapper.class);
        VisitPlanRemote.upsertVisitPlan(JSON.serialize(newPlan), JSON.serialize(visitPlanWrapper.visits), JSON.serialize(new List<Visit__c>()), JSON.serialize(iconDetails));

        List<LookupSearchResult> resList = VisitPlanSearchLookup.searchVPByIds(planId);
        resList = VisitPlanSearchLookup.searchVPByTerm('Plan', '');
        Test.stopTest();
    }

    @IsTest
    static void upsertVisitPlanWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitPlanRemote.upsertVisitPlan(null, null, null, null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitPlanWrapperWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitPlanRemote.getVisitPlanWrapper(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}