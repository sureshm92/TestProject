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
        String query = 'SELECT Id, Name,Title__c, Duration__c, Status__c,Start_Time__c, Visit_Date__c, Visit_Date_Time__c,Participant_Enrollment__r.Study_Site__c,(SELECT Id, Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c WHERE Participant_Enrollment__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c =TRUE AND Participant_Enrollment__c = :peId ';
        if (String.isNotBlank(visitMode)) {
            query += '  AND Status__c = :visitMode ';
        }
        query += ' ORDER BY Visit_Date_Time__c';
        if (visitMode != 'Scheduled'){
            query += ' DESC';
           }
        List<Televisit__c> teleVisits = Database.query(query);
        return generateVisitWrappers(teleVisits);
    }

    @AuraEnabled
    public static List<TelevisitWrapper> getTeleVisits(String visitMode) {
        ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
        String query;
        if (state.pe != null) {
            String peId = state.pe.Id;
            query = 'SELECT Id,Name,Title__c,Duration__c,Start_Time__c,Visit_Date__c,Visit_Date_Time__c,Status__c,Participant_Enrollment__r.Study_Site__c,(SELECT Id,Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c where Participant_Enrollment__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c =TRUE AND Participant_Enrollment__c = :peId';
        } else {
        String contactId = state.currentContactId;
            query = 'SELECT Id,Name,Title__c,Duration__c,Start_Time__c,Visit_Date__c,Visit_Date_Time__c,Status__c,Participant_Enrollment__r.Study_Site__c,(SELECT Id,Firstname__c, Lastname__c, Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c where Participant_Enrollment__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c =TRUE AND Id in (SELECT Televisit__c FROM Televisit_Attendee__c WHERE Contact__c =:contactId)';
        }
        if (String.isNotBlank(visitMode)) {
            query += '  AND Status__c = :visitMode ';
        }
        query += ' ORDER BY Visit_Date_Time__c';
       if (visitMode != 'Scheduled'){
        query += ' DESC';
       }
        List<Televisit__c> teleVisits = Database.query(query);
        return generateVisitWrappers(teleVisits);
    }

    public static List<TelevisitWrapper> generateVisitWrappers(List<Televisit__c> televisits) {
        List<Televisit__c> filteredTelevisits = new List<Televisit__c>();
        List<Id> studySiteIds = new List<Id>();
        for (Televisit__c telObj : televisits) {
            studySiteIds.add(telObj.Participant_Enrollment__r.Study_Site__c);
        }
        Map<Id, Study_Site__c> ssMap = new Map<Id, Study_Site__c>(
            [
                SELECT Id
                FROM Study_Site__c
                WHERE
                    Id IN (
                        SELECT Study_Site__c
                        FROM TelevisitVendorSettings__c
                        WHERE
                            isEnable__c = TRUE
                            AND Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c = TRUE
                            AND Study_Site__c = :studySiteIds
                    )
            ]
        );
        for (Televisit__c telObj : televisits) {
            if (
                ssMap.size() > 0 &&
                ssMap.containsKey(telObj.Participant_Enrollment__r.Study_Site__c)
            ) {
                filteredTelevisits.add(telObj);
            }
        }

        if (filteredTelevisits.size() > 0) {
            TranslateHelper.translate(filteredTelevisits);
            List<TelevisitWrapper> televisitWrappersList = new List<TelevisitWrapper>();
            for (Televisit__c teleObj : filteredTelevisits) {
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
