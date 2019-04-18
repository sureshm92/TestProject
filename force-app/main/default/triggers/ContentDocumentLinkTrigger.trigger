trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    TriggerHandlerExecutor.execute(ContentDocumentLinkTriggerHandler.class);
}