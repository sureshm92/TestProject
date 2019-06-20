public inherited sharing class ParticipantVisitsDecoupler {

    @TestVisible
    private static Map<Id, List<Task>> tasksByVisitIds = new Map<Id, List<Task>>();

    public static List<Task> getVisitTasks(Visit__c visit) {
        return tasksByVisitIds.get(visit.Id) == null ?
                visit.Tasks :
                tasksByVisitIds.get(visit.Id);
    }
}