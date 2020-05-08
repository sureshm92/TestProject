/**
 * Created by Leonid Bartenev
 */

global without sharing class RRLoginRemote {

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
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