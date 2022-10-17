public class MedicalRecordAccessRemote {
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
