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
    
    public static User getUser(){
        if(user == null) setUser(UserInfo.getUserId());
        return user;
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
    
    private static void setContact(Id contactId) {
        userContact = ContactService.getContact(contactId);
        List<User> users = [
                SELECT Id,
                        FirstName,
                        LastName,
                        ContactId
                FROM User
                WHERE ContactId =: contactId
        ];
        if(users.size() > 0){
            user = users[0];
        }
    }
    
    private static void setUser(Id userId){
        user = [SELECT Id, ContactId FROM User WHERE Id =: userId];
        setContact(user.ContactId);
    }
}