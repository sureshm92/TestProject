public without sharing class ParticipantTelevisitRemote {
    public static Map<Id,Participant_Enrollment__c> perMapForMultiRole = New Map<Id,Participant_Enrollment__c>();
    @AuraEnabled
    public static televisitWrapper getParticipantTelevisits(List<Id> joinbuttonids){
        try {
            Id userId;
            String timezonechanges;
            Boolean delegatecheck = false;
            participantservice.participantstate pstate = ((participantservice) classfactory.newinstance(participantservice.class)).getState(); 
            String ctpId;
            if(pstate != null && pstate.pe != null){
                ctpId = pstate.pe.Clinical_Trial_Profile__c;
            }
            user u = [Select id,contactid,TimeZoneSidKey from User where id =: UserInfo.getUserId()];
            userId = u.Id;
            timezonechanges = u.TimeZoneSidKey;
            Boolean isDelegate = pstate.isDelegate;
            String query = 'Select Televisit__r.Id, Televisit__r.Meeting_URL__c,Televisit__r.Title__c,Televisit__r.Status__c,Televisit__r.Duration__c,Televisit__r.Visit_Date_Time__c,Televisit__r.Visit_End_Date_Time__c,Televisit__r.Participant_Enrollment__r.Study_Site__c, Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c, Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c from Televisit_Attendee__c';
            if(ctpId != null && ctpId != ''){
                String peId = pstate.pe.Id;
                Participant_Enrollment__c currentPER =  new Participant_Enrollment__c(Id=peId);
                List<Participant_Enrollment__c> allPERList =  new List<Participant_Enrollment__c>();
                allPERList.Add(currentPER);
                if(!isDelegate){
                    //participant View
                    query += '  where Televisit__r.Participant_Enrollment__c = :peId AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true AND Televisit__r.Participant_Enrollment__r.Invited_To_PP_Date__c != null order by Televisit__r.Visit_Date_Time__c desc';
                }else{
                    //Delegate switched to participant View
                    if(ParticipantContext.getCurrentContact() != null){ // Participant contact
                        List<Participant_Enrollment__c> pastEnrollments  = ContactService.getPastEnrollments(
                            ParticipantContext.getCurrentContact().Id
                        );
                        //Check If participant has past study - if yes then it is half Alumni case.
                        if(pastEnrollments.size() > 0){
                            allPERList.AddAll(pastEnrollments);
                        }
                    }
                    query += '  where Televisit__r.Participant_Enrollment__c = :allPERList AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true order by Televisit__r.Visit_Date_Time__c desc';
                }     
            }else{ 
                delegatecheck = true;
                String contactId;
                //Added for PEH-13732
                Boolean minorAlumni = false;
                if(isDelegate){
                    contactId = ParticipantContext.getCurrentParticipant().Contact__c ;
                    //Added for PEH-13732
                    if(ParticipantContext.getCurrentUser() == null){
                        contactId = pstate.currentContactId;
                        minorAlumni = true;
                    }
                }else{
                    contactId = pstate.currentContactId;
                }
                //query += '  where Contact__c =:contactId order by Televisit__r.Visit_Date_Time__c desc';
                
                //Added for PEH-13732
                if(minorAlumni){
                    query += '  where Televisit__r.Participant_Enrollment__r.Participant_Contact__c =:contactId AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true order by Televisit__r.Visit_Date_Time__c desc';
                }else{
                    if(isDelegate){
                        //Delegate Switch to Participant View.
                        query += '  where Contact__c =:contactId AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true order by Televisit__r.Visit_Date_Time__c desc';
                    }else{
                        //Delegate self view or Multi Role(self View) for all non Invited study or full alumni. 
                        //Get PER record if Delegate is also a participant.
                        contact currentContact = ParticipantContext.getCurrentContact();
                        perMapForMultiRole = ParticipantEnrollmentService.getPerMapByContactId(currentContact.Id);
                        query += '  where Contact__c =:contactId AND Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true order by Televisit__r.Visit_Date_Time__c desc';
                    }
                    
                }
            }
            List<Televisit_Attendee__c> televisitattendeesdata = Database.query(query);
            List<Televisit_Attendee__c> televisitattendeeList;
            if(televisitattendeesdata != null && televisitattendeesdata.size() > 0){
                televisitattendeeList =  filteringtelevisits(televisitattendeesdata);
            }else{
                televisitattendeeList = televisitattendeesdata;
            }                                                    
            Set<Id> televisitIdSet = new Set<Id>();
            televisitWrapper  tw = new televisitWrapper();
            if(televisitattendeeList != null && !televisitattendeeList.isempty()){
                Map<id,upcomingTelevisits> upcomingTelevisitmap = new Map<id,upcomingTelevisits>();
                Map<id,pastTelevisits> pastTelevisitsmap = new Map<id,pastTelevisits>();
                for(Televisit_Attendee__c attendee:televisitattendeeList){
                    televisitIdSet.add(attendee.Televisit__r.Id);
                    if(attendee.Televisit__r.Status__c != 'Cancelled' && attendee.Televisit__r.Status__c != 'Completed' &&
                       attendee.Televisit__r.Visit_End_Date_Time__c >= system.now() &&
                       attendee.Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated (Admin)'&&
                       attendee.Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated' &&
                       attendee.Televisit__r.Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c == 'Accepted' &&
                       attendee.Televisit__r.Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null ){
                           upcomingTelevisits upcomingTelevisit = new upcomingTelevisits();
                           upcomingTelevisit.televisitId = attendee.Televisit__r.Id;
                           upcomingTelevisit.title = attendee.Televisit__r.Title__c;
                           upcomingTelevisit.televisitdate = attendee.Televisit__r.Visit_Date_Time__c;
                           upcomingTelevisit.televisitduration = attendee.Televisit__r.Duration__c.split(' ')[0] + ' '+System.Label.Minutesinshort;
                           upcomingTelevisit.televisitmettingurl = attendee.Televisit__r.Meeting_URL__c;
                           if(joinbuttonids.contains(attendee.Televisit__r.Id) /*&& !isDelegate*/){
                               upcomingTelevisit.showjoinbutton = true;
                           }else{
                               upcomingTelevisit.showjoinbutton = false;
                           }
                           upcomingTelevisitmap.put(attendee.Televisit__r.Id,upcomingTelevisit);
                       }else if(attendee.Televisit__r.Visit_End_Date_Time__c < system.now() || 
                                attendee.Televisit__r.Status__c == 'Cancelled'){
                                    pastTelevisits pastTelevisit = new pastTelevisits();
                                    pastTelevisit.title = attendee.Televisit__r.Title__c;
                                    pastTelevisit.televisitdate = attendee.Televisit__r.Visit_Date_Time__c;
                                    pastTelevisit.televisitduration = attendee.Televisit__r.Duration__c;
                                    pastTelevisit.televisitId = attendee.Televisit__r.Id;
                                    if(attendee.Televisit__r.Status__c == 'Cancelled'){
                                        pastTelevisit.status = 'Canceled';
                                        pastTelevisit.iscancelledone = true;
                                    }
                                    pastTelevisitsmap.put(attendee.Televisit__r.Id,pastTelevisit);
                                }                                       
                }
                List<Televisit__c> televisitList = [Select id,(select id,Attendee_Type__c,Firstname__c,Televisit__c,Lastname__c,CreatedBy.Name  from Televisit_Attendee__r) from Televisit__c 
                                                    where Id IN : televisitIdSet order by Visit_Date_Time__c,Duration__c asc];
                List<Televisit_Attendee__c> attendeelist = new List<Televisit_Attendee__c>();
                if(televisitList != null && !televisitList.isempty()){
                    for(Televisit__c televisit: televisitList){
                        attendeelist.addAll(televisit.Televisit_Attendee__r);
                    }
                }
                Map<Id,List<televisitattendeeWrapper>> upcomingattendeesmap = new Map<Id,List<televisitattendeeWrapper>>();
                Map<Id,List<televisitattendeeWrapper>> pastattendeesmap = new Map<Id,List<televisitattendeeWrapper>>();
                
                for(Televisit_Attendee__c ta:attendeelist){
                    televisitattendeeWrapper taw = new televisitattendeeWrapper();
                    taw.firstname = ta.Firstname__c;
                    taw.lastname = ta.Lastname__c;
                    taw.attendeeType = ta.Attendee_Type__c;
                    if(pastTelevisitsmap.containskey(ta.Televisit__c)){
                        if(pastattendeesmap.containskey(ta.Televisit__c)){
                            pastattendeesmap.get(ta.Televisit__c).add(taw);
                        }else{                        
                            pastattendeesmap.put(ta.Televisit__c,new List<televisitattendeeWrapper> {taw});
                        }
                    }else if(upcomingTelevisitmap.containskey(ta.Televisit__c)){
                        if(upcomingattendeesmap.containskey(ta.Televisit__c)){
                            upcomingattendeesmap.get(ta.Televisit__c).add(taw);
                        }else{                        
                            upcomingattendeesmap.put(ta.Televisit__c,new List<televisitattendeeWrapper> {taw});
                        }
                    }
                    
                }
                List<upcomingTelevisits> finalupcomingTelevisitslist = new List<upcomingTelevisits>();
                List<pastTelevisits> finalpastTelevisitslist = new List<pastTelevisits>();
                for(Id i:upcomingattendeesmap.keyset()){
                    upcomingTelevisits ut = new upcomingTelevisits();
                    ut = upcomingTelevisitmap.get(i);
                    ut.relatedAttendees = upcomingattendeesmap.get(i);
                    finalupcomingTelevisitslist.add(ut);
                }
                for(Id i:pastTelevisitsmap.keyset()){
                    pastTelevisits pt = new pastTelevisits();
                    pt = pastTelevisitsmap.get(i);
                    pt.relatedAttendees = pastattendeesmap.get(i);
                    finalpastTelevisitslist.add(pt);
                }
                tw.televisitupcomingList = finalupcomingTelevisitslist;
                tw.televisitpastList = finalpastTelevisitslist;
                tw.showDefault = 'upcoming';
                tw.tz = timezonechanges;
                tw.isdelegate = delegatecheck;
                return tw;
            }
            tw.televisitupcomingList = new List<upcomingTelevisits>();
            tw.televisitpastList = new List<pastTelevisits>();
            tw.showDefault = 'upcoming';
            tw.tz = timezonechanges;
            tw.isdelegate = delegatecheck;
            return tw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Televisit_Attendee__c> filteringtelevisits(List<Televisit_Attendee__c> attendeesList){
        try {
            List<Televisit_Attendee__c> filteredTelevisits = new List<Televisit_Attendee__c>();
            Set<Id> studySiteIds = new Set<Id>();
            for (Televisit_Attendee__c telattendeeObj : attendeesList) {
                studySiteIds.add(telattendeeObj.Televisit__r.Participant_Enrollment__r.Study_Site__c);
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
            for (Televisit_Attendee__c telattendeeObj : attendeesList) {
                //if participat has multi role and not invited to studies, skip the Televisit.
                Id perId = telattendeeObj?.Televisit__r?.Participant_Enrollment__c;
                if(perMapForMultiRole.containsKey(perId) && perMapForMultiRole.get(perId).Invited_To_PP_Date__c == null){
                    continue;
                }
                if (
                    ssMap.size() > 0 &&
                    ssMap.containsKey(telattendeeObj.Televisit__r.Participant_Enrollment__r.Study_Site__c)
                ) {
                    filteredTelevisits.add(telattendeeObj);
                }
            }
            return  filteredTelevisits;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class upcomingTelevisits{
        @AuraEnabled public string title;
        @AuraEnabled public datetime televisitdate;
        @AuraEnabled public string televisitduration;
        @AuraEnabled public id televisitId;
        @AuraEnabled public string televisitmettingurl;
        @AuraEnabled public boolean showjoinbutton;
        @AuraEnabled public List<televisitattendeeWrapper> relatedAttendees;
    }
    public class pastTelevisits{
        @AuraEnabled public string title;
        @AuraEnabled public datetime televisitdate;
        @AuraEnabled public string televisitduration;
        @AuraEnabled public string status;
        @AuraEnabled public id televisitId;
        @AuraEnabled public boolean iscancelledone = false;
        @AuraEnabled public List<televisitattendeeWrapper> relatedAttendees;
    }
    public class televisitWrapper{
        @AuraEnabled public List<upcomingTelevisits> televisitupcomingList;
        @AuraEnabled public List<pastTelevisits> televisitpastList;
        @AuraEnabled public string showDefault;
        @AuraEnabled public string tz;
        @AuraEnabled public boolean isdelegate;
    }
    public class televisitattendeeWrapper{
        @AuraEnabled public string firstname;
        @AuraEnabled public string lastname;
        @AuraEnabled public string attendeeType;
        @AuraEnabled public boolean organiger = false;
    }
}