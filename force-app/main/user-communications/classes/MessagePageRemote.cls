/**
 * Created by Igor Malyuta on 24.12.2019.
 */

public without sharing class MessagePageRemote {

    public class MSPageData {
        @AuraEnabled public String userMode;
        @AuraEnabled public List<ConversationWrapper> conversationWrappers;
        @AuraEnabled public List<String> messageTemplates;
        @AuraEnabled public List<Participant_Enrollment__c> enrollments;
    }

    public class ConversationWrapper {
        @AuraEnabled public Conversation__c conversation;
        @AuraEnabled public Boolean isPastStudy = false;
        @AuraEnabled public Boolean unread = false;
        @AuraEnabled public String fullName;
        @AuraEnabled public String title;
        @AuraEnabled public Date lastUpdate;
        @AuraEnabled public String description;
        @AuraEnabled public String lastMessagePart;
        @AuraEnabled public Boolean haveAttachment;
        @AuraEnabled public List<MessageWrapper> messages;
    }

    public class MessageWrapper {
        @AuraEnabled public Message__c message;
        @AuraEnabled public AttachmentWrapper attachmentWrapper;
    }

    public class AttachmentWrapper {

        private Map<String, String> iconByExtention = new Map<String, String>{
                'csv' => '',
                'doc' => 'attach-file-doc',
                'jpg' => '',
                'pdf' => 'attach-file-pdf',
                'png' => '',
                'xls' => 'attach-file-xls'
        };

        @AuraEnabled public String fileName;
        @AuraEnabled public String fileIcon;
        @AuraEnabled public String downloadLink = '/sfc/servlet.shepherd/document/download/';//ContentDocumentId

        public AttachmentWrapper(ContentDocumentLink doc) {
            fileName = doc.ContentDocument.Title + '.' + doc.ContentDocument.FileExtension;
            fileIcon = iconByExtention.containsKey(doc.ContentDocument.FileExtension) ?
                    iconByExtention.get(doc.ContentDocument.FileExtension) : 'icon-blank';
            downloadLink += doc.ContentDocumentId;
        }
    }

    @AuraEnabled
    public static MSPageData getInitData() {
        try {
            MSPageData pageData = new MSPageData();
            pageData.userMode = UserContext.getCurrentUserMode().userMode;

            List<Conversation__c> sharedConversations = ConversationService.getSharedConversations(UserInfo.getUserId());
            List<Conversation__c> conversations = new List<Conversation__c>();
            if (pageData.userMode == CommunityService.USER_MODE_PARTICIPANT) {
                //Collect Enrollments
                ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
                List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
                if (participantState.pe != null) participantEnrollments.add(participantState.pe);
                List<Participant_Enrollment__c> pastEnrollments =
                        ContactService.getPastEnrollments(participantState.participant.Contact__c);
                if (!pastEnrollments.isEmpty()) participantEnrollments.addAll(pastEnrollments);

                pageData.enrollments = new List<Participant_Enrollment__c>();
                for (Participant_Enrollment__c pe : participantEnrollments) {
                    if (pe.Study_Site__r.Messages_Are_Available__c) pageData.enrollments.add(pe);
                }

                //Collect Conversations
                Set<Id> availablePEIds = new Set<Id>();
                for (Participant_Enrollment__c pe : pageData.enrollments) availablePEIds.add(pe.Id);

                if (sharedConversations != null) {
                    for (Conversation__c con : sharedConversations) {
                        if (availablePEIds.contains(con.Participant_Enrollment__c)) conversations.add(con);
                    }
                }

                //Message Variants
                List<Message_Template__mdt> messageTemplates = [SELECT Message_Variant__c FROM Message_Template__mdt];
                if (!messageTemplates.isEmpty()) {
                    TranslateHelper.translate(messageTemplates, UserInfo.getLanguage());
                    pageData.messageTemplates = new List<String>();
                    for (Message_Template__mdt mesTmp : messageTemplates) pageData.messageTemplates.add(mesTmp.Message_Variant__c);
                }
            } else if (pageData.userMode == CommunityService.USER_MODE_PI) {
                //Collect Conversations
                if (sharedConversations != null) conversations.addAll(sharedConversations);

                //Collect Enrollments
                pageData.enrollments = getEnrollmentsForPI(null);
            }
            if (!conversations.isEmpty()) {
                Map<Id, Conversation__c> conversationsByIds = new Map<Id, Conversation__c>();
                for (Conversation__c con : conversations) conversationsByIds.put(con.Id, con);

                Map<Id, List<Message__c>> messagesByConversation =
                        MessageService.getMessagesByConversations(new List<Id>(conversationsByIds.keySet()));
                Map<Id, List<ContentDocumentLink>> documentLinkMap =
                        ConversationService.getAttachments(new List<Id>(conversationsByIds.keySet()));

                pageData.conversationWrappers = new List<ConversationWrapper>();
                for (Id conId : messagesByConversation.keySet()) {
                    Conversation__c conversation = conversationsByIds.get(conId);
                    pageData.conversationWrappers.add(getConversationWrapper(
                            pageData.userMode, conversation,
                            getMessageWrappers(messagesByConversation.get(conversation.Id), documentLinkMap.get(conversation.Id)))
                    );
                }
            }

            return pageData;
        } catch (Exception e) {
            return (MSPageData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ConversationWrapper createConversation(Participant_Enrollment__c enrollment, String messageText) {
        try {
            Conversation__c newConversation = new Conversation__c(Participant_Enrollment__c = enrollment.Id);
            insert newConversation;

            ConversationService.createConversationSharesForMembers(newConversation.Id, enrollment);
            newConversation.Participant_Enrollment__r = enrollment;
            return sendMessage(newConversation, messageText, null);
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void sendMultipleMessage(List<String> peIds, String messageText) {
        try {
            List<Participant_Enrollment__c> participantEnrollments = (List<Participant_Enrollment__c>) DatabaseService.query(
                    ParticipantEnrollmentService.PE_COMMON_FIELDS,
                    Participant_Enrollment__c.getSObjectType(),
                    DatabaseService.fieldInValues('Id', peIds)
            );
            Map<String, Participant_Enrollment__c> enrollmentMap = new Map<String, Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : participantEnrollments) enrollmentMap.put(pe.Id, pe);

            List<Conversation__c> existingConversations = [
                    SELECT Id, Participant_Enrollment__c
                    FROM Conversation__c
                    WHERE Participant_Enrollment__c IN:peIds
            ];

            List<String> peIdsWithoutConversation = new List<String>(peIds);
            if (!existingConversations.isEmpty()) {
                List<Id> conIds = new List<Id>();
                for (Conversation__c con : existingConversations) {
                    conIds.add(con.Id);
                    Integer index = peIdsWithoutConversation.indexOf(String.valueOf(con.Participant_Enrollment__c));
                    if (index >= 0) peIdsWithoutConversation.remove(index);
                }
                for (Conversation__c exCon : ConversationService.getConversations(conIds)) {
                    sendMessage(exCon, messageText, null);
                }
            }

            if (!peIdsWithoutConversation.isEmpty()) {
                for (String peId : peIdsWithoutConversation) {
                    createConversation(enrollmentMap.get(peId), messageText);
                }
            }

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ConversationWrapper sendMessage(Conversation__c conversation, String messageText, String docId) {
        try {
            Contact userContact = CommunityService.getUserContact();

            String senderName;
            Boolean needUpdate = false;
            if (UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PARTICIPANT) {
                List<Participant__c> participant = [SELECT Id, Full_Name__c FROM Participant__c WHERE Contact__c = :userContact.Id];
                if (!participant.isEmpty()) {
                    senderName = participant.get(0).Full_Name__c;
                } else {
                    senderName = userContact.UserCommunityIsDelegate__c ?
                            userContact.Full_Name__c : conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
                }
                if (!conversation.haveUnreadForPI__c) {
                    conversation.haveUnreadForPI__c = true;
                    needUpdate = true;
                }
            } else if (UserContext.getCurrentUserMode().userMode == CommunityService.USER_MODE_PI) {
                senderName = userContact.Full_Name__c;
                if (!conversation.haveUnreadForParticipant__c) {
                    conversation.haveUnreadForParticipant__c = true;
                    needUpdate = true;
                }
            }

            if (needUpdate) update conversation;

            Message__c message = new Message__c(
                    Conversation__c = conversation.Id,
                    Message_Content__c = messageText,
                    Sender_Name__c = senderName
            );
            if(!String.isEmpty(docId)) message.ContentDocumentLinkId__c = docId;
            insert message;

            List<Message__c> messages = MessageService.getMessages(conversation.Id);
            Map<Id, List<ContentDocumentLink>> contentDocumentLinksByIds = ConversationService.getAttachments(new List<Id>{
                    conversation.Id
            });
            return getConversationWrapper(
                    CommunityService.getUserContact().userCommunityMode__c,
                    conversation,
                    getMessageWrappers(messages, contentDocumentLinksByIds.get(conversation.Id))
            );
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ConversationWrapper markConversationAsRead(Conversation__c conversation) {
        try {
            update new Conversation__c(
                    Id = conversation.Id,
                    haveUnreadForParticipant__c = false,
                    haveUnreadForPI__c = false
            );
            conversation.haveUnreadForParticipant__c = false;
            conversation.haveUnreadForPI__c = false;

            List<Message__c> messages = MessageService.getMessages(conversation.Id);
            Map<Id, List<ContentDocumentLink>> contentDocumentLinksByIds = ConversationService.getAttachments(new List<Id>{
                    conversation.Id
            });
            return getConversationWrapper(
                    CommunityService.getUserContact().userCommunityMode__c,
                    conversation,
                    getMessageWrappers(messages, contentDocumentLinksByIds.get(conversation.Id))
            );
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Integer getUnreadCount() {
        try {
            return ConversationService.getUnreadConversationCount(UserInfo.getUserId(), UserContext.getCurrentUserMode().userMode);
        } catch (Exception e) {
            return (Integer) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchParticipant(String searchTerm, List<String> selectedIds) {
        try {
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            List<Participant_Enrollment__c> enrollments = getEnrollmentsForPI(DatabaseService.fieldNotInValues('Id', selectedIds));
            if (enrollments == null || enrollments.isEmpty()) return results;

            List<Participant_Enrollment__c> matchingEnrollments = new List<Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : enrollments) {
                if (pe.Participant__r.Full_Name__c.containsIgnoreCase(searchTerm)) matchingEnrollments.add(pe);
            }

            for (Participant_Enrollment__c pe : matchingEnrollments) {
                results.add(new LookupSearchResult(
                        pe.Id,
                        'Participant_Enrollment__c',
                        'standard:avatar',
                        pe.Participant__r.Full_Name__c,
                        'Study • ' + pe.Clinical_Trial_Profile__r.Study_Code_Name__c)
                );
            }

            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    //Wrappers Logic:---------------------------------------------------------------------------------------------------
    private static List<MessageWrapper> getMessageWrappers(List<Message__c> messages, List<ContentDocumentLink> documentLinks) {
        List<MessageWrapper> messageWrappers = new List<MessagePageRemote.MessageWrapper>();
        for (Message__c message : messages) {
            MessageWrapper messageWrapper = new MessageWrapper();
            messageWrapper.message = message;

            if (!String.isEmpty(message.ContentDocumentLinkId__c) && !documentLinks.isEmpty()) {
                for (ContentDocumentLink link : documentLinks) {
                    if (link.Id == message.ContentDocumentLinkId__c) {
                        messageWrapper.attachmentWrapper = new AttachmentWrapper(link);
                        break;
                    }
                }
            }
            messageWrappers.add(messageWrapper);
        }
        return messageWrappers;
    }

    private static ConversationWrapper getConversationWrapper(String userMode, Conversation__c conversation,
            List<MessageWrapper> messageWrappers) {
        ConversationWrapper conWr = new ConversationWrapper();
        conWr.conversation = conversation;

        String conTitle;
        String conFullName;
        String conDescription;
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            conWr.unread = conversation.haveUnreadForParticipant__c;
            Contact piContact = conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r;
            conTitle = Label.Study_Team;
            conFullName = piContact.Name;

            if (PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(conversation.Participant_Enrollment__r.Participant_Status__c)) {
                conWr.isPastStudy = true;
                conDescription = conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
            } else {
                conDescription = Label.PI_Colon + ' ' +
                        (String.isNotBlank(piContact.Title) ? piContact.Title + ' ' : '')
                        + piContact.Name;
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            conWr.unread = conversation.haveUnreadForPI__c;
            conTitle = conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
            conFullName = conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
            conDescription = conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
        }
        conWr.title = conTitle;
        conWr.fullName = conFullName;
        conWr.description = conDescription;

        if (!messageWrappers.isEmpty()) {
            conWr.messages = messageWrappers;
            conWr.haveAttachment = messageWrappers.get(0).attachmentWrapper != null;
            Message__c lastMessage = messageWrappers.get(0).message;
            conWr.lastUpdate = lastMessage.CreatedDate.date();
            conWr.lastMessagePart = lastMessage.Message_Content__c;
        }
        return conWr;
    }

    //Service Logic:----------------------------------------------------------------------------------------------------
    private static List<Participant_Enrollment__c> getEnrollmentsForPI(String additionalFiler) {
        String filter = 'Study_Site__r.Messages_Are_Available__c = TRUE AND';
        Id currentContactId = CommunityService.getInstance().getCurrentContactId();
        List<Site_Staff__c> siteStaffs = [
                SELECT Id, Study_Site__c
                FROM Site_Staff__c
                WHERE Site_Contact__c = :currentContactId
        ];
        if (!siteStaffs.isEmpty()) {
            List<String> ssIds = new List<String>();
            for (Site_Staff__c staff : siteStaffs) ssIds.add(staff.Study_Site__c);
            filter += DatabaseService.fieldInValues('Study_Site__c', ssIds);
        } else {
            filter += DatabaseService.fieldEqual('Study_Site__r.Principal_Investigator__c', currentContactId);
        }

        if (String.isNotEmpty(additionalFiler)) filter += ' AND' + additionalFiler;

        return (List<Participant_Enrollment__c>) DatabaseService.query(
                new List<String>{
                        'Id',
                        'Clinical_Trial_Profile__r.Study_Code_Name__c',
                        'Participant__r.Full_Name__c',
                        'Participant_Contact__c'
                }, Participant_Enrollment__c.getSObjectType(), filter);
    }
}