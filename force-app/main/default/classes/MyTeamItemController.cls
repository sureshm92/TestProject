/**
 * Created by D.Yasinskyi on 04.05.2018
 */
public without sharing class MyTeamItemController {

    //TODO DEPRECATED CLASS!!!

//    @AuraEnabled
//    public static void changeDelegateAccessLevel(String delegateContactId, String newAccessLevel, String userMode) {
//
//        Contact delegate = getDelegate(delegateContactId);
//
//        if(userMode == CommunityService.USER_MODE_HCP){
//            delegate.HCP_DelegateAccessLevel__c = newAccessLevel;
//        } else if(userMode == CommunityService.USER_MODE_PI){
//            delegate.PI_DelegateAccessLevel__c = newAccessLevel;
//        } else {
//            throw new AuraHandledException('Incorrect User rights!');
//        }
//
//        try {
//            update delegate;
//        } catch (Exception e) {
//            throw new AuraHandledException('Can`t change delegate access level!' + e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }
//
//    @AuraEnabled
//    public static String removeDelegate(String delegateContactId, String userMode) {
//
//        Contact delegate = getDelegate(delegateContactId);
//        Boolean deleteDelegate = false;
//        String response = 'Delegate ' + delegate.FirstName + ' ' + delegate.LastName;
//
//        if(userMode == CommunityService.USER_MODE_PI){
//            delegate.PI_DelegateAccessLevel__c = null;
//            if(delegate.HCP_DelegateAccessLevel__c == null) deleteDelegate = true;
//        } else if(userMode == CommunityService.USER_MODE_HCP){
//            delegate.HCP_DelegateAccessLevel__c = null;
//            if(delegate.PI_DelegateAccessLevel__c == null) deleteDelegate = true;
//        } else {
//            throw new AuraHandledException('Can`t remove delegate!');
//        }
//
//        if(deleteDelegate){
//            delegate.primaryContact__c = null;
//            delegate.userCommunytyType__c = null;
//            delegate.userCommunityMode__c = null;
//            response += ' was successfully removed!';
//        } else {
//            response += ' access rights was successfully removed!';
//        }
//        try {
//            update delegate;
//            return response;
//        } catch (Exception e) {
//            throw new AuraHandledException('Can`t remove delegate!');
//        }
//    }
//
//    private static Contact getDelegate(String delegateContactId) {
//
//        List<Contact> delegate = [
//                SELECT Id
//                        , FirstName
//                        , LastName
//                        , primaryContact__c
//                        , HCP_DelegateAccessLevel__c
//                        , PI_DelegateAccessLevel__c
//                FROM Contact
//                WHERE Id = :delegateContactId
//                AND primaryContact__c IN (
//                        SELECT ContactId
//                        FROM User
//                        WHERE Id = :UserInfo.getUserId()
//                )
//        ];
//
//        if (delegate.isEmpty()) throw new AuraHandledException('No rights to remove delegate!');
//
//        return delegate[0];
//    }
}