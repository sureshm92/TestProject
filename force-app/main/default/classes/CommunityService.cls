/**
 * Created by D.Yasinskyi on 21.02.2018
 */
public without sharing class CommunityService {

    public static final String IQVIA_NETWORK_NAME = 'IQVIA Referral Hub';
    public static final String GSK_NETWORK_NAME = 'GSK Community';

    public static final String COMMUNITY_USER_PROFILE_NAME = 'IQVIA Customer Community Plus Login User';
    public static final Id COMMUNITY_USER_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_USER_PROFILE_NAME].Id;
    public static final String SPNL_USER_PROFILE_NAME = 'IQVIA SPNL';
    public static final Id SPNL_USER_PROFILE_ID = [SELECT Id FROM Profile WHERE Name =: SPNL_USER_PROFILE_NAME].Id;
    public static final Id SPNL_ROLE = [SELECT Id FROM UserRole WHERE Name='SPNL'].Id;

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

    //Exception messages
    public static String ERROR_MISSING_STUDY = 'Unexpected error occurred. Contact administrator.';
    private static String ERROR_MISSING_CONTACT_ON_USER = 'User Contact can not be NULL';
    private static String ERROR_MISSING_PARTICIPANT_ON_CONTACT = 'Contact does not have related Participant';


    //hold contact instance:
    private static Contact userContact;
    private static Id userId = UserInfo.getUserId();
    
    private static CommunityService instance;
    
    public static CommunityService getInstance(){
        if(instance == null) instance = new CommunityService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (CommunityService) Test.createStub(CommunityService.class, stubProvider);
    }
    
    public Id getCurrentContactId(){
        return UserContext.getUserContactId();
    }

    public String getUserAccessLevel(String delegateId){
        String accessLevel;
        try {
            Id currentContactId = CommunityService.getInstance().getCurrentContactId();
            accessLevel = [ SELECT Delegate_Access_Level__c
                            FROM RP_Delegate_Relationship__c
                            WHERE Delegate__c = :currentContactId AND Referring_Provider__c = :delegateId LIMIT 1].Delegate_Access_Level__c;
        } catch (Exception ex){
            accessLevel=null;
        }
        return accessLevel;
    }

    //Old static logic: ------------------------------------------------------------------------------------------------
    
    public static Contact getUserContact() {
        return UserContext.getUserContact();
    }
    
    public static Id getUserId(){
        return UserContext.getUserId();
    }

    //Todo remove this:
    public String getParticipantId() {
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(currentUser.ContactId == null) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_CONTACT_ON_USER);
        }
        Contact contact  = [SELECT Id, (SELECT Id FROM Participants__r) FROM Contact WHERE Id = :currentUser.ContactId];
        ParticipantService.ParticipantState state = ParticipantService.getParticipantState();
        if(contact.Participants__r.size() != 0 && !state.isDelegate) {
            return contact.Participants__r[0].Id;
        } else if (state.isDelegate) {
            return state.participant.Id;
        } else {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_PARTICIPANT_ON_CONTACT);
        }
    }

    public static List<Contact> getContactsByUserContactIds(Set<Id> userContactIds){
        return [
                SELECT Id, userCommunityMode__c, userCommunytyType__c
                FROM Contact
                WHERE Id IN :userContactIds
        ];
    }
    
    public static List<User> getCommunityUsersByContactIds(Set<Id> contactIds) {
        return [
                SELECT Id, Name, FirstName, LastName, ContactId, Email, IsActive,
                (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User
                WHERE
                        //Profile.Name = :COMMUNITY_USER_PROFILE_NAME AND
                        ContactId IN :contactIds
                //AND email != null
        ];
    }

    public static Boolean isUserModeValid(String userMode) {
        Contact userContact = getUserContact();
        if(userContact == null) return false;
        return userContact.userCommunytyType__c.contains(userMode);
    }

    //return converted status to display
    public static String getConvertedStatus(String fullStatus){
        return fullStatus.split(' \\(')[0];
    }

    public static Profile getCommunityProfile(){
        return [
                SELECT Id
                FROM Profile
                WHERE Name = :COMMUNITY_USER_PROFILE_NAME
        ];
    }

    public void createPortalUsers(Set<Id> contactIds){
        List<Contact> contacts = getContacts(contactIds);
        List<User> newPortalUsers = new List<User>();
        for (Contact cont : contacts) newPortalUsers.add(createUser(cont, null, null, null));
        insert newPortalUsers;
    }

    //Create participant users, fill time zone, locale and language from HCP contact
    public List<User> createParticipantUsers(Map<Id, Id> contactIdsMap) {
        System.debug('ParticipantContactId -> HCPContactId MAP: ' + contactIdsMap);
        List<Contact> contacts = getContacts(contactIdsMap.keySet());
        List<User> hcpUsers = [
                SELECT Id, ContactId, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey
                FROM User
                WHERE ContactId IN: contactIdsMap.values() AND LocaleSidKey != NULL
        ];
        Map<Id, User> hcpUsersMap = new Map<Id, User>();
        for(User hcp : hcpUsers) hcpUsersMap.put(hcp.ContactId, hcp);

        List<User> newPortalUsers = new List<User>();
        Set<String> usedNames = new Set<String>();
        for (Contact cont : contacts) {
            String timeZone;
            String locale;
            String language;
            User hcpUser = hcpUsersMap.get(contactIdsMap.get(cont.Id));
            if(hcpUser != null){
                timeZone = hcpUser.TimeZoneSidKey;
                locale = hcpUser.LocaleSidKey;
                language = hcpUser.LanguageLocaleKey;
            }
            if(!cont.Participants__r.isEmpty() && cont.Participants__r[0].Preferred_Language__c != null){
                cont.Language__c = cont.Participants__r[0].Preferred_Language__c;
            }
            if(cont.Language__c != null) language = cont.Language__c;
            if(cont.Email != null && cont.Email != ''){
                newPortalUsers.add(createUser(cont, locale, language, timeZone));
            }
        }
        System.debug('newPortalUsers' + newPortalUsers);
        insert newPortalUsers;
        System.debug('Portal users successfully created = ' + newPortalUsers.size());
        return newPortalUsers;
    }

    public void createParticipantUsersAsync(Map<Id, Id> contactIdsMap, Set<Id> participantContactIds) {
        System.enqueueJob(new CreateParticipantUsersAsync(contactIdsMap, participantContactIds));
    }

    public static User createUser(Contact cont, String locale, String language, String timeZone){
        if(locale == null) locale = 'en_US';
        if(language == null) {
            if(cont.Language__c == null){
                language = 'en_US';
            }else{
                language = cont.Language__c;
            }
        }
        if(timeZone == null) timeZone = 'America/Los_Angeles';
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
        Database.DMLOptions dlo=new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail =true;
        dlo.EmailHeader.triggerAutoResponseEmail=true;
        newUser.setOptions(dlo);
        return newUser;
    }

    @Future
    public static void deactivateUsers(List<Id> contactIds) {
        List<User> users = [
                SELECT Id, IsActive
                FROM User
                WHERE ContactId IN :contactIds
        ];
        for (User u : users) u.IsActive = false;
        update users;
    }

    public static List<Contact> getContacts(Set<Id> contactIds) {
        return [
                SELECT Id, Email, FirstName, LastName, Name, Language__c, Library_Primary_Language__c, Full_Name__c, Salutation, Suffix
                FROM Contact
                WHERE Id = :contactIds
                //ORDER BY Name
        ];
    }

    private static String getAvailableUserName(String email){
        List<String> names = new List<String>();
        names.add(email);
        for(Integer i = 1; i < 100; i++){
            String numberStr = (100 + i) + '';
            numberStr = numberStr.right(2);
            names.add(email + '.' + numberStr);
        }
        //BUG: Don't return Username field for portal users
        List<User> users = [SELECT FirstName, Username, Email FROM User WHERE Username IN : names OR Email IN :names];
        System.debug('usersAvailable:' + users);
        if(users != null && users.size() == 1){
            return email + '01';
        }else if(users != null && users.size() == 2){
            return email + '02';
        }else{
            Set<String> usedNames = new Set<String>();
            for(User user : users) usedNames.add(user.Username);
            for(String userName : names){
                if(!usedNames.contains(userName)) return userName;
            }
        }
        return null;
    }

    public static Boolean isUserInCommunity(Id contactId) {
        return ![SELECT Id
                    FROM User
                    WHERE ContactId =: contactId
                        AND Profile.Name =: COMMUNITY_USER_PROFILE_NAME
        ].isEmpty();
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
        User user = [
                SELECT Id
                FROM User
                WHERE ContactId = :contactId
        ];
        setUserToCommunity(user);
    }

    public static String getContactUserMode(String contactId) {
        List<Contact> contact = [
                SELECT userCommunityMode__c
                FROM Contact
                WHERE Id =: contactId
        ];
        if(!contact.isEmpty()) return contact.get(0).userCommunityMode__c;

        return null;
    }

    public static Id getCommunityId(String name) {
        String nameFilter = '';
        if(name != null) nameFilter = ' WHERE Name = \'' + name + '\' ';
        return Database.query('SELECT Id FROM Network' + nameFilter).get(0).Id;
    }

    public static Map<String, Id> getCommunityIdsMap() {
        List<Network> networks = [SELECT Id, Name FROM Network];
        Map<String, Id> communityMap = new Map<String, Id>();
        for(Network net : networks) communityMap.put(net.Name, net.Id);

        return communityMap;
    }

    public static Boolean isNewSession(){
        Contact userContact = getUserContact();
        Boolean isNewSession = UserInfo.getSessionId() != userContact.Last_Session_Id__c;
        if(isNewSession) {
            userContact.Last_Session_Id__c = UserInfo.getSessionId();
            update userContact;
        }
        return isNewSession;
    }

    public class CreateParticipantUsersAsync implements Queueable {
        Set<Id> participantContactIds;
        Map<Id, Id> contactIdsMap = new Map<Id, Id>();

        public CreateParticipantUsersAsync(Map<Id, Id> contactIdsMap, Set<Id> participantContactIds) {
            this.contactIdsMap = contactIdsMap;
            this.participantContactIds = participantContactIds;
        }

        public void execute(QueueableContext context) {
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(contactIdsMap);

            if (participantContactIds != null && !participantContactIds.isEmpty()) {
                Map<Id, List<Id>> delegatesByParticipant =
                        PatientDelegateService.getDelegateContactIdsByPAContactIs(new List<Id>(participantContactIds));
                Set<Id> allContactIds = new Set<Id>(participantContactIds);
                for(Id partKey : delegatesByParticipant.keySet()) {
                    for(Id delConId : delegatesByParticipant.get(partKey)) {
                        allContactIds.add(delConId);
                    }
                }
                PatientDelegateService.updatePermissionSets(allContactIds);
            }
        }

    }

}
