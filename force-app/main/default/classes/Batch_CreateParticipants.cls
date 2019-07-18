/**
 * Created by Denis Z on 16-Jul-19.
 */

public without sharing class Batch_CreateParticipants implements Database.Batchable<String>, Database.Stateful{
    
    private List<Id> createdPEIds = new List<Id>();
    private Integer scopeSize;
    private String postfix;

    public Batch_CreateParticipants(Integer scopeSize, String postfix){
        this.scopeSize = scopeSize;
        this.postfix = postfix;
    }

    public Iterable<String> start(Database.BatchableContext bc){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PECreationData'];
        List<String> dataLines = new List<String>();
        dataLines = sr.Body.toString().split('\n');
        List<String> resList = new List<String>();
        for (Integer i = 1; i < dataLines.size(); i++) resList.add(dataLines[i]);
        return resList;
    }

    public void execute(Database.BatchableContext bc, List<String> scope){
       createdPEIds.addAll(ParticipantEnrollmentFactory.createParticipantEnrollmentRecords(scope, postfix));
    }

    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new Batch_PEToPSE(createdPEIds), scopeSize);
    }

    public static void run(Integer scopeSize, String postfix){
        Database.executeBatch(new Batch_CreateParticipants(scopeSize, postfix), scopeSize);
    }
}