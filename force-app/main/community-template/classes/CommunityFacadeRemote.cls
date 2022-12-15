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
        ParticipantService.ParticipantState participantData;
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
                cd.participantData = ParticipantService.getParticipantState();
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
}
