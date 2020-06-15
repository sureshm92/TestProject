/**
 * Created by Leonid Bartenev
 */

public without sharing class PP_LanguageSwitcherRemote {
    
	
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
        String defaultCountryName;								
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
            List<Participant__c> participantList = new List<Participant__c>();
			participantList = [
                                SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Phone__c,
                                        Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                                        Mailing_Country_Code__c, Mailing_State_Code__c,
                                        Gender__c, Date_of_Birth__c
                                FROM Participant__c
                                WHERE Contact__c = :user.ContactId limit 1
                        ];
			boolean isParticipant = false;
			if(participantList.size()>0)
			isParticipant = true;
			if(isParticipant){
				update new Contact(
						Id = user.ContactId,
						Second_Choice_Language__c = secondLangKey,
						Third_Choice_Language__c = thirdLangKey						
				);
			}
			else{
				update new Contact(
						Id = user.ContactId,
						Second_Choice_Language__c = secondLangKey,
						Third_Choice_Language__c = thirdLangKey,
						MailingCountry = countryName,
						MailingState = stateName,
						MailingPostalCode = zipcode						
				);
			}
			
			if(isParticipant){
				update new Participant__c(
                    Id = participantList[0].id,
                    Mailing_Zip_Postal_Code__c = zipcode,
                    Mailing_Country__c = countryName,
					Mailing_State__c = stateName					
				);
			}
				
			
						
				
			
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
}