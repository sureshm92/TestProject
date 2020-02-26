/**
 * Created by Leonid Bartenev
 */
global without sharing class EmailTemplateController {

    public static final String LABEL_EMAIL_USER_GREETING = 'Email_User_Greeting';

    public static final String LABEL_TITLE = 'Email_Title';
    public static final String LABEL_TITLE_PH = 'Email_Title_PH';
    public static final String LABEL_TITLE_ALL = 'Email_Title_ALL';

    public static final String LABEL_HEADER_INITIAL_PARTICIPANT = 'Email_Header_Initial_Patient';
    public static final String LABEL_HEADER_INITIAL_PATIENT_DELEGATE = 'Email_Header_Initial_Patient_Delegate';
    public static final String LABEL_HEADER_INITIAL_DELEGATE = 'Email_Header_Initial_Delegate';
    public static final String LABEL_HEADER_INITIAL_PI = 'Email_Header_Initial_PI';
    public static final String LABEL_HEADER_INITIAL_HCP = 'Email_Header_Initial_HCP';
    public static final String LABEL_HEADER_INITIAL_PI_PT_HCP = 'Email_Header_Initial_HCP';
    public static final String LABEL_HEADER_INITIAL_PI_HCP = 'Email_Header_Initial_HCP';

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
    public static final String LABEL_SIGNATURE_PATIENT_DELEGATE = 'Email_Signature_New_Participant_Delegate';
    public static final String LABEL_SIGNATURE = 'Email_Signature';
    public static final String LABEL_SIGNATURE_NEW = 'Email_Signature_New';

    public static final String LABEL_GREETING_VALUE_DEFAULT = 'Email_User_Greeting_FirstName';
    public static final String LABEL_GREETING_VALUE_PI_HCP = 'Email_User_Greeting';

    public static final String PARAM_PREFIX = '##';

    global String userCommunityType { get; set; }
    global String emailRecipientName { get; set; }
    global String emailRecipientId { get; set; }
    global String emailRecipientLanguage { get; set; }
    global String emailParametersProvider { get; set; }
    global Id sourceRecordId { get; set; }
    global Boolean replaceLineBreaksOnHTMLBreaks { get; set; }
    global Boolean showDelegateTableValue { get; set; }
    global Boolean multiplePIMessageValue { get; set; }
    global Boolean showDelegateSSTableValue { get; set; }

    global Boolean hasPIRPDelegationRecords {
        get {
            try {
                return !getDataProvider().delegateLevelsPI.isEmpty() || !getDataProvider().delegateLevelsHCP.isEmpty();
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return false;
            }
        }
    }

    private String bodyParamValue;
    global String bodyValue {
        get {
            try {
                setDefaultValues();
                String resValue = TranslateHelper.replaceParams(bodyValue, PARAM_PREFIX, getDataProvider().parameters);
                return prepareLineBreaks(resValue);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set {
            bodyValue = value;
            bodyParamValue = value;
        }
    }

    global String headerValue {
        get {
            try {
                setDefaultValues();
                if (headerValue.contains(PARAM_PREFIX)) {
                    String resValue = TranslateHelper.replaceParams(headerValue, PARAM_PREFIX, getDataProvider().parameters);
                    return prepareLineBreaks(resValue);
                } else {
                    return headerValue;
                }
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String titleValue {
        get {
            try {
                setDefaultValues();
                return titleValue;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String preSignatureValue {
        get {
            try {
                if (preSignatureValue == null) return null;
                return prepareLineBreaks(preSignatureValue);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String signatureValue {
        get {
            try {
                if (getDataProvider().userMode == CommunityModeService.USER_MODE_PARTICIPANT) {
                    String signatureLabel = getTemplateProperties().get('EmailTemplateSignatureLabel');
                    return prepareLineBreaks(TranslateHelper.getLabelValue(signatureLabel));
                }
                return prepareLineBreaks(signatureValue);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String userGreetingValue {
        get {
            try {
                setDefaultValues();
                return prepareLineBreaks(TranslateHelper.replaceParams(userGreetingValue, PARAM_PREFIX, getDataProvider().parameters) + '\n\n');
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String buttonLabelValue {
        get {
            try {
                return TranslateHelper.replaceParams(buttonLabelValue, PARAM_PREFIX, getDataProvider().parameters);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String buttonUrlValue {
        get {
            try {
                return TranslateHelper.replaceParams(buttonUrlValue, PARAM_PREFIX, getDataProvider().parameters);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String dataParametersValue {
        get {
            try {
                return JSON.serialize(getDataProvider().parameters);
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    private Map<String, String> getTemplateProperties() {
        if (sourceRecordId !=null) {
            String userModeString = getDataProvider().userMode;
            String templateName = TemplatePropertiesService.getTemplatePropertiesBySObject(sourceRecordId, emailRecipientId, userModeString);
            if (templateName != null) {
                return CommunityTemplateService.getTemplate(templateName).properties;
            }
        }
        return CommunityTemplateService.getDefaultTemplate().properties;
    }

    global String emailTemplateBackground {
        get {
            try {
                emailTemplateBackground = getTemplateProperties().get('EmailTemplateBackgr');
                return emailTemplateBackground;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateTextBackground {
        get {
            try {
                emailTemplateTextBackground = getTemplateProperties().get('EmailTemplateTextBackgr');
                return emailTemplateTextBackground;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateHeaderBackground {
        get {
            try {
                emailTemplateHeaderBackground = getTemplateProperties().get('EmailTemplateHeaderBackgr');
                return emailTemplateHeaderBackground;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateHeader {
        get {
            try {
                emailTemplateHeader = getTemplateProperties().get('EmailTemplateHeader');
                return emailTemplateHeader;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateTitle {
        get {
            try {
                emailTemplateTitle = getTemplateProperties().get('EmailTemplateTitle');
                return emailTemplateTitle;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateBrandLogo {
        get {
            try {
                emailTemplateBrandLogo = getTemplateProperties().get('EmailTemplateBrandLogo');
                return emailTemplateBrandLogo;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateBottomLogo {
        get {
            try {
                emailTemplateBottomLogo = getTemplateProperties().get('EmailTemplateBottomLogo');
                return emailTemplateBottomLogo;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String emailTemplateBrandLogoCSS {
        get {
            try {
                emailTemplateBrandLogoCSS = getTemplateProperties().get('EmailTemplateBrandLogoCSS');
                return emailTemplateBrandLogoCSS;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    global String outputMode { get; set; }
    private ParametersDataProvider dataProvider;
    private String userLanguageCode;

    public ParametersDataProvider getDataProvider() {
        if (dataProvider == null) {
            dataProvider = new ParametersDataProvider(sourceRecordId, emailRecipientName, emailRecipientId, emailRecipientLanguage, emailParametersProvider, userCommunityType, outputMode, multiplePIMessageValue);
        }
        return dataProvider;
    }

    global String getUserLanguageCode() {
        try {
            if (userLanguageCode == null) userLanguageCode = getDataProvider().getUserLanguage();
            return userLanguageCode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return e.getMessage();
        }
    }

    global List<DelegateLevelWrapper> getDelegateLevelsPI() {
        try {
            return getDataProvider().delegateLevelsPI;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return new List<DelegateLevelWrapper>();
        }
    }

    global List<DelegateLevelWrapper> getDelegateLevelsHCP() {
        try {
            return getDataProvider().delegateLevelsHCP;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return new List<DelegateLevelWrapper>();
        }
    }

    global String getResultUserMode() {
        try {
            return getDataProvider().userMode;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return e.getMessage();
        }
    }

    global Boolean getIsDelegate() {
        try {
            return getDataProvider().isDelegate;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return false;
        }
    }

    global String getUserName() {
        try {
            return getDataProvider().getUserName();
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return e.getMessage();
        }
    }

    global Map<String, String> getParameters() {
        try {
            return getDataProvider().parameters;
        } catch (Exception e) {
            EmailService.sendException(e, null);
            return new Map<String, String>();
        }
    }

    public String prepareLineBreaks(String source) {
        if (source == null) return null;
        if (replaceLineBreaksOnHTMLBreaks) return source.replaceAll('\n', '<br/>');
        return source;
    }

    public void setDefaultValues() {
        try {
            if (sourceRecordId != null &&
                    (sourceRecordId.getSobjectType() == User.getSObjectType()
                            || sourceRecordId.getSobjectType() == Contact.getSObjectType())
                    && bodyParamValue == null) {
                String bodyLabel;
                String headerLabel;
                String titleLabel;
                String signatureLabel;
                String userGreetingLabel = LABEL_GREETING_VALUE_DEFAULT;
                if (getDataProvider().isDelegate) {
                    userCommunityType = getDataProvider().userMode;
                    if (getDataProvider().userMode == CommunityService.USER_MODE_PARTICIPANT) {
                        bodyLabel = LABEL_BODY_INITIAL_PATIENT_DELEGATE;
                        headerLabel = LABEL_HEADER_INITIAL_PATIENT_DELEGATE;
                        titleLabel = LABEL_TITLE_ALL;
                        signatureLabel = LABEL_SIGNATURE_PATIENT_DELEGATE;
                    } else {
                        bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
                        headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
                        titleLabel = LABEL_TITLE_ALL;
                        signatureLabel = LABEL_SIGNATURE;
                    }
                } else if (getDataProvider().userMode == CommunityService.USER_MODE_PARTICIPANT) {
                    String referralSource = getDataProvider().parameters.get('ReferralSource');
                    if (referralSource == 'PI') {
                        bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_BY_PI;
                    } else if (referralSource == 'HCP') {
                        bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT;
                    } else {
                        bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_EPR;
                    }
                    headerLabel = LABEL_HEADER_INITIAL_PARTICIPANT;
                    titleLabel = LABEL_TITLE_ALL;
                    signatureLabel = LABEL_SIGNATURE_PATIENT;
                } else if (getDataProvider().userMode == CommunityService.USER_MODE_PI) {
                    bodyLabel = LABEL_BODY_INITIAL_PI;
                    headerLabel = LABEL_HEADER_INITIAL_PI;
                    titleLabel = LABEL_TITLE_ALL;
                    signatureLabel = LABEL_SIGNATURE;
                    userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                } else if (getDataProvider().userMode == CommunityService.USER_MODE_HCP) {
                    Contact hcpContact;
                    if (sourceRecordId.getSobjectType() == Contact.getSObjectType()) {
                        hcpContact = [SELECT Id, userCommunytyType__c, userCommunityMode__c FROM Contact WHERE Id = :sourceRecordId];
                    } else if (sourceRecordId.getSobjectType() == User.getSObjectType()) {
                        User hcpUsr = [SELECT Id, ContactId FROM User WHERE Id = :sourceRecordId];
                        hcpContact = [SELECT Id, userCommunytyType__c, userCommunityMode__c FROM Contact WHERE Id = :hcpUsr.ContactId];
                    }
                    if (hcpContact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP) && hcpContact.userCommunityMode__c == CommunityService.USER_MODE_HCP) {
                        List<Healthcare_Provider__c> hcp = [SELECT Id FROM Healthcare_Provider__c WHERE HCP_Enrollment__c IN (SELECT Id FROM HCP_Enrollment__c WHERE HCP_Contact__c = :hcpContact.Id)];
                        Map<Id, List<HCP_Enrollment__c>> PIpeMap = new Map<Id, List<HCP_Enrollment__c>>();
                        for (HCP_Enrollment__c hcpe : [
                                SELECT Id,
                                        Study_Site__r.Principal_Investigator__c
                                FROM HCP_Enrollment__c
                                WHERE HCP_Contact__c = :hcpContact.Id AND
                                (Status__c = :HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O OR Status__c = :HCPEnrollmentService.HCP_S_ACTIVATED )
                                ORDER BY CreatedDate DESC
                        ]) {
                            if (PIpeMap.containsKey(hcpe.Study_Site__r.Principal_Investigator__c)) {
                                PIpeMap.get(hcpe.Study_Site__r.Principal_Investigator__c).add(hcpe);
                            } else {
                                PIpeMap.put(hcpe.Study_Site__r.Principal_Investigator__c, new List<HCP_Enrollment__c>{
                                        hcpe
                                });
                            }
                        }
                        /*List<HCP_Enrollment__c> hcpe = [
                                SELECT Id
                                FROM HCP_Enrollment__c
                                WHERE HCP_Contact__c = :hcpContact.Id AND
                                ( Status__c = :HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O OR Status__c = :HCPEnrollmentService.HCP_S_ACTIVATED )
                                ORDER BY CreatedDate DESC
                        ];*/
                        if (!hcp.isEmpty()) {
                            bodyLabel = LABEL_BODY_INITIAL_PI_PT_HCP;
                            headerLabel = LABEL_HEADER_INITIAL_PI_PT_HCP;
                            titleLabel = LABEL_TITLE_ALL;
                            signatureLabel = LABEL_SIGNATURE;
                            userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                            dataProvider = new ParametersDataProvider(sourceRecordId, emailRecipientName, emailRecipientId, emailRecipientLanguage, emailParametersProvider, userCommunityType, outputMode, false);
                        } else if (!PIpeMap.isEmpty()) {
                            if (PIpeMap.keySet().size() > 1) {
                                multiplePIMessageValue = true;
                            }
                            bodyLabel = LABEL_BODY_INITIAL_PI_HCP;
                            headerLabel = LABEL_HEADER_INITIAL_PI_HCP;
                            titleLabel = LABEL_TITLE_ALL;
                            signatureLabel = LABEL_SIGNATURE;
                            userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                            dataProvider = new ParametersDataProvider(sourceRecordId, emailRecipientName, emailRecipientId, emailRecipientLanguage, emailParametersProvider, userCommunityType, outputMode, multiplePIMessageValue);
                        } else {
                            bodyLabel = LABEL_BODY_INITIAL_HCP;
                            headerLabel = LABEL_HEADER_INITIAL_HCP;
                            titleLabel = LABEL_TITLE_ALL;
                            signatureLabel = LABEL_SIGNATURE;
                            userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                        }
                    } else {
                        bodyLabel = LABEL_BODY_INITIAL_HCP;
                        headerLabel = LABEL_HEADER_INITIAL_HCP;
                        titleLabel = LABEL_TITLE_ALL;
                        signatureLabel = LABEL_SIGNATURE;
                        userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                    }
                }

                if (bodyLabel != null) bodyValue = TranslateHelper.getLabelValue(bodyLabel, getUserLanguageCode());
                if (headerLabel != null) headerValue = TranslateHelper.getLabelValue(headerLabel, getUserLanguageCode());
                if (titleLabel != null) titleValue = TranslateHelper.getLabelValue(titleLabel, getUserLanguageCode());
                if (getDataProvider().userMode == CommunityModeService.USER_MODE_PARTICIPANT) {
                    String signatureLabelForTranslate = getTemplateProperties().get('EmailTemplateSignatureLabel');
                    signatureValue = prepareLineBreaks(TranslateHelper.getLabelValue(signatureLabelForTranslate));
                } else {
                    if (signatureLabel != null) signatureValue = TranslateHelper.getLabelValue(signatureLabel, getUserLanguageCode());
                }
                if (userGreetingLabel != null) userGreetingValue = TranslateHelper.getLabelValue(userGreetingLabel, getUserLanguageCode());
            }
        } catch (Exception e) {
            EmailService.sendException(e, null);
        }
    }

}