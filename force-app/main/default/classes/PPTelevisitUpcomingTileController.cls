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
}