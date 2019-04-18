public with sharing class TherapeuticAreaTriggerHandler extends TriggerHandler {

    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        tAAService.reparentTAAs((List<Therapeutic_Area__c>) newList, (Map<Id, Therapeutic_Area__c>) oldMap);
    }

    public override void beforeDelete(List<SObject> oldList) {

        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);
        tAAService.deleteTAAs((List<Therapeutic_Area__c>) oldList);
    }
}