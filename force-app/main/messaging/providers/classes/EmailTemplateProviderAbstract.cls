/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public abstract without sharing class EmailTemplateProviderAbstract {

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

    public EmailTemplateProviderAbstract() {
    }

    public EmailTemplateProviderAbstract(Id sourceId, Id recipientId, String recipientName, String recipientLanguage,
            String parametersProviderName, String outputMode
    ) {
        updateRecipientName(recipientId, recipientName, recipientLanguage);

        templatePropertiesService = new TemplatePropertiesService(sourceId, this.recipientContactId, userMode, isDelegate);
        parameters.putAll(getTemplateParams());
        parameters.put('RecipientName', getUserName());
        parameters.put('RecipientFirstName', recipientFirstName);

        isHTML = outputMode == 'HTML';
        initCRCommunityUrl(isHTML);
        initForgotPassURL(isHTML);

        if (!String.isEmpty(parametersProviderName)) {
            parameters.putAll(CatalogParametersHelper.getParamsValueMap(
                    sourceId,
                    CatalogParametersHelper.getParametersProviderMetadata(parametersProviderName),
                    this.recipientLanguage
            ));
        }
    }

    public void initLabels(Map<String, String> labels) {

    }

    public Map<String, String> getParameters() {
        return parameters;
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

    //Template Specific Properties:-------------------------------------------------------------------------------------
    private Map<String, String> getTemplateParams() {
        Map<String, String> templateParams = new Map<String, String>();
        templateParams.put('emailTemplateBackground', getEmailTemplateBackground());
        templateParams.put('emailTemplateTextBackground', getEmailTemplateTextBackground());
        templateParams.put('emailTemplateHeaderBackground', getEmailTemplateHeaderBackground());
        templateParams.put('emailTemplateHeader', getEmailTemplateHeader());
        templateParams.put('emailTemplateTitle', getEmailTemplateTitle());
        templateParams.put('emailTemplateBrandLogo', getEmailTemplateBrandLogo());
        templateParams.put('emailTemplateBottomLogo', getEmailTemplateBottomLogo());
        templateParams.put('emailTemplateBrandLogoCSS', getEmailTemplateBrandLogoCSS());
        return templateParams;
    }

    private String getEmailTemplateBackground() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BACKGROUND);
    }

    private String getEmailTemplateHeaderBackground() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_BACKGROUND);
    }

    private String getEmailTemplateTextBackground() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TEXT_BACKGROUND);
    }

    private String getEmailTemplateHeader() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER);
    }

    private String getEmailTemplateTitle() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE);
    }

    private String getEmailTemplateBrandLogo() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO);
    }

    private String getEmailTemplateBrandLogoCSS() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO_CSS);
    }

    private String getEmailTemplateBottomLogo() {
        return templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_BOTTOM_LOGO);
    }

    //Labels: ----------------------------------------------------------------------------------------------------------
    public virtual void setHeaderValue(String headerLabel) {
        String headerLabelValue = TranslateHelper.getLabelValue(headerLabel, recipientLanguage);
        if (headerLabelValue.contains(PARAM_PREFIX)) {
            String commNameShort =
                    templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_SHORT_NAME);
            parameters.put('HeaderShortName', commNameShort);
            headerLabelValue = prepareLineBreaks(TranslateHelper.replaceParams(headerLabelValue, PARAM_PREFIX, parameters));
        }
        parameters.put('headerValue', headerLabelValue);
    }

    public virtual void setTitleValue(String titleLabel) {
        String titleLabelValue = TranslateHelper.getLabelValue(titleLabel, recipientLanguage);
        if (titleLabelValue.contains(PARAM_PREFIX)) {
            titleLabelValue = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM);
        }
        parameters.put('titleValue', titleLabelValue);
    }

    public virtual void setGreetingValue(String greetingLabel) {
        String greetingLabelValue = TranslateHelper.getLabelValue(greetingLabel, recipientLanguage);
        parameters.put(
                'greetingValue',
                prepareLineBreaks(TranslateHelper.replaceParams(greetingLabelValue, PARAM_PREFIX, parameters) + '\n\n')
        );
    }

    public virtual void setBodyValue(String bodyLabel) {
        String commNameFull = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_LABEL);
        String commNameShort = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_SHORT);
        parameters.put('CommunityName', commNameFull);
        parameters.put('ShortCommunityName', commNameShort);
        String bodyLabelValue = TranslateHelper.getLabelValue(bodyLabel, recipientLanguage);
        parameters.put(
                'bodyValue',
                prepareLineBreaks(TranslateHelper.replaceParams(bodyLabelValue, PARAM_PREFIX, parameters))
        );
    }

    public virtual void setPreSignatureValue(String preSignatureLabel) {
        parameters.put(
                'preSignatureValue',
                prepareLineBreaks(TranslateHelper.getLabelValue(preSignatureLabel, recipientLanguage))
        );
    }

    public virtual void setSignatureValue(String signatureLabel) {
        String commNameFull = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE);
        String commNameShort = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_SHORT);
        String commName = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME);

        parameters.put('SignatureFullCommunityName', commNameFull);
        parameters.put('SignatureShortCommunityName', commNameShort);
        parameters.put('CommunityName', commName);
        String signatureLabelValue = TranslateHelper.getLabelValue(signatureLabel, recipientLanguage);
        signatureLabelValue = TranslateHelper.replaceParams(signatureLabelValue, PARAM_PREFIX, parameters);
        parameters.put(
                'signatureValue',
                prepareLineBreaks(signatureLabelValue)
        );
    }

    public void setButtonLabelValue(String buttonLabel) {
        parameters.put('buttonValue', TranslateHelper.replaceParams(buttonLabel, PARAM_PREFIX, parameters));
    }

    public void setButtonUrlValue(String buttonUrlLabel) {
        parameters.put('buttonUrlValue', TranslateHelper.replaceParams(buttonUrlLabel, PARAM_PREFIX, parameters));
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
                            Contact.Name, Contact.FirstName, Contact.LastName, Contact.Salutation,
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
                            Name, FirstName, LastName, Salutation,
                            Language__c,
                            UserCommunityIsDelegate__c,
                            userCommunityMode__c
                    FROM Contact
                    WHERE Id = :recipientId
            ];
        }
        parameters.put('FullName', getFullContactName(recipientContact));
        recipientContactId = recipientContact.Id;

        this.recipientName = recipientName;
        if(String.isEmpty(this.recipientName)) {
            this.recipientName = (recipientContact.Salutation == null ? '' : recipientContact.Salutation + ' ')
                    + recipientContact.Name;
        }

        recipientFirstName = recipientContact.FirstName;

        this.recipientLanguage = recipientLanguage;
        if(String.isEmpty(this.recipientLanguage)) this.recipientLanguage = recipientContact.Language__c;
        isDelegate = recipientContact.UserCommunityIsDelegate__c;
        userMode = recipientContact.userCommunityMode__c;
    }

    protected String getFullContactName(Contact c) {
        String fullName = c.Name;
        if (c.Salutation != null) fullName = c.Salutation + ' ' + fullName;
        return fullName;
    }

    private String getCommunityUserName(String contactId) {
        List<User> userList = [SELECT Username FROM User WHERE ContactId = :contactId];
        return !userList.isEmpty() ? userList.get(0).Username : '';
    }

    private String prepareLineBreaks(String source) {
        if (source == null) return null;
        if (isHTML) return source.replaceAll('\n', '<br/>');
        return source;
    }
}