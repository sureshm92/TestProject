trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    for(ContentDocumentLink singleLink : Trigger.new) {
        singleLink.ShareType = 'I';
        singleLink.Visibility = 'AllUsers';
    }
}