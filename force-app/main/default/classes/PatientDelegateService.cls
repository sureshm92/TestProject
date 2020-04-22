/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateService {

    public class PatientDelegateServiceException extends Exception {
    }

    private List<Contact> delegates = new List<Contact>();
    private Boolean isDelegate = false;
    private Participant__c participant;

    private static PatientDelegateService instance;

    public static PatientDelegateService getInstance() {
        if (instance == null) instance = new PatientDelegateService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (PatientDelegateService) Test.createStub(PatientDelegateService.class, stubProvider);
    }

    public PatientDelegateService() {
        List<Patient_Delegate__c> participantsPDList = DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__r.Full_Name__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Participant__r.First_Name__c',
                        'Participant__r.Last_Name__c',
                        'Contact__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getInstance().getCurrentContactId())
        );
        isDelegate = participantsPDList.size() > 0;
        participant = ParticipantContext.getCurrentParticipant();
        if (participant != null) {
            List<Patient_Delegate__c> delegatesPDList = getPDelegates(UserContext.getUserContact().Id);
            for (Patient_Delegate__c pd : delegatesPDList) delegates.add(pd.Contact__r);
        }
    }

    public List<Contact> getDelegates() {
        return delegates;
    }

    public Contact getDelegateContact(Id contactId) {
        Contact delegate;
        for (Contact con : getDelegates()) {
            if (con.Id == contactId) delegate = con;
        }
        if (delegate == null) throw new PatientDelegateServiceException('Wrong id');

        return delegate;
    }

    public Participant__c getParticipant() {
        return participant;
    }

    public Boolean isDelegate() {
        return isDelegate;
    }

    public Id getParticipantUserId() {
        List<User> users = DatabaseService.query(
                'SELECT Id FROM User WHERE ' + DatabaseService.fieldEqual('ContactId', participant.Contact__c) + ' LIMIT 1'
        );
        if (users.isEmpty()) {
            throw new PatientDelegateServiceException('No user found for participant: '
                    + participant.First_Name__c + ' ' + participant.Last_Name__c);
        }
        return users[0].Id;
    }

    public List<Patient_Delegate__c> getPDelegates() {
        return getPDelegates(CommunityService.getInstance().getCurrentContactId());
    }

    public static List<Patient_Delegate__c> getPDelegates(Id participantContactId) {
        return DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Name',
                        'Contact__c',
                        'Contact__r.Name',
                        'Contact__r.FirstName',
                        'Contact__r.LastName',
                        'Contact__r.Language__c',
                        'Contact__r.Email',
                        'Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Patient_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Study_Emails__c',
                        'Contact__r.HCP_Opt_In_Referral_Status_Emails__c',
                        'Contact__r.Resource_Notifications__c',
                        'Contact__r.userCommunityMode__c',
                        'Contact__r.Next_Notify_Date__c',
                        'Status__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldEqual('Participant__r.Contact__c', participantContactId)
        );
    }

    public static List<Patient_Delegate__c> getPDelegates(List<Id> participantContactIds) {
        return DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Name',
                        'Contact__c',
                        'Contact__r.Name',
                        'Contact__r.FirstName',
                        'Contact__r.LastName',
                        'Contact__r.Language__c',
                        'Contact__r.Email',
                        'Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Patient_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Study_Emails__c',
                        'Contact__r.HCP_Opt_In_Referral_Status_Emails__c',
                        'Contact__r.Resource_Notifications__c',
                        'Contact__r.userCommunityMode__c',
                        'Contact__r.Next_Notify_Date__c',
                        'Status__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldInValues('Participant__r.Contact__c', participantContactIds)
        );
    }

    public static List<Patient_Delegate__c> getPatientDelegates(Id participantId) {
        return DatabaseService.query(
                new List<String>{
                        'Id',
                        'Participant__c',
                        'Participant__r.Contact__c',
                        'Participant__r.Contact__r.Name',
                        'Contact__c',
                        'Contact__r.Name',
                        'Contact__r.FirstName',
                        'Contact__r.LastName',
                        'Contact__r.Language__c',
                        'Contact__r.Email',
                        'Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Patient_Status_Emails__c',
                        'Contact__r.HCP_Opt_In_Study_Emails__c',
                        'Contact__r.HCP_Opt_In_Referral_Status_Emails__c',
                        'Contact__r.Resource_Notifications__c',
                        'Contact__r.userCommunityMode__c',
                        'Contact__r.Next_Notify_Date__c',
                        'Status__c'
                },
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldEqual('Participant__c', participantId)
        );
    }

    public static Map<Id, List<Id>> getDelegatedParticipantIdsMap(List<Id> contactIds) {
        List<Patient_Delegate__c> pdList = [
                SELECT Id, Participant__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN:contactIds AND Status__c = 'Active'
        ];
        Map<Id, List<Id>> resMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : pdList) {
            List<Id> participantIds = resMap.get(pd.Contact__c);
            if (participantIds == null) participantIds = new List<Id>();
            participantIds.add(pd.Participant__c);
            resMap.put(pd.Contact__c, participantIds);
        }
        return resMap;
    }

    public static List<Id> getDelegatedParticipantIds(Id contactId) {
        return getDelegatedParticipantIdsMap(new List<Id>{
                contactId
        }).get(contactId);
    }

    public List<Id> getDelegatedUsersIds() {
        if (delegates.isEmpty()) return new List<Id>();

        Map<Id, SObject> usersMap = new Map<Id, SObject>(
                DatabaseService.query('SELECT Id FROM User WHERE ' + DatabaseService.fieldIn('ContactId', delegates))
        );
        return new List<Id>(usersMap.keySet());
    }

    public static List<Contact> getDelegateContacts(Id participantContactId) {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPDelegates(participantContactId)) contacts.add(pd.Contact__r);
        return contacts;
    }

    public List<Id> getDelegatedContactIds() {
        return SObjectHelper.toIdsList(delegates);
    }

    public static List<Id> getDelegatedContactIds(Id participantContactId) {
        return SObjectHelper.toIdsList(getDelegateContacts(participantContactId));
    }

    public void createPatientDelegate(Contact newDelegate) {
        for (Id contactId : getDelegatedContactIds()) {
            if (contactId == newDelegate.Id) {
                throw new PatientDelegateServiceException(Label.PG_PST_L_Delegates_WrongAdd);
            }
        }

        List<User> delegateUser = [SELECT Id FROM User WHERE ContactId = :newDelegate.Id AND IsActive = TRUE];
        if (!delegateUser.isEmpty()) {
            List<Conversation__c> patientConversation = ConversationService.getSharedConversations(UserInfo.getUserId());
            if (patientConversation != null) {
                List<Id> conversationIds = new List<Id>();
                for (Conversation__c conversation : patientConversation) conversationIds.add(conversation.Id);

                insert ConversationService.createConversationSharesForUser(conversationIds, delegateUser.get(0).Id);
            }
        }

        createPDAlerts(newDelegate);

        List<Participant__c> participant = DatabaseService.getInstance().queryImpl(
                new List<String>{
                        'Id', 'Contact__c', 'Contact__r.Current_Participant_Enrollment__c'
                },
                Participant__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getUserContact().Id)
        );

        if (participant.size() == 0) {
            throw new PatientDelegateServiceException('Wrong contact: ' + CommunityService.getUserContact().Id);
        }

        Patient_Delegate__c delegate = new Patient_Delegate__c(
                Contact__c = newDelegate.Id,
                Participant__c = participant.get(0).Id
        );
        insert delegate;
    }

    public void createPDAlerts(Contact contactDelegate) {
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        if (participantState.pe == null) return ;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(new Alert__c(
                Contact__c = contactDelegate.Id,
                Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_DELEGATE,
                Record_ID__c = participantState.pe.Id
        ));

        if (participantState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            alertList.add(new Alert__c(
                    Contact__c = contactDelegate.Id,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                    Record_ID__c = participantState.pe.Id
            ));
        }

        insert alertList;
    }

    public static void changeStatus(Id contactId, String newStatus) {
        List<Patient_Delegate__c> patientDelegate = [SELECT Id, Status__c FROM Patient_Delegate__c WHERE Contact__c = :contactId];
        if(!patientDelegate.isEmpty()) {
            patientDelegate.get(0).Status__c = newStatus;
            update patientDelegate;
        }
    }

    public void resetDelegate(Id contactId, Boolean removeHimself) {
        Id ownerContactId = ParticipantContext.getCurrentParticipant().Contact__c;
        String filter = DatabaseService.fieldEqual('Contact__c', contactId) + 'AND'
                + (removeHimself ? DatabaseService.fieldEqual('Participant__r.Contact__c', ownerContactId)
                : DatabaseService.fieldEqual('Participant__r.Contact__c', CommunityService.getInstance().getCurrentContactId()));

        List<Patient_Delegate__c> patientDelegates = (List<Patient_Delegate__c>) DatabaseService.query(
                new List<String>{
                        'Id'
                },
                Patient_Delegate__c.getSObjectType(),
                filter
        );
        if (!patientDelegates.isEmpty()) {
            delete patientDelegates;

            Id searchContactId = removeHimself ? ownerContactId : contactId;
            List<User> teamUsers = [
                    SELECT Id
                    FROM User
                    WHERE ContactId = :searchContactId
                    AND IsActive = TRUE
            ];
            if (!teamUsers.isEmpty()) {
                Id ownerUserId = removeHimself ? teamUsers.get(0).Id : UserInfo.getUserId();
                Id delegateUserId = removeHimself ? UserInfo.getUserId() : teamUsers.get(0).Id;
                List<Conversation__c> patientConversations = ConversationService.getSharedConversations(ownerUserId);
                if (patientConversations != null) {
                    ConversationService.removeConversationSharesForUser(CollectionUtil.getObjectIds(patientConversations), delegateUserId);
                }
            }
        }
    }

    public static Participant__c getParticipantByDelegateContactId(Id contactId) {
        List<Patient_Delegate__c> patientDelegates = [
                SELECT Id,
                        Participant__r.Contact__c,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Participant__r.Full_Name__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :contactId
        ];
        if (patientDelegates.size() > 0) return patientDelegates[0].Participant__r;
        return null;
    }

    public static List<Id> getDelegatedContactIdsEmailOptIn(Id participantContactId) {
        List<Id> contacts = new List<Id>();
        for (Contact c : getDelegateContacts(participantContactId)) {
            if (c.Participant_Opt_In_Status_Emails__c) contacts.add(c.Id);
        }

        return contacts;
    }

    public static Map<Id, List<Id>> getDelegateContactIdsByPAContactIs(List<Id> participantContIds) {
        List<Patient_Delegate__c> patientDelegates = [
                SELECT Id, Contact__c, Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN:participantContIds
        ];

        Map<Id, List<Id>> delContIdsByPAContId = new Map<Id, List<Id>>();
        if (patientDelegates.isEmpty()) return delContIdsByPAContId;

        for (Patient_Delegate__c pd : patientDelegates) {
            Id paConId = pd.Participant__r.Contact__c;
            if (!delContIdsByPAContId.containsKey(paConId)) delContIdsByPAContId.put(paConId, new List<Id>());

            delContIdsByPAContId.get(paConId).add(pd.Contact__c);
        }

        return delContIdsByPAContId;
    }

    /**
     * @param partContactsIds List with participant contact ids
     * @param delegatedCntFields List with required contact fields
     */
    public static Map<Id, List<Contact>> getDelegatedCntsByParticipantCnt(List<Id> partContactsIds, List<String> delegatedCntFields) {
        List<String> pdFields = new List<String>();
        pdFields.add('Participant__r.Contact__c');
        for (String cntField : delegatedCntFields) pdFields.add('Contact__r.' + cntField);

        List<Patient_Delegate__c> patientDelegates = (List<Patient_Delegate__c>) DatabaseService.query(
                pdFields,
                Patient_Delegate__c.getSObjectType(),
                DatabaseService.fieldInValues('Participant__r.Contact__c', partContactsIds)
        );

        Map<Id, List<Contact>> delContactsByPartCnt = new Map<Id, List<Contact>>();
        for (Patient_Delegate__c pd : patientDelegates) {
            Id partCntId = pd.Participant__r.Contact__c;
            if (!delContactsByPartCnt.containsKey(partCntId)) {
                delContactsByPartCnt.put(partCntId, new List<Contact>());
            }

            delContactsByPartCnt.get(partCntId).add(pd.Contact__r);
        }

        return delContactsByPartCnt;
    }

    public static Map<Id, List<Id>> getDelegatedContactIdsByParticipantIdMap(List<Id> participantIds) {
        List<Patient_Delegate__c> delegatesList = [
                SELECT Id, Participant__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__c IN:participantIds
        ];
        Map<Id, List<Id>> delegatedContactsByParticipantMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : delegatesList) {
            List<Id> delegatedContacts = delegatedContactsByParticipantMap.get(pd.Participant__c);
            if (delegatedContacts == null) delegatedContacts = new List<Id>();
            delegatedContacts.add(pd.Contact__c);
            delegatedContactsByParticipantMap.put(pd.Participant__c, delegatedContacts);
        }
        return delegatedContactsByParticipantMap;
    }

    public static Map<Id, List<Id>> getParticipantIdsByDelegatedContactIdMap(List<Id> contactIds) {
        List<Patient_Delegate__c> pdList = [
                SELECT Participant__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN:contactIds
        ];
        Map<Id, List<Id>> resultMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : pdList) {
            List<Id> participantIds = resultMap.get(pd.Contact__c);
            if (participantIds == null) participantIds = new List<Id>();
            participantIds.add(pd.Participant__c);
            resultMap.put(pd.Contact__c, participantIds);
        }
        return resultMap;
    }

    public static Map<Id, List<Id>> getPEIdsListByContactIdMap(List<Id> contactIds, String filter, Boolean includeDelegates) {
        if (filter == null) filter = '';
        String ownPEFilter = 'Participant__r.Contact__c IN ' + DatabaseService.listToString(contactIds);
        if (!String.isEmpty(filter)) ownPEFilter += ' AND ' + filter;
        List<Participant_Enrollment__c> ownPEList = DatabaseService.query(
                new List<String>{
                        'Participant__c',
                        'Participant__r.Contact__c'
                },
                Participant_Enrollment__c.getSObjectType(),
                ownPEFilter);
        Map<Id, List<Id>> resultMap = new Map<Id, List<Id>>();
        for (Participant_Enrollment__c pe : ownPEList) {
            List<Id> ownPEIdsForContact = resultMap.get(pe.Participant__r.Contact__c);
            if (ownPEIdsForContact == null) ownPEIdsForContact = new List<Id>();
            ownPEIdsForContact.add(pe.Id);
            resultMap.put(pe.Participant__r.Contact__c, ownPEIdsForContact);
        }

        if (includeDelegates) {
            Map<Id, List<Id>> participantIdsByDelegatedContactIdMap = getParticipantIdsByDelegatedContactIdMap(contactIds);
            System.debug('Participant Ids >>> ' + JSON.serializePretty(participantIdsByDelegatedContactIdMap));
            List<Id> delegatedParticipantIds = new List<Id>();
            for (List<Id> participantIds : participantIdsByDelegatedContactIdMap.values()) delegatedParticipantIds.addAll(participantIds);
            String allDelegatedPEFilter = '';
            if (String.isNotBlank(filter)) allDelegatedPEFilter = ' WHERE ' + filter;
            List<Participant__c> allDelegatedParticipants = DatabaseService.query(new List<String>{
                    'Id',
                    ' ( SELECT Id FROM Participant_Profile__r ' + allDelegatedPEFilter + ') '
            }, Participant__c.getSObjectType(), DatabaseService.fieldInValues('Id', delegatedParticipantIds));
            System.debug('>>> All participants: ' + JSON.serializePretty(allDelegatedParticipants));
            Map<Id, List<Id>> peIdsByParticipantIdMap = new Map<Id, List<Id>>();
            for (Participant__c participant : allDelegatedParticipants) {
                List<Id> peIdsForParticipant = new List<Id>();
                for (Participant_Enrollment__c pe : participant.Participant_Profile__r) peIdsForParticipant.add(pe.Id);
                peIdsByParticipantIdMap.put(participant.Id, peIdsForParticipant);
            }

            for (Id contactId : participantIdsByDelegatedContactIdMap.keySet()) {
                List<Id> delegatedParticipantIdsForContact = participantIdsByDelegatedContactIdMap.get(contactId);
                if (delegatedParticipantIds == null) delegatedParticipantIds = new List<Id>();
                List<Id> delegatedPEIdsForContact = new List<Id>();
                for (Id participantId : delegatedParticipantIdsForContact) {
                    delegatedPEIdsForContact.addAll(peIdsByParticipantIdMap.get(participantId));
                }
                List<Id> allPEIdsForContact = resultMap.get(contactId);
                if (allPEIdsForContact == null) allPEIdsForContact = new List<Id>();
                allPEIdsForContact.addAll(delegatedPEIdsForContact);
                resultMap.put(contactId, allPEIdsForContact);
            }
        }
        return resultMap;
    }

    public static Map<Id, List<Id>> getAvailablePEIdsListByContactIdMap(List<Id> contactIds) {
        return getPEIdsListByContactIdMap(
                contactIds,
                ' Participant_Status__c NOT IN ' + DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI),
                true
        );
    }

    public static List<Id> getAvailablePEIdsForContact(Id contactId) {
        List<Id> resList = getAvailablePEIdsListByContactIdMap(new List<Id>{
                contactId
        }).get(contactId);
        return resList == null ? new List<Id>() : resList;
    }

    public static Map<Id, List<Id>> getForExclStatusPEIdsListByContactIdMap(List<Id> contactIds, List<String> excludedPEStatuses) {
        return getPEIdsListByContactIdMap(
                contactIds,
                ' Participant_Status__c NOT IN ' + DatabaseService.listToString(excludedPEStatuses),
                true
        );
    }

    public static List<Id> getForExclStatusPEIdsForContact(Id contactId, List<String> excludedPEStatuses) {
        return getForExclStatusPEIdsListByContactIdMap(new List<Id>{
                contactId
        }, excludedPEStatuses).get(contactId);
    }

    public static Map<Id, List<Id>> getPastPEIdsListByContactIdMap(List<Id> contactIds) {
        return getPEIdsListByContactIdMap(
                contactIds,
                ' Participant_Status__c IN ' + DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI),
                false
        );
    }

    public static List<Id> getPastPEIdsForContact(Id contactId) {
        return getPastPEIdsListByContactIdMap(new List<Id>{
                contactId
        }).get(contactId);
    }

    public static void updatePermissionSets(Set<Id> contactIds) {
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        Patient_Delegate__c[] pdList = [
                SELECT Id, Contact__c, Participant__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN:contactIds AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        Map<Id, Set<Id>> delegatedParticipantsMap = new Map<Id, Set<Id>>();
        Set<Id> allDelegatedParticipantIds = new Set<Id>();
        for (Patient_Delegate__c pd : pdList) {
            Set<Id> delegatedParticipants = delegatedParticipantsMap.get(pd.Contact__c);
            if (delegatedParticipants == null) delegatedParticipants = new Set<Id>();
            delegatedParticipants.add(pd.Participant__c);
            delegatedParticipantsMap.put(pd.Contact__c, delegatedParticipants);
            allDelegatedParticipantIds.add(pd.Participant__c);
        }

        List<Participant_Enrollment__c> peList = [
                SELECT Id,
                        Participant__c,
                        Participant_Contact__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN:allDelegatedParticipantIds OR Participant_Contact__c IN:contactIds
        ];
        Map<Id, Set<String>> participantPermissions = new Map<Id, Set<String>>();
        Map<Id, Id> participantIdByContactIdMap = new Map<Id, Id>();
        for (Participant_Enrollment__c pe : peList) {
            if (pe.Participant_Contact__c != null && pe.Participant__c != null) participantIdByContactIdMap.put(pe.Participant_Contact__c, pe.Participant__c);
            Set<String> permissions = participantPermissions.get(pe.Participant__c);
            if (permissions == null) permissions = new Set<String>();
            permissions.add(CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
            participantPermissions.put(pe.Participant__c, permissions);
        }

        for (Id contactId : contactIds) {
            Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();

            //assign own permission sets:
            Id ownParticipantId = participantIdByContactIdMap.get(contactId);
            Set<String> ownPermissions;
            if (ownParticipantId != null) ownPermissions = participantPermissions.get(ownParticipantId);
            if (ownPermissions != null) actionAssignContactPermissions.addPermissions(contactId, ownPermissions);
            //assign all permission sets from available participants:
            Set<Id> participantIds = delegatedParticipantsMap.get(contactId);
            if (participantIds != null && !participantPermissions.isEmpty()) {
                for (Id participantId : participantIds) {
                    if (participantPermissions.containsKey(participantId)) {
                        for (String participantPermissionSet : participantPermissions.get(participantId)) {
                            if (communityPermissionSets.contains(participantPermissionSet)) {
                                actionAssignContactPermissions.addPermission(contactId, participantPermissionSet);
                            }
                        }
                    }
                }
            }
        }

        //add action to queue
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
    }
    
    public static void updateContactPermSetsWithDelegates(Set<Id> participantContactIds){
        Map<Id, List<Id>> delegatesByParticipant = PatientDelegateService.getDelegateContactIdsByPAContactIs(new List<Id>(participantContactIds));
        Set<Id> allContactIds = new Set<Id>(participantContactIds);
        for(Id partKey : delegatesByParticipant.keySet()) {
            for(Id delConId : delegatesByParticipant.get(partKey)) {
                allContactIds.add(delConId);
            }
        }
        PatientDelegateService.updatePermissionSets(allContactIds);
    }
}

