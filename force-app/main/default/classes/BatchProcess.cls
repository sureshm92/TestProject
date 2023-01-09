/**
 * Created by Yehor Dobrovolskyi
 */ 
global class BatchProcess implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global Boolean isFinished;
    global final String query;
    global BatchHandler handler;
    global List<SObject> sObjects;

    global BatchProcess(String query, BatchHandler handler) {
        this.query = query;
        this.handler = handler;
        this.isFinished = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (query != null) {
            return Database.getQueryLocator(query);
        } else {
            throw new BatchException('unable to create query locator, query string  is null');
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        handler.handle(scope);
        handler.processScopeResult();
    }

    global void finish(Database.BatchableContext BC) {
        handler.processResult();
        isFinished = true;
    }
}
