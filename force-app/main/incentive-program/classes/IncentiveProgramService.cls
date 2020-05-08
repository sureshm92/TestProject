/**
 * Created by Andrii Kryvolap.
 */

public without sharing class IncentiveProgramService {

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
        return result;
    }

    public static void completeIncentiveTaskCurrentContact(String taskName, Id ctpId, Id peId){
        completeIncentiveTask(UserContext.getUserContactId(), taskName, ctpId, peId);
    }

    public static void completeIncentiveTaskCurrentContact(String taskName, Id ctpId){
        completeIncentiveTask(UserContext.getUserContactId(), taskName, ctpId, null);
    }

    public static void completeIncentiveTask(Id contactId, String taskName, Id ctpId){
        completeIncentiveTask(contactId, taskName, ctpId, null);
    }

    public static void completeIncentiveTask(Id contactId, String taskName, Id ctpId, Id peId){
        Incentive_Plan_Task__c incentivePlanTask = getIncentivePlanTask(taskName, ctpId);
        if (incentivePlanTask != null && incentivePlanTask.Enabled__c) {
            Completed_Incentive_Task__c completedIncentiveTask = new Completed_Incentive_Task__c();
            completedIncentiveTask.Completed_By__c = contactId;
            completedIncentiveTask.Completed_Date__c = Datetime.now();
            completedIncentiveTask.Incentive_Task_Catalog__c = taskName;
            completedIncentiveTask.Points__c = incentivePlanTask.Points__c;
        }
    }

    public static Incentive_Plan_Task__c getIncentivePlanTask(String taskName, Id ctpId){
        Set<Id> planIds = new Set<Id>();
        for (Study_Incentive_Plan__c studyIncentivePlan : [
                SELECT Id, Incentive_Plan__c, Clinical_Trial_Profile__c
                FROM Study_Incentive_Plan__c
                WHERE Clinical_Trial_Profile__c = :ctpId
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

    public class PointsResultWrapper{
        @AuraEnabled public Integer totalPoints = 0;
        @AuraEnabled public Integer lastPoints = 0;
    }
}