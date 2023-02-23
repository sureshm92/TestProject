public inherited sharing class PatientVisitService {
    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';
    public static final String VISIT_MODE_PENDING = 'Pending';
    public static final String VISIT_MODE_ALL = 'All';
    public static final String VISIT_MODE_SCHEDULED = 'Scheduled';
    public static final String VISIT_MODE_COMPLETED = 'Completed';
    public static final String VISIT_MODE_MISSED = 'Missed';
    public static final String VISIT_MODE_UPCOMING = 'Upcoming';
    private static User CURRENT_USER;

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        return this.getVisitWrappers(visitMode, null);
    }

    public PatientVisitsAndEvent getVisitWrappersAndStudyType(
        String visitMode,
        List<String> additionalFields
    ) {
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(
                ParticipantService.class
            ))
            .getState();
        if (pState == null || pState.pe == null || !pState.showVisits) {
            return null;
        }
        PatientVisitsAndEvent pvAndEvent = new PatientVisitsAndEvent();
        List<Patient_Visit__c> pvList = this.getVisitsData(
            pState,
            visitMode,
            null,
            additionalFields
        );
        processPendingInitialVisits(pvList);
        pvAndEvent.pvList = this.getVisitWrappers(pvList);
        pvAndEvent.isEvent = pState.pe.Clinical_Trial_Profile__r.Is_Program__c;
        return pvAndEvent;
    }

    public class PatientVisitsAndEvent {
        @AuraEnabled
        public List<VisitWrapper> pvList;
        @AuraEnabled
        public Boolean isEvent = false;
    }

    public List<VisitWrapper> getVisitWrappers(String visitMode, Integer limitNumber) {
        return this.getVisitWrappers(this.getVisits(visitMode, limitNumber));
    }

    public List<VisitWrapper> getVisitWrappers(
        String visitMode,
        Integer limitNumber,
        List<String> additionalFields
    ) {
        return this.getVisitWrappers(this.getVisits(visitMode, limitNumber, additionalFields));
    }

    public List<VisitWrapper> getVisitWrappersAndHandleInitialVisits(
        String visitMode,
        Integer limitNumber,
        List<String> additionalFields
    ) {
        List<Patient_Visit__c> pvList = this.getVisits(visitMode, limitNumber, additionalFields);
        processPendingInitialVisits(pvList);
        return this.getVisitWrappers(pvList);
    }

    @TestVisible
    private List<Patient_Visit__c> getVisits(String visitMode, Integer limitNumber) {
        return getVisits(visitMode, limitNumber, new List<String>());
    }

    @TestVisible
    private List<Patient_Visit__c> getVisits(
        String visitMode,
        Integer limitNumber,
        List<String> additionalFields
    ) {
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(
                ParticipantService.class
            ))
            .getState();
        if (pState == null || pState.pe == null || !pState.showVisits) {
            return null;
        }
        return getVisitsData(pState, visitMode, limitNumber, additionalFields);
    }

    private List<Patient_Visit__c> getVisitsData(
        ParticipantService.ParticipantState pState,
        String visitMode,
        Integer limitNumber,
        List<String> additionalFields
    ) {
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
            'Planned_Date__c',
            'Visit_Number__c'
        };

        if (additionalFields != null && additionalFields.size() > 0) {
            fields.addAll(additionalFields);
        }
        String filter = DatabaseService.fieldEqual('Participant_Enrollment__c', pState.pe.Id);
        if (visitMode != VISIT_MODE_ALL) {
            if (visitMode == VISIT_MODE_SCHEDULED) {
                filter +=
                    'AND' +
                    DatabaseService.fieldEqual('Status__c', VISIT_MODE_SCHEDULED) +
                    ' AND' +
                    DatabaseService.DatefieldNotEqualsNull('Planned_Date__c');
            } else if (visitMode == VISIT_MODE_PENDING) {
                Datetime dt = null;
                filter +=
                    'AND' +
                    DatabaseService.fieldEqual('Status__c', VISIT_STATUS_PENDING) +
                    ' AND ' +
                    DatabaseService.DatefieldEqualsNull('Planned_Date__c');
                //+ 'AND Planned_Date__c=NULL';
                //+' AND '+ DatabaseService.fieldEqual('Planned_Date__c', null) ;
            } else if (visitMode == VISIT_MODE_PAST) {
                List<String> paststatusFilter = new List<String>{
                    VISIT_MODE_COMPLETED,
                    VISIT_MODE_MISSED
                };
                filter += 'AND' + DatabaseService.fieldInValues('Status__c', paststatusFilter);
            } else {
                if (visitMode == VISIT_MODE_CURRENT) {
                    List<String> currentstatusFilter = new List<String>{
                        VISIT_MODE_COMPLETED,
                        VISIT_MODE_MISSED
                    };
                    filter +=
                        'AND' + DatabaseService.fieldNotInValues('Status__c', currentstatusFilter);
                }
            }
        }

        String order =
            'Visit_Number__c ' +
            (VISIT_MODE_PAST == visitMode ? ' DESC ' : 'ASC') +
            ' NULLS LAST';
        Integer limitVisits = (limitNumber != null ? limitNumber : null);

        List<Patient_Visit__c> visits = (List<Patient_Visit__c>) DatabaseService.query(
            fields,
            Patient_Visit__c.getSObjectType(),
            filter,
            order,
            limitVisits
        );
        TranslateHelper.translate(
            visits,
            IRBParticipantService.getSuitableLanguageForIRBTranslation(pState.pe.Id)
        );

        return visits;
    }

    public static List<Icon_Details__c> getVisitIconsbyName(Id visitId) {
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        List<Patient_Visit__c> visits = [
            SELECT Id, Visit__c, Visit__r.Visit_Plan__c, Completed_Date__c, Visit__r.Icons__c
            FROM Patient_Visit__c
            WHERE Id = :visitId
        ];
        for (Patient_Visit__c visit : visits) {
            if (visit.Visit__c != null && visit.Visit__r.Visit_Plan__c != null) {
                visitPlanId = visit.Visit__r.Visit_Plan__c;
                break;
            }
        }
        String icons;
        List<String> iconNames = new List<String>();
        if (visits[0].Visit__c != null) {
            icons = visits[0].Visit__r.Icons__c;
            if (visits[0].Visit__r != null && visits[0].Visit__r.Icons__c != null)
                iconNames = visits[0].Visit__r.Icons__c.split(';');
        }
        iconDetails = [
            SELECT Id, Name, Label__c, Description__c
            FROM Icon_Details__c
            WHERE Name IN :iconNames AND Visit_Plan__c = :visitPlanId
        ];
        TranslateHelper.translate(iconDetails);
        return iconDetails;
    }

    public static List<Patient_Visit__c> getPatientCardVisits(Id peId) {
        String filter =
            DatabaseService.fieldEqual('Participant_Enrollment__c', peId) +
            'AND Is_Adhoc__c = FALSE ';
        String order = 'Visit_Number__c ASC NULLS LAST';
        List<Patient_Visit__c> patientVisits = (List<Patient_Visit__c>) DatabaseService.query(
            new List<String>{
                'Id',
                'Name',
                'Completed_Date__c',
                'Status__c',
                'Planned_Date__c',
                'Portal_Name__c',
                'Visit_Number__c',
                'Visit__c'
            },
            Patient_Visit__c.getSObjectType(),
            filter,
            order,
            null
        );

        List<Id> recordIds = new List<Id>();
        for(Patient_Visit__c pv: patientVisits){
            recordIds.add(pv.Visit__c);
        }
		String language=IRBParticipantService.getSuitableLanguageForIRBTranslation(peId);
        if (language == null)
            language = UserInfo.getLanguage();
        
        List<Translation__c> translations = [
            SELECT Id, Field_Name__c, Language__c, Object_Name__c, Record_Id__c, Value__c
            FROM Translation__c
            WHERE Record_Id__c IN :recordIds AND Language__c = :language and Object_Name__c ='Visit__c'
        	and Field_Name__c='patient_portal_name__c'];
        map<id,Translation__c> mapVisitIdToTranslations=new Map<id,Translation__c>();
        for(Translation__c tt:translations){
            mapVisitIdToTranslations.put(tt.Record_Id__c,tt);
        }
        for(Patient_Visit__c pv: patientVisits){
            if(mapVisitIdToTranslations.containskey(pv.Visit__c)){
                Translation__c tt=mapVisitIdToTranslations.get(pv.Visit__c);
                pv.Portal_Name__c=tt.Value__c;
            }
        }

        /*TranslateHelper.translate(
            patientVisits,
            IRBParticipantService.getSuitableLanguageForIRBTranslation(peId)
        );*/
        return patientVisits;
    }
    public List<VisitWrapper> getVisitDetails(Id visitId) {
        List<Patient_Visit__c> visits = [
            SELECT
                Id,
                Visit__c,
                Visit_Number__c,
                Visit__r.Visit_Plan__c,
                Planned_Date__c,
                Completed_Date__c,
                Visit__r.Icons__c,
                Status__c
            FROM Patient_Visit__c
            WHERE Id = :visitId
        ];
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if (visits == null || visits.isEmpty())
            return visitWrappers;
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        for (Patient_Visit__c visit : visits) {
            if (visit.Visit__c != null && visit.Visit__r.Visit_Plan__c != null) {
                visitPlanId = visit.Visit__r.Visit_Plan__c;
                break;
            }
        }
        if (visitPlanId != null) {
            iconDetails = [
                SELECT Id, Name, Label__c, Description__c
                FROM Icon_Details__c
                WHERE Visit_Plan__c = :visitPlanId
            ];
        }
        TranslateHelper.translate(iconDetails);
        Map<String, Icon_Details__c> iconDetailsMap = new Map<String, Icon_Details__c>();
        for (Icon_Details__c iconDetail : iconDetails)
            iconDetailsMap.put(iconDetail.Name, iconDetail);

        List<User> users = [
            SELECT Id, LocaleSidKey, TimeZoneSidKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
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
                visitWrappers.add(
                    new VisitWrapper(
                        singleVisit,
                        tasksByVisitIds.get(singleVisit.Id),
                        iconDetailsMap
                    )
                );
            }
        }
        return visitWrappers;
    }

    public List<Patient_Visit__c> getPatientVisitDetails(Id visitId) {
        List<Patient_Visit__c> visits = [
            SELECT
                Id,
                Name,
                Visit__c,
                Visit_Number__c,
                Visit__r.Visit_Plan__c,
                Visit__r.Patient_Portal_Name__c,
                Is_Pre_Enrollment_Patient_Visit__c,
                Planned_Date__c,
                Completed_Date__c,
                Visit__r.Icons__c,
                Status__c
            FROM Patient_Visit__c
            WHERE Id = :visitId
        ];

        return visits;
    }

    private List<VisitWrapper> getVisitWrappers(List<Patient_Visit__c> visits) {
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        if (visits == null || visits.isEmpty())
            return visitWrappers;
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        for (Patient_Visit__c visit : visits) {
            if (visit.Visit__c != null && visit.Visit__r.Visit_Plan__c != null) {
                visitPlanId = visit.Visit__r.Visit_Plan__c;
                break;
            }
        }
        if (visitPlanId != null) {
            iconDetails = [
                SELECT Id, Name, Label__c, Description__c
                FROM Icon_Details__c
                WHERE Visit_Plan__c = :visitPlanId
            ];
        }
        TranslateHelper.translate(iconDetails);
        Map<String, Icon_Details__c> iconDetailsMap = new Map<String, Icon_Details__c>();
        for (Icon_Details__c iconDetail : iconDetails)
            iconDetailsMap.put(iconDetail.Name, iconDetail);

        List<User> users = [
            SELECT Id, LocaleSidKey, TimeZoneSidKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
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
                visitWrappers.add(
                    new VisitWrapper(
                        singleVisit,
                        tasksByVisitIds.get(singleVisit.Id),
                        iconDetailsMap
                    )
                );
            }
        }
        return visitWrappers;
    }

    private Map<Id, Task> getTasksByVisitIds(List<Patient_Visit__c> visits) {
        Map<Id, Task> tasksByVisitIds = new Map<Id, Task>();
        List<Task> tasks = [
            SELECT
                Id,
                Patient_Visit__c,
                Reminder_Date__c,
                ReminderDateTime,
                Remind_Me__c,
                Remind_Using_Email__c,
                Remind_Using_SMS__c
            FROM Task
            WHERE
                Patient_Visit__c IN :new Map<Id, Patient_Visit__c>(visits).keySet()
                AND Status = 'Open'
        ];
        for (Task singleTask : tasks) {
            tasksByVisitIds.put(singleTask.Patient_Visit__c, singleTask);
        }
        return tasksByVisitIds;
    }

    public static Patient_Visit__c createInitialVisit(
        Visit__c visit,
        Participant_Enrollment__c pe
    ) {
        return new Patient_Visit__c(
            Name = visit.Name,
            Visit__c = visit.Id,
            Visit_Schedule__c = visit.Visit_Schedule__c,
            Visit_Number__c = visit.Visit_Number__c,
            Participant_Enrollment__c = pe.Id,
            Planned_Date__c = pe.Initial_Visit_Scheduled_DateTime__c != null
                ? pe.Initial_Visit_Scheduled_DateTime__c
                : null,
            Status__c = pe.Initial_visit_occurred_flag__c
                ? 'Completed'
                : pe.Initial_Visit_Scheduled_DateTime__c != null ? 'Scheduled' : 'Pending',
            Completed_Date__c = pe.Initial_visit_occurred_date__c != null
                ? DateTime.newInstance(
                          pe.Initial_visit_occurred_date__c,
                          Time.newInstance(0, 0, 0, 0)
                      )
                      .date()
                : null,
            Portal_Name__c = visit.Patient_Portal_Name__c
        );
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

    public static void processPendingInitialVisits(List<Patient_Visit__c> patientVisits) {
        Boolean needsUpdate = false;
        for (Patient_Visit__c pv : patientVisits) {
            if (
                pv.Is_Pre_Enrollment_Patient_Visit__c &&
                (pv.Status__c == 'Pending' ||
                pv.Status__c == 'Scheduled') &&
                pv.Planned_Date__c != null &&
                pv.Planned_Date__c < DateTime.now()
            ) {
                //pv.Status__c = 'Missed';
                needsUpdate = true;
                pv.Status__c = 'Missed';
            }
        }
        if (needsUpdate) {
            DMLService.updateRecords(patientVisits);
        }
    }

    @AuraEnabled
    public static List<Icon_Details__c> getVisitIcons(Id visitId) {
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        List<Patient_Visit__c> visits = [
            SELECT Id, Visit__c, Visit__r.Visit_Plan__c, Completed_Date__c, Visit__r.Icons__c
            FROM Patient_Visit__c
            WHERE Id = :visitId
        ];
        for (Patient_Visit__c visit : visits) {
            if (visit.Visit__c != null && visit.Visit__r.Visit_Plan__c != null) {
                visitPlanId = visit.Visit__r.Visit_Plan__c;
                break;
            }
        }
        String icons;
        List<String> iconNames = new List<String>();
        if (visits[0].Visit__c != null) {
            icons = visits[0].Visit__r.Icons__c;
            if (visits[0].Visit__r != null && visits[0].Visit__r.Icons__c != null)
                iconNames = visits[0].Visit__r.Icons__c.split(';');
        }
        iconDetails = [
            SELECT Id, Name, Label__c
            FROM Icon_Details__c
            WHERE Label__c IN :iconNames AND Visit_Plan__c = :visitPlanId
        ];
        TranslateHelper.translate(iconDetails);
        return iconDetails;
    }

    public class VisitWrapper {
        @AuraEnabled
        public String completedOrPlannedDate;
        @AuraEnabled
        public Datetime visitDate;
        @AuraEnabled
        public String icons;
        @AuraEnabled
        public List<Icon_Details__c> iconDetails;
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Datetime reminderDate;
        @AuraEnabled
        public Patient_Visit__c visit;
        @AuraEnabled
        public String visitStatus;

        public VisitWrapper(
            Patient_Visit__c visit,
            Task task,
            Map<String, Icon_Details__c> iconDetailsMap
        ) {
            this.visit = visit;
            this.visitStatus = TranslateHelper.getPickListLabel(
                Patient_Visit__c.Status__c,
                visit.Status__c
            );
            iconDetails = new List<Icon_Details__c>();
            if (visit.Visit__c != null) {
                icons = visit.Visit__r.Icons__c;

                List<String> iconNames = new List<String>();
                if (visit.Visit__r != null && visit.Visit__r.Icons__c != null)
                    iconNames = visit.Visit__r.Icons__c.split(';');

                if (!iconNames.isEmpty()) {
                    for (String iconName : iconNames) {
                        if (iconDetailsMap.containsKey(iconName)) {
                            iconDetails.add(iconDetailsMap.get(iconName));
                        }
                    }
                }
            }

            this.task = task;
            if (task != null && task.ReminderDateTime != null) {
                this.reminderDate = task.ReminderDateTime;
            }
            /*completedOrPlannedDate = visit.Completed_Date__c != null
                ? String.valueOf(visit.Completed_Date__c)
                : (visit.Planned_Date__c != null
                      ? String.valueOf(visit.Planned_Date__c)
                      : Label.Study_Visit_Unavailable);*/
            if (visit.Completed_Date__c != null) {
                visitDate = visit.Completed_Date__c;
            } else if (visit.Planned_Date__c != null) {
                visitDate = visit.Planned_Date__c;
            } else {
                completedOrPlannedDate = Label.Study_Visit_Unavailable;
            }
        }
    }
}
