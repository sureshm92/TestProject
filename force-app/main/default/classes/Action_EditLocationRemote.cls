/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_EditLocationRemote {

    private static final String DUMMY_ACCOUNT_NAME = 'Dummy Account For Location Check';

    public class InitData {
        @AuraEnabled public List<LabelValueItem> countriesLVList = CountryStateUtil.getCountries();
        @AuraEnabled public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
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
    public static String createTmpAccountForLocationCheck(String account) {
        try {
            Account newAccount = (Account) JSON.deserialize(account, Account.class);
            Account accForCheck = new Account(Name = DUMMY_ACCOUNT_NAME + ' ' + UserInfo.getUserId(),
                    BillingStreet = newAccount.BillingStreet,
                    BillingCountryCode = newAccount.BillingCountryCode,
                    BillingCity = newAccount.BillingCity);
            if (!String.isEmpty(newAccount.BillingStateCode)) accForCheck.BillingStateCode = newAccount.BillingStateCode;
            if (!String.isEmpty(newAccount.BillingPostalCode)) accForCheck.BillingPostalCode = newAccount.BillingPostalCode;
            insert accForCheck;
            return accForCheck.Id;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void deleteTmpAccount(Id tmpAccountId) {
        try {
            delete new Account(Id = tmpAccountId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Account getTmpAccount(Id tmpAccountId) {
        try {
            Account acc = [
                    SELECT Id,
                            BillingGeocodeAccuracy,
                            BillingLongitude,
                            BillingLatitude,
                            BillingCity,
                            BillingCountryCode,
                            BillingCountry,
                            BillingStateCode,
                            BillingState,
                            BillingStreet,
                            BillingPostalCode
                    FROM Account
                    WHERE Id = :tmpAccountId
            ];
            if (acc.BillingGeocodeAccuracy != null) delete acc;
            return acc;
        } catch (Exception e) {
            return (Account) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Account upsertAccount(String accountJSON, Id ssId) {
        try {
            Study_Site__c ss = [
                    SELECT Id,
                            Principal_Investigator__c
                    FROM Study_Site__c
                    WHERE Id = :ssId
            ];
            Account account = (Account) JSON.deserialize(accountJSON, Account.class);
            //create new account
            Contact currentContact = CommunityService.getUserContact();
            if (account.Id == null) {
                account.OwnerId = currentContact.Account.OwnerId;
                insert account;
                ss.Site__c = account.Id;
                ss.Account_Was_Changed__c = true;
                update ss;
                insert new AccountContactRelation(AccountId = account.Id, ContactId = ss.Principal_Investigator__c);
            } else if (account.ParentId == null) { //create new sub Account and remove AccountContactRelation for main Account
                Account subAccount = account.clone();
                subAccount.ParentId = account.Id;
                subAccount.OwnerId = currentContact.Account.OwnerId;
                insert subAccount;
                insert new AccountContactRelation(AccountId = subAccount.Id, ContactId = ss.Principal_Investigator__c);
               /* delete [
                        SELECT Id,
                                IsDirect
                        FROM AccountContactRelation
                        WHERE AccountId = :account.Id AND ContactId = :ss.Principal_Investigator__c
                        LIMIT 1
                ];*/
                ss.Site__c = subAccount.Id;
                ss.Account_Was_Changed__c = true;
                update ss;
                return subAccount;
            } else {
                //update sub Account
                update account;
            }
            return account;
        } catch (Exception e) {
            return (Account) AuraHelper.throwException(e);
        }
    }
}