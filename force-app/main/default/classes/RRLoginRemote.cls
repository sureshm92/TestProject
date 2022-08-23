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
}
