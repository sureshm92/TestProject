@isTest
private class Test_CaseCreator {
    @isTest
    private static void createCase_CaseGetsCreatedSuccessfully(){
        CaseCreator.createCase();
        List<Case> res = [SELECT ID FROM Case];
        system.assertEquals(1, res.size());
    }
}