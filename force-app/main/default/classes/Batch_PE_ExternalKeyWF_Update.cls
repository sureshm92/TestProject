/**
 * Created by Sravani Dasari
 */

public class Batch_PE_ExternalKeyWF_Update implements Database.Batchable<SObject>{
    private String query;
    
    public Batch_PE_ExternalKeyWF_Update(){
        this.query = 'select External_Key_WF__c, External_Key__c from Participant_Enrollment__c where External_Key_WF__c=null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
      
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        //for PE records:
        Batch_FixReferralAcceptedEPR.disableTriggers();
	TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        if(records[0].getSObjectType() == Participant_Enrollment__c.getSObjectType()){
            for(Participant_Enrollment__c pe : (List<Participant_Enrollment__c>)records){
                pe.External_Key_WF__c = pe.External_Key__c;
            }
        }
        Database.update(records,false);
    }
    
    public void finish(Database.BatchableContext bc) {}
    
}