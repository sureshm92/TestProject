/**
 * Created by Igor Malyuta on 25.12.2019.
 */

public without sharing class MessageService {

    public static List<Message__c> getMessages(Id conId, String sortOrder) {
        if(String.isEmpty(sortOrder)) sortOrder = 'DESC';
        return (List<Message__c>) DatabaseService.query(
                new List<String>{'Id',
                        'CreatedDate',
                        'Conversation__c',
                        'DocId__c',
                        'Message_Content__c',
                        'Sender_Name__c'},
                Message__c.getSObjectType(),
                DatabaseService.fieldEqual('Conversation__c', conId),
                'CreatedDate ' + sortOrder
        );
    }

    public static Map<Id, List<Message__c>> getMessagesByConversations(List<Id> conIds, String sortOrder) {
        if(String.isEmpty(sortOrder)) sortOrder = 'DESC';
        List<Message__c> messages = (List<Message__c>) DatabaseService.query(
                new List<String>{'Id',
                        'CreatedDate',
                        'Conversation__c',
                        'DocId__c',
                        'Message_Content__c',
                        'Sender_Name__c'},
                Message__c.getSObjectType(),
                DatabaseService.fieldInValues('Conversation__c', conIds),
                'CreatedDate ' + sortOrder
        );

        Map<Id, List<Message__c>> messagesByConversation = new Map<Id, List<Message__c>>();
        for (Message__c message : messages) {
            if (!messagesByConversation.containsKey(message.Conversation__c)) {
                messagesByConversation.put(message.Conversation__c, new List<Message__c>());
            }
            messagesByConversation.get(message.Conversation__c).add(message);
        }
        return messagesByConversation;
    }

    public static Map<Id, ContentDocumentLink> getAttachments(Id conversationId) {
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT
                        Id,
                        ContentDocumentId,
                        ContentDocument.CreatedDate,
                        ContentDocument.Title,
                        ContentDocument.FileExtension,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :conversationId
                ORDER BY ContentDocument.CreatedDate DESC
        ];

        Map<Id, ContentDocumentLink> attachmentByDocIds = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink link : contentDocumentLinks) attachmentByDocIds.put(link.ContentDocumentId, link);

        return attachmentByDocIds;
    }

    public static Map<Id, Map<Id, ContentDocumentLink>> getAttachmentsByConversation(List<Id> parentIds) {
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Id,
                        ContentDocumentId,
                        ContentDocument.CreatedDate,
                        ContentDocument.Title,
                        ContentDocument.FileExtension,
                        LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN:parentIds
        ];

        Map<Id, Map<Id, ContentDocumentLink>> attachmentByMesByCon = new Map<Id, Map<Id, ContentDocumentLink>>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            Id conversationId = link.LinkedEntityId;
            if (!attachmentByMesByCon.containsKey(conversationId)) {
                attachmentByMesByCon.put(conversationId, new Map<Id, ContentDocumentLink>());
            }
            attachmentByMesByCon.get(conversationId).put(link.ContentDocumentId, link);
        }
        return attachmentByMesByCon;
    }
}