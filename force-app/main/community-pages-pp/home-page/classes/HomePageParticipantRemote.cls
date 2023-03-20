/**
 * Created by Leonid Bartenev
 */

public without sharing class HomePageParticipantRemote {

    private static void initialUpdate() {
            List<User> users = [
                SELECT ContactId, Contact.Next_Notify_Date__c, LastLoginDate
                FROM User
                WHERE Id = :UserInfo.getUserId() AND LastLoginDate != NULL
            ];

            if (!users.isEmpty()) {
                User user = users.get(0);
                if (user.Contact.Next_Notify_Date__c != Date.today()) {
                    ContactService.updateNextNotifyDate(user.ContactId, user.LastLoginDate);
                }
            }
            ContactService.updateVisitedCommunity(
                UserContext.getUserContact(),
                UserContext.getCurrentCommunityTemplate()
            );
    }

    class peStateAndCount{
        @AuraEnabled
        public ParticipantService.ParticipantState pState;
        @AuraEnabled
        public Integer pvCount;
        @AuraEnabled
        public Boolean televisitVendorAvailable;
    }

    
    @AuraEnabled(cacheable=false)
    public static String getInitData() {
        try{
            initialUpdate();
            return JSON.serialize(ParticipantService.getInstance().getState());
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String getInitDataAndCount() {
        try{
            initialUpdate();
            peStateAndCount peSAndC = new peStateAndCount();
            peSAndC.pState = ParticipantService.getInstance().getState();
            peSAndC.pvCount = 0;
            if(peSAndC.pState !=null && peSAndC.pState.pe!=null && peSAndC.pState.pe.Id!=null){
                Integer count = 0;
                Id peId = peSAndC.pState.pe.Id;
                String countQuery = 'SELECT count() FROM Patient_Visit__c WHERE Participant_Enrollment__c =:peId';
                count = Database.countQuery(countQuery);
                peSAndC.pvCount = count;
                
                Participant_Enrollment__c pe = [SELECT Id,Study_Site__c FROM Participant_Enrollment__c WHERE Id =:peId limit 1];
                List<TelevisitVendorSettings__c> tvs = new List<TelevisitVendorSettings__c>();
                tvs = [SELECT Id,isEnable__c from TelevisitVendorSettings__c where Study_Site__c =:pe.Study_Site__c order by lastmodifieddate desc limit 1];
                if(tvs.size() > 0)
                    peSAndC.televisitVendorAvailable = tvs[0].isEnable__c;
                
            }
            return JSON.serialize(peSAndC);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Boolean getIsRTL() {
        try {
            return (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}