/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public abstract without sharing class EmailTemplateInitialAbstract {

    public static final String LABEL_TITLE_ALL = 'Email_Title_ALL';

    public static final String LABEL_HEADER_INITIAL_PARTICIPANT = 'Email_Header_Initial_Patient';
    public static final String LABEL_HEADER_INITIAL_PATIENT_DELEGATE = 'Email_Header_Initial_Patient_Delegate';
    public static final String LABEL_HEADER_INITIAL_DELEGATE = 'Email_Header_Initial_Delegate';
    public static final String LABEL_HEADER_INITIAL_PI = 'Email_Header_Initial_PI';
    public static final String LABEL_HEADER_INITIAL_HCP = 'Email_Header_Initial_HCP';
    public static final String LABEL_HEADER_INITIAL_PI_PT_HCP = 'Email_Header_Initial_HCP';
    public static final String LABEL_HEADER_INITIAL_PI_HCP = 'Email_Header_Initial_HCP';

    public static final String LABEL_GREETING_VALUE_DEFAULT = 'Email_User_Greeting_FirstName';
    public static final String LABEL_GREETING_VALUE_PI_HCP = 'Email_User_Greeting';

    public static final String LABEL_BODY_INITIAL_PARTICIPANT = 'Email_Body_Initial_Patient';
    public static final String LABEL_BODY_INITIAL_PARTICIPANT_BY_PI = 'Email_Body_Initial_Patient_Created_By_PI';
    public static final String LABEL_BODY_INITIAL_PARTICIPANT_EPR = 'Email_Body_Initial_Patient_Virtual';
    public static final String LABEL_BODY_INITIAL_PATIENT_DELEGATE = 'Email_Body_Initial_Patient_Delegate';
    public static final String LABEL_BODY_INITIAL_DELEGATE = 'Email_Body_Initial_Delegate';
    public static final String LABEL_BODY_INITIAL_PI = 'Email_Body_Initial_PI';
    public static final String LABEL_BODY_INITIAL_HCP = 'Email_Body_Initial_HCP';
    public static final String LABEL_BODY_INITIAL_PI_PT_HCP = 'Email_Body_Initial_PI_PT_HCP';
    public static final String LABEL_BODY_INITIAL_PI_HCP = 'Email_Body_Initial_PI_HCP';

    public static final String LABEL_SIGNATURE_PATIENT = 'Email_Signature_Patient';
    public static final String LABEL_SIGNATURE = 'Email_Signature';
    public static final String LABEL_SIGNATURE_NEW = 'Email_Signature_New';

    protected String headerLabel;
    protected String titleLabel = LABEL_TITLE_ALL;
    protected String greetingLabel = LABEL_GREETING_VALUE_DEFAULT;
    protected String bodyLabel;
    protected String signatureLabel = LABEL_SIGNATURE;

    private Map<String, String> templateLabels;
    protected Id recipientId;
    private String outputMode;
    private String communityTemplateName;

    protected Id whatId;
    protected String parametersProviderName;

    public EmailTemplateInitialAbstract(Map<String, String> templateLabels, Id recipientId,
            String outputMode, String communityTemplateName) {
        this.templateLabels = templateLabels;
        this.recipientId = recipientId;
        this.outputMode = outputMode;
        this.communityTemplateName = communityTemplateName;
    }

    public EmailTemplateProviderDefault getProvider() {
        templateLabels.putAll(getTemplateLabels());
        return new EmailTemplateProviderDefault(templateLabels, whatId, recipientId, null, null, parametersProviderName, outputMode, null);
    }

    private Map<String, String> getTemplateLabels() {
        Map<String, String> templateLabels = new Map<String, String>{
                'title' => titleLabel,
                'header' => headerLabel,
                'greeting' => greetingLabel,
                'body' => bodyLabel,
                'signature' => signatureLabel
        };
        return templateLabels;
    }
}