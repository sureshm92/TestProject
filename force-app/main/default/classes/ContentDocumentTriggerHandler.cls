public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {

    public override void beforeDelete(List<SObject> oldList) {
        ContentDocumentLinkService contentDocumentLinkService = (ContentDocumentLinkService) ClassFactory.newInstance(ContentDocumentLinkService.class);
        contentDocumentLinkService.removeURLsFromImagesOnResources(oldList);
    }
}