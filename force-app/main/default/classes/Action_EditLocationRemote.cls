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
    public static void upsertAccount(String accountJSON, Id ssId) {
        try {
            //TODO add logic here
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }


}