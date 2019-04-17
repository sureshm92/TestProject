public with sharing class TherapeuticAreaTriggerHandler extends TriggerHandler {

    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

        List<Therapeutic_Area__c> tAsToProcess = new List<Therapeutic_Area__c>();
        for(Therapeutic_Area__c singleTA : (List<Therapeutic_Area__c>) newList) {
            if(singleTA.RecordType.DeveloperName == TherapeuticAreaService.THIRD_PARTY_COI_RT_NAME && singleTA.Therapeutic_Area__c != null) {
                tAsToProcess.add(singleTA);
            }
        }
        TherapeuticAreaAssignmentService tAAService = (TherapeuticAreaAssignmentService) ClassFactory.newInstance(TherapeuticAreaAssignmentService.class);


        /*todo move this code to the Service*/
        {
            TherapeuticAreaService service = new TherapeuticAreaService();
            Map<String, Therapeutic_Area__c> tAsByNames = service.getTAsByNamesMap(tAsToProcess);
            List<Therapeutic_Area_Assignment__c> assignments = [SELECT Id, Therapeutic_Area__r.Therapeutic_Area__c FROM Therapeutic_Area_Assignment__c WHERE Therapeutic_Area__c IN :tAsByNames.keySet()];
            if(assignments != null) {
                for(Therapeutic_Area_Assignment__c singleAssignment : assignments) {
                    singleAssignment.Therapeutic_Area__c = singleAssignment.Therapeutic_Area__r.Therapeutic_Area__c;
                }
                update assignments;
            }
        }
    }
}