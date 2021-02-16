public without sharing class StudySiteInformationController {
    @AuraEnabled
    public static  List<Account> getAccountData(Id ContactId){
        List<Study_Site__c> piStudySites = new List<Study_Site__c>();
        //List<AccountContactRelation> accList = new List<AccountContactRelation>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        For(Study_Site__c ss: [SELECT Id,
                               Principal_Investigator__c,
                               Principal_Investigator__r.AccountId,
                               Site__c,Account_Was_Changed__c,
                               Site__r.Name,
                               Site__r.ParentId,
                               Site__r.BillingCountry,
                               Site__r.BillingCountryCode,
                               Site__r.BillingCity,
                               Site__r.BillingStreet,
                               Site__r.BillingPostalCode,
                               Site__r.BillingState,
                               Site__r.BillingStateCode,
                               Site__r.BillingGeocodeAccuracy,
                               Site__r.Driving_Directions__c,
                               Site__r.Parking_Instructions__c,
                               Site__r.BillingLatitude,
                               Site__r.BillingLongitude
                               FROM Study_Site__c 
                               WHERE Principal_Investigator__c =: ContactId]){
                                   piStudySites.add(ss); 
                               }
        
        Map<Id, Map<Id,Account>> piAccounts = getPiAccounts(piStudySites);
        
        List< Account> piAccountMap = new List< Account>();
        piAccountMap = piAccounts.get(ContactId).values();
        return piAccountMap;
    }
    
    private static Map<Id, Map<Id, Account>> getPiAccounts(List<Study_Site__c> studies) {
        try {
            Map<Id, Id> piIdsWithAccounts = new Map<Id, Id>();
            for (Integer i = 0; i < studies.size(); i++) {
                piIdsWithAccounts.put(
                    studies[i].Principal_Investigator__c,
                    studies[i].Principal_Investigator__r.AccountId
                );
            }
            Map<Id, Map<Id, Account>> accountMap = new Map<Id, Map<Id, Account>>();
            if (!piIdsWithAccounts.isEmpty()) {
                for (AccountContactRelation piAccounts : [
                    SELECT
                    Id,
                    Contact.Id,
                    Contact.Name,
                    Contact.primaryContact__c,
                    Account.Id,
                    Account.Name,
                    Account.ParentId,
                    Account.BillingCountry,
                    Account.BillingCountryCode,
                    Account.BillingCity,
                    Account.BillingStreet,
                    Account.BillingPostalCode,
                    Account.BillingState,
                    Account.BillingStateCode,
                    Account.BillingGeocodeAccuracy,
                    Account.Driving_Directions__c,
                    Account.Parking_Instructions__c,
                    Account.BillingLatitude,
                    Account.BillingLongitude,
                    Account.OwnerId
                    FROM AccountContactRelation
                    WHERE ContactId IN :piIdsWithAccounts.keySet()
                ]) {
                    if (accountMap.containsKey(piAccounts.Contact.Id)) {
                        accountMap.get(piAccounts.Contact.Id).put(piAccounts.Account.Id, piAccounts.Account);
                    } else {
                        accountMap.put(piAccounts.Contact.Id, new Map<Id, Account>{ piAccounts.Account.Id => piAccounts.Account });
                    }
                }
                for (Id piId : piIdsWithAccounts.keySet()) {
                    Map<Id, Account> piAccs = accountMap.get(piId);
                    for (Account acc : piAccs.values()) {
                        if (acc.ParentId == piIdsWithAccounts.get(piId)) {
                            piAccs.remove(piIdsWithAccounts.get(piId));
                        }
                    }
                    accountMap.put(piId, piAccs);
                }
                
                for (Integer i = 0; i < studies.size(); i++) {
                    if (!studies[i].Account_Was_Changed__c) {
                        if (accountMap.containsKey(studies[i].Principal_Investigator__c)) {
                            Map<Id, Account> accMap = accountMap.get(
                                studies[i].Principal_Investigator__c
                            );
                            accMap.put(studies[i].Site__c, studies[i].Site__r);
                        } else {
                            accountMap.put(studies[i].Principal_Investigator__c, new Map<Id, Account>{ studies[i].Site__c => studies[i].Site__r });
                        }
                    }
                }
            }
            return accountMap;
        } catch (Exception ex) {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<LabelValueItem> getDelegateMap( String StudySiteId){
        List<Id> siteContactIds = new List<Id>();
        Map<String, List<Site_Staff__c>> delegatesMap = getDelegates(StudySiteId, siteContactIds);
        Map<Id, String> participantFullnameMap = getParticipantFullnameMap(siteContactIds);
        Map<String, List<LabelValueItem>> delegatesPicklistMap = convertDelegatesToLabelValue(
            delegatesMap,
            participantFullnameMap
        );
        
        List<LabelValueItem> delegatePicklist = delegatesPicklistMap.get(StudySiteId);
        return delegatePicklist;
    }
    
    @AuraEnabled
    public static Map<String, List<Site_Staff__c>> getDelegates(
        String StudySiteId,
        List<Id> outSiteContactIds
    ) {
        Map<String, List<Site_Staff__c>> delegatesMap = new Map<String, List<Site_Staff__c>>();
        for (Site_Staff__c ss : [
            SELECT
            Id,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__c,
            Site_Contact__r.Name,
            Site_Contact__c
            FROM Site_Staff__c
            WHERE Study_Site__c =:StudySiteId
        ]) {
            if (delegatesMap.containsKey(ss.Study_Site__c)) {
                delegatesMap.get(ss.Study_Site__c).add(ss);
            } else {
                delegatesMap.put(ss.Study_Site__c, new List<Site_Staff__c>{ ss });
            }
            outSiteContactIds.add(ss.Site_Contact__c);
        }
        return delegatesMap;
    }
    
    private static Map<String, List<LabelValueItem>> convertDelegatesToLabelValue(
        Map<String, List<Site_Staff__c>> delegateMap,
        Map<Id, String> participantFullnameMap
    ) {
        Map<String, List<LabelValueItem>> resultMap = new Map<String, List<LabelValueItem>>();
        for (String ssId : delegateMap.keySet()) {
            resultMap.put(ssId, getDelegatePickList(delegateMap.get(ssId), participantFullnameMap));
        }
        return resultMap;
    }
    
    private static Map<Id, String> getParticipantFullnameMap(List<Id> delegateContactIds) {
        List<Participant__c> participantDelegates = [
            SELECT Id, First_Name__c, Last_Name__c, Contact__c
            FROM Participant__c
            WHERE Contact__c IN :delegateContactIds
        ];
        Map<Id, String> participantDelegateNames = new Map<Id, String>();
        for (Participant__c partDelegate : participantDelegates) {
            participantDelegateNames.put(
                partDelegate.Contact__c,
                partDelegate.First_Name__c +
                ' ' +
                partDelegate.Last_Name__c
            );
        }
        return participantDelegateNames;
    }
    
    
    private static List<LabelValueItem> getDelegatePickList(
        List<Site_Staff__c> ss,
        Map<Id, String> participantFullnameMap
    ) {
        Map<Id, LabelValueItem> delegates = new Map<Id, LabelValueItem>();
        try {
            if (!ss.isEmpty()) {
                for (Site_Staff__c delegatesSites : ss) {
                    if (participantFullnameMap.containsKey(delegatesSites.Site_Contact__c)) {
                        delegates.put(
                            delegatesSites.Site_Contact__c,
                            new LabelValueItem(
                                participantFullnameMap.get(delegatesSites.Site_Contact__c),
                                delegatesSites.Id
                            )
                        );
                    } else {
                        delegates.put(
                            delegatesSites.Site_Contact__c,
                            new LabelValueItem(
                                delegatesSites.Site_Contact__r.Name,
                                delegatesSites.Id
                            )
                        );
                    }
                }
            }
            List<LabelValueItem> labelList = new List<LabelValueItem>();
            if (!delegates.isEmpty()) {
                labelList.add(new LabelValueItem('None', ' '));
                labelList.addAll(delegates.values());
            }
            return labelList;
        } catch (Exception ex) {
            return null;
        }
    }
    
    public class InitData {
        @AuraEnabled
        public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled
        public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    }
    
    @AuraEnabled
    public static InitData getInitData() {
        try {
            return new InitData();
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void saveSSChanges(String studySiteInfo,String accId, String callDisp, Boolean newCall) {
        try {
            Study_Site__c study = new Study_Site__c();
            SiteWrapper response = (SiteWrapper) JSON.deserialize(
                studySiteInfo,
                SiteWrapper.class
            );
            study.Id = response.siteId;
            study.Name = response.siteName;
            study.Study_Site_Phone__c = response.sitePhone;
            if(!String.IsBlank(response.siteStaff) ){
                study.Site_Staff__c = response.siteStaff;
            }
            study.Study_Site_Email__c = response.siteEmail;
            study.Completed_training__c =  response.trainingComplete;
            study.Site_Information_Form_Completed__c = response.siteInfoComplete;
            study.Suppress_Study_Site_PI_Emails__c = !response.receivePIEmail;
            study.Opt_in_for_warm_transfer__c = response.optInForWarmTransfer;
            
            if(accId != NULL){
                study.Site__c = accId;
            }
            update study;
            if(newCall){
                Call_Dispositions__c cDisp = new Call_Dispositions__c();
                callDisp cd = (callDisp) JSON.deserialize(callDisp, callDisp.class);
                cDisp.Study_Site__c = study.Id;
                cDisp.Call_Category__c = cd.callcategory;
                cDisp.Inbound_Outbound__c = cd.callbound;
                cDisp.IQVIA_intervention_required__c = cd.interventionReq;
                cDisp.Notes__c = cd.notes;
                cDisp.Caller__c = CommunityService.getUserContact().Id;
                insert cDisp;
                
                if(cd.interventionReq)
                {
                  Study_Site__c ss = new Study_Site__c();
                  ss.id=study.Id;
                  ss.IQVIA_intervention_required__c=true;
                  update ss;
                }
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
    public class SiteWrapper {
        @AuraEnabled
        public String siteId;
        @AuraEnabled
        public String piId;
        @AuraEnabled
        public String studyName;
        @AuraEnabled
        public String siteNumber;
        @AuraEnabled
        public String siteName;
        @AuraEnabled
        public String siteCountry;
        @AuraEnabled
        public String piName;
        @AuraEnabled
        public String sitePhone;
        @AuraEnabled
        public String primaryContact;
        @AuraEnabled
        public String siteStatus;
        @AuraEnabled
        public String siteEmail;
        @AuraEnabled
        public String siteStaff;
        @AuraEnabled
        public Boolean receivePIEmail;
        @AuraEnabled
        public Boolean siteInfoComplete;
        @AuraEnabled
        public Boolean trainingComplete;
        @AuraEnabled
        public Boolean isStudySiteEmailValid;
        @AuraEnabled
        public Boolean isRecordUpdated;
        @AuraEnabled
        public String site;
        @AuraEnabled
        public boolean optInForWarmTransfer;
    }
    
    public class callDisp{
        @AuraEnabled
        public String callbound;
        @AuraEnabled
        public String callcategory;
        @AuraEnabled
        public Boolean interventionReq;
        @AuraEnabled
        public String notes;
        
    }
}