/**
 * Created by Igor Malyuta on 25.12.2019.
 */

public without sharing class ConversationService {

    public static List<Conversation__c> getSharedConversations(Id userId) {
        List<Conversation__Share> conversationShares = (List<Conversation__Share>) DatabaseService.query(new List<String>{
                'Id', 'ParentID'
        }, Conversation__Share.getSObjectType(), DatabaseService.fieldEqual('UserOrGroupId', userId));

        Set<String> conversationIds = new Set<String>();
        for(Conversation__Share conShare : conversationShares) conversationIds.add(conShare.ParentId);
        if(conversationIds.isEmpty()) return null;

        List<String> conIds = new List<String>();
        conIds.addAll(conversationIds);

        return getConversations(conIds);
    }

    public static List<Conversation__c> getConversations(List<Id> conIds) {
        String filter = DatabaseService.fieldInValues('Id', conIds)
                + 'AND Participant_Enrollment__r.Study_Site__r.Messages_Are_Available__c = TRUE ';
        return (List<Conversation__c>) DatabaseService.query(new List<String>{
                'haveUnreadForParticipant__c', 'haveUnreadForPI__c', 'Id', 'OwnerId',
                'Participant_Enrollment__c',
                'Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
                'Participant_Enrollment__r.Participant__r.Full_Name__c',
                'Participant_Enrollment__r.Participant_Status__c',
                'Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Name',
                'Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Title',
                'Participant_Enrollment__r.Study_Site__r.Messages_Are_Available__c'
        }, Conversation__c.getSObjectType(), filter, 'CreatedDate DESC', null);
    }

    public static Integer getUnreadConversationCount(Id userId, String userMode) {
        Integer unreadCount = 0;
        for(Conversation__c conversation : getSharedConversations(userId)) {
            if(conversation.haveUnreadForPI__c && userMode.equals(CommunityService.USER_MODE_PI)) unreadCount++;
            if(conversation.haveUnreadForParticipant__c && userMode.equals(CommunityService.USER_MODE_PARTICIPANT)) unreadCount++;
        }

        return unreadCount;
    }

    public static void createConversationSharesForMembers(Id conversationId, Participant_Enrollment__c enrollment) {
        Contact userContact = CommunityService.getUserContact();
        List<Id> contactsForSharing = new List<Id>();

        List<Id> patientDelegateServiceDelegatedContactIds =
                PatientDelegateService.getDelegatedContactIds(enrollment.Participant_Contact__c);
        for(Id paDelConId : patientDelegateServiceDelegatedContactIds) {
            if(paDelConId != userContact.Id) contactsForSharing.add(paDelConId);
        }
        List<Site_Staff__c> siteStaff = [
                SELECT Site_Contact__c
                FROM Site_Staff__c
                WHERE Study_Site__r.Principal_Investigator__c = :enrollment.Study_Site__r.Principal_Investigator__c
        ];
        for(Site_Staff__c ss : siteStaff) {
            if(ss.Site_Contact__c != userContact.Id) contactsForSharing.add(ss.Site_Contact__c);
        }

        if(userContact.UserCommunityIsDelegate__c && userContact.Id != enrollment.Participant_Contact__c) {
            Id headSenderId = userContact.userCommunityMode__c.equals(CommunityService.USER_MODE_PARTICIPANT) ?
                    enrollment.Participant_Contact__c : enrollment.Study_Site__r.Principal_Investigator__c;
            contactsForSharing.add(headSenderId);
        }
        Id headRecipientId = userContact.userCommunityMode__c.equals(CommunityService.USER_MODE_PARTICIPANT) ?
                        enrollment.Study_Site__r.Principal_Investigator__c : enrollment.Participant_Contact__c;
        contactsForSharing.add(headRecipientId);

        List<Conversation__Share> conversationShares = new List<Conversation__Share>();
        List<User> usersForSharing = [SELECT Id FROM User WHERE ContactId IN:contactsForSharing AND IsActive = TRUE];
        if (!usersForSharing.isEmpty()) {
            for (User user : usersForSharing) {
                conversationShares.add(new Conversation__Share(
                        AccessLevel = 'Edit',
                        ParentId = conversationId,
                        UserOrGroupId = user.Id
                ));
            }

            insert conversationShares;
        }
    }

    public static List<Conversation__Share> createConversationSharesForUser(List<Id> conversationIds, Id userId) {
        List<Conversation__Share> shares = new List<Conversation__Share>();
        for(Id conId : conversationIds) {
            shares.add(new Conversation__Share(
                    AccessLevel = 'Edit',
                    ParentId = conId,
                    UserOrGroupId = userId
            ));
        }
        return shares;
    }

    public static void removeConversationSharesForUser(List<Id> conversationIds, Id userId) {
        List<Conversation__Share> shares = [
                SELECT Id FROM Conversation__Share
                WHERE ParentId IN:conversationIds
                AND UserOrGroupId = :userId
        ];
        if(!shares.isEmpty()) delete shares;
    }
}