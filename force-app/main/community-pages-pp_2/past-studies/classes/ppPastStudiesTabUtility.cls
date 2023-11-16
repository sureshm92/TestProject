public without sharing class ppPastStudiesTabUtility {
    
    public class studyResult{
        @AuraEnabled
        public List<Participant_Enrollment__c> peList  ;
        @AuraEnabled
        public List<string> hideFilesForPER;
    }

    @AuraEnabled
    public static studyResult getStudyData(Id contID, Boolean isDelegate) {
        studyResult resultWrapper = new studyResult();
        resultWrapper.hideFilesForPER = new List<string>();
        String getUserContact = UserContext.getUserContactId();
        set<Id> setPrimaryPER = new set<Id> ();        
        List<Participant_Enrollment__c> PrimaryalumniPERList = new List<Participant_Enrollment__c> ();
        List<String> PE_STATUS_GROUP_ALUMNI = PEStatusState.PE_STATUS_GROUP_ALUMNI;
        String queryString =
            'SELECT '+
            'id ,'+
            'Enrolled_DateTime__c ,'+
            'Participant_Status__c ,'+
            'Study_Site__r.Principal_Investigator__r.Name ,'+
            'Study_Site__r.Principal_Investigator__r.Salutation ,'+
            'Study_Site__r.Site__r.Name ,'+
            'Clinical_Trial_Profile__c ,'+
            'Clinical_Trial_Profile__r.Profile_Picture__c ,'+
            'Clinical_Trial_Profile__r.Study_Code_Name__c ,'+
            'Clinical_Trial_Profile__r.Detailed_Description__c ,'+
            'Clinical_Trial_Profile__r.Study_Documents_Are_Available__c ,'+
            'Clinical_Trial_Profile__r.Visit_Data_Shareback__c ,'+
            'Study_Site__r.Messages_Are_Available__c ,'+
            'Study_Site__r.Study_Site_Phone__c ,'+
            'Study_Site__r.Study_Site_Email__c ,'+
            'Study_Site__r.Override_PI_Referral_Status__c '+
            'FROM Participant_Enrollment__c '+
            'WHERE Participant_Status__c IN :PE_STATUS_GROUP_ALUMNI AND Participant_Contact__c = :contID ORDER BY Clinical_Trial_Profile__r.Study_Code_Name__c ASC LIMIT 10000';
        Map<Id,Participant_Enrollment__c>  alumiPerMap =  new Map<Id, Participant_Enrollment__c>((List<Participant_Enrollment__c>)Database.query(queryString));
        
        if (isDelegate) {
            for(Patient_Delegate_Enrollment__c objPDER : [SELECT id, Participant_Enrollment__c, Primary_Delegate__c  FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c IN :alumiPerMap.keySet() AND Patient_Delegate__r.Contact__c = :getUserContact AND Status__c = 'Active'
            LIMIT 10000])
            {
                setPrimaryPER.add(objPDER.Participant_Enrollment__c);
                if(!objPDER.Primary_Delegate__c){
                    resultWrapper.hideFilesForPER.add(objPDER.Participant_Enrollment__c);
                }
            } 

            for(Participant_Enrollment__c objPER : alumiPerMap.values())
            {
                if(setPrimaryPER.contains(objPER.Id))
                {
                    PrimaryalumniPERList.add(objPER);
                }

            } 
            resultWrapper.peList = PrimaryalumniPERList;
            return resultWrapper;             
        }
        resultWrapper.peList =alumiPerMap.values();
        return resultWrapper;
    }

    @AuraEnabled
    public static list<Userwrapper> getrecentlycommunicatedmembers(Id contID,Participant_Enrollment__c per,Boolean isdelegate){
        List<Userwrapper> userdetaillist = new List<Userwrapper>();
        string piName ;
        if(per != null && per.Study_Site__r != null && per.Study_Site__r.Principal_Investigator__r != null){
            piName = per.Study_Site__r.Principal_Investigator__r.name;
        }
        if(piName != null && piName != ''){
            Map<id,User> userMap = new Map<id,User>();
            String getUserContact = UserContext.getUserContactId();
            List<User> lstUser = [Select Id,contactId,Firstname,contact.name,contact.Salutation,Lastname,name,SmallPhotoUrl,FullPhotoUrl  from User where contactid =: per.Study_Site__r.Principal_Investigator__r.Id or contactid =:contID 
                                    or contactid =:getUserContact ];
            for(User u:lstUser){
                    userMap.put(u.contactId,u);
            }
            List<Conversation__c> sharedConversations;
            if(isdelegate != null && isdelegate){
                sharedConversations = ConversationService.getSharedConversations(
                  userMap.get(getUserContact).Id
                );
            }else{
                sharedConversations = ConversationService.getSharedConversations(
                  userMap.get(contID).Id
                );
            }
            Boolean showemptymessagescreen = false;
            if(sharedConversations != null){
                for(Conversation__c cnv:sharedConversations){
                    if(cnv.Participant_Enrollment__c == per.Id){
                        showemptymessagescreen = true;
                        break;
                    }
                }   
            }
            
            if(showemptymessagescreen && lstUser != null){
                Userwrapper wrap = new Userwrapper();
                wrap.Userid = userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).id;
                wrap.Profilepicurl = userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).SmallPhotoUrl;
                String salutation = userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).contact.Salutation != null ? userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).contact.Salutation+' ':'';
                wrap.Username = salutation + userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).name + System.Label.Past_Studies_Team ; 
                if(!userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).SmallPhotoUrl.contains('profilephoto/005/T')){
                    wrap.hasuserpic = true;
                }else{
                    wrap.hasuserpic = false;
                    String firstName = '';
                    if(userMap.get(per.Study_Site__r.Principal_Investigator__r.Id) != null && 
                       userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).FirstName != null &&
                       userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).FirstName != ''){
                           firstName = userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).FirstName.toUpperCase().substring(0,1);
                    }
                    wrap.Initials = firstName + userMap.get(per.Study_Site__r.Principal_Investigator__r.Id).LastName.toUpperCase().substring(0,1);
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

    @AuraEnabled
    public static boolean resultAvailable(String perId){
        Integer resultRecCount = [select  count() from Visit_Result__c where Patient_Visit__r.Participant_Enrollment__c =: perId ];
        return resultRecCount > 0;
    }
}