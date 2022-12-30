/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateService {
    public class PatientDelegateServiceException extends Exception {
    }

    private List<Contact> delegates = new List<Contact>();
    private Boolean isDelegate = false;
    public Boolean hasDelegates = false;
    private Participant__c participant;
    public static Patient_Delegate__c patientDel = new Patient_Delegate__c();

    private static PatientDelegateService instance;

    public static PatientDelegateService getInstance() {
        if (instance == null)
            instance = new PatientDelegateService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (PatientDelegateService) Test.createStub(
            PatientDelegateService.class,
            stubProvider
        );
    }

    public PatientDelegateService() {
        List<Patient_Delegate__c> participantsPDList = DatabaseService.query(
            new List<String>{
                'Id',
                'Participant__r.Full_Name__c',
                'Participant__r.Contact__c',
                'Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                'Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                'Participant__r.First_Name__c',
                'Participant__r.Last_Name__c',
                'Contact__c',
                'Contact__r.Participant_Opt_In_Status_Emails__c',
                'Contact__r.Participant_Opt_In_Status_SMS__c',
                'Status__c'
            },
            Patient_Delegate__c.getSObjectType(),
            DatabaseService.fieldEqual(
                'Contact__c',
                CommunityService.getInstance().getCurrentContactId()
            ) +
            ' AND ' +
            DatabaseService.fieldNotEqual('Status__c', 'Withdrawn')
        );
        isDelegate = participantsPDList.size() > 0;
        hasDelegates = isDelegate;
        participant = ParticipantContext.getCurrentParticipant();
        if (participant != null) {
            List<Patient_Delegate__c> delegatesPDList = getPDelegates(
                UserContext.getUserContact().Id
            );
            if (isDelegate) {
                delegatesPDList.addAll(getPDelegates(participant.Contact__c));
            }
            for (Patient_Delegate__c pd : delegatesPDList)
                delegates.add(pd.Contact__r);
        }
    }

    public List<Contact> getDelegates() {
        return delegates;
    }

    public Contact getDelegateContact(Id contactId) {
        Contact delegate;
        for (Contact con : getDelegates()) {
            if (con.Id == contactId)
                delegate = con;
        }
        if (delegate == null)
            throw new PatientDelegateServiceException('Wrong id');

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
            'SELECT Id FROM User WHERE ' +
            DatabaseService.fieldEqual('ContactId', participant.Contact__c) +
            ' LIMIT 1'
        );
        if (users.isEmpty()) {
            throw new PatientDelegateServiceException(
                'No user found for participant: ' +
                participant.First_Name__c +
                ' ' +
                participant.Last_Name__c
            );
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
                'Primary_Delegate__c',
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
                'Contact__r.Participant_Opt_In_Status_SMS__c',
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
        if (participantContactIds.size() == 0) {
            return new List<Patient_Delegate__c>();
        }
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
                'Contact__r.Participant_Opt_In_Status_SMS__c',
                'Contact__r.HCP_Opt_In_Patient_Status_Emails__c',
                'Contact__r.HCP_Opt_In_Study_Emails__c',
                'Contact__r.HCP_Opt_In_Referral_Status_Emails__c',
                'Contact__r.Resource_Notifications__c',
                'Contact__r.userCommunityMode__c',
                'Contact__r.Next_Notify_Date__c',
                'Status__c',
                'Participant__r.Contact__r.Id',
                'Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                'Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                'Primary_Delegate__c'
            },
            Patient_Delegate__c.getSObjectType(),
            DatabaseService.fieldInValues('Participant__r.Contact__c', participantContactIds)
        );
    }

    /*public static List<Contact> getPatientDelegates(Id participantId) {
        List<Patient_Delegate__c> listdel = [SELECT Id, Contact__c FROM Patient_Delegate__c WHERE Participant__c =: participantId];
        Set<Id> setIdDel = new Set<Id>();
        for(Patient_Delegate__c del : listdel){
            setIdDel.add(del.Contact__c);
        }
        List<Contact> contList = [SELECT Id, (SELECT Status__c FROM Contacts__r), (SELECT First_Name__c, Last_Name__c, Email__c FROM Participants__r) FROM Contact WHERE Id IN : setIdDel];
        return contList;

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
    }*/

    public static Map<Id, List<Id>> getDelegatedParticipantIdsMap(List<Id> contactIds) {
        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
        if (!contactIds.isEmpty()) {
            pdList = [
                SELECT Id, Participant__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN :contactIds AND Status__c = 'Active'
            ];
        }
        Map<Id, List<Id>> resMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : pdList) {
            List<Id> participantIds = resMap.get(pd.Contact__c);
            if (participantIds == null)
                participantIds = new List<Id>();
            participantIds.add(pd.Participant__c);
            resMap.put(pd.Contact__c, participantIds);
        }
        return resMap;
    }

    public static List<Id> getDelegatedParticipantIds(Id contactId) {
        return getDelegatedParticipantIdsMap(new List<Id>{ contactId }).get(contactId);
    }

    public List<Id> getDelegatedUsersIds() {
        if (delegates.isEmpty())
            return new List<Id>();

        Map<Id, SObject> usersMap = new Map<Id, SObject>(
            DatabaseService.query(
                'SELECT Id FROM User WHERE ' + DatabaseService.fieldIn('ContactId', delegates)
            )
        );
        return new List<Id>(usersMap.keySet());
    }

    public static List<Contact> getDelegateContacts(Id participantContactId) {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPDelegates(participantContactId))
            contacts.add(pd.Contact__r);
        return contacts;
    }

    public List<Id> getDelegatedContactIds() {
        return SObjectHelper.toIdsList(delegates);
    }

    public static List<Id> getDelegatedContactIds(Id participantContactId) {
        return SObjectHelper.toIdsList(getDelegateContacts(participantContactId));
    }

    public Boolean delegateAlreadyExists(Contact newDelegate) {
        Boolean isDelegateExisting = false;
        List<Participant__c> participant = DatabaseService.getInstance()
            .queryImpl(
                new List<String>{
                    'Id',
                    'Contact__c',
                    'Contact__r.Current_Participant_Enrollment__c'
                },
                Participant__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getUserContact().Id)
            );

        Contact[] newDelegateContact = [
            SELECT Id, UserCommunityIsDelegate__c, userCommunytyType__c, userCommunityMode__c, Email
            FROM Contact
            WHERE Id = :newDelegate.Id
        ];
        Boolean hasWithdrawn = true;
        if (newDelegateContact.size() > 0) {
            List<Patient_Delegate__c> pdList = [
                SELECT Id, Contact__r.Email, Contact__c, Status__c, Participant__c
                FROM Patient_Delegate__c
                WHERE
                    Contact__r.Email = :newDelegateContact[0].Email
                    AND Participant__c = :participant.get(0).Id
            ];

            for (Patient_Delegate__c pd : pdList) {
                if (pd.Status__c != 'Withdrawn') {
                    hasWithdrawn = false;
                }
            }
        }
        for (Id contactId : getDelegatedContactIds()) {
            if (contactId == newDelegate.Id) {
                isDelegateExisting = true;
                break;
            }
        }
        return (isDelegateExisting && (hasWithdrawn == false));
    }
    public void createPatientDelegate(Contact newDelegate,String delegateFilterData) {
        createPatientDelegate(newDelegate);
        if(delegateFilterData!=null){
            //PatientDelegateEnrollmentService.getInstance().createPatientDelegateEnrollment(patientDel,delegateFilterData);
            PatientDelegateEnrollmentService.createPatientDelegateEnrollment(patientDel,delegateFilterData);
       }
    }

    public void createPatientDelegate(Contact newDelegate) {
        List<User> delegateUser = [
            SELECT Id
            FROM User
            WHERE ContactId = :newDelegate.Id AND IsActive = TRUE
        ];
        if (!delegateUser.isEmpty()) {
            List<Conversation__c> patientConversation = ConversationService.getSharedConversations(
                UserInfo.getUserId()
            );
            if (patientConversation != null) {
                List<Id> conversationIds = new List<Id>();
                for (Conversation__c conversation : patientConversation)
                    conversationIds.add(conversation.Id);

                insert ConversationService.createConversationSharesForUser(
                    conversationIds,
                    delegateUser.get(0).Id
                );
            }
        }

        createPDAlerts(newDelegate);

        List<Participant__c> participant = DatabaseService.getInstance()
            .queryImpl(
                new List<String>{
                    'Id',
                    'Contact__c',
                    'Contact__r.Current_Participant_Enrollment__c'
                },
                Participant__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', CommunityService.getUserContact().Id)
            );

        if (participant.size() == 0) {
            throw new PatientDelegateServiceException(
                'Wrong contact: ' + CommunityService.getUserContact().Id
            );
        }

        Contact newDelegateContact = [
            SELECT Id, UserCommunityIsDelegate__c, userCommunytyType__c, userCommunityMode__c, Email
            FROM Contact
            WHERE Id = :newDelegate.Id
        ];
        //Fetch the participant record of the Delegate contact.
        List<Participant__c> delegateParticipant = DatabaseService.getInstance()
            .queryImpl(
                new List<String>{
                    'Id',
                    'Contact__c',
                    'Email__c',
                    'First_Name__c',
                    'Last_Name__c'     
                },
                Participant__c.getSObjectType(),
                DatabaseService.fieldEqual('Contact__c', newDelegate.Id)
            );

        Boolean check =
            String.isBlank(newDelegateContact.userCommunytyType__c) ||
            newDelegateContact.userCommunytyType__c.contains('PI') ||
            newDelegateContact.userCommunytyType__c.contains('HCP');
        if (check)
            newDelegateContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;

        newDelegateContact.UserCommunityIsDelegate__c = true;
        update newDelegateContact;

        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
        List<Patient_Delegate__c> pdToUpsert = new List<Patient_Delegate__c>();
        Patient_Delegate__c pd = new Patient_Delegate__c();
        pd.Contact__c = newDelegate.Id;
        pd.Participant__c = participant.get(0).Id;
        pd.Status__c = 'Active';
        pdList = [
            SELECT Id, 
                    Contact__r.Email, 
                    Contact__c, 
                    Status__c, 
                    Participant__c,
                    Attestation_TimeStamp__c,
                    Attested_by__c,
                    Attestation__c

            FROM Patient_Delegate__c
            WHERE
                Contact__r.Email = :delegateParticipant[0].Email__c
                AND Participant_Delegate__r.First_Name__c =:delegateParticipant[0].First_Name__c
                AND Participant_Delegate__r.Last_Name__c =:delegateParticipant[0].Last_Name__c
                AND Participant__c = :participant.get(0).Id
        ];
        if (pdList.size() > 0 && pdList[0].Id != null) {
            pdList[0].Status__c = 'Active';
            update pdList;
            patientDel =pdList[0];
        } else {
            pd.Attestation__c = true;
            pd.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
            pd.Attested_by__c = participant.get(0).Contact__c;
            insert pd;
            patientDel = pd;
        }
    }

    public void createPDAlerts(Contact contactDelegate) {
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        if (participantState.pe == null)
            return;
        List<Alert__c> alertList = new List<Alert__c>();
        if (
            participantState.pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
            CommunityTemplateService.TEMPLATE_PP
        ) {
            alertList.add(
                new Alert__c(
                    Contact__c = contactDelegate.Id,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_DELEGATE_PP,
                    Record_ID__c = participantState.pe.Id
                )
            );
        } else {
            alertList.add(
                new Alert__c(
                    Contact__c = contactDelegate.Id,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_DELEGATE,
                    Record_ID__c = participantState.pe.Id
                )
            );
        }

        if (participantState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            if (
                participantState.pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                CommunityTemplateService.TEMPLATE_PP
            ) {
                alertList.add(
                    new Alert__c(
                        Contact__c = contactDelegate.Id,
                        Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE_PP,
                        Record_ID__c = participantState.pe.Id
                    )
                );
            } else {
                alertList.add(
                    new Alert__c(
                        Contact__c = contactDelegate.Id,
                        Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                        Record_ID__c = participantState.pe.Id
                    )
                );
            }
        }

        insert alertList;
    }

    public static void changeStatus(Id contactId, String newStatus) {
        List<Patient_Delegate__c> patientDelegate = [
            SELECT Id, Status__c
            FROM Patient_Delegate__c
            WHERE
                Contact__c = :contactId
                AND Participant__c = :ParticipantContext.getCurrentParticipantId()
        ];
        if (!patientDelegate.isEmpty()) {
            patientDelegate.get(0).Status__c = newStatus;
            update patientDelegate;
        }
    }

    public void resetDelegate(Id contactId, Boolean removeHimself) {
        Id ownerContactId = ParticipantContext.getCurrentParticipant().Contact__c;
        String filter =
            DatabaseService.fieldEqual('Contact__c', contactId) +
            'AND' +
            (removeHimself
                ? DatabaseService.fieldEqual('Participant__r.Contact__c', ownerContactId)
                : DatabaseService.fieldEqual(
                      'Participant__r.Contact__c',
                      CommunityService.getInstance().getCurrentContactId()
                  ));

        List<Patient_Delegate__c> patientDelegates = (List<Patient_Delegate__c>) DatabaseService.query(
            new List<String>{ 'Id' },
            Patient_Delegate__c.getSObjectType(),
            filter
        );
        if (!patientDelegates.isEmpty()) {
            delete patientDelegates;

            Id searchContactId = removeHimself ? ownerContactId : contactId;
            List<User> teamUsers = [
                SELECT Id
                FROM User
                WHERE ContactId = :searchContactId AND IsActive = TRUE
            ];
            if (!teamUsers.isEmpty()) {
                Id ownerUserId = removeHimself ? teamUsers.get(0).Id : UserInfo.getUserId();
                Id delegateUserId = removeHimself ? UserInfo.getUserId() : teamUsers.get(0).Id;
                List<Conversation__c> patientConversations = ConversationService.getSharedConversations(
                    ownerUserId
                );
                if (patientConversations != null) {
                    ConversationService.removeConversationSharesForUser(
                        CollectionUtil.getObjectIds(patientConversations),
                        delegateUserId
                    );
                }
            }
        }
    }

    public static Participant__c getParticipantByDelegateContactId(Id contactId) {
        List<Patient_Delegate__c> patientDelegates = [
            SELECT
                Id,
                Participant__r.Contact__c,
                Participant__r.First_Name__c,
                Participant__r.Last_Name__c,
                Participant__r.Full_Name__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :contactId
        ];
        if (patientDelegates.size() > 0)
            return patientDelegates[0].Participant__r;
        return null;
    }

    public static List<Id> getDelegatedContactIdsEmailOptIn(Id participantContactId) {
        List<Id> contacts = new List<Id>();
        for (Contact c : getDelegateContacts(participantContactId)) {
            if (c.Participant_Opt_In_Status_Emails__c)
                contacts.add(c.Id);
        }

        return contacts;
    }

    public static Map<Id, List<Id>> getDelegateContactIdsByPAContactIs(
        List<Id> participantContIds
    ) {
        if (participantContIds.size() == 0) {
            return new Map<Id, List<Id>>();
        }
        List<Patient_Delegate__c> patientDelegates = new List<Patient_Delegate__c>();
        if (!participantContIds.isEmpty()) {
            patientDelegates = [
                SELECT Id, Contact__c, Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN :participantContIds AND Status__c = 'Active'
            ];
        }
        Map<Id, List<Id>> delContIdsByPAContId = new Map<Id, List<Id>>();
        if (patientDelegates.isEmpty())
            return delContIdsByPAContId;

        for (Patient_Delegate__c pd : patientDelegates) {
            Id paConId = pd.Participant__r.Contact__c;
            if (!delContIdsByPAContId.containsKey(paConId))
                delContIdsByPAContId.put(paConId, new List<Id>());

            delContIdsByPAContId.get(paConId).add(pd.Contact__c);
        }

        return delContIdsByPAContId;
    }

    /**
     * @param partContactsIds List with participant contact ids
     * @param delegatedCntFields List with required contact fields
     */
    public static Map<Id, List<Contact>> getDelegatedCntsByParticipantCnt(
        List<Id> partContactsIds,
        List<String> delegatedCntFields
    ) {
        if (partContactsIds.isEmpty()) {
            return new Map<Id, List<Contact>>();
        }
        List<String> pdFields = new List<String>();
        pdFields.add('Participant__r.Contact__c');
        for (String cntField : delegatedCntFields)
            pdFields.add('Contact__r.' + cntField);

        List<Patient_Delegate__c> patientDelegates = (List<Patient_Delegate__c>) DatabaseService.query(
            pdFields,
            Patient_Delegate__c.getSObjectType(),
            DatabaseService.fieldInValues('Participant__r.Contact__c', partContactsIds) +
            ' AND ' +
            DatabaseService.fieldInValues('Status__c', new List<String>{ 'Active' })
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

    public static Map<Id, List<Id>> getDelegatedContactIdsByParticipantIdMap(
        List<Id> participantIds
    ) {
        List<Patient_Delegate__c> delegatesList = [
            SELECT
                Id,
                Participant__c,
                Contact__c,
                Contact__r.Participant_Opt_In_Status_SMS__c,
                Contact__r.Welcome_Message_Sent__c,
                Contact__r.Welcome_Message_Delivered__c
            FROM Patient_Delegate__c
            WHERE Participant__c IN :participantIds AND Status__c = 'Active'
        ];
        Map<Id, List<Id>> delegatedContactsByParticipantMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : delegatesList) {
            List<Id> delegatedContacts = delegatedContactsByParticipantMap.get(pd.Participant__c);
            if (delegatedContacts == null)
                delegatedContacts = new List<Id>();
            delegatedContacts.add(pd.Contact__c);
            delegatedContactsByParticipantMap.put(pd.Participant__c, delegatedContacts);
            ContactService.patientdelList.put(pd.Contact__c, pd);
        }
        return delegatedContactsByParticipantMap;
    }

    public static Map<Id, List<Id>> getParticipantIdsByDelegatedContactIdMap(List<Id> contactIds) {
        List<Patient_Delegate__c> pdList = [
            SELECT Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c IN :contactIds
        ];
        Map<Id, List<Id>> resultMap = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : pdList) {
            List<Id> participantIds = resultMap.get(pd.Contact__c);
            if (participantIds == null)
                participantIds = new List<Id>();
            participantIds.add(pd.Participant__c);
            resultMap.put(pd.Contact__c, participantIds);
        }
        return resultMap;
    }

    public static Map<Id, List<Id>> getPEIdsListByContactIdMap(
        List<Id> contactIds,
        String filter,
        Boolean includeDelegates
    ) {
        Id delContactId = CommunityService.getInstance().getCurrentContactId();
        Set<Id> delPeidsset = new Set<Id>();
        List<Id> delPeids = new List<Id>();

        if (filter == null)
            filter = '';
        String ownPEFilter =
            'Participant__r.Contact__c IN ' + DatabaseService.listToString(contactIds);
        system.debug('ownPEFilter:::'+ownPEFilter); //Participant__r.Contact__c IN ('0037g00001B2uZ8AAJ')

        if(contactIds != null && delContactId != contactIds[0]){
            Map<Id, Patient_Delegate_Enrollment__c> pdelIdMap = new Map<Id, Patient_Delegate_Enrollment__c>(
                [
                    SELECT
                        Id,
                            Patient_Delegate__r.Participant__r.Full_Name__c,
                            Patient_Delegate__r.Id,
                            Welcome_Message_Sent__c,
                            Study_Email_Consent__c,
                            Study_SMS_Consent__c,
                            Welcome_Message_Delivered__c,
                            Patient_Delegate__r.Participant__r.Contact__c,
                            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                            Patient_Delegate__r.Participant__r.First_Name__c,
                            Patient_Delegate__r.Participant__r.Last_Name__c,
                            Patient_Delegate__r.Contact__c,
                            Patient_Delegate__r.Participant__c,   
                            Patient_Delegate__r.Participant_Delegate__r.Id,
                            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                            Patient_Delegate__r.Participant_Delegate__r.Email__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                            Status__c,
                            Participant_Enrollment__c,
                            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                            Participant_Enrollment__r.Name,
                            Participant_Enrollment__r.Clinical_Trial_Profile__c,
                            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE Patient_Delegate__r.Contact__c =: delContactId
                    AND Status__c = 'Active'
                ]
            );    
            if(!pdelIdMap.isEmpty()){
                for(Patient_Delegate_Enrollment__c pde : pdelIdMap.values()){
                    delPeidsset.add(pde.Participant_Enrollment__c);
                }    
            }
        }
        if(delPeidsset != null) delPeids.addAll(delPeidsset);
        if (!String.isEmpty(filter) && delContactId != null && delPeids != null && delPeids.size()>0){
            filter += ' AND Id IN ' +DatabaseService.listToString(delPeids);
            ownPEFilter += ' AND ' + filter;
            system.debug('ownPEFilter:::'+ownPEFilter);
        }
        else if (!String.isEmpty(filter)){
            ownPEFilter += ' AND ' + filter;
        }
        system.debug('ownPEFilter:::'+ownPEFilter);
        List<Participant_Enrollment__c> ownPEList = DatabaseService.query(
            new List<String>{ 'Participant__c', 'Participant__r.Contact__c' },
            Participant_Enrollment__c.getSObjectType(),
            ownPEFilter
        );
        system.debug('ownPEList:::'+ownPEList); //(Participant_Enrollment__c:{Participant__c=a0z7g00000Gr4lkAAB, Id=a0v7g000004KooQAAS})

        Map<Id, List<Id>> resultMap = new Map<Id, List<Id>>();
        for (Participant_Enrollment__c pe : ownPEList) {
            List<Id> ownPEIdsForContact = resultMap.get(pe.Participant__r.Contact__c);
            if (ownPEIdsForContact == null)
                ownPEIdsForContact = new List<Id>();
            ownPEIdsForContact.add(pe.Id);
            resultMap.put(pe.Participant__r.Contact__c, ownPEIdsForContact);
        }

        if (includeDelegates) {
            Map<Id, List<Id>> participantIdsByDelegatedContactIdMap = getParticipantIdsByDelegatedContactIdMap(
                contactIds
            );

            System.debug(
                'Participant Ids >>> ' + JSON.serializePretty(participantIdsByDelegatedContactIdMap)
            );
            List<Id> delegatedParticipantIds = new List<Id>();
            for (List<Id> participantIds : participantIdsByDelegatedContactIdMap.values())
                delegatedParticipantIds.addAll(participantIds);
            String allDelegatedPEFilter = '';
            if (String.isNotBlank(filter))
                allDelegatedPEFilter = ' WHERE ' + filter;
            List<Participant__c> allDelegatedParticipants = DatabaseService.query(
                new List<String>{
                    'Id',
                    ' ( SELECT Id FROM Participant_Profile__r ' +
                    allDelegatedPEFilter +
                    ') '
                },
                Participant__c.getSObjectType(),
                DatabaseService.fieldInValues('Id', delegatedParticipantIds)
            );

            System.debug('>>> All participants: ' + JSON.serializePretty(allDelegatedParticipants));
            Map<Id, List<Id>> peIdsByParticipantIdMap = new Map<Id, List<Id>>();
            for (Participant__c participant : allDelegatedParticipants) {
                List<Id> peIdsForParticipant = new List<Id>();
                for (Participant_Enrollment__c pe : participant.Participant_Profile__r)
                    peIdsForParticipant.add(pe.Id);
                peIdsByParticipantIdMap.put(participant.Id, peIdsForParticipant);
            }

            for (Id contactId : participantIdsByDelegatedContactIdMap.keySet()) {
                List<Id> delegatedParticipantIdsForContact = participantIdsByDelegatedContactIdMap.get(
                    contactId
                );

                if (delegatedParticipantIds == null)
                    delegatedParticipantIds = new List<Id>();
                List<Id> delegatedPEIdsForContact = new List<Id>();
                for (Id participantId : delegatedParticipantIdsForContact) {
                    delegatedPEIdsForContact.addAll(peIdsByParticipantIdMap.get(participantId));
                }
                System.debug('>>> All delegatedPEIdsForContact: ' + (delegatedPEIdsForContact));

                List<Id> allPEIdsForContact = resultMap.get(contactId);
                if (allPEIdsForContact == null)
                    allPEIdsForContact = new List<Id>();
                allPEIdsForContact.addAll(delegatedPEIdsForContact);
                resultMap.put(contactId, allPEIdsForContact);

            }
        }
        return resultMap;
    }

    public static Map<Id, List<Id>> getAvailablePEIdsListByContactIdMap(List<Id> contactIds) {
        return getPEIdsListByContactIdMap(
            contactIds,
            ' Participant_Status__c NOT IN ' +
            DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI),
            true
        );
    }
    // method to return PE Ids for all participant statuses
    public static List<Id> getAvailablePEIDsForAllContacts(Id contactId) {
        list<Id> contactIds = new List<Id>{ contactId };
        List<Id> resList = getPEIdsListByContactIdMap(contactIds, null, true).get(contactId);
        return resList == null ? new List<Id>() : resList;
    }

    public static List<Id> getAvailablePEIdsForContact(Id contactId) {
        List<Id> resList = getAvailablePEIdsListByContactIdMap(new List<Id>{ contactId })
            .get(contactId);
        return resList == null ? new List<Id>() : resList;
    }

    //Get PER record for Delegate for Alumni Participant.
    public static List<Id> getAvailablePEIdsForDelContact(Id contactId) {
        List<Id> resList = getAvailablePEIdsListByDelContactIdMap(new List<Id>{ contactId })
            .get(contactId);
        return resList == null ? new List<Id>() : resList;
    }

    //Get PER record for Delegate for Alumni Participant.
    public static Map<Id, List<Id>> getAvailablePEIdsListByDelContactIdMap(List<Id> contactIds) {
        return getPEIdsListByContactIdMap(
            contactIds,
            ' Participant_Status__c IN ' +
            DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI),
            true
        );
    }

    public static Map<Id, List<Id>> getForExclStatusPEIdsListByContactIdMap(
        List<Id> contactIds,
        List<String> excludedPEStatuses
    ) {
        return getPEIdsListByContactIdMap(
            contactIds,
            ' Participant_Status__c NOT IN ' + DatabaseService.listToString(excludedPEStatuses),
            true
        );
    }

    public static List<Id> getForExclStatusPEIdsForContact(
        Id contactId,
        List<String> excludedPEStatuses
    ) {
        return getForExclStatusPEIdsListByContactIdMap(
                new List<Id>{ contactId },
                excludedPEStatuses
            )
            .get(contactId);
    }

    public static Map<Id, List<Id>> getPastPEIdsListByContactIdMap(List<Id> contactIds) {
        return getPEIdsListByContactIdMap(
            contactIds,
            ' Participant_Status__c IN ' +
            DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI),
            false
        );
    }

    public static List<Id> getPastPEIdsForContact(Id contactId) {
        return getPastPEIdsListByContactIdMap(new List<Id>{ contactId }).get(contactId);
    }

    public static void updatePermissionSets(Set<Id> contactIds) {
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        Patient_Delegate__c[] pdList = [
            SELECT Id, Contact__c, Participant__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE
                Contact__c IN :contactIds
                AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        Map<Id, Set<Id>> delegatedParticipantsMap = new Map<Id, Set<Id>>();
        Set<Id> allDelegatedParticipantIds = new Set<Id>();
        List<Id> delegatedContacts = new List<Id>();
        Map<Id, Set<Id>> delegatedContactsMap = new Map<Id, Set<Id>>();
        for (Patient_Delegate__c pd : pdList) {
            Set<Id> delegatedParticipants = delegatedParticipantsMap.get(pd.Contact__c);
            if (delegatedParticipants == null)
                delegatedParticipants = new Set<Id>();
            delegatedParticipants.add(pd.Participant__c);
            delegatedParticipantsMap.put(pd.Contact__c, delegatedParticipants);
            allDelegatedParticipantIds.add(pd.Participant__c);
            delegatedContacts.add(pd.Participant__r.Contact__c);
            if (!delegatedContactsMap.containsKey(pd.Contact__c))
                delegatedContactsMap.put(pd.Contact__c, new Set<Id>());
            delegatedContactsMap.get(pd.Contact__c).add(pd.Participant__r.Contact__c);
        }

        List<Participant_Enrollment__c> peList = [
            SELECT
                Id,
                Participant__c,
                Participant_Contact__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Participant_Enrollment__c
            WHERE
                (Participant__c IN :allDelegatedParticipantIds
                OR Participant_Contact__c IN :contactIds)
                AND Clinical_Trial_Profile__r.CommunityTemplate__c NOT IN :CommunityModeService.rhSponsorsByCommunity.keySet()
                AND Study_Site__r.Study_Site_Type__c != 'Virtual'
                AND Study_Site__r.Study_Site_Type__c != 'Hybrid'
                AND Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                AND Study_Site__r.Suppress_Participant_Emails__c = FALSE
                AND Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
        ];
        Map<Id, Set<String>> participantPermissions = new Map<Id, Set<String>>();
        Map<Id, Id> participantIdByContactIdMap = new Map<Id, Id>();
        for (Participant_Enrollment__c pe : peList) {
            if (pe.Participant_Contact__c != null && pe.Participant__c != null)
                participantIdByContactIdMap.put(pe.Participant_Contact__c, pe.Participant__c);
            Set<String> permissions = participantPermissions.get(pe.Participant__c);
            if (permissions == null)
                permissions = new Set<String>();
            permissions.add(
                CommunityTemplateService.getTemplate(
                        pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                    )
                    .permissionSet
            );
            participantPermissions.put(pe.Participant__c, permissions);
        }

        Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();

        //get permission sets for delegated contacts
        Map<Id, Set<String>> delegatedContactPermissionsMap = new Map<Id, Set<String>>();
        List<User> delegatedUsers = new List<User>();
        if (!delegatedContacts.isEmpty()) {
            delegatedUsers = [
                SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User
                WHERE ContactId IN :delegatedContacts
            ];

            for (User usr : delegatedUsers) {
                Set<String> permSets = new Set<String>();
                for (PermissionSetAssignment psa : usr.PermissionSetAssignments) {
                    if (communityPermissionSets.contains(psa.PermissionSet.Name)) {
                        permSets.add(psa.PermissionSet.Name);
                    }
                }
                delegatedContactPermissionsMap.put(usr.ContactId, permSets);
            }
        }
        for (Id contactId : contactIds) {
            //assign own permission sets:
            Id ownParticipantId = participantIdByContactIdMap.get(contactId);
            Set<String> ownPermissions;
            if (ownParticipantId != null)
                ownPermissions = participantPermissions.get(ownParticipantId);
            if (ownPermissions != null)
                actionAssignContactPermissions.addPermissions(contactId, ownPermissions);
            //assign all permission sets from available participants:
            Set<Id> participantIds = delegatedParticipantsMap.get(contactId);
            if (participantIds != null && !participantPermissions.isEmpty()) {
                for (Id participantId : participantIds) {
                    if (participantPermissions.containsKey(participantId)) {
                        for (
                            String participantPermissionSet : participantPermissions.get(
                                participantId
                            )
                        ) {
                            if (communityPermissionSets.contains(participantPermissionSet)) {
                                actionAssignContactPermissions.addPermission(
                                    contactId,
                                    participantPermissionSet
                                );
                            }
                        }
                    }
                }
            }
            //assign permissions from delegated contacts
            if (
                delegatedContactsMap.get(contactId) != null &&
                delegatedContactsMap.get(contactId).size() > 0
            ) {
                for (Id delegatedContact : delegatedContactsMap.get(contactId)) {
                    Set<String> permissions = delegatedContactPermissionsMap.get(delegatedContact);
                    if (permissions != null && permissions.size() > 0) {
                        actionAssignContactPermissions.addPermissions(contactId, permissions);
                    }
                }
            }
        }
        System.debug('XXX_ACTION: ' + JSON.serializePretty(actionAssignContactPermissions));

        //add action to queue
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
    }

    public static void updateContactPermSetsWithDelegates(
        Set<Id> participantContactIds,
        Set<Id> invitedPartContactIds
    ) {
        Map<Id, List<Id>> delegatesByParticipant = PatientDelegateService.getDelegateContactIdsByPAContactIs(
            new List<Id>(participantContactIds)
        );
        Set<Id> allContactIds = new Set<Id>(invitedPartContactIds);
        for (Id partKey : delegatesByParticipant.keySet()) {
            for (Id delConId : delegatesByParticipant.get(partKey)) {
                allContactIds.add(delConId);
            }
        }
        PatientDelegateService.updatePermissionSets(allContactIds);
    }
    /**
     * @description: This Method will retun true if the Patient Delegate is Primary delegate else it will return false.
     *
     * @author: Krishna Mahto
     * @param: pdContactId
     * @return: Boolean
     **/
    public static Boolean isPrimaryDelegate(Id pdContactId, Id currentParticipantId) {
        Boolean isPrimaryDelegate = false;
        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
        pdList = [
            SELECT Id, Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :pdContactId AND Participant__c = :currentParticipantId
        ];
        if (pdList != null && !pdList.isEmpty() && pdList[0].Primary_Delegate__c) {
            isPrimaryDelegate = true;
        }
        return isPrimaryDelegate;
    }
    /**
     * @description: This Method will return PD record if Participant is Minor or adult without email. 
     * @author: Krishna Mahto
     * @param: pdContactId
     * @return: List<Patient_Delegate__c> 
     **/
    public static List<Patient_Delegate__c>  getPDForMinorOrAdultWithoutEmailPar(Id pdContactId) {
        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
        pdList = [
            SELECT Id, 
                   Participant__c,
                   Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :pdContactId 
            AND (Participant__r.Adult__c = false OR Participant__r.Email__c = null)
        ];
        
        return pdList;
    }
    /**
     * @description: This Method will return Participant Enrollment record for the given participant Id. 
     * @author: Krishna Mahto
     * @param: ParticipantIdSet
     * @return: List<Participant_Enrollment__c> 
     **/
    public static List<Participant_Enrollment__c>  getPerRecords(Set<Id> ParticipantIdSet) {
        List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        perList = [
            SELECT Id, 
                   Participant_Contact__c,
                   Participant__c,
                   Permit_SMS_Text_for_this_study__c,
                   Welcome_Message_Sent__c,
                   Welcome_Message_Delivered__c
            FROM Participant_Enrollment__c
            WHERE Participant__c IN: ParticipantIdSet 
        ];
        
        return perList;
    }
}