/**
 * Created by Nargiz Mamedova on 10/15/2019.
 */

public without sharing class ChangePasswordPageController {
    public User user {get; set;}
    public Contact contact {get; set;}

    public String browserLanguage {get; set;}

    public Boolean isParticipant {get; set;}

    public ChangePasswordPageController() {
        user = [
                SELECT Id,
                        Contact.Is_First_Logon__c,
                        Contact.Language__c,
                        Contact.Second_Choice_Language__c,
                        Contact.Third_Choice_Language__c,
                        Contact.userCommunityMode__c,
                        Contact.userCommunytyType__c,
                        Contact.UserCommunityIsDelegate__c,
                        LanguageLocaleKey
                FROM User
                WHERE Id =: UserInfo.getUserId()
        ];

        contact = user.Contact;

        isParticipant = contact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT && !contact.UserCommunityIsDelegate__c;

    }

    public void updateBrowserLanguageAction(){
        List<String> browserLanguages = (List<String>)JSON.deserialize(browserLanguage, List<String>.class);
        List<String> convertedLanguages = new List<String>();
        for (String bLanguage : browserLanguages ) {
            String convertedLanguage = TranslateHelper.convertBrowserLanguage(new List<String> { bLanguage });
            if(convertedLanguage != null) convertedLanguages.add(convertedLanguage);
        }
        if(convertedLanguages.size() > 0) convertedLanguages.add('en_US');
        user.Contact.Language__c = convertedLanguages.remove(0);

        if(convertedLanguages.size() > 0) user.Contact.Second_Choice_Language__c = convertedLanguages.remove(0);
        if(convertedLanguages.size() > 0) user.Contact.Third_Choice_Language__c = convertedLanguages.remove(0);

        update user.Contact;
        user.LanguageLocaleKey = user.Contact.Language__c;
        update user;
    }
}