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
                'Visit__r.Icons__c',
                'Visit__r.Visit_Plan__c',
                'Planned_Date__c'
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

    public static List<Patient_Visit__c> getPatientCardVisits(Id peId) {
        String filter = DatabaseService.fieldEqual('Participant_Enrollment__c', peId)
                + 'AND Is_Adhoc__c = FALSE ';
        String order = 'Visit_Number__c ASC NULLS LAST';
        List<Patient_Visit__c> patientVisits = (List<Patient_Visit__c>) DatabaseService.query(
                new List<String>{
                        'Id',
                        'Name',
                        'Completed_Date__c',
                        'Status__c',
                        'Planned_Date__c',
                        'Portal_Name__c',
                        'Visit_Number__c'
                }, Patient_Visit__c.getSObjectType(), filter, order, null
        );

        TranslateHelper.translate(patientVisits, IRBParticipantService.getSuitableLanguageForIRBTranslation(peId));
        return patientVisits;
    }

    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if (visits == null || visits.isEmpty()) return visitWrappers;
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        for(Patient_Visit__c visit: visits){
            if(visit.Visit__c!=null && visit.Visit__r.Visit_Plan__c !=null){
                visitPlanId = visit.Visit__r.Visit_Plan__c;   
                break;
            }
        }
        if(visitPlanId !=null){
            iconDetails = [
                SELECT Id, Name, Label__c
                FROM Icon_Details__c
                WHERE Visit_Plan__c = :visitPlanId
            ];
        }
        TranslateHelper.translate(iconDetails);
        Map<String, Icon_Details__c> iconDetailsMap = new Map<String, Icon_Details__c>();
        for(Icon_Details__c iconDetail : iconDetails) iconDetailsMap.put(iconDetail.Name, iconDetail);
        
        List<User> users = [
                SELECT Id, LocaleSidKey, TimeZoneSidKey
                FROM User WHERE Id = :UserInfo.getUserId()
        ];
        
        CURRENT_USER = users.get(0);
        TimeZone timeZone = TimeZone.getTimeZone(CURRENT_USER.TimeZoneSidKey);
        Map<Id, Task> tasksByVisitIds = getTasksByVisitIds(visits);
        Set<Id> uniqueId = new Set<Id>();
        for (Patient_Visit__c singleVisit : visits) {
            if (singleVisit.Completed_Date__c != null) {
                singleVisit.Completed_Date__c = singleVisit.Completed_Date__c;
            }

            if (uniqueId.add(singleVisit.Id)) {
                visitWrappers.add(new VisitWrapper(singleVisit, tasksByVisitIds.get(singleVisit.Id), iconDetailsMap));
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

    public static Patient_Visit__c createPatientVisit(Visit__c visit, Id peId) {
        return new Patient_Visit__c(
                Name = visit.Name,
                Visit__c = visit.Id,
                Visit_Schedule__c = visit.Visit_Schedule__c,
                Visit_Number__c = visit.Visit_Number__c,
                Participant_Enrollment__c = peId,
                Portal_Name__c = visit.Patient_Portal_Name__c
        );
    }

    public class VisitWrapper {

        @AuraEnabled public String completedOrPlannedDate;
        @AuraEnabled public String icons;
        @AuraEnabled public List<Icon_Details__c> iconDetails;
        @AuraEnabled public Task task;
        @AuraEnabled public Date reminderDate;
        @AuraEnabled public Patient_Visit__c visit;

        public VisitWrapper(Patient_Visit__c visit, Task task, Map<String, Icon_Details__c> iconDetailsMap) {
            this.visit = visit;
            iconDetails = new List<Icon_Details__c>();
            if (visit.Visit__c != null) {
                icons = visit.Visit__r.Icons__c;
                
				List<String> iconNames = new List<String>();
                if(visit.Visit__r !=null && visit.Visit__r.Icons__c !=null)
                    iconNames = visit.Visit__r.Icons__c.split(';');

                if (!iconNames.isEmpty()) {
                    for(String iconName : iconNames) {
                        if(iconDetailsMap.containsKey(iconName)) {
                            iconDetails.add(iconDetailsMap.get(iconName));
                        }
                    }
                }
            }

            this.task = task;
            if (task != null && task.ReminderDateTime != null) {
                this.reminderDate = task.ReminderDateTime.date();
            }
            completedOrPlannedDate = visit.Completed_Date__c != null ?
                    String.valueOf(visit.Completed_Date__c)
                    : (visit.Planned_Date__c != null ? String.valueOf(visit.Planned_Date__c) : Label.Study_Visit_Unavailable);
        }
    }
}