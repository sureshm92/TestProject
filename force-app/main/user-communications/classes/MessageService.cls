/**
 * Created by Igor Malyuta on 25.12.2019.
 */

public without sharing class MessageService {
    public static List<Message__c> getMessages(Id conId) {
        return [
            SELECT Id, CreatedDate, Conversation__c, DocId__c, Message_Content__c, Sender_Name__c,CreatedById
            FROM Message__c
            WHERE Conversation__c = :conId
            ORDER BY CreatedDate DESC
        ];
    }
    
    public static List<Message__c> getNonConfidentialMessages(Id conId) {
        return [
            SELECT Id, CreatedDate, Conversation__c, DocId__c, Message_Content__c, Sender_Name__c,CreatedById,Is_Confidential__c
            FROM Message__c
            WHERE Conversation__c = :conId and Is_Confidential__c = false
            ORDER BY CreatedDate DESC
        ];
    }
    
     public static Map<Id,List<Message__c>> getnonConfidentialMessageByConversations(List<Id> conIds,Map<Id, List<Message__c>> messagesByConversation){
        List<Message__c> messages = [
            SELECT Id, CreatedDate, Conversation__c, DocId__c, Message_Content__c, Sender_Name__c,Is_Confidential__c,CreatedById
            FROM Message__c
            WHERE Conversation__c IN :conIds and Is_Confidential__c = false
            ORDER BY CreatedDate DESC
        ];

        //Map<Id, List<Message__c>> messagesByConversation = new Map<Id, List<Message__c>>();
        for (Message__c message : messages) {
            if (!messagesByConversation.containsKey(message.Conversation__c)) {
                messagesByConversation.put(message.Conversation__c, new List<Message__c>());
            }
            messagesByConversation.get(message.Conversation__c).add(message);
        }
        return messagesByConversation;  
        
    }
    

    public static Map<Id, List<Message__c>> getMessagesByConversations(List<Id> conIds) {
        List<Message__c> messages = [
            SELECT Id, CreatedDate, Conversation__c, DocId__c, Message_Content__c, Sender_Name__c,CreatedById,Is_Confidential__c
            FROM Message__c
            WHERE Conversation__c IN :conIds
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

    
    public static Map<Id, ContentDocumentLink> getAttachments(Id conversationId) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT
                Id,
                ContentDocumentId,
                ContentDocument.CreatedDate,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                LinkedEntityId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :conversationId
            ORDER BY ContentDocument.CreatedDate DESC
        ];

        Map<Id, ContentDocumentLink> attachmentByDocIds = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink link : contentDocumentLinks)
            attachmentByDocIds.put(link.ContentDocumentId, link);

        return attachmentByDocIds;
    }

    public static Map<Id, Map<Id, ContentDocumentLink>> getAttachmentsByConversation(
        List<Id> parentIds
    ) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT
                Id,
                ContentDocumentId,
                ContentDocument.CreatedDate,
                ContentDocument.Title,
                ContentDocument.FileExtension,
                ContentDocument.LatestPublishedVersionId,
                LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :parentIds
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