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
    public static void accpetTerms() {
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
        List<CommunityType> communityTypes;
        Boolean isDelegate;
        String state;
        String pathPrefix;
        Boolean isTCAccepted;
        String language;
        List<String> preventedCookies;
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
            cd.communityTypes = new List<CommunityFacadeRemote.CommunityType>();
            Set<String> availableModes = new Set<String>();
            if(HCPEnrollmentService.getHCPEnrollmentsForHCP(true).size() > 0) {
                availableModes.add(CommunityService.USER_MODE_HCP);
                cd.communityTypes.add( new CommunityType(CommunityService.USER_MODE_HCP,Label.CTL_L_HCP_MODE,''));
            }
            for(RP_Delegate_Relationship__c delegate : DelegateService.getHCPDelegates()){
                availableModes.add(CommunityService.USER_MODE_HCP + ';' + delegate.Referring_Provider__c);
                String RPFullName = delegate.Referring_Provider__r.Salutation + ' ' + delegate.Referring_Provider__r.Full_Name__c; //+ ' ' + delegate.Referring_Provider__r.Suffix;
                cd.communityTypes.add( new CommunityType(CommunityService.USER_MODE_HCP,Label.CTL_L_HCP_DELEGATE_MODE.replaceAll('##RPName',RPFullName),delegate.Referring_Provider__c));
            }
            if(StudySiteService.getStudySitesForPI().size() > 0){
                availableModes.add(CommunityService.USER_MODE_PI);
                cd.communityTypes.add( new CommunityType(CommunityService.USER_MODE_PI,Label.CTL_L_PI_MODE,''));
            }
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
            if(participantState.pe != null) {
                availableModes.add(CommunityService.USER_MODE_PARTICIPANT);
                cd.communityTypes.add( new CommunityType(CommunityService.USER_MODE_PARTICIPANT,Label.CTL_L_Patricipant_MODE,''));
            }
            if (availableModes.size() == 0) {
                if (userContact.userCommunityMode__c == CommunityService.USER_MODE_HCP) {
                    availableModes.add(CommunityService.USER_MODE_HCP);
                    cd.communityTypes.add( new CommunityType(CommunityService.USER_MODE_HCP,Label.CTL_L_HCP_MODE,''));
                }
            }
            if (!availableModes.contains(userContact.userCommunityMode__c + (userContact.userCommunityDelegateId__c==null
                    || userContact.userCommunityDelegateId__c ==''?'':';'+userContact.userCommunityDelegateId__c))) {
                userContact.userCommunityMode__c = null;
                userContact.userCommunityDelegateId__c = null;
                if (cd.communityTypes.size() > 0) {
                    userContact.userCommunityMode__c = cd.communityTypes[0].value;
                    userContact.userCommunityDelegateId__c = cd.communityTypes[0].delegateId;
                }
                upsert userContact;
            }
            cd.isTCAccepted = isTCAccepted();
            cd.communityMode = userContact.userCommunityMode__c;
            cd.communityDelegateId = userContact.userCommunityDelegateId__c!=null?userContact.userCommunityDelegateId__c:'';
            cd.state = participantState.value.name();
            cd.pathPrefix = Site.getPathPrefix();
            cd.language = UserInfo.getLanguage();
            cd.preventedCookies = getPreventedCookies(userContact.Id);
            cd.isDelegate = userContact.UserCommunityIsDelegate__c;

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
    public static void changeMode(String mode, String delegateId) {
        try {
            User user = [SELECT Id, Contact.userCommunityMode__c, Contact.userCommunityDelegateId__c , Contact.userCommunytyType__c, Contact.Id FROM User WHERE Id = :UserInfo.getUserId()];
            Contact cont = user.Contact;
            cont.userCommunityMode__c = mode;
            cont.userCommunityDelegateId__c = delegateId;
            update cont;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
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
