global without sharing class Batch_UpdateECOARetryFlag implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
    ContentVersion cvo = [SELECT VersionData FROM ContentVersion WHERE ContentDocument.Title = 'Update PE ECOA Retry' AND isLatest= true];     
    system.debug('cvo'+cvo);
    List<String> peIdstring = cvo.VersionData.toString().Split('\n');
	peIdstring.remove(0); 
    List<Id> peIds = new List<Id>();
    for(String pe:peIdstring){
        peIds.add(pe.trim());
    }
    return Database.getQueryLocator([SELECT ID FROM Participant_Enrollment__c WHERE ECOA_Retry_Disabled__c =TRUE AND Id IN:peIds]);
  }
    global void execute(Database.BatchableContext bc,List<Participant_Enrollment__c> scope){   
        ECOAService.disableTriggers();
        for(Participant_Enrollment__c pe:scope){
            pe.ECOA_Retry_Disabled__c = false;
        }
        update scope;
	}
    global void finish(Database.BatchableContext bc){
        
    }
}