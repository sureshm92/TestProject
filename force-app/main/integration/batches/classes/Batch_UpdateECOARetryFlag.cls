//To be run occassionaly by App support team 
global without sharing class Batch_UpdateECOARetryFlag implements Database.Batchable<SObject>,Database.Stateful {
    private Map<Id,String> peIds = new Map<Id,String>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
ContentVersion cvo = [SELECT VersionData FROM ContentVersion WHERE ContentDocument.Title = 'Update PE ECOA Retry' AND isLatest= true];     
    List<String> peIdstring = cvo.VersionData.toString().Split('\n');
peIdstring.remove(0); 
    for(String pe:peIdstring){
        List<String> peComponents = new List<String>();
        peComponents = pe.split(',');
        if(peComponents.size() == 2){
            Id peId = Id.valueOf(peComponents[0].trim());
            String peString = peComponents[1].trim();
        peIds.put(peId,peString);
        }
    }    
    return Database.getQueryLocator([SELECT ID,ECOA_Retry_Count__c,Subject_GUID__c FROM Participant_Enrollment__c WHERE ECOA_Retry_Count__c>=3 AND Id IN:peIds.keyset()]);
  }
    global void execute(Database.BatchableContext bc,List<Participant_Enrollment__c> scope){   
        ECOAService.disableTriggers();
        List<Participant_Enrollment__c> recordsToUpdate = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe:scope){
            String associatedString  =  peIds.get(pe.Id);
                pe.ECOA_Retry_Count__c = null;
            System.debug('>>associatedString2<<'+associatedString);
             if(pe.Subject_GUID__c == null && associatedString != null){
                System.debug('>>associatedString<<'+associatedString);
                	pe.Subject_GUID__c = associatedString;
                    //peIdsForEvents.add(pe.Id);
                System.debug('>>associatedString1<<'+associatedString);
               
            }
             recordsToUpdate.add(pe);
        }
        if(recordsToUpdate.size()>0){
        update scope;
        }
	}
    global void finish(Database.BatchableContext bc){
        /*
        if(peIdsForEvents.size()>0){
            Batch_CreateECOASubjectEvents objBatch = new Batch_CreateECOASubjectEvents(peIdsForEvents);
            Database.executeBatch(objBatch, 200);
        }
        */
    }
}