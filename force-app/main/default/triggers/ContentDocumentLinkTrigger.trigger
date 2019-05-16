trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before delete, after insert, after delete) {

    TriggerHandlerExecutor.execute(ContentDocumentLinkTriggerHandler.class);
}