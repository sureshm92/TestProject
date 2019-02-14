/**
 * Created by Leonid Bartenev
 */

public class Batch_UpdateRecords implements Database.Batchable<SObject>{
    
    private String query;
    
    public Batch_UpdateRecords(String query){
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        //for Clinical Trial Profile records:
        if(records[0].getSObjectType() == Clinical_Trial_Profile__c.getSObjectType()){
            for(Clinical_Trial_Profile__c ctp : (List<Clinical_Trial_Profile__c>)records){
                if(ctp.Study_Code_Name__c == null && ctp.Study_Title__c != null){
                    ctp.Study_Code_Name__c = ctp.Study_Title__c.mid(0, Clinical_Trial_Profile__c.Study_Code_Name__c.getDescribe().getLength());
                }
            }
        }
        update records;
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public static void run(){
        Database.executeBatch(new Batch_UpdateRecords('SELECT Id FROM Participant_Enrollment__c'), 50);
        Database.executeBatch(new Batch_UpdateRecords('SELECT Id FROM HCP_Enrollment__c'), 50);
        Database.executeBatch(new Batch_UpdateRecords(
                ' SELECT Id, Study_Code_Name__c, Study_Title__c ' +
                ' FROM Clinical_Trial_Profile__c'
        ), 50);
    }

}