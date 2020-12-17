/**
 * Created by Velu on 11-Dec-20.
 */

public without sharing class Batch_UpdatePERParticipantKey implements Database.Batchable<SObject> {
    private String query;

    public Batch_UpdatePERParticipantKey() {
        this.query = 'select id,Participant_Key__c,Participant__c,Participant__r.Name,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.NCT_Number__c,Clinical_Trial_Profile__r.Protocol_ID__c from Participant_Enrollment__c where Participant_Key__c=null';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Participant_Enrollment__c> lstPER = new List<Participant_Enrollment__c>();
        try {
            for (Participant_Enrollment__c PER : (List<Participant_Enrollment__c>) records) {
                 if(PER.Participant_Key__c==null && PER.Clinical_Trial_Profile__c!=null)
                 {
                     if(PER.Clinical_Trial_Profile__r.NCT_Number__c!=null && PER.Participant__c!=null)
                       {  
                         Participant_Enrollment__c PerRecord= new Participant_Enrollment__c();
                         PerRecord.id=PER.id;
                         PerRecord.Participant_Key__c= PER.Participant__r.Name + ' ' + PER.Clinical_Trial_Profile__r.NCT_Number__c;
                         lstPER.add(PerRecord);
                        }else if(PER.Clinical_Trial_Profile__r.Protocol_ID__c!=null && PER.Participant__c!=null){
                         Participant_Enrollment__c PerRecord= new Participant_Enrollment__c();
                         PerRecord.id=PER.id;
                         PerRecord.Participant_Key__c= PER.Participant__r.Name + ' ' + PER.Clinical_Trial_Profile__r.Protocol_ID__c;
                         lstPER.add(PerRecord);
                        }
                 }
            }
            if (lstPER.size() > 0 && lstPER!= null) {
                update lstPER;
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}