public class Batch_SendPIEmailForNewReferrals extends Batch_ScheduledAbstract {
    private List<User> finalPIs = new List<User>();
    Map<String, List<User>> timezoneUsers = new Map<String, List<User>>();
    DateTime timestarted;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!test.isRunningTest())
        	timestarted = DateTime.now();
        else{
            timestarted = DateTime.newInstance(2022,10,23,09,0,0);
        }
        system.debug('^' + UserInfo.getUserId());
        return Database.getQueryLocator(
            [
                SELECT Id, ContactId, timezonesidkey, Time_To_Send_Mail__c, TimeOfRun__c
                FROM User
                WHERE
                    ContactId IN (
                        SELECT PI_Contact__c
                        FROM Participant_Enrollment__c
                        WHERE
                            (Participant_Status__c = 'Received' OR 
                             (Participant_Status__c IN ('Contact Attempted','Pre-review Passed','Successfully Contacted','Successfully re-engaged')
                              AND High_Priority__c = true) OR Re_consent__c = true 
                            ) 
                            AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                            AND Study_Site__r.Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')
                    )
            ]
        );
    }
    public void execute(Database.BatchableContext bc, List<User> users) {
    
     List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
    Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'PI_Delegates_New_Referral'
        );
        Notification_Target__mdt nt = notificationType.Notification_Targets__r[0];
        Map<String, Batch_Notification__c> notifications = new Map<String, Batch_Notification__c>();
        List<User> qualifiedUsers = new List<User>();
        Map<Id, Id> ssByContactIdMap = new Map<Id, Id>();
        List<Id> contactIds = new List<Id>();
        List<Id> validContacts = new List<Id>();
        List<Study_Site__c> studySite = new List<Study_Site__c>();
        system.debug('usersLine36>>'+users);
        for (User usr : users) {
            contactIds.add(usr.ContactId);
        }
      NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(
            contactIds,
            contactIds
        );  
        studySite = [
            SELECT Id, Principal_Investigator__c
            FROM Study_Site__c
            WHERE
            Principal_Investigator__c IN :contactIds
            AND Suppress_Study_Site_PI_Emails__c = FALSE
            AND Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')
            ORDER BY CreatedDate
        ];
        for (Study_Site__c ssite : studySite) {
            if (!ssByContactIdMap.containsKey(ssite.Principal_Investigator__c)) {
                ssByContactIdMap.put(ssite.Principal_Investigator__c, ssite.Id);
            }
        }
        
        for (User u : users) {
            DateTime timeToSendMail;
            Timezone tz = Timezone.getTimeZone(u.timezonesidkey);
            Integer offset = tz.getOffset(timestarted);
            Datetime userlocaltime = timestarted.addSeconds(offset / 1000);
            Integer hours = 0;
            Integer minutes = 0;
            Boolean isQualified = false; 
            DateTime currentTime = DateTime.now();
            if (
                ((userlocaltime.hourgmt() == 7 && userlocaltime.minutegmt() <= 45) ||
                userlocaltime.hourgmt() == 6) &&
                ((userlocaltime.hourgmt() + 1 == 7 && userlocaltime.minutegmt() >= 45) ||
                userlocaltime.hourgmt() + 1 == 8) &&
                u.TimeOfRun__c != String.valueOf(timestarted).subStringBefore(' ')
            ) {
                //finalPIs.add(u);
                //u.TimeOfRun__c = 'AM';
                offset = tz.getOffset(currentTime);
                DateTime currentLocalTime = currentTime.addSeconds(offset / 1000);
                if (
                    (currentLocalTime.hourgmt() == 7 && currentLocalTime.minutegmt() < 40) ||
                    currentLocalTime.hourgmt() < 7
                ) {
                    hours = 7 - currentLocalTime.hourgmt();
                    if (hours == 0) {
                        minutes = 45 - currentLocalTime.minutegmt();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    } else {
                        minutes = 45 + 60 - currentLocalTime.minutegmt();
                        timeToSendMail = currentTime.addMinutes(minutes);
                    }
                } else {
                    timeToSendMail = currentTime.addMinutes(2);
                }
                isQualified = true;
                u.Time_To_Send_Mail__c = currentTime;
                u.TimeOfRun__c = String.valueOf(timestarted).subStringBefore(' ');
                qualifiedUsers.add(u);
            }
            if (isQualified && !ssByContactIdMap.isEmpty() && ssByContactIdMap.containsKey(u.ContactId)) {
                emailMessages.add(
                    EmailService.createEmail(
                        EmailService.getEmailTemplateId('PI_RP_New_Referral'),
                        u.ContactId,
                        ssByContactIdMap.get(u.ContactId),
                        availabilityService.getOrgWideEmail(
                            u.ContactId,
                            ssByContactIdMap.get(u.ContactId),
                            nt.Org_Wide_Email_Address__c
                        )
                    )
                );
            }
        }
        if (!Test.isRunningTest()) {
            update qualifiedUsers;
        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
        
    }

    public override Type getType() {
        return Batch_SendPIEmailForNewReferrals.class;
    }

    public override void finalAction() {
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