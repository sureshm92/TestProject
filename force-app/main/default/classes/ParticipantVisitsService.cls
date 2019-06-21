public with sharing class ParticipantVisitsService {

    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        if (VISIT_MODE_CURRENT == visitMode) {
            return getVisitWrappers(VisitService.getInstance().getVisits(' AND Status__c = \'' + VISIT_STATUS_PENDING + '\''));
        } else if (VISIT_MODE_PAST == visitMode) {
            return getVisitWrappers(VisitService.getInstance().getVisits(' AND Status__c != \'' + VISIT_STATUS_PENDING + '\''));
        } else {
            return new List<VisitWrapper>();
        }
    }

    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {

        Map<Id, Task> tasksByVisitIds = getTasksByVisitIds(visits);
        Set<Id> uniqueId = new Set<Id>();
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        for (Patient_Visit__c singleVisit : visits) {
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
                        Reminder_Date__c
                FROM Task
                WHERE Patient_Visit__c IN :new Map<Id, Patient_Visit__c>(visits).keySet() AND Status = 'Open'
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
        public Patient_Visit__c visit;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String timeplane;
        @AuraEnabled
        public String icons;
        @AuraEnabled
        public Boolean isAdhoc;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public String reminderDate;

        public VisitWrapper(Patient_Visit__c visit, Task task) {
            this.visit = visit;
            this.timeplane = visit.Timeplane__c;
            this.icons = visit.Visit__r.Icons__c;
            this.isAdhoc = visit.Is_Adhoc__c;
            this.status = visit.Status__c;
            this.name = visit.Name;
            this.task = task;
            this.reminderDate = (this.task == null || this.task.Reminder_Date__c == null) ? Label.Home_Page_StudyVisit_No_Reminder_Date : DateService.format(this.task.Reminder_Date__c.date(), 'DD-MMM-YYYY');
            this.completedDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
        }
    }
}