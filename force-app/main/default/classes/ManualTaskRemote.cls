/**
 * Created by Igor Malyuta on 01.03.2019.
 */

public with sharing class ManualTaskRemote {

    public static Boolean createTasks(Task newTask, ManualTaskFilter filter) {
        try {
            if(newTask.ActivityDate != null) {
                newTask.Activity_Datetime__c = Datetime.newInstanceGmt(
                        newTask.ActivityDate,
                        Time.newInstance(Datetime.now().hourGmt(), 0, 0, 0));
            }

            if(newTask.ReminderDateTime != null) {
                newTask.ReminderDateTime = Datetime.newInstanceGmt(
                        newTask.Reminder_Date__c.yearGmt(),
                        newTask.Reminder_Date__c.monthGmt(),
                        newTask.Reminder_Date__c.dayGmt(),
                        Datetime.now().hourGmt(), 0, 0
                );
            }
            
            Batch_CreateAdminTasks.launch(filter.getContactsWithPE(), newTask);
            return true;
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }

    public class TaskPanelWrapper {
        @AuraEnabled public Task task;
        @AuraEnabled public Date nowDate;
        @AuraEnabled public List<LabelValueItem> priorities;
        @AuraEnabled public List<LabelValueItem> visibility;

        public TaskPanelWrapper() {
            task = new Task();
            task.Priority = 'Normal';

            nowDate = Date.today();

            priorities = new List<LabelValueItem>();
            priorities.add(new LabelValueItem('Not selected', 'Normal'));
            priorities.add(new LabelValueItem('Critical', 'Critical'));

            visibility = new List<LabelValueItem>();
            visibility.add(new LabelValueItem('All', 'Owner;Delegates'));
            visibility.add(new LabelValueItem('Patients only', 'Owner'));
            visibility.add(new LabelValueItem('Delegates only', 'Delegates'));
        }
    }
}