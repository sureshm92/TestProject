@isTest
private class Test_Batch_MoveTaskInvitations {
    
    @isTest
    public static void testBatch()
    {
        List<Task> lstTask = new List<Task>();
     
        for(Integer i=0;i<50;i++)
        {
            Task objTask = new Task(Task_Type__c = 'Survey');
            lstTask.add(objTask);
            
        }
        if(!lstTask.isEmpty())
            insert lstTask;
        test.startTest();
        Database.executeBatch(new Batch_MoveTaskInvitations());
        test.stopTest();
        
    }
    @isTest
    public static void testBatchRun()
    {
        List<Task> lstTask = new List<Task>();
     
        for(Integer i=0;i<50;i++)
        {
            Task objTask = new Task(Task_Type__c = 'Survey');
            lstTask.add(objTask);
            
        }
        if(!lstTask.isEmpty())
            insert lstTask;
        test.startTest();
         Batch_MoveTaskInvitations.run();
        test.stopTest();
        
    }

}