public with sharing class ParticipantVisitsService {

    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        if (VISIT_MODE_CURRENT == visitMode) {
            return getVisitWrappers(VisitService.getInstance().getVisits(' AND Status__c = \'' + VISIT_STATUS_PENDING + '\''));
        } else if (VISIT_MODE_PAST == visitMode) {
            return getVisitWrappers(
                    ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                            .getVisits(' AND Status__c != \'' + VISIT_STATUS_PENDING + '\'')
            );
        } else {
            return new List<VisitWrapper>();
        }
    }

    private List<VisitWrapper> getVisitWrappers(List<Visit__c> visits) {

        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if(visits == null || visits.isEmpty()) {
            return visitWrappers;
        }
        Map<Id, Task> tasksByVisitIds = getTasksByVisitIds(visits);
        Set<Id> uniqueId = new Set<Id>();
        for (Visit__c singleVisit : visits) {
            if (uniqueId.add(singleVisit.Id)) {
                visitWrappers.add(new VisitWrapper(singleVisit, tasksByVisitIds.get(singleVisit.Id)));
            }
        }
        return visitWrappers;
    }

    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {

        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if(visits == null || visits.isEmpty()) {
            return visitWrappers;
        }
        Set<Id> uniqueId = new Set<Id>();
        for (Patient_Visit__c singleVisit : visits) {
            if (uniqueId.add(singleVisit.Id)) {
                visitWrappers.add(new VisitWrapper(singleVisit));
            }
        }
        return visitWrappers;
    }

    private Map<Id, Task> getTasksByVisitIds(List<Visit__c> visits) {

        Map<Id, Task> tasksByVisitIds = new Map<Id, Task>();
        List<Task> tasks = [
                SELECT Id,
                        Visit__c,
                        ActivityDate
                FROM Task
                WHERE Visit__c IN :new Map<Id, Visit__c>(visits).keySet() AND Status = 'Open'
        ];
        for (Task singleTask : tasks) {
            tasksByVisitIds.put(singleTask.Visit__c, singleTask);
        }
        return tasksByVisitIds;
    }

    public class VisitWrapper {

        @AuraEnabled
        public String completedDate;
        @AuraEnabled
        public String visitId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String schedule;
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

        public VisitWrapper(Patient_Visit__c visit) {
            this.visitId = visit.Visit__r.Id;
            this.schedule = visit.Visit_Schedule__c;
            this.icons = visit.Visit__r.Icons__c;
            this.isAdhoc = visit.Is_Adhoc__c;
            this.status = visit.Status__c;
            this.name = visit.Name;
            this.completedDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
        }

        public VisitWrapper(Visit__c visit, Task task) {
            this.visitId = visit.Id;
            this.schedule = visit.Visit_Schedule__c;
            this.icons = visit.Icons__c;
            this.status = visit.Status__c;
            this.name = visit.Name;
            this.task = task;
            this.reminderDate = (this.task == null || this.task.ActivityDate == null) ? Label.Home_Page_StudyVisit_No_Reminder_Date : DateService.format(this.task.ActivityDate, 'DD-MMM-YYYY');
        }
    }
}