/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public abstract without sharing class EmailTemplateInitial {

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

    public static final String LABEL_HEADER_INITIAL_DELEGATE = 'Email_Header_Initial_Delegate';
    public static final String LABEL_GREETING_VALUE_PI_HCP = 'Email_User_Greeting';
    public static final String LABEL_BODY_INITIAL_DELEGATE = 'Email_Body_Initial_Delegate';

    protected String headerLabel;
    protected String titleLabel = 'Email_Title_ALL';
    protected String greetingLabel = 'Email_User_Greeting_FirstName';
    protected String bodyLabel;
    protected String signatureLabel = 'Email_Signature';

    public Map<String, String> templateLabels;
    public Map<String, String> additionalParams;

    public Id whatId;
    public Id recipientId;
    public String recipientName;
    public String recipientLanguage;
    public String outputMode;
    public String communityTemplateName;
    public String parametersProviderName;

    public EmailTemplateInitial(Map<String, String> templateLabels, Id recipientId, String outputMode, String communityTemplateName) {
        this.templateLabels = templateLabels;
        this.recipientId = recipientId;
        this.outputMode = outputMode;
        this.communityTemplateName = communityTemplateName;

        additionalParams = new Map<String, String>();
    }

    protected void updateTemplateLabels() {
        templateLabels.put('title', titleLabel);
        templateLabels.put('header', headerLabel);
        templateLabels.put('greeting', greetingLabel);
        templateLabels.put('body', bodyLabel);
        templateLabels.put('signature', signatureLabel);
    }
}