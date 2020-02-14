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

    public static Map<Id, ContentDocumentLink> getAttachments(List<Id> messageIds) {
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT
                        Id,
                        ContentDocumentId,
                        ContentDocument.CreatedDate,
                        ContentDocument.Title,
                        ContentDocument.FileExtension,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN:messageIds
                ORDER BY ContentDocument.CreatedDate DESC
        ];

        Map<Id, ContentDocumentLink> attachmentByParentIds = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink link : contentDocumentLinks) attachmentByParentIds.put(link.LinkedEntityId, link);

        return attachmentByParentIds;
    }

    public static Map<Id, Map<Id, ContentDocumentLink>> getAttachmentsByConversation(List<Id> messageIds) {
        List<Message__c> messages = [
                SELECT Id, Conversation__c, (
                        SELECT Id,
                                ContentDocumentId,
                                ContentDocument.CreatedDate,
                                ContentDocument.Title,
                                ContentDocument.FileExtension,
                                LinkedEntityId
                        FROM ContentDocumentLinks
                )
                FROM Message__c
                WHERE Id IN:messageIds
        ];

        Map<Id, Map<Id, ContentDocumentLink>> attachmentByMesByCon = new Map<Id, Map<Id, ContentDocumentLink>>();
        for (Message__c message : messages) {
            Id conversation = message.Conversation__c;
            if (!attachmentByMesByCon.containsKey(conversation)) {
                attachmentByMesByCon.put(conversation, new Map<Id, ContentDocumentLink>());
            }
            if (!message.ContentDocumentLinks.isEmpty()) {
                attachmentByMesByCon.get(conversation).put(message.Id, message.ContentDocumentLinks.get(0));
            }
        }

        return attachmentByMesByCon;
    }
}