/**
 * Created by Leonid Bartenev
 */

public without sharing class UserContext {
    
    private static Contact userContact;
    private static User user;
    private static CommunityMode userMode;
    private static List<CommunityMode> allUserModes;
    
    public static Contact getUserContact(){
        if(userContact == null) setUser(UserInfo.getUserId());
        return userContact;
    }
    
    public static Id getUserContactId(){
        if(getUserContact() != null) return getUserContact().Id;
        return null;
    }
    
    public static User getUser(){
        if(user == null) setUser(UserInfo.getUserId());
        return user;
    }
    
    public static Id getUserId(){
        if(getUser() != null) return getUser().Id;
        return null;
    }
    
    public static void setDummyUserContact(Id userContactId){
        setContact(userContactId);
    }
    
    public static void setDummyUser(Id userId){
        setUser(userId);
    }
    
    public static CommunityMode getCurrentUserMode(){
        if(userMode == null){
            allUserModes = CommunityModeService.getUserCommunityModes(getUserContact().Id);
            userMode = CommunityModeService.getCurrentCommunityMode(getUserContact(), allUserModes);
        }
        return userMode;
    }
    
    public static List<CommunityMode> getAllUserModes(){
        if(allUserModes == null){
            allUserModes = CommunityModeService.getUserCommunityModes(getUserContact().Id);
            userMode = CommunityModeService.getCurrentCommunityMode(getUserContact(), allUserModes);
        }
        return allUserModes;
    }
    
    public static Boolean isParticipant(){
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_PARTICIPANT;
    }
    
    public static Boolean isHCP(){
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_HCP;
    }
    
    public static Boolean isPI(){
        return getUserContact().userCommunityMode__c == CommunityModeService.USER_MODE_PI;
    }
    
    public static String getTemplateProperty(String propertyName){
        return getCurrentUserMode().template.properties.get(propertyName);
    }
    
    private static void setContact(Id contactId) {
        userContact = ContactService.getContact(contactId);
        List<User> users = [
                SELECT Id,
                        Username,
                        FirstName,
                        LastName,
                        ContactId,
                        LanguageLocaleKey,
                        TimeZoneSidKey,
                        LocaleSidKey,
                        FullPhotoUrl
                FROM User
                WHERE ContactId =: contactId
        ];
        if(users.size() > 0){
            user = users[0];
        }
    }
    
    private static void setUser(Id userId){
        user = [SELECT Id, ContactId FROM User WHERE Id =: userId];
        if(user.ContactId == null) {
            setContact((Id) SettingStoreService.getOrgDefault('DummyCommunityContactId'));
        } else {
            setContact(user.ContactId);
        }
    }
}