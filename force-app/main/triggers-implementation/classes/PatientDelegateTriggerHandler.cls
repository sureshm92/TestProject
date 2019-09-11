/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateTriggerHandler {
    
    public class UpdateCurrentPEOnContactsHandler extends TriggerHandler {
        
        public override void afterInsert(List<SObject> newList) {
            updateCurrentPEOnContacts(newList);
        }
        
        public override void afterDelete(List<SObject> oldList) {
            updateCurrentPEOnContacts(oldList);
        }
    }
    
    private static void updateCurrentPEOnContacts(List<Patient_Delegate__c> pdList){
        List<Id> contactIds = new List<Id>();
        for(Patient_Delegate__c pd : pdList) contactIds.add(pd.Contact__c);
        ContactService.updateCurrentPEOnContacts(contactIds);
    }

}