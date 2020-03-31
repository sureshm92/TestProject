/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public without sharing class EmailTemplateProviderInitial {

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

    private String headerLabel;
    private String titleLabel = LABEL_TITLE_ALL;
    private String greetingLabel = LABEL_GREETING_VALUE_DEFAULT;
    private String bodyLabel;
    private String signatureLabel = LABEL_SIGNATURE;

    private EmailTemplateProviderAbstract emailTemplateProvider;


    public EmailTemplateProviderInitial(Id sourceId, String outputMode, String communityTemplateName) {
        User user = [SELECT Id, ContactId, Contact.userCommunityMode__c FROM User WHERE Id = :sourceId];
        String userMode = user.Contact.userCommunityMode__c;
        switch on userMode {
            when 'PI' {
                emailTemplateProvider = new EmailTemplateProviderPI(sourceId, sourceId, null,
                        null, null, outputMode
                );
            }
            when 'HCP' {
                emailTemplateProvider = new EmailTemplateProviderHCP(
                        sourceId, sourceId, null, null, null, outputMode
                );
            }
            when else {
                emailTemplateProvider = new EmailTemplateProviderPT(
                        sourceId, sourceId, null, null, null,
                        outputMode, communityTemplateName
                );
            }
        }

        setInitialLabels();
    }

    public EmailTemplateProviderAbstract getProvider() {
        return emailTemplateProvider;
    }

    private void setInitialLabels() {
        if (emailTemplateProvider.isDelegate()) {
            setDelegateLabels();
        } else {
            if (emailTemplateProvider.getUserMode() == CommunityService.USER_MODE_PARTICIPANT) {
                setParticipantLabels();
            } else {
                greetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                if (emailTemplateProvider.getUserMode() == CommunityService.USER_MODE_PI) {
                    setPrincipalInvestigatorLabels();
                } else {
                    setHCPLabels();
                }
            }
        }

        emailTemplateProvider.setHeaderValue(headerLabel);
        emailTemplateProvider.setTitleValue(titleLabel);
        emailTemplateProvider.setGreetingValue(greetingLabel);
        emailTemplateProvider.setBodyValue(bodyLabel);
        emailTemplateProvider.setSignatureValue(signatureLabel);
    }

    private void setDelegateLabels() {
        if (emailTemplateProvider.getUserMode() == CommunityService.USER_MODE_PARTICIPANT) {
            headerLabel = LABEL_HEADER_INITIAL_PATIENT_DELEGATE;
            bodyLabel = LABEL_BODY_INITIAL_PATIENT_DELEGATE;
            signatureLabel = LABEL_SIGNATURE_NEW;
        } else {
            headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
            bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
        }
    }

    private void setParticipantLabels() {
        bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_EPR;
        headerLabel = LABEL_HEADER_INITIAL_PARTICIPANT;
        signatureLabel = LABEL_SIGNATURE_PATIENT;

        String referralSource = ((EmailTemplateProviderPT) emailTemplateProvider).getReferralSource();
        if (referralSource == 'PI') {
            bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_BY_PI;
        } else if (referralSource == 'HCP') {
            bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT;
        }
    }

    private void setPrincipalInvestigatorLabels() {
        bodyLabel = LABEL_BODY_INITIAL_PI;
        headerLabel = LABEL_HEADER_INITIAL_PI;
    }

    private void setHCPLabels() {
        bodyLabel = LABEL_BODY_INITIAL_HCP;
        headerLabel = LABEL_HEADER_INITIAL_HCP;

        EmailTemplateProviderHCP emailTemplateProviderHCP = ((EmailTemplateProviderHCP) emailTemplateProvider);
        if (emailTemplateProviderHCP.hasHealCareProviders()) {
            bodyLabel = LABEL_BODY_INITIAL_PI_PT_HCP;
            headerLabel = LABEL_HEADER_INITIAL_PI_PT_HCP;
        } else if (emailTemplateProviderHCP.hasEnrollments()) {
            bodyLabel = LABEL_BODY_INITIAL_PI_HCP;
            headerLabel = LABEL_HEADER_INITIAL_PI_HCP;
        }
    }
}