/**
 * Created by Leonid Bartenev
 */

public without sharing class UserContext {
    public class UserContextException extends Exception {
    }

    private static final String DUMMY_COMMUNITY_CONTACT_ID_DEV_NAME = 'DummyCommunityContactId';

    private static Contact userContact;
    private static User user;
    private static CommunityMode userMode;
    private static List<CommunityMode> allUserModes;
    private static Boolean isDummy = false;
    private static CommunityMode dummyMode;
    private static String currentCommunityName;

    public static Contact getUserContact() {
        if (userContact == null)
            setUser(UserInfo.getUserId());
        return userContact;
    }

    public static Id getUserContactId() {
        if (getUserContact() != null)
            return getUserContact().Id;
        return null;
    }

    public static User getUser() {
        if (user == null)
            setUser(UserInfo.getUserId());
        return user;
    }

    public static Id getUserId() {
        if (getUser() != null)
            return getUser().Id;
        return null;
    }

    public static void setDummyContact(Id contactId) {
        setContact(contactId);
    }

    public static void setDefaultDummyContact(Id contactId) {
        SettingStoreService.saveOrgDefault(
            DUMMY_COMMUNITY_CONTACT_ID_DEV_NAME,
            contactId,
            String.class
        );
    }

    public static void clearDefaultDummyContact() {
        SettingStoreService.deleteSettingOrgDefault(DUMMY_COMMUNITY_CONTACT_ID_DEV_NAME);
    }

    public static Boolean isDummyContact() {
        getUserContact();
        return isDummy;
    }

    public static void setDummyUser(Id userId) {
        setUser(userId);
    }

    public static CommunityMode getCurrentUserMode() {
        if (isDummyContact())
            return getDummyCommunityMode();

        if (userMode == null) {
            allUserModes = CommunityModeService.getUserCommunityModes(getUserContact().Id);
            userMode = CommunityModeService.getCurrentCommunityMode(getUserContact(), allUserModes);
        }
        return userMode;
    }

    public static CommunityMode getDummyCommunityMode() {
        if (dummyMode == null)
            dummyMode = new CommunityMode(CommunityService.USER_MODE_PI, Label.CTL_L_PI_MODE, null);
        return dummyMode;
    }

    public static List<CommunityMode> getAllUserModes() {
        if (allUserModes == null) {
            allUserModes = CommunityModeService.getUserCommunityModes(getUserContact().Id);
            userMode = CommunityModeService.getCurrentCommunityMode(getUserContact(), allUserModes);
        }
        return allUserModes;
    }

    public static Boolean isParticipant() {
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_PARTICIPANT;
    }

    public static Boolean isHCP() {
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_HCP;
    }

    public static Boolean isPI() {
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_PI;
    }

    //Added by Akanksha
    public static Boolean isCC() {
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_CC;
    }
    //

    public static String getTemplateProperty(String propertyName) {
        return getCurrentUserMode().template.properties.get(propertyName);
    }

    public static CommunityTemplate getCurrentCommunityTemplate() {
        return CommunityTemplateService.getTemplateByCommunityName(getCurrentCommunityName());
    }

    public static String getCurrentCommunityName() {
        if (currentCommunityName == null) {
            Site[] sites = [SELECT Id, MasterLabel FROM Site WHERE Name = :Site.getName()];
            if (sites.size() > 0)
                currentCommunityName = sites[0].MasterLabel;
        }
        if (currentCommunityName == 'IQVIA RH' || currentCommunityName == 'IQVIA ReferralHub')
            currentCommunityName = 'IQVIA Referral Hub';
        return currentCommunityName;
    }

    private static void setContact(Id contactId) {
        userContact = ContactService.getContact(contactId);
        List<User> users = [
            SELECT
                Id,
                Username,
                FirstName,
                LastName,
                ContactId,
                LanguageLocaleKey,
                TimeZoneSidKey,
                LocaleSidKey,
                FullPhotoUrl
            FROM User
            WHERE ContactId = :contactId
        ];
        if (users.size() > 0) {
            user = users[0];
        }
    }

    private static void setUser(Id userId) {
        user = [SELECT Id, ContactId, FullPhotoUrl FROM User WHERE Id = :userId];
        if (user == null || user.ContactId == null) {
            isDummy = true;
        } else {
            setContact(user.ContactId);
        }
    }
}