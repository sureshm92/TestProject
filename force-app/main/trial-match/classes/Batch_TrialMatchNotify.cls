/**
 * Created by Igor Malyuta on 14.05.2020. 
 */
public with sharing class Batch_TrialMatchNotify extends Batch_ScheduledAbstract {
    private Map<Id, Map<String, Id>> enrollmentsByTemplateByContact = new Map<Id, Map<String, Id>>();
	 
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                	Matched_Date__c,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                	Participant_Enrollment__r.Clinical_Trial_Profile__r.Delayed_No_Of_Days__c,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM Trial_Match__c
                WHERE Is_Eligible__c = TRUE AND Is_User_notified__c = FALSE AND 
                Participant_Enrollment__r.Clinical_Trial_Profile__r.Trial_Match_Is_Available__c = TRUE AND
                (Clinical_Trial_Profile__r.Override_Recruitment_Status__c = 'Actively Enrolling' OR 
                 Clinical_Trial_Profile__r.Override_Recruitment_Status__c = 'On Hold')
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Trial_Match__c> matches) {
        Set<id> uniqueParticipantContactIds = new Set<id>();
        List<user> uniqueParticipantUsers = new List<user>();
        Map<id,User> userRecordsByContactId = new Map<id,user>();
        for (Trial_Match__c match : matches) {
            uniqueParticipantContactIds.add(match.Participant_Enrollment__r.Participant_Contact__c);
        }
        uniqueParticipantUsers=[Select id, contactid, timezonesidkey from user where contactid=:uniqueParticipantContactIds];
        if(uniqueParticipantUsers!=null && uniqueParticipantUsers.size()>0){
            for(User userRecord:uniqueParticipantUsers){
                userRecordsByContactId.put(userRecord.contactId,userRecord);
            }
        }
        for (Trial_Match__c match : matches) {
            Integer delayDays=0;
            if(match.Participant_Enrollment__r.Clinical_Trial_Profile__r.Delayed_No_Of_Days__c != null){
                delayDays = Integer.valueOf(match.Participant_Enrollment__r.Clinical_Trial_Profile__r.Delayed_No_Of_Days__c);
            }
            
            Date notifyDate;
            if(match.Matched_Date__c != null){
                notifyDate = match.Matched_Date__c + delayDays;
            }
            else{
                notifyDate = date.today();
            }
            Participant_Enrollment__c enrollment = match.Participant_Enrollment__r;
			// To capture the current hour of the Participant Time Zone
			Integer currentHour = System.now().hour();
            String batchContextTimezone=String.valueof(UserInfo.getTimeZone());
            Date currentDateInParticipantTimeZone= date.today();
            // checking if User exists for this participant or not
            if(userRecordsByContactId.containsKey(enrollment.Participant_Contact__c)){
                String userTimezoneKey=userRecordsByContactId.get(enrollment.Participant_Contact__c).timezonesidkey;
                // checking if participant time zone is same as per current batch user time zone
                if(!batchContextTimezone.equalsIgnoreCase(userTimezoneKey)){
                  Timezone participantTimeZone= Timezone.getTimeZone(userTimezoneKey);
                  // finding the time difference between participants date and current GMT date
                  Integer timeOffSetInSeconds= (participantTimeZone.getOffset(date.Today()) / 3600000);
                  // finding the current datetime in participants context
                  Datetime currentDateTimeInParticipantContext= System.now().addHours(timeOffSetInSeconds);
                  //finding the current hour in participants context
                  currentHour = currentDateTimeInParticipantContext.hourGmt();
                  //fetching current date in participant timezone
                  currentDateInParticipantTimeZone=currentDateTimeInParticipantContext.dateGMT();
                }
            }
            
            if(currentDateInParticipantTimeZone >= notifyDate && currentHour >= Integer.valueof(System.Label.TrialMatchMailTime)){
                match.Is_User_notified__c = true;
                if (!enrollmentsByTemplateByContact.containsKey(enrollment.Participant_Contact__c)) {
                    enrollmentsByTemplateByContact.put(
                        enrollment.Participant_Contact__c,
                        new Map<String, Id>()
                    );
            	}
            }
            Map<String, Id> enrollmentsByTemplate = enrollmentsByTemplateByContact.get(
                enrollment.Participant_Contact__c
            );
            String communityTemplate = enrollment.Clinical_Trial_Profile__r.CommunityTemplate__c;
            if (enrollmentsByTemplate != null && !enrollmentsByTemplate.containsKey(communityTemplate)) {
                enrollmentsByTemplate.put(communityTemplate, enrollment.Id);
            }
        }

        update matches;
    }

    public override void finalAction() {
        Map<Id, List<Id>> delegatesContByParticipantContact = 	PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
            new List<Id>(enrollmentsByTemplateByContact.keySet())
        );

        List<Notification__c> notifications = new List<Notification__c>();
        for (Id partContactId : enrollmentsByTemplateByContact.keySet()) {
            List<Id> delegates = delegatesContByParticipantContact.get(partContactId);
            Map<String, Id> enrollmentsByTemplate = enrollmentsByTemplateByContact.get(
                partContactId
            );
            for (String template : enrollmentsByTemplate.keySet()) {
                Id peId = enrollmentsByTemplate.get(template);
                notifications.add(
                    new Notification__c(
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TRIAL_MATCH,
                        Recipient__c = partContactId,
                        WhatId__c = peId
                    )
                );

                if (delegates != null) {
                    for (Id delCont : delegates) {
                        notifications.add(
                            new Notification__c(
                                IsDelegate__c = true,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TRIAL_MATCH,
                                Recipient__c = delCont,
                                WhatId__c = peId
                            )
                        );
                    }
                }
            }
        }

        if (!notifications.isEmpty())
            insert notifications;
    }

    public override String getBatchDescription() {
        return 'Processes Trial Matches ans creates patient notifications.';
    }

    public override String getRecommendedIntervalMode() {
        return INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 3;
    }

    public override Type getType() {
        return Batch_TrialMatchNotify.class;
    }
}
