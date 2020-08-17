@isTest
private class Test_CaseCreator {
    @isTest
    private static void createCase_CaseGetsCreatedSuccessfully(){
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        CaseCreator.createCase(new List<id>{con.Id});
        List<Case> res = [SELECT ID FROM Case];
        system.assertEquals(1, res.size());
    }
}