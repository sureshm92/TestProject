/**
 * Created by Leonid Bartenev
 */

public class HomePageParticipantRemote {

    @AuraEnabled
    public static String getInitData() {
        try {
            User user = [SELECT LastLoginDate, Contact.Next_Notify_Date__c, Contact.UserCommunityIsDelegate__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if (user.LastLoginDate != null) {
                if (user.Contact.Next_Notify_Date__c != Date.today()) {
                    ContactService.updateNextNotifyDate(
                            user.ContactId,
                            user.LastLoginDate,
                            user.Contact.UserCommunityIsDelegate__c);
                }
            }

            return JSON.serialize(ParticipantService.getInstance().getState());
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}