Public without sharing Class PPTelevisitUpcomingTileController{
    @auraEnabled
    Public Static Boolean CheckIfTelevisitToggleOnForDelegate(){
        String userId = UserInfo.getUserId();
        List<User> lstUsr = [SELECT ContactId FROM User WHERE Id =:userId limit 1];
        Boolean televisitVendorAvailable = false;
        
        for(Patient_Delegate__c pd : [SELECT Id,Contact__c,Name,Participant__c,Participant__r.Contact__r.LastName,Participant__r.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c FROM Patient_Delegate__c WHERE Contact__c =:lstUsr[0].ContactId ]){
            if(pd.Participant__r.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c){
                televisitVendorAvailable = true;
                break;
            }else{
                televisitVendorAvailable = false;
            }
        }
        
        return televisitVendorAvailable;
        
    }
    
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
        String userId = UserInfo.getUserId();
        participantservice.participantstate pstate = ((participantservice) classfactory.newinstance(participantservice.class)).getState(); 
        String ctpId = '';
        
        if(pstate != null && pstate.pe != null){
            ctpId = pstate.pe.Clinical_Trial_Profile__c;
        }
    
        Datetime currentDateTime = Datetime.now();
        Datetime next24HoursDateTime = Datetime.now().addHours(24);
        String query = 'SELECT Televisit__r.Id,Televisit__r.Participant_Enrollment__r.Participant__r.Salutation__c,Televisit__r.Title__c,Televisit__r.Visit_Date_Time__c,Televisit__r.Visit_Link_Activation_End_Time__c,Televisit__r.Visit_Link_Activation_Start_Time__c,Televisit__r.Meeting_URL__c,Televisit__r.Participant_Enrollment__r.Participant_Name__c,Televisit__r.Duration__c,Televisit__r.Visit_End_Date_Time__c,Attendee_Type__c,Televisit__r.Participant_Enrollment__r.PI_Contact__r.Salutation_With_Name__c,Televisit__r.Participant_Enrollment__r.Participant__r.Full_Name__c,Televisit__r.Source_Community__c,Televisit__r.Participant_Enrollment__r.Study_Site__c FROM Televisit_Attendee__c';
        Boolean delegateOrAlumni = false;
        
        if(ctpId != ''){
            String peId = pstate.pe.Id;
            query += ' WHERE Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Status__c = \'Scheduled\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
        }else{
            delegateOrAlumni = true;
            query += ' WHERE User__c = :userId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
        }
        
        List<Televisit_Attendee__c> allVisitis = Database.query(query);
        
        if(delegateOrAlumni){
            List<Televisit_Attendee__c> filteredTelevisits = new List<Televisit_Attendee__c>();
            Set<Id> studySiteIds = new Set<Id>();
            Set<Id> actualStudySiteIds = new Set<Id>();
            for (Televisit_Attendee__c telattendeeObj : allVisitis) {
                system.debug('allVisitis :'+telattendeeObj.Televisit__r.Participant_Enrollment__r.Study_Site__c);
                studySiteIds.add(telattendeeObj.Televisit__r.Participant_Enrollment__r.Study_Site__c);
            }
            for(TelevisitVendorSettings__c lstTVS :[SELECT Id,Study_Site__c FROM TelevisitVendorSettings__c  WHERE isEnable__c = TRUE AND Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c = TRUE AND Study_Site__c IN:studySiteIds]){
                actualStudySiteIds.add(lstTVS.Study_Site__c);
            }
            
            for (Televisit_Attendee__c telattendeeObj : allVisitis) {
                if (actualStudySiteIds.contains(telattendeeObj.Televisit__r.Participant_Enrollment__r.Study_Site__c)){
                    filteredTelevisits.add(telattendeeObj);
                }
            }
            allVisitis.clear();
            allVisitis.addAll(filteredTelevisits);
        }
        
        
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