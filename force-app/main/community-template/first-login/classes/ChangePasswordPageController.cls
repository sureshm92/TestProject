/**
 * Created by Nargiz Mamedova on 10/15/2019.
 */

public without sharing class ChangePasswordPageController {
    
    public User user {get; set;}
    public Contact contact {get; set;}
    public String browserLanguage {get; set;}
    public Boolean isParticipant {get; set;}
    public String themeCSS {get; set;}

    public void init() {
        user = UserContext.getUser();
        contact = UserContext.getUserContact();
        isParticipant = UserContext.isParticipant();
        themeCSS = UserContext.getTemplateProperty(CommunityTemplateService.PROPERTY_THEME_CSS);
    }

    public void updateBrowserLanguageAction(){
        List<String> browserLanguages = (List<String>)JSON.deserialize(browserLanguage, List<String>.class);
        List<String> convertedLanguages = new List<String>();
        for (String bLanguage : browserLanguages ) {
            String convertedLanguage = TranslateHelper.convertBrowserLanguage(new List<String> { bLanguage });
            if(convertedLanguage != null) convertedLanguages.add(convertedLanguage);
        }
        if(convertedLanguages.size() > 0) convertedLanguages.add('en_US');
        contact.Language__c = convertedLanguages.remove(0);

        if(convertedLanguages.size() > 0) contact.Second_Choice_Language__c = convertedLanguages.remove(0);
        if(convertedLanguages.size() > 0) contact.Third_Choice_Language__c = convertedLanguages.remove(0);

        update contact;
        user.LanguageLocaleKey = contact.Language__c;
        update user;
    }
}