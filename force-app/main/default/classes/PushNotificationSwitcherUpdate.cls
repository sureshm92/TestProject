public without sharing class PushNotificationSwitcherUpdate {
    @AuraEnabled
    public static void updateCurrentContact(String currentPE,String userCommunityDelegateId){
        Contact currentContact = CommunityService.getUserContact();
        //currentContact.Current_Participant_Enrollment__c = currentPE;
        currentContact.userCommunityDelegateId__c = userCommunityDelegateId;
        update currentContact;
        //System.debug('currentContact id : '+currentContact.Id);
    }
}