Public Class PPTelevisitUpcomingTileController{
    @auraEnabled
    Public Static List<TelevisitWrapper> fetchTelevisitAttendees(List<String> lstTelevisitIds){
        List<TelevisitWrapper> lstTelevisitWrapper = new List<TelevisitWrapper>();
        List<televisitattendeeWrapper> lstTelevisitAttendeeWrapper = new List<televisitattendeeWrapper>();
        system.debug('lstTelevisitIds :'+lstTelevisitIds);
        for(Televisit__c tv : [Select Id,(SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c FROM Televisit_Attendee__r) FROM Televisit__c WHERE Id IN :lstTelevisitIds ]){
            TelevisitWrapper wrap = new TelevisitWrapper();
            lstTelevisitAttendeeWrapper = new List<televisitattendeeWrapper>();
            wrap.televisitId = tv.Id;
            wrap.numberOfParticipants = tv.Televisit_Attendee__r.size() - 1;
            wrap.televisitAttendees = tv.Televisit_Attendee__r;
            
            for(Televisit_Attendee__c ta : tv.Televisit_Attendee__r){
                //if(ta.Attendee_Type__c != 'PI'){
                    televisitattendeeWrapper taw = new televisitattendeeWrapper();
                    taw.firstname = ta.Firstname__c;
                    taw.lastname = ta.Lastname__c;
                    taw.attendeeType = ta.Attendee_Type__c;
                    lstTelevisitAttendeeWrapper.add(taw);
                //}
            }
            
            wrap.relatedAttendees = lstTelevisitAttendeeWrapper;
            lstTelevisitWrapper.add(wrap);
        }
        system.debug('lstTelevisitWrapper :'+lstTelevisitWrapper);
        return lstTelevisitWrapper;
    }
    
    Public Class TelevisitWrapper{
        @auraEnabled Public String televisitId;
        @auraEnabled Public Integer numberOfParticipants;
        @auraEnabled Public List<Televisit_Attendee__c> televisitAttendees;
        @AuraEnabled public List<televisitattendeeWrapper> relatedAttendees;
    }
    
    public class televisitattendeeWrapper{
        @AuraEnabled public string firstname;
        @AuraEnabled public string lastname;
        @AuraEnabled public string attendeeType;
        @AuraEnabled public boolean organiger = false;
    }
    
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    @AuraEnabled
    public static String getVisits(String communityMode, String userMode) {
    
        participantservice.participantstate pstate = ((participantservice) classfactory.newinstance(participantservice.class)).getState(); 
        system.debug('+++++++++pstate'+pstate);
        String ctpId;
        if(pstate != null && pstate.pe != null){
            ctpId = pstate.pe.Clinical_Trial_Profile__c;
        }
    
        Datetime currentDateTime = Datetime.now();
        Datetime next24HoursDateTime = Datetime.now().addHours(24);
        List<Televisit_Attendee__c> allVisitis = [
            SELECT
                Televisit__r.Id,
                Televisit__r.Title__c,
                Televisit__r.Visit_Date_Time__c,
                Televisit__r.Visit_Link_Activation_End_Time__c,
                Televisit__r.Visit_Link_Activation_Start_Time__c,
                Televisit__r.Meeting_URL__c,
                Televisit__r.Participant_Enrollment__r.Participant_Name__c,
                Televisit__r.Duration__c,
                Televisit__r.Visit_End_Date_Time__c,
                Attendee_Type__c,
                Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c,
                Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c,
                Televisit__r.Source_Community__c 
            FROM Televisit_Attendee__c
            WHERE
                User__c = :UserInfo.getUserId()
                AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime
                //AND Televisit__r.Visit_Link_Activation_End_Time__c <= :next24HoursDateTime
                AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c = :ctpId
                AND Televisit__r.Status__c = 'Scheduled'
            ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3
        ];
        
        
        List<Televisit_Attendee__c> visits = new List<Televisit_Attendee__c> ();
        for(Televisit_Attendee__c attendee : allVisitis){
            if(userMode != 'Participant' && attendee.Televisit__r.Source_Community__c == communityMode && (attendee.Attendee_Type__c != 'Participant' && attendee.Attendee_Type__c != 'Participant Delegate')){
                visits.add(attendee);
            }
            if(userMode == 'Participant' && (attendee.Attendee_Type__c == 'Participant' || attendee.Attendee_Type__c == 'Participant Delegate')){
                visits.add(attendee);
            }
        }
        return JSON.serialize(visits);
    }
}