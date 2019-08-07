/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class PETriggerHandler  extends TriggerHandler {

    public override void onAfterInsert(List<SObject> newList) {
        TherapeuticAreaPatientService.createTAP(newList);
        PSEService.updateExternalKey(newList, null);
    }

    protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        TherapeuticAreaPatientService.deleteTherapeuticAreaPatientFromPE(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        TherapeuticAreaPatientService.createTAP(newList);
        PSEService.updateExternalKey((List<Participant_Enrollment__c>) newList,(Map<Id, Participant_Enrollment__c>) oldMap);
    }

}