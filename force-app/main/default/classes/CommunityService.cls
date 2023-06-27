/**
 * Created by D.Yasinskyi on 21.02.2018
 */
public without sharing class CommunityService {
    public static final String IQVIA_NETWORK_NAME = 'IQVIA Referral Hub';
    public static final String GSK_NETWORK_NAME = 'GSK Community';
    public static final String JANSSEN_NETWORK_NAME = 'Janssen Community';
    public static final String JANSSEN_COMMUNITY_TEMPLATE = 'Janssen';

    public static List<String> strusrName = new List<String>();
    public static final String COMMUNITY_USER_PROFILE_NAME = 'IQVIA Customer Community Plus Login User';
    public static final String CC_COMMUNITY_USER_PROFILE_NAME = 'IQVIA Call Center Login User';
    public static final Id COMMUNITY_USER_PROFILE_ID = [
        SELECT Id
        FROM Profile
        WHERE Name = :COMMUNITY_USER_PROFILE_NAME
    ]
    .Id;

    public static final Id CC_COMMUNITY_USER_PROFILE_ID = [
        SELECT Id
        FROM Profile
        WHERE Name = :CC_COMMUNITY_USER_PROFILE_NAME
    ]
    .Id;

    public static String COMMUNITY_PARTICIPANT_ACCOUNT_NAME = 'Participant';
    public static String COMMUNITY_DELEGATE_ACCOUNT_NAME = 'Delegate';

    //community email process
    public static String COMMUNITY_ET_DELEGATE_WELCOME = 'Initial_Email'; //email template

    // org wide email address
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_REFERRAL = 'IQVIA Referral Hub';
    public static final String COMMUNITY_ORG_WIDE_ADDRESS_PATIENT = 'IQVIA Patient Portal';

    // case auto assignment rule
    public static String COMMUNITY_CASE_AR_NAME = 'HelpCase';

    // lead queue
    public static String INVITATION_QUEUE = 'Referring Providers Invited by PI Queue';

    //on Contact.userCommunityMode__c
    public static final String USER_MODE_HCP = 'HCP';
    public static final String USER_MODE_PI = 'PI';
    public static final String USER_MODE_PARTICIPANT = 'Participant';
    public static final String USER_MODE_CC = 'CC';
    public static final String USER_MODE_DELEGATEPI = 'DelegatePI';
    //Exception messages
    public static String ERROR_MISSING_STUDY = 'Unexpected error occurred. Contact administrator.';
    private static String ERROR_MISSING_CONTACT_ON_USER = 'User Contact can not be NULL';
    private static String ERROR_MISSING_PARTICIPANT_ON_CONTACT = 'Contact does not have related Participant';

    //hold contact instance:
    private static Contact userContact;
    private static Id userId = UserInfo.getUserId();

    private static CommunityService instance;

    public static CommunityService getInstance() {
        if (instance == null)
            instance = new CommunityService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (CommunityService) Test.createStub(CommunityService.class, stubProvider);
    }

    public Id getCurrentContactId() {
        return UserContext.getUserContactId();
    }

    public String getUserAccessLevel(String delegateId) {
        String accessLevel;
        try {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            accessLevel = [
                SELECT Delegate_Access_Level__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :currentContactId AND Referring_Provider__c = :delegateId
                LIMIT 1
            ]
            .Delegate_Access_Level__c;
        } catch (Exception ex) {
            accessLevel = null;
        }
        return accessLevel;
    }

    //Old static logic: ------------------------------------------------------------------------------------------------

    public static Contact getUserContact() {
        return UserContext.getUserContact();
    }

    public static Id getUserId() {
        return UserContext.getUserId();
    }

    public static Map<String, Integer> getMaxLength(Sobject so, List<String> fieldNames) {
        Map<String, Integer> lengthByFieldName = new Map<String, Integer>();
        for (String field : fieldNames) {
            Integer length = so.getSObjectType()
                .getDescribe()
                .fields.getMap()
                .get(field)
                .getDescribe()
                .length;
            lengthByFieldName.put(field, length);
        }
        return lengthByFieldName;
    }

    //Todo remove this:
    public String getParticipantId() {
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (currentUser.ContactId == null) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_CONTACT_ON_USER);
        }
        Contact contact = [
            SELECT Id, (SELECT Id FROM Participants__r)
            FROM Contact
            WHERE Id = :currentUser.ContactId
        ];
        ParticipantService.ParticipantState state = ParticipantService.getParticipantState();
        if (contact.Participants__r.size() != 0 && !state.isDelegate) {
            return contact.Participants__r[0].Id;
        } else if (state.isDelegate) {
            return state.participant.Id;
        } else {
            throw new CommunityServiceException(
                CommunityService.ERROR_MISSING_PARTICIPANT_ON_CONTACT
            );
        }
    }

    public static List<Contact> getContactsByUserContactIds(Set<Id> userContactIds) {
        return [
            SELECT Id, userCommunityMode__c, userCommunytyType__c
            FROM Contact
            WHERE Id IN :userContactIds
            FOR UPDATE
        ];
    }

    public static List<User> getCommunityUsersByContactIds(Set<Id> contactIds) {
        List<User> lstUser = new List<User>();
        if (!contactIds.isEmpty()) {
            lstUser = [
                SELECT
                    Id,
                    Name,
                    FirstName,
                    LastName,
                    ContactId,
                    Email,
                    IsActive,
                    (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User
                WHERE
                    //Profile.Name = :COMMUNITY_USER_PROFILE_NAME AND
                    ContactId IN :contactIds
            ];
        }
        return lstUser;
        //AND email != null
    }

    public static Boolean isUserModeValid(String userMode) {
        Contact userContact = getUserContact();
        if (userContact == null)
            return false;
        return userContact.userCommunytyType__c.contains(userMode);
    }

    //return converted status to display
    public static String getConvertedStatus(String fullStatus) {
        return fullStatus.split(' \\(')[0];
    }

    public static Profile getCommunityProfile() {
        return [SELECT Id FROM Profile WHERE Name = :COMMUNITY_USER_PROFILE_NAME];
    }

    public void createPortalUsers(Set<Id> contactIds) {
        List<Contact> contacts = getContacts(contactIds);
        List<User> newPortalUsers = new List<User>();
        for (Contact cont : contacts)
            newPortalUsers.add(createUser(cont, null, null, null));
        insert newPortalUsers;
    }

    public void createCCPortalUsers(Set<Id> contactIds) {
        List<Contact> contacts = getContacts(contactIds);
        List<User> newPortalUsers = new List<User>();
        for (Contact cont : contacts)
            newPortalUsers.add(createCCUser(cont, null, null, null));
        insert newPortalUsers;
    }

    //Create participant users, fill time zone, locale and language from HCP contact
    public List<User> createParticipantUsers(Map<Id, Id> contactIdsMap) {
        System.debug('ParticipantContactId -> HCPContactId MAP: ' + contactIdsMap);
        List<Contact> contacts = getContacts(contactIdsMap.keySet());
        List<User> hcpUsers = [
            SELECT Id, ContactId, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey
            FROM User
            WHERE ContactId IN :contactIdsMap.values() AND LocaleSidKey != NULL
        ];
        Map<Id, User> hcpUsersMap = new Map<Id, User>();
        for (User hcp : hcpUsers)
            hcpUsersMap.put(hcp.ContactId, hcp);

        List<User> newPortalUsers = new List<User>();
        Set<String> usedNames = new Set<String>();
        for (Contact cont : contacts) {
            String timeZone;
            String locale;
            String language;
            User hcpUser = hcpUsersMap.get(contactIdsMap.get(cont.Id));
            if (hcpUser != null) {
                timeZone = hcpUser.TimeZoneSidKey;
                locale = hcpUser.LocaleSidKey;
                language = hcpUser.LanguageLocaleKey;
            }
            if (
                !cont.Participants__r.isEmpty() &&
                cont.Participants__r[0].Preferred_Language__c != null
            ) {
                cont.Language__c = cont.Participants__r[0].Preferred_Language__c;
            }
            if (cont.Language__c != null)
                language = cont.Language__c;
            if (cont.Email != null && cont.Email != '') {
                newPortalUsers.add(createUser(cont, locale, language, timeZone));
            }
        }
        System.debug('newPortalUsers' + newPortalUsers);
        insert newPortalUsers;
        System.debug('Portal users successfully created = ' + newPortalUsers.size());
        return newPortalUsers;
    }

    public List<User> createParticipantUsersBulk(Map<Id, Id> contactIdsMap) {
        System.debug('ParticipantContactId -> HCPContactId MAP: ' + contactIdsMap);
        List<Contact> contacts = getContacts(contactIdsMap.keySet());
        List<User> hcpUsers = [
            SELECT Id, ContactId, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey
            FROM User
            WHERE ContactId IN :contactIdsMap.values() AND LocaleSidKey != NULL
        ];
        System.debug('ParticipantContactId 11-> ');
        Map<Id, User> hcpUsersMap = new Map<Id, User>();
        for (User hcp : hcpUsers)
            hcpUsersMap.put(hcp.ContactId, hcp);

        List<User> newPortalUsers = new List<User>();
        Set<String> usedNames = new Set<String>();
        for (Contact cont : contacts) {
            String timeZone;
            String locale;
            String language;
            System.debug('forloop->');
            User hcpUser = hcpUsersMap.get(contactIdsMap.get(cont.Id));
            if (hcpUser != null) {
                timeZone = hcpUser.TimeZoneSidKey;
                locale = hcpUser.LocaleSidKey;
                language = hcpUser.LanguageLocaleKey;
            }
            if (
                !cont.Participants__r.isEmpty() &&
                cont.Participants__r[0].Preferred_Language__c != null
            ) {
                cont.Language__c = cont.Participants__r[0].Preferred_Language__c;
            }
            if (cont.Language__c != null)
                language = cont.Language__c;
            if (cont.Email != null && cont.Email != '') {
                newPortalUsers.add(createUserBulk(cont, locale, language, timeZone));
            }
        }
        System.debug('newPortalUsers' + newPortalUsers);
        insert newPortalUsers;
        System.debug('Portal users successfully created = ' + newPortalUsers.size());
        return newPortalUsers;
    }

    public void createParticipantUsersAsync(
        Map<Id, Id> contactIdsMap,
        Set<Id> participantContactIds,
        Set<Id> peIds
    ) {
        System.enqueueJob(new CreateParticipantUsersAsync(contactIdsMap, participantContactIds, peIds));
    }

    public static User createUser(Contact cont, String locale, String language, String timeZone) {
        if (locale == null)
            locale = 'en_US';
        if (language == null) {
            if (cont.Language__c == null) {
                language = 'en_US';
            } else {
                language = cont.Language__c;
            }
        }
        if (timeZone == null)
            timeZone = 'America/Los_Angeles';
        String newUserName = getAvailableUserName(cont.Email);
        User newUser = new User(
            ProfileId = COMMUNITY_USER_PROFILE_ID,
            Username = newUserName,
            Email = cont.Email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = locale,
            LanguageLocaleKey = language,
            TimeZoneSidKey = timeZone,
            ContactId = cont.Id,
            LastName = cont.LastName,
            FirstName = cont.FirstName,
            Alias = 'test', //todo
            IsActive = true
        );

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;
        newUser.setOptions(dlo);
        return newUser;
    }

    public static User createUserBulk(
        Contact cont,
        String locale,
        String language,
        String timeZone
    ) {
        if (locale == null)
            locale = 'en_US';
        if (language == null) {
            if (cont.Language__c == null) {
                language = 'en_US';
            } else {
                language = cont.Language__c;
            }
        }
        if (timeZone == null)
            timeZone = 'America/Los_Angeles';
        String newUserName = getAvailableUserNameBulk(cont.Email);
        strusrName.add(newUserName);
        User newUser = new User(
            ProfileId = COMMUNITY_USER_PROFILE_ID,
            Username = newUserName,
            Email = cont.Email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = locale,
            LanguageLocaleKey = language,
            TimeZoneSidKey = timeZone,
            ContactId = cont.Id,
            LastName = cont.LastName,
            FirstName = cont.FirstName,
            Alias = 'test', //todo
            IsActive = true
        );

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;
        newUser.setOptions(dlo);
        return newUser;
    }

    //for activating CC Users
    @Future
    public static void ActivateUsers(Set<Id> contactIds) {
        List<User> users = [SELECT Id, IsActive FROM User WHERE ContactId IN :contactIds];
        for (User u : users)
            u.IsActive = true;
        update users;
    }

    @Future
    public static void deactivateUsers(List<Id> contactIds) {
        List<User> users = [SELECT Id, IsActive FROM User WHERE ContactId IN :contactIds];
        for (User u : users)
            u.IsActive = false;
        update users;
    }

    public static List<Contact> getContacts(Set<Id> contactIds, Boolean queryParticipants) {
        if (queryParticipants == true) {
            return [
                SELECT
                    Id,
                    (
                        SELECT
                            Id,
                            First_Name__c,
                            Salutation__c,
                            Full_Name__c,
                            Suffix__c,
                            Last_Name__c
                        FROM Participants__r
                    ),
                    Email,
                    FirstName,
                    LastName,
                    Name,
                    Language__c,
                    Library_Primary_Language__c,
                    Full_Name__c,
                    Salutation,
                    Suffix
                FROM Contact
                WHERE Id = :contactIds
                FOR UPDATE
                //ORDER BY Name
            ];
        } else {
            return [
                SELECT
                    Id,
                    Email,
                    FirstName,
                    LastName,
                    Name,
                    Language__c,
                    Library_Primary_Language__c,
                    Full_Name__c,
                    Salutation,
                    Suffix
                FROM Contact
                WHERE Id = :contactIds
                FOR UPDATE
                //ORDER BY Name
            ];
        }
    }

    public static List<Contact> getContacts(Set<Id> contactIds) {
        return [
            SELECT
                Id,
                Email,
                FirstName,
                LastName,
                Name,
                Language__c,
                Library_Primary_Language__c,
                Full_Name__c,
                Salutation,
                Suffix
            FROM Contact
            WHERE Id = :contactIds
            FOR UPDATE
            //ORDER BY Name
        ];
    }

    public static List<Contact> getContactsWithFields(Set<Id> contactIds, List<String> fields) {
        String queryString =
            'SELECT ' +
            String.join(fields, ',') +
            ' FROM Contact WHERE Id IN: contactIds FOR UPDATE';
        return Database.query(queryString);
    }

    private static String getAvailableUserName(String email) {
        List<String> names = new List<String>();
        names.add(email);
        for (Integer i = 1; i < 100; i++) {
            String numberStr = (100 + i) + '';
            numberStr = numberStr.right(2);
            names.add(email + '.' + numberStr);
        }
        //BUG: Don't return Username field for portal users
        List<User> users = [
            SELECT FirstName, Username, Email
            FROM User
            WHERE Username IN :names OR Email IN :names
        ];
        System.debug('usersAvailable:' + users);
        if (users != null && users.size() == 1) {
            return email + '01';
        } else if (users != null && users.size() == 2) {
            return email + '02';
        } else {
            Set<String> usedNames = new Set<String>();
            for (User user : users)
                usedNames.add(user.Username);
            for (String userName : names) {
                if (!usedNames.contains(userName))
                    return userName;
            }
        }
        return null;
    }

    private static String getAvailableUserNameBulk(String email) {
        List<String> names = new List<String>();
        names.add(email);
        for (Integer i = 1; i < 100; i++) {
            String numberStr = (100 + i) + '';
            numberStr = numberStr.right(2);
            names.add(email + '.' + numberStr);
        }
        //BUG: Don't return Username field for portal users
        List<User> users = [
            SELECT FirstName, Username, Email
            FROM User
            WHERE Username IN :names OR Email IN :names
        ];
        System.debug('usersAvailable:' + users);

        Set<String> usedNames = new Set<String>();
        for (User user : users)
            usedNames.add(user.Username);

        string email1 = email + '01';
        string email2 = email + '02';
        if (
            users != null &&
            users.size() == 1 &&
            !strusrName.contains(email1) &&
            !usedNames.contains(email1)
        ) {
            return email + '01';
        } else if (
            users != null &&
            users.size() == 2 &&
            !strusrName.contains(email2) &&
            !usedNames.contains(email2)
        ) {
            return email + '02';
        } else {
            for (String userName : names) {
                if (!usedNames.contains(userName) && !strusrName.contains(userName))
                    return userName;
            }
        }
        return null;
    }

    public static Boolean isUserInCommunity(Id contactId) {
        return ![
                SELECT Id
                FROM User
                WHERE ContactId = :contactId AND Profile.Name = :COMMUNITY_USER_PROFILE_NAME
            ]
            .isEmpty();
    }

    public static void setUserToCommunity(User user) {
        user.IsActive = true;
        user.ProfileId = COMMUNITY_USER_PROFILE_ID;

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.emailHeader.triggerUserEmail = true;
        dlo.emailHeader.triggerAutoResponseEmail = true;
        user.setOptions(dlo);

        update user;
    }

    public static void setUserToCommunity(Id contactId) {
        User user = [SELECT Id FROM User WHERE ContactId = :contactId];
        setUserToCommunity(user);
    }

    public static String getContactUserMode(String contactId) {
        List<Contact> contact = [SELECT userCommunityMode__c FROM Contact WHERE Id = :contactId];
        if (!contact.isEmpty())
            return contact.get(0).userCommunityMode__c;

        return null;
    }

    public static Id getCommunityId(String name) {
        String nameFilter = '';
        if (name != null)
            nameFilter = ' WHERE Name = \'' + name + '\' ';
        return Database.query('SELECT Id FROM Network' + nameFilter).get(0).Id;
    }

    public static Map<String, Id> getCommunityIdsMap() {
        List<Network> networks = [SELECT Id, Name FROM Network];
        Map<String, Id> communityMap = new Map<String, Id>();
        for (Network net : networks)
            communityMap.put(net.Name, net.Id);

        return communityMap;
    }

    public static Boolean isNewSession() {
        Contact userContact = getUserContact();
        Boolean isNewSession = UserInfo.getSessionId() != userContact.Last_Session_Id__c;
        if (isNewSession) {
            userContact.Last_Session_Id__c = UserInfo.getSessionId();
            update userContact;
        }
        return isNewSession;
    }

    public static String getCommunityURLFromTemplateName(String templateName) {
        String communityName = '';
        Map<String, CommunityTemplate> allCommunityTemplates = CommunityTemplateService.getTemplatesMap();
        for (CommunityTemplate currentTemplate : allCommunityTemplates.values()) {
            if (currentTemplate.templateName == templateName) {
                communityName = CommunityTemplateService.getCommunityURL(
                    currentTemplate.communityName
                );
            }
        }

        return communityName;
    }

    public class CreateParticipantUsersAsync implements Queueable {
        Set<Id> participantContactIds;
        Map<Id, Id> contactIdsMap = new Map<Id, Id>();
        Set<Id> peIds;

        public CreateParticipantUsersAsync(
            Map<Id, Id> contactIdsMap,
            Set<Id> participantContactIds,
            Set<Id> peIds
        ) {
            this.contactIdsMap = contactIdsMap;
            this.participantContactIds = participantContactIds;
            this.peIds= peIds;
        }

        public void execute(QueueableContext context) {
            try {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(contactIdsMap);

                if (participantContactIds != null && !participantContactIds.isEmpty()) {
                    Map<Id, List<Id>> delegatesByParticipant = PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
                        new List<Id>(peIds), true);
                    Set<Id> allContactIds = new Set<Id>(participantContactIds);
                    for (Id partKey : delegatesByParticipant.keySet()) {
                        for (Id delConId : delegatesByParticipant.get(partKey)) {
                            allContactIds.add(delConId);
                        }
                    }
                    PatientDelegateService.updatePermissionSets(allContactIds);
                }
            } catch (Exception ex) {
                resetInvitationFlag(contactIdsMap);
            }
        }
    }

    public static User createCCUser(Contact cont, String locale, String language, String timeZone) {
        if (locale == null)
            locale = 'en_US';
        if (language == null) {
            if (cont.Language__c == null) {
                language = 'en_US';
            } else {
                language = cont.Language__c;
            }
        }
        if (timeZone == null)
            timeZone = 'America/Los_Angeles';
        String newUserName = getAvailableUserName(cont.Email);
        User newUser = new User(
            ProfileId = CC_COMMUNITY_USER_PROFILE_ID,
            Username = newUserName,
            Email = cont.Email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = locale,
            LanguageLocaleKey = language,
            TimeZoneSidKey = timeZone,
            ContactId = cont.Id,
            LastName = cont.LastName,
            FirstName = cont.FirstName,
            Alias = 'test', //todo
            IsActive = true
        );

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;
        newUser.setOptions(dlo);
        return newUser;
    }

    public static void resetInvitationFlag(Map<Id, Id> contactIdsMap) {
        List<Participant_Enrollment__c> perList = [
            SELECT Id, Invited_To_PP_Date__c, Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN :contactIdsMap.keyset()
        ];
        for (Participant_Enrollment__c per : perList) {
            if (per.Invited_To_PP_Date__c != null) {
                per.Invited_To_PP_Date__c = null;
            }
        }
        update perList;
    }
}
