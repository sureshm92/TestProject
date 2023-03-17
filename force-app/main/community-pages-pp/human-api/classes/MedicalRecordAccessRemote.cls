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
    public static HumanAPIWrapper getHumanAPIAlunmiPastPEListRevamp()
    {
        try{
            HumanAPIWrapper hWrapper = new HumanAPIWrapper();
            //Listing all Alumini status
            List<String> aluminiStatus = new List<String>{'Failed Review','Failed Referral','Excluded from Referring','Unable to Reach','Eligibility Passed','Declined Final Consent','Withdrew Consent','Screening Failed','Unable to Screen','Enrollment Failed','Randomization Failed','Withdrew Consent After Screening','Drop Out','Participation Complete','Trial Complete'};     
            //fatching contactId for running user
            Id contactId = [Select Id,contactId from user where Id =: userInfo.getUserId() ].contactId;
            //fetching contact for running user
            Contact userContact = [Select id,userCommunityDelegateId__c,Current_Participant_Enrollment__c from Contact where id =:contactId];
            //populate current contact details
            hWrapper.currentContactId = (userContact.userCommunityDelegateId__c != null) ? userContact.userCommunityDelegateId__c : contactId;
            //populate current PER Id
            hWrapper.currentPerId =  userContact.Current_Participant_Enrollment__c;
            
            Participant_Enrollment__c currentPer;
            List<Medical_Record_Vendor__c> medicalVendors;
            if(hWrapper.currentPerId != null){
                currentPer = [Select Id,Unique_HumanId__c,Participant_Status__c,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Study_Site__c from Participant_Enrollment__c where Id=:hWrapper.currentPerId];
                if(aluminiStatus.contains(currentPer.Participant_Status__c)){
                         hWrapper.currentPerStatus = 'ALUMINI';
                }
                medicalVendors =  MedicalRecordVendorPanelRemote.getVendors(
                    currentPer.Study_Site__c
                );         
            }
            else if(hWrapper.currentPerId ==  null){
                hWrapper.currentPerStatus = 'ALUMINI';
            }
            
            List<Participant_Enrollment__c> newPRList = [select id,Participant__c,Name,Participant__r.Contact__c,Participant_Status__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Human_Id__c,Unique_HumanId__c,Participant__r.Email__c from Participant_Enrollment__c where (Human_Id__c != null and Participant__r.Contact__c =: hWrapper.currentContactId and Participant_Status__c IN :aluminiStatus ) ];
            
            List<LabelValueItem> labelItems = new List<LabelValueItem>();
            //adding current Active study in list
            if(hWrapper.currentPerId != null && currentPer.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c && !medicalVendors.isEmpty()){
                for(Medical_Record_Vendor__c vendor: medicalVendors){
                    if(vendor.Medical_Vendor__c == 'HumanAPI'){
                        LabelValueItem labelItem = new LabelValueItem(currentPer.Clinical_Trial_Profile__r.Study_Code_Name__c,currentPer.Unique_HumanId__c+':::'+currentPer.Id);
                        labelItems.add(labelItem);
                        break;
                    }
                }           
            }
            List<LabelValueItem> aluminiItems = new List<LabelValueItem>();
            //adding past/Alumini Studies
            if(newPRList.size()>0){
                for(Participant_Enrollment__c pe : newPRList){
                    if(hWrapper.currentPerId != null && hWrapper.currentPerId == pe.id){
                        continue;
                    }
                    LabelValueItem labelItem = new LabelValueItem(pe.Clinical_Trial_Profile__r.Study_Code_Name__c,pe.Unique_HumanId__c+':::'+pe.Id);
                    if(!aluminiItems.contains(labelItem)){
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
            system.debug('Something went wrong:'+ex.getMessage()+'/'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    
    @AuraEnabled
    public static List<StudyProviderDTO> getStudyProviderList(String itemstr,String peId,String status){
        List<LabelValueItem> items = (List<LabelValueItem>)JSON.deserialize(itemstr,List<LabelValueItem>.class); 
        List<StudyProviderDTO> studyProviders = new List<StudyProviderDTO>();
        try{
            if(!items.isEmpty()){
                for(LabelValueItem item : items){
                    system.debug(item.label);
                    // API call to get access token
                    RemoteCall_getHumanAPITokens.AccessTokenInfo tokeninfo = getAccessToken(item.value,null,null);
                    if(tokeninfo.access_token != null ){
                        //API call to get Providers
                        List<Provider> provider = getHumanSourcesList(item.value,null,null);
                        if(!provider.isEmpty()|| (peId != null && item.value.contains(peId) && status != 'ALUMINI'))
                            studyProviders.add(getStudyProvider(item.value,item.label,provider));
                    }
                    else if(peId != null && item.value.contains(peId) && status != 'ALUMINI'){
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
    
   
    //Method to map data in wrapper format
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
