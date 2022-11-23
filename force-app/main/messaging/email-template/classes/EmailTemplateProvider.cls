/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing virtual class EmailTemplateProvider {
    public static final String PARAM_PREFIX = '##';
    public static final String DEFAULT_LANGUAGE = 'en_US';
    // Added the value at line number 14 to fix REF-2560 bug, PIName is not displaying receipient.
    public static final Map<String, String> PARAM_PROVIDER_BY_TYPE = new Map<String, String>{
        'Case' => 'Email_Template_Parameters_From_Case',
        'Contact' => 'PP_Contact',
        'Clinical_Trial_Profile__c' => 'Email_Template_Parameters_From_CTP',
        'HCP_Enrollment__c' => 'Email_Template_Parameters_From_HCPE',
        'Participant__c' => 'PP_Participant',
        'Healthcare_Provider__c' => 'PP_Healthcare_Provider',
        'Participant_Enrollment__c' => 'Email_Template_Parameters_From_PE',
        'Resource__c' => 'Email_Template_Parameters_From_Resource',
        'Study_Site__c' => 'PP_Study_Site',
        'SurveyInvitation' => 'Email_Template_Parameters_From_SI',
        'Task' => 'Email_Template_Parameters_From_Task',
        'Trial_Notification__c' => 'Email_Template_Parameters_From_TN',
        'Televisit__c' => 'Email_Template_Parameters_From_TV',
        'Televisit_Attendee__c' => 'Email_Template_Parameters_From_TA'
    };

    protected Id recipientId;
    protected String recipientName;
    protected String recipientLanguage;
    protected Boolean isHTML = true;
    protected String recipientFirstName;
    protected Id recipientContactId;
    protected Boolean isDelegate = false;
    @TestVisible
    protected String userMode = 'Guest';
    protected Id whatId;
    protected Boolean isShareTemplate = false;
    private Boolean initialized = false;

    protected TemplatePropertiesService templatePropertiesService;
    protected Map<String, String> parameters = new Map<String, String>();

    public virtual void initState(
        Id recipientId,
        String recipientName,
        String recipientLanguage,
        String communityTemplateName,
        Id whatId,
        String outputMode,
        String shareTemplate
    ) {
        this.recipientId = recipientId;
        this.recipientName = recipientName;
        this.recipientLanguage = recipientLanguage;
        UserService.contactIDvalue = recipientId;
        if (shareTemplate == 'Yes')
            this.isShareTemplate = true;
        if (String.isNotEmpty(outputMode))
            this.isHTML = outputMode.equals('HTML');

        updateRecipientName();

        templatePropertiesService = String.isNotEmpty(communityTemplateName)
            ? new TemplatePropertiesService(communityTemplateName)
            : new TemplatePropertiesService(whatId, userMode);
        fillTemplateParams();

        parameters.put('RecipientName', getUserName());
        parameters.put('RecipientFirstName', recipientFirstName);
        parameters.put('GuestName', TranslateHelper.getLabelValue(Label.Email_Guest_User_Name));
        //Cookie counter = new Cookie('recipientId', this.recipientId,null,-1,true);

        initCRCommunityUrl();

        if (whatId != null) {
            this.whatId = whatId;
            String parametersProvider = PARAM_PROVIDER_BY_TYPE.get(
                whatId.getSobjectType().getDescribe().getName()
            );
            if (!String.isEmpty(parametersProvider)) {
                List<SObject> sObjects = ParametersProviderService.queryRecords(
                    new List<Id>{ whatId },
                    parametersProvider
                );
                if (!sObjects.isEmpty()) {
                    parameters.putAll(
                        ParametersProviderService.getValueMap(
                            parametersProvider,
                            sObjects.get(0),
                            this.recipientLanguage
                        )
                    );
                }
            }
        }
        if (isDelegate && userMode == 'Participant')
            initYourParticipantFirstName();

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
        if (recipientLanguage != null)
            return recipientLanguage;
        String langParam = userMode + 'Language';
        String language = parameters.get(langParam);
        if (language != null)
            return language;
        return DEFAULT_LANGUAGE;
    }

    public String getDelegateBottomTxt() {
        if (recipientId.getSobjectType() != User.getSObjectType())
            return '';
        return TranslateHelper.replaceParams(
            TranslateHelper.getLabelValue(
                Label.Email_Body_Initial_Patient_Delegate_AfterText,
                recipientLanguage
            ),
            PARAM_PREFIX,
            parameters
        );
    }

    //Template Specific Properties:-------------------------------------------------------------------------------------
    private void fillTemplateParams() {
        parameters.put(
            'emailTemplateBackground',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_BACKGROUND
            )
        );
        parameters.put(
            'emailTemplateBackgroundRTL',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_BACKGROUND_RTL
            )
        );
        parameters.put(
            'emailTemplateTextBackground',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_TEXT_BACKGROUND
            )
        );
        parameters.put(
            'emailTemplateHeaderBackground',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_BACKGROUND
            )
        );
        parameters.put(
            'emailTemplateHeaderBackgroundRTL',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_BACKGROUND_RTL
            )
        );
        parameters.put(
            'emailTemplateHeader',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER
            )
        );
        parameters.put(
            'emailTemplateTitle',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE
            )
        );
        parameters.put(
            'emailTemplateBrandLogo',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO
            )
        );
        parameters.put(
            'emailTemplateBrandLogoCSS',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_BRAND_LOGO_CSS
            )
        );
        parameters.put(
            'emailTemplateBottomLogo',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_BOTTOM_LOGO
            )
        );

        parameters.put(
            'HeaderShortName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_HEADER_SHORT_NAME
            )
        );
        parameters.put(
            'FullCommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_LABEL
            )
        );
        parameters.put(
            'ShortCommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME_SHORT
            )
        );
        parameters.put(
            'SignatureFullCommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE
            )
        );
        parameters.put(
            'SignatureFullCommunityNewName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_SHORT
            )
        );
        parameters.put(
            'SignatureShortCommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_SHORT
            )
        );
        parameters.put(
            'SignatureShortCommunityVTName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_SIGNATURE_VT_SHORT
            )
        );
        parameters.put(
            'CommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_COMM_NAME
            )
        );
        parameters.put(
            'SignatureCommunityName',
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_SIGN_COMM_NAME
            )
        );
        parameters.put(
            'SignatureTeam',
            templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_SIGN_TEAM)
        );

        parameters.put(
            TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL,
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL
            )
        );
        parameters.put(
            TemplatePropertiesCatalog.TEMPLATE_PROP_TEAM_RH,
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_TEAM_RH
            )
        );
        parameters.put(
            TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM,
            templatePropertiesService.getPropertyValue(
                TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM
            )
        );
        parameters.put(
            TemplatePropertiesCatalog.COMM_TEMPLATE_URL,
            templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.COMM_TEMPLATE_URL)
        );
    }

    private void initCRCommunityUrl() {
        String clinicalResearchCommunityURL = isHTML
            ? '<a href="https://www.clinicalresearch.com" target="_blank">IQVIA Clinical Research Community</a>'
            : 'IQVIA Clinical Research Community at https://www.clinicalresearch.com';
        parameters.put('CRCommunityURL', clinicalResearchCommunityURL);
    }

    private void updateRecipientName() {
        if (recipientId == null)
            return;

        Contact recipientContact;
        if (recipientId.getSobjectType() == User.getSObjectType()) {
            User recipientUser = [
                SELECT
                    Id,
                    ContactId,
                    Contact.FirstName,
                    Contact.Salutation,
                    Contact.Salutation_With_Name__c,
                    Contact.Language__c,
                    Contact.UserCommunityIsDelegate__c,
                    Contact.userCommunityMode__c,
                    LanguageLocaleKey
                FROM User
                WHERE Id = :recipientId
            ];
            recipientContact = recipientUser.Contact;
            if (recipientContact == null)
                return;
        } else {
            recipientContact = [
                SELECT
                    Id,
                    Salutation,
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
        isDelegate = recipientContact.UserCommunityIsDelegate__c;

        recipientFirstName = recipientContact.FirstName;
        List<Participant__c> participants = [
            SELECT First_Name__c, Last_Name__c
            FROM Participant__c
            WHERE Contact__c = :recipientContactId
        ];
        if (!participants.isEmpty()) {
            recipientFirstName = checkMetacharacters(participants.get(0).First_Name__c);
            recipientName =
                (recipientContact.Salutation == null ? '' : recipientContact.Salutation) +
                ' ' +
                checkMetacharacters(participants.get(0).First_Name__c) +
                ' ' +
                checkMetacharacters(participants.get(0).Last_Name__c);
        }

        if (String.isEmpty(recipientName))
            recipientName = recipientContact.Salutation_With_Name__c;
        parameters.put(userMode + 'Name', recipientName);
        parameters.put('UserName', getCommunityUserName());

        if (String.isEmpty(recipientLanguage))
            recipientLanguage = recipientContact.Language__c;
        if (isShareTemplate)
            userMode = CommunityModeService.USER_MODE_PARTICIPANT;
    }
    private String checkMetacharacters(String str) {
        if (String.isNotBlank(str))
            return Matcher.quoteReplacement(str);
        else
            return str;
    }

    private String getCommunityUserName() {
        List<User> userList = [SELECT Username FROM User WHERE ContactId = :recipientContactId];
        return !userList.isEmpty() ? userList.get(0).Username : '';
    }

    private String getUserName() {
        if (recipientName != null)
            return recipientName;
        String userNameParam = isDelegate ? 'FullName' : userMode + 'Name';
        String name = parameters.get(userNameParam);
        if (name == null)
            name = parameters.get('ParticipantContactFirstName');
        return name;
    }

    protected virtual void initYourParticipantFirstName() {
        if (parameters.containsKey('ParticipantFirstName'))
            return;

        Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(
            recipientContactId
        );
        if (participant != null) {
            parameters.put('ParticipantFirstName', checkMetacharacters(participant.First_Name__c));
            parameters.put('ParticipantLastName', checkMetacharacters(participant.Last_Name__c));
        }
    }

    public void addStudySiteNumber() {
        List<AggregateResult> totalParticipants = new List<AggregateResult>();
        List<Id> studySites = new List<Id>();

        if (recipientId != null) {
            for (Site_Staff__c ss : [
                SELECT Study_Site__c, is_Invited__c
                FROM Site_Staff__c
                WHERE
                    Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                    AND Site_Contact__c = :recipientId
                    AND is_Invited__c = TRUE
                    AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                    AND Study_Site__r.Override_PI_Referral_Status__c IN (
                        'Accepted',
                        'Accepted (Admin)'
                    )
            ]) {
                studySites.add(ss.Study_Site__c);
            }

            totalParticipants = [
                SELECT count(Id)
                FROM Participant_Enrollment__c
                WHERE
                    (Participant_Status__c = 'Received'
                    OR (Participant_Status__c IN (
                        'Contact Attempted',
                        'Pre-review Passed',
                        'Successfully Contacted',
                        'Successfully re-engaged'
                    )
                    AND High_Priority__c = TRUE))
                    AND (Study_Site__c IN :studySites
                    OR PI_Contact__c = :recipientId)
                    AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                    AND Study_Site__r.Override_PI_Referral_Status__c IN (
                        'Accepted',
                        'Accepted (Admin)'
                    )
            ];
        }
        String size = '0';
        if (totalParticipants.size() > 0) {
            size = String.valueOf(totalParticipants[0].get('expr0'));
        }
        parameters.put('TotalStudies', size);
    }
}
