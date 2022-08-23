global without sharing class LightningForgotPasswordController {
    public LightningForgotPasswordController() {
    }

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            List<User> u = [SELECT Id, TimeZoneSidKey FROM User WHERE Username = :username];
            if (!u.isEmpty()) {
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [
                    SELECT Id, Status, LoginTime
                    FROM LoginHistory
                    WHERE UserId = :u[0].Id
                    ORDER BY LoginTime DESC
                    LIMIT 10
                ];
                if (ul.IsPasswordLocked) {
                    DateTime lockoutTime = null;
                    for (LoginHistory loginAttempt : history) {
                        if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                            lockoutTime = loginAttempt.LoginTime;
                        }
                    }
                    return Label.PG_Login_Lockout_Error_Message.replace(
                        '##LockoutEndTime',
                        lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey)
                    );
                }
            }
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if (!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    @AuraEnabled
    public static String forgotPasswordCommunity(String username, String checkEmailUrl) {
        try {
            List<User> u = [SELECT Id, TimeZoneSidKey FROM User WHERE Username = :username];
            Map<String, String> returnMap = new Map<String, String>();
            if (!u.isEmpty()) {
                UserLogin ul = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId = :u[0].Id];
                List<LoginHistory> history = [
                    SELECT Id, Status, LoginTime
                    FROM LoginHistory
                    WHERE UserId = :u[0].Id
                    ORDER BY LoginTime DESC
                    LIMIT 10
                ];
                if (ul.IsPasswordLocked) {
                    DateTime lockoutTime = null;
                    for (LoginHistory loginAttempt : history) {
                        if (lockoutTime == null && loginAttempt.Status == 'Invalid Password') {
                            lockoutTime = loginAttempt.LoginTime;
                        }
                    }
                    if (Site.getPathPrefix().startsWith('/gsk')) {
                        return Label.PG_Login_Lockout_Error_Message.replace(
                            '##LockoutEndTime',
                            lockoutTime.addMinutes(16).format('hh:mm a', u[0].TimeZoneSidKey)
                        );
                    } else {
                        String timeDifference = String.valueof(
                            lockOutTime.addMinutes(15).getTime() - System.now().getTime()
                        );
                        returnMap.put('timeDifference', timeDifference);
                        return JSON.serialize(returnMap);
                    }
                }
            }
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if (!Site.isValidUsername(username)) {
                if (Site.getMasterLabel() == Label.IQVIA_Patient_Portal) {
                    returnMap.put('invalidEmail', Label.PP_Email_Error);
                    return JSON.serialize(returnMap);
                } else {
                    returnMap.put('invalidEmail', Label.PP_InvalidUsername);
                    return JSON.serialize(returnMap);
                }
            }
            if (Site.getPathPrefix().startsWith('/gsk')) {
                aura.redirect(checkEmailRef);
                return null;
            } else {
                return checkEmailUrl;
            }
        } catch (Exception ex) {
            return ex.getMessage();
        }
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
