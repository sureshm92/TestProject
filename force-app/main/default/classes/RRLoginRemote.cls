/**
 * Created by Leonid Bartenev
 */

global without sharing class RRLoginRemote {
    public static Integer lockoutMinutes = 15;
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            List<User> loginUser = [
                SELECT
                    Id,
                    ContactId,
                    Contact.Email,
                    Contact.Current_Participant_Enrollment__c,
                    Contact.userCommunityDelegateId__c,
                    Contact.UserCommunityIsDelegate__c,
                    Contact.userCommunityMode__c,
                    Contact.Landing_Community__c
                FROM User
                WHERE UserName = :username
                LIMIT 1
            ];
            //When porspect who is delegate of a participant logs in the community
            if (
                !loginUser.isEmpty() && loginUser[0].Contact.userCommunityMode__c == 'Participant'
            ) {
                Contact c = new Contact(
                    Id = loginUser[0].ContactId,
                    //set Current_Participant_Enrollment__c to null
                    Current_Participant_Enrollment__c = null,
                    //set userCommunityDelegateId__c to null
                    userCommunityDelegateId__c = null,
                    //set the Landing_Community__c based on the Site
                    Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH')
                        ? CommunityService.IQVIA_NETWORK_NAME
                        : Site.getMasterLabel()
                );
                update c;
            }
            aura.redirect(lgn);
            return null;
        } catch (Exception ex) {
            List<User> u = [
                SELECT Id, TimeZoneSidKey, isPasswordLocked__c
                FROM User
                WHERE Username = :username
            ];
            if (!u.isEmpty()) {
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [
                    SELECT Id, Status, LoginTime
                    FROM LoginHistory
                    WHERE UserId = :u[0].Id
                    ORDER BY LoginTime DESC
                    LIMIT 100
                ];
                if (ul.IsPasswordLocked) {
                    DateTime lockoutTime = null;
                    for (LoginHistory loginAttempt : history) {
                        if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                            lockoutTime = loginAttempt.LoginTime;
                        }
                    }
                    if (!u[0].isPasswordLocked__c) {
                        u[0].isPasswordLocked__c = true;
                        Database.update(u[0]);
                        Site.forgotPassword(username);
                    }
                    return Label.PG_Login_Lockout_Error_Message.replace(
                        '##LockoutEndTime',
                        lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey)
                    );
                } else if (!history.isEmpty() && history[0].Status == 'Invalid Password') {
                    Integer attempts = 0;
                    if (u[0].isPasswordLocked__c) {
                        u[0].isPasswordLocked__c = false;
                        Database.update(u[0]);
                    }
                    while (
                        attempts < history.size() &&
                        history[attempts].Status == 'Invalid Password'
                    ) {
                        attempts++;
                    }
                    if (attempts > 5) {
                        attempts = math.mod(attempts, 5);
                    }
                    String forgotPasswordLink =
                        '<a class="no-float" href="' +
                        getForgotPasswordUrl() +
                        '">' +
                        Label.PG_Login_L_here_link +
                        '</a>';
                    return Label.PG_Login_Wrong_Password_Error_Message.replace(
                            '##AttemptsLeft',
                            String.valueOf(5 - attempts)
                        )
                        .replace('##ForgotPasswordLink', forgotPasswordLink);
                } else {
                    return ex.getMessage();
                }
            } else {
                return ex.getMessage();
            }
        }
    }
    public String getCommunityPatientUrl() {
        String url =  CommunityService.getCommunityURLFromTemplateName('PatientPortal');
        url = url+'/s';
        return url ;
    }
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl(String username) {
        List<User> u = [
            SELECT Id, TimeZoneSidKey, isPasswordLocked__c
            FROM User
            WHERE Username = :username
        ];
        if (!u.isEmpty()) {
            UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
            List<LoginHistory> history = [
                SELECT Id, Status, LoginTime
                FROM LoginHistory
                WHERE UserId = :u[0].Id
                ORDER BY LoginTime DESC
                LIMIT 100
            ];
            if (ul.IsPasswordLocked) {
                DateTime lockoutTime = null;
                for (LoginHistory loginAttempt : history) {
                    if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                        lockoutTime = loginAttempt.LoginTime;
                    }
                }
                if (!u[0].isPasswordLocked__c) {
                    u[0].isPasswordLocked__c = true;
                    Database.update(u[0]);
                    Site.forgotPassword(username);
                }
                return '**return' +
                    Label.PG_Login_Lockout_Error_Message.replace(
                        '##LockoutEndTime',
                        lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey)
                    );
            }
        }
        return '**url' + getForgotPasswordUrl();
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    @AuraEnabled
    public static String getCommunityURL(String communityName) {
        return CommunityTemplateService.getCommunityURL(communityName);
    }

    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig() {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * This method will return the current communityName
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @Method:   getCommunityName
     * @param:    NA
     * @return:   String
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     **/
    @auraEnabled
    public static String getCommunityName() {
        Id networkId = Network.getNetworkId();
        String communityName = [SELECT Id, Name FROM Network WHERE Id = :networkId].Name;
        return communityName;
    }

    @AuraEnabled
    public static Map<String, Long> isUserPasswordLocked(String userName) {
        Map<String, Long> passwordLockMap = new Map<String, Long>();
        try {
            if (!String.isBlank(userName)) {
                List<User> portalUser = [
                    SELECT Id, TimeZoneSidKey, isPasswordLocked__c
                    FROM User
                    WHERE Username = :userName
                    LIMIT 1
                ];
                if (!portalUser.isEmpty()) {
                    UserLogin usrLogin = [
                        SELECT IsPasswordLocked
                        FROM UserLogin
                        WHERE UserId = :portalUser[0].Id
                    ];
                    List<LoginHistory> history = [
                        SELECT Id, Status, LoginTime
                        FROM LoginHistory
                        WHERE UserId = :portalUser[0].Id
                        ORDER BY LoginTime DESC
                        LIMIT 100
                    ];
                    if (usrLogin.IsPasswordLocked) {
                        DateTime lockoutTime = null;
                        for (LoginHistory loginAttempt : history) {
                            if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                                lockoutTime = loginAttempt.LoginTime;
                                passwordLockMap.put(
                                    'TimeDifference',
                                    lockOutTime.addMinutes(lockoutMinutes).getTime() -
                                    System.now().getTime()
                                );
                            }
                        }
                        if (!portalUser[0].isPasswordLocked__c) {
                            portalUser[0].isPasswordLocked__c = true;
                            Database.update(portalUser[0]);
                            Site.forgotPassword(username);
                        }

                        return passwordLockMap;
                    }
                }
            }
            return passwordLockMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> communityLogin(
        String userName,
        String password,
        String startUrl
    ) {
        //Key: startUrl, lockoutError, wrongPasswordError, exception
        Map<String, String> returnMap = new Map<String, String>();
        try {
            ApexPages.PageReference pageRef = Site.login(userName, password, startUrl);
            List<User> loginUser = [
                SELECT
                    Id,
                    ContactId,
                    Contact.Email,
                    Contact.Current_Participant_Enrollment__c,
                    Contact.userCommunityDelegateId__c,
                    Contact.UserCommunityIsDelegate__c,
                    Contact.userCommunityMode__c,
                    Contact.Landing_Community__c
                FROM User
                WHERE UserName = :username
                LIMIT 1
            ];
            //PEH-2038 & PEH-2008: When porspect who is a delegate of a participant logs in to the community
            if (
                !loginUser.isEmpty() && loginUser[0].Contact.userCommunityMode__c == 'Participant'
            ) {
                Contact c = new Contact(
                    Id = loginUser[0].ContactId,
                    //set Current_Participant_Enrollment__c to null
                    Current_Participant_Enrollment__c = null,
                    //set userCommunityDelegateId__c to null
                    userCommunityDelegateId__c = null,
                    //set the Landing_Community__c based on the Site
                    Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH')
                        ? CommunityService.IQVIA_NETWORK_NAME
                        : Site.getMasterLabel()
                );
                update c;
            }
            returnMap.put('startUrl', pageRef.getUrl());
        } catch (Exception ex) {
            List<User> u = [
                SELECT Id, TimeZoneSidKey, isPasswordLocked__c
                FROM User
                WHERE Username = :username
            ];
            if (!u.isEmpty()) {
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [
                    SELECT Id, Status, LoginTime
                    FROM LoginHistory
                    WHERE UserId = :u[0].Id
                    ORDER BY LoginTime DESC
                    LIMIT 100
                ];
                if (ul.IsPasswordLocked) {
                    DateTime lockoutTime = null;
                    for (LoginHistory loginAttempt : history) {
                        if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                            lockoutTime = loginAttempt.LoginTime;
                        }
                    }
                    if (!u[0].isPasswordLocked__c) {
                        u[0].isPasswordLocked__c = true;
                        Database.update(u[0]);
                        Site.forgotPassword(username);
                    }
                    returnMap.put('lockoutError', 'lockout');
                    returnMap.put(
                        'TimeDifference',
                        String.valueof(
                            lockOutTime.addMinutes(lockoutMinutes).getTime() -
                            System.now().getTime()
                        )
                    );
                } else if (!history.isEmpty() && history[0].Status == 'Invalid Password') {
                    Integer attempts = 0;
                    if (u[0].isPasswordLocked__c) {
                        u[0].isPasswordLocked__c = false;
                        Database.update(u[0]);
                    }
                    while (
                        attempts < history.size() &&
                        history[attempts].Status == 'Invalid Password'
                    ) {
                        attempts++;
                    }
                    if (attempts > 5) {
                        attempts = math.mod(attempts, 5);
                    }
                    if (Site.getMasterLabel() == Label.IQVIA_Patient_Portal) {
                        returnMap.put(
                            'wrongPasswordError',
                            Label.PP_Login_Wrong_Password_Error_Message.replace(
                                '##AttemptsLeft',
                                String.valueOf(5 - attempts)
                            )
                        );
                    } else {
                    String forgotPasswordLink =
                        '<a class="no-float" href="' +
                        getForgotPasswordUrl() +
                        '">' +
                        Label.PG_Login_L_here_link +
                        '</a>';
                    returnMap.put(
                        'wrongPasswordError',
                        Label.PG_Login_Wrong_Password_Error_Message.replace(
                                '##AttemptsLeft',
                                String.valueOf(5 - attempts)
                            )
                            .replace('##ForgotPasswordLink', forgotPasswordLink)
                    );
                }
            }
        }
            returnMap.put('exception', ex.getMessage());
            return returnMap;
        }
        return returnMap;
    }
    
   public static Organization getOrganization(){
        Organization  orgObj    = [Select id,IsSandbox,InstanceName,OrganizationType, Name from Organization];
        return orgObj;
    }

    public static Boolean isSandbox(){
        Organization  orgObj = getOrganization();
        return orgObj.IsSandbox;
    }

    public static String getSandboxName(){
        String        domainUrl = Url.getOrgDomainUrl().toExternalForm();
        System.Domain domain    = System.DomainParser.parse(domainUrl);
        String        sandboxName = domain.getSandboxName();
        return sandboxName;
    }
    public class SSODataWrapper{
            @AuraEnabled
            public String patientAuthProviderURL;
            @AuraEnabled
            public Boolean isSSOEnabled;
            @AuraEnabled            
            public String ssoUrl;
            @AuraEnabled
            Public Boolean usrNameExist;
            @AuraEnabled
            Public Boolean isValidPPUser;   
    }
    @AuraEnabled
    public static SSODataWrapper getSSOData(String userName,String state){ 
        try {
        SSODataWrapper sso = new SSODataWrapper();
        List<User> u = new List<User>();
        //List<String> PE_STATUS_GROUP_ALUMNI = PEStatusState.PE_STATUS_GROUP_ALUMNI;
        //List<String> PE_STATUS_GROUP_FAILED = PEStatusState.PE_STATUS_GROUP_FAILED;
        List<String> PE_STATUS_GROUP_ACTIVE = PEStatusState.PE_STATUS_GROUP_ACTIVE;
        List<Participant_Enrollment__c> validPE = new List<Participant_Enrollment__c>();
        List<Patient_Delegate_Enrollment__c> validPDER = new List<Patient_Delegate_Enrollment__c>();
        Boolean isSSO_PE_Active=false;
        Boolean isSSO_PE_InActive=false;
        Boolean isNSSO_PE_Active=false;
        Boolean isNSSO_PE_InActive=false;
        u = [Select Id,ContactId,Name,Username,IsActive,Email from User where Username=:userName AND IsActive = TRUE];
        if(!u.isEmpty() && u[0].ContactId != null){
         validPE = [SELECT Id,Name,Participant_Contact__c,Participant_Status__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.SSO_enabled__c, 
                       Clinical_Trial_Profile__r.PPTemplate__c FROM Participant_Enrollment__c where 
                       Participant_Contact__c=:u[0].ContactId AND ((Clinical_Trial_Profile__r.CommunityTemplate__c ='PatientPortal') OR
                       (Clinical_Trial_Profile__r.CommunityTemplate__c ='Janssen' AND Clinical_Trial_Profile__r.PPTemplate__c ='PP 2.0'))];
        validPDER = [Select Id,Participant_Enrollment__c,Patient_Delegate__c,Patient_Delegate__r.Contact__c from Patient_Delegate_Enrollment__c where 
                         Patient_Delegate__r.Contact__c=:u[0].ContactId AND ((Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ='PatientPortal') OR
                         (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ='Janssen' AND Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c ='PP 2.0')) ];  
        }
        if(!u.isEmpty() && u[0].ContactId != null && (!validPE.isEmpty() || !validPDER.isEmpty())){
            String url;
            String ssoLanguage = 'en';
            Boolean isSocialIDP = false;
            String signInEmail = u[0].Email;
            String spSelection=isSocialIDP?'sp':'false';
            List<Participant_Enrollment__c> per = new List<Participant_Enrollment__c>();
            List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
            
            List<Participant_Enrollment__c> ssoPE = new List<Participant_Enrollment__c>();
            List<Participant_Enrollment__c> nonssoPE = new List<Participant_Enrollment__c>();
            List<Id> lstPEId= new List<Id>();
            List<Participant_Enrollment__c> listPDER_PE = new List<Participant_Enrollment__c>();
           
                    
            if(!validPE.isEmpty() || !validPDER.isEmpty()){}
            per = [SELECT Id,Name,Participant_Contact__c,Participant_Status__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.SSO_enabled__c, 
                   Clinical_Trial_Profile__r.PPTemplate__c FROM Participant_Enrollment__c where 
                   Participant_Contact__c=:u[0].ContactId];
            pder  = [Select Id,Participant_Enrollment__c,Patient_Delegate__c,Patient_Delegate__r.Contact__c from Patient_Delegate_Enrollment__c where 
                         Patient_Delegate__r.Contact__c=:u[0].ContactId];
            if(!pder.isEmpty() && pder !=null ){
                for(Patient_Delegate_Enrollment__c pde:pder){
                    lstPEId.add(pde.Participant_Enrollment__c);
                }
                listPDER_PE = [SELECT Id,Name,Participant_Contact__c,Participant_Status__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__r.SSO_enabled__c, 
                   Clinical_Trial_Profile__r.PPTemplate__c FROM Participant_Enrollment__c where Id IN:lstPEId];
                per.addAll(listPDER_PE);    
            }       
            if(!per.isEmpty() && per!=null ){
                    for(Participant_Enrollment__c pe:per){
                        if(pe.Clinical_Trial_Profile__r.SSO_enabled__c && ((pe.Clinical_Trial_Profile__r.CommunityTemplate__c =='PatientPortal') ||
                           (pe.Clinical_Trial_Profile__r.CommunityTemplate__c =='Janssen' && pe.Clinical_Trial_Profile__r.PPTemplate__c =='PP 2.0')))
                          {
                              ssoPE.add(pe);
                              if(PE_STATUS_GROUP_ACTIVE.Contains(pe.Participant_Status__c)){
                                  isSSO_PE_Active = true;
                                  }else{isSSO_PE_InActive = true;}
                              
                          }else{
                              nonssoPE.add(pe);
                              if(PE_STATUS_GROUP_ACTIVE.Contains(pe.Participant_Status__c)){
                                  isNSSO_PE_Active= true;
                                  }else{isNSSO_PE_InActive=true;}
                          }
                     }
                     
                     
                if(!ssoPE.isEmpty() && isSSO_PE_Active){
                     sso.isSSOEnabled = true;
                }else if(!ssoPE.isEmpty() && isSSO_PE_InActive){
                        if(!nonssoPE.isEmpty() && isNSSO_PE_Active){
                             sso.isSSOEnabled = false;
                        }else{sso.isSSOEnabled = true;}
                }else{
                    sso.isSSOEnabled = false;
                }       
                
                sso.usrNameExist = true;
                if(sso.isSSOEnabled){
                    //AzureB2CAuthProvider__mdt authData=AzureB2CAuthProvider__mdt.getInstance('Patient_SSO');
                    List<AzureB2CAuthProvider__mdt> authData = new List<AzureB2CAuthProvider__mdt>();
                    authData = [Select MasterLabel, 
                                              Auth_Url__c,Policy__c,Consumer_Key__c,Redirect_Url__c from AzureB2CAuthProvider__mdt where MasterLabel='Patient_SSO'];
                    url=System.label.SSO_Sign_in_Url; 
                    String redirectUrl = authData[0].Redirect_Url__c;
                    redirectUrl = EncodingUtil.urlEncode(redirectUrl, 'UTF-8');
                    redirectUrl = redirectUrl.replace ('+', '%2Fpp');
        
                    //List<Object> urlData = new List<Object>{authData[0].Auth_Url__c,authData[0].Policy__c,authData[0].Consumer_Key__c,authData[0].Redirect_Url__c,state,signInEmail,ssoLanguage,u[0].Username,spSelection};
                    List<Object> urlData = new List<Object>{authData[0].Auth_Url__c,authData[0].Policy__c,authData[0].Consumer_Key__c,redirectUrl,state,signInEmail,ssoLanguage,u[0].Username,spSelection};
                    url=String.format(url, urlData);
                    sso.ssoUrl=url+'&prompt=select_account';
                }
            }else{
                sso.usrNameExist = false;
                 sso.isSSOEnabled = false;
            }
            sso.patientAuthProviderURL=RRLoginRemote.getPatientSsoUrl();
            return sso;
        }else{
             sso.usrNameExist = false;
             sso.isSSOEnabled = false;
             return sso;
        }
      } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    } 
    @AuraEnabled
    public static String getPatientSsoUrl(){
      
        Boolean isSandbox = RRLoginRemote.isSandbox();
        String  sandboxName = isSandbox ? RRLoginRemote.getSandboxName() : '';
        String  ssoUrl = '';
        if(isSandbox){
            //SSO_OrgSpecificMetadata__mdt orgSpecificMetadata = SSO_OrgSpecificMetadata__mdt.getInstance(sandboxName);
            List<SSO_OrgSpecificMetadata__mdt> orgSpecificMetadata = new List<SSO_OrgSpecificMetadata__mdt >();
            orgSpecificMetadata = [Select MasterLabel, 
                                          Patient_Auth_Provider_URL__c from SSO_OrgSpecificMetadata__mdt where MasterLabel=:sandboxName];
            if(!orgSpecificMetadata.isEmpty()){ 
            ssoUrl = orgSpecificMetadata[0].Patient_Auth_Provider_URL__c;
            }else{
                ssoUrl = 'null';
            }
            
        }else{
            ssoUrl = 'null';
        }
        
        return ssoUrl;
    }
}