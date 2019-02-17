global without sharing class TermsAndConditions {

    public static Terms_And_Conditions__c getPortalTC(){
        return getTC(null, null);
    }
    
    public static Terms_And_Conditions__c getTrialTC(Id ctpId){
        Clinical_Trial_Profile__c [] ctpList = [
                SELECT Terms_And_Conditions_ID__c
                FROM Clinical_Trial_Profile__c
                WHERE Id =: ctpId
        ];
        if(ctpList.size() > 0) {
            return getTC(ctpList[0].Terms_And_Conditions_ID__c, null);
        }
        return null;
    }
    
    public static Terms_And_Conditions__c getTC(Id tcId, String languageCode){
        if(String.isEmpty(languageCode)) languageCode = UserInfo.getLanguage();
        String query =
                ' SELECT Id, T_C_Text__c, ' +
                '   (SELECT Id, T_C_Text__c FROM Terms_And_Conditions__r WHERE Language__c = \'' + languageCode  + '\') ' +
                ' FROM Terms_And_Conditions__c' +
                ' WHERE ';
        if(tcId != null) {
            query += ' Id =\'' + tcId + '\' ';
        }else{
            query += ' Active__c = TRUE ';
        }
        query += ' ORDER BY Name DESC LIMIT 1';
        System.debug('QUERY: ' + query);
        Terms_And_Conditions__c [] tcList = Database.query(query);
        if(tcList.size() > 0) {
            Terms_And_Conditions__c tc = tcList[0];
            if(tc.Terms_And_Conditions__r.size() > 0) tc.T_C_Text__c = tc.Terms_And_Conditions__r[0].T_C_Text__c;
            return tc;
        }
        return null;
    }
    
    public static Boolean isTCAccepted(Id tcId){
        return getTCA(tcId) != null;
    }

    public static Map<Id, Boolean> getTrialsAcceptanceMap(List<Clinical_Trial_Profile__c> trials){
        List<Id> tcIds = new List<Id>();
        for(Clinical_Trial_Profile__c trial : trials) if(trial.Terms_And_Conditions_ID__c != null) tcIds.add(trial.Terms_And_Conditions_ID__c);
        List<Terms_And_Conditions_Acceptance__c> tcAcceptances = [
                SELECT Id, Terms_And_Conditions__c
                FROM Terms_And_Conditions_Acceptance__c
                WHERE Terms_And_Conditions__c IN: tcIds AND User__c =: UserInfo.getUserId()
        ];
        //Map tcId -> tcaId
        Map<Id, Id> tcaMap = new Map<Id, Id>();
        for(Terms_And_Conditions_Acceptance__c tca : tcAcceptances){
            tcaMap.put(tca.Terms_And_Conditions__c, tca.Id);
        }
        Map<Id, Boolean> resMap = new Map<Id, Boolean>();
        for(Clinical_Trial_Profile__c trial : trials){
            if(trial.Terms_And_Conditions_ID__c != null){
                resMap.put(trial.Id, tcaMap.get(trial.Terms_And_Conditions_ID__c) != null);
            }
        }
        return resMap;
    }

    public static Terms_And_Conditions_Acceptance__c getTCA(Id tcId){
        List<Terms_And_Conditions_Acceptance__c> tcAcceptance = [
                SELECT Id, Accepted_Date__c
                FROM Terms_And_Conditions_Acceptance__c
                WHERE User__c =: UserInfo.getUserId() AND Terms_And_Conditions__c =: tcId
        ];
        if(tcAcceptance.size() > 0) return tcAcceptance[0];
        return null;

    }

    public static void acceptTC(Id tcId){
        if(!isTCAccepted(tcId)){
            Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c(
                    Accepted_Date__c = Datetime.now(),
                    Terms_And_Conditions__c = tcId,
                    User__c = UserInfo.getUserId()
            );
            insert tca;
        }
    }

}