public inherited sharing class PatientVisitService {

    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        return this.getVisitWrappers(visitMode, null);
    }

    public List<VisitWrapper> getVisitWrappers(String visitMode, Integer limitNumber) {
        return this.getVisitWrappers(this.getVisits(visitMode, limitNumber));
    }

    @TestVisible
    private List<Patient_Visit__c> getVisits(String visitMode, Integer limitNumber) {

        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.pe == null || !pState.showVisits) return null;

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Visit__r.Visit_Schedule__c, ' +
                'Visit__r.Patient_Portal_Name__c, ' +
                'Visit__r.Icons__c, ' +
                'Status__c, ' +
                'Completed_Date__c, ' +
                'Is_Adhoc__c ' +
                'FROM Patient_Visit__c ' +
                'WHERE Participant_Enrollment__c = \'' + pState.pe.Id + '\'' +
                ' AND Status__c ' + (VISIT_MODE_CURRENT == visitMode ? '=' : '!=') + '\'' + VISIT_STATUS_PENDING + '\'' +
                ' ORDER BY Visit_Number__c ' + (VISIT_MODE_PAST == visitMode ? ' DESC ' : 'ASC') + ' NULLS LAST' +
                (limitNumber == null ? '' : ' LIMIT ' + limitNumber);

        List<Patient_Visit__c> visits = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
        TranslateHelper.translate(visits, IRBParticipantService.getIRBLanguageMode(pState.pe.Id).languageToTranslate);
        return visits;
    }


    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {

        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if (visits == null || visits.isEmpty()) {
            return visitWrappers;
        }
        Map<Id, Task> tasksByVisitIds = getTasksByVisitIds(visits);
        Set<Id> uniqueId = new Set<Id>();
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
                        ActivityDate
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
        public String icons;
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public String reminderDate;
        @AuraEnabled
        public Patient_Visit__c visit;

        public VisitWrapper(Patient_Visit__c visit, Task task) {
            this.visit = visit;
            this.icons = visit.Visit__r.Icons__c;
            this.task = task;
            this.reminderDate = (this.task == null || this.task.ActivityDate == null) ? Label.Home_Page_StudyVisit_No_Reminder_Date : DateService.format(this.task.ActivityDate, 'DD-MMM-YYYY');
            this.completedDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
        }
    }
}