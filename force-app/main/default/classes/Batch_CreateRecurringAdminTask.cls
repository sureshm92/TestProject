public class Batch_CreateRecurringAdminTask extends Batch_ScheduledAbstract {
    private String query;
    private Map<Id, List<Id>> failedContactsWithWhatIds;
    private List<Manual_Creation_Panel_Task__c> manualConfigList;
    private Id userId;
    private Integer taskCreated;
    
    public Batch_CreateRecurringAdminTask() {
        this.query = 'Select Recurrence_End_Date__c, Last_Recurrence_Reminder__c, Status__c, Start_Date__c, Next_Due_Date__c, Next_Reminder_Date__c, Next_Occurence_Date__c, Last_Occurrence_Date__c, TaskConfig__c, TaskFilter__c from Manual_Creation_Panel_Task__c where Status__c = \'Active\' and Next_Occurence_Date__c <= '+Datetime.now().format('yyyy-MM-dd', 'GMT');
        this.manualConfigList = new List<Manual_Creation_Panel_Task__c>();
        this.failedContactsWithWhatIds = new Map<Id, List<Id>>();
        this.userId = UserInfo.getUserId();
        this.taskCreated = 0;
    }
    
    public Database.QueryLocator start(Database.BatchableContext param) {
       return Database.getQueryLocator(this.query);
    }
    
    public void execute(Database.BatchableContext param, List<Manual_Creation_Panel_Task__c> manualTasks) {
        Map<Id, List<Id>> whatIdByContactIds = new Map<Id, List<Id>>();
        set<id> contactWithoutUser = new set<Id>();
        Map<id,String> idTypeOfContactMap = new Map<id,String>();
        
        ManualTaskFilter filter = (ManualTaskFilter) JSON.deserialize(
            manualTasks[0].TaskFilter__c,
            ManualTaskFilter.class
        );
        TaskService.TaskConfig taskConfig = (TaskService.TaskConfig) JSON.deserialize(
            manualTasks[0].TaskConfig__c,
            TaskService.TaskConfig.class
        );
        taskConfig.startDate = manualTasks[0].Next_Occurence_Date__c;
        taskConfig.endTime = manualTasks[0].Next_Due_Date__c;
        if(manualTasks[0].Next_Reminder_Date__c != null){
            taskConfig.reminderDate = manualTasks[0].Next_Reminder_Date__c;
        }
        whatIdByContactIds = filter.getContactsWithWhatIds(taskConfig);
        idTypeOfContactMap = ManualTaskFilter.IdTypeOfContactMap;
        contactWithoutUser.addAll(whatIdByContactIds.keySet());
        Boolean isTasksCreated = insertTasks(
                                        whatIdByContactIds, 
                                        contactWithoutUser, 
                                        idTypeOfContactMap,
            							taskConfig
                                    );
        if(isTasksCreated){
            updateManualTaskConfig(manualTasks[0], taskConfig);
        }                          
    }
    
    public override void finalAction() {
        try{
            if(manualConfigList.size() != 0){
                Database.update(manualConfigList);
            }
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            List<User> user = [SELECT Id, Email FROM User WHERE Id = :userId];
            emailMessage.setToAddresses(new List<String>{ user.get(0).Email });
            emailMessage.setSubject('Batch Create Admin Task');
            
            String messageBody = 'Tasks : ' + '\n';
            messageBody +=
                'Task(s) created = ' +
                taskCreated +
                '. Task(s) failed = ' +
                (failedContactsWithWhatIds.isEmpty()
                 ? '0'
                 : '' + (failedContactsWithWhatIds.values().size() + '\n'));
            if (!failedContactsWithWhatIds.isEmpty()) {
                messageBody += 'Failed contact ids:\n';
                Integer i = 0;
                for (Id conId : failedContactsWithWhatIds.keySet()) {
                    messageBody += conId + ', ';
                    if (Math.mod(3, ++i) == 0){
                        messageBody += '\n';
                    }
                }
                messageBody = messageBody.removeEnd(', ');
            }
            
            emailMessage.setPlainTextBody(messageBody);
            Messaging.sendEmail(
                (List<Messaging.Email>) new List<Messaging.SingleEmailMessage>{ emailMessage }
            );
        }catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
    public Boolean insertTasks(
        Map<Id, List<Id>> whatIdByContactIds, 
        set<id> contactWithoutUser, 
        Map<id,String> idTypeOfContactMap,
        TaskService.TaskConfig taskConfig
    ) {
        try {
            List<User> users = [
                SELECT Id, ContactId, Name, TimeZoneSidKey
                FROM User
                WHERE
                ContactId IN :whatIdByContactIds.keySet()
                AND IsActive = TRUE
                AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
            ];
            List<Task> tasks = new List<Task>();
            for (User user : users) {
                contactWithoutUser.remove(user.ContactId);
                TimeZone userTZ = TimeZone.getTimeZone(user.TimeZoneSidKey);
                Time eodTime = Time.newInstance(23,59, 0, 0);
                Time remTime = Time.newInstance(11,30, 0, 0);
                String typeOfContactTemp = idTypeOfContactMap.get(user.ContactId);
                for (Id whatId : whatIdByContactIds.get(user.ContactId)) {
                    Datetime activityDT;
                    Integer offsetSeconds;
                    if (taskConfig.endTime != null){
                        offsetSeconds = userTZ.getOffset(taskConfig.endTime) / 1000;
                        activityDT = Datetime.newInstanceGmt(taskConfig.endTime, eodTime).addSeconds(-offsetSeconds);
                    } 
                    Datetime reminderDTGMT;
                    Datetime reminderDT;
                    if (taskConfig.reminderDate != null) {
                        reminderDTGMT = Datetime.newInstanceGmt(
                            taskConfig.reminderDate,
                            Datetime.now().timeGmt()
                        );
                        reminderDT = Datetime.newInstanceGmt(
                            taskConfig.reminderDate,
                            remTime
                        ).addSeconds(-offsetSeconds);
                    }
                    String visibleFor = taskConfig.visibility;
                    if(String.isNotBlank(typeOfContactTemp) && typeOfContactTemp.contains('Participant')){ 
                        typeOfContactTemp = typeOfContactTemp.remove('Participant');
                    }else if(String.isNotBlank(typeOfContactTemp) && typeOfContactTemp.contains('Delegate')){
                        visibleFor = 'Owner';
                    }else{
                        visibleFor = taskConfig.visibility;
                    }
                    // KK-End
                    tasks.add(
                        new Task(
                            OwnerId = user.Id,
                            Subject = taskConfig.subject,
                            Priority = taskConfig.priority,
                            Start_Date__c = taskConfig.startDate,
                            Activity_Datetime__c = activityDT,
                            ReminderDateTime = reminderDTGMT,
                            Reminder_Date__c = reminderDT,
                            Visible_For__c = VisibleFor,
                            WhatId = whatId,
                            WhoId = user.ContactId,
                            Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED,
                            CreatedByAdmin__c = true
                            
                        )
                    );
                }
            }
            List<Id> contactListOfId = new List<Id>(contactWithoutUser);
            if(!contactListOfId.isEmpty()){
                for(Id contactIds: contactListOfId){
                    for (Id whatId : whatIdByContactIds.get(contactIds)) {
                        String typeOfContactTemp = idTypeOfContactMap.get(contactIds);
                        String visibleFor = taskConfig.visibility;
                        if(String.isNotBlank(TypeOfContactTemp) && TypeOfContactTemp.contains('Participant')){ 
                            typeOfContactTemp = typeOfContactTemp.remove('Participant');
                        }else if(String.isNotBlank(typeOfContactTemp) && typeOfContactTemp.contains('Delegate')){
                            visibleFor = 'Owner';
                        }else{
                            visibleFor = taskConfig.visibility;
                        }
                        tasks.add(
                            new Task(
                                Owner_Contact__c = contactIds,
                                Subject = taskConfig.subject,
                                Priority = taskConfig.priority,
                                Start_Date__c = taskConfig.startDate,
                                Visible_For__c = VisibleFor,
                                WhatId = whatId,
                                WhoId = contactIds,
                                Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED,
                                CreatedByAdmin__c = true
                                
                            )
                        );
                    }
                }
            }
            insert tasks;
            taskCreated += tasks.size();
            return true;
        } catch (Exception e) {
            failedContactsWithWhatIds.putAll(whatIdByContactIds);
            return false;
        }
    }

    public void updateManualTaskConfig(Manual_Creation_Panel_Task__c manualTask, TaskService.TaskConfig taskConfig){
        manualTask.Last_Occurrence_Date__c = manualTask.Next_Occurence_Date__c;
        manualTask.Last_Recurrence_Reminder__c = manualTask.Next_Reminder_Date__c;
        if(taskConfig.isRecurrence){
            if(manualTask.Next_Due_Date__c != manualTask.Recurrence_End_Date__c){
                if(taskConfig.recurrenceFrequency == 'Daily'){
                manualTask.Next_Occurence_Date__c = taskConfig.startDate + 1;
                manualTask.Next_Due_Date__c = taskConfig.endTime + 1;
                }
                if(taskConfig.recurrenceFrequency == 'Weekly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addDays(7);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addDays(7);
                }
                if(taskConfig.recurrenceFrequency == 'Monthly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addMonths(1);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addMonths(1);
                }
                if(taskConfig.recurrenceFrequency == 'Yearly'){
                    manualTask.Next_Occurence_Date__c = taskConfig.startDate.addYears(1);
                    manualTask.Next_Due_Date__c = taskConfig.endTime.addYears(1);
                }
                if(manualTask.Next_Due_Date__c > manualTask.Recurrence_End_Date__c){
                    manualTask.Next_Due_Date__c = manualTask.Recurrence_End_Date__c;
                }
                manualConfigList.add(manualTask);
            }
            else{
                manualTask.Next_Occurence_Date__c = null;
                manualTask.Next_Due_Date__c = null;
                manualTask.Status__c = 'Completed';
                manualConfigList.add(manualTask);
            }
        }
    }
    public override Type getType() {
        return Batch_CreateRecurringAdminTask.class;
    }

    public override String getBatchDescription() {
        return 'This job creates recurring tasks';
    }
    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
    public override Integer getRecommendedScopeSize() {
        return 1;
    }
}