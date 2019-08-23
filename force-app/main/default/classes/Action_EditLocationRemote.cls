/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_EditLocationRemote {
    
    private static final String DUMMY_ACCOUNT_NAME = 'Dummy Account For Location Check';
    
    public class InitData{
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    }
    
    @AuraEnabled
    public static InitData getInitData(){
        try{
            return new InitData();
        }catch (Exception e){
            return (InitData)AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static String createTmpAccountForLocationCheck(String account) {
        try{
            Account newAccount = (Account) JSON.deserialize(account, Account.class);
            Account accForCheck = new Account(Name = DUMMY_ACCOUNT_NAME + ' ' + UserInfo.getUserId(),
                    BillingStreet = newAccount.BillingStreet,
                    BillingCountryCode = newAccount.BillingCountryCode,
                    BillingCity = newAccount.BillingCity);
            if(!String.isEmpty(newAccount.BillingStateCode)) accForCheck.BillingStateCode = newAccount.BillingStateCode;
            insert accForCheck;
            return accForCheck.Id;
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void deleteTmpAccount(Id tmpAccountId){
        try{
            delete new Account(Id = tmpAccountId);
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static Account getTmpAccount(Id tmpAccountId) {
        try{
            Account acc = [
                    SELECT Id,
                            BillingGeocodeAccuracy,
                            BillingLongitude,
                            BillingLatitude
                    FROM Account
                    WHERE Id =: tmpAccountId
            ];
            if(acc.BillingGeocodeAccuracy != null) delete acc;
            return acc;
        }catch (Exception e){
            return (Account) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void upsertAccount(String accountJSON, Id ssId, Id piId) {
        try {
            Contact currentContact = [
                    SELECT Id,
                            OwnerId,
                            AccountId
                    FROM Contact
                    WHERE Id = :piId
            ];
            Account newAccount = (Account) JSON.deserialize(accountJSON, Account.class);
            Account createAccount = new Account();
            //create new account
            if (newAccount.Id == null) {
                createAccount = setFields(newAccount, currentContact, false);
                insert createAccount;
                currentContact.AccountId = createAccount.Id;
                update currentContact;
            } else {
                //create new sub Account and remove AccountContactRelation for main Account
                if (newAccount.ParentId == null) {
                    newAccount.ParentId = newAccount.Id;
                    createAccount = setFields(newAccount, currentContact, false);
                    insert createAccount;
                    List<AccountContactRelation> removeAccContRelation = [
                            SELECT Id,
                                    IsDirect
                            FROM AccountContactRelation
                            WHERE AccountId = :newAccount.Id AND ContactId = :currentContact.Id
                            LIMIT 1
                    ];
                    currentContact.AccountId = createAccount.Id;
                    update currentContact;
                    if (!removeAccContRelation.isEmpty()) {
                        delete removeAccContRelation[0];
                    }
                } else {
                    //update sub Account
                    createAccount = setFields(newAccount, currentContact, true);
                    update createAccount;
                    if (currentContact.AccountId != createAccount.Id) {
                        currentContact.AccountId = createAccount.Id;
                        update currentContact;
                    }
                }
            }
            Study_Site__c updSS = new Study_Site__c(Id = ssId, Account_Was_Changed__c = true, Site__c = createAccount.Id);
            update updSS;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static Account setFields(Account newAccount, Contact currentContact, Boolean setId) {
        Account acc = new Account(Id = setId ? newAccount.Id : null,
                Name = newAccount.Name,
                ParentId = newAccount.ParentId,
                BillingCountry = newAccount.BillingCountry,
                BillingStreet = newAccount.BillingStreet,
                BillingCity = newAccount.BillingCity,
                BillingPostalCode = newAccount.BillingPostalCode,
                Driving_Directions__c = newAccount.Driving_Directions__c,
                Parking_Instructions__c = newAccount.Parking_Instructions__c,
                BillingState = newAccount.BillingState,
                OwnerId = currentContact.OwnerId);
        return acc;
    }

}