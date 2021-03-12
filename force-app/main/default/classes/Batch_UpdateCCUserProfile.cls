global without sharing class Batch_UpdateCCUserProfile implements Database.Batchable<SObject> { 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id,ProfileId,Contact.userCommunityMode__c FROM User WHERE Contact.userCommunityMode__c = \'CC\' ';
        
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext bc, List<User> scope) {
        String CC_COMMUNITY_USER_PROFILE_NAME = 'IQVIA Call Center Login User';
        Id CC_COMMUNITY_USER_PROFILE_ID = [
            SELECT Id
            FROM Profile
            WHERE Name = :CC_COMMUNITY_USER_PROFILE_NAME
        ].Id;
        List<User> userList = New List<User> ();
        For(User u: scope){
            if(u.ProfileId != CC_COMMUNITY_USER_PROFILE_ID){
                u.ProfileId = CC_COMMUNITY_USER_PROFILE_ID;
                userList.add(u);
            }
        }
        update userList;
        
        if(!userList.isEmpty()){
            TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.class);
        }
    }
    global void finish(Database.BatchableContext bc) {
    }
    
}