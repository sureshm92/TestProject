/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaPatientTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {
        TherapeuticAreaPatientService.validationOnDuplicate(newList);
    }
}