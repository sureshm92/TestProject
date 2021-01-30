public class EmailForPendingReferrals {
    @InvocableMethod
    public static void sendMails(List<Batch_Notification__c> notifications) {
        system.debug('notifications' + notifications);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Notification_Type__mdt notificationType = NotificationService.getNotificationType(
            'PI_Delegates_New_Referral'
        );
        Notification_Target__mdt nt = notificationType.Notification_Targets__r[0];
        List<Id> allContactIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for (Batch_Notification__c bn : notifications) {
            contactIds = bn.Recipient_Ids__c.split(';');
            for (Id conId : contactIds)
                if (!allContactIds.contains(conId))
                    allContactIds.add(conId);
        }

        NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(
            allContactIds,
            allContactIds
        );

        List<Study_Site__c> studySite = new List<Study_Site__c>();

        studySite = [
            SELECT Id, Principal_Investigator__c
            FROM Study_Site__c
            WHERE
            Principal_Investigator__c IN :allContactIds
            ORDER BY CreatedDate
        ];

        /**   List<Participant_Enrollment__c> pes = [
                SELECT Study_Site__c,
                        Study_Site__r.Principal_Investigator__c
                FROM Participant_Enrollment__c
                WHERE Participant_Status__c = 'Received'
                AND Clinical_Trial_Profile__c IN (
                        SELECT Clinical_Trial_Profile__c
                        FROM Study_Site__c
                        WHERE Principal_Investigator__c IN:allContactIds
                )
                ORDER By CreatedDate
        ];  **/
        Map<Id, Id> ssByContactIdMap = new Map<Id, Id>();
        /**   for (Participant_Enrollment__c pe : pes) {
            if (!ssByContactIdMap.containsKey(pe.Study_Site__r.Principal_Investigator__c)) {
                ssByContactIdMap.put(pe.Study_Site__r.Principal_Investigator__c, pe.Study_Site__c);
            }
        }  **/

        for (Study_Site__c ssite : studySite) {
            if (!ssByContactIdMap.containsKey(ssite.Principal_Investigator__c)) {
                ssByContactIdMap.put(ssite.Principal_Investigator__c, ssite.Id);
            }
        }

        List<Site_Staff__c> siteStaffs = [
            SELECT Id, Site_Contact__c, Study_Site__c, is_Invited__c
            FROM Site_Staff__c
            WHERE
                Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                AND is_Invited__c = TRUE
                AND Site_Contact__c IN :allContactIds
        ];
        for (Site_Staff__c ss : siteStaffs) {
            if (!ssByContactIdMap.containsKey(ss.Site_Contact__c)) {
                ssByContactIdMap.put(ss.Site_Contact__c, ss.Study_Site__c);
            }
        }

        List<HCP_Enrollment__c> hpes = [
            SELECT Study_Site__c, HCP_Contact__c
            FROM HCP_Enrollment__c
            WHERE
            HCP_Contact__c IN :allContactIds
        ];
        for (HCP_Enrollment__c hpe : hpes) {
            if (!ssByContactIdMap.containsKey(hpe.HCP_Contact__c)) {
                ssByContactIdMap.put(hpe.HCP_Contact__c, hpe.Study_Site__c);
            }
        }

        for (Id contactId : ssByContactIdMap.keySet())
            if (allContactIds.contains(contactId)) {
                emailMessages.add(
                    EmailService.createEmail(
                        EmailService.getEmailTemplateId('PI_RP_New_Referral'),
                        contactId,
                        ssByContactIdMap.get(contactId),
                        availabilityService.getOrgWideEmail(
                            contactId,
                            ssByContactIdMap.get(contactId),
                            nt.Org_Wide_Email_Address__c
                        )
                    )
                );
            }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailMessages, false);
    }
}
