/**
 * Created by Leonid Bartenev
 */

global without sharing class RRLoginRemote {

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            
            //PEH-2038 & PEH-2008: When porspect who is delegate of a participant logs in the community,
            //set the Landing_Community__c based on the Site
            //set userCommunityDelegateId__c to null 
            //set Current_Participant_Enrollment__c to null 
            User loginUser = [SELECT Id, ContactId, Contact.Email, Contact.Current_Participant_Enrollment__c,
                              Contact.userCommunityDelegateId__c, Contact.UserCommunityIsDelegate__c, 
                              Contact.Landing_Community__c
                              FROM User WHERE UserName =: username limit 1];
            List<Participant_Enrollment__c> loginUserPEs = [SELECT Id FROM Participant_Enrollment__c WHERE Participant_Contact__c = : loginUser.ContactId ];
            //No participant enrollment and UserCommunityIsDelegate__c to ensure the 
            //contact is a prospect and delegate of a certain contact
            if(loginUserPEs.isEmpty() && loginUser.Contact.UserCommunityIsDelegate__c){
                Contact c= new Contact(Id = loginUser.ContactId, 
                                       Current_Participant_Enrollment__c = null, 
                                       userCommunityDelegateId__c = null,
                                       Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH') ? CommunityService.IQVIA_NETWORK_NAME : Site.getMasterLabel());
                update c;
            }
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            List<User> u = [SELECT Id, TimeZoneSidKey, isPasswordLocked__c FROM User WHERE Username = :username];
            if(!u.isEmpty()){
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [SELECT Id, Status, LoginTime FROM LoginHistory WHERE UserId = :u[0].Id ORDER BY LoginTime DESC LIMIT 100];
                if(ul.IsPasswordLocked){
                    DateTime lockoutTime = null;
                    for( LoginHistory loginAttempt : history){
                        if(lockoutTime == null && loginAttempt.Status == 'Invalid Password'){
                            lockoutTime = loginAttempt.LoginTime;
                        }

                    }
                    if(!u[0].isPasswordLocked__c){
                        u[0].isPasswordLocked__c = true;
                        Database.update(u[0]);
                        Site.forgotPassword(username);
                    }
                    return Label.PG_Login_Lockout_Error_Message.replace('##LockoutEndTime',lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey));

                }
                else if(!history.isEmpty() && history[0].Status == 'Invalid Password'){
                    Integer attempts = 0;
                    if(u[0].isPasswordLocked__c){
                        u[0].isPasswordLocked__c = false;
                        Database.update(u[0]);
                    }
                    while (attempts<history.size() && history[attempts].Status == 'Invalid Password'){
                        attempts++;
                    }
                    if(attempts > 5){
                        attempts = math.mod(attempts,5);
                    }
                    String forgotPasswordLink = '<a class="no-float" href="'+getForgotPasswordUrl() + '">'+Label.PG_Login_L_here_link + '</a>';
                    return Label.PG_Login_Wrong_Password_Error_Message.replace('##AttemptsLeft',String.valueOf(5-attempts)).replace('##ForgotPasswordLink',forgotPasswordLink);
                }
                else{
                    return ex.getMessage();
                }

            }
            else{
            return ex.getMessage();
        }

        }
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
                    List<User> u = [SELECT Id, TimeZoneSidKey, isPasswordLocked__c FROM User WHERE Username = :username];
            if(!u.isEmpty()){
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [SELECT Id, Status, LoginTime FROM LoginHistory WHERE UserId = :u[0].Id ORDER BY LoginTime DESC LIMIT 100];
                if(ul.IsPasswordLocked){
                    DateTime lockoutTime = null;
                    for( LoginHistory loginAttempt : history){
                        if(lockoutTime == null && loginAttempt.Status == 'Invalid Password'){
                            lockoutTime = loginAttempt.LoginTime;
                        }

                    }
                    if(!u[0].isPasswordLocked__c){
                        u[0].isPasswordLocked__c = true;
                        Database.update(u[0]);
                        Site.forgotPassword(username);
                    }
                    return '**return' + Label.PG_Login_Lockout_Error_Message.replace('##LockoutEndTime',lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey));

                }
            }
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return '**url' + authConfig.getForgotPasswordUrl();
    }    
    
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
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

}