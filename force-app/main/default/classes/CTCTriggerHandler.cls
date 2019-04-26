public with sharing class CTCTriggerHandler extends TriggerHandler {

    public override void afterDelete(List<SObject> oldList) {

        CTCService ctcService = (CTCService) ClassFactory.newInstance(CTCService.class);
        ctcService.deleteTAAs(oldList);
    }

    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        for (SObject singleCTC : newList) {
            singleCTC.addError(Label.Can_Not_Edit_Mapping);
        }
    }

    public override void afterInsert(List<SObject> newList) {

        CTCService ctcService = (CTCService) ClassFactory.newInstance(CTCService.class);
        ctcService.createDeleteTAAs(newList);
    }
}
