public without sharing class TeleVisitRemote {
    @TestVisible
    @AuraEnabled
    public static List<TelevisitWrapper> getVisits(String visitMode, Boolean isAlumniOrDelegate) {
        if (isAlumniOrDelegate != null && isAlumniOrDelegate) {
            return getTeleVisits(visitMode);
        }
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(
                ParticipantService.class
            ))
            .getState();
        if (pState == null || pState.pe == null)
            return new List<TelevisitWrapper>();
        String peId = pState.pe.Id;
        String query = 'SELECT Id, Name,Title__c, Duration__c, Status__c,Start_Time__c, Visit_Date__c, Visit_Date_Time__c,(SELECT Id, Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c WHERE Participant_Enrollment__c = :peId ';
        if (String.isNotBlank(visitMode)) {
            query += '  AND Status__c = :visitMode ';
        }
        query += ' ORDER BY Visit_Date_Time__c';
        List<Televisit__c> teleVisits = Database.query(query);
        return generateVisitWrappers(teleVisits);
    }

    @AuraEnabled
    public static List<TelevisitWrapper> getTeleVisits(String visitMode) {
        ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
        String contactId = state.currentContactId;
        String query = 'SELECT Id,Name,Title__c,Duration__c,Start_Time__c,Visit_Date__c,Visit_Date_Time__c,Status__c,(SELECT Id,Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c where Id in (SELECT Televisit__c FROM Televisit_Attendee__c WHERE Contact__c =:contactId)';
        if (String.isNotBlank(visitMode)) {
            query += '  AND Status__c = :visitMode ';
        }
        query += ' ORDER BY Visit_Date_Time__c';
        List<Televisit__c> teleVisits = Database.query(query);
        return generateVisitWrappers(teleVisits);
    }

    public static List<TelevisitWrapper> generateVisitWrappers(List<Televisit__c> televisits) {
        if (teleVisits.size() > 0) {
            TranslateHelper.translate(teleVisits);
            List<TelevisitWrapper> televisitWrappersList = new List<TelevisitWrapper>();
            for (Televisit__c teleObj : teleVisits) {
                if (teleObj.Televisit_Attendee__r.size() <= 0) {
                    continue;
                }
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
                tvWrapperObj.visitStatus = teleObj.Status__c;
                tvWrapperObj.visitDateTime = teleObj.Visit_Date_Time__c;
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
        public Datetime visitDateTime;
        @AuraEnabled
        public String duration;
        @AuraEnabled
        public String attendeeList;
        @AuraEnabled
        public String visitStatus;
    }
}
