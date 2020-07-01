/**
 * Created by Leonid Bartenev
 */

public without sharing class RRChangePasswordController {

    public static final String ERROR_SUFFIX = ': You must enter a value';
    public static final String ERROR_VALUE_SUFFIX = ': You must enter a valid value';
    public static final String TEMP_ACCOUNT = 'temporary account';

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
    public String failingPageResponse {get; set;}

    public Boolean isPaswordsEquals {get; set;}
    public Account account {get; set;}
    public Contact contact {get; set;}
    public User userVal {get; set;}

    public String helpText_1st_Language { get; private set; }
    public String helpText_2nd_Language { get; private set; }
    public String helpText_3rd_Language { get; private set; }

    public String userLocale {get; set;}
    public transient String userLanguage {get; set;}

    public Boolean notEnrollNow {get; set;}
    public Boolean isProfileView {get; set;}
    public String tcText {get; set;}
    public String tcId {get; set;}
    public Boolean isParticipant {get; set;}
    public Participant__c participant {get; set;}

    public Translation__c translation {get; set;}
    public String browserLanguage {get; set;}
    public String communityLogo {get; set;}
    public String resetPassLogo {get; set;}
    public String themeCSS {get; set;}
    public String backgroundStyle {get; set;}
    public String templateName {get; set;}
    public String currentCommunityName {get; set;}
    public String siteName {get; set;}

    private String previousLanguage;

    public List<SelectOption> countries {get; set;}
    public List<SelectOption> states {get; set;}
    public String country {get; set;}
    public String state {get; set;}
    public Boolean isStateRequired {get; set;}
    public Boolean mainPortal {
        get { return !Site.getPathPrefix().startsWith('/gsk');}
        set;
    }

    private Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    private Map<String, String> countryCodeByName = new Map<String, String>();
    private Map<String, String> stateCodeByName = new Map<String, String>();
    private String oldAccountName;
    
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
                        Contact.Salutation,
                        Contact.MiddleName,
                        Contact.Suffix,
                        Contact.MailingCountry,
                        Contact.MailingCountryCode,
                        Contact.MailingCity,
                        Contact.MailingPostalCode,
                        Contact.MailingState,
                        Contact.MailingStateCode,
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
                FROM User WHERE Id =: userId
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
                        Salutation, MiddleName, Suffix, MailingCountry, MailingCountryCode, MailingCity,
                        MailingPostalCode, MailingState, MailingStateCode, MailingStreet, OwnerId,
                        userCommunytyType__c, userCommunityMode__c, Phone, Fax
                FROM Contact WHERE Id =: contact.Id
        ];
        account = cont.Account;
        if(account.Name.contains(TEMP_ACCOUNT)){
            account.Name = '';
        }
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

        isParticipant = contact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT;
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

        countries = new List<SelectOption>();
        states = new List<SelectOption>();
        for (LabelValueItem country : CountryStateUtil.getCountries()) {
            countries.add(new SelectOption(country.value, country.label));
            countryCodeByName.put(country.value, country.label);
        }
        country = contact.MailingCountryCode;
        state = contact.MailingStateCode;
        if (!String.isBlank(country)) {
            updateStatesAction();
        }
    }

    public PageReference changePassword() {
        try{
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact.Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH') ? CommunityService.IQVIA_NETWORK_NAME : Site.getMasterLabel();
            contact.Is_First_Logon__c = false;
            update contact;
//            if(translation.Language__c != null) {
//                userVal.LanguageLocaleKey = translation.Language__c;
            update userVal;
//            }
            for (ApexPages.Message m : ApexPages.getMessages()) {
                if(m.getDetail().contains(System.Label.Pswd_Val_strng1) || m.getDetail().contains(System.Label.Pswd_Val_strng2))
                {
                    m = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Pswd_ValidationMsg3);
                    failingPageResponse = m.getDetail();
                }else{
                    failingPageResponse = Null;
                }
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
            return null;
        }
    }

    public void showProfileAction(){
        isProfileView = true;
    }

    public void checkPasswords() {
        try{
            ApexPages.getMessages().clear();  // Messages can't be cleared this way! Redirect page.
            if (!notEnrollNow && String.isBlank(contact.FirstName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.LastName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last Name' + ERROR_SUFFIX));
            }
    
            if (!notEnrollNow && ApexPages.getMessages().isEmpty()) {
                Boolean noCountry = contact.MailingCountryCode == '--None--' || String.isBlank(contact.MailingCountryCode);
                Boolean noState = contact.MailingStateCode == '--None--' || String.isBlank(contact.MailingStateCode) || states == null || states.size() < 2;
                contact.MailingCountry = (noCountry ? null : countryCodeByName.get(contact.MailingCountryCode));
                contact.MailingState = (noState ? null : stateCodeByName.get(contact.MailingCountryCode));
        
                if (account.Name != oldAccountName && !String.isEmpty(account.Name)) {
                    Account newClinic = new Account(
                            Name = account.Name,
                            BillingCountryCode = (noCountry ? null : contact.MailingCountryCode),
                            BillingCountry = contact.MailingCountry,
                            BillingCity = contact.MailingCity,
                            BillingState = contact.MailingState,
                            BillingStateCode = (noState ? null : contact.MailingStateCode),
                            BillingStreet = contact.MailingStreet,
                            BillingPostalCode = contact.MailingPostalCode,
                            Phone = contact.Phone,
                            Fax = contact.Fax,
                            OwnerId = contact.OwnerId
                    );
                    try {
                        insert newClinic;
                
                        contact.AccountId = newClinic.Id;
                    } catch (Exception exp) {
                        System.debug(exp);
                    }
                }
                try {
                    contact.MailingCountryCode = (noCountry ? null : contact.MailingCountryCode);
                    contact.MailingStateCode = (noState ? null : contact.MailingStateCode);
                    List<Participant_Enrollment__c> loginUserPEs = [SELECT Id FROM Participant_Enrollment__c WHERE Participant_Contact__c = : contact.Id ];
                    if(loginUserPEs.isEmpty() && contact.UserCommunityIsDelegate__c){
                        contact.Current_Participant_Enrollment__c = null;
                        contact.userCommunityDelegateId__c = null;
                        contact.Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH') ? CommunityService.IQVIA_NETWORK_NAME : Site.getMasterLabel();
                    }
                    update contact;
                    country = contact.MailingCountryCode;
                    state = contact.MailingStateCode;
                } catch (Exception exp) {
                    System.debug(exp);
                }
            }
            if (!notEnrollNow && String.isBlank(contact.MailingStreet)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Street Address' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.MailingCity)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'City' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.MailingCountryCode)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Country' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.MailingStateCode) && states.size() > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'State' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.MailingPostalCode)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ZIP/Postal Code' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(contact.Phone)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Phone Number' + ERROR_SUFFIX));
            }
            if (!notEnrollNow && String.isBlank(account.Name)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Institute Name' + ERROR_SUFFIX));
            }
            try {
                if (!Test.isRunningTest()){ 
                    Site.validatePassword(userVal, newPassword, verifyNewPassword);
                
              		for (ApexPages.Message m : ApexPages.getMessages()) 
                    {
                        if(m.getDetail().contains(System.Label.Pswd_Val_strng1) || m.getDetail().contains(System.Label.Pswd_Val_strng2))
                        {
                            m = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Pswd_ValidationMsg3);
                            failingPageResponse = m.getDetail();
                        }else{
                            failingPageResponse = Null;
                        }
                	}
            	}
                
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
    
            if (!notEnrollNow && ApexPages.getMessages().isEmpty()) {
                updateHCPStatus(contact.Id);
            }
    
            if (ApexPages.getMessages().isEmpty()) isProfileView = false;
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '/n' + e.getStackTraceString()));
        }
    }
    
    @Future
    private static void updateHCPStatus(Id contactId){
        List<HCP_Enrollment__c> hcpEnrollments = [
                SELECT Id,//
                        HCP_Contact__c,
                        Status__c
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__c = :contactId AND
                Status__c = :HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        ];
        if (!hcpEnrollments.isEmpty()) {
            if (hcpEnrollments.size() > 1) {
                for (HCP_Enrollment__c hcpe : hcpEnrollments) {
                    hcpe.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
                }
                update hcpEnrollments;
            } else {
                hcpEnrollments[0].Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
                update hcpEnrollments;
                hcpEnrollments[0].Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
                update hcpEnrollments;
            }
        }
    }

    public void upload() {
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, contentType, filename);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), userVal.Id, photoFileInput);
        photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), userVal.Id).fullEmailPhotoUrl;
    }

    public void updateTranslations(){
        if(isParticipant){
            //translate country:
            participant.Mailing_Country__c = CountryStateUtil.getCountryName(participant.Mailing_Country_Code__c);
            //translate state
            participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, participant.Mailing_State_Code__c);
        }
    }
    
    public void initTemplateData(){
        CommunityTemplate currentTemplate = UserContext.getCurrentCommunityTemplate();
        siteName = Site.getName();
        currentCommunityName = UserContext.getCurrentCommunityName();
        templateName = currentTemplate.templateName;
        themeCSS = currentTemplate.properties.get(CommunityTemplateService.PROPERTY_THEME_CSS);
        backgroundStyle = currentTemplate.properties.get('LoginBackground');
        communityLogo = currentTemplate.properties.get(CommunityTemplateService.PROPERTY_COMMUNITY_LOGO);
        resetPassLogo = currentTemplate.properties.get(CommunityTemplateService.PROPERTY_RESET_PASS_LOGO);
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
                contact.Second_Choice_Language__c = TranslateHelper.convertBrowserLanguage(new List<String> { secondLanguage });
            }

            if (String.isNotBlank(thirdLanguage) && TranslateHelper.convertBrowserLanguage(new List<String> { thirdLanguage }) != null) {
                contact.Third_Choice_Language__c = TranslateHelper.convertBrowserLanguage(new List<String> { thirdLanguage });
            }

            translation.Language__c = contact.Language__c;  //TranslateHelper.convertBrowserLanguage((List<String>)JSON.deserialize(browserLanguage, List<String>.class));
        }
        if(translation.Language__c == null) translation.Language__c = userVal.LanguageLocaleKey;
        updateLanguageAction();
    }

    public void updateLanguageAction(){
        try {
            userVal.LanguageLocaleKey = userVal.Contact.Language__c;
            update userVal;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            contact.Language__c = previousLanguage;
            return;
        }

        update userVal.Contact;
        updateTranslations();
    }

    public void translateFieldsAction(){
        updateTranslations();
    }

    public void updateStatesAction(){
        stateCodeByName = new Map<String, String>();
        states = new List<SelectOption>();
        List<LabelValueItem> statesByCountry = statesByCountryMap.get(contact.MailingCountryCode);
        if (statesByCountry != null) {
            for (LabelValueItem state : statesByCountry) {
                states.add(new SelectOption(state.value, state.label));
                stateCodeByName.put(state.value, state.label);
            }
        }
        isStateRequired = statesByCountry != null && !statesByCountry.isEmpty();
    }

}