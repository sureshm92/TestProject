/**
 * Created by Leonid Bartenev
 */

public without sharing class RRChangePasswordController {
    public String photolink{get;set;}
    
    //The binary data of the image uploaded by the user
    public transient Blob blobValue {get; set;}

    //The content type, determined by Salesforce, of the image uploaded by the user
    public transient String contentType {get; set;}
    
    // The name of the image file uploaded by the user
    public transient String filename {get; set;}
 
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}

    public Boolean isPaswordsEquals {get; set;}
    public Account account {get; set;}
    public Contact contact {get; set;}
    public User userVal {get; set;}
    
    public String helpText_1st_Language { get; private set; }
    public String helpText_2nd_Language { get; private set; }
    public String helpText_3rd_Language { get; private set; }

    public String userLocale {get; set;}
    public transient String userLanguage {get; set;}

    public Boolean isProfileView {get; set;}
    public String tcText {get; set;}
    public String tcId {get; set;}
    public Boolean isParticipant {get; set;}
    public Participant__c participant {get; set;}

    public Translation__c translation {get; set;}
    public String browserLanguage {get; set;}
    
    private String previousLanguage;
    
    public RRChangePasswordController() {
        translation = new Translation__c();
        init();
        if(!contact.Is_First_Logon__c) translation.Language__c = userVal.LanguageLocaleKey;
    }

    private void init(){
        Id userId = UserInfo.getUserId();
        userVal = [
                SELECT Id, Name, Username, FirstName, LastName, FullPhotoUrl,
                        Contact.FirstName,
                        Contact.LastName,
                        Contact.MailingAddress,
                        Contact.Is_First_Logon__c,
                        Contact.Language__c,
                        Contact.SecondChoiceLanguage__c,
                        Contact.ThirdChoiceLanguage__c,
                        Contact.userCommunityMode__c,
                        Contact.UserCommunityIsDelegate__c,
                        LanguageLocaleKey,
                        TimeZoneSidKey,
                        LocaleSidKey
                FROM User WHERE Id =: userId
        ];
        contact = userVal.Contact;
        previousLanguage = contact.Language__c;
    
        Map<String, SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        helpText_1st_Language = fieldMap.get('Language__c').getDescribe().inlineHelpText;
        helpText_2nd_Language = fieldMap.get('SecondChoiceLanguage__c').getDescribe().inlineHelpText;
        helpText_3rd_Language = fieldMap.get('ThirdChoiceLanguage__c').getDescribe().inlineHelpText;
    
        Contact cont = [
                SELECT Id, Account.Name, Account.Phone, Account.BillingStreet,
                        Account.BillingCity, Account.BillingState, Account.Fax,
                        Account.BillingCountry, Account.BillingPostalCode,
                        Account.BillingCountryCode,
                        Language__c
                FROM Contact WHERE Id =: contact.Id
        ];
        account = cont.Account;
        account.BillingCountry = TranslateHelper.getPickListLabel(User.CountryCode, account.BillingCountryCode);
        photolink = userVal.FullPhotoUrl;
        isProfileView = true;
        isPaswordsEquals = true;

        tcText = '';
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC();
        if(portalTC != null){
            tcText = portalTC.T_C_Text__c;
            tcId = portalTC.Id;
        }
        
        isParticipant = contact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT && !contact.UserCommunityIsDelegate__c;
        if(isParticipant) {
            participant = [
                    SELECT Id, Name, First_Name__c, Last_Name__c, Phone__c,
                            Mailing_Country__c, Mailing_State__c, Mailing_Zip_Postal_Code__c,
                            Mailing_Country_Code__c, Mailing_State_Code__c

                    FROM Participant__c
                    WHERE Contact__c = :contact.Id
            ];
            updateTranslations();
        }
    }

    public PageReference changePassword() {
        try{
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact.Is_First_Logon__c = false;
            update contact;
            if(translation.Language__c != null) {
                userVal.LanguageLocaleKey = translation.Language__c;
                update userVal;
            }

            if (tcId!=null) {           
                Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c();
                tca.Accepted_Date__c = Datetime.now();
                tca.Terms_And_Conditions__c = tcId;
                tca.User__c = UserInfo.getUserId();
                insert tca;
            }

            return pr;
        }catch (Exception e){
            isProfileView = true;
            ApexPages.addMessages(e);
            return null;
        }
    }

    public void showProfileAction(){
        isProfileView = true;
    }

    public void checkPasswords(){
        Site.validatePassword(userVal, newPassword, verifyNewPassword);
        if(ApexPages.getMessages().size() == 0) isProfileView = false;
    }

    public void upload() {
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, contentType, filename);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), userVal.Id, photoFileInput);
        photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), userVal.Id).fullEmailPhotoUrl;
    }
    
    public void updatePhotoURL(){
    }

    public void updateTranslations(){
        if(isParticipant){
            //translate country:
            participant.Mailing_Country__c = CountryStateUtil.getCountryName(participant.Mailing_Country_Code__c);
            //translate state
            participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, participant.Mailing_State_Code__c);
        }
    }

    public void updateBrowserLanguageAction(){
        System.debug(contact);
        if(contact != null && contact.Is_First_Logon__c && contact.Language__c != null && contact.Language__c != ''
                && (translation.Language__c == null || translation.Language__c == '')) {
            translation.Language__c = contact.Language__c;
        } else {

            List<String> browserLanguages = (List<String>)JSON.deserialize(browserLanguage, List<String>.class);
            String firstLanguage  = browserLanguages.get(0);
            String secondLanguage = browserLanguages.get(1);
            String thirdLanguage  = browserLanguages.get(2);

            if (String.isNotBlank(firstLanguage) && TranslateHelper.convertBrowserLanguage(new List<String> { firstLanguage }) != null) {
                if (String.isBlank(contact.Language__c)) {
                    contact.Language__c = TranslateHelper.convertBrowserLanguage(new List<String>{
                            firstLanguage
                    });
                }
            } else {
                List<Schema.PicklistEntry> entries = Translation__c.Language__c.getDescribe().getPicklistValues();
                for (PicklistEntry entry : entries) {
                    if (entry.getValue().startsWithIgnoreCase('en')) {
                        contact.Language__c = entry.getValue();
                        break;
                    }
                }
//              contact.Language__c = Translation__c.Language__c.getDescribe().getPicklistValues().get(0).getValue();
            }

            if (String.isNotBlank(secondLanguage) && TranslateHelper.convertBrowserLanguage(new List<String> { secondLanguage }) != null) {
                contact.SecondChoiceLanguage__c = TranslateHelper.convertBrowserLanguage(new List<String> { secondLanguage });
            }

            if (String.isNotBlank(thirdLanguage) && TranslateHelper.convertBrowserLanguage(new List<String> { thirdLanguage }) != null) {
                contact.ThirdChoiceLanguage__c = TranslateHelper.convertBrowserLanguage(new List<String> { thirdLanguage });
            }

            translation.Language__c = contact.Language__c;  //TranslateHelper.convertBrowserLanguage((List<String>)JSON.deserialize(browserLanguage, List<String>.class));
        }
        if(translation.Language__c == null) translation.Language__c = userVal.LanguageLocaleKey;
        updateLanguageAction();
    }
    
    public void updateLanguageAction(){
        try {
System.debug('=========== userVal.Name = '+userVal.Name);
System.debug('=========== userVal.LanguageLocaleKey BEFORE = '+userVal.LanguageLocaleKey);
            userVal.LanguageLocaleKey = contact.Language__c;
            update userVal;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            contact.Language__c = previousLanguage;
            return;
        }

        update userVal.Contact;
        
System.debug('=========== userVal.LanguageLocaleKey AFTER = '+userVal.LanguageLocaleKey);
System.debug('=========== contact.Language__c = '+userVal.Contact.Language__c);
        updateTranslations();
    }
    
    public void translateFieldsAction(){
        updateTranslations();
    }

}