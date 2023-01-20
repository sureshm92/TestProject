public class Batch_SendDelegateEMailForNewReferrals extends Batch_ScheduledAbstract {
    private List<User> finalPIs = new List<User>();
    private List<Id> finalDelegateIds = new List<Id>();
    DateTime lastbatchstart;
    public Batch_SendDelegateEMailForNewReferrals(DateTime input_lastbatchstart) {
        lastbatchstart = input_lastbatchstart;
    }
    public Batch_SendDelegateEMailForNewReferrals() {
    } 
    Map<String, List<User>> timezoneUsers = new Map<String, List<User>>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT Id, Site_Contact__c
                FROM Site_Staff__c
                WHERE
                    Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                	AND is_Invited__c = TRUE
                    AND Study_Site__c IN (
                        SELECT Study_Site__c
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
    public void execute(Database.BatchableContext bc, List<Site_Staff__c> siteStaff) {
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'PI_Delegates_New_Referral'
        );
        Notification_Target__mdt nt = notificationType.Notification_Targets__r[0];
        Map<String, Batch_Notification__c> notifications = new Map<String, Batch_Notification__c>();
        List<Id> contactIds = new List<Id>();
        Map<Id, Id> ssByContactIdMap = new Map<Id, Id>();
        // List<PendingReferral__e> pendingReferrals = new List<PendingReferral__e>();
        List<User> qualifiedUsers = new List<User>();
        List<Id> validContacts = new List<Id>();
        for (Site_Staff__c ss : siteStaff) {
            contactIds.add(ss.Site_Contact__c);
        }
        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(
            contactIds,
            contactIds
        );
        List<Site_Staff__c> siteStaffs = [
            SELECT Id, Site_Contact__c, Study_Site__c, is_Invited__c
            FROM Site_Staff__c
            WHERE
                Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                AND is_Invited__c = TRUE
                AND Site_Contact__c IN :contactIds
            	AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                AND Study_Site__r.Override_PI_Referral_Status__c IN ('Accepted','Accepted (Admin)')
        ];
        for (Site_Staff__c ss : siteStaffs) {
            if (!ssByContactIdMap.containsKey(ss.Site_Contact__c)) {
                ssByContactIdMap.put(ss.Site_Contact__c, ss.Study_Site__c);
            }
        }

        List<User> users = [
            SELECT Id, ContactId, timezonesidkey, Time_To_Send_Mail__c, TimeOfRun__c
            FROM User
            WHERE ContactId IN :contactIds
        ];

        for (User u : users) {
            Boolean isQualified = false;
            DateTime timeToSendMail;
            Timezone tz = Timezone.getTimeZone(u.timezonesidkey);
            Integer offset = tz.getOffset(lastbatchstart);
            Datetime userlocaltime = lastbatchstart.addSeconds(offset / 1000);
            Integer hours = 0;
            Integer minutes = 0;
            system.debug('uid' + u.Id);
            system.debug('lastbatchstart' + lastbatchstart);
            system.debug('userlocaltime' + userlocaltime);
            if (
                ((userlocaltime.hourgmt() == 7 && userlocaltime.minutegmt() <= 45) ||
                userlocaltime.hourgmt() == 6) &&
                ((userlocaltime.hourgmt() + 1 == 7 && userlocaltime.minutegmt() >= 45) ||
                userlocaltime.hourgmt() + 1 == 8) &&
                u.TimeOfRun__c != String.valueOf(lastbatchstart).subStringBefore(' ')
            ) {
                //u.TimeOfRun__c = 'AM';
                DateTime currentTime = DateTime.now();
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
                u.Time_To_Send_Mail__c = currentTime;
                u.TimeOfRun__c = String.valueOf(lastbatchstart).subStringBefore(' ');
                isQualified = true;
                qualifiedUsers.add(u);
                finalDelegateIds.add(u.Id);
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
        return Batch_SendDelegateEMailForNewReferrals.class;
    }
}