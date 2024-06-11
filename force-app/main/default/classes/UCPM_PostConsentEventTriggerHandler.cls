public with sharing class UCPM_PostConsentEventTriggerHandler {
    public class SendBulkImportRecordsToUCPM extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            sendtoUCPM_AfterInsert((List<UCPM_Post_Consent__e>) newList);
        }
    }
    private static void sendtoUCPM_AfterInsert(
        List<UCPM_Post_Consent__e> newList
    ){       
        List<Id> perRecIds=new List<Id>();
        List<Id> pderRecIds=new List<Id>();
        if(!newList.isEmpty()){
            for(UCPM_Post_Consent__e evt:newList){            
                if(String.isNotBlank(evt.Participant_Enrollment_Record_Ids__c)){
                    perRecIds= evt.Participant_Enrollment_Record_Ids__c.split(',');
                }
                if(String.isNotBlank(evt.Patient_Delegate_Enrollment_Record_Ids__c)){
                    pderRecIds= evt.Patient_Delegate_Enrollment_Record_Ids__c.split(',');
                }
                if(!perRecIds.isEmpty()){
                    UCPM_ConsentPostBulkImport_Future.processRecords(perRecIds,pderRecIds,evt.Place_of_Funcitionality__c);
                }
            }
        }
        
    }
  

}