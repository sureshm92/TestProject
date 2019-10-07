public with sharing class TherapeuticAreaTriggerHandler extends TriggerHandler {

    public override void beforeDelete(List<SObject> oldList) {

        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        tAAService.deleteTAAs((List<Therapeutic_Area__c>) oldList);
    }
}