public without sharing class ppPastStudiesTabUtility {
    @AuraEnabled
    public static List<Participant_Enrollment__c> getStudyData(Id contID, Boolean isDelegate) {
        String getUserContact = UserContext.getUserContactId();
        set<Id> setPrimaryPER = new set<Id> ();        
        List<Participant_Enrollment__c> PrimaryalumniPERList = new List<Participant_Enrollment__c> ();
        List<String> PE_STATUS_GROUP_ALUMNI = PEStatusState.PE_STATUS_GROUP_ALUMNI;
        String queryString =
            'SELECT '+
            'id ,'+
            'Enrolled_DateTime__c ,'+
            'Study_Site__r.Principal_Investigator__r.Name ,'+
            'Study_Site__r.Site__r.Name ,'+
            'Clinical_Trial_Profile__c ,'+
            'Clinical_Trial_Profile__r.Profile_Picture__c ,'+
            'Clinical_Trial_Profile__r.Study_Code_Name__c ,'+
            'Clinical_Trial_Profile__r.Detailed_Description__c ,'+
            'Clinical_Trial_Profile__r.Study_Documents_Are_Available__c ,'+
            'Clinical_Trial_Profile__r.Visit_Data_Shareback__c ,'+
            'Study_Site__r.Messages_Are_Available__c ,'+
            'Study_Site__r.Study_Site_Phone__c ,'+
            'Study_Site__r.Study_Site_Email__c '+
            'FROM Participant_Enrollment__c '+
            'WHERE Participant_Status__c IN :PE_STATUS_GROUP_ALUMNI AND Participant_Contact__c = :contID LIMIT 10000';
        Map<Id,Participant_Enrollment__c>  alumiPerMap =  new Map<Id, Participant_Enrollment__c>((List<Participant_Enrollment__c>)Database.query(queryString));
        
        if (isDelegate) {
            for(Patient_Delegate_Enrollment__c objPDER : [SELECT id, Participant_Enrollment__c FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c IN :alumiPerMap.keySet() AND Patient_Delegate__r.Contact__c = :getUserContact AND Primary_Delegate__c = TRUE
            LIMIT 10000])
            {
                setPrimaryPER.add(objPDER.Participant_Enrollment__c);
            } 

            for(Participant_Enrollment__c objPER : alumiPerMap.values())
            {
                if(setPrimaryPER.contains(objPER.Id))
                {
                    PrimaryalumniPERList.add(objPER);
                }

            } 
             
        }
        if(!PrimaryalumniPERList.isEmpty()){
            return PrimaryalumniPERList;
        } 
        else{
            return alumiPerMap.values();
        }
        
    }

    @AuraEnabled
    public static list<Userwrapper> getrecentlycommunicatedmembers(Id contID,Participant_Enrollment__c per){
        /*Set<Id> lstUserId = new Set<Id>(); 
            for(Message__c mes:lstMessage){
                lstUserId.add(mes.CreatedById);
            } 
            lstUserId.add(UserInfo.getUserId()); */
        Map<Id,String> usrPic = new Map<Id,String>();
        List<Userwrapper> userdetaillist = new List<Userwrapper>();
        //List<Message__c> lstMessage = [Select Id,CreatedById,Conversation__c,Sender_Name__c from Message__c where Conversation__r.Participant_Enrollment__r.Clinical_Trial_Profile__c =:per.Clinical_Trial_Profile__c order by createddate DESC];
        string piName ;
        if(per != null && per.Study_Site__r != null && per.Study_Site__r.Principal_Investigator__r != null){
            piName = per.Study_Site__r.Principal_Investigator__r.name;
        }
        if(piName != null && piName != ''){
            List<User> lstUser = [Select Id,Firstname,Lastname,name,SmallPhotoUrl,FullPhotoUrl  from User where contactid =: per.Study_Site__r.Principal_Investigator__r.Id];
            for(User u:lstUser){
                Userwrapper wrap = new Userwrapper();
                wrap.Userid = u.id;
                wrap.Profilepicurl = u.SmallPhotoUrl;
                wrap.Username = u.name;
                if(!u.SmallPhotoUrl.contains('profilephoto/005/T')){
                    wrap.hasuserpic = true;
                }else{
                    wrap.hasuserpic = false;
                    wrap.Initials = u.FirstName.toUpperCase().substring(0,1) + 
                    u.LastName.toUpperCase().substring(0,1);
                }
                userdetaillist.add(wrap);
            }
            return userdetaillist;
        }else{
            return null;
        }
        
    }

    Public class Userwrapper{
        @AuraEnabled
        public Id Userid;
        @AuraEnabled
        public boolean hasuserpic;
        @AuraEnabled
        public String Profilepicurl;
        @AuraEnabled
        public String Username;
        @AuraEnabled
        public String Initials;
    }
}