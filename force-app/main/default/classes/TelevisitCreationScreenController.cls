Public without sharing Class TelevisitCreationScreenController {
    @AuraEnabled
    Public static Boolean televisistPrerequisiteCheck(String ParticipantEnrollmentId){
        Boolean enableTelevisitTab = false;
        if(ParticipantEnrollmentId != Null){
            Participant_Enrollment__c ParticipantEnrollment = [SELECT Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c,Study_Site__c, Study_Site__r.Study_Site_Type__c 
                FROM Participant_Enrollment__c WHERE Id = :ParticipantEnrollmentId];
            
            TelevisitVendorSettings__c vendorDetails = [Select id,Study_Site__c, Televisit_Record_Vendor__r.name,isEnable__c from TelevisitVendorSettings__c where Study_Site__c =:ParticipantEnrollment.Study_Site__c and  Televisit_Record_Vendor__r.name = 'Vonage' limit 1];
                
            if(ParticipantEnrollment.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c && ParticipantEnrollment.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c &&
               ParticipantEnrollment.Study_Site__r.Study_Site_Type__c == 'Traditional' && 
               vendorDetails.Televisit_Record_Vendor__r.name == 'Vonage' && vendorDetails.isEnable__c){
                     enableTelevisitTab = true;
                 
             }else{
                 enableTelevisitTab = false;
             }
        }
        return enableTelevisitTab;
    }
    
    @AuraEnabled
    Public Static String insertTelevisitRecord(String wrapperText){
        TelevisitWrapper wrapper=(TelevisitWrapper)JSON.deserialize(wrapperText,TelevisitWrapper.class);
        //system.debug('Title : ');
        //system.debug('Wrap : '+wrap);
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
        upsert televisitRecord;
        
        
        //List<ParseAttendeesList> wrapper1=(List<ParseAttendeesList>)JSON.deserialize(wrapper.attendeesList,ParseAttendeesList.class);
        system.debug('wrapperText :'+wrapperText);
        system.debug('wrapper1 :'+wrapper.attendeesList);
        Map<Id,User> mapUser = new Map<Id,User>();
        List<String> Ids = new List<String>();
        for(string str : wrapper.attendeesList){
            string id = str.split(':')[0];
            Ids.add(id);
        }
        for(User usr :[SELECT Id,firstname,lastname,contactId FROM User WHERE contactId  =:Ids]){
            mapUser.put(usr.contactId, usr);
        }
        List<Televisit_Attendee__c> lsttelevisitAttendees = new List<Televisit_Attendee__c>();
        
        if(wrapper.id==''){
        String participantContactId;
        String participantDelegateContactId;
        
        for(String str : wrapper.attendeesList){
            String type = str.split(':')[1];
            type = type.split('\\(')[1];
            type = type.split('\\)')[0];
            if(type == 'Participant'){
                participantContactId = str.split(':')[0];
            }
            if(type == 'Participant Delegate'){
                participantDelegateContactId = str.split(':')[0];
            } 
           
        }
        
        Participant_Enrollment__c per = new Participant_Enrollment__c();
        Patient_Delegate__c pd = new Patient_Delegate__c();
        if(participantContactId != null){
            per = [SELECT Id,Participant__c,Participant_Contact__c,PI_Contact__c,PI_Contact__r.FirstName, PI_Contact__r.LastName, Study_Site__c,
                                          Participant__r.First_Name__c,Participant__r.Last_Name__c FROM Participant_Enrollment__c WHERE Participant_Contact__c =: participantContactId];
        
        }
        if(participantDelegateContactId != null){
            pd = [SELECT Id,Participant__c, Primary_Delegate__c, Participant_Delegate__r.First_Name__c, 
                                                      Participant_Delegate__r.Last_Name__c, Contact__c FROM Patient_Delegate__c WHERE 
                                                      Contact__c =: participantDelegateContactId];
        
        }
        
        
        for(String str : wrapper.attendeesList){
            Televisit_Attendee__c televisitAttendee = new Televisit_Attendee__c();
            String contactId = str.split(':')[0];
            televisitAttendee.Contact__c = contactId;
            televisitAttendee.Televisit__c = televisitRecord.id;
            televisitAttendee.User__c = (mapUser.get(contactId)!= null)? mapUser.get(contactId).Id:null;
            televisitAttendee.Firstname__c =(mapUser.get(contactId)!= null)? mapUser.get(contactId).firstname:null;
            televisitAttendee.Lastname__c =(mapUser.get(contactId)!= null)? mapUser.get(contactId).lastname:null;
            String type = str.split(':')[1];
            type = type.split('\\(')[1];
            type = type.split('\\)')[0];
            televisitAttendee.Attendee_Type__c = type;
            
            if(type == 'Participant' && televisitAttendee.Firstname__c == null){
                televisitAttendee.Firstname__c = per.Participant__r.First_Name__c;
            }
            if(type == 'Participant' && televisitAttendee.Lastname__c == null){
                televisitAttendee.Lastname__c = per.Participant__r.Last_Name__c;
            }
            
            if(type == 'Participant Delegate' && televisitAttendee.Firstname__c == null){
                televisitAttendee.Firstname__c = pd.Participant_Delegate__r.First_Name__c;
            }
            if(type == 'Participant Delegate' && televisitAttendee.Lastname__c == null){
                televisitAttendee.Lastname__c = pd.Participant_Delegate__r.Last_Name__c;
            }
            
            lsttelevisitAttendees.add(televisitAttendee);
        }
        //Televisit_Attendee__c televisitAttendees = new Televisit_Attendee__c();
        //televisitAttendees.Contact__c = wrapper1.label;
        
            insert lsttelevisitAttendees;
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
        public String[] attendeesList{get;set;}
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
        public Boolean isScheduleStatus{get;set;}
        @AuraEnabled 
        public Boolean isCancelledStatus{get;set;}
        @AuraEnabled 
        public Boolean isCompletedStatus{get;set;}
    }
    
    @AuraEnabled
    Public Static List<FetchTelevisitWrapper> fetchTelevisitRecord(String status, String participantEnrollmentId){
        String Cancelled;
        String Completed;
        String Schdeduled;
        
        if(status.contains('/')){
            Cancelled = status.split('/')[0];
            Completed = status.split('/')[1];
        }else{
            Schdeduled = status;
        }
        List<FetchTelevisitWrapper> lstWrap = new List<FetchTelevisitWrapper>();
        List<Televisit__c> lstTelevisitRecords = new List<Televisit__c>();
        
        for(Televisit__c tv :[SELECT Id,Duration__c,Start_Time__c,Status__c,Title__c,Visit_Date__c,Meeting_URL__c,Participant_Enrollment__c,
                                Participant_Enrollment__r.Participant__r.First_Name__c, 
                                Participant_Enrollment__r.Participant__r.Last_Name__c, 
                                (SELECT Id,Firstname__c,Lastname__c,Attendee_Type__c FROM Televisit_Attendee__r)
                                FROM Televisit__c WHERE (Participant_Enrollment__c =:participantEnrollmentId) and (Status__c =:Schdeduled or Status__c =:Cancelled or Status__c =:Completed)
                                  order by Visit_Date__c asc, Start_Time__c asc]){
            FetchTelevisitWrapper wrap = new FetchTelevisitWrapper();
            wrap.id = tv.Id;
            wrap.title = tv.Title__c;
            wrap.duration = tv.Duration__c;
            wrap.startTime = tv.Start_Time__c;
            wrap.status = tv.Status__c;
            if(tv.Status__c == 'Scheduled'){
                wrap.isScheduleStatus = true;
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
            lstWrap.add(wrap);
        }
        
        
        
        return lstWrap;
        //return [SELECT Id,Duration__c,Start_Time__c,Status__c,Title__c,Visit_Date__c,Meeting_URL__c,Participant_Enrollment__r.Participant__r.First_Name__c, Participant_Enrollment__r.Participant__r.Last_Name__c FROM Televisit__c order by createdDate desc];
    }
    
    @AuraEnabled
    Public Static List<AttendeesWrapper> fetchAttendees(String ParticipantEnrollmentId){
        List<AttendeesWrapper> lstAttendeesWrapper = new List<AttendeesWrapper>();
        Participant_Enrollment__c  per = [SELECT Id,Participant__c,Participant_Contact__c,PI_Contact__c,PI_Contact__r.FirstName, PI_Contact__r.LastName, Study_Site__c,
                                          Participant__r.First_Name__c,Participant__r.Last_Name__c FROM Participant_Enrollment__c 
                                          WHERE Id =:ParticipantEnrollmentId];
            AttendeesWrapper wrap3 = new AttendeesWrapper();
            wrap3.firstName= per.Participant__r.First_Name__c;
            wrap3.lastName= per.Participant__r.Last_Name__c;
            wrap3.attendeeType= 'Participant';
            wrap3.contactId= per.Participant_Contact__c;
            lstAttendeesWrapper.add(wrap3);
        
        for(Site_Staff__c siteStaff : [Select Id,Site_Contact__c,Site_Contact__r.FirstName,Site_Contact__r.LastName  from Site_Staff__c WHERE Study_Site__c = :per.Study_Site__c]){
            AttendeesWrapper wrap = new AttendeesWrapper();
            wrap.firstName= siteStaff.Site_Contact__r.FirstName;
            wrap.lastName= siteStaff.Site_Contact__r.LastName;
            wrap.attendeeType= 'Site Staff';
            wrap.contactId= siteStaff.Site_Contact__c;
            lstAttendeesWrapper.add(wrap);
        }
        AttendeesWrapper wrap1 = new AttendeesWrapper();
        wrap1.firstName= per.PI_Contact__r.FirstName;
        wrap1.lastName= per.PI_Contact__r.LastName;
        wrap1.attendeeType= 'PI';
        wrap1.contactId= per.PI_Contact__c;
        lstAttendeesWrapper.add(wrap1);
        
        for(Patient_Delegate__c participantDelegate : [SELECT Id,Participant__c, Primary_Delegate__c, Participant_Delegate__r.First_Name__c, 
                                                      Participant_Delegate__r.Last_Name__c, Contact__c FROM Patient_Delegate__c WHERE 
                                                      Participant__c =: per.Participant__c]){
                                                      
            AttendeesWrapper wrap2 = new AttendeesWrapper();
            wrap2.firstName= participantDelegate .Participant_Delegate__r.First_Name__c;
            wrap2.lastName= participantDelegate .Participant_Delegate__r.Last_Name__c;
            wrap2.attendeeType= 'Participant Delegate';
            wrap2.contactId= participantDelegate.Contact__c;
            lstAttendeesWrapper.add(wrap2);
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
        
    }
    
    @AuraEnabled
    Public Static String cancelTelevisit(String TelevisitId){
        Televisit__c updateTelevisit = new Televisit__c();
        updateTelevisit.Id = TelevisitId;
        updateTelevisit.status__c = 'Cancelled';
        update updateTelevisit;
        return 'Televisit Cancelled Successfully';
    }
    
    
}