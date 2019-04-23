public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {

        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.extendSharingToAllUsers(newList);
    }
}