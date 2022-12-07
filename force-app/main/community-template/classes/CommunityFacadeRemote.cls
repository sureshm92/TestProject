/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityFacadeRemote {
    public static final String COOKIE_FIELD_MARK = 'AllowedCookie__c';


    @AuraEnabled
    public static Boolean isFirstLogon() {
        return [SELECT Id, Contact.Is_First_Logon__c FROM User WHERE Id = :UserInfo.getUserId()]
        .Contact.Is_First_Logon__c;
    }

    @AuraEnabled
    public static void acceptTerms() {
        try {
            User user = [
                SELECT Id, Contact.Is_First_Logon__c, ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            Contact cont = [SELECT Id FROM Contact WHERE Id = :user.ContactId];
            cont.Is_First_Logon__c = false;
            update cont;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private class CommunityData {
        String communityMode;
        String communityDelegateId;
        Boolean isDelegate;
        String state;
        Boolean isTCAccepted;
        String language;
        List<String> preventedCookies;
        Boolean isNewSession;
        String baseUrl;
        String pathPrefix;
        String subDomain;
        List<CommunityMode> allUserModes;
        CommunityMode currentUserMode;
        Boolean isDummy;
        String communityName;
        String sponsorName;
        Boolean messagesVisible;
        Boolean trialMatchVisible;
        Boolean eDiaryVisible;
        Boolean isMobileApp;
        Boolean hasIQVIAStudiesPI;
    }
    @testvisible
    private class CommunityType {
        String value;
        String label;
        String delegateId;
        public CommunityType(String value, String label, String delegateId) {
            this.value = value;
            this.label = label;
            this.delegateId = delegateId;
        }
    }

    /**
     * Class, that contains all community user visibility. Please add your new visibility here
     */
    public class CommunityUserVisibility {
        @AuraEnabled
        public Boolean messagesVisible;
        @AuraEnabled
        public Boolean trialMatchVisible;
        @AuraEnabled
        public Boolean eDiaryVisible;
    }
    @AuraEnabled
    public static String getCommunityUrl() {
        return site.getMasterLabel();
    }

    @AuraEnabled
    public static String getCommunityData() {
        try {
            CommunityData cd = new CommunityData();
            cd.isDummy = UserContext.isDummyContact();
            if (!cd.isDummy) {
                Contact userContact = CommunityService.getUserContact();
                cd.communityMode = userContact.userCommunityMode__c;
                cd.communityDelegateId = userContact.userCommunityDelegateId__c != null
                    ? userContact.userCommunityDelegateId__c
                    : '';
                cd.isDelegate = userContact.UserCommunityIsDelegate__c;
                cd.allUserModes = UserContext.getAllUserModes();
                cd.state = ParticipantService.getParticipantState().value.name();
                cd.preventedCookies = getPreventedCookies(userContact.Id);
                cd.messagesVisible = getMessagesVisibility();
                cd.trialMatchVisible = getTrialMatchVisibility();
                cd.eDiaryVisible = getEDiaryVisibility();
            }
            cd.hasIQVIAStudiesPI = getHasIQVIAStudiesPI();
            cd.currentUserMode = UserContext.getCurrentUserMode();
            cd.subDomain = Site.getPathPrefix().replace('/s', '');
            cd.communityName = Site.getName();
            cd.sponsorName = getSponsorName(cd.currentUserMode.template.templateName);
            cd.baseUrl = Site.getBaseUrl();
            cd.pathPrefix = Site.getPathPrefix();
            cd.isTCAccepted = cd.isDummy || isTCAccepted();
            cd.language = UserInfo.getLanguage();
            cd.isMobileApp = false;

            return JSON.serialize(cd);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Boolean isDummyMode() {
        try {
            return UserContext.isDummyContact();
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static Boolean checkStudyMessage() {
        Id id = UserContext.getUserContactId();
        List<Id> idDel = DelegateService.getDelegatedStudySiteIds();
        String sponsorName = UserContext.getCurrentCommunityTemplate().templateName;
        String query = 'SELECT Id, Messages_Are_Available__c, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE  (Principal_Investigator__c =: id OR Id IN :idDel) AND ';
        if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            query +=
                'Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        } else {
            query +=
                'Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
                CommunityTemplateService.TEMPLATE_JANSSEN +
                '\' ';
        }
        List<Study_Site__c> studies = new List<Study_Site__c>();
        studies = Database.query(query);
        for (Study_Site__c study : studies) {
            if (study.Messages_Are_Available__c)
                return true;
        }
        return false;

        /*if (sponsorName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            List<Study_Site__c> studies = new List<Study_Site__c>([SELECT Id,
                                                                          Messages_Are_Available__c,
                                                                          Clinical_Trial_Profile__r.CommunityTemplate__c
                                                                   FROM   Study_Site__c
                                                                   WHERE  Principal_Investigator__c =: id
                                                                   AND    Clinical_Trial_Profile__r.CommunityTemplate__c =: CommunityTemplateService.TEMPLATE_JANSSEN ]);
            for (Study_Site__c study: studies) {
                if (study.Messages_Are_Available__c) return false;
            }
            return false;
           } else {
            List<Study_Site__c> studies = new List<Study_Site__c>([SELECT Id,
                                                                          Messages_Are_Available__c,
                                                                          Clinical_Trial_Profile__r.CommunityTemplate__c
                                                                   FROM   Study_Site__c
                                                                   WHERE  Principal_Investigator__c =: id
                                                                   AND    Clinical_Trial_Profile__r.CommunityTemplate__c !=: CommunityTemplateService.TEMPLATE_JANSSEN ]);
            for (Study_Site__c study : studies) {
                if (study.Messages_Are_Available__c) return true;
            }
            return true;
           }*/
    }

    @AuraEnabled
    public static CommunityUserVisibility getCommunityUserVisibility() {
        try {
            CommunityUserVisibility userVisibility = new CommunityUserVisibility();
            userVisibility.messagesVisible = getMessagesVisibility();
            userVisibility.trialMatchVisible = getTrialMatchVisibility();
            userVisibility.eDiaryVisible = getEDiaryVisibility();
            return userVisibility;
        } catch (Exception e) {
            return (CommunityUserVisibility) AuraHelper.throwException(e);
        }
    }

    private static List<String> getPreventedCookies(Id contactId) {
        List<String> preventedCookies = new List<String>();

        List<String> cookieFields = new List<String>();
        String commUrl = getCommunityUrl();
        //Map<String, Schema.SObjectField> fields = Contact.getSObjectType().getDescribe().fields.getMap();
        if (commUrl != null)
            if (commUrl.contains('Janssen Community')) {
                cookieFields.add('RRJanssenCookiesAllowedCookie__c');
                cookieFields.add('RRJanssenLanguageAllowedCookie__c');
            } else {
                cookieFields.add('RRCookiesAllowedCookie__c');
                cookieFields.add('RRLanguageAllowedCookie__c');
            }
        /*for (String currField : fields.keySet()) {
            String fieldName = fields.get(currField).getDescribe().getName();
            if (fieldName.endsWith(COOKIE_FIELD_MARK)) {
                cookieFields.add(fieldName);
            }
        } */

        if (!cookieFields.isEmpty()) {
            String query =
                'SELECT ' +
                String.join(cookieFields, ', ') +
                ' FROM Contact WHERE Id = \'' +
                contactId +
                '\'';
            List<Contact> currContacts = Database.query(query);
            if (!currContacts.isEmpty()) {
                Contact currContact = currContacts[0];
                for (String cookieField : cookieFields) {
                    if ((Boolean) currContact.get(cookieField) == false) {
                        String cookieName = extractCookieName(cookieField);
                        if (cookieName != null) {
                            preventedCookies.add(cookieName);
                        }
                    }
                }
            }
        }

        return preventedCookies;
    }

    public static String extractCookieName(String fieldName) {
        if (String.isNotBlank(fieldName)) {
            Integer pos = fieldName.indexOf(COOKIE_FIELD_MARK);
            String res = fieldName.substring(0, pos);
            return res;
        } else {
            return null;
        }
    }

    public static Boolean isTCAccepted() {
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC(false);
        if (portalTC != null)
            return TermsAndConditions.isTCAccepted(portalTC.Id);
        return true;
    }

    @AuraEnabled
    public static Boolean getMessagesVisibility() {
        Contact userContact = CommunityService.getUserContact();
        List<Conversation__c> conversations = new List<Conversation__c>();
        List<Participant_Enrollment__c> peWithAvailableMessages = new List<Participant_Enrollment__c>();
        List<Id> peIds = new List<Id>();
        CommunityMode communityMode = UserContext.getCurrentUserMode();

        if (communityMode.currentPE != null)
            peIds.add(communityMode.currentPE);
        if (communityMode.hasPastStudies) {
            Id currentContactId = userContact.Id;
            if (communityMode.isDelegate) {
                currentContactId = PatientDelegateService.getParticipantByDelegateContactId(
                        currentContactId
                    )
                    .Contact__c;
            }
            List<Id> pastPEs = PatientDelegateService.getPastPEIdsForContact(currentContactId);
            if (pastPEs != null)
                peIds.addAll(pastPEs);
        }

        if (!peIds.isEmpty()) {
            conversations = [
                SELECT Id
                FROM Conversation__c
                WHERE Participant_Enrollment__c IN :peIds
            ];

            peWithAvailableMessages = [
                SELECT Id
                FROM Participant_Enrollment__c
                WHERE Id IN :peIds AND Study_Site__r.Messages_Are_Available__c = TRUE
            ];
        }

        if (conversations.isEmpty() && peWithAvailableMessages.isEmpty())
            return false;
        return true;
    }

    private static Boolean getTrialMatchVisibility() {
        if (ParticipantContext.getCurrentPEId() != null) {
            return ParticipantContext.getCurrentPE()
                    .Clinical_Trial_Profile__r.Trial_Match_Is_Available__c &&
                ParticipantService.getParticipantState().value ==
                ParticipantService.ParticipantStates.PARTICIPANT;
        }
        return false;
    }
    // set visibility for eDiary tab for patient when eCOA toggle is on at CTP level.
    private static Boolean getEDiaryVisibility() {
        if (ParticipantContext.getCurrentPEId() != null) {
            return ParticipantContext.getCurrentPE()
                    .Clinical_Trial_Profile__r.ECOA_Is_Avaialble__c &&
                ParticipantService.getParticipantState().value ==
                ParticipantService.ParticipantStates.PARTICIPANT;
        }
        return false;
    }
    @testVisible
    private static String getSponsorName(String communityName) {
        String sponsorName = null;
        Map<String, String> rhSponsorsByCommunity = CommunityModeService.rhSponsorsByCommunity;
        if (rhSponsorsByCommunity.containsKey(communityName)) {
            sponsorName = rhSponsorsByCommunity.get(communityName);
        }
        return sponsorName;
    }

    @AuraEnabled
    public static Contact changeMode(String mode, Id delegateId, Id peId, String communityName) {
        try {
            Contact userContact = CommunityService.getUserContact();
            userContact.userCommunityMode__c = mode;
            userContact.userCommunityDelegateId__c = delegateId;
            if (mode == CommunityService.USER_MODE_PARTICIPANT)
                userContact.Current_Participant_Enrollment__c = peId;
            if (mode == CommunityService.USER_MODE_PI)
                userContact.Current_Sponsor_Name__c = communityName;
            update userContact;
            return userContact;
        } catch (Exception e) {
            return (Contact) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPreferredLanguageCode(String browserLanguages) {
        try {
            if (UserInfo.getUserType() != 'Guest')
                return 'Skip';
            return TranslateHelper.convertBrowserLanguage(
                (List<String>) JSON.deserialize(browserLanguages, List<String>.class)
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static String getLocalizedURL(String defaultURL) {
        String lang = UserInfo.getLanguage();
        lang = lang.replace('_', '-');
        String url1 = defaultURL + '-' + lang;
        String url2 = defaultURL + '-' + lang.split('-')[0];
        System.debug('URL1: ' + url1);
        System.debug('URL2: ' + url2);
        if (urlExists(url1)) {
            return url1;
        } else if (urlExists(url2)) {
            return url2;
        }
        return defaultURL;
    }

    public static Boolean urlExists(String url) {
        try {
            if (Test.isRunningTest())
                return true;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
            return res.getStatusCode() == 200;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean isCurrentSessionMobileApp() {
        Boolean isMobileApp = false;
        List<AuthSession> sessions = [
            SELECT Id, IsCurrent, LoginHistory.Browser, LoginHistory.Application, LastModifiedDate
            FROM AuthSession
            WHERE UsersId = :UserContext.getUserId() AND IsCurrent = TRUE
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        if (!sessions.isEmpty() && sessions[0].LoginHistory != null) {
            LoginHistory history = sessions[0].LoginHistory;
            if (history.Browser != null && history.Application != null) {
                isMobileApp = (!history.Application.equals('Browser') ||
                history.Browser.equals('Unknown Mobile Browser') ||
                history.Browser.equals('Unknown Webkit Mobile'));
            }
        }
        return isMobileApp;
    }

    private static Boolean getHasIQVIAStudiesPI() {
        if (CommunityService.getUserContact() == null) {
            return false;
        }
        List<Id> delegatedSites = DelegateService.getDelegatedStudySiteIds();

        return [
                SELECT Id
                FROM Study_Site__c
                WHERE
                    (Clinical_Trial_Profile__r.CommunityTemplate__c = :CommunityTemplateService.TEMPLATE_DEFAULT
                    OR Clinical_Trial_Profile__r.CommunityTemplate__c = :CommunityTemplateService.TEMPLATE_PP
                    OR Clinical_Trial_Profile__r.CommunityTemplate__c = :CommunityTemplateService.TEMPLATE_GSK)
                    AND (Id IN :delegatedSites
                    OR Principal_Investigator__c = :UserContext.getUserContactId())
            ]
            .size() > 0;
    }
//RH-6579/RH-6581 - Bell Notification - Start Changes
    //Get SessionID
    @AuraEnabled(Cacheable=true)
    public static Map<String,string> getSessionId() {
        Map<string,string> getId = new Map<string,string>();
        String sessionId = UserInfo.getOrganizationId()+','+UserInfo.getSessionId();
        getId.put('sessionId',sessionId);
        String userID = UserInfo.getUserId();
        User u = [SELECT u.Id,u.ContactId,u.IsActive
                  FROM User u
                  WHERE u.Id =: userID AND u.IsActive =: true];
        getId.put('userId',u.ContactId);
        return getId;
    }

    // Get Send Results records for Logged in User
    @AuraEnabled
    public static SendResultWrapper getSendResults(Id contactId, String isExecute){
        SendResultWrapper sendResultWrap= new SendResultWrapper();
        List<Send_Result__c> listOfSendResult = new List<Send_Result__c>();
        List<Send_Result__c> listOfResult = new List<Send_Result__c>();
        List<LoginHistory> lstLoginHistory = new List<LoginHistory>();
        Id userId = UserInfo.getUserId();
        Integer numberOfEnrollments = 0;
        String query = 'SELECT Id, Clinical_Trial_Profile__r.Study_Code_Name__c, Study_Site__c, Clinical_Trial_Profile__c FROM Participant_Enrollment__c WHERE Study_Site__c IN :lstOfStudySite AND CreatedById != :userId'+
                        ' AND Participant_Status__c IN (\'Received\',\'Pre-review Passed\',\'Contact Attempted\',\'Successfully Contacted\',\'Screening In Progress\',\'Screening In Progress - Wash Out Period\',\'Screening Passed\','+
                        ' \'Eligibility Passed\',\'Ready to Screen\',\'Participant No Show\',\'Successfully re-engaged\',\'Randomization Success\',\'Enrollment Success\') AND Participant__r.Present_Age__c >= 0 AND Participant__r.Present_Age__c <= 150';
        List<Study_Site__c> lstOfStudySite = new List<Study_Site__c>();
        DateTime userLogin1;
        DateTime userLogin2;
        List<Participant_Enrollment__c> lstOfEnrollment = new List<Participant_Enrollment__c>();
        List<Notification__c> lstOfNotification = new List<Notification__c>();
        String communityType = UserContext.getCurrentUserMode().template.templateName;
        String userRole = UserContext.getCurrentUserMode().userMode;
        Map<String, List<Participant_Enrollment__c>> mapOfProtocolVsEnrollment = new Map<String, List<Participant_Enrollment__c>>();
        Map<String, Set<String>> mapOfStudyVsSite = new Map<String, Set<String>>();
        Map<String, String> mapOfStudyVsStringSite = new Map<String, String>();

        if(contactId != null){
            listOfResult = [SELECT Id,CreatedById,CreatedDate,Is_Active__c,Is_Read__c,Link_to_Related_Event_or_Object__c,
                            Msg_Id__c,Name,Notification__r.Notification_Type__c,Notification__c,Push_Message_Body__c,
                            Push_Message_Title__c,Status__c,Target_Type__c
                            FROM Send_Result__c
                            WHERE (Is_Active__c = true)
                            AND (Notification__r.Recipient__r.Id =:contactId)
                            AND ( CreatedDate = LAST_N_DAYS:30)
                            AND Community_Type__c = :communityType
                            AND User_Role__c = :userRole
                            ORDER BY CreatedDate DESC];
        }

        if(!String.isBlank(isExecute) && Boolean.valueOf(isExecute)){
            lstOfStudySite = [SELECT Id FROM Study_Site__c
                              WHERE Clinical_Trial_Profile__r.CommunityTemplate__c =: communityType
                              AND (Principal_Investigator__c = :contactId OR ID IN :DelegateService.getDelegatedStudySiteIds())];

            DateTime userCreatedDate = [SELECT CreatedDate FROM User WHERE ID = :userId][0].CreatedDate;

            lstLoginHistory = [SELECT Id, LoginTime, Status, LoginUrl FROM LoginHistory WHERE UserId = :userId AND NetworkId <> null ORDER BY LoginTime DESC];
            List<LoginHistory> lstOfSuccess = new List<LoginHistory>();

            for(LoginHistory eachRec : lstLoginHistory){
                if(eachRec.Status == 'Success' && eachRec.LoginUrl.containsIgnoreCase(communityType)){
                    lstOfSuccess.add(eachRec);
                    if(lstOfSuccess.size() == 2){
                        break;
                    }
                }else if(eachRec.Status == 'Success' && communityType.equalsIgnoreCase('Default') && eachRec.LoginUrl.containsIgnoreCase('com/s/login')){
                    lstOfSuccess.add(eachRec);
                    if(lstOfSuccess.size() == 2){
                        break;
                    }
                }
            }
            if(lstOfSuccess.size() == 1){
                userLogin1 = lstOfSuccess[0].LoginTime;
                query += ' AND CreatedDate >= :userCreatedDate AND CreatedDate <= :userLogin1 LIMIT 45000';
            }

            if(lstOfSuccess.size() == 2){
                userLogin1 = lstOfSuccess[0].LoginTime;
                userLogin2 = lstOfSuccess[1].LoginTime;
                query += ' AND CreatedDate <= :userLogin1 AND CreatedDate >= :userLogin2 LIMIT 45000';
            }

            lstOfEnrollment = Database.Query(query);

            if(lstOfEnrollment.size() > 0){
                for(Participant_Enrollment__c eachRec :lstOfEnrollment){
                    if(!mapOfProtocolVsEnrollment.containsKey(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c)){
                        mapOfProtocolVsEnrollment.put(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c, new List<Participant_Enrollment__c>{});
                    }
                    mapOfProtocolVsEnrollment.get(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c).add(eachRec);

                    if(!mapOfStudyVsSite.containsKey(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c)){
                        mapOfStudyVsSite.put(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c, new Set<String>{});
                    }
                    mapOfStudyVsSite.get(eachRec.Clinical_Trial_Profile__r.Study_Code_Name__c).add(eachRec.Study_Site__c);
                }

                for(String eachRec : mapOfStudyVsSite.keySet()){
                    mapOfStudyVsStringSite.put(eachRec, String.join(new List<String>(mapOfStudyVsSite.get(eachRec)), '+'));
                }

                sendResultWrap.mapOfProtocolVsEnrollment = mapOfProtocolVsEnrollment;
                for (String eachProtocol : mapOfProtocolVsEnrollment.keySet()) {
                    Notification__c notificationRec = BellNotificationsHelper.createNotification('BELL_Message_on_New_Referrals', contactId, userRole, communityType, false);
                    lstOfNotification.add(notificationRec);
                }

                if(lstOfNotification.size() > 0){
                     TriggerHandlerExecutor.bypassHandler(
                        NotificationTriggerHandler.CheckFieldsHandler.class
                    );
                    insert lstOfNotification;
                    Map<String, String> mapOfInfo = new Map<String, String>();
                    for(String eachStudy : mapOfProtocolVsEnrollment.keySet()){
                        for(Notification__c eachRec : lstOfNotification){
                            if(!mapOfInfo.containsKey(eachRec.Id)){
                                mapOfInfo.put(eachRec.Id, eachStudy+'#'+mapOfProtocolVsEnrollment.get(eachStudy).size()+'#'+mapOfProtocolVsEnrollment.get(eachStudy)[0].Clinical_Trial_Profile__c+'#'+mapOfStudyVsStringSite.get(eachStudy));
                                break;
                            }
                        }
                    }
                    Id jobId = System.enqueueJob(new BellNotificationQueueable(lstOfNotification, mapOfInfo));
                }
            }
        }

		List<Send_Result__c> listOfAllSendResult = new List<Send_Result__c>();
		if(listOfResult.size() > 0){
          sendResultWrap.allSendResult = listOfResult;
          return sendResultWrap;
        }
        return null;
    }

    // Update the Send Result for soft delete for a user
    @AuraEnabled
    public static Send_Result__c isActivate(Id sendResultId){
        try{
            if(sendResultId != null){
                Send_Result__c sendRes = new Send_Result__c(Id = sendResultId, Is_Active__c = false, Is_Read__c = true);
                update sendRes;
                return sendRes;
            }else {
                return null;
            }
        }
        catch(Exception e){
            System.debug('Error Occured while Updation==' + e.getMessage());
            return null;
        }
    }

    // Update the Send Result Record as Read by the user
    @AuraEnabled
    public static Send_Result__c updateReadNotification(Id sendResultId){
        try{
            if(sendResultId != null){
                Send_Result__c sendRes = new Send_Result__c(Id = sendResultId, Is_Read__c = true, Is_Active__c = true);
                update sendRes;
                return sendRes;
            }else{
                return null;
            }
        }
        catch(Exception e){
            System.debug('Error Occured while Updation==' + e.getMessage());
            return null;
        }
    }

    public class SendResultWrapper {
        @AuraEnabled
        public List<Send_Result__c> allSendResult;
        @AuraEnabled
        public List<Send_Result__c> newReferralsSendResult;
        @AuraEnabled
        public Map<String, List<Participant_Enrollment__c>> mapOfProtocolVsEnrollment;
    }
//RH-6579/RH-6581 - Bell Notification - End Changes
}