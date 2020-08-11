/**
 * Created by Sneha Shilpa Thuluri
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
		Participant__c participant;
    }
	 
    public static List<LabelValueItem> countriesLVList = new List<LabelValueItem>();
    @AuraEnabled
    public static String getInitData(){
        try{
            InitData initData = new InitData();
			contact myContact = new contact();
			myContact = getCurrentContact();
			if(myContact.userCommunityDelegateId__c != null){
                myContact = ContactService.getContact(myContact.userCommunityDelegateId__c);
			}
			
			List<Participant__c> participantList = new List<Participant__c>();
			participantList = [
                                SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Phone__c,
                                        Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                                        Mailing_Country_Code__c, Mailing_State_Code__c,Adult__c,
                                        Gender__c, Date_of_Birth__c
                                FROM Participant__c
                                WHERE Contact__c = :myContact.Id limit 1
                        ];	
			boolean isMinor=false;
			if(participantList.size()>0){
				if(!participantList[0].Adult__c){
					isMinor = true;
					system.debug('@@ in if '+isMinor);
				}
			}			
			system.debug('@@ in if '+isMinor);
						User userdetail;
			if(!isMinor){
			userdetail = [
                    SELECT  ContactId,
							LocaleSidKey,
							LanguageLocaleKey,
							TimeZoneSidKey,
                            Contact.Language__c,
                            Contact.Second_Choice_Language__c,
                            Contact.Third_Choice_Language__c,
							Contact.MailingCountry,
							Contact.MailingState
                    FROM    User
                    WHERE  contactId=:myContact.Id];
			}
            //
			
            //initData.localeKey     = UserInfo.getLocale();
					
			if(isMinor){				
				initData.languageKey   = UserInfo.getLanguage();
				initData.secondLangKey = myContact.Second_Choice_Language__c;
				initData.thirdLangKey  = myContact.Third_Choice_Language__c;
				initData.localeKey     = UserInfo.getLocale();
				initData.timezoneKey   = String.ValueOf(UserInfo.getTimeZone());				
            }
			else{
				initData.localeKey     = userdetail.LocaleSidKey;           
				initData.timezoneKey = userdetail.TimeZoneSidKey;		
				initData.languageKey   = userdetail.LanguageLocaleKey;
				initData.secondLangKey = userdetail.Contact.Second_Choice_Language__c;
				initData.thirdLangKey  = userdetail.Contact.Third_Choice_Language__c;
			}
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
			
							
            return JSON.serialize(initData);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void changeLanguage(String languageKey, String countryName,String stateName,String zipcode, String secondLangKey, String thirdLangKey, String localeKey, String timezoneKey){
        try{
			contact myContact = new contact();
			myContact = getCurrentContact();
			if(myContact.userCommunityDelegateId__c != null){
                myContact = ContactService.getContact(myContact.userCommunityDelegateId__c);				
            }
			List<Participant__c> participantList = new List<Participant__c>();
			participantList = [
                                SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Phone__c,
                                        Mailing_Zip_Postal_Code__c, Mailing_State__c, Mailing_Country__c,
                                        Mailing_Country_Code__c, Mailing_State_Code__c,Adult__c,
                                        Gender__c, Date_of_Birth__c
                                FROM Participant__c
                                WHERE Contact__c = :myContact.Id limit 1
                        ];
			boolean isMinor=false;
			if(participantList.size()>0){
				if(!participantList[0].Adult__c)
					isMinor = true;
			}
			system.debug('@@ isMinor'+isMinor);
						User userdetail;			
			if(!isMinor)
			 userdetail = [SELECT id,LanguageLocaleKey,LocaleSidKey,Timezonesidkey,ContactId FROM User WHERE ContactId = :myContact.Id];
				if(isMinor){									
					update new User(
                    Id = userinfo.getUserId(),
                    LanguageLocaleKey = languageKey,
						LocaleSidKey = localeKey,
						Timezonesidkey = timezoneKey
					);
					system.debug('@@ in if');
				}
				else{
					update new User(
						Id = userdetail.Id,
						LanguageLocaleKey = languageKey,
						LocaleSidKey = localeKey,
						Timezonesidkey = timezoneKey
					);
				}
           // User user = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
           		
			if(participantList.size()>0){
				update new Contact(
						Id = myContact.Id,
						Second_Choice_Language__c = secondLangKey,
						Third_Choice_Language__c = thirdLangKey						
				);
				update new Participant__c(
                    Id = participantList[0].id,
                    Mailing_Zip_Postal_Code__c = zipcode,
                    Mailing_Country__c = countryName,
					Mailing_State__c = stateName					
				);
				
			}
			else{
				update new Contact(
						Id = myContact.Id,
						Second_Choice_Language__c = secondLangKey,
						Third_Choice_Language__c = thirdLangKey,
						MailingCountry = countryName,
						MailingState = stateName,
						MailingPostalCode = zipcode						
				);
			}
																		
				
			
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }
	
	public static Contact getCurrentContact() {
        return [
            SELECT Id,
            FirstName,
			MiddleName,
            LastName,
            AccountId,
            Email,
            Fax,
            Phone,
            MailingAddress,
            MailingCity,
            MailingCountry,
            MailingCountryCode,
            MailingPostalCode,
            MailingState,
            MailingStateCode,
            MailingStreet,
            MobilePhone,
            Suffix,
            primaryContact__c,
            primaryContact__r.AccountId,
            HasOptedOutOfEmail,
            Participant_Opt_In_Status_Emails__c,
            Participant_Opt_In_Status_SMS__c,
            HCP_Opt_In_Patient_Status_Emails__c,
            HCP_Opt_In_Study_Emails__c,
            HCP_Opt_In_Referral_Status_Emails__c,
            Delegate_Opt_In_Status_Emails__c,
            RRCookiesAllowedCookie__c,
            RRLanguageAllowedCookie__c,
            Salutation,
            userCommunityDelegateId__c,
			userCommunytyType__c,
            Phone_Type__c,
			Second_Choice_Language__c,
			Third_Choice_Language__c
			
            FROM Contact
            WHERE Id IN (
                SELECT ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            )
            LIMIT 1
        ];
    }
}