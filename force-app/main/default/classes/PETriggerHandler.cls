/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class PETriggerHandler  extends TriggerHandler {

    protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        TherapeuticAreaPatientService.deleteTherapeuticAreaPatientFromPE(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
    }

}