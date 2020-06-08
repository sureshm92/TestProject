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
    }
    
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
                            Contact.Third_Choice_Language__c
                    FROM    User
                    WHERE   Id = :UserInfo.getUserId()];
    
            initData.languageKey   = UserInfo.getLanguage();
            initData.secondLangKey = user.Contact.Second_Choice_Language__c;
            initData.thirdLangKey  = user.Contact.Third_Choice_Language__c;
            initData.localeKey     = UserInfo.getLocale();
            initData.timezoneKey   = String.ValueOf(UserInfo.getTimeZone());
            return JSON.serialize(initData);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void changeLanguage(String languageKey, String secondLangKey, String thirdLangKey, String localeKey, String timezoneKey){
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
                    Third_Choice_Language__c = thirdLangKey
            );
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
}
