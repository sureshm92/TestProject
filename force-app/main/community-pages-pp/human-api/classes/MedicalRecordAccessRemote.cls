public class MedicalRecordAccessRemote {
      public class StudyProviderDTO{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled 
        public String humanId;
        @AuraEnabled
        public List<Provider> providers;
    }
    
    @AuraEnabled 
    public static RemoteCall_getHumanAPITokens.SessionTokenInfo getSessionToken(String participantEmail,String referralId,String humanId,String uniqueHumanId){    
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        
        RemoteCall_getHumanAPITokens remoteObj = new RemoteCall_getHumanAPITokens();
        if(participantState.pe != null && (!UserContext.getCurrentUserMode().hasPastStudies || (String.isBlank(referralId) && UserContext.getCurrentUserMode().hasPastStudies)))
        {
            participantEmail = participantState.pe.Participant__r.Email__c;
            referralId = participantState.pe.Id;
            humanId = participantState.pe.Human_Id__c;
            uniqueHumanId = participantState.pe.Unique_HumanId__c;
        }
        if(!String.isBlank(referralId) && UserContext.getCurrentUserMode().hasPastStudies)
        {
            //setting attributes for alumni
            String[] arrTest = referralId.split(':::');
            if(arrTest.size()>1)
            {
                uniqueHumanId = arrTest[0];
                referralId = arrTest[1];
                humanId ='EXIST';
                
            }
            
        }
        
        return remoteObj.remoteCallGetSessionToken(participantEmail,referralId,humanId,uniqueHumanId); 
    }
    
    @AuraEnabled
    public static RemoteCall_getHumanAPITokens.AccessTokenInfo getAccessToken(String referralId,String clientUserEmail,String uniqueHumanId){
        
        String referralRecordId;
        String uniqueId;
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        if(participantState.pe != null && String.isBlank(referralId)) 
        {
            clientUserEmail = participantState.pe.Participant__r.Email__c;
            referralRecordId = participantState.pe.Id;
            uniqueId = participantState.pe.Unique_HumanId__c;
            
            
        }
        if(!String.isBlank(referralId))
        {
            //setting attributes for alumni
            String[] arrTest = referralId.split(':::');
            if(arrTest.size()>1)
            {
                uniqueId = arrTest[0];
                referralRecordId = arrTest[1];
                
            }
            
        }
        
        
        
        return RemoteCall_getHumanAPITokens.getInstance().remoteCallGetAccessToken(referralRecordId,clientUserEmail,uniqueId);
    }
    
    
    
    
    
    @AuraEnabled
    public static List<Provider> getHumanSourcesList(String referralId,String clientUserEmail,String uniqueHumanId){
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        if(participantState.pe != null && String.isBlank(referralId)) 
        {
            clientUserEmail = participantState.pe.Participant__r.Email__c;
            uniqueHumanId = participantState.pe.Unique_HumanId__c;
            
        }
        
        RemoteCall_getHumanAPITokens.AccessTokenInfo accessToken = getAccessToken( referralId, clientUserEmail, uniqueHumanId);
        List<Provider> providersList = RemoteCall_getHumanAPIData.getHumanSources(accessToken.access_token);
        TokenService.storeToken(referralId, 'access', accessToken.access_token,null,accessToken.expires_in);
        return providersList;
        
    }
    
    
   
    @AuraEnabled
    public static List<LabelValueItem> getHumanAPIPastPEList(Id contactId)
    {
        
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        List<Id> ownidList= new List<Id>();
        if(participantState.pe != null && participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
            ownidList.add(participantState.pe.Id);
        } 
        
        String ownPEFilter ='(Human_Id__c != null OR Id IN '+DatabaseService.listToString(ownidList)+')  AND Participant__r.Contact__c IN ' + DatabaseService.listToString(new List<Id>{contactId}) +' order by CreatedDate desc';
        
        System.debug('ownPEFilter'+ownPEFilter);
        List<Participant_Enrollment__c> ownPEList = DatabaseService.query(
            new List<String>{ 'Id','Participant__c','Name', 'Participant__r.Contact__c','Clinical_Trial_Profile__r.Study_Code_Name__c','Human_Id__c','Unique_HumanId__c','Participant__r.Email__c'},
            Participant_Enrollment__c.getSObjectType(),
            ownPEFilter
        );
        
        List<LabelValueItem> labelItems = new List<LabelValueItem>();
        if(ownPEList.size()>0){
            
            for(Participant_Enrollment__c pe : ownPEList){
                if(participantState.pe != null) {
                if(!participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c)
                {
                    if(pe.Id == participantState.pe.Id)
                    {
                    continue;
                    }
                }
                }
                
                LabelValueItem labelItem = new LabelValueItem(pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Unique_HumanId__c+':::'+pe.Id);
                if(!labelItems.contains(labelItem))
                {
                    labelItems.add(labelItem);
                }
            }
            return labelItems;}
        return labelItems;
    }

        @AuraEnabled
    public static HumanAPIWrapper getHumanAPIAlunmiPastPEListRevamp(Id contactId)
    {
        try{
            HumanAPIWrapper hWrapper = new HumanAPIWrapper();
            ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
            String conId =  participantState.currentContactId;
            hWrapper.participantState = JSON.serialize(participantState);
            
            List<Participant_Enrollment__c> newPRList = [select id,Participant__c,Name,Participant__r.Contact__c,Participant_Status__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Human_Id__c,Unique_HumanId__c,Participant__r.Email__c from Participant_Enrollment__c where (Human_Id__c != null and Participant__r.Contact__c =: conId and Participant_Status__c in ('Failed Review','Failed Referral','Excluded from Referring','Unable to Reach','Eligibility Passed','Declined Final Consent','Withdrew Consent','Screening Failed','Unable to Screen','Enrollment Failed','Randomization Failed','Withdrew Consent After Screening','Drop Out','Participation Complete','Trial Complete')) ];
            List<LabelValueItem> labelItems = new List<LabelValueItem>();
            if(participantState.pe != null && participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c && !participantState.medicalVendors.isEmpty()){
                for(Medical_Record_Vendor__c vendor: participantState.medicalVendors){
                    if(vendor.Medical_Vendor__c == 'HumanAPI'){
                        LabelValueItem labelItem = new LabelValueItem(participantState.pe.Clinical_Trial_Profile__r.Study_Code_Name__c,participantState.pe.Unique_HumanId__c+':::'+participantState.pe.Id);
                        labelItems.add(labelItem);
                        break;
                    }
                }
                
            }
            List<LabelValueItem> aluminiItems = new List<LabelValueItem>();
            if(newPRList.size()>0){
                for(Participant_Enrollment__c pe : newPRList){
                     if(participantState.pe != null && participantState.pe.id == pe.id) {
                    	continue;
                	}
                    LabelValueItem labelItem = new LabelValueItem(pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Unique_HumanId__c+':::'+pe.Id);
                    
                    if(!aluminiItems.contains(labelItem))
                    {
                        aluminiItems.add(labelItem);
                    }
                }
            }
            if(!aluminiItems.isEmpty()){
                aluminiItems.sort();
                labelItems.addAll(aluminiItems);
            }
            hWrapper.referrals = labelItems; 
            
            hWrapper.communityName = FindCommunityName.getCommunityName();
            return hWrapper;
        } 
        catch(Exception ex){
            throw new AuraHandledException(ex.getStackTraceString());
        }
        
        
    }
    
 
    @AuraEnabled
    public static List<StudyProviderDTO> getStudyProviderList(String itemstr,String peId){
         //ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        List<LabelValueItem> items = (List<LabelValueItem>)JSON.deserialize(itemstr,List<LabelValueItem>.class); 
        List<StudyProviderDTO> studyProviders = new List<StudyProviderDTO>();
        try{
             system.debug('provided items:'+items);
        if(!items.isEmpty()){
            for(LabelValueItem item : items){
                system.debug(item.label);
                RemoteCall_getHumanAPITokens.AccessTokenInfo tokeninfo = getAccessToken(item.value,null,null);
                system.debug('returned security token:'+tokeninfo);
                  if(tokeninfo.access_token != null ){
                    List<Provider> provider = getHumanSourcesList(item.value,null,null);
                    system.debug('returned providers:'+provider);
                     if(!provider.isEmpty()|| (peId != null && item.value.contains(peId)))
                        studyProviders.add(getStudyProvider(item.value,item.label,provider));
                    }
                    else if(peId != null && item.value.contains(peId)){
                         studyProviders.add(getStudyProvider(item.value,item.label,new List<Provider>()));
                    }
                } 
           
            
            }
        } 
            
        
        catch(Exception ex){
            system.debug('exception testing mockcallOut Result:'+ex);
           
        }
       return studyProviders;  
       
    }
    
   
    public static StudyProviderDTO getStudyProvider(String value,String label,List<Provider> provider){
        
        StudyProviderDTO studyProvider = new StudyProviderDTO();
        studyProvider.value = value;
        List<String> valuebif = value.split(':::');
        if(valuebif.size() > 1){
             studyProvider.humanId  = valuebif[0];     
         }
        studyProvider.label = label;
        studyProvider.providers = provider;
        
        return studyProvider;
        
    }
 
/*
* ───────────────────────────────────────────────────────────────────────────────────────────────┐
* This method will return the current communityName
* ────────────────────────────────────────────────────────────────────────────────────────────────
* @Method:   getCommunityName
* @param:    NA
* @return:   Strings
* ───────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled
    public static String getCommunityName() {
        String communityName = FindCommunityName.getCommunityName();
        return communityName;
    }
    
}
