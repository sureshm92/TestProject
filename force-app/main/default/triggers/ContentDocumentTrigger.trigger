trigger ContentDocumentTrigger on ContentDocument (before delete) {

    TriggerHandlerExecutor.execute(ContentDocumentTriggerHandler.class);
}