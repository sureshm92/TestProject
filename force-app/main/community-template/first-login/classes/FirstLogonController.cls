/**
 * Created by Nargiz Mamedova on 10/15/2019.
 */

public without sharing class FirstLogonController {
    public static final String ERROR_SUFFIX = ': You must enter a value';
    public static final String ERROR_VALUE_SUFFIX = ': You must enter a valid value';

    public String photolink { get; set; }
    public String newPassword { get; set; }
    public String verifyNewPassword { get; set; }
    public Boolean isPasswordsEquals { get; set; }


    public User currUser { get; set; }
    public Contact contact { get; set; }
    public Account account { get; set; }
    public Boolean isParticipant { get; set; }

    public String helpText_1st_Language { get; private set; }
    public String helpText_2nd_Language { get; private set; }
    public String helpText_3rd_Language { get; private set; }

    public Boolean notEnrollNow { get; set; }
    public Boolean isProfileView { get; set; }
    public String tcText { get; set; }
    public String tcId { get; set; }
    public Participant__c participant { get; set; }

    public Translation__c translation { get; set; }

    private String previousLanguage;

    public List<SelectOption> countries { get; set; }
    public List<SelectOption> states { get; set; }
    public Boolean isStateRequired { get; set; }


    private Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    private Map<String, String> countryCodeByName = new Map<String, String>();
    private String oldAccountName;

    public FirstLogonController() {
        getUserAndContactAndAccount();
        initLanguagesAndTranslation();
        photolink = currUser.FullPhotoUrl;
        isProfileView = true;
        isPasswordsEquals = true;

        tcText = '';
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC(false);
        if (portalTC != null) {
            tcText = portalTC.T_C_Text__c;
            tcId = portalTC.Id;
        }
    }

    private void getUserAndContactAndAccount() {
        currUser = UserContext.getUser();
        contact = UserContext.getUserContact();
        account = UserContext.getUserContact().Account;

        notEnrollNow = !((contact.userCommunytyType__c == null || contact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP))
                && contact.userCommunityMode__c == CommunityService.USER_MODE_HCP);
        isStateRequired = false;

        account.BillingCountry = TranslateHelper.getPickListLabel(User.CountryCode, account.BillingCountryCode);
        oldAccountName = account.Name;

        isParticipant = contact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT;
        if (isParticipant) {
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
    
    public String getCommunityLogoURL(){
        return UserContext.getTemplateProperty(CommunityTemplateService.PROPERTY_COMMUNITY_LOGO);
    }

    private void initLanguagesAndTranslation() {
        previousLanguage = contact.Language__c;

        Map<String, SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        helpText_1st_Language = fieldMap.get('Language__c').getDescribe().inlineHelpText;
        helpText_2nd_Language = fieldMap.get('Second_Choice_Language__c').getDescribe().inlineHelpText;
        helpText_3rd_Language = fieldMap.get('Third_Choice_Language__c').getDescribe().inlineHelpText;

        translation = new Translation__c();
        if (!contact.Is_First_Logon__c) translation.Language__c = currUser.LanguageLocaleKey;
    }

    public void showProfileAction() {
        isProfileView = true;
    }

    public void checkPasswords() {
        updateNameOfAccount();

        ApexPages.getMessages().clear();
        if (!notEnrollNow) {
            addMessageToPage(contact.FirstName, 'First Name');
            addMessageToPage(contact.LastName, 'Last Name');
            addMessageToPage(contact.MailingStreet, 'Street Address');
            addMessageToPage(contact.MailingCity, 'City');
            addMessageToPage(contact.MailingCountry, 'Country');
            if (states.size() > 1) addMessageToPage(contact.MailingState, 'State');
            addMessageToPage(contact.MailingPostalCode, 'ZIP/Postal Code');
            addMessageToPage(contact.Phone, 'Phone Number');
            addMessageToPage(account.Name, 'Institute Name');
        }

        try {
            Site.validatePassword(currUser, newPassword, verifyNewPassword);
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }

        if (!notEnrollNow) {
            if (ApexPages.getMessages().size() == 0) {
                List<HCP_Enrollment__c> hcpEnrollments = [
                        SELECT Id,
                                HCP_Contact__c,
                                Status__c
                        FROM HCP_Enrollment__c
                        WHERE HCP_Contact__c = :contact.Id AND
                        Status__c = :HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
                ];
                for (HCP_Enrollment__c hcpe : hcpEnrollments) {
                    hcpe.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
                }
                if (!hcpEnrollments.isEmpty()) {
                    update hcpEnrollments;
                }
                for (HCP_Enrollment__c hcpe : hcpEnrollments) {
                    hcpe.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
                }
                if (!hcpEnrollments.isEmpty()) {
                    update hcpEnrollments;
                }
            }
        }

        if (ApexPages.getMessages().size() == 0) isProfileView = false;
    }

    @TestVisible
    private void updateNameOfAccount() {
        if (account.Name != oldAccountName && !String.isEmpty(account.Name)) {
            Account newClinic = new Account(
                    Name = account.Name,
                    BillingCountry = contact.MailingCountry,
                    BillingCity = contact.MailingCity,
                    BillingState = contact.MailingState,
                    BillingStreet = contact.MailingStreet,
                    BillingPostalCode = contact.MailingPostalCode,
                    Phone = contact.Phone,
                    Fax = contact.Fax,
                    OwnerId = contact.OwnerId
            );
            try {
                insert newClinic;
                contact.AccountId = newClinic.Id;
            } catch (Exception exp) {}
        }

        try {
            update contact;
        } catch (Exception exp) {}
    }

    private void addMessageToPage(String field, String message) {
        if (String.isBlank(field)) ApexPages.addMessage(
                new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        message + ERROR_SUFFIX)
        );
    }

    public PageReference setPassword() {

        if (tcId != null) {
            Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c();
            tca.Accepted_Date__c = Datetime.now();
            tca.Terms_And_Conditions__c = tcId;
            tca.User__c = UserInfo.getUserId();
            try {
                insert tca;
            } catch (Exception e) {}
        }

        PageReference pageReference;
        try {
            pageReference = Site.changePassword(newPassword, verifyNewPassword, null);
            contact.Is_First_Logon__c = false;
            update contact;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            isProfileView = true;
        }
        return pageReference;
    }

    private void updateTranslations() {
        if (isParticipant) {
            //translate country:
            participant.Mailing_Country__c = CountryStateUtil.getCountryName(participant.Mailing_Country_Code__c);
            //translate state
            participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, participant.Mailing_State_Code__c);
        }
    }

    public void updateLanguageAction() {
        if (String.isBlank(contact.Language__c)) contact.Language__c = previousLanguage;
        currUser.LanguageLocaleKey = contact.Language__c;

        try {
            update currUser;
            updateTranslations();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public void updateStatesAction() {
        states = new List<SelectOption>();
        List<LabelValueItem> statesByCountry = statesByCountryMap.get(countryCodeByName.get(contact.MailingCountry));
        if (statesByCountry != null) {
            for (LabelValueItem state : statesByCountry) {
                states.add(new SelectOption(state.label, state.label));
            }
        }
        isStateRequired = statesByCountry != null && !statesByCountry.isEmpty();
    }
}