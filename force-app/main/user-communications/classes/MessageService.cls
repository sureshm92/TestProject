/**
 * Created by Igor Malyuta on 25.12.2019.
 */

public without sharing class MessageService {

    public static List<Message__c> getMessages(Id conId) {
        return [
                SELECT Id,
                        CreatedDate,
                        Conversation__c,
                        Message_Content__c,
                        Sender_Name__c
                FROM Message__c
                WHERE Conversation__c = :conId
                ORDER BY CreatedDate DESC
        ];
    }

    public static Map<Id, List<Message__c>> getMessagesByConversations(List<Id> conIds) {
        List<Message__c> messages = [
                SELECT Id,
                        CreatedDate,
                        Conversation__c,
                        Message_Content__c,
                        Sender_Name__c
                FROM Message__c
                WHERE Conversation__c IN:conIds
                ORDER BY CreatedDate DESC
        ];
        Map<Id, List<Message__c>> messagesByConversation = new Map<Id, List<Message__c>>();
        for (Message__c message : messages) {
            if (!messagesByConversation.containsKey(message.Conversation__c)) {
                messagesByConversation.put(message.Conversation__c, new List<Message__c>());
            }
            messagesByConversation.get(message.Conversation__c).add(message);
        }
        return messagesByConversation;
    }

    public static Map<Id, ContentDocumentLink> getMessageAttachment(List<Id> messageIds) {
        Map<Id, ContentDocumentLink> attachmentByMessageId = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT
                        ContentDocument.Title,
                        ContentDocument.FileType,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN:messageIds
        ];
        for (ContentDocumentLink doc : contentDocumentLinks) attachmentByMessageId.put(doc.LinkedEntityId, doc);
        return attachmentByMessageId;
    }
}