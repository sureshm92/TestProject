/**
 * Created by Leonid Bartenev
 */

public without sharing class RRChangePasswordController {
    public static final String ERROR_SUFFIX = ': ' + System.Label.RH_ProfileInfoErrorMsz;
    public static final String ERROR_VALUE_SUFFIX = ': You must enter a valid value';
    public static final String TEMP_ACCOUNT = 'temporary account';
    public static final String AGE_OF_MAJORITY_ALL_COUNTRIES = 'Age_for_All_Countries';

    public String photolink { get; set; }

    //The binary data of the image uploaded by the user
    public transient Blob blobValue { get; set; }

    //The content type, determined by Salesforce, of the image uploaded by the user
    public transient String contentType { get; set; }

    // The name of the image file uploaded by the user
    public transient String filename { get; set; }

    public String oldPassword { get; set; }
    public String newPassword { get; set; }
    public String verifyNewPassword { get; set; }
    public String failingPageResponse { get; set; }

    public Boolean isPaswordsEquals { get; set; }
    public Account account { get; set; }
    public Contact contact { get; set; }
    public User userVal { get; set; }

    public String helpText_1st_Language { get; private set; }
    public String helpText_2nd_Language { get; private set; }
    public String helpText_3rd_Language { get; private set; }

    public String userLocale { get; set; }
    public transient String userLanguage { get; set; }

    public Boolean notEnrollNow { get; set; }
    public Boolean isProfileView { get; set; }
    public String tcText { get; set; }
    public String tcId { get; set; }
    public Boolean isParticipant { get; set; }
    public Boolean isDelegate { get; set; }
    public Boolean isAdult { get; set; }
    public Boolean isAttested { get; set; }
    public Participant__c participant { get; set; }
    public Participant_Enrollment__c per {get;set;}
    public String tcLink { get; set; }
    public String studyPrivacyPolicyUrl { get; set; }
    public String platformPrivacyPolicyUrl { get; set; }

    public Translation__c translation { get; set; }
    public String browserLanguage { get; set; }
    public String communityLogo { get; set; }
    public String resetPassLogo { get; set; }
    public String themeCSS { get; set; }
    public Boolean isMobileView { get; set; }
    public Boolean isMobileApp { get; set; }
    public String backgroundStyle { get; set; }
    public String templateName { get; set; }
    public String currentCommunityName { get; set; }
    public String siteName { get; set; }
    public Boolean hasProfilePic { get; set; }
    public Boolean showPassword { get; set; }
    public Boolean showNewPassword { get; set; }
    //public Boolean showPassword = true;
    public Boolean isRTL { get; set; }

    private String previousLanguage;

    public List<SelectOption> countries { get; set; }
    public List<SelectOption> states { get; set; }
    public List<SelectOption> years { get; set; }
    public String country { get; set; }
    public String state { get; set; }
    public String birthYear { get; set; }
    public Boolean isStateRequired { get; set; }
    public Boolean isDisabled { get; set; }
    public Boolean isSaveButtonDisabled { get; set; }
    public Boolean passwordValidation {get; set;}
    public boolean onLoad { get; set; }
    public boolean showErrorMessage { get; set; }
    public static boolean isAttestationUpdated = false;

    public String maskUserName {get;set;}
    public String maskLastName {get;set;}
    public String maskDaytimephone {get;set;}
    public String addPhotoLabel {get;set;}

    public Boolean mainPortal {
        get {
            return !Site.getPathPrefix().startsWith('/gsk');
        }
        set;
    }

    private Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
    private Map<String, String> countryCodeByName = new Map<String, String>();
    private Map<String, String> stateCodeByName = new Map<String, String>();
    private String oldAccountName;

    public RRChangePasswordController() {
        passwordValidation=false;
        isRTL = false;
        onLoad = true;
        isMobileView = false;
        isMobileApp = false;
        showPassword = true;
        showNewPassword = true;
        translation = new Translation__c();
        init();
        if (!contact.Is_First_Logon__c)
            translation.Language__c = userVal.LanguageLocaleKey;
        String rtl_language = System.Label.RTL_Languages;
        if (rtl_language.contains(previousLanguage)) {
            isRTL = true;
        }
        if (isRTL) {
            tcText = tcText.replaceAll(
                '/s/privacy-policy',
                '/s/privacy-policy?lanCode=' + previousLanguage
            );
            tcText = tcText.replaceAll(
                '/s/cookie-policy',
                '/s/cookie-policy?lanCode=' + previousLanguage
            );
        }

        Map<String, String> headerlist = ApexPages.currentPage().getHeaders();
        if (headerList.size() > 0) {
            if (
                headerList.get('User-Agent').contains('Android') ||
                headerList.get('User-Agent').contains('BlackBerry') ||
                headerList.get('User-Agent').contains('IEMobile') ||
                headerList.get('User-Agent').contains('iPhone') ||
                headerList.get('User-Agent').contains('iPad')
            ) {
                isMobileView = true;
            }
            if (headerList.get('User-Agent').contains('SalesforceMobileSDK')) {
                isMobileApp = true;
            }
        }
    }

    private void init() {
        showPassword = true;
        showNewPassword = true;
        Id userId = UserInfo.getUserId();
        userVal = [
            SELECT
                Id,
                Name,
                Username,
                FirstName,
                LastName,
                FullPhotoUrl,
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
                Contact.Cookies_Agreed_on_Reg__c,
                Contact.Participant_Opt_In_Status_Emails__c,
                Contact.Participant_Opt_In_Status_SMS__c ,
                Contact.Participant_Phone_Opt_In_Permit_Phone__c ,
                Contact.IQVIA_Direct_Mail_Consent__c, 
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
                LocaleSidKey,
                IsCommunityUserRegistered__c
            FROM User
            WHERE Id = :userId
        ];
        contact = userVal.Contact;
        system.debug('userVal.FullPhotoUrl' + userVal.FullPhotoUrl);

        maskUserName = userVal.Username.substring(0, 3) + '************';
        hasProfilePic = !userVal.FullPhotoUrl.contains('profilephoto/005/F');
        system.debug('hasProfilePic-->' + hasProfilePic);
        addPhotoLabel=hasProfilePic?System.Label.PP_AddProfilePhoto:System.Label.PP_AddPhoto;

        previousLanguage = contact.Language__c;

        Map<String, SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        helpText_1st_Language = fieldMap.get('Language__c').getDescribe().inlineHelpText;
        helpText_2nd_Language = fieldMap.get('Second_Choice_Language__c')
            .getDescribe()
            .inlineHelpText;
        helpText_3rd_Language = fieldMap.get('Third_Choice_Language__c')
            .getDescribe()
            .inlineHelpText;

        notEnrollNow = !((contact.userCommunytyType__c == null ||
        contact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) &&
        contact.userCommunityMode__c == CommunityService.USER_MODE_HCP);
        isStateRequired = false;

        Contact cont = [
            SELECT
                Id,
                Account.Name,
                Account.Phone,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.Fax,
                Account.BillingCountry,
                Account.BillingPostalCode,
                Account.BillingCountryCode,
                Language__c,
                MailingAddress,
                Salutation,
                MiddleName,
                Suffix,
                MailingCountry,
                MailingCountryCode,
                MailingCity,
                MailingPostalCode,
                MailingState,
                MailingStateCode,
                MailingStreet,
                OwnerId,
                userCommunytyType__c,
                userCommunityMode__c,
                Phone,
                Fax
            FROM Contact
            WHERE Id = :contact.Id
        ];
        account = cont.Account;
        if (account.Name.contains(TEMP_ACCOUNT)) {
            account.Name = '';
        }
        account.BillingCountry = TranslateHelper.getPickListLabel(
            User.CountryCode,
            account.BillingCountryCode
        );
        oldAccountName = account.Name;

        photolink = userVal.FullPhotoUrl;
        isProfileView = true;
        isPaswordsEquals = true;

        tcText = '';
        Terms_And_Conditions__c portalTC = TermsAndConditions.getPortalTC(false);
        if (portalTC != null) {
            tcText = portalTC.T_C_Text__c;
            tcId = portalTC.Id;
        }

        isParticipant = contact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT;
        if (isParticipant) {
            participant = [
                SELECT
                    Id,
                    Name,
                    First_Name__c,
                    Last_Name__c,
                    Phone__c,
                    Mailing_Country__c,
                    Mailing_State__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_Country_Code__c,
                    Mailing_State_Code__c,
                    Birth_Year__c

                FROM Participant__c
                WHERE Contact__c = :contact.Id
            ];
            
            updateTranslations();
        }
        countries = new List<SelectOption>();
        states = new List<SelectOption>();
        years = new List<SelectOption>();
        for (LabelValueItem country : CountryStateUtil.getCountries()) {
            countries.add(new SelectOption(country.value, country.label));
            countryCodeByName.put(country.value, country.label);
        }
        country = contact.MailingCountryCode;
        state = contact.MailingStateCode;
        isDelegate = contact.UserCommunityIsDelegate__c;
        showErrorMessage = false;
        isSaveButtonDisabled = false;
        if(participant!=null){
        maskLastName = participant.Last_Name__c.substring(0,1)+'************';
        maskDaytimephone =participant.Phone__c!=null? '************'+participant.Phone__c.substring(participant.Phone__c.length()-4,participant.Phone__c.length()):'';
    }
        if (isParticipant) {
            country = participant.Mailing_Country_Code__c;
            state = participant.Mailing_State_Code__c;

            /* Communitcation preference*/
            if (Site.getMasterLabel() == Label.IQVIA_Patient_Portal && contact.Is_First_Logon__c) {
            
                List<Participant_Enrollment__c> loginUserPEs = [
                    SELECT Id,Clinical_Trial_Profile__r.IQVIA_Outreach__c,Permit_Mail_Email_contact_for_this_study__c,Permit_SMS_Text_for_this_study__c ,Permit_Voice_Text_contact_for_this_study__c,Study_Direct_Mail_Consent__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c, Clinical_Trial_Profile__r.Privacy_Policy_ID__c
                    FROM Participant_Enrollment__c
                    WHERE Participant_Contact__c = :contact.Id AND Clinical_Trial_Profile__r.CommunityTemplate__c ='PatientPortal'
                ];
                if(loginUserPEs.size()>0)
                {
                    per= loginUserPEs[0];
                }

                if (contact.UserCommunityIsDelegate__c ) {
                   //Delegate Logic shoule be here
                   List<Patient_Delegate__c> delegatesPDList = [Select Id,Participant__r.Name,Participant__r.Contact__c  from Patient_Delegate__c where Contact__c = :contact.Id ];
                   if(delegatesPDList.size()>0)
                   {
                    List<Participant_Enrollment__c> delegateContactUserPEs = [
                        SELECT Id,Clinical_Trial_Profile__r.IQVIA_Outreach__c,Permit_Mail_Email_contact_for_this_study__c,Permit_SMS_Text_for_this_study__c ,Permit_Voice_Text_contact_for_this_study__c,Study_Direct_Mail_Consent__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c, Clinical_Trial_Profile__r.Privacy_Policy_ID__c
                        FROM Participant_Enrollment__c
                        WHERE Participant_Contact__c = :delegatesPDList[0].Participant__r.Contact__c AND Clinical_Trial_Profile__r.CommunityTemplate__c ='PatientPortal'
                    ];
                    if(delegateContactUserPEs.size()>0)
                    {
                        per= delegateContactUserPEs[0];
                    }
                   }

                }
            }
            /** Communication preference */
        }
        if (contact.UserCommunityIsDelegate__c && isParticipant) {
            Integer currentYear = Date.Today().Year();
            for (Integer i = currentYear; i > currentYear - 150; i--) {
                years.add(new SelectOption(String.valueof(i), String.valueof(i)));
            }
            birthYear = participant.Birth_Year__c;
            isAttested = false;
            isDisabled = false;
            if (!String.isBlank(participant.Birth_Year__c)) {
                isAdult = true;
            } else {
                isAdult = false;
            }
            isSaveButtonDisabled = true;
        }
        else if(isParticipant){
            birthYear = participant.Birth_Year__c;
        }
        if (!String.isBlank(country)) {
            updateStatesAction();
        }
        onLoad = false;
        Id ctpId;

        ctpId = per?.Clinical_Trial_Profile__c;
        String baseUrl = Site.getBaseUrl().replace('/pp', '/terms');

        if (
            (ctpId != null) &&
            (per.Clinical_Trial_Profile__r
                ?.Terms_And_Conditions_ID__c != null)
        ) {
            tcLink = baseUrl + '/s/terms-and-conditions?id=' + ctpId;
        } else {
            tcLink = baseUrl + '/s/terms-and-conditions/';
        }
        platformPrivacyPolicyUrl = baseUrl + '/s/privacy-policy';

        if (
            ctpId != null &&
            (per.Clinical_Trial_Profile__r
                ?.Privacy_Policy_Id__c != null)
        ) {
            studyPrivacyPolicyUrl = baseUrl + '/s/privacy-policy?id=' + ctpId;
        } else {
            studyPrivacyPolicyUrl = baseUrl + '/s/privacy-policy';
        }
    }

    public PageReference changePassword() {
        try {
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact cont = new contact();

            cont.Id = contact.Id;
            if(contact.Is_First_Logon__c){
            cont.Cookies_Agreed_on_Reg__c = true;
            }
            cont.Is_First_Logon__c = false;
            cont.Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH')
                ? CommunityService.IQVIA_NETWORK_NAME
                : Site.getMasterLabel();
            if (isParticipant) {
                cont.MailingCountrycode = contact.MailingCountrycode;
                cont.MailingStatecode = contact.MailingStatecode;
            }
            update cont;

            //            if(translation.Language__c != null) {
            //                userVal.LanguageLocaleKey = translation.Language__c;

            userVal.IsCommunityUserRegistered__c = true;
            update userVal;
            //            }
            for (ApexPages.Message m : ApexPages.getMessages()) {
                if (m.getDetail().contains(System.Label.Pswd_ValidationMsg5)) {
                    m = new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.Pswd_ValidationMsg6
                    );
                    failingPageResponse = m.getDetail();
                } else if (
                    m.getDetail().contains(System.Label.Pswd_Val_strng1) ||
                    m.getDetail().contains(System.Label.Pswd_Val_strng2) ||
                    m.getDetail().contains(System.Label.Pswd_ValidationMsg4)
                ) {
                    m = new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.Pswd_ValidationMsg3
                    );
                    failingPageResponse = m.getDetail();
                } else {
                    if (Site.getMasterLabel() == Label.IQVIA_Patient_Portal) {
                        failingPageResponse = System.Label.PP_CannotReuseOldPwd;
                    } else if (
                        m.getDetail().contains(System.Label.PP_CantReuseOldPwd) &&
                        !Site.getPathPrefix().startsWith('/gsk')
                    ) {
                        failingPageResponse = System.Label.PP_CantReuseOldPwd;
                    } else {
                        failingPageResponse = null;
                    }
                }
            }

            if (tcId != null) {
                Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c();
                tca.Accepted_Date__c = Datetime.now();
                tca.Terms_And_Conditions__c = tcId;
                tca.User__c = UserInfo.getUserId();
                insert tca;
            }

            return pr;
        } catch (Exception e) {
            isProfileView = true;
            return null;
        }
    }

    public PageReference ppChangePassword() {
        try {
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            contact cont = new contact();
            cont.Id = contact.Id;
            if(contact.Is_First_Logon__c){
            cont.Cookies_Agreed_on_Reg__c = true;
            }
            cont.Is_First_Logon__c = false;
            cont.Landing_Community__c = Site.getMasterLabel();
            if (isParticipant) {
                cont.MailingCountrycode = contact.MailingCountrycode;
                cont.MailingStatecode = contact.MailingStatecode;
                cont.MailingCountryCode = participant.Mailing_Country_Code__c;
                cont.MailingStateCode = participant.Mailing_State_Code__c;
                cont.Participant_Phone_Opt_In_Permit_Phone__c = contact.Participant_Phone_Opt_In_Permit_Phone__c;
                cont.Participant_Opt_In_Status_Emails__c = contact.Participant_Opt_In_Status_Emails__c;
                cont.Participant_Opt_In_Status_SMS__c = contact.Participant_Opt_In_Status_SMS__c;
                cont.IQVIA_Direct_Mail_Consent__c = contact.IQVIA_Direct_Mail_Consent__c;

            }
            if (isParticipant && ApexPages.getMessages().isEmpty()) {
                if (isDelegate && !isAttestationUpdated) {
                    participant.Attestation__c = true;
                    participant.Attestation_TimeStamp__c = ParticipantService.getFormattedTimeImpl(
                        userVal
                    );
                    participant.Attested_By__c = contact.id;
                    isAttestationUpdated = true;
                }
                if (isDelegate) {
                    participant.Attestation__c = true;
                }
               // update participant;
            }
            update cont;
            update participant;
            update per;
            userVal.IsCommunityUserRegistered__c = true;
            update userVal;
            for (ApexPages.Message m : ApexPages.getMessages()) {
                if (m.getDetail().contains(System.Label.Pswd_ValidationMsg5)) {
                    m = new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.Pswd_ValidationMsg6
                    );
                    failingPageResponse = m.getDetail();
                } else if (
                    m.getDetail().contains(System.Label.Pswd_Val_strng1) ||
                    m.getDetail().contains(System.Label.Pswd_Val_strng2) ||
                    m.getDetail().contains(System.Label.Pswd_ValidationMsg4)
                ) {
                    m = new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.Pswd_ValidationMsg3
                    );
                    failingPageResponse = m.getDetail();
                } else {
                    if (m.getDetail().contains(System.Label.PP_CantReuseOldPwd)) {
                        failingPageResponse = System.Label.PP_CantReuseOldPwd;
                    } else {
                        failingPageResponse = null;
                    }
                }
            }
            return pr;
        } catch (Exception e) {
            isProfileView = true;
            return null;
        }
    }
    public void toggleNewPassword() {
        showNewPassword = !showNewPassword;
    }
    public void togglePassword() {
        showPassword = !showPassword;
    }
    public void showProfileAction() {
        isProfileView = true;
        isAttestationUpdated = false;
    }

    public void checkPasswords() {
        try {
            ApexPages.getMessages().clear(); // Messages can't be cleared this way! Redirect page.
            Map<String, String> countryCodeByNameMap = new Map<String, String>();
            Map<String, String> stateCodeByNameMap = new Map<String, String>();
            Map<String, Map<String, String>> countryCodeByStateCodeByNameMap = new Map<String, Map<String, String>>();
            List<RH_State_Code_By_Country_Name__mdt> stateCodeByCountryList = [
                SELECT
                    RH_Country_Name__r.Country_Name__c,
                    RH_Country_Name__r.Country_Code__c,
                    RH_Country_Name__r.IsVisible__c,
                    State_Code__c,
                    State_Name__c,
                    IsVisible__c
                FROM RH_State_Code_By_Country_Name__mdt
            ];
            for (RH_State_Code_By_Country_Name__mdt objMetadata : stateCodeByCountryList) {
                if (
                    !String.isBlank(objMetadata.RH_Country_Name__r.Country_Code__c) &&
                    objMetadata.IsVisible__c == true &&
                    objMetadata.RH_Country_Name__r.IsVisible__c == true
                ) {
                    countryCodeByNameMap.put(
                        objMetadata.RH_Country_Name__r.Country_Code__c,
                        objMetadata.RH_Country_Name__r.Country_Name__c
                    );
                    if (!String.isBlank(objMetadata.State_Code__c)) {
                        if (
                            countryCodeByStateCodeByNameMap.containsKey(
                                objMetadata.RH_Country_Name__r.Country_Code__c
                            )
                        ) {
                            countryCodeByStateCodeByNameMap.get(
                                    objMetadata.RH_Country_Name__r.Country_Code__c
                                )
                                .put(objMetadata.State_Code__c, objMetadata.State_Name__c);
                        } else {
                            Map<String, String> stateCodeAndNameTemp = new Map<String, String>();
                            stateCodeAndNameTemp.put(
                                objMetadata.State_Code__c,
                                objMetadata.State_Name__c
                            );
                            countryCodeByStateCodeByNameMap.put(
                                objMetadata.RH_Country_Name__r.Country_Code__c,
                                stateCodeAndNameTemp
                            );
                        }
                    }
                }
                if (!String.isBlank(objMetadata.State_Code__c)) {
                    stateCodeByNameMap.put(objMetadata.State_Code__c, objMetadata.State_Name__c);
                }
            }
            if (isParticipant) {
                participant.Mailing_Country_Code__c = country;
                participant.Mailing_State_Code__c = state;
                participant.Birth_Year__c = birthYear;
                Boolean noCountry =
                    participant.Mailing_Country_Code__c == '--None--' ||
                    String.isBlank(participant.Mailing_Country_Code__c);
                Boolean noState =
                    participant.Mailing_State_Code__c == '--None--' ||
                    String.isBlank(participant.Mailing_State_Code__c) ||
                    states == null ||
                    states.size() < 1;
                participant.Mailing_Country__c = (noCountry
                    ? null
                    : countryCodeByNameMap.get(participant.Mailing_Country_Code__c));
                participant.Mailing_State__c = (noState
                    ? null
                    : countryCodeByStateCodeByNameMap.get(participant.Mailing_Country_Code__c)
                          .get(participant.Mailing_State_Code__c));

                contact.MailingCountryCode = participant.Mailing_Country_Code__c;
                contact.MailingStateCode = participant.Mailing_State_Code__c;
                // for country or states values update by code
                // contact.MailingCountry = participant.Mailing_Country__c;
                //  contact.MailingState = participant.Mailing_State__c;
            }
            if (
                (!notEnrollNow && String.isBlank(contact.FirstName)) ||
                (isParticipant && String.isBlank(participant.First_Name__c))
            ) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.RH_RP_First_Name + ERROR_SUFFIX
                    )
                );
            }
            if (
                (!notEnrollNow && String.isBlank(contact.LastName)) ||
                (isParticipant && String.isBlank(participant.Last_Name__c))
            ) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.RH_RP_Last_Name + ERROR_SUFFIX
                    )
                );
            }

            if (!notEnrollNow && ApexPages.getMessages().isEmpty()) {
                Boolean noCountry =
                    contact.MailingCountryCode == '--None--' ||
                    String.isBlank(contact.MailingCountryCode);
                Boolean noState =
                    contact.MailingStateCode == '--None--' ||
                    String.isBlank(contact.MailingStateCode) ||
                    states == null ||
                    states.size() < 1;
                contact.MailingCountry = (noCountry
                    ? null
                    : countryCodeByNameMap.get(contact.MailingCountryCode));
                contact.MailingState = (noState
                    ? null
                    : countryCodeByStateCodeByNameMap.get(contact.MailingCountryCode)
                          .get(contact.MailingStateCode));

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
                    List<Participant_Enrollment__c> loginUserPEs = [
                        SELECT Id
                        FROM Participant_Enrollment__c
                        WHERE Participant_Contact__c = :contact.Id
                    ];
                    List<RP_Delegate_Relationship__c> delgateRelationship = [
                        SELECT id, Delegate__c, Referring_Provider__c
                        FROM RP_Delegate_Relationship__c
                        WHERE Delegate__c = :contact.Id
                    ];

                    if (loginUserPEs.isEmpty() && contact.UserCommunityIsDelegate__c) {
                        contact.Current_Participant_Enrollment__c = null;
                        if (delgateRelationship != null) {
                            contact.userCommunityDelegateId__c = (delgateRelationship[0]
                                    .Delegate__c != contact.Id)
                                ? null
                                : delgateRelationship[0].Referring_Provider__c;
                        }
                        contact.Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH')
                            ? CommunityService.IQVIA_NETWORK_NAME
                            : Site.getMasterLabel();
                    }
                    update contact;
                    country = contact.MailingCountryCode;
                    state = contact.MailingStateCode;
                } catch (Exception exp) {
                    System.debug(exp);
                }
            }
            if (!notEnrollNow && String.isBlank(contact.MailingStreet)) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.PG_AS_F_Institute_Address_Line + ERROR_SUFFIX
                    )
                );
            }
            if (!notEnrollNow && String.isBlank(contact.MailingCity)) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.PG_AS_F_Institute_City + ERROR_SUFFIX
                    )
                );
            }
            if (
                (!notEnrollNow && String.isBlank(contact.MailingCountryCode)) ||
                (isParticipant && String.isBlank(participant.Mailing_Country_Code__c))
            ) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.RH_RP_Country + ERROR_SUFFIX
                    )
                );
            }
            if (
                ((!notEnrollNow && String.isBlank(contact.MailingStateCode)) ||
                (isParticipant && String.isBlank(participant.Mailing_State_Code__c))) &&
                states.size() > 0
            ) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.RH_RP_State + ERROR_SUFFIX
                    )
                );
            }
            if (!notEnrollNow && String.isBlank(contact.MailingPostalCode)) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.PG_AS_F_Institute_Zip_Postal_Code + ERROR_SUFFIX
                    )
                );
            }
            if (!notEnrollNow && String.isBlank(contact.Phone)) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.RH_RP_Delegate_Phone_Number + ERROR_SUFFIX
                    )
                );
            }
            if (!notEnrollNow && String.isBlank(account.Name)) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        System.Label.PG_AS_F_Institute_Name + ERROR_SUFFIX
                    )
                );
            }
            try {
                if (!Test.isRunningTest()) {
                    Site.validatePassword(userVal, newPassword, verifyNewPassword);
                    String errorMsg1 = 'The passwords do not match';
                    String errorMsg2 = 'The password you entered is too easy to guess. Enter a different one';
                    String errorMsg3 = 'Your password cannot be null';
                    for (ApexPages.Message m : ApexPages.getMessages()) {
                        if (m.getDetail().contains(System.Label.Pswd_ValidationMsg5)) {
                            m = new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                System.Label.Pswd_ValidationMsg6
                            );
                            failingPageResponse = m.getDetail();
                        } else if (
                            m.getDetail().contains(System.Label.Pswd_Val_strng1) ||
                            m.getDetail().contains(System.Label.Pswd_Val_strng2) ||
                            m.getDetail().contains(System.Label.Pswd_ValidationMsg4)
                        ) {
                            m = new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                System.Label.Pswd_ValidationMsg3
                            );
                            failingPageResponse = m.getDetail();
                        } else if (m.getDetail().contains(errorMsg3)) {
                            m = new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                System.Label.Pswd_ValidationMsg8
                            );
                            failingPageResponse = m.getDetail();
                        } else if (m.getDetail().contains(errorMsg1)) {
                            m = new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                System.Label.Pswd_ValidationMsg5
                            );
                            failingPageResponse = m.getDetail();
                        } else if (m.getDetail().contains(errorMsg2)) {
                            m = new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                System.Label.Pswd_ValidationMsg7
                            );
                            failingPageResponse = m.getDetail();
                        } else {
                            failingPageResponse = null;
                        }
                    }
                }
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }

            if (!notEnrollNow && ApexPages.getMessages().isEmpty()) {
                updateHCPStatus(contact.Id);
            }
            if (isParticipant && ApexPages.getMessages().isEmpty()) {
                if (isDelegate && !isAttestationUpdated) {
                    participant.Attestation__c = true;
                    participant.Attestation_TimeStamp__c = ParticipantService.getFormattedTimeImpl(
                        userVal
                    );
                    participant.Attested_By__c = contact.id;
                    isAttestationUpdated = true;
                }
                if (isDelegate) {
                    participant.Attestation__c = true;
                }
                update participant;
            }

            if (ApexPages.getMessages().isEmpty())
                isProfileView = false;
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    e.getMessage() +
                    '/n' +
                    e.getStackTraceString()
                )
            );
        }
    }

    @Future
    private static void updateHCPStatus(Id contactId) {
        List<HCP_Enrollment__c> hcpEnrollments = [
            SELECT
                Id, //
                HCP_Contact__c,
                Status__c
            FROM HCP_Enrollment__c
            WHERE
                HCP_Contact__c = :contactId
                AND Status__c = :HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
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

    public PageReference upload() {
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(
            blobValue,
            contentType,
            filename
        );
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), userVal.Id, photoFileInput);
        photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), userVal.Id)
            .fullEmailPhotoUrl;
        PageReference pf = new PageReference('/_ui/system/security/ChangePassword');
        pf.setRedirect(true);
        return pf;
    }

    public PageReference deletePicture() {
        system.debug('userval.Id' + userVal.Id);

        ConnectApi.UserProfiles.deletePhoto(Network.getNetworkId(), userVal.Id);
        photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), userVal.Id)
            .fullEmailPhotoUrl;
        PageReference pf = new PageReference('/_ui/system/security/ChangePassword');
        pf.setRedirect(true);
        return pf;
    }

    public void updateTranslations() {
        if (isParticipant) {
            //translate country:
            participant.Mailing_Country__c = CountryStateUtil.getCountryName(
                participant.Mailing_Country_Code__c
            );
            //translate state
            participant.Mailing_State__c = CountryStateUtil.getStateName(
                participant.Mailing_Country_Code__c,
                participant.Mailing_State_Code__c
            );
        }
    }

    public void initTemplateData() {
        CommunityTemplate currentTemplate = UserContext.getCurrentCommunityTemplate();
        siteName = Site.getName();
        currentCommunityName = UserContext.getCurrentCommunityName();
        templateName = currentTemplate.templateName;
        themeCSS = currentTemplate.properties.get(CommunityTemplateService.PROPERTY_THEME_CSS);
        backgroundStyle = currentTemplate.properties.get('LoginBackground');
        communityLogo = currentTemplate.properties.get(
            CommunityTemplateService.PROPERTY_COMMUNITY_LOGO
        );
        resetPassLogo = currentTemplate.properties.get(
            CommunityTemplateService.PROPERTY_RESET_PASS_LOGO
        );
       
    }

    public void updateBrowserLanguageAction() {
        System.debug(contact);
        if (
            contact != null &&
            contact.Is_First_Logon__c &&
            contact.Language__c != null &&
            contact.Language__c != '' &&
            (translation.Language__c == null ||
            translation.Language__c == '')
        ) {
            translation.Language__c = contact.Language__c;
        } else {
            List<String> browserLanguages = (List<String>) JSON.deserialize(
                browserLanguage,
                List<String>.class
            );
            String firstLanguage = browserLanguages.get(0);
            String secondLanguage = browserLanguages.get(1);
            String thirdLanguage = browserLanguages.get(2);

            if (
                String.isNotBlank(firstLanguage) &&
                TranslateHelper.convertBrowserLanguage(new List<String>{ firstLanguage }) != null
            ) {
                if (String.isBlank(contact.Language__c)) {
                    contact.Language__c = TranslateHelper.convertBrowserLanguage(
                        new List<String>{ firstLanguage }
                    );
                }
            } else {
                List<Schema.PicklistEntry> entries = Translation__c.Language__c.getDescribe()
                    .getPicklistValues();
                for (PicklistEntry entry : entries) {
                    if (entry.getValue().startsWithIgnoreCase('en')) {
                        contact.Language__c = entry.getValue();
                        break;
                    }
                }
                //              contact.Language__c = Translation__c.Language__c.getDescribe().getPicklistValues().get(0).getValue();
            }

            if (
                String.isNotBlank(secondLanguage) &&
                TranslateHelper.convertBrowserLanguage(new List<String>{ secondLanguage }) != null
            ) {
                contact.Second_Choice_Language__c = TranslateHelper.convertBrowserLanguage(
                    new List<String>{ secondLanguage }
                );
            }

            if (
                String.isNotBlank(thirdLanguage) &&
                TranslateHelper.convertBrowserLanguage(new List<String>{ thirdLanguage }) != null
            ) {
                contact.Third_Choice_Language__c = TranslateHelper.convertBrowserLanguage(
                    new List<String>{ thirdLanguage }
                );
            }

            translation.Language__c = contact.Language__c; //TranslateHelper.convertBrowserLanguage((List<String>)JSON.deserialize(browserLanguage, List<String>.class));
        }
        if (translation.Language__c == null)
            translation.Language__c = userVal.LanguageLocaleKey;
        updateLanguageAction();
    }

    public void updateLanguageAction() {
        try {
            userVal.LanguageLocaleKey = userVal.Contact.Language__c;
            update userVal;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            contact.Language__c = previousLanguage;
            return;
        }

        update contact;
        String rtl_language = System.Label.RTL_Languages;
        if (rtl_language.contains(contact.Language__c)) {
            isRTL = true;
        } else {
            isRTL = false;
        }
        if (isRTL) {
            tcText = tcText.replaceAll(
                '/s/privacy-policy',
                '/s/privacy-policy?lanCode=' + contact.Language__c
            );
            tcText = tcText.replaceAll(
                '/s/cookie-policy',
                '/s/cookie-policy?lanCode=' + contact.Language__c
            );
        } else {
            tcText = tcText.replaceAll(
                '/s/privacy-policy?lanCode=' + contact.Language__c,
                '/s/privacy-policy'
            );
            tcText = tcText.replaceAll(
                '/s/cookie-policy?lanCode=' + contact.Language__c,
                '/s/cookie-policy'
            );
        }
        countries = new List<SelectOption>();
        for (LabelValueItem country : CountryStateUtil.getCountries()) {
            countries.add(new SelectOption(country.value, country.label));
            countryCodeByName.put(country.value, country.label);
        }
        states = new List<SelectOption>();
        List<LabelValueItem> statesByCountry;
        statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        if (isParticipant) {
            statesByCountry = statesByCountryMap.get(participant.Mailing_Country_Code__c);
            country = participant.Mailing_Country_Code__c;
        } else {
            statesByCountry = statesByCountryMap.get(contact.MailingCountryCode);
        }
        if (statesByCountry != null) {
            for (LabelValueItem state : statesByCountry) {
                states.add(new SelectOption(state.value, state.label));
                stateCodeByName.put(state.value, state.label);
            }
        }
        updateTranslations();
    }

    public void translateFieldsAction() {
        updateTranslations();
    }

    public void updateStatesAction() {
        stateCodeByName = new Map<String, String>();
        states = new List<SelectOption>();
        List<LabelValueItem> statesByCountry;
        if (isParticipant) {
            statesByCountry = statesByCountryMap.get(participant.Mailing_Country_Code__c);
            country = participant.Mailing_Country_Code__c;
        } else {
            statesByCountry = statesByCountryMap.get(contact.MailingCountryCode);
        }
        if (statesByCountry != null) {
            for (LabelValueItem state : statesByCountry) {
                states.add(new SelectOption(state.value, state.label));
                stateCodeByName.put(state.value, state.label);
            }
        }
        isStateRequired = statesByCountry != null && !statesByCountry.isEmpty();
        if (!onLoad && isParticipant) {
            state = '';
            participant.Mailing_State_Code__c = '';
            if (isDelegate) {
                updateFlags();
            }
        }
    }
    public void updateYearOfBirth() {
        state = participant.Mailing_State_Code__c;
        if (isDelegate) {
            updateFlags();
        }
    }
    private void updateFlags() {
        birthYear = '';
        participant.Birth_Year__c = '';
        isSaveButtonDisabled = true;
        isAttested = false;
        showErrorMessage = false;
        isDisabled = false;
    }
    public void validateAgeOfMajority() {
        participant.Mailing_Country_Code__c = country;
        participant.Mailing_State_Code__c = state;
        if (String.isBlank(participant.Birth_Year__c)) {
            isAttested = false;
            isDisabled = true;
            isSaveButtonDisabled = true;
            showErrorMessage = false;
        } else if (!String.isBlank(participant.Birth_Year__c)) {
            isAdult = false;
            birthYear = participant.Birth_Year__c;
            List<Age_of_Majority__mdt> ageOfMajorities = [
                SELECT DeveloperName, Country_Code__c, State_Code__c, Age__c
                FROM Age_of_Majority__mdt
            ];
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            for (Age_of_Majority__mdt ageOfMajority : ageOfMajorities) {
                if (ageOfMajority.Age__c != null) {
                    ageByCountryCode.put(
                        ageOfMajority.DeveloperName,
                        ageOfMajority.Age__c.intValue()
                    );
                }
            }
            Integer delegateAge =
                DateTime.now().yearGmt() - Integer.valueOf(participant.Birth_Year__c);

            if (
                ageByCountryCode.get(
                    participant.Mailing_Country_Code__c +
                    '_' +
                    participant.Mailing_State_Code__c
                ) != null
            ) {
                if (
                    delegateAge >=
                    ageByCountryCode.get(
                        participant.Mailing_Country_Code__c +
                        '_' +
                        participant.Mailing_State_Code__c
                    )
                ) {
                    isAdult = true;
                }
            } else if (ageByCountryCode.get(participant.Mailing_Country_Code__c) != null) {
                if (delegateAge >= ageByCountryCode.get(participant.Mailing_Country_Code__c)) {
                    isAdult = true;
                }
            } else if (ageByCountryCode.get(AGE_OF_MAJORITY_ALL_COUNTRIES) != null) {
                if (delegateAge >= ageByCountryCode.get(AGE_OF_MAJORITY_ALL_COUNTRIES)) {
                    isAdult = true;
                }
            }
            if (isAdult) {
                showErrorMessage = false;
                isDisabled = false;
                if(per!=null && per.Clinical_Trial_Profile__r.CommunityTemplate__c=='PatientPortal')
                {
                    ppValidateSaveButton();
                }else{
                    validateSaveButton();
                }
            } else {
                showErrorMessage = true;
                isAttested = false;
                isDisabled = true;
                isSaveButtonDisabled = true;
            }
        }
    }
    public void validateSaveButton() {
        participant.Mailing_Country_Code__c = country;
        participant.Mailing_State_Code__c = state;
        participant.Birth_Year__c = birthYear;
        if (
            (country != null && !String.isBlank(country)) &&
            ((isStateRequired && state != null && !String.isBlank(state)) || !isStateRequired) &&
            (birthYear != null && !String.isBlank(birthYear)) &&
            isAttested &&
            isAdult
        ) {
            isSaveButtonDisabled = false;
        } else {
            isSaveButtonDisabled = true;
        }
    }
    public void ppValidateSaveButton()
    {
        if (String.isBlank(participant.Birth_Year__c) || !isAttested || passwordValidation) {
            isSaveButtonDisabled = true;
        }
        else{
          if(String.isNotBlank(participant.Birth_Year__c) && isAttested && !passwordValidation)
          {
            isSaveButtonDisabled = false;

          }
        }
    }
}
