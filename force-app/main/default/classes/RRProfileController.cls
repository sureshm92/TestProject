/**
 * Created by D.Yasinskyi on 04.05.2018
 */
public without sharing class RRProfileController {

    @AuraEnabled
    public static String getUser() {

        List<User> currentUser = [
                SELECT Id
                        , Contact.Name
                , SmallPhotoUrl
                FROM User
                WHERE Id = : UserInfo.getUserId()
        ];
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

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static String getLogoutURL() {
        return Site.getBaseUrl();
    }
    public class UserWrapper{
        public User user;
        public String participantName;
    }
}