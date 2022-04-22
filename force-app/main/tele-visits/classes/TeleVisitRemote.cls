public without sharing class TeleVisitRemote {
    @TestVisible
    @AuraEnabled
    public static List<TelevisitWrapper> getVisits(String visitMode) {
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(
                ParticipantService.class
            ))
            .getState();
        if (pState == null || pState.pe == null)
            return null;

        List<Televisit__c> teleVisits = [
            SELECT
                Id,
                Name,
                Title__c,
                Duration__c,
                Start_Time__c,
                Visit_Date__c,
                (SELECT Id, Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r)
            FROM Televisit__c
            WHERE Participant_Enrollment__c = :pState.pe.Id AND Status__c = :visitMode
            ORDER BY Visit_Date__c, Start_Time__c
        ];
        if (teleVisits.size() > 0) {
            List<TelevisitWrapper> televisitWrappersList = new List<TelevisitWrapper>();
            for (Televisit__c teleObj : teleVisits) {
                String attendeename = '';

                for (Televisit_Attendee__c tobj : teleObj.Televisit_Attendee__r) {
                    attendeename +=
                        ' ' +
                        (tobj.Firstname__c != null ? tobj.Firstname__c : '') +
                        ' ' +
                        (tobj.Lastname__c != null ? tobj.Lastname__c : '') +
                        (tobj.Attendee_Type__c != null ? '(' : '') +
                        (tobj.Attendee_Type__c != null ? tobj.Attendee_Type__c : '') +
                        (tobj.Attendee_Type__c != null ? '),' : '');
                }
                TelevisitWrapper tvWrapperObj = new TelevisitWrapper();
                tvWrapperObj.tvId = teleObj.Id;
                tvWrapperObj.title = teleObj.Title__c;
                tvWrapperObj.visitDate = teleObj.Visit_Date__c;
                tvWrapperObj.duration = teleObj.Duration__c;
                tvWrapperObj.visitTime = teleObj.Start_Time__c;
                tvWrapperObj.attendeeList = attendeename.removeEnd(',').trim();
                televisitWrappersList.add(tvWrapperObj);
            }
            return televisitWrappersList;
        } else
            return new List<TelevisitWrapper>();
    }

    public class TelevisitWrapper {
        @AuraEnabled
        public Id tvId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Date visitDate;
        @AuraEnabled
        public Time visitTime;
        @AuraEnabled
        public String duration;
        @AuraEnabled
        public String attendeeList;
    }
}
