public class MedicalRecordAccessRemote {
    
    public static String clientId='72cd1f1f7b36cc80e104efd2a9332e74372fcb24';
    public static  String clientUserId='SK_Sandeep'; //referral Id
    public static String clientUserEmail='sandeepsfdc527@gmail.com';//patient email
    public static String clientSecret='8338fd6645b6b430fe186729a1a873e7cd57a839';
    
    @AuraEnabled 
    public static RemoteCall_getHumanAPITokens.SessionTokenInfo getSessionToken(String participantEmail,String referralId,String humanId,String uniqueHumanId){    
        /**String participantEmail;
        String referralId;
        String humanId;
        String uniqueHumanId; **/
         /**String referralId;
        String uniqueHumanId; **/
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
   
        RemoteCall_getHumanAPITokens remoteObj = new RemoteCall_getHumanAPITokens();
        if(participantState.pe != null && !UserContext.getCurrentUserMode().hasPastStudies)
        {
            participantEmail = participantState.pe.Participant__r.Email__c;
            referralId = participantState.pe.Id;
            humanId = participantState.pe.Human_Id__c;
            uniqueHumanId = participantState.pe.Unique_HumanId__c;
        }
        System.debug('hasPaststudies'+UserContext.getCurrentUserMode().hasPastStudies);
        if(!String.isBlank(referralId) && UserContext.getCurrentUserMode().hasPastStudies)
        {
            //setting attributes for alumni
            System.debug('referralId--->'+referralId);
            String[] arrTest = referralId.split(':::');
            if(arrTest.size()>1)
            {
               uniqueHumanId = arrTest[0];
               referralId = arrTest[1];
               humanId ='EXIST';
               
            }
            
        }
      
        System.debug('participantEmail'+participantEmail);
        System.debug('referralId::'+referralId+'humanId:::'+humanId);
        System.debug('uniqueHumanId::::'+uniqueHumanId);
        Contact c = null;
       // System.debug(c.Id);
        return remoteObj.remoteCallGetSessionToken(participantEmail,referralId,humanId,uniqueHumanId); 
    }
    
    @AuraEnabled
    public static RemoteCall_getHumanAPITokens.AccessTokenInfo getAccessToken(String referralId,String clientUserEmail,String uniqueHumanId){
    
        System.debug('referralId in fun:::'+referralId); 
        String referralRecordId;
        String uniqueId;
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        System.debug('String.isBlank(referralId)'+String.isBlank(referralId));
         if(participantState.pe != null && String.isBlank(referralId)) 
        {
            clientUserEmail = participantState.pe.Participant__r.Email__c;
            //referralId = participantState.pe.Id;
            referralRecordId = participantState.pe.Id;
            uniqueId = participantState.pe.Unique_HumanId__c;
            
            System.debug('inside if ');
            System.debug('uniqueId:::'+uniqueId);
            
        }
       // if(participantState.pe == null)
       if(!String.isBlank(referralId))
        {
            //setting attributes for alumni
            System.debug('!String.isBlank(referralId)');
            System.debug('referralId--->'+referralId);
            String[] arrTest = referralId.split(':::');
            if(arrTest.size()>1)
            {
               // if(participantState.pe.Id != referralRecordId){
               uniqueId = arrTest[0];
               referralRecordId = arrTest[1];
               // }
               
            }
            
        }
        
        
        Contact c = null;
      // System.debug(c.Id);
        
       // return RemoteCall_getHumanAPITokens.getInstance().remoteCallGetAccessToken(referralRecordId,clientUserEmail,uniqueId).access_token;
        
         return RemoteCall_getHumanAPITokens.getInstance().remoteCallGetAccessToken(referralRecordId,clientUserEmail,uniqueId);
    }
    
    
    
    
    
    @AuraEnabled
    public static List<Provider> getHumanSourcesList(String referralId,String clientUserEmail,String uniqueHumanId){
         System.debug('referralId:::in getHumanSourcesList'+referralId);
       // System.debug()
       ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
       if(participantState.pe != null && String.isBlank(referralId)) 
        {
            clientUserEmail = participantState.pe.Participant__r.Email__c;
            //referralId = participantState.pe.Id;
            uniqueHumanId = participantState.pe.Unique_HumanId__c;
            
        }
        
        RemoteCall_getHumanAPITokens.AccessTokenInfo accessToken = getAccessToken( referralId, clientUserEmail, uniqueHumanId);
        List<Provider> providersList = RemoteCall_getHumanAPIData.getHumanSources(accessToken.access_token);
        TokenService.storeToken(referralId, 'access', accessToken.access_token,null,accessToken.expires_in);
        Contact c = null;
        //System.debug(c.Id);
        return providersList;
        
    }
    
    @AuraEnabled
    public static List<Provider> getHumanSourcesListwelcome()
    {
        return new List<Provider>();
    }
    
    @AuraEnabled
    public static List<LabelValueItem> getHumanAPIPastPEList(Id contactId)
    {
        //String ownPEFilter =' Participant_Status__c IN ' +
          //  DatabaseService.listToString(PEStatusState.PE_STATUS_GROUP_ALUMNI) +
            //'AND Human_Id__c != null AND Participant__r.Contact__c IN ' + DatabaseService.listToString(new List<Id>{contactId});
        
         ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        List<Id> ownidList= new List<Id>();
         if(participantState.pe != null) ownidList.add(participantState.pe.Id);
        String ownPEFilter ='(Human_Id__c != null OR Id IN '+DatabaseService.listToString(ownidList)+')  AND Participant__r.Contact__c IN ' + DatabaseService.listToString(new List<Id>{contactId});

        
        
         List<Participant_Enrollment__c> ownPEList = DatabaseService.query(
            new List<String>{ 'Id','Participant__c','Name', 'Participant__r.Contact__c','Clinical_Trial_Profile__r.Study_Code_Name__c','Human_Id__c','Unique_HumanId__c','Participant__r.Email__c'},
            Participant_Enrollment__c.getSObjectType(),
            ownPEFilter
        );
       //  ownPEList.addAll(peList);
       
        List<LabelValueItem> labelItems = new List<LabelValueItem>();
        if(ownPEList.size()>0){
            
            for(Participant_Enrollment__c pe : ownPEList){
                
              //  labelItems.add(new LabelValueItem(pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Unique_HumanId__c+':::'+pe.Id));
                LabelValueItem labelItem = new LabelValueItem(pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Unique_HumanId__c+':::'+pe.Id);
                if(!labelItems.contains(labelItem))
                {
                    labelItems.add(labelItem);
                }
            }
            return labelItems;}
        return labelItems;
    }
    
    
    
    
    
}