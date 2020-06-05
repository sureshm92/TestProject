/**
 * Created by Leonid Bartenev
 */

public without sharing class LanguageSwitcherRemote {
    
	
    public class InitData{
        String languageKey;
        List<LabelValueItem> languages = new List<LabelValueItem>();        		
        List<LabelValueItem> optionalLanguages = new List<LabelValueItem>();
        String localeKey;
        List<LabelValueItem> locales = new List<LabelValueItem>();
        String timezoneKey;
        List<LabelValueItem> timezones = new List<LabelValueItem>();
        String secondLangKey;
        String thirdLangKey;
		
		//Sneha-Added variables to store country and its states
		String countryKey;
        List<LabelValueItem> countries = new List<LabelValueItem>();		
		String stateKey;
		Map<String, List<LabelValueItem>> statesByCountryMap = new Map<String, List<LabelValueItem>>();
    }
	 
    public static List<LabelValueItem> countriesLVList = new List<LabelValueItem>();
    @AuraEnabled
    public static String getInitData(){
        try{
            InitData initData = new InitData();
            List<PicklistEntry> listPLE = Translation__c.Language__c.getDescribe().getPicklistValues();
            initData.optionalLanguages.add(new LabelValueItem('--' + Label.None + '--', null));
            for(PicklistEntry ple : listPLE){
                initData.languages.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
                initData.optionalLanguages.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
			//Sneha-Added logic to store country and its states
			countriesLVList = CountryStateUtil.getCountries();
			initData.countries.addAll(countriesLVList);
			Map<String, List<LabelValueItem>> tempStatesByCountryMap = new Map<String, List<LabelValueItem>>();
			tempStatesByCountryMap = CountryStateUtil.getStatesByCountryMap();
			for(string cc: tempStatesByCountryMap.keySet()){
				if(tempStatesByCountryMap.get(cc).size()>0)
				tempStatesByCountryMap.get(cc).add(0,new LabelValueItem('--' + Label.None + '--', null));
			}
			initData.statesByCountryMap.putAll(tempStatesByCountryMap);
			
			
			
            listPLE = User.LocaleSidKey.getDescribe().getPicklistValues();
            for(PicklistEntry ple : listPLE){
                initData.locales.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
            listPLE = User.Timezonesidkey.getDescribe().getPicklistValues();
            for(PicklistEntry ple : listPLE){
                initData.timezones.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
    
            User user = [
                    SELECT  ContactId,
                            Contact.Language__c,
                            Contact.Second_Choice_Language__c,
                            Contact.Third_Choice_Language__c,
							Contact.MailingCountry,
							Contact.MailingState
                    FROM    User
                    WHERE   Id = :UserInfo.getUserId()];
    
            initData.languageKey   = UserInfo.getLanguage();
            initData.secondLangKey = user.Contact.Second_Choice_Language__c;
            initData.thirdLangKey  = user.Contact.Third_Choice_Language__c;
            initData.localeKey     = UserInfo.getLocale();
            initData.timezoneKey   = String.ValueOf(UserInfo.getTimeZone());
			if(user.contact.MailingCountry!=null)
			initData.countryKey    = user.contact.MailingCountry;
			if(user.contact.MailingState!=null)
			initData.stateKey    = user.contact.MailingState; 
            return JSON.serialize(initData);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void changeLanguage(String languageKey, String countryName,String stateName,String zipcode, String secondLangKey, String thirdLangKey, String localeKey, String timezoneKey){
        try{
			
            update new User(
                    Id = UserInfo.getUserId(),
                    LanguageLocaleKey = languageKey,
                    LocaleSidKey = localeKey,
                	Timezonesidkey = timezoneKey
            );
    
            User user = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            
            update new Contact(
                    Id = user.ContactId,
                    Second_Choice_Language__c = secondLangKey,
                    Third_Choice_Language__c = thirdLangKey,
					MailingCountry = countryName,
					MailingState = stateName,
					MailingPostalCode = zipcode
            );
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
}