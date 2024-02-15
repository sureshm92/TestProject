Public without sharing Class PPTelevisitUpcomingTileController{
    public static list<Participant_Enrollment__c> perList= New list<Participant_Enrollment__c>();
    public static Map<Id,Participant_Enrollment__c> perForMultiRoleMap= New map<Id,Participant_Enrollment__c>();
    @auraEnabled
    Public Static Boolean CheckIfTelevisitToggleOnForDelegate(){
        String userId = UserInfo.getUserId();
        List<User> lstUsr = [SELECT ContactId FROM User WHERE Id =:userId limit 1];
        Boolean televisitVendorAvailable = false;
        Set<Id> participantIds = new Set<Id>();
        Set<Id> ssIds = new Set<Id>();
        Set<Id> actualSSIds = new Set<Id>();
        
        for(Patient_Delegate__c pd : [SELECT Participant__c FROM Patient_Delegate__c WHERE Contact__c =:lstUsr[0].ContactId ]){
            participantIds.add(pd.Participant__c);
        }  
        
        for(Participant_Enrollment__c pe : [SELECT Id,Name,Study_Site__c FROM Participant_Enrollment__c WHERE Participant__c IN :participantIds]){
            ssIds.add(pe.Study_Site__c);
        }
        
        for(TelevisitVendorSettings__c tvs :[SELECT Id,Study_Site__c FROM TelevisitVendorSettings__c  WHERE isEnable__c = TRUE AND Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c = TRUE AND Study_Site__c IN:ssIds]){
            actualSSIds.add(tvs.Study_Site__c);
        }
        
        for(Participant_Enrollment__c pe : [SELECT Id,Name,Study_Site__c,Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c FROM Participant_Enrollment__c WHERE Participant__c IN :participantIds]){
            if(pe.Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c && actualSSIds.contains(pe.Study_Site__c)){
                televisitVendorAvailable = true;
                break;
            }else{
                televisitVendorAvailable = false;
            }
        }
        
        return televisitVendorAvailable;
    }
    
    @auraEnabled
    Public Static Boolean CheckIfTelevisitToggleOnForAlumni(){
        String userId = UserInfo.getUserId();
        List<User> lstUsr = [SELECT ContactId FROM User WHERE Id =:userId limit 1];
        Boolean televisitVendorAvailable = false;
        Set<Id> ssIds = new Set<Id>();
        Set<Id> actualSSIds = new Set<Id>();
        
        for(Participant_Enrollment__c pe : [SELECT Id,Name,Study_Site__c FROM Participant_Enrollment__c WHERE Participant_Contact__c =:lstUsr[0].ContactId]){
            ssIds.add(pe.Study_Site__c);
        }
        
        for(TelevisitVendorSettings__c tvs :[SELECT Id,Study_Site__c FROM TelevisitVendorSettings__c  WHERE isEnable__c = TRUE AND Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c = TRUE AND Study_Site__c IN:ssIds]){
            actualSSIds.add(tvs.Study_Site__c);
        }
        
        for(Participant_Enrollment__c pe : [SELECT Id,Name,Study_Site__c,Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c FROM Participant_Enrollment__c WHERE Participant_Contact__c =:lstUsr[0].ContactId]){
            if(pe.Study_Site__r.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c && actualSSIds.contains(pe.Study_Site__c)){
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
        String contactId;
        Map<Id,Participant_Enrollment__c> perMapForMultiRole = New Map<Id,Participant_Enrollment__c>();
        if(ctpId != ''){
            String peId = pstate.pe.Id;
            Participant_Enrollment__c currentPER =  new Participant_Enrollment__c(Id=peId);
            List<Participant_Enrollment__c> allPERList =  new List<Participant_Enrollment__c>();
            allPERList.Add(currentPER);
            if(pstate.isDelegate){
                if(ParticipantContext.getCurrentUser() != null){ // Participant user
                    List<Participant_Enrollment__c> pastEnrollments  = ContactService.getPastEnrollments(
                        ParticipantContext.getCurrentContact()?.Id
                    );
                        //Check If half Alumni
                    if(pastEnrollments.size() > 0){
                        allPERList.AddAll(pastEnrollments);
                    }
                    //To Display Participant's Televisit from Delegate participant view
                    userId = ParticipantContext.getCurrentUser().Id;
                    query += ' WHERE User__c = :userId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Participant_Enrollment__c = :allPERList AND Televisit__r.Status__c = \'Scheduled\'  AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
                }else{
                    //To Display Minor or Adult without email Participant's Televisit from Delegate view
                    //query += ' WHERE User__c = :userId AND Attendee_Type__c = \'Participant Delegate\' AND Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
                    List<Patient_Delegate_Enrollment__c> pdeList = [Select Id,Patient_Delegate__r.Participant_Delegate__r.Contact__c from Patient_Delegate_Enrollment__c where Primary_Delegate__c = true and Participant_Enrollment__c =: peId LIMIT 1];
                    List<User> userList = [SELECT Id From User WHERE ContactId =: pdeList[0].Patient_Delegate__r.Participant_Delegate__r.Contact__c Limit 1];
                    String primaryDelegateUserId = userList[0].Id;
                    if(primaryDelegateUserId != userId){
                        //secondary delegate can view Minor Participant televisit scheduled with Primary Delegate
                        query += ' WHERE User__c = :primaryDelegateUserId AND Attendee_Type__c = \'Participant Delegate\' AND Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' AND  Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
                    }else{
                        query += ' WHERE User__c = :userId AND Attendee_Type__c = \'Participant Delegate\' AND Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
                    }
                }

            }else{
                //To Display Participant's Televisit 
                query += ' WHERE User__c = :userId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Status__c = \'Scheduled\' AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Invited_To_PP_Date__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c LIMIT 3';
            }
        }else{
            delegateOrAlumni = true;
            if(pstate.isDelegate){
                if(ParticipantContext.getCurrentUser() != null){
                    //To Display Alumni Participant's Televisit from Delegate view
                    userId = ParticipantContext.getCurrentUser().Id;
                    query += ' WHERE User__c = :userId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' AND  Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c';
                }else{
                    //To Display Minor or Adult without email Alumni participant's Televisit from Delegate view
                    contactId = pstate.currentContactId;
                    query += ' WHERE User__c = :userId AND Attendee_Type__c = \'Participant Delegate\' AND Televisit__r.Participant_Enrollment__r.Participant_Contact__c =:contactId AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' AND  Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c';
                }    
            }else{
                //Delegate self view or Multi Role(self View) for all non Invited study or full alumni. 
                //Get PER record if Delegate is also a participant.
                contact currentContact = ParticipantContext.getCurrentContact();
                perMapForMultiRole = ParticipantEnrollmentService.getPerMapByContactId(currentContact.Id);
                query += ' WHERE User__c = :userId  AND Televisit__r.Visit_Link_Activation_End_Time__c >= :currentDateTime AND Televisit__r.Status__c = \'Scheduled\' AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = \'Accepted\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated\' AND Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != \'Deactivated (Admin)\' ORDER BY Televisit__r.Visit_Date_Time__c, Televisit__r.Duration__c';
            
            }
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
            if(filteredTelevisits.size()>3){
                for(Integer i=0; i<3; i++){
                    allVisitis.add(filteredTelevisits[i]);
                }
            }else{
                allVisitis.addAll(filteredTelevisits);
            }
        }
        
        List<Televisit_Attendee__c> visits = new List<Televisit_Attendee__c> ();
        for(Televisit_Attendee__c attendee : allVisitis){
            if(userMode != 'Participant' && attendee.Televisit__r.Source_Community__c == communityMode && (attendee.Attendee_Type__c != 'Participant' && attendee.Attendee_Type__c != 'Participant Delegate')){
                visits.add(attendee);
            }
            if(userMode == 'Participant' && (attendee.Attendee_Type__c == 'Participant' || attendee.Attendee_Type__c == 'Participant Delegate')){
                Id perId = attendee?.Televisit__r?.Participant_Enrollment__c;
                //if participat has multi role and not invited to studies, skip the Televisit.
                if(perMapForMultiRole.containsKey(perId) && perMapForMultiRole.get(perId).Invited_To_PP_Date__c == null){
                    continue;
                }
                visits.add(attendee);
            }
        }
        return JSON.serialize(visits);
    }
    
}