/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityFacadeRemote {

    @AuraEnabled
    public static Boolean isFirstLogon(){
        return [SELECT Id, Contact.Is_First_Logon__c FROM User WHERE Id =: UserInfo.getUserId()].Contact.Is_First_Logon__c;
    }

    @AuraEnabled
    public static void accpetTerms(){
        try {
            User user =[SELECT Id, Contact.Is_First_Logon__c, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
            Contact cont = [SELECT Id FROM Contact WHERE Id =: user.ContactId];
            cont.Is_First_Logon__c = false;
            update cont;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private class CommunityData{
        String communityMode;
        List<String> communityTypes;
        String pathPrefix;
        Boolean isTCAccepted;
        String language;
    }

    @AuraEnabled
    public static String getCommunityData(){
        try {
            Contact userContact = CommunityService.getUserContact();
            CommunityData cd = new CommunityData();
            Set<String> availableModes = new Set<String>();
            if(HCPEnrollmentService.getHCPEnrollmentsForHCP().size() > 0) availableModes.add(CommunityService.USER_MODE_HCP);
            if(StudySiteService.getStudySitesForPI().size() > 0) availableModes.add(CommunityService.USER_MODE_PI);
            if(ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant().size() > 0) availableModes.add(CommunityService.USER_MODE_PARTICIPANT);
            List<String> modesList = new List<String>(availableModes);
            if(!availableModes.contains(userContact.userCommunityMode__c)) {
                userContact.userCommunityMode__c = null;
                if(modesList.size() > 0) userContact.userCommunityMode__c = modesList[0];
                upsert userContact;
            }
            cd.isTCAccepted  = isTCAccepted();
            cd.communityMode = userContact.userCommunityMode__c;
            cd.communityTypes = modesList;
            cd.pathPrefix = Site.getPathPrefix();
            cd.language = UserInfo.getLanguage();
            return JSON.serialize(cd); 
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static Boolean isTCAccepted(){
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC();
        if(portalTC != null) return TermsAndConditions.isTCAccepted(portalTC.Id);
        return true;
    }


    @AuraEnabled
    public static void changeMode(String mode){
        try {
            User user =[SELECT Id, Contact.userCommunityMode__c, Contact.userCommunytyType__c, Contact.Id FROM User WHERE Id =: UserInfo.getUserId()];
            Contact cont = user.Contact;
            cont.userCommunityMode__c = mode;
            update cont;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        } 
    }
    
    @AuraEnabled
    public static String getPreferredLanguageCode(String browserLanguages){
        try{
            return TranslateHelper.convertBrowserLanguage((List<String>)JSON.deserialize(browserLanguages, List<String>.class));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static String getLocalizedURL(String defaultURL){
        String lang = UserInfo.getLanguage();
        lang = lang.replace('_', '-');
        String url1 = defaultURL + '-' + lang;
        String url2 = defaultURL + '-' + lang.split('-')[0];
        System.debug('URL1: ' + url1);
        System.debug('URL2: ' + url2);
        if(urlExists(url1)){
            return url1;
        }else if(urlExists(url2)){
            return url2;
        }
        return defaultURL;
        
    }
    public static Boolean urlExists(String url){
        if(Test.isRunningTest()) return true;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getStatusCode() == 200;
    }
    
}