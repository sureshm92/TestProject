/**
 * Created by D.Yasinskyi on 21.02.2018
 */
public without sharing class CommunityService {

    public static String COMMUNITY_USER_PROFILE_NAME = 'IQVIA Customer Community Plus Login User';
    public static Id COMMUNITY_USER_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_USER_PROFILE_NAME].Id;

    public static String COMMUNITY_PARTICIPANT_ACCOUNT_NAME = 'Participant';
    public static String COMMUNITY_DELEGATE_ACCOUNT_NAME = 'Delegate';

    //community email process
    public static String COMMUNITY_ET_HCP = 'RP1_New_Study_Email'; //email template
    public static String COMMUNITY_ET_PI = 'PI1_New_Study_Email'; //email template
    public static String COMMUNITY_ET_PARTICIPANT = 'Patient1_New_Study'; //email template
    public static String COMMUNITY_ET_DELEGATE = 'Delegate_New_Email'; //email template
    public static String COMMUNITY_ET_SHARE_STUDY = 'Share_Study_Template'; //email template

    // org wide email address
    public static String COMMUNITY_ORG_WIDE_ADDRESS_NAME = 'IQVIA Referral Hub';

    // case auto assignment rule
    public static String COMMUNITY_CASE_AR_NAME = 'HelpCase';

    //on Contact.userCommunityMode__c
    public static final String USER_MODE_HCP = 'HCP';
    public static final String USER_MODE_PI = 'PI';
    public static final String USER_MODE_PARTICIPANT = 'Participant';
    public static final String USER_MODE_DELEGATE = 'Delegate';

	//Exception messages
	private static String ERROR_MISSING_CONTACT_ON_USER = 'User Contact can not be NULL';
	private static String ERROR_MISSING_PARTICIPANT_ON_CONTACT = 'Contact does not have related Participant';


    //hold contact instance:
    private static Contact userContact;

    public static Contact getUserContact() {
        if (userContact == null) {
            User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if(currentUser.ContactId == null) throw new CommunityServiceException(CommunityService.ERROR_MISSING_CONTACT_ON_USER);
            userContact = getContactById(currentUser.ContactId);
        }
        return userContact;
    }

    //TODO for remove:
    public static String getAccessRights(String userMode){
        return null;
    }

    //for debug under internal user
    public static void setDummyUserContact(Id contactId){
        userContact = getContactById(contactId);
    }

    public static String getParticipantId() {
        User currentUser;
        if (userContact == null) {
            currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        }
        if(currentUser.ContactId == null) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_CONTACT_ON_USER);
        }

        Contact contact  = [SELECT Id, (SELECT Id FROM Participants__r) FROM Contact WHERE Id = :currentUser.ContactId];
        if(contact.Participants__r.size() == 0) {
            throw new CommunityServiceException(CommunityService.ERROR_MISSING_PARTICIPANT_ON_CONTACT);
        } else {
            return contact.Participants__r[0].Id;
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
                SELECT Id, Name, FirstName, LastName, ContactId, Email
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

    public static void createPortalUsers(Set<Id> contactIds){
        List<Contact> contacts = getContacts(contactIds);
        List<User> newPortalUsers = new List<User>();
        for (Contact cont : contacts) newPortalUsers.add(createUser(cont, null, null, null));
        insert newPortalUsers;
    }

    //Create participant users, fill time zone, locale and language from HCP contact
    public static void createParticipantUsers(Map<Id, Id> contactIdsMap) {
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
            if(cont.Language__c != null) language = cont.Language__c;
            newPortalUsers.add(createUser(cont, locale, language, timeZone));
        }
        insert newPortalUsers;
        System.debug('Portal users successfully created = ' + newPortalUsers.size());
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

    public static List<Contact> getContacts(Set<Id> contactIds) {
        return [
                SELECT Id, Email, FirstName, LastName, Name, Language__c
                FROM Contact
                WHERE Id = :contactIds
        ];
    }

    private static Contact getContactById(Id contactId) {
        return [
                SELECT Id,
                        primaryContact__c,
                        userCommunityMode__c,
                        userCommunytyType__c,
                        HCP_DelegateAccessLevel__c,
                        PI_DelegateAccessLevel__c,
                        userCommunity_ShowTour__c,
                        Last_Session_Id__c,
                        MailingLatitude,
                        MailingLongitude
                FROM Contact
                WHERE Id = :contactId
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

        List<User> users = [SELECT Username FROM User WHERE Username IN: names];
        Set<String> usedNames = new Set<String>();
        for(User user : users) usedNames.add(user.Username);
        for(String userName : names){
            if(!usedNames.contains(userName)) return userName;
        }
        return null;
    }

}