public inherited sharing class PatientVisitService {

    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';
    public static final String VISIT_MODE_ALL = 'All';
    private static User CURRENT_USER;

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        return this.getVisitWrappers(visitMode, null);
    }

    public List<VisitWrapper> getVisitWrappers(String visitMode, Integer limitNumber) {
        return this.getVisitWrappers(this.getVisits(visitMode, limitNumber));
    }

    @TestVisible
    private List<Patient_Visit__c> getVisits(String visitMode, Integer limitNumber) {
        ParticipantService.ParticipantState pState =
                ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.pe == null || !pState.showVisits) return null;

        List<String> fields = new List<String>{
                'Completed_Date__c',
                'Is_Adhoc__c',
                'Name',
                'Participant_Enrollment__r.Participant_Contact__c',
                'Status__c',
                'Visit__r.Visit_Schedule__c',
                'Visit__r.Patient_Portal_Name__c',
                'Visit__r.Icons__c'
        };
        String filter = DatabaseService.fieldEqual('Participant_Enrollment__c', pState.pe.Id);
        if (visitMode != VISIT_MODE_ALL) {
            filter +=
                'AND' + (VISIT_MODE_CURRENT == visitMode ?
                        DatabaseService.fieldEqual('Status__c', VISIT_STATUS_PENDING)
                        : DatabaseService.fieldNotEqual('Status__c', VISIT_STATUS_PENDING)
                );
        }
        String order = 'Visit_Number__c ' + (VISIT_MODE_PAST == visitMode ? ' DESC ' : 'ASC') + ' NULLS LAST';
        Integer limitVisits = (limitNumber != null ? limitNumber : null);

        List<Patient_Visit__c> visits = (List<Patient_Visit__c>)
                DatabaseService.query(fields, Patient_Visit__c.getSObjectType(), filter, order, limitVisits);
        TranslateHelper.translate(visits, IRBParticipantService.getSuitableLanguageForIRBTranslation(pState.pe.Id));
        return visits;
    }


    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if (visits == null || visits.isEmpty()) return visitWrappers;

        List<User> users = [SELECT Id, LocaleSidKey, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        CURRENT_USER = users.get(0);
        TimeZone timeZone = TimeZone.getTimeZone(CURRENT_USER.TimeZoneSidKey);
        Map<Id, Task> tasksByVisitIds = getTasksByVisitIds(visits);
        Set<Id> uniqueId = new Set<Id>();
        for (Patient_Visit__c singleVisit : visits) {
            if (singleVisit.Completed_Date__c != null) {
                singleVisit.Completed_Date__c = DateTimeConverterUtil.getUserDatetime(timeZone, singleVisit.Completed_Date__c).date();
            }

            if (uniqueId.add(singleVisit.Id)) {
                visitWrappers.add(new VisitWrapper(singleVisit, tasksByVisitIds.get(singleVisit.Id)));
            }
        }
        return visitWrappers;
    }

    private Map<Id, Task> getTasksByVisitIds(List<Patient_Visit__c> visits) {

        Map<Id, Task> tasksByVisitIds = new Map<Id, Task>();
        List<Task> tasks = [
                SELECT Id,
                        Patient_Visit__c,
                        Reminder_Date__c,
                        ReminderDateTime
                FROM Task
                WHERE Patient_Visit__c IN :NEW Map<Id, Patient_Visit__c>(visits).keySet() AND Status = 'Open'
        ];
        for (Task singleTask : tasks) {
            tasksByVisitIds.put(singleTask.Patient_Visit__c, singleTask);
        }
        return tasksByVisitIds;
    }

    public class VisitWrapper {

        @AuraEnabled
        public String completedDate;
        @AuraEnabled
        public String icons;
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Date reminderDate;
        @AuraEnabled
        public Patient_Visit__c visit;

        public VisitWrapper(Patient_Visit__c visit, Task task) {
            this.visit = visit;
            this.icons = visit.Visit__r.Icons__c;
            this.task = task;
            this.reminderDate = DateTimeConverterUtil.getUserDatetime(TimeZone.getTimeZone(CURRENT_USER.TimeZoneSidKey), this.task.ReminderDateTime).date();
            this.completedDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : String.valueOf(visit.Completed_Date__c);
        }
    }
}