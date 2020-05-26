/**
 * Created by Nargiz Mamedova on 5/22/2020.
 */

@IsTest
private class Test_Batch_UpdateIconDetailsOnVisitPlans {
    @IsTest
    static void testBehavior() {
        List<String> iconIds = new List<String>{'cancel', 'clickboard', 'leg', 'lungs','pills', 'pregnant'};
        Visit_Plan__c newPlan = new Visit_Plan__c(Name = 'Test Plan');
        insert newPlan;

        newPlan = [SELECT Id FROM Visit_Plan__c LIMIT 1];
        Icon_Details__c iconDetail = new Icon_Details__c(Name = 'cancel', Visit_Plan__c = newPlan.Id);
        insert iconDetail;

        Test.startTest();
        Batch_UpdateIconDetailsOnVisitPlans batch = new Batch_UpdateIconDetailsOnVisitPlans();
        batch.iconIds = iconIds;
        Database.executeBatch(batch);
        Test.stopTest();

        List<Icon_Details__c> iconDetails = [SELECT Id FROM Icon_Details__c WHERE Visit_Plan__c =: newPlan.Id];
        System.assertEquals(iconDetails.size(), iconIds.size());
    }
}