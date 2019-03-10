/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {

    @AuraEnabled
    public static String getInitData() {
        try {
            InitData initData = new InitData();
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Integer createTasks(Task task, List<String> selectedStatus, ManualTaskFilter filter) {
        try {
            Set<Id> participantIds = new Set<Id>();


            if (selectedStatus.contains('Enrolled')) {
                String query = 'SELECT Participant_Study_Enrollment__c WHERE Status__c = \'Enrolled\'';
                query += filter.getFiltersQuery();

                List<Participant_Study_Enrollment__c> participantStudyEnrollment =
                        (List<Participant_Study_Enrollment__c>) Database.query(query);

                Set<Id> participantContactIds = new Set<Id>();
                for(Participant_Study_Enrollment__c pse : participantStudyEnrollment)
                    participantContactIds.add(pse.Participant__r.Contact__c);
            }


            //For toast after onclick
            return 0;//participantIds.size();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Date addDays(Date dateStart, Integer count) {
        try {
            return dateStart.addDays(count);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Date checkAndGetValidDate(Date start, Date due) {
        try {
            if (due.dayOfYear() >= start.dayOfYear())
                return due; else
                    return start;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class InitData {
        public List<String> priorities = new List<String>();

        public InitData() {
            for (TaskPriorityEnum priority : TaskPriorityEnum.values())
                priorities.add(priority.name());
        }
    }
}