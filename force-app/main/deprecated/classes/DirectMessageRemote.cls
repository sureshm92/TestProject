/**
 * Created by Igor Malyuta on 13.11.2019.
 */

public without sharing class DirectMessageRemote {

/*    @AuraEnabled(Cacheable = true)
    public static List<Conversation> getConversations() {
        List<Conversation> result = new List<Conversation>();

        try {
            ConnectApi.ChatterConversationPage page = ConnectApi.ChatterMessages.getConversations();
            for (ConnectApi.ChatterConversationSummary conv : page.conversations) result.add(new Conversation(conv));
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

        return result;
    }

    @AuraEnabled(Cacheable = true)
    public static List<DirectMessage> getConversation(String convId) {
        List<DirectMessage> result = new List<DirectMessage>();
        if(String.isBlank(convId)) return result;

        try {
            ConnectApi.ChatterConversation page = ConnectApi.ChatterMessages.getConversation(convId);
            for (ConnectApi.ChatterMessage msg : page.messages.messages) result.add(new DirectMessage(msg));
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

        return result;
    }

    @AuraEnabled
    public static DirectMessage replyToMessage(String text, String msgId) {
        try {
            return new DirectMessage(ConnectApi.ChatterMessages.replyToMessage(text, msgId));
        } catch (Exception e) {
            return (DirectMessage) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static DirectMessage sendMessage(String text, String recipients) {
        try {
            return new DirectMessage(ConnectApi.ChatterMessages.sendMessage(text, recipients));
        } catch (Exception e) {
            return (DirectMessage) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<UserWrapper> searchUsers(String query) {
        List<UserWrapper> result = new List<UserWrapper>();
        try {
            ParticipantService.ParticipantState state = ParticipantService.getParticipantState();
            if(state.value == ParticipantService.ParticipantStates.PARTICIPANT) {
                List<User> users = [
                        SELECT
                                CompanyName,
                                ContactId,
                                Id,
                                LanguageLocaleKey,
                                Name,
                                SmallPhotoUrl,
                                Title,
                                Username
                        FROM User
                        WHERE ContactId = :state.pe.PI_Contact__c
                ];
                if(!users.isEmpty()) {
                    User piUser = users.get(0);
                    UserWrapper userWrapper = new UserWrapper();
                    userWrapper.name = piUser.Name;
                    userWrapper.companyName = piUser.CompanyName;
                    userWrapper.id = piUser.Id;
                    userWrapper.smallPhotoUrl = piUser.SmallPhotoUrl;
                    userWrapper.title = piUser.Title;

                    result.add(userWrapper);
                }
            } else {
                ConnectApi.UserPage chatterUsers = ConnectApi.ChatterUsers.searchUsers(null, query);
                for (ConnectApi.UserDetail user : chatterUsers.users) {
                    if (UserInfo.getUserId() != user.Id) {
                        result.add(new UserWrapper(user));
                    }
                }
            }

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return result;
    }

    @AuraEnabled
    public static void publishNewMessageEvent(String conversationId, String messageId) {
        try {
            EventBus.publish(new DirectMessageEvent__e(ConversationID__c = conversationId, MessageID__c = messageId));
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public class UserWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String smallPhotoUrl;
        @AuraEnabled public String companyName;
        @AuraEnabled public String title;

        public UserWrapper(){}

        public UserWrapper(ConnectApi.User user) {
            this.id = user.Id;
            this.name = user.displayName;
            this.smallPhotoUrl = user.photo.SmallPhotoUrl;
            this.companyName = user.companyName;
            this.title = user.title;
        }
    }

    public class Conversation {
        @AuraEnabled public String id;
        @AuraEnabled public Boolean isRead;
        @AuraEnabled public String formattedRecipientNames;
        @AuraEnabled public Datetime sentDate;
        @AuraEnabled public String message;
        @AuraEnabled public String smallPhotoUrl;
        @AuraEnabled public String latestMessageId;

        public Conversation(ConnectApi.ChatterConversationSummary conv) {
            this.id = conv.id;
            this.isRead = conv.read;
            this.sentDate = conv.latestMessage.SentDate;
            this.message = conv.latestMessage.Body.Text;
            this.smallPhotoUrl = conv.latestMessage.Sender.Photo.SmallPhotoUrl;
            this.latestMessageId = conv.latestMessage.Id;
            this.formattedRecipientNames = '';
            for (ConnectApi.UserSummary user : conv.members) {
                if (UserInfo.getUserId() != user.Id) {
                    this.formattedRecipientNames += user.DisplayName + ', ';
                }
            }
            this.formattedRecipientNames = this.formattedRecipientNames.removeEnd(', ');
        }
    }

    public class DirectMessage {
        @AuraEnabled public Datetime sentDate;
        @AuraEnabled public String id;
        @AuraEnabled public String conversationId;
        @AuraEnabled public String sender;
        @AuraEnabled public String formattedSentDate;
        @AuraEnabled public String text;
        @AuraEnabled public String smallPhotoUrl;
        @AuraEnabled public Boolean isMine;
        @AuraEnabled public List<String> recipients;

        public DirectMessage(ConnectApi.ChatterMessage msg) {
            this.id = msg.id;
            this.conversationId = msg.conversationId;
            this.sender = msg.sender.name;
            this.sentDate = msg.sentDate;
            this.formattedSentDate = msg.sentDate.format();
            this.text = msg.body.text;
            this.smallPhotoUrl = msg.sender.photo.smallPhotoUrl;
            this.isMine = (UserInfo.getUserId() == msg.sender.id);

            this.recipients = new List<String>();
            if (!msg.recipients.isEmpty()) {
                for (ConnectApi.UserSummary recipient : msg.recipients) {
                    this.recipients.add(recipient.id);
                }
            }
        }
    }*/
}