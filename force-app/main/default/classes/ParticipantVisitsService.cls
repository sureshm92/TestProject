public with sharing class ParticipantVisitsService {

    public static final String VISIT_MODE_CURRENT = 'Current';
    public static final String VISIT_MODE_PAST = 'Past';
    public static final String VISIT_STATUS_PENDING = 'Pending';

    public List<VisitWrapper> getVisitWrappers(String visitMode) {
        if(VISIT_MODE_CURRENT == visitMode) {
            return getVisitWrappers(VisitService.getInstance().getVisits(' AND Status__c = \'' + VISIT_STATUS_PENDING + '\''));
        } else if(VISIT_MODE_PAST == visitMode) {
            return getVisitWrappers(VisitService.getInstance().getVisits(' AND Status__c != \'' + VISIT_STATUS_PENDING + '\''));
        } else {
            return new List<VisitWrapper>();
        }
    }

    private List<VisitWrapper> getVisitWrappers(List<Visit__c> visits) {

        Set<Id> uniqueId = new Set<Id>();
        List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
        for(Visit__c singleVisit : visits) {
            if(uniqueId.add(singleVisit.Id)) {
                visitWrappers.add(new VisitWrapper(singleVisit));
            }
        }
        return visitWrappers;
    }

    public class VisitWrapper {

        @AuraEnabled
        public String completedDate;
        @AuraEnabled
        public Visit__c visit;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String timeplane;
        @AuraEnabled
        public String icons;
        @AuraEnabled
        public Boolean isAdhoc;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Task task;

        public VisitWrapper(Visit__c visit) {
            this.visit = visit;
            this.timeplane = visit.Timeplane__c;
            this.icons = visit.Visit__r.Icons__c;
            this.isAdhoc = visit.Is_Adhoc__c;
            this.status = visit.Status__c;

            if(!ParticipantVisitsDecoupler.getVisitTasks(visit).isEmpty()) {
                this.task = ParticipantVisitsDecoupler.getVisitTasks(visit)[0];
            }
            this.completedDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
        }
    }
}