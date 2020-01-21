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
        @AuraEnabled public Boolean isPastStudy;
        @AuraEnabled public Boolean unread;
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
        @AuraEnabled public Boolean isAttachment;
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileIcon;
        @AuraEnabled public String downloadLink;
    }

    @AuraEnabled
    public static MSPageData getInitData() {
        try {
            MSPageData pageData = new MSPageData();
            pageData.userMode = CommunityService.getUserContact().userCommunityMode__c;

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
                for(Participant_Enrollment__c pe : participantEnrollments) {
                    if(pe.Study_Site__r.Messages_Are_Available__c) pageData.enrollments.add(pe);
                }

                //Collect Conversations
                List<Id> availablePEIds = new List<Id>();
                for(Participant_Enrollment__c pe : pageData.enrollments) availablePEIds.add(pe.Id);

                if(sharedConversations != null) {
                    for(Conversation__c con : sharedConversations) {
                        if(availablePEIds.contains(con.Participant_Enrollment__c)) conversations.add(con);
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
                if(sharedConversations != null) conversations.addAll(sharedConversations);

                //Collect Enrollments
                Set<Id> piContactIds = DelegateService.getPIDelegateParents();
                Id piContactId = piContactIds.isEmpty() ?
                        CommunityService.getInstance().getCurrentContactId() : piContactIds.iterator().next();

                pageData.enrollments = [
                        SELECT
                                Id,
                                Clinical_Trial_Profile__r.Study_Code_Name__c,
                                Participant__r.Full_Name__c,
                                Participant_Contact__c
                        FROM Participant_Enrollment__c
                        WHERE Study_Site__r.Principal_Investigator__c = :piContactId
                        AND Study_Site__r.Messages_Are_Available__c = TRUE
                ];
            }
            if (!conversations.isEmpty()) {
                List<Id> conIds = new List<Id>();
                for (Conversation__c con : conversations) conIds.add(con.Id);

                Map<Id, List<Message__c>> messagesByConversation = MessageService.getMessagesByConversations(conIds);
                pageData.conversationWrappers = new List<ConversationWrapper>();

                for (Conversation__c conversation : conversations) {
                    pageData.conversationWrappers.add(getConversationWrapper(
                            pageData.userMode, conversation, messagesByConversation.get(conversation.Id))
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
            return sendMessage(newConversation, messageText);
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ConversationWrapper sendMessage(Conversation__c conversation, String messageText) {
        try {
            Contact userContact = CommunityService.getUserContact();

            String senderName;
            Boolean needUpdate = false;
            if (userContact.userCommunityMode__c.equals(CommunityService.USER_MODE_PARTICIPANT)) {
                List<Participant__c> participant = [SELECT Id, Full_Name__c FROM Participant__c WHERE Contact__c = :userContact.Id];
                if(!participant.isEmpty()) {
                    senderName = participant.get(0).Full_Name__c;
                } else {
                    senderName = userContact.UserCommunityIsDelegate__c ?
                            userContact.Full_Name__c : conversation.Participant_Enrollment__r.Participant__r.Full_Name__c;
                }
                if(!conversation.haveUnreadForPI__c) {
                    conversation.haveUnreadForPI__c = true;
                    needUpdate = true;
                }
            } else {
                senderName = userContact.Full_Name__c;
                if(!conversation.haveUnreadForParticipant__c) {
                    conversation.haveUnreadForParticipant__c = true;
                    needUpdate = true;
                }
            }

            if(needUpdate) update conversation;

            insert new Message__c(
                    Conversation__c = conversation.Id,
                    Message_Content__c = messageText,
                    Sender_Name__c = senderName
            );

            List<Message__c> messages = MessageService.getMessages(conversation.Id);
            return getConversationWrapper(userContact.userCommunityMode__c, conversation, messages);
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
            return getConversationWrapper(CommunityService.getUserContact().userCommunityMode__c, conversation, messages);
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Integer getUnreadCount() {
        try {
            return ConversationService.getUnreadConversationCount(UserInfo.getUserId(), CommunityService.getUserContact().userCommunityMode__c);
        } catch (Exception e) {
            return (Integer) AuraHelper.throwException(e);
        }
    }

    private static ConversationWrapper getConversationWrapper(String userMode, Conversation__c conversation, List<Message__c> messages) {
        ConversationWrapper conWr = new ConversationWrapper();
        conWr.conversation = conversation;

        String conTitle;
        String conFullName;
        String conDescription;
        if(userMode == CommunityService.USER_MODE_PARTICIPANT) {
            conWr.unread = conversation.haveUnreadForParticipant__c;
            Contact piContact = conversation.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r;
            conTitle = Label.Study_Team;
            conFullName = piContact.Name;

            if(PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(conversation.Participant_Enrollment__r.Participant_Status__c)) {
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

        if (!messages.isEmpty()) {
            conWr.messages = new List<MessagePageRemote.MessageWrapper>();
            for (Message__c message : messages) {
                MessageWrapper messageWrapper = new MessageWrapper();
                messageWrapper.message = message;
                conWr.messages.add(messageWrapper);
            }
            Message__c lastMessage = messages.get(0);
            conWr.lastUpdate = lastMessage.CreatedDate.date();
            conWr.lastMessagePart = lastMessage.Message_Content__c;
        }
        return conWr;
    }
}