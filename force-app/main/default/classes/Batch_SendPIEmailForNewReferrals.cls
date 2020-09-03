public class Batch_SendPIEmailForNewReferrals extends Batch_ScheduledAbstract {
    private List<User> finalPIs = new List<User>();
    Map<String,List<User>> timezoneUsers = new Map<String,List<User>>();
    DateTime timestarted;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        timestarted = DateTime.now();
        system.debug('^'+UserInfo.getUserId());
        return Database.getQueryLocator([
            SELECT Id,ContactId,timezonesidkey,Time_To_Send_Mail__c,TimeOfRun__c FROM User WHERE ContactId IN (
                SELECT PI_Contact__c     
                FROM Participant_Enrollment__c
                WHERE  Participant_Status__c = 'Received' AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = false
            )
        ]);
    }
    public void execute(Database.BatchableContext bc, List<User> users) {
        Map<String,Batch_Notification__c> notifications = new Map<String,Batch_Notification__c>();
        List<User> qualifiedUsers = new List<User>();
        List<Id> contactIds = new List<Id>();
        List<Id> validContacts = new List<Id>();
        for(User usr: users){
            contactIds.add(usr.ContactId);
        }

        for(User u: users){
            DateTime timeToSendMail;
            Timezone tz = Timezone.getTimeZone(u.timezonesidkey);
            Integer offset = tz.getOffset(timestarted);
            Datetime userlocaltime = timestarted.addSeconds(offset/1000); 
            Integer hours = 0;
            Integer minutes = 0;
            Boolean isQualified = false;
            system.debug('userlocaltime'+userlocaltime);
            
            if(((userlocaltime.hourgmt() == 7 && userlocaltime.minutegmt()<45)||userlocaltime.hourgmt()==6) && 
               ((userlocaltime.hourgmt()+1 == 7 && userlocaltime.minutegmt()>45)||userlocaltime.hourgmt()+1 == 8)  
               && u.TimeOfRun__c != String.valueOf(timestarted).subStringBefore(' ')) {
                //finalPIs.add(u);   
                //u.TimeOfRun__c = 'AM';
                DateTime currentTime = DateTime.now();
                offset = tz.getOffset(currentTime);
                DateTime currentLocalTime = currentTime.addSeconds(offset/1000);
                system.debug('currentLocalTime'+currentLocalTime);   
                if((currentLocalTime.hourgmt() == 7 && currentLocalTime.minutegmt()<40)|| currentLocalTime.hourgmt()<7){
                    hours = 7-currentLocalTime.hourgmt();
                    if(hours == 0){
                        minutes = 45 - currentLocalTime.minutegmt();
                        system.debug('currentTime'+currentTime);
                        system.debug('minutes'+minutes);
                        timeToSendMail = currentTime.addMinutes(minutes);
                        system.debug('timeToSendMail'+timeToSendMail);
                    }else{
                        minutes = 45 + 60 - currentLocalTime.minutegmt();
                        system.debug('hours'+hours);
                        system.debug('minutes'+minutes);
                        system.debug('currentTime'+currentTime);
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }
                }else{
                    system.debug('#currentTime'+currentTime);
                    timeToSendMail = currentTime.addMinutes(2);
                }
                isQualified = true;
                u.Time_To_Send_Mail__c = timeToSendMail;
                system.debug('u.Time_To_Send_Mail__c'+u.Time_To_Send_Mail__c);
                u.TimeOfRun__c = String.valueOf(timestarted).subStringBefore(' '); 
                qualifiedUsers.add(u);
            }
            system.debug('isQualified'+isQualified);
            if(isQualified){
                if(notifications.containsKey(u.timezonesidkey)){
                    notifications.get(u.timezonesidkey).Recipient_Ids__c = notifications.get(u.timezonesidkey).Recipient_Ids__c+ ';'+u.ContactId;
                }else{
                    Batch_Notification__c notification = new Batch_Notification__c();
                    notification.Recipient_Ids__c = u.ContactId;
                    notification.Time_Zone_Date__c = timeToSendMail;
                    notifications.put(u.TimeZoneSidKey,notification);
                }
            }
        }
        if(!Test.isRunningTest()){
            update qualifiedUsers;
        }    
        system.debug('notifications.values()'+notifications.values());
        if (notifications.values().size() > 0)
            insert notifications.values();
    }
    
    
    public override Type getType() {
        return Batch_SendPIEmailForNewReferrals.class;
    }
    
    public override void finalAction(){
        DataBase.executeBatch(new Batch_SendDelegateEMailForNewReferrals(timestarted), 100);
    }
    
        public override String getBatchDescription() {
        return 'This job sends Emails to PIs and Delegates to remind them about pending referrals';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}