/**
* Created by Krishna Mahto on 08/26/20.
*/

GLobal class UploadParticipantsBatchHelper implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
 
   public  List<Id> ids = new List<Id>();
   public  String query;
    
   public UploadParticipantsBatchHelper(List<Id> ids){
     this.ids = ids;
     query = 'Select Id,Participant_Status__c from Participant_Enrollment__c where Id IN :ids';
   }
 
   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
 
   public void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> scope){
       IntegrationService.intLogList = new List<Integration_Log__c>();
       String acceptedStatus = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
       List<id> PEStatusHistIdList = new List<Id>();
       Map<id,Integration_Log__c> PELogMap = new Map<id,Integration_Log__c>();
       for(Participant_Enrollment__c s : scope){
            If(s.Participant_Status__c==acceptedStatus){
            //Callout for Participent enrollment and store the Return value from the method in a list.
                Integration_Log__c  PEReturnedValue = IntegrationService.sendPEToStudyHubBatch(s.id);
                PELogMap.put(s.id,PEReturnedValue);
            }
        }
       //Iterate over Participant Enrollment status history object
       for(Participant_Enrollment_Status_History__c obj : [Select Id from Participant_Enrollment_Status_History__c where ParticipantEnrollment__c IN :ids]){
         PEStatusHistIdList.Add(obj.id);
           
       }
       //Callout for Participent enrollment Status History. 
        IntegrationService.sendPESHToEPRBatch(PEStatusHistIdList);
       //Update PE Study Hub log
        if(PELogMap!=null){
            try{
                insert PELogMap.Values();
            }catch (Exception e){
                System.debug('ERROR: ' + e.getMessage());
            }
        }

       List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
       //Update the logs for Each PE records
       for(id PEid: PELogMap.keySet()){        
         Participant_Enrollment__c obj = new Participant_Enrollment__c(Id = PEid,
                                                                       Study_Hub_Log__c = PELogMap.get(PEid).id);

         PEUpdateList.Add(obj);   
       }
        
       if(PEUpdateList!=null && !PEUpdateList.isEmpty()){
            try{
                update PEUpdateList;
            }catch (Exception e){
                System.debug('ERROR: ' + e.getMessage());
            }
        }
       List<Integration_Log__c> integrationLogList = IntegrationService.intLogList;
       //Insert the integration Logs
       if(integrationLogList!=null && integrationLogList.isEmpty()){
           try{
                Insert integrationLogList;
            }catch (Exception e){
                System.debug('ERROR: ' + e.getMessage());
            }
       }
   }

    public void finish(Database.BatchableContext BC){}
}