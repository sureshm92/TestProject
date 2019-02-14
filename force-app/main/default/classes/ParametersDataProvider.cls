/**
 * Created by Leonid Bartenev
 *
 * Email Template Parameters Data Provider
 *
 */

public class ParametersDataProvider {
    
    public static final String DEFAULT_LANGUAGE = 'en_US';
    
    public Map<String, String> parameters;
    public String userMode;
    public Boolean isDelegate = false;
    public List<DelegateLevelWrapper> delegateLevelsPI = new List<DelegateLevelWrapper>();
    public List<DelegateLevelWrapper> delegateLevelsHCP = new List<DelegateLevelWrapper>();
    
    
    
    public ParametersDataProvider(Id sourceId, String userType, String outputMode){
        userMode = userType;
        if(sourceId != null){
            if (sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                initParamsFromPE(sourceId);
            } else if (sourceId.getSobjectType() == HCP_Enrollment__c.getSObjectType()) {
                initParamsFromHCPE(sourceId);
            } else if (sourceId.getSobjectType() == Study_Site__c.getSObjectType()) {
                initParamsFromSS(sourceId);
            } else if(sourceId.getSobjectType() == Contact.getSObjectType()){
                initParamsFromContact(sourceId);
            } else if(sourceId.getSobjectType() == User.getSObjectType()){
                initParamsFromUser(sourceId);
            }
        }else{
            initDummyParams();
        }
        
        String clinicalResearchCommunityURL = 'IQVIA Clinical Research Community at https://www.clinicalresearch.com';
        if(outputMode == 'HTML') clinicalResearchCommunityURL = '<a href="https://www.clinicalresearch.com" target="_blank">IQVIA Clinical Research Community</a>';
        parameters.put('CRCommunityURL', clinicalResearchCommunityURL);
        
        System.debug('PARAMS: ' + JSON.serializePretty(parameters));
    }
    
    private void initParamsFromPE(Id sourceId){
        Participant_Enrollment__c pe = [
                SELECT Id, Name,
                        HCP__r.HCP_Contact__c,
                        HCP__r.HCP_Contact__r.Name,
                        HCP__r.HCP_Contact__r.Salutation,
                        HCP__r.HCP_Contact__r.Language__c,
                        Participant__r.Contact__c,
                        Participant__r.Contact__r.Name,
                        Participant__r.Contact__r.Salutation,
                        Participant__r.Contact__r.Language__c,
                        Participant__r.Language_Preference_Code__c,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Study_Site__r.Name,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Salutation,
                        Study_Site__r.Principal_Investigator__r.Language__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Study_Site_Phone__c,
                        Is_Virtual_Study_Site__c,
                        HCP__c
                FROM Participant_Enrollment__c
                WHERE Id =: sourceId OR Participant__r.Contact__c =: sourceId LIMIT 1
        ];
        
        parameters = new Map<String, String>{
                'PIName' => getFullContactName(pe.Study_Site__r.Principal_Investigator__r),
                'PILanguage' => pe.Study_Site__r.Principal_Investigator__r.Language__c,
                'ParticipantName' => getFullParticipantName(pe.Participant__r),
                'ParticipantLanguage' => getParticipantLanguage(pe.Participant__r),
                'IsVirtual' => pe.Is_Virtual_Study_Site__c + ''
        };
        
        if(pe.HCP__c != null){
            parameters.putAll(new Map<String, String>{
                    'HCPName' => getFullContactName(pe.HCP__r.HCP_Contact__r),
                    'HCPLanguage' => pe.HCP__r.HCP_Contact__r.Language__c
            });
        }
    
        TranslateHelper.translate(pe, getUserLanguage());
    
        parameters.putAll(new Map<String, String>{
                'PEName' => pe.Name,
                'StudyName' => pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => pe.Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                'StudySiteName' => pe.Study_Site__r.Name,
                'HCP' => pe.HCP__c,
                'SitePhoneNumber' => pe.Study_Site__r.Study_Site_Phone__c
        });
    }
    
    private void initParamsFromHCPE(Id hcpeId){
        HCP_Enrollment__c hcpe = [
                SELECT Id, Name,
                        HCP_Contact__r.Name,
                        HCP_Contact__r.Salutation,
                        HCP_Contact__r.Language__c,
                        Study_Site__r.Name,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Principal_Investigator__r.Language__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Salutation,
                        Study_Site__r.Study_Site_Phone__c,
                        HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id = :hcpeId
        ];
    
        parameters = new Map<String, String>{
                'GuestName' => TranslateHelper.getLabelValue('Email_Guest_User_Name'),
                'GuestLanguage' => hcpe.HCP_Contact__r.Language__c,
                'PIName' =>  getFullContactName(hcpe.Study_Site__r.Principal_Investigator__r),
                'HCPName' => getFullContactName(hcpe.HCP_Contact__r),
                'PILanguage' => hcpe.Study_Site__r.Principal_Investigator__r.Language__c,
                'HCPLanguage' => hcpe.HCP_Contact__r.Language__c
        };
    
        TranslateHelper.translate(hcpe, getUserLanguage());
    
        parameters.putAll(new Map<String, String>{
                'StudySiteName' => hcpe.Study_Site__r.Name,
                'StudyName' => hcpe.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => hcpe.Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                'SitePhoneNumber' => hcpe.Study_Site__r.Study_Site_Phone__c
        });
        

    }
    
    private void initParamsFromSS(Id ssId){
        Study_Site__c ss = [
                SELECT Id, Name,
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.Salutation,
                        Principal_Investigator__r.Language__c,
                        Principal_Investigator__c,
                        Clinical_Trial_Profile__r.Study_Title__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site_Phone__c
                FROM Study_Site__c
                WHERE Id = :ssId
        ];
    
        parameters = new Map<String, String>{
                'PIName' => getFullContactName(ss.Principal_Investigator__r),
                'PILanguage' => ss.Principal_Investigator__r.Language__c
        };
    
        TranslateHelper.translate(ss, getUserLanguage());
    
        parameters.putAll(new Map<String, String>{
                'StudySiteName' => ss.Name,
                'StudyName' => ss.Clinical_Trial_Profile__r.Study_Code_Name__c,
                'StudyTitle' => ss.Clinical_Trial_Profile__r.Study_Title__c,
                'SitePhoneNumber' => ss.Study_Site_Phone__c
        });

    }
    
    private void initParamsFromContact(Id contactId){
        Contact cnt = [
                SELECT Id, Name, Salutation,
                        Language__c,
                        userCommunityMode__c,
                        UserCommunityIsDelegate__c
                FROM Contact
                WHERE Id =: contactId
        ];
        initDelegates(cnt);
        isDelegate = cnt.UserCommunityIsDelegate__c;
        userMode = cnt.userCommunityMode__c;
        if(userMode == CommunityService.USER_MODE_PI){
            parameters = new Map<String, String>{
                    'PIName' => getFullContactName(cnt),
                    'PILanguage' => cnt.Language__c
            };
    
        }else if(userMode == CommunityService.USER_MODE_HCP){
            parameters = new Map<String, String>{
                    'HCPName' => getFullContactName(cnt),
                    'HCPLanguage' => cnt.Language__c
            };
        }else{
            initParamsFromPE(contactId);
        }
    }
    
    private void initParamsFromUser(Id userId){
        User user = [SELECT Id, ContactId FROM User WHERE Id =: userId];
        initParamsFromContact(user.ContactId);
    }
    
    public String getUserName(){
        String userNameParam = userMode + 'Name';
        return parameters.get(userNameParam);
    }
    
    public String getUserLanguage(){
        String langParam = userMode + 'Language';
        String language = parameters.get(langParam);
        if(language != null) return language;
        return DEFAULT_LANGUAGE;
    }
    
    private void initDummyParams(){
        List<Email_Dummy_Parameter__mdt> mparams = [SELECT Id, Label, Value__c FROM Email_Dummy_Parameter__mdt];
        parameters = new Map<String, String>();
        for(Email_Dummy_Parameter__mdt mparam : mparams) parameters.put(mparam.Label, mparam.Value__c);
    }
    
    private void initDelegates(Contact cnt) {
        //delegated by PI
        List<Site_Staff__c> siteStaffs = [
                SELECT toLabel(Delegate_Level__c),
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c
                FROM Site_Staff__c
                WHERE Site_Contact__c = :cnt.Id
        ];
        TranslateHelper.translate(siteStaffs, cnt.Language__c);
        for (Site_Staff__c PIDelegate : siteStaffs) {
            DelegateLevelWrapper dlw = new DelegateLevelWrapper();
            dlw.level = PIDelegate.Delegate_Level__c;
            dlw.studyName = PIDelegate.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
            delegateLevelsPI.add(dlw);
        }
        delegateLevelsPI.sort();
        
        //delegated by HCP
        List<Referring_HCP_Staff__c> hcpStaffs = [
                SELECT toLabel(Delegate_Level__c),
                        HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c,
                        HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                        HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c
                FROM Referring_HCP_Staff__c
                WHERE Contact__c = :cnt.Id
        ];
        TranslateHelper.translate(hcpStaffs, cnt.Language__c);
        for (Referring_HCP_Staff__c HCPDelegate : hcpStaffs) {
            DelegateLevelWrapper dlw = new DelegateLevelWrapper();
            dlw.level = HCPDelegate.Delegate_Level__c;
            dlw.studyName = HCPDelegate.HCP_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
            delegateLevelsHCP.add(dlw);
        }
        delegateLevelsHCP.sort();
    }
    
    private String getFullContactName(Contact c){
        String fullName = c.Name;
        if(c.Salutation != null) fullName = c.Salutation + ' ' + fullName;
        return fullName;
    }
    
    private String getFullParticipantName(Participant__c participant){
        List<String> nameParts = new List<String>();
        if(participant.First_Name__c != null) nameParts.add(participant.First_Name__c);
        if(participant.Last_Name__c != null) nameParts.add(participant.Last_Name__c);
        return String.join(nameParts, ' ');
    }
    
    private String getParticipantLanguage(Participant__c participant){
        String participantLanguage = participant.Contact__r.Language__c;
        if(participant.Contact__c == null) participantLanguage = participant.Language_Preference_Code__c;
        return participantLanguage;
    }
  
}