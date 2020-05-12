/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {

    @AuraEnabled
    public static String getInitData() {
        try {
            List<User> users = [
                    SELECT
                            ContactId,
                            Contact.Next_Notify_Date__c,
                            LastLoginDate
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    AND LastLoginDate != NULL
            ];

            if (!users.isEmpty()) {
                User user = users.get(0);
                if (user.Contact.Next_Notify_Date__c != Date.today()) {
                    ContactService.updateNextNotifyDate(
                            user.ContactId,
                            user.LastLoginDate);
                }
            }

            return JSON.serialize(ParticipantService.getInstance().getState());
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}