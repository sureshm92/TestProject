/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public virtual without sharing class EmailTemplateProvider {

    public static final String PARAM_PREFIX = '##';
    public static final String DEFAULT_LANGUAGE = 'en_US';

    protected TemplatePropertiesService templatePropertiesService;
    protected Map<String, String> parameters = new Map<String, String>();

    protected String recipientName;
    protected String recipientFirstName;
    protected Id recipientContactId;
    protected String recipientLanguage;
    protected Boolean isDelegate;
    protected String userMode;

    private Boolean isHTML;
    private static Boolean isReady = false;

    private static EmailTemplateInitial templateInitial;
    public static void setTemplateInitial(EmailTemplateInitial initial) {
        templateInitial = initial;
    }

    public static Boolean haveTemplateInitial() {
        return templateInitial != null;
    }

    private static EmailTemplateProvider instance;
    public static EmailTemplateProvider getInstance() {
        if(instance == null) instance = new EmailTemplateProvider();
        return instance;
    }

    private EmailTemplateProvider() {
        updateRecipientName(templateInitial.recipientId, recipientName, recipientLanguage);

        templatePropertiesService = String.isNotEmpty(templateInitial.communityTemplateName) ?
                new TemplatePropertiesService(templateInitial.communityTemplateName) :
                new TemplatePropertiesService(templateInitial.whatId, this.recipientContactId, userMode, isDelegate);
        fillTemplateParams();

        parameters.put('RecipientName', getUserName());
        parameters.put('RecipientFirstName', recipientFirstName);
        parameters.put('GuestName', TranslateHelper.getLabelValue(Label.Email_Guest_User_Name));
        if (isDelegate && userMode == 'Participant') initYourParticipantFirstName();

        isHTML = templateInitial.outputMode == 'HTML';
        initCRCommunityUrl(isHTML);
//        initForgotPassURL(isHTML);

        if (!String.isEmpty(templateInitial.parametersProviderName) && templateInitial.whatId != null) {
            parameters.putAll(CatalogParametersHelper.getParamsValueMap(
                    templateInitial.whatId,
                    CatalogParametersHelper.getParametersProviderMetadata(templateInitial.parametersProviderName),
                    this.recipientLanguage
            ));
        }
        if(!templateInitial.additionalParams.isEmpty()) parameters.putAll(templateInitial.additionalParams);

        isReady = true;
        System.debug('PARAMS: ' + JSON.serializePretty(parameters));
    }

    public static Boolean isReady() {
        return isReady;
    }

    public Map<String, String> getParameters() {
        return parameters;
    }

    public Boolean isHTML() {
        return isHTML;
    }

    public String getCommunityTemplateName() {
        return templatePropertiesService.getTemplateName();
    }

    public Id getRecipientId() {
        return recipientContactId;
    }

    public String getRecipientLanguage() {
        return recipientLanguage;
    }

    public Boolean isDelegate() {
        return isDelegate;
    }

    public String getUserMode() {
        return userMode;
    }

    public virtual String getUserName() {
        if (recipientName != null) return recipientName;
        String userNameParam = isDelegate ? 'FullName' : userMode + 'Name';
        String name = parameters.get(userNameParam);
        if (name == null) name = parameters.get('ParticipantContactFirstName');
        return name;
    }

    public String getUserLanguage() {
        if (recipientLanguage != null) return recipientLanguage;
        String langParam = userMode + 'Language';
        String language = parameters.get(langParam);
        if (language != null) return language;
        return DEFAULT_LANGUAGE;
    }

    public String getDelegateBottomTxt() {
        if(templateInitial.recipientId.getSobjectType() != User.getSObjectType()) return '';
        return TranslateHelper.replaceParams(
                TranslateHelper.getLabelValue(Label.Email_Body_Initial_Patient_Delegate_AfterText, recipientLanguage),
                PARAM_PREFIX, parameters
        );
    }

    //Template Specific Properties:-------------------------------------------------------------------------------------
    private void fillTemplateParams() {
        parameters.put('emailTemplateBackground', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BACKGROUND));
        parameters.put('emailTemplateTextBackground', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TEXT_BACKGROUND));
        parameters.put('emailTemplateHeaderBackground', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_BACKGROUND));
        parameters.put('emailTemplateHeader', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER));
        parameters.put('emailTemplateTitle', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE));
        parameters.put('emailTemplateBrandLogo', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO));
        parameters.put('emailTemplateBrandLogoCSS', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO_CSS));
        parameters.put('emailTemplateBottomLogo', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BOTTOM_LOGO));

        parameters.put('HeaderShortName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_SHORT_NAME));
        parameters.put('CommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_LABEL));
        parameters.put('ShortCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_SHORT));
        parameters.put('SignatureFullCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE));
        parameters.put('SignatureShortCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_SHORT));
        parameters.put('CommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME));

        parameters.put(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL, templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL));
        parameters.put(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM, templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM));
    }

    //Specific URLs:----------------------------------------------------------------------------------------------------
    private void initCRCommunityUrl(Boolean isHTML) {
        String clinicalResearchCommunityURL = isHTML ?
                '<a href="https://www.clinicalresearch.com" target="_blank">IQVIA Clinical Research Community</a>'
                : 'IQVIA Clinical Research Community at https://www.clinicalresearch.com';
        parameters.put('CRCommunityURL', clinicalResearchCommunityURL);
    }

    private void initForgotPassURL(Boolean isHTML) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(Network.getNetworkId(), '');
        String clinicalResearchCommunityForgotPasswordURL = isHTML ? '' : 'IQVIA Clinical Research Community Forgot password at';
        clinicalResearchCommunityForgotPasswordURL += authConfig.getForgotPasswordUrl();
        parameters.put('ForgotPasswordURL', clinicalResearchCommunityForgotPasswordURL);
    }

    protected virtual void updateRecipientName(Id recipientId, String recipientName, String recipientLanguage) {
        if (recipientId == null) return;

        Contact recipientContact;
        if (recipientId.getSobjectType() == User.getSObjectType()) {
            User recipientUser = [
                    SELECT Id,
                            ContactId,
                            Contact.FirstName,
                            Contact.Salutation_With_Name__c,
                            Contact.Language__c,
                            Contact.UserCommunityIsDelegate__c,
                            Contact.userCommunityMode__c,
                            LanguageLocaleKey
                    FROM User
                    WHERE Id = :recipientId
            ];
            recipientContact = recipientUser.Contact;
        } else {
            recipientContact = [
                    SELECT Id,
                            FirstName,
                            Language__c,
                            Salutation_With_Name__c,
                            UserCommunityIsDelegate__c,
                            userCommunityMode__c
                    FROM Contact
                    WHERE Id = :recipientId
            ];
        }
        recipientContactId = recipientContact.Id;

        userMode = recipientContact.userCommunityMode__c;
        recipientFirstName = recipientContact.FirstName;
        this.recipientName = recipientName;
        if (String.isEmpty(this.recipientName)) this.recipientName = recipientContact.Salutation_With_Name__c;
        parameters.put(userMode + 'Name', this.recipientName);

        this.recipientLanguage = recipientLanguage;
        if (String.isEmpty(this.recipientLanguage)) this.recipientLanguage = recipientContact.Language__c;

        isDelegate = recipientContact.UserCommunityIsDelegate__c;
        if (isDelegate) parameters.put('UserName', getCommunityUserName(recipientContactId));
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            List<Participant__c> participants = [
                    SELECT First_Name__c, Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c = :recipientContactId
            ];
            if (!participants.isEmpty()) recipientFirstName = participants.get(0).First_Name__c;
        }
    }

    private String getCommunityUserName(String contactId) {
        List<User> userList = [SELECT Username FROM User WHERE ContactId = :contactId];
        return !userList.isEmpty() ? userList.get(0).Username : '';
    }

    private void initYourParticipantFirstName() {
        Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(recipientContactId);
        if (participant != null) parameters.put('ParticipantFirstName', participant.First_Name__c);
    }
}