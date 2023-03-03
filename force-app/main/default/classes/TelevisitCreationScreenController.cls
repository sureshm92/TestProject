Public without sharing Class TelevisitCreationScreenController {
    @AuraEnabled
    Public static Boolean televisistPrerequisiteCheck(String ParticipantEnrollmentId){
        try{
            Boolean enableTelevisitTab = false;
            if(ParticipantEnrollmentId != Null){
                Participant_Enrollment__c ParticipantEnrollment = [SELECT Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                    Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c,Study_Site__c, Study_Site__r.Study_Site_Type__c 
                    FROM Participant_Enrollment__c WHERE Id = :ParticipantEnrollmentId];
                
                TelevisitVendorSettings__c vendorDetails = [Select id,Study_Site__c, Televisit_Record_Vendor__r.name,isEnable__c from TelevisitVendorSettings__c where Study_Site__c =:ParticipantEnrollment.Study_Site__c and isEnable__c = true limit 1];
                    
                if(ParticipantEnrollment.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c && ParticipantEnrollment.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && vendorDetails.isEnable__c ){
                         enableTelevisitTab = true;
                     
                 }else{
                     enableTelevisitTab = false;
                 }
            }
            return enableTelevisitTab;
        }catch (exception ex){
            return false;
        }
    
        
    }
    
    @AuraEnabled
    Public Static String insertTelevisitRecord(String wrapperText){
        TelevisitWrapper wrapper=(TelevisitWrapper)JSON.deserialize(wrapperText,TelevisitWrapper.class);
        Televisit__c televisitRecord = new Televisit__c();
        if(wrapper.id!=''){
            televisitRecord.Id = wrapper.id;
        }
        televisitRecord.Duration__c = wrapper.duration;
        String parseTime = wrapper.startTime;
        String[] splitStringTime = parseTime.split(':');
        Time timeChange = Time.newInstance( Integer.valueOf(splitStringTime[0]),Integer.valueOf(splitStringTime[1]),0,0);
        televisitRecord.Start_Time__c = timeChange;
        televisitRecord.Status__c = 'Scheduled';
        televisitRecord.Title__c = wrapper.title;
        televisitRecord.Visit_Date__c = wrapper.visitDate;
        televisitRecord.Participant_Enrollment__c = wrapper.peid;
        Datetime visitDateTime = Datetime.newInstance(wrapper.visitDate, timeChange);
        televisitRecord.Visit_Date_Time__c = visitDateTime;
        televisitRecord.Visit_End_Date_Time__c = visitDateTime.addMinutes(Integer.valueOf(wrapper.duration.remove(' minutes')));
        CommunityMode mode = UserContext.getCurrentUserMode();
        televisitRecord.Source_Community__c = mode.template.communityName;
        upsert televisitRecord;
        Televisit__c televisit = [Select id,Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c from Televisit__c where ID =:televisitRecord.Id];
        if(wrapper.id==''){
            List<AttendeesWrapper> attendeesWrapperList = wrapper.attendeesList;
            List<String> ids = new List<String>();
            List<Televisit_Attendee__c> lsttelevisitAttendees = new List<Televisit_Attendee__c>();
            Map<Id,User> mapUser = new Map<Id,User>();
            for(AttendeesWrapper wrap : attendeesWrapperList){
                ids.add(wrap.id);
            }
            for(User usr :[SELECT Id,firstname,lastname,contactId FROM User WHERE contactId  =:ids]){
                mapUser.put(usr.contactId, usr);
            }
            Televisit_Attendee__c participenttelevisitAttendee = new Televisit_Attendee__c();
            List<Televisit_Attendee__c> pisslsttelevisitAttendees = new List<Televisit_Attendee__c>();
            for(AttendeesWrapper wrap : attendeesWrapperList){
                Televisit_Attendee__c televisitAttendee = new Televisit_Attendee__c();
                televisitAttendee.Contact__c = wrap.id;
                televisitAttendee.Televisit__c = televisitRecord.id;
                televisitAttendee.User__c = (mapUser.get(wrap.id)!= null)? mapUser.get(wrap.id).Id:null;
                televisitAttendee.Firstname__c =wrap.firstName;
                televisitAttendee.Lastname__c =wrap.lastName;
                televisitAttendee.Attendee_Type__c = wrap.attendeeType;
                if(wrap.attendeeType == 'Participant'){
                    participenttelevisitAttendee = televisitAttendee;
                }
                if(wrap.attendeeType == 'Site Staff' || wrap.attendeeType == 'PI'){
                    pisslsttelevisitAttendees.add(televisitAttendee);
                }else{
                    lsttelevisitAttendees.add(televisitAttendee);
                }
            }
            
            for(Televisit_Attendee__c pissAttendee:pisslsttelevisitAttendees){
                pissAttendee.Participant_First_Name__c = participenttelevisitAttendee.Firstname__c;
                pissAttendee.Participant_Last_Name__c = participenttelevisitAttendee.Lastname__c;
                lsttelevisitAttendees.add(pissAttendee);
            }
            
            if(!lsttelevisitAttendees.isEmpty()){
                 try{
                    insert lsttelevisitAttendees;
                     /*
                    List<Notification__c> notifications = new List<Notification__c>();
                    for (Televisit_Attendee__c attendee : lsttelevisitAttendees) {
                        if(attendee.Attendee_Type__c == 'Site Staff' || attendee.Attendee_Type__c == 'PI'){
                            Notification__c notification = new Notification__c();
                            notification.Recipient__c = attendee.Contact__c;
                            notification.WhatId__c = attendee.Id;
                            notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation';
                            
                            if(televisit != null && televisit.Participant_Enrollment__c != null && televisit.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                                if(televisit.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation_Janssen';
                                }else if(televisit.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'GSK'){
                                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation_GSK';
                                }else{
                                    notification.Notification_Type__c = 'Message_to_PI_Televisit_Creation';
                                }

                            }
                            
                            notifications.add(notification);
                        }                          
                    }
                    if(!notifications.isEmpty()){
                        insert notifications;
                    }
                     */
                }catch(exception ex){
                    return ex.getMessage();
                }
            }
        }
        return 'Televisit record created successfully.';
        
    }
    
    Public Class ParseAttendeesList{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public Date value{get;set;}
    }
    
    Public Class TelevisitWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public Date visitDate{get;set;}
        @AuraEnabled
        public String startTime{get;set;}
        @AuraEnabled
        public String duration{get;set;}
        @AuraEnabled 
        public String peid{get;set;}
        @AuraEnabled 
        public String pefirstname{get;set;}
        @AuraEnabled 
        public String pelastname{get;set;}
        @AuraEnabled 
        public String status{get;set;}
        @AuraEnabled 
        public String meetingUrl{get;set;}
        @AuraEnabled 
        public List<AttendeesWrapper> attendeesList{get;set;}
    }
    
    Public Class FetchTelevisitWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public Date visitDate{get;set;}
        @AuraEnabled
        public Time startTime{get;set;}
        @AuraEnabled
        public String duration{get;set;}
        @AuraEnabled 
        public String peid{get;set;}
        @AuraEnabled 
        public String pefirstname{get;set;}
        @AuraEnabled 
        public String pelastname{get;set;}
        @AuraEnabled 
        public String status{get;set;}
        @AuraEnabled 
        public String meetingUrl{get;set;}
        @AuraEnabled 
        public List<Televisit_Attendee__c> attendeesList{get;set;}
        @AuraEnabled 
        public Boolean isScheduledStatus{get;set;}
        @AuraEnabled 
        public Boolean isCancelledStatus{get;set;}
        @AuraEnabled 
        public Boolean isCompletedStatus{get;set;}
        @AuraEnabled
        public List<AttendeesWrapper> attendeesWrapperList{get;set;}
        @AuraEnabled
        public Datetime visitDateTime{get;set;}
    }
    
    @AuraEnabled
    Public Static List<FetchTelevisitWrapper> fetchTelevisitRecord(String status, String participantEnrollmentId){
        List<Televisit__c> lstTelevisitRecordsToFetch = new List<Televisit__c>();
        String Cancelled;
        String Completed;
        String Schdeduled;
        if(status.contains('/')){
            Cancelled = status.split('/')[0];
            Completed = status.split('/')[1];
            lstTelevisitRecordsToFetch =[SELECT Id,Duration__c,Start_Time__c,Status__c,Title__c,Visit_Date__c,Meeting_URL__c,Participant_Enrollment__c,
                                        Participant_Enrollment__r.Participant__r.First_Name__c, 
                                        Participant_Enrollment__r.Participant__r.Last_Name__c, Visit_Date_Time__c,
                                        (SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c FROM Televisit_Attendee__r order by Firstname__c asc)
                                        FROM Televisit__c WHERE (Participant_Enrollment__c =:participantEnrollmentId) and (Status__c =:Schdeduled or Status__c =:Cancelled or Status__c =:Completed)
                                        order by Visit_Date__c desc, Start_Time__c desc];
        }else{
            Schdeduled = status;
            lstTelevisitRecordsToFetch =[SELECT Id,Duration__c,Start_Time__c,Status__c,Title__c,Visit_Date__c,Meeting_URL__c,Participant_Enrollment__c,
                                        Participant_Enrollment__r.Participant__r.First_Name__c, 
                                        Participant_Enrollment__r.Participant__r.Last_Name__c, Visit_Date_Time__c,
                                        (SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c FROM Televisit_Attendee__r order by Firstname__c asc)
                                        FROM Televisit__c WHERE (Participant_Enrollment__c =:participantEnrollmentId) and (Status__c =:Schdeduled or Status__c =:Cancelled or Status__c =:Completed)
                                        order by Visit_Date__c asc, Start_Time__c asc];
        }
        List<FetchTelevisitWrapper> lstWrap = new List<FetchTelevisitWrapper>();
        List<Televisit__c> lstTelevisitRecords = new List<Televisit__c>();
        List<AttendeesWrapper> lstAttendeesWrapper = new List<AttendeesWrapper>();
        for(Televisit__c tv :lstTelevisitRecordsToFetch){
            FetchTelevisitWrapper wrap = new FetchTelevisitWrapper();
            wrap.id = tv.Id;
            wrap.title = tv.Title__c;
            wrap.duration = tv.Duration__c;
            wrap.startTime = tv.Start_Time__c;
            wrap.status = tv.Status__c;
            if(tv.Status__c == 'Scheduled'){
                wrap.isScheduledStatus = true;
            }
            if(tv.Status__c == 'Completed'){
                wrap.isCompletedStatus = true;
            }
            if(tv.Status__c == 'Cancelled'){
                wrap.isCancelledStatus = true;
            }
            wrap.visitDate = tv.Visit_Date__c;
            wrap.meetingUrl = tv.Meeting_URL__c;
            wrap.pefirstname = tv.Participant_Enrollment__r.Participant__r.First_Name__c;
            wrap.pelastname = tv.Participant_Enrollment__r.Participant__r.Last_Name__c;
            wrap.attendeesList = tv.Televisit_Attendee__r;
            wrap.visitDateTime = tv.Visit_Date_Time__c;
            lstWrap.add(wrap);
        }
        return lstWrap;
    }
    
    @AuraEnabled
    Public Static List<AttendeesWrapper> fetchAttendees(String ParticipantEnrollmentId){
        List<AttendeesWrapper> lstAttendeesWrapper = new List<AttendeesWrapper>();
        Participant_Enrollment__c  per = [SELECT Id,Participant__c,Participant__r.Adult__c,Participant__r.Email__c,Participant_Contact__c,PI_Contact__c,PI_Contact__r.FirstName, PI_Contact__r.LastName, Study_Site__c,
                                          Participant__r.First_Name__c,Participant__r.Last_Name__c FROM Participant_Enrollment__c 
                                          WHERE Id =:ParticipantEnrollmentId];
        
        List<String> portalUserContactIds = new List<String>();
        List<Site_Staff__c> lstSiteStaff = new List<Site_Staff__c>([Select Id,Site_Contact__c,Site_Contact__r.FirstName,Site_Contact__r.LastName  from Site_Staff__c WHERE Study_Site__c = :per.Study_Site__c]);
        Map<Id,User> mapUserRecord = new Map<Id,User>();
        for(Site_Staff__c siteStaff : lstSiteStaff){
            portalUserContactIds.add(siteStaff.Site_Contact__c);
        }
        portalUserContactIds.add(per.PI_Contact__c);
        
        for(User usr : [SELECT Id,FirstName,LastName,ContactId FROM User WHERE ContactId =:portalUserContactIds]){
            mapUserRecord.put(usr.ContactId,usr);
        }
        
        if(per.Participant__r.Adult__c && per.Participant__r.Email__c != null){
            AttendeesWrapper wrap3 = new AttendeesWrapper();
            wrap3.firstName= per.Participant__r.First_Name__c;
            wrap3.lastName= per.Participant__r.Last_Name__c;
            wrap3.attendeeType= 'Participant';
            wrap3.contactId= per.Participant_Contact__c;
            lstAttendeesWrapper.add(wrap3);
        }
        for(Site_Staff__c siteStaff : lstSiteStaff){
            AttendeesWrapper wrap = new AttendeesWrapper();
            wrap.firstName= siteStaff.Site_Contact__r.FirstName;
            wrap.lastName= siteStaff.Site_Contact__r.LastName;
            if(wrap.firstName == null && wrap.lastName.startsWith('P-') && mapUserRecord.get(siteStaff.Site_Contact__c) != null){
                wrap.firstName= mapUserRecord.get(siteStaff.Site_Contact__c).FirstName;
                wrap.lastName= mapUserRecord.get(siteStaff.Site_Contact__c).LastName;
            }
            wrap.attendeeType= 'Site Staff';
            wrap.contactId= siteStaff.Site_Contact__c;
            lstAttendeesWrapper.add(wrap);
        }
        AttendeesWrapper wrap1 = new AttendeesWrapper();
        wrap1.firstName= per.PI_Contact__r.FirstName;
        wrap1.lastName= per.PI_Contact__r.LastName;
        if(wrap1.firstName == null && wrap1.lastName.startsWith('P-') && mapUserRecord.get(per.PI_Contact__c) != null){
            wrap1.firstName= mapUserRecord.get(per.PI_Contact__c).FirstName;
            wrap1.lastName= mapUserRecord.get(per.PI_Contact__c).LastName;
        }
        wrap1.attendeeType= 'PI';
        wrap1.contactId= per.PI_Contact__c;
        lstAttendeesWrapper.add(wrap1);
        
        Set<String> preventDuplicate = new Set<String>();
        for(Patient_Delegate_Enrollment__c participantDelegate : [SELECT Id,Patient_Delegate__c,Patient_Delegate__r.Participant__c,
                                                    Patient_Delegate__r.Participant__r.Adult__c,Patient_Delegate__r.Participant__r.Email__c, 
                                                    Primary_Delegate__c,Patient_Delegate__r.Participant_Delegate__c,
                                                    Patient_Delegate__r.Participant_Delegate__r.First_Name__c, 
                                                    Patient_Delegate__r.Participant_Delegate__r.Last_Name__c, 
                                                    Patient_Delegate__r.Contact__c,Patient_Delegate__r.Contact__r.FirstName, 
                                                    Patient_Delegate__r.contact__r.LastName 
                                                    FROM Patient_Delegate_Enrollment__c 
                                                    WHERE 
                                                    Participant_Enrollment__c =: per.id AND 
                                                    Patient_Delegate__r.Participant__c =: per.Participant__c 
                                                    and Status__c in 'Active' Order by Primary_Delegate__c Desc]){
            if(preventDuplicate.add(participantDelegate.Patient_Delegate__r.Contact__c)){
                AttendeesWrapper wrap2 = new AttendeesWrapper();
                if(participantDelegate.Patient_Delegate__r.Participant_Delegate__c != null){
                    wrap2.firstName= participantDelegate.Patient_Delegate__r.Participant_Delegate__r.First_Name__c;
                    wrap2.lastName= participantDelegate.Patient_Delegate__r.Participant_Delegate__r.Last_Name__c;
                }else{
                    wrap2.firstName= participantDelegate.Patient_Delegate__r.Contact__r.FirstName;
                    wrap2.lastName= participantDelegate.Patient_Delegate__r.contact__r.LastName;
                }
                wrap2.attendeeType= 'Participant Delegate';
                wrap2.contactId= participantDelegate.Patient_Delegate__r.Contact__c;
                wrap2.participantAdult = participantDelegate.Patient_Delegate__r.Participant__r.Adult__c;
                if(participantDelegate.Patient_Delegate__r.Participant__r.Email__c != null){
                    wrap2.participantHasEmail = true;
                }else{
                    wrap2.participantHasEmail = false;
                }
                wrap2.participantPrimaryDelegate = participantDelegate.Primary_Delegate__c;
                lstAttendeesWrapper.add(wrap2);
            }
        }
        return lstAttendeesWrapper;
    }
    
    Public Class AttendeesWrapper{
        @AuraEnabled 
        Public String firstName;
        @AuraEnabled 
        Public String lastName;
        @AuraEnabled 
        Public String attendeeType;
        @AuraEnabled 
        Public String contactId;
        @AuraEnabled 
        Public String attendeeId;  
        @AuraEnabled 
        Public String name;
        @AuraEnabled 
        Public String id;
        @AuraEnabled 
        Public Boolean participantAdult;
        @AuraEnabled 
        Public Boolean participantPrimaryDelegate;
        @AuraEnabled 
        Public Boolean participantHasEmail;
    }
    
    @AuraEnabled
    Public Static String cancelTelevisit(String TelevisitId){
        Televisit__c updateTelevisit = new Televisit__c();
        updateTelevisit.Id = TelevisitId;
        updateTelevisit.status__c = 'Cancelled';
        try{
            update updateTelevisit;
            List<Notification__c> notifications = new List<Notification__c>();
            List<Televisit_Attendee__c> attendeesList = [Select id,Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Contact__c,Attendee_Type__c from Televisit_Attendee__c 
                                                         where Televisit__c =:TelevisitId AND (Attendee_Type__c = 'PI' OR Attendee_Type__c = 'Site Staff')];
            for(Televisit_Attendee__c attendee:attendeesList){
                Notification__c notification = new Notification__c();
                notification.Recipient__c = attendee.Contact__c;
                notification.WhatId__c = attendee.Id;
                if(attendeesList != null &&  attendeesList[0].Televisit__c != null && attendeesList[0].Televisit__r.Participant_Enrollment__c != null && 
                   attendeesList[0].Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__c != null){
                    if(attendee.Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == 'Janssen'){
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Cancel_Janssen';
                    }else{
                        notification.Notification_Type__c = 'Message_to_PI_Televisit_Cancellation';
                    }

                }
                notifications.add(notification);
            }
            if(!notifications.isEmpty()){
                insert notifications;
            }

        }catch(exception ex){
            return ex.getMessage();
        }
        return 'Televisit Cancelled Successfully';
    }
    
    @AuraEnabled
    Public Static List<AttendeesWrapper> fetchSelectedAttendees(String TelevisitId){
        List<AttendeesWrapper> lstSelectedAttendees = new List<AttendeesWrapper>();
        for(Televisit_Attendee__c selectedAttendee: [SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c,Contact__c  
                                                    FROM Televisit_Attendee__c WHERE Televisit__c =: TelevisitId]){
            AttendeesWrapper wrap = new AttendeesWrapper();
            wrap.firstName = selectedAttendee.Firstname__c;
            wrap.lastName = selectedAttendee.Lastname__c;
            wrap.attendeeType = selectedAttendee.Attendee_Type__c;
            wrap.contactId = selectedAttendee.Contact__c;
            wrap.id = selectedAttendee.Contact__c;
            wrap.attendeeId = selectedAttendee.Id;
            lstSelectedAttendees.add(wrap);                     
        }
        return lstSelectedAttendees;
    }
    
    @AuraEnabled
    Public Static String updateAttendees(String TelevisitId,String deletedAttendeesRecord, String newlyAddedAttendeesRecord){
        List<AttendeesWrapper> deletedAttendeesRecordWrap=(List<AttendeesWrapper>)JSON.deserialize(deletedAttendeesRecord,List<AttendeesWrapper>.class);
        List<Televisit_Attendee__c> delListTelevisitAttendee = new List<Televisit_Attendee__c>();
        List<Id> delListTelevisitAttendeeId = new List<Id>();
        for(AttendeesWrapper delRec :deletedAttendeesRecordWrap){
            delListTelevisitAttendeeId.add(delRec.attendeeId);
        }
        for(Televisit_Attendee__c tvAttendeeRecord : [SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c,Contact__c  
                                                    FROM Televisit_Attendee__c WHERE Televisit__c =: TelevisitId AND Id =:delListTelevisitAttendeeId]){
            delListTelevisitAttendee.add(tvAttendeeRecord);                              
        }
        if(!delListTelevisitAttendee.isEmpty()){
            delete delListTelevisitAttendee;
        }
        addNewAttendees(TelevisitId,newlyAddedAttendeesRecord);
        return 'Success';
    }
    
    @AuraEnabled
    Public Static Void addNewAttendees(String TelevisitId, String newlyAddedAttendeesRecord){
        List<AttendeesWrapper> newlyAddedAttendeesRecordWrap=(List<AttendeesWrapper>)JSON.deserialize(newlyAddedAttendeesRecord,List<AttendeesWrapper>.class);
        Map<Id,User> mapUser = new Map<Id,User>();
        List<String> ids = new List<String>();
        for(AttendeesWrapper wrap : newlyAddedAttendeesRecordWrap){
            string id = wrap.id;
            ids.add(id);
        }
        for(User usr :[SELECT Id,firstname,lastname,contactId FROM User WHERE contactId  =:ids]){
            mapUser.put(usr.contactId, usr);
        }
        List<Televisit_Attendee__c> lsttelevisitAttendees = new List<Televisit_Attendee__c>();
        for(AttendeesWrapper wrap : newlyAddedAttendeesRecordWrap){
            Televisit_Attendee__c televisitAttendee = new Televisit_Attendee__c();
            televisitAttendee.Contact__c = wrap.id;
            televisitAttendee.Televisit__c = TelevisitId;
            televisitAttendee.User__c = (mapUser.get(wrap.id)!= null)? mapUser.get(wrap.id).Id:null;
            televisitAttendee.Firstname__c =wrap.firstName;
            televisitAttendee.Lastname__c =wrap.lastName;
            televisitAttendee.Attendee_Type__c = wrap.attendeeType;
            lsttelevisitAttendees.add(televisitAttendee);
        }
        if(!lsttelevisitAttendees.isEmpty()){
            insert lsttelevisitAttendees;
        }
    }
    @AuraEnabled
    public static participantEnrollment fetchParticipantDetails(String perId){
        participantEnrollment participantData = new participantEnrollment();
        if(!String.isBlank(perId)){
            Participant_Enrollment__c per = [select Id,Participant_Contact__c,Permit_Mail_Email_contact_for_this_study__c,Participant__c  from Participant_Enrollment__c where Id  =:perId];
            participantData.isEmailPermitted = per.Permit_Mail_Email_contact_for_this_study__c;
            Set<Id> contactId = new Set<Id>();
            if(!String.isBlank(per.Participant_Contact__c)){
                contactId.add(per.Participant_Contact__c);   
            }
            
            List<Patient_Delegate_Enrollment__c> participantDelegate = [SELECT Id,Patient_Delegate__c,Patient_Delegate__r.Contact__c,Primary_Delegate__c 
                                                                        FROM Patient_Delegate_Enrollment__c 
                                                                        WHERE Patient_Delegate__r.Participant__c =: per.Participant__c 
                                                                        AND Primary_Delegate__c = true
                                                                        AND Participant_Enrollment__c =: per.id];

            if(participantDelegate.size() > 0){
                if(!String.isBlank(participantDelegate[0].Patient_Delegate__r.Contact__c)){
                    contactId.add(participantDelegate[0].Patient_Delegate__r.Contact__c);  
                }
            }
            
            if(contactId.size()> 0){
                List<user> usr = [select Id,IsCommunityUserRegistered__c from User where IsCommunityUserRegistered__c = true AND (contactId=:contactId) limit 1];
                if(usr.size()>0){
                    participantData.isPPUserActivated =  usr[0].IsCommunityUserRegistered__c;
                }else{
                    participantData.isPPUserActivated = false;
                }
            }
        }
        return participantData;
    }

    public class participantEnrollment{
        @AuraEnabled
        public boolean isPPUserActivated{get;set;}
        @AuraEnabled
        public boolean isEmailPermitted{get;set;}
    }
}