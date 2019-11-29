/**
 * Created by Denis Z on 16-Jul-19.
 */

public without sharing class Batch_CreateParticipants implements Database.Batchable<String>, Database.Stateful{
    
    private List<Id> createdPEIds = new List<Id>();
    private Integer scopeSize;
    private String postfix;
    private Integer maxLines;

    public Batch_CreateParticipants(Integer scopeSize, String postfix, Integer maxLines){
        this.scopeSize = scopeSize;
        this.postfix = postfix;
        this.maxLines = maxLines;
    }

    public Iterable<String> start(Database.BatchableContext bc){
//        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PECreationData'];
//        List<String> dataLines = sr.Body.toString().split('\n');
        List<String> resList = new List<String>();
//        Integer addedLines = 0;
//        for (Integer i = 1; i < dataLines.size(); i++) {
//            addedLines++;
//            resList.add(dataLines[i].split(',')[1]);
//            if(maxLines != null && addedLines >= maxLines) break;
//        }
        return resList;
    }

    public void execute(Database.BatchableContext bc, List<String> scope){
//       createdPEIds.addAll(ParticipantEnrollmentFactory.createParticipantEnrollmentRecords(scope, postfix));
    }

    public void finish(Database.BatchableContext bc){
        //if(createdPEIds.size() > 0)Database.executeBatch(new Batch_PEToPSE(createdPEIds), scopeSize);
    }
    
    public static void run(Integer scopeSize, String postfix, Integer maxlines){
        Database.executeBatch(new Batch_CreateParticipants(scopeSize, postfix, maxlines), scopeSize);
    }
    
    public static void run(Integer scopeSize){
        Database.executeBatch(new Batch_CreateParticipants(scopeSize, null, null), scopeSize);
    }
}