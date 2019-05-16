public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {

        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.extendSharingToAllUsers(newList);
        contentDocumentLinkService.validateImageTypes(newList);
    }
    public override void afterInsert(List<SObject> newList) {
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.remindEventFire(newList);
        contentDocumentLinkService.createURLsForImagesOnResources(newList);
    }

    public override void afterDelete(List<SObject> oldList) {
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.remindEventFire(oldList);
    }
}