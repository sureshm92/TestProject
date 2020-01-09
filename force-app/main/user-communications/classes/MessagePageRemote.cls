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

    @AuraEnabled(Cacheable = true)
    public static MSPageData getInitData() {
        try {
            MSPageData pageData = new MSPageData();
            pageData.userMode = CommunityModeService.getCurrentCommunityMode(CommunityModeService.getUserCommunityModes()).userMode;

            List<Conversation__c> conversations = ConversationService.getSharedConversations(UserInfo.getUserId());
            if (conversations != null && !conversations.isEmpty()) {
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

            if (pageData.userMode == CommunityService.USER_MODE_PARTICIPANT) {
                //Collect Enrollments
                ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
                pageData.enrollments = new List<Participant_Enrollment__c>();
                if (participantState.pe != null) pageData.enrollments.add(participantState.pe);
                List<Participant_Enrollment__c> pastEnrollments =
                        ContactService.getPastEnrollments(participantState.participant.Contact__c);
                if (!pastEnrollments.isEmpty()) pageData.enrollments.addAll(pastEnrollments);

                //Message Variants
                List<Message_Template__mdt> messageTemplates = [SELECT Message_Variant__c FROM Message_Template__mdt];
                if (!messageTemplates.isEmpty()) {
                    TranslateHelper.translate(messageTemplates, UserInfo.getLanguage());
                    pageData.messageTemplates = new List<String>();
                    for (Message_Template__mdt mesTmp : messageTemplates) pageData.messageTemplates.add(mesTmp.Message_Variant__c);
                }
            } else if (pageData.userMode == CommunityService.USER_MODE_PI) {
                //Collect Enrollments
                pageData.enrollments = [
                        SELECT Id, Participant__r.Full_Name__c
                        FROM Participant_Enrollment__c
                        WHERE Study_Site__r.Principal_Investigator__c = :CommunityService.getInstance().getCurrentContactId()
                ];
            }

            return pageData;
        } catch (Exception e) {
            return (MSPageData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ConversationWrapper createConversation(Participant_Enrollment__c enrollment, String messageText) {
        try {
            String userMode = CommunityModeService.getCurrentCommunityMode(CommunityModeService.getUserCommunityModes()).userMode;

            Conversation__c newConversation = new Conversation__c(Participant_Enrollment__c = enrollment.Id);
            if(userMode.equals(CommunityService.USER_MODE_PARTICIPANT)) {
                newConversation.haveUnreadForPI__c = true;
            } else {
                newConversation.haveUnreadForParticipant__c = true;
            }
            insert newConversation;

            ConversationService.createConversationShares(newConversation.Id, enrollment);

            insert new Message__c(
                    Conversation__c = newConversation.Id,
                    Message_Content__c = messageText,
                    Sender_Name__c = enrollment.Participant__r.Full_Name__c
            );

            Conversation__c conversation = ConversationService.getConversations(new List<Id>{
                    newConversation.Id
            }).get(0);
            List<Message__c> messages = MessageService.getMessages(conversation.Id);
            return getConversationWrapper(userMode, conversation, messages);
        } catch (Exception e) {
            return (ConversationWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void sendMessage(Conversation__c conversation, Message__c message) {
        try {
            String userMode = CommunityModeService.getCurrentCommunityMode(CommunityModeService.getUserCommunityModes()).userMode;
            if(userMode.equals(CommunityService.USER_MODE_PARTICIPANT)) {
                conversation.haveUnreadForPI__c = true;
            } else {
                conversation.haveUnreadForParticipant__c = true;
            }
            update conversation;

            insert message;
        } catch (Exception e) {
            AuraHelper.throwException(e);
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
            Message__c lastMessage = messages.get(messages.size() - 1);
            conWr.lastUpdate = lastMessage.CreatedDate.date();
            conWr.lastMessagePart = lastMessage.Message_Content__c;
        }

        return conWr;
    }
}