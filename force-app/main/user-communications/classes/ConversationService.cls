/**
 * Created by Igor Malyuta on 25.12.2019.
 */

public without sharing class ConversationService {
    public static List<Conversation__c> getSharedConversations(Id userId) {
        List<Conversation__Share> conversationShares = new List<Conversation__Share>();
        if(userId.getSObjectType().getDescribe().getName()== 'Participant_Enrollment__c'){
            conversationShares = (List<Conversation__Share>) DatabaseService.query(
                new List<String>{ 'Id', 'ParentID' },
                Conversation__Share.getSObjectType(),
                DatabaseService.fieldEqual('Parent.Participant_Enrollment__c', userId)
            );
        }else{
            conversationShares = (List<Conversation__Share>) DatabaseService.query(
                new List<String>{ 'Id', 'ParentID' },
                Conversation__Share.getSObjectType(),
                DatabaseService.fieldEqual('UserOrGroupId', userId)
            );
        }
        
        Set<String> conversationIds = new Set<String>();
        for (Conversation__Share conShare : conversationShares)
            conversationIds.add(conShare.ParentId);
        if (conversationIds.isEmpty())
            return null;

        List<String> conIds = new List<String>();
        conIds.addAll(conversationIds);

        return getConversations(conIds);
    }

    public static List<Conversation__c> getConversations(List<Id> conIds) {
        return (List<Conversation__c>) DatabaseService.query(
            new List<String>{
                'haveUnreadForParticipant__c',
                'haveUnreadForPI__c',
                'Id',
                'OwnerId',
                'Participant_Enrollment__c',
                'Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
                'Participant_Enrollment__r.Participant__c',
                'Participant_Enrollment__r.Participant__r.Full_Name__c',
                'Participant_Enrollment__r.Participant_Contact__c',
                'Participant_Enrollment__r.Participant_Status__c',
                'Participant_Enrollment__r.Study_Site__c',
                'Participant_Enrollment__r.Study_Site__r.Principal_Investigator__c',    
                'Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Name',
                'Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Title',
                'Participant_Enrollment__r.Study_Site__r.Messages_Are_Available__c'
            },
            Conversation__c.getSObjectType(),
            DatabaseService.fieldInValues('Id', conIds),
            'CreatedDate DESC',
            null
        );
    }

    public static Integer getUnreadConversationCount(Id userId, String userMode) {
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        Integer unreadCount = 0;
        if(userMode != CommunityService.USER_MODE_PI){
            pState = ParticipantService.getInstance().getState();
        }
        Id useThisId = userMode == CommunityService.USER_MODE_PI ? userId : pState.pe.Id;
        List<Conversation__c> sharedConversations = getSharedConversations(useThisId);
        if (sharedConversations == null || sharedConversations.isEmpty())
            return unreadCount;

        for (Conversation__c conversation : sharedConversations) {
            if (conversation.haveUnreadForPI__c && userMode.equals(CommunityService.USER_MODE_PI))
                unreadCount++;
            if (
                conversation.haveUnreadForParticipant__c &&
                userMode.equals(CommunityService.USER_MODE_PARTICIPANT)
            ) {
                List<Participant_Enrollment__c> enrollments = [
                    SELECT Id
                    FROM Participant_Enrollment__c
                    WHERE Id = :useThisId
                ];
                for (Participant_Enrollment__c enrollment : enrollments) {
                    if (conversation.Participant_Enrollment__c == enrollment.Id)
                        unreadCount++;
                }
            }
        }

        return unreadCount;
    }

    public static void createConversationSharesForMembers(
        Id conversationId,
        Participant_Enrollment__c enrollment
    ) {
        Contact userContact = CommunityService.getUserContact();
        List<Id> contactsForSharing = new List<Id>();

        List<Id> patientDelegateContactIds = PatientDelegateService.getDelegatedContactIds(
            enrollment.Participant_Contact__c
        );
        for (Id paDelConId : patientDelegateContactIds) {
            if (paDelConId != userContact.Id)
                contactsForSharing.add(paDelConId);
        }
        List<Site_Staff__c> siteStaff = [
            SELECT Site_Contact__c
            FROM Site_Staff__c
            WHERE
                Study_Site__r.Principal_Investigator__c = :enrollment.Study_Site__r.Principal_Investigator__c
                AND Study_Site__c = :enrollment.Study_Site__c
        ];
        for (Site_Staff__c ss : siteStaff) {
            if (ss.Site_Contact__c != userContact.Id)
                contactsForSharing.add(ss.Site_Contact__c);
        }

        if (
            userContact.UserCommunityIsDelegate__c &&
            userContact.Id != enrollment.Participant_Contact__c
        ) {
            Id headSenderId = userContact.userCommunityMode__c.equals(
                    CommunityService.USER_MODE_PARTICIPANT
                )
                ? enrollment.Participant_Contact__c
                : enrollment.Study_Site__r.Principal_Investigator__c;
            contactsForSharing.add(headSenderId);
        }
        Id headRecipientId = userContact.userCommunityMode__c.equals(
                CommunityService.USER_MODE_PARTICIPANT
            )
            ? enrollment.Study_Site__r.Principal_Investigator__c
            : enrollment.Participant_Contact__c;
        contactsForSharing.add(headRecipientId);

        List<Conversation__Share> conversationShares = new List<Conversation__Share>();
        List<User> usersForSharing = [
            SELECT Id
            FROM User
            WHERE ContactId IN :contactsForSharing AND IsActive = TRUE
        ];
        if (!usersForSharing.isEmpty()) {
            for (User user : usersForSharing) {
                conversationShares.add(
                    new Conversation__Share(
                        AccessLevel = 'Edit',
                        ParentId = conversationId,
                        UserOrGroupId = user.Id
                    )
                );
            }

            insert conversationShares;
        }
    }

    public static List<Conversation__Share> createConversationSharesForUser(
        List<Id> conversationIds,
        Id userId
    ) {
        List<Conversation__Share> shares = new List<Conversation__Share>();
        for (Id conId : conversationIds) {
            shares.add(
                new Conversation__Share(
                    AccessLevel = 'Edit',
                    ParentId = conId,
                    UserOrGroupId = userId
                )
            );
        }
        return shares;
    }

    public static void removeConversationSharesForUser(List<Id> conversationIds, Id userId) {
        List<Conversation__Share> shares = [
            SELECT Id
            FROM Conversation__Share
            WHERE ParentId IN :conversationIds AND UserOrGroupId = :userId
        ];
        if (!shares.isEmpty())
            delete shares;
    }
    public static Map<Id,Map<Id, List<String>>> peParticipantDelegateNameMap(Set<Id> peIds) {
        List<Patient_Delegate_Enrollment__c> pdeList = [    
                                                            SELECT
                                                            Id,
                                                            Participant_Enrollment__c,
                                                            Patient_Delegate__c,
                                                            Patient_Delegate__r.Contact__c,
                                                            Patient_Delegate__r.Contact__r.Full_Name__c,
                                                            Patient_Delegate__r.Participant__c,
                                                            Patient_Delegate__r.Participant__r.Contact__c,
                                                            Name,
                                                            Status__c,
                                                            Welcome_Message_Sent__c,
                                                            Welcome_Message_Delivered__c,
                                                            Participant_Enrollment__r.study__c
                                                            FROM Patient_Delegate_Enrollment__c
                                                            WHERE Participant_Enrollment__c IN :peIds AND
                                                            Status__c = 'Active'
                                                        ];
        List<Id> delegateContactIds = new List<Id>();
        for (Patient_Delegate_Enrollment__c pd : pdeList)
            delegateContactIds.add(pd.Patient_Delegate__r.Contact__c);
        List<Participant__c> decoupledParticipants = [
            SELECT Id, Contact__c, Full_Name__c
            FROM Participant__c
            WHERE Contact__c IN :delegateContactIds
        ];
         Map<String, SObject> decoupledParticipantsMap;
        if (!decoupledParticipants.isEmpty()) {
            decoupledParticipantsMap = CollectionUtil.getSObjectMap(
                decoupledParticipants,
                'Contact__c'
            );
        }
        Map<Id, List<String>> delegateNamesByParticipant = new Map<Id, List<String>>();
        Map<Id,Map<Id, List<String>>> peDelegateNamesMap = new Map<Id,Map<Id, List<String>>>();
        for (Patient_Delegate_Enrollment__c pd : pdeList) {
            if(!peDelegateNamesMap.containsKey(pd.Participant_Enrollment__c)){
                peDelegateNamesMap.put(pd.Participant_Enrollment__c,new Map<Id, List<String>>());
            }
            if (!delegateNamesByParticipant.containsKey(pd.Participant_Enrollment__c)) {
                delegateNamesByParticipant.put(pd.Participant_Enrollment__c, new List<String>());
            }
            Id delConId = pd.Patient_Delegate__r.Contact__c;
            String delegateName = decoupledParticipantsMap != null &&
                decoupledParticipantsMap.containsKey(delConId)
                ? ((Participant__c) decoupledParticipantsMap.get(delConId)).Full_Name__c
                : pd.Patient_Delegate__r.Contact__r.Full_Name__c;
            delegateNamesByParticipant.get(pd.Participant_Enrollment__c).add(delegateName);
        }
        for (Patient_Delegate_Enrollment__c pd : pdeList) {
            peDelegateNamesMap.get(pd.Participant_Enrollment__c).put(pd.Participant_Enrollment__c,delegateNamesByParticipant.get(pd.Participant_Enrollment__c));
        }
        return peDelegateNamesMap;
    }
    public static Map<Id, List<String>> getYourParticipantsDelegateNames(Id piUserId) {
        List<Conversation__c> sharedConversations = getSharedConversations(piUserId);
        List<Id> participantIds = new List<Id>();
        List<Id> peIds = new List<Id>();
        for (Conversation__c conversation : sharedConversations) {
            participantIds.add(conversation.Participant_Enrollment__r.Participant__c);
            peIds.add(conversation.Participant_Enrollment__c);
        }
        List<Patient_Delegate_Enrollment__c> pdeList = [    
                                                            SELECT
                                                            Id,
                                                            Participant_Enrollment__c,
                                                            Patient_Delegate__c,
                                                            Patient_Delegate__r.Contact__c,
                                                            Patient_Delegate__r.Contact__r.Full_Name__c,
                                                            Patient_Delegate__r.Participant__c,
                                                            Patient_Delegate__r.Participant__r.Contact__c,
                                                            Name,
                                                            Status__c,
                                                            Welcome_Message_Sent__c,
                                                            Welcome_Message_Delivered__c,
                                                            Participant_Enrollment__r.study__c
                                                            FROM Patient_Delegate_Enrollment__c
                                                            WHERE Participant_Enrollment__c IN :peIds AND
                                                            Status__c = 'Active'
                                                        ]; 
        List<Id> delegateContactIds = new List<Id>();
        for (Patient_Delegate_Enrollment__c pd : pdeList)
            delegateContactIds.add(pd.Patient_Delegate__r.Contact__c);

        List<Participant__c> decoupledParticipants = [
            SELECT Id, Contact__c, Full_Name__c
            FROM Participant__c
            WHERE Contact__c IN :delegateContactIds
        ];
        Map<String, SObject> decoupledParticipantsMap;
        if (!decoupledParticipants.isEmpty()) {
            decoupledParticipantsMap = CollectionUtil.getSObjectMap(
                decoupledParticipants,
                'Contact__c'
            );
        }

        Map<Id, List<String>> delegateNamesByParticipant = new Map<Id, List<String>>();
        for (Patient_Delegate_Enrollment__c pd : pdeList) {
            if (!delegateNamesByParticipant.containsKey(pd.Patient_Delegate__r.Participant__c)) {
                delegateNamesByParticipant.put(pd.Patient_Delegate__r.Participant__c, new List<String>());
            }
            Id delConId = pd.Patient_Delegate__r.Contact__c;
            String delegateName = decoupledParticipantsMap != null &&
                decoupledParticipantsMap.containsKey(delConId)
                ? ((Participant__c) decoupledParticipantsMap.get(delConId)).Full_Name__c
                : pd.Patient_Delegate__r.Contact__r.Full_Name__c;
            delegateNamesByParticipant.get(pd.Patient_Delegate__r.Participant__c).add(delegateName);
        }
        return delegateNamesByParticipant;
    }
}