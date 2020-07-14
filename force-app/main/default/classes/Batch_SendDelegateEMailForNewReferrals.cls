public class Batch_SendDelegateEMailForNewReferrals extends Batch_ScheduledAbstract {
    private List<User> finalPIs = new List<User>();
    private List<Id> finalDelegateIds = new List<Id>();
    DateTime lastbatchstart;
    public Batch_SendDelegateEMailForNewReferrals(DateTime input_lastbatchstart){
        lastbatchstart = input_lastbatchstart;
    }
    public Batch_SendDelegateEMailForNewReferrals(){
        
    }
    Map<String,List<User>> timezoneUsers = new Map<String,List<User>>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,Site_Contact__c
            FROM Site_Staff__c
            WHERE Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
            AND Study_Site__c IN(
                SELECT Study_Site__c     
                FROM Participant_Enrollment__c
                WHERE  Participant_Status__c = 'Received' 
            )
        ]);
    }
    public void execute(Database.BatchableContext bc, List<Site_Staff__c> siteStaff) {
        Map<String,Batch_Notification__c> notifications = new Map<String,Batch_Notification__c>();
        List<Id> contactIds = new List<Id>();
        // List<PendingReferral__e> pendingReferrals = new List<PendingReferral__e>();        
        List<User> qualifiedUsers = new List<User>();
        List<Id> validContacts = new List<Id>();
        for(Site_Staff__c ss : siteStaff){
            contactIds.add(ss.Site_Contact__c);
        }
        
        List<User> users =[SELECT Id,ContactId,timezonesidkey,Time_To_Send_Mail__c,TimeOfRun__c FROM User WHERE ContactId IN:contactIds];
      
        for(User u: users){
            Boolean isQualified = false;
            DateTime timeToSendMail;
            Timezone tz = Timezone.getTimeZone(u.timezonesidkey);
            Integer offset = tz.getOffset(lastbatchstart);
            Datetime userlocaltime = lastbatchstart.addSeconds(offset/1000);  
            Integer hours = 0;
            Integer minutes = 0;
            system.debug('uid'+u.Id);
            system.debug('lastbatchstart'+lastbatchstart);
            system.debug('userlocaltime'+userlocaltime);
            if(((userlocaltime.hourgmt() == 7 && userlocaltime.minutegmt()<45)||userlocaltime.hourgmt()==6) 
               && ((userlocaltime.hourgmt()+1 == 7 && userlocaltime.minutegmt()>45)||userlocaltime.hourgmt()+1 == 8) 
               && u.TimeOfRun__c != 'AM'){//  && !finalDelegateIds.contains(u.Id)){// && validContacts.contains(u.ContactId)){
                //finalPIs.add(u);   
                
                u.TimeOfRun__c = 'AM';
                DateTime currentTime = DateTime.now();
                offset = tz.getOffset(currentTime);
                DateTime currentLocalTime = currentTime.addSeconds(offset/1000);                
                if((currentLocalTime.hourgmt() == 7 && currentLocalTime.minutegmt()<40)|| currentLocalTime.hourgmt()<7){
                    hours = 7-currentLocalTime.hourgmt();
                    if(hours == 0){
                        minutes = 45 - currentLocalTime.minutegmt();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }else{
                        minutes = 45 + 60 - currentLocalTime.minutegmt();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }
                }else{
                    timeToSendMail = currentTime.addMinutes(2);
                }
                   system.debug('timeToSendMail'+timeToSendMail);
                u.Time_To_Send_Mail__c = timeToSendMail;
                isQualified = true;
                qualifiedUsers.add(u);
                finalDelegateIds.add(u.Id);
            }else if(((userlocaltime.hourgmt() == 12 && userlocaltime.minute()<45)||userlocaltime.hourgmt()==11) 
                     && ((userlocaltime.hourgmt()+1 == 12 && userlocaltime.minute()>45)||userlocaltime.hourgmt()+1 == 13) 
                     && u.TimeOfRun__c != 'PM'){//  && !finalDelegateIds.contains(u.Id)){// && validContacts.contains(u.ContactId)){
                //finalPIs.add(u);
                
                u.TimeOfRun__c = 'PM';
                DateTime currentTime = DateTime.now();
                offset = tz.getOffset(currentTime);
                DateTime currentLocalTime = currentTime.addSeconds(offset/1000);                   
                if((currentLocalTime.hourgmt() == 12 && currentLocalTime.minute()<40)|| currentLocalTime.hourgmt()<12){
                    hours = 12-currentLocalTime.hourgmt();
                    if(hours == 0){
                        minutes = 45 - currentLocalTime.minute();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }else{
                        minutes = 45 + 60 - currentLocalTime.minute();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }
                }else{
                    timeToSendMail = currentTime.addMinutes(2);
                }
                u.Time_To_Send_Mail__c = timeToSendMail;
                isQualified = true;
                qualifiedUsers.add(u);
                finalDelegateIds.add(u.Id);
            }
            if(isQualified){
                if(notifications.containsKey(u.timezonesidkey)){
                    notifications.get(u.timezonesidkey).Recipient_Ids__c = notifications.get(u.timezonesidkey).Recipient_Ids__c+';'+u.ContactId;
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
        if (notifications.values().size() > 0)
            insert notifications.values();
        
    }
    
    
    public override Type getType() {
        return Batch_SendDelegateEMailForNewReferrals.class;
    }
}