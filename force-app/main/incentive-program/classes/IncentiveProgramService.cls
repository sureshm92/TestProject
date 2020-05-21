/**
 * Created by Andrii Kryvolap.
 */

public without sharing class IncentiveProgramService {

    private static Map<String, Incentive_Task_Catalog__mdt> taskCatalogMap;
    private static Map<Id, List<Incentive_Plan_Task__c>> studySiteEnabledTasksMap;

    private static void initTaskCatalogMap(){
        taskCatalogMap = new Map<String, Incentive_Task_Catalog__mdt>();
        for(Incentive_Task_Catalog__mdt taskCatalog : [
                SELECT DeveloperName, Title_Label__c, Default_Number_of_Points__c, Description_Label__c,
                        History_Description_Label__c
                FROM Incentive_Task_Catalog__mdt]){
            taskCatalogMap.put(taskCatalog.DeveloperName, taskCatalog);
        }
    }

    public static void initStudySiteEnabledTasksMap(){
        studySiteEnabledTasksMap = new Map<Id, List<Incentive_Plan_Task__c>>();
        Map<Id, List<Incentive_Plan_Task__c>> tasksMapByPlanIds = new Map<Id, List<Incentive_Plan_Task__c>>();

        for (Incentive_Plan_Task__c enabledTask : [
                SELECT Id, Points__c, Incentive_Task_Catalog__c, Incentive_Plan__c
                FROM Incentive_Plan_Task__c
                WHERE Enabled__c = TRUE
                ORDER BY Points__c ASC
        ]){
            if (!tasksMapByPlanIds.containsKey(enabledTask.Incentive_Plan__c)) {
                tasksMapByPlanIds.put(enabledTask.Incentive_Plan__c, new List<Incentive_Plan_Task__c>());
            }
            tasksMapByPlanIds.get(enabledTask.Incentive_Plan__c).add(enabledTask);
        }

        for(Study_Incentive_Plan__c sip: [SELECT Id, Incentive_Plan__c, Study_Site__c FROM Study_Incentive_Plan__c WHERE Incentive_Plan__c IN :tasksMapByPlanIds.keySet()]){
            if (!studySiteEnabledTasksMap.containsKey(sip.Study_Site__c)) {
                studySiteEnabledTasksMap.put(sip.Study_Site__c, new List<Incentive_Plan_Task__c>());
            }
            studySiteEnabledTasksMap.get(sip.Study_Site__c).addAll(tasksMapByPlanIds.get(sip.Incentive_Plan__c));
        }
    }

    public static Map<String, Incentive_Task_Catalog__mdt> getTaskCatalogMap(){
        if(taskCatalogMap == null){
            initTaskCatalogMap();
        }
        return taskCatalogMap;
    }

    public static Map<Id,List< Incentive_Plan_Task__c>> getStudySiteEnabledTasksMap(){
        if(studySiteEnabledTasksMap == null){
            initStudySiteEnabledTasksMap();
        }
        return studySiteEnabledTasksMap;
    }

    public static PointsResultWrapper getCurrentContactPoints(Datetime timeStamp){
        return getContactPoints(UserContext.getUserContactId(), timeStamp);
    }

    public static PointsResultWrapper getContactPoints(Id contactId, Datetime timeStamp){
        PointsResultWrapper result = new PointsResultWrapper();
        for (Completed_Incentive_Task__c task : [SELECT Id, Points__c, Completed_Date__c FROM Completed_Incentive_Task__c WHERE Completed_By__c =:contactId]){
            result.totalPoints += Math.round(task.Points__c);
            if(task.Completed_Date__c >= timeStamp){
                result.lastPoints += Math.round(task.Points__c);
            }
        }
        result.hasEnabledTasks = getInitialIncentivePlanResultWrapper().studySitesOptions.size() > 0;
        return result;
    }

    public static void completeIncentiveTaskCurrentContact(String taskName, Id ssId, String completedFor){
        completeIncentiveTask(UserContext.getUserContactId(), taskName, ssId, completedFor);
    }

    public static void completeIncentiveTaskCurrentContact(String taskName, Id ssId){
        completeIncentiveTask(UserContext.getUserContactId(), taskName, ssId, null);
    }

    public static void completeIncentiveTask(Id contactId, String taskName, Id ssId){
        completeIncentiveTask(contactId, taskName, ssId, null);
    }

    public static void completeIncentiveTask(Id contactId, String taskName, Id ssId, String completedFor){
        Incentive_Plan_Task__c incentivePlanTask = getIncentivePlanTask(taskName, ssId);
        if (incentivePlanTask != null && incentivePlanTask.Enabled__c) {
            Completed_Incentive_Task__c completedIncentiveTask = new Completed_Incentive_Task__c();
            completedIncentiveTask.Completed_By__c = contactId;
            completedIncentiveTask.Completed_Date__c = Datetime.now();
            completedIncentiveTask.Incentive_Task_Catalog__c = taskName;
            completedIncentiveTask.Points__c = incentivePlanTask.Points__c;
            completedIncentiveTask.Completed_For__c = completedFor;
            insert completedIncentiveTask;
        }
    }

    public static Incentive_Plan_Task__c getIncentivePlanTask(String taskName, Id ssId){
        Set<Id> planIds = new Set<Id>();
        for (Study_Incentive_Plan__c studyIncentivePlan : [
                SELECT Id, Incentive_Plan__c, Clinical_Trial_Profile__c, Study_Site__c
                FROM Study_Incentive_Plan__c
                WHERE Study_Site__c = :ssId
        ]){
            planIds.add(studyIncentivePlan.Incentive_Plan__c);
        }
        if (!planIds.isEmpty()) {
            List<Incentive_Plan_Task__c> incentiveTasks = [
                    SELECT Id,Points__c, Enabled__c, IQVIA_Supported__c
                    FROM Incentive_Plan_Task__c
                    WHERE Incentive_Plan__c IN :planIds AND Incentive_Task_Catalog__c = :taskName
            ];
            if (incentiveTasks.isEmpty()) {
                return null;
            }
            else{
                return incentiveTasks[0];
            }
        }
        else{
            return null;
        }

    }

    public static IncentiveHistoryWrapper getCurrentContactIncentiveHistory(){
        IncentiveHistoryWrapper result = new IncentiveHistoryWrapper();
        for (Completed_Incentive_Task__c completedTask : [
                SELECT Id, Incentive_Task_Catalog__c, Points__c, Completed_Date__c, Completed_By__c, Completed_For__c
                FROM Completed_Incentive_Task__c
                WHERE Completed_By__c = :UserContext.getUserContactId()
                ORDER BY Completed_Date__c DESC ]){
            result.totalPoints += Math.round(completedTask.Points__c);
            result.completedTasks.add(new CompletedTaskWrapper(completedTask));
        }
        return result;
    }

    public static IncentivePlanResultWrapper getIncentivePlanResultWrapperForStudySite(Id ssId){
        return new IncentivePlanResultWrapper(null, getTaskMapForStudySite(ssId));
    }

    public static IncentivePlanResultWrapper getInitialIncentivePlanResultWrapper(){
        List<Study_Site__c> studySites = StudySiteService.getStudySitesForPI();
        List<LabelValueItem> studySiteLVL = new List<LabelValueItem>();
        for(Study_Site__C ss: studySites){
            if (getStudySiteEnabledTasksMap().containsKey(ss.Id)) {
                studySiteLVL.add(new LabelValueItem(ss.Name, ss.Id));
            }
        }
        if(!studySiteLVL.isEmpty()){
            return new IncentivePlanResultWrapper(studySiteLVL, getTaskMapForStudySite(studySiteLVL[0].value));
        }
        else{
            return new IncentivePlanResultWrapper(studySiteLVL, getTaskMapForStudySite(null));
        }

    }

    public static Map<Integer, Set<Incentive_Task_Catalog__mdt>> getTaskMapForStudySite(Id ssId){
        Map<Integer, Set<Incentive_Task_Catalog__mdt>> result = new Map<Integer, Set<Incentive_Task_Catalog__mdt>>();
        if (getStudySiteEnabledTasksMap().containsKey(ssId)) {
            for (Incentive_Plan_Task__c task : getStudySiteEnabledTasksMap().get(ssId)){
                Integer points = Math.round(task.Points__c);
                if(getTaskCatalogMap().containsKey(task.Incentive_Task_Catalog__c)){
                    if(!result.containsKey(points)){
                        result.put(points, new Set<Incentive_Task_Catalog__mdt>());
                    }
                    result.get(points).add(getTaskCatalogMap().get(task.Incentive_Task_Catalog__c));
                }
            }
        }

        return result;
    }

    public class PointsResultWrapper{
        @AuraEnabled public Integer totalPoints = 0;
        @AuraEnabled public Integer lastPoints = 0;
        @Auraenabled public Boolean hasEnabledTasks = false;
    }

    public class IncentiveHistoryWrapper{
        @AuraEnabled public Integer totalPoints = 0;
        @AuraEnabled public List<CompletedTaskWrapper> completedTasks = new List<CompletedTaskWrapper>();
    }

    public class IncentivePlanGroupWrapper{
        @AuraEnabled public Integer points = 0;
        @AuraEnabled public List<String> tasksDescription = new List<String>();

        public IncentivePlanGroupWrapper(Integer points, Set<Incentive_Task_Catalog__mdt> tasks){
            this.points =  points;
            for(Incentive_Task_Catalog__mdt task: tasks){
                this.tasksDescription.add(TranslateHelper.getLabelValue(task.Description_Label__c));
            }
        }
    }

    public class IncentivePlanResultWrapper{
        @AuraEnabled public List<LabelValueItem> studySitesOptions = new List<LabelValueItem>();
        @AuraEnabled public List<IncentivePlanGroupWrapper> tasksGroups = new List<IncentivePlanGroupWrapper>();

        public IncentivePlanResultWrapper(List<LabelValueItem> studySitesOptions, Map<Integer, Set<Incentive_Task_Catalog__mdt>> tasksMap){
            this.studySitesOptions =  studySitesOptions;
            for(Integer points: tasksMap.keySet()){
                this.tasksGroups.add(new IncentivePlanGroupWrapper(points, tasksMap.get(points)));
            }
        }
    }

    public class CompletedTaskWrapper{

        @AuraEnabled public Integer points;
        @AuraEnabled public String dateCompleted;
        @AuraEnabled public String description;
        @AuraEnabled public String id;

        public CompletedTaskWrapper(Completed_Incentive_Task__c completedTask){
            this.dateCompleted = completedTask.Completed_Date__c.date().format();
            this.points = Math.round(completedTask.Points__c);
            if(getTaskCatalogMap().containsKey(completedTask.Incentive_Task_Catalog__c)){
                this.description = TranslateHelper.getLabelValue(getTaskCatalogMap().get(completedTask.Incentive_Task_Catalog__c).History_Description_Label__c).replace('##ItemName', String.isBlank(completedTask.Completed_For__c)?'':completedTask.Completed_For__c);
            }
            this.id = completedTask.Id;

        }
    }

}