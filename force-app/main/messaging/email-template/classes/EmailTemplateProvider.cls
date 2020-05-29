/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing virtual class EmailTemplateProvider {

    public static final String PARAM_PREFIX = '##';
    public static final String DEFAULT_LANGUAGE = 'en_US';
    public static final Map<String, String> PARAM_PROVIDER_BY_TYPE = new Map<String, String>{
            'Case' => 'Email_Template_Parameters_From_Case',
            'Contact' => 'PP_Contact',
            'Clinical_Trial_Profile__c' => 'Email_Template_Parameters_From_CTP',
            'HCP_Enrollment__c' => 'Email_Template_Parameters_From_HCPE',
            'Participant__c' => 'PP_Participant',
            'Participant_Enrollment__c' => 'Email_Template_Parameters_From_PE',
            'Resource__c' => 'Email_Template_Parameters_From_Resource',
            'Study_Site__c' => 'PP_Study_Site',
            'SurveyInvitation' => 'Email_Template_Parameters_From_SI',
            'Task' => 'Email_Template_Parameters_From_Task',
            'Trial_Notification__c' => 'Email_Template_Parameters_From_TN'
    };

    protected Id recipientId;
    protected String recipientName;
    protected String recipientLanguage;
    protected Boolean isHTML = true;
    protected String recipientFirstName;
    protected Id recipientContactId;
    protected Boolean isDelegate;
    protected String userMode;

    private Boolean initialized = false;

    protected TemplatePropertiesService templatePropertiesService;
    protected Map<String, String> parameters = new Map<String, String>();

    public virtual void initState(Id recipientId, String recipientName, String recipientLanguage,
            String communityTemplateName, Id whatId, String outputMode) {
        this.recipientId = recipientId;
        this.recipientName = recipientName;
        this.recipientLanguage = recipientLanguage;
        if(!String.isNotEmpty(outputMode)) this.isHTML = outputMode.equals('HTML');

        updateRecipientName();

        templatePropertiesService = String.isNotEmpty(communityTemplateName) ?
                new TemplatePropertiesService(communityTemplateName) :
                new TemplatePropertiesService(whatId, userMode);
        fillTemplateParams();

        parameters.put('RecipientName', getUserName());
        parameters.put('UserName', getCommunityUserName(recipientContactId));
        parameters.put('RecipientFirstName', recipientFirstName);
        parameters.put('GuestName', TranslateHelper.getLabelValue(Label.Email_Guest_User_Name));
        if (isDelegate && userMode == 'Participant') initYourParticipantFirstName();

        initCRCommunityUrl();

        if(whatId != null) {
            String parametersProvider = PARAM_PROVIDER_BY_TYPE.get(whatId.getSobjectType().getDescribe().getName());
            if (!String.isEmpty(parametersProvider)) {
                parameters.putAll(CatalogParametersHelper.getParamsValueMap(
                        whatId,
                        CatalogParametersHelper.getParametersProviderMetadata(parametersProvider),
                        this.recipientLanguage
                ));
            }
        }

        initialized = true;
    }

    public Boolean isInitialized() {
        return initialized;
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

    public String getCommunityName() {
        return templatePropertiesService.getCommunityName();
    }

    public Id getRecipientId() {
        return recipientContactId;
    }

    public String getUserMode() {
        return userMode;
    }

    public String getUserLanguage() {
        if (recipientLanguage != null) return recipientLanguage;
        String langParam = userMode + 'Language';
        String language = parameters.get(langParam);
        if (language != null) return language;
        return DEFAULT_LANGUAGE;
    }

    public String getDelegateBottomTxt() {
        if(recipientId.getSobjectType() != User.getSObjectType()) return '';
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
        parameters.put('FullCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_LABEL));
        parameters.put('ShortCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_SHORT));
        parameters.put('SignatureFullCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE));
        parameters.put('SignatureShortCommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_SHORT));
        parameters.put('CommunityName', templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME));

        parameters.put(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL, templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL));
        parameters.put(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM, templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM));
    }

    private void initCRCommunityUrl() {
        String clinicalResearchCommunityURL = isHTML ?
                '<a href="https://www.clinicalresearch.com" target="_blank">IQVIA Clinical Research Community</a>'
                : 'IQVIA Clinical Research Community at https://www.clinicalresearch.com';
        parameters.put('CRCommunityURL', clinicalResearchCommunityURL);
    }

    private void updateRecipientName() {
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

        if (String.isEmpty(recipientName)) recipientName = recipientContact.Salutation_With_Name__c;
        parameters.put(userMode + 'Name', recipientName);

        if (String.isEmpty(recipientLanguage)) recipientLanguage = recipientContact.Language__c;

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

    private String getUserName() {
        if (recipientName != null) return recipientName;
        String userNameParam = isDelegate ? 'FullName' : userMode + 'Name';
        String name = parameters.get(userNameParam);
        if (name == null) name = parameters.get('ParticipantContactFirstName');
        return name;
    }

    private void initYourParticipantFirstName() {
        Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(recipientContactId);
        if (participant != null) parameters.put('ParticipantFirstName', participant.First_Name__c);
    }
}