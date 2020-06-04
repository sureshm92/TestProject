/**
* Created by D.Yasinskyi on 04.05.2018
*/
public without sharing class RRProfileController {

@AuraEnabled
public static String getUser() {

    List<User> currentUser = [
            SELECT Id, Contact.FirstName, Contact.LastName, SmallPhotoUrl
            FROM User
            WHERE Id = : UserInfo.getUserId()
    ];
    ContactService.applyRelevantNames(currentUser);
    
    UserWrapper result = new UserWrapper();
    result.user = currentUser[0];
    List<Participant__c> participantForCurrentUser = [
            SELECT  Id,
                    First_Name__c,
                    Last_Name__c
            FROM Participant__c
            WHERE Contact__c = :result.user.ContactId
    ];
    if(!participantForCurrentUser.isEmpty()){
        result.participantName = participantForCurrentUser[0].First_Name__c + ' ' + participantForCurrentUser[0].Last_Name__c;
    }

    result.isDelegate = ParticipantContext.isCurrentDelegate();
    return JSON.serialize(result);
}
//PEH-2060: Login/Logout experience for PP users
@AuraEnabled
public static String getLogoutURL() {
    List<LoginHistory> userLoginHistory = [SELECT Id, UserId, LoginTime, LoginUrl 
                                            FROM LoginHistory 
                                            WHERE UserId = : UserInfo.getUserId()
                                            //AND Status =: 'Success'
                                            ORDER BY LoginTime DESC LIMIT 1];
    //return the site base URL when there is no login history available
    //else return the login url from current login
    return userLoginHistory.isEmpty() ? Site.getBaseUrl() : 'https://' + userLoginHistory.get(0).LoginUrl.substringAfter('https://').substringBefore('/').trim();
}
public class UserWrapper{
    public User user;
    public String participantName;
    public Boolean isDelegate;
}
}