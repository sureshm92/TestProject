public without sharing class PushNotificationSwitcherUpdate {
    @AuraEnabled
    public static void updateCurrentContact(String notificationType,String whatId,String recipientId){
        Contact currentContact = CommunityService.getUserContact();
        List<String> resStdPushNotifications = new List<String>();
        resStdPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_ARTICLE);
        resStdPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_DOCUMENT);
        resStdPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_LINK);
        resStdPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_VIDEO);
        resStdPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_MULTIMEDIA);
        List<String> resPlatPushNotifications = new List<String>();
        resPlatPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_ARTICLE);
        resPlatPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_DOCUMENT);
        resPlatPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_LINK);
        resPlatPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_VIDEO);
        resPlatPushNotifications.add(NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_MULTIMEDIA);
        //Study level Notifications
        if(resStdPushNotifications.contains(notificationType)){
            List<Participant_Enrollment__c> peList = [SELECT Id,Participant_Status__c,Participant_Contact__c,Participant__r.Has_Studies_In_Progress__c FROM Participant_Enrollment__c WHERE Id =: whatId];
            if(!PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(peList.get(0).Participant_Status__c)){
                if(peList.get(0).Participant_Contact__c == recipientId){
                    currentContact.Current_Participant_Enrollment__c = (Id)whatId;
                    currentContact.userCommunityDelegateId__c = null;
                }else{
                    currentContact.Current_Participant_Enrollment__c = (Id)whatId;
                    currentContact.userCommunityDelegateId__c = peList.get(0).Participant_Contact__c;
                }
            }else if(PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(peList.get(0).Participant_Status__c) && !peList.get(0).Participant__r.Has_Studies_In_Progress__c){
                if(peList.get(0).Participant_Contact__c == recipientId){
                    currentContact.Current_Participant_Enrollment__c = null;
                    currentContact.userCommunityDelegateId__c = null;
                }else{
                    currentContact.Current_Participant_Enrollment__c = null;
                    currentContact.userCommunityDelegateId__c = peList.get(0).Participant_Contact__c;
                }
            }
        }else if(resPlatPushNotifications.contains(notificationType)){ 
            List<Participant__c> ptList = [SELECT Id,Has_Past_Studies__c,Has_Studies_In_Progress__c,Contact__c FROM Participant__c WHERE Id =: whatId];
            if(ptList.get(0).Contact__c == recipientId){
                if(!ptList.get(0).Has_Past_Studies__c && !ptList.get(0).Has_Studies_In_Progress__c){
                    //delegate self view
                    currentContact.Current_Participant_Enrollment__c = null;
                    currentContact.userCommunityDelegateId__c = null;
                }else if(ptList.get(0).Has_Studies_In_Progress__c){
                    //active participant
                    currentContact.Current_Participant_Enrollment__c = getActiveEnrollment(ptList.get(0).Contact__c).Id;
                    currentContact.userCommunityDelegateId__c = null;
                }else if(ptList.get(0).Has_Past_Studies__c && !ptList.get(0).Has_Studies_In_Progress__c){
                    //alumni
                    currentContact.Current_Participant_Enrollment__c = null;
                    currentContact.userCommunityDelegateId__c = null;
                }
            }else{
                if(ptList.get(0).Has_Studies_In_Progress__c){
                    //active participant
                    currentContact.Current_Participant_Enrollment__c = getActiveEnrollment(ptList.get(0).Contact__c).Id;
                    currentContact.userCommunityDelegateId__c = ptList.get(0).Contact__c;
                }else if(ptList.get(0).Has_Past_Studies__c && !ptList.get(0).Has_Studies_In_Progress__c){
                    //alumni
                    currentContact.Current_Participant_Enrollment__c = null;
                    currentContact.userCommunityDelegateId__c = ptList.get(0).Contact__c;
                }
            }
        }
        update currentContact;
        //Platform level Notifications        
    }
    public static Participant_Enrollment__c getActiveEnrollment(String contactId){ 
        List<Participant_Enrollment__c> activePeList = [select id,Participant_Status__c from Participant_Enrollment__c where Participant__r.Contact__c=:contactId AND Participant_Status__c NOT IN : PEStatusState.PE_STATUS_GROUP_ALUMNI AND Invited_To_PP_Date__c!=null LIMIT 1];
        return activePeList.get(0);
    }
}