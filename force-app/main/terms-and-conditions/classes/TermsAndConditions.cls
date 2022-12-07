global without sharing class TermsAndConditions {
    public static final String COOKIE_TC_ID_SETTING = 'COOKIE_TC_ID_SETTING';
    public static final String PRIVACY_TC_ID_SETTING = 'PRIVACY_TC_ID_SETTING';
    public static final String PRIVACY_POLICY = 'Privacy Policy';
    public static final String TERMS_AND_CONDITIONS = 'Terms and Conditions';
    public static final String COOKIE_POLICY = 'Cookie Policy';

    public static Terms_And_Conditions__c getPortalTC(Boolean useDefaultCommunity) {
        return getTC(null, null, useDefaultCommunity);
    }

    public static Terms_And_Conditions__c getTrialTC(Id ctpId) {
        Clinical_Trial_Profile__c[] ctpList = [
            SELECT Terms_And_Conditions_ID__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :ctpId
        ];
        if (ctpList.size() > 0) {
            return getTC(ctpList[0].Terms_And_Conditions_ID__c, null, false);
        }
        return null;
    }

    public static Terms_And_Conditions__c getTC(
        Id tcId,
        String languageCode,
        Boolean useDefaultCommunity
    ) {
        if (String.isEmpty(languageCode))
            languageCode = UserInfo.getLanguage();
        String query = getTCQuery(tcId, languageCode, TERMS_AND_CONDITIONS, useDefaultCommunity);
        Terms_And_Conditions__c[] tcList = Database.query(query);
        if (tcList.size() > 0) {
            Terms_And_Conditions__c tc = tcList[0];
            if (tc.Terms_And_Conditions__r.size() > 0)
                tc.T_C_Text__c = tc.Terms_And_Conditions__r[0].T_C_Text__c;
            return tc;
        }
        return null;
    }

    public static String getTCQuery(
        Id tcId,
        String languageCode,
        String tcType,
        Boolean useDefaultCommunity
    ) {
        if (String.isEmpty(languageCode))
            languageCode = UserInfo.getLanguage();
        String query =
            ' SELECT Id, T_C_Text__c, Last_Updated_on__c,Policy_Headers__c,' +
            '   (SELECT Id, T_C_Text__c,Last_Updated_on__c,Policy_Headers__c FROM Terms_And_Conditions__r WHERE Language__c = \'' +
            languageCode +
            '\') ' +
            ' FROM Terms_And_Conditions__c' +
            ' WHERE ';
        String communityName = useDefaultCommunity
            ? CommunityService.IQVIA_NETWORK_NAME
            : UserContext.getCurrentCommunityName();
        System.debug('communityName: ' + communityName);
        //condition for  registration page links
        if (communityName != null) {
            if (communityName.containsIgnoreCase('terms')) {
                communityName = 'IQVIA Patient Portal';
            }
        } else {
            communityName = 'IQVIA Patient Portal';
        }
        if (tcId != null) {
            query += ' Id =\'' + tcId + '\' ';
        } else {
            query += ' Active__c = TRUE ';
            query += 'AND Community_Name__c =\'' + communityName + '\'';
        }
        if (tcType != null) {
            query += 'AND T_C_Type__c =\'' + tcType + '\'';
        }
        query += ' ORDER BY Name DESC LIMIT 1';
        System.debug('>>>QUERY: ' + query);
        return query;
    }

    @AuraEnabled
    public static Boolean isTCAccepted(Id tcId) {
        return getTCA(tcId) != null;
    }

    public static Map<Id, Boolean> getTrialsAcceptanceMap(List<Clinical_Trial_Profile__c> trials) {
        List<Id> tcIds = new List<Id>();
        for (Clinical_Trial_Profile__c trial : trials) {
            if (trial.Terms_And_Conditions_ID__c != null) {
                tcIds.add(trial.Terms_And_Conditions_ID__c);
            }
        }
        List<Terms_And_Conditions_Acceptance__c> tcAcceptances = [
            SELECT Id, Terms_And_Conditions__c
            FROM Terms_And_Conditions_Acceptance__c
            WHERE Terms_And_Conditions__c IN :tcIds AND User__c = :UserInfo.getUserId()
        ];
        //Map tcId -> tcaId
        Map<Id, Id> tcaMap = new Map<Id, Id>();
        for (Terms_And_Conditions_Acceptance__c tca : tcAcceptances) {
            tcaMap.put(tca.Terms_And_Conditions__c, tca.Id);
        }
        Map<Id, Boolean> resMap = new Map<Id, Boolean>();
        for (Clinical_Trial_Profile__c trial : trials) {
            if (trial.Terms_And_Conditions_ID__c != null) {
                resMap.put(trial.Id, tcaMap.get(trial.Terms_And_Conditions_ID__c) != null);
            }
        }
        return resMap;
    }

    public static Terms_And_Conditions_Acceptance__c getTCA(Id tcId) {
        List<Terms_And_Conditions_Acceptance__c> tcAcceptance = [
            SELECT Id, Accepted_Date__c
            FROM Terms_And_Conditions_Acceptance__c
            WHERE User__c = :UserInfo.getUserId() AND Terms_And_Conditions__c = :tcId
        ];
        if (tcAcceptance.size() > 0)
            return tcAcceptance[0];
        return null;
    }

    public static void acceptTC(Id tcId) {
        if (!isTCAccepted(tcId)) {
            Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c(
                Accepted_Date__c = Datetime.now(),
                Terms_And_Conditions__c = tcId,
                User__c = UserInfo.getUserId()
            );
            insert tca;
        }
    }

    public static Id getOrgDefaultTCbyCode(String code) {
        if (code.equals('CookiePolicy'))
            return getOrgDefaultCookieTC();
        return null;
    }

    public static Id getOrgDefaultCookieTC() {
        return (Id) SettingStoreService.getOrgDefault(COOKIE_TC_ID_SETTING);
    }

    public static Terms_And_Conditions__c getCookieTC(Boolean useDefaultCommunity) {
        String query = getTCQuery(null, null, COOKIE_POLICY, useDefaultCommunity);
        Terms_And_Conditions__c[] tcList = Database.query(query);
        if (tcList.size() > 0) {
            Terms_And_Conditions__c tc = tcList[0];
            if (tc.Terms_And_Conditions__r.size() > 0)
                tc.T_C_Text__c = tc.Terms_And_Conditions__r[0].T_C_Text__c;
            return tc;
        }
        return null;
    }

    public static void setOrgDefaultCookieTC(Id termsAndConditions) {
        SettingStoreService.saveOrgDefault(COOKIE_TC_ID_SETTING, termsAndConditions, Id.class);
    }

    public static Terms_And_Conditions__c getOrgDefaultPrivacyTC(Boolean useDefaultCommunity) {
        String query = getTCQuery(null, null, PRIVACY_POLICY, useDefaultCommunity);
        Terms_And_Conditions__c[] tcList = Database.query(query);
        if (tcList.size() > 0) {
            Terms_And_Conditions__c tc = tcList[0];
            if (tc.Terms_And_Conditions__r.size() > 0) {
                tc.T_C_Text__c = tc.Terms_And_Conditions__r[0].T_C_Text__c;
                tc.Last_Updated_on__c = tc.Terms_And_Conditions__r[0].Last_Updated_on__c;
                tc.Policy_Headers__c = tc.Terms_And_Conditions__r[0].Policy_Headers__c;
            }
            return tc;
        }
        return null;
    }

    public static Terms_And_Conditions__c getOrgDefaultPPTC(
        Boolean useDefaultCommunity,
        String ctId
    ) {
        Id ppTcId;
        String query;
        if (!String.isBlank(ctId) || ctId != null) {
            ppTcId = [
                SELECT Id, Privacy_Policy_Id__c
                FROM Clinical_Trial_Profile__c
                WHERE Id = :ctId
                LIMIT 1
            ]
            .Privacy_Policy_Id__c;
        }
        if (ppTcId != null) {
            query = getTCQuery(ppTcId, null, PRIVACY_POLICY, useDefaultCommunity);
        } else {
            query = getTCQuery(null, null, PRIVACY_POLICY, useDefaultCommunity);
        }

        Terms_And_Conditions__c[] tcList = Database.query(query);
        if (tcList.size() > 0) {
            Terms_And_Conditions__c tc = tcList[0];
            if (tc.Terms_And_Conditions__r.size() > 0) {
                tc.T_C_Text__c = tc.Terms_And_Conditions__r[0].T_C_Text__c;
                tc.Last_Updated_on__c = tc.Terms_And_Conditions__r[0].Last_Updated_on__c;
                tc.Policy_Headers__c = tc.Terms_And_Conditions__r[0].Policy_Headers__c;
            }
            return tc;
        }
        return null;
    }

    public static void setOrgDefaultPrivacyTC(Id termsAndConditions) {
        SettingStoreService.saveOrgDefault(PRIVACY_TC_ID_SETTING, termsAndConditions, Id.class);
    }
}
