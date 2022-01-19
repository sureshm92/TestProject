/**
 * Created by Igor Malyuta on 19.06.2019.
 */

public without sharing class TrialSurveyTriggerHandler {
    public class ExpireSurveyTaskAndInvitations extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            doExpire((List<Trial_Survey__c>) oldList);
        }
    }
    public class UpdateTrialSurveyAndInvitations extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            updateTrialSurvey(
                (List<Trial_Survey__c>) newList,
                null
            );
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateTrialSurvey(
                (List<Trial_Survey__c>) newList,
                (Map<Id, Trial_Survey__c>) oldMap
            );
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateSurveyInvitation(
                (List<Trial_Survey__c>) newList,
                (Map<Id, Trial_Survey__c>) oldMap
            );
        }
    }

    @TestVisible
    private static void updateTrialSurvey(List<Trial_Survey__c> newTrialSurveys, Map<Id, Trial_Survey__c> oldMap) {
        if(oldMap == null ){
            for(Trial_Survey__c ts : newTrialSurveys){
                if(ts.Survey_start_date__c != null && ts.Is_Recurrence_Survey__c){
                    updateNextOccurences(ts, ts.Survey_start_date__c);
                }
            }
        }
        else{
            for(Trial_Survey__c ts : newTrialSurveys){
                if(ts.Survey_start_date__c != null && ts.Is_Recurrence_Survey__c){
                    if(ts.Survey_start_date__c != oldMap.get(ts.id).Survey_start_date__c){
                        updateNextOccurences(ts, ts.Survey_start_date__c);
                    }
                    if(ts.Survey_end_date__c != oldMap.get(ts.id).Survey_end_date__c){
                        if(ts.Survey_end_date__c < ts.Next_Occurrence_Date__c){ 
                            ts.Next_Occurrence_Date__c = null;
                            ts.Next_Occurrence_Reminder__c = null;
                            ts.Next_Task_Due_Date__c = null;
                        }
                        else if(ts.Survey_end_date__c >= ts.Next_Occurrence_Date__c && 
                            ts.Survey_end_date__c <= ts.Next_Task_Due_Date__c){
                            ts.Next_Task_Due_Date__c = ts.Survey_end_date__c;
                            Integer days;
                            if(ts.Reminder_in_days_before_the_end_date__c != null){
                                days = Integer.valueOf(ts.Reminder_in_days_before_the_end_date__c);
                            }
                            if(days!=null && ts.Next_Task_Due_Date__c.addDays(-days) >= ts.Next_Occurrence_Date__c){
                                ts.Next_Occurrence_Reminder__c = ts.Next_Task_Due_Date__c.addDays(-days);
                            }
                            else{
                                ts.Next_Occurrence_Reminder__c = null;
                            }
                        }
                        else if(ts.Survey_end_date__c > oldMap.get(ts.id).Survey_end_date__c && 
                        ts.Next_Occurrence_Date__c == null){
                            updateNextOccurences(ts, oldMap.get(ts.id).Survey_end_date__c.addDays(1));
                        }
                    }
                    if(ts.Recurrence_Frequency__c != oldMap.get(ts.id).Recurrence_Frequency__c){
                        updateNextOccurences(ts, ts.Next_Occurrence_Date__c);
                    }   
                }
            }
        }
    }

    private static void updateNextOccurences(Trial_Survey__c ts, Date nextOccDate){
        Integer days;
        if(ts.Reminder_in_days_before_the_end_date__c != null){
            days = Integer.valueOf(ts.Reminder_in_days_before_the_end_date__c);
        }
        ts.Next_Occurrence_Date__c = nextOccDate;
        Date endDate = ts.Next_Occurrence_Date__c;
        if(ts.Recurrence_Frequency__c == 'Weekly'){
            endDate = ts.Next_Occurrence_Date__c.addDays(6);
        }
        else if(ts.Recurrence_Frequency__c == 'Monthly'){
            endDate = ts.Next_Occurrence_Date__c.addMonths(1).addDays(-1);
        }
        else if(ts.Recurrence_Frequency__c == 'Yearly'){
            endDate = ts.Next_Occurrence_Date__c.addYears(1).addDays(-1);
        }
        ts.Next_Task_Due_Date__c = endDate;
        if(days!=null && endDate.addDays(-days) >= ts.Next_Occurrence_Date__c){
            ts.Next_Occurrence_Reminder__c = endDate.addDays(-days);
        }
    }

    @TestVisible
    private static void updateSurveyInvitation(List<Trial_Survey__c> newTrialSurveys, Map<Id, Trial_Survey__c> oldMap) {
        List<Id> trialSurveyIds = new List<Id>();
        for(Trial_Survey__c survey: newTrialSurveys){
            if(survey.Is_Midpoint__c != oldMap.get(survey.Id).Is_Midpoint__c){
                trialSurveyIds.add(survey.Id);
            }
        }
        List<Id> surveyInvitationIds = new List<Id>();
        List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();
        if(trialSurveyIds.size() != 0){
            surveyInvitations = [
                    SELECT
                        Id,
                        Is_Midpoint__c,
                        Participant_Enrollment__r.id,
                        Participant_Enrollment__r.Participant_Status__c,
                        Trial_Survey__r.Is_Midpoint__c
                    FROM SurveyInvitation
                    WHERE Trial_Survey__c IN :trialSurveyIds
                ];
        }
        if(surveyInvitations.size() != 0){
            for(SurveyInvitation inv : surveyInvitations){
                inv.Is_Midpoint__c = inv.Trial_Survey__r.Is_Midpoint__c;
                if(PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(inv.Participant_Enrollment__r.Participant_Status__c)){
                    surveyInvitationIds.add(inv.id);
                }
            }
        }
        if(surveyInvitationIds.size() != 0){
            List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE
                Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Status IN :TaskService.TASK_STATUS_GROUP_AVAILABLE
                AND Survey_Invitation__c IN :surveyInvitationIds
            ];

            List<Task> tasksForExpire = new List<Task>();
            for (Task task : tasks) {
                task.Status = TaskService.TASK_STATUS_EXPIRED;
                tasksForExpire.add(task);
            }
            update tasksForExpire;

            SurveyService.getInstance().expireInvitation(new List<Id>(surveyInvitationIds));
        }
        

    }

    @TestVisible
    private static void doExpire(List<Trial_Survey__c> oldTrialSurveys) {
        Map<Id, SurveyInvitation> surveyInvitations = new Map<Id, SurveyInvitation>(
            [
                SELECT
                    Id,
                    CreatedDate,
                    ExpireDateTime__c,
                    InviteExpiryDateTime,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM SurveyInvitation
                WHERE Trial_Survey__c IN :oldTrialSurveys
            ]
        );

        Set<Id> contactIds = new Set<Id>();
        for (SurveyInvitation inv : surveyInvitations.values()) {
            inv.ExpireDateTime__c = System.now();
            inv.Is_Expired__c = true;
            if (inv.InviteExpiryDateTime != null)
                inv.InviteExpiryDateTime = null;

            Id participantCId = inv.Participant_Enrollment__r.Participant_Contact__c;
            contactIds.add(participantCId);
            contactIds.addAll(PatientDelegateService.getDelegatedContactIds(participantCId));
        }
        update surveyInvitations.values();

        List<Task> surveyTasks = [
            SELECT Id, Status
            FROM Task
            WHERE
                Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Status IN :TaskService.TASK_STATUS_GROUP_EXPIRE_AVAILABLE
                AND WhoId IN :contactIds
                AND Survey_Invitation__c IN :surveyInvitations.keySet()
        ];
        for (Task task : surveyTasks)
            task.Status = TaskService.TASK_STATUS_EXPIRED;

        update surveyTasks;
    }
}
