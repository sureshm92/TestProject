global class televisitBatch implements Database.Batchable<sObject> {
     global Database.QueryLocator start( Database.BatchableContext BC ) {
        String query = 'SELECT Id,Status__c,Visit_Date__c,Start_Time__c FROM Televisit__c ';
        return Database.getQueryLocator( query );
 
    }
   
    global void execute( Database.BatchableContext BC, List< Televisit__c > scope ) {
         for (Televisit__c tv : scope) {
             if(tv.Visit_Date__c < system.today()+1){
                 tv.Status__c = 'Completed';  
             }
                           
         }
         update scope;
 
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
 
}