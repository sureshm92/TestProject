/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityFacadeRemote {
    public static String COOKIE_FIELD_MARK = 'AllowedCookie__c';
    
    @AuraEnabled
    public static Boolean isFirstLogon() {
        return [SELECT Id, Contact.Is_First_Logon__c FROM User WHERE Id = :UserInfo.getUserId()].Contact.Is_First_Logon__c;
    }
    
    @AuraEnabled
    public static void acceptTerms() {
        try {
            User user = [SELECT Id, Contact.Is_First_Logon__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
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
        String pathPrefix;
        Boolean isTCAccepted;
        Boolean messagesVisible;
        String language;
        List<String> preventedCookies;
        Boolean isNewSession;
        String baseUrl;
        List<CommunityMode> allUserModes;
        CommunityMode currentUserMode;
        Boolean isDummy;
        String communityName;
        String subDomain;
        Boolean trialMatchFeature;
        String participantCurrentStatus;
       
    }
    
    private class CommunityType{
        String value;
        String label;
        String delegateId;
        public CommunityType(String value, String label, String delegateId){
            this.value = value;
            this.label = label;
            this.delegateId = delegateId;
        }
    }
    
    @AuraEnabled
    public static String getCommunityData() {
        try {
            Contact userContact = CommunityService.getUserContact();
            CommunityData cd = new CommunityData();
            cd.isDummy = UserContext.isDummyContact();
            cd.allUserModes = UserContext.getAllUserModes();
            cd.currentUserMode = UserContext.getCurrentUserMode();
            cd.isTCAccepted = cd.isDummy || isTCAccepted();
            cd.communityMode = userContact.userCommunityMode__c;
            cd.communityDelegateId = userContact.userCommunityDelegateId__c!=null?userContact.userCommunityDelegateId__c:'';
            cd.state = ParticipantService.getParticipantState().value.name();
            cd.pathPrefix = Site.getPathPrefix();
            cd.language = UserInfo.getLanguage();
            cd.preventedCookies = getPreventedCookies(userContact.Id);
            cd.isDelegate = userContact.UserCommunityIsDelegate__c;
            cd.baseUrl = Site.getBaseUrl();
            cd.messagesVisible = getMessagesVisibility();
            cd.communityName = Site.getName();
            cd.subDomain = Site.getPathPrefix().replace('/s', '');
            cd.trialMatchFeature = userContact.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.Trial_Match_Is_Available__c;
		
		    cd.participantCurrentStatus=userContact.Current_Participant_Enrollment__r.Participant_Status__c;
         
            return JSON.serialize(cd);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    private static List<String> getPreventedCookies(Id contactId) {
        List<String> preventedCookies = new List<String>();
        
        List<String> cookieFields = new List<String>();
        Map<String, Schema.SObjectField> fields = Contact.getSObjectType().getDescribe().fields.getMap();
        for (String currField : fields.keySet()) {
            String fieldName = fields.get(currField).getDescribe().getName();
            if (fieldName.endsWith(COOKIE_FIELD_MARK)) {
                cookieFields.add(fieldName);
            }
        }
        
        if (!cookieFields.isEmpty()) {
            String query = 'SELECT ' + String.join(cookieFields, ', ') + ' FROM Contact WHERE Id = \'' + contactId + '\'';
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
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC();
        if (portalTC != null) return TermsAndConditions.isTCAccepted(portalTC.Id);
        return true;
    }

    @AuraEnabled
    public static Boolean getMessagesVisibility() {
        Contact userContact = CommunityService.getUserContact();
        List<Conversation__c> conversations = new List<Conversation__c>();
        List<Participant_Enrollment__c> peWithAvailableMessages = new List<Participant_Enrollment__c>();
        List<Id> peIds = new List<Id>();
        CommunityMode communityMode = UserContext.getCurrentUserMode();

        if(communityMode.currentPE != null) peIds.add(communityMode.currentPE);
        if(communityMode.hasPastStudies) {
            Id currentContactId = userContact.Id;
            if(communityMode.isDelegate) {
                currentContactId = PatientDelegateService.getParticipantByDelegateContactId(currentContactId).Contact__c;
            }
            List<Id> pastPEs = PatientDelegateService.getPastPEIdsForContact(currentContactId);
            if(pastPEs != null) peIds.addAll(pastPEs);
        }

        if (!peIds.isEmpty()) {
            conversations = [ SELECT Id FROM Conversation__c WHERE Participant_Enrollment__c IN: peIds];

            peWithAvailableMessages = [
                    SELECT Id FROM Participant_Enrollment__c
                    WHERE Id IN: peIds AND Study_Site__r.Messages_Are_Available__c = TRUE
            ];
        }

        if(conversations.isEmpty() && peWithAvailableMessages.isEmpty()) return false;
        return true;
    }

    @AuraEnabled
    public static Contact changeMode(String mode, Id delegateId, Id peId) {
        try {
            Contact userContact = CommunityService.getUserContact();
            userContact.userCommunityMode__c = mode;
            if(mode == CommunityService.USER_MODE_HCP) userContact.userCommunityDelegateId__c = delegateId;
            if(mode == CommunityService.USER_MODE_PARTICIPANT) {
                userContact.Current_Participant_Enrollment__c = peId;
                userContact.userCommunityDelegateId__c = delegateId;
            }
            update userContact;
            return userContact;
        } catch (Exception e) {
            return (Contact)AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static Contact getUserContact() {
       
            Contact userContact = CommunityService.getUserContact();
             return userContact;
        
    }
    
    @AuraEnabled
    public static String getPreferredLanguageCode(String browserLanguages) {
        try {
            return TranslateHelper.convertBrowserLanguage((List<String>) JSON.deserialize(browserLanguages, List<String>.class));
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
        try{
            if (Test.isRunningTest()) return true;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
            return res.getStatusCode() == 200;
        }catch (Exception e){
            return false;
        }
    }

}