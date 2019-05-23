public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {

        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.extendSharingToAllUsers(newList);
        contentDocumentLinkService.validateImageTypes(newList);
    }
    public override void afterInsert(List<SObject> newList) {
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(PlatformEventService.class);
        contentDocumentLinkService.createURLsForImagesOnResources(newList);
        platformEventService.remindEventFire((List<ContentDocumentLink>) newList);
    }
}