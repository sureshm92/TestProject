/**
 * Created by Nargiz Mamedova on 10/14/2019.
 */

public with sharing class ChangePasswordController {

    public static final String ERROR_SUFFIX = ': You must enter a value';
    public static final String ERROR_VALUE_SUFFIX = ': You must enter a valid value';

    public String photolink{get;set;}

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

    public Boolean notEnrollNow {get; set;}
    public Boolean isProfileView {get; set;}
    public String tcText {get; set;}
    public String tcId {get; set;}
    public Boolean isParticipant {get; set;}
    public Participant__c participant {get; set;}

    public Translation__c translation {get; set;}

    private String previousLanguage;

    public List<SelectOption> countries {get; set;}
    public Boolean isStateRequired {get; set;}

    private Map<String, String> countryCodeByName = new Map<String, String>();
    private String oldAccountName;

    public ChangePasswordController() {
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
                        Contact.Salutation,
                        Contact.MiddleName,
                        Contact.Suffix,
                        Contact.MailingCountry,
                        Contact.MailingCity,
                        Contact.MailingPostalCode,
                        Contact.MailingState,
                        Contact.MailingStreet,
                        Contact.Is_First_Logon__c,
                        Contact.Language__c,
                        Contact.Second_Choice_Language__c,
                        Contact.Third_Choice_Language__c,
                        Contact.userCommunityMode__c,
                        Contact.userCommunytyType__c,
                        Contact.UserCommunityIsDelegate__c,
                        Contact.Phone,
                        Contact.Fax,
                        Contact.OwnerId,
                        LanguageLocaleKey,
                        TimeZoneSidKey,
                        LocaleSidKey
                FROM User WHERE ContactId = '0030E00000Vs9R2QAJ'
        ];
        contact = userVal.Contact;
        previousLanguage = contact.Language__c;

        Map<String, SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        helpText_1st_Language = fieldMap.get('Language__c').getDescribe().inlineHelpText;
        helpText_2nd_Language = fieldMap.get('Second_Choice_Language__c').getDescribe().inlineHelpText;
        helpText_3rd_Language = fieldMap.get('Third_Choice_Language__c').getDescribe().inlineHelpText;

        notEnrollNow = !((contact.userCommunytyType__c == null || contact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) && contact.userCommunityMode__c == CommunityService.USER_MODE_HCP);
        isStateRequired = false;

        Contact cont = [
                SELECT Id, Account.Name, Account.Phone, Account.BillingStreet,
                        Account.BillingCity, Account.BillingState, Account.Fax,
                        Account.BillingCountry, Account.BillingPostalCode,
                        Account.BillingCountryCode, Language__c, MailingAddress,
                        Salutation, MiddleName, Suffix, MailingCountry, MailingCity,
                        MailingPostalCode, MailingState, MailingStreet, OwnerId,
                        userCommunytyType__c, userCommunityMode__c, Phone, Fax
                FROM Contact WHERE Id =: contact.Id
        ];
        account = cont.Account;
        account.BillingCountry = TranslateHelper.getPickListLabel(User.CountryCode, account.BillingCountryCode);
        oldAccountName = account.Name;

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
        }

        countries = new List<SelectOption>();
        //countries.add(new SelectOption('', '--None--'));
        for (LabelValueItem country : CountryStateUtil.getCountries()) {
            countries.add(new SelectOption(country.label, country.label));
            countryCodeByName.put(country.label, country.value);
        }
    }

    public PageReference changePassword() {
        try{
            oldPassword = '12345678qw';
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact.Is_First_Logon__c = false;
            update contact;
//            if(translation.Language__c != null) {
//                userVal.LanguageLocaleKey = translation.Language__c;
//                update userVal;
//            }

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
}