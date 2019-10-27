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
    public static final String LABEL_HEADER_INITIAL_DELEGATE= 'Email_Header_Initial_Delegate';
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

    public static final String LABEL_SIGNATURE_PATIENT =  'Email_Signature_Patient';
    public static final String LABEL_SIGNATURE_PATIENT_DELEGATE =  'Email_Signature_New_Participant_Delegate';
    public static final String LABEL_SIGNATURE = 'Email_Signature';
    public static final String LABEL_SIGNATURE_NEW = 'Email_Signature_New';
    
    public static final String LABEL_GREETING_VALUE_DEFAULT = 'Email_User_Greeting_FirstName';
    public static final String LABEL_GREETING_VALUE_PI_HCP = 'Email_User_Greeting';

    public static final String PARAM_PREFIX = '##';
    
    global String userCommunityType {get; set;}
    global String emailRecipientName {get; set;}
    global String emailRecipientId {get; set;}
    global String emailRecipientLanguage {get; set;}
    global String emailParametersProvider {get; set;}
    global Id sourceRecordId {get; set;}
    global Boolean replaceLineBreaksOnHTMLBreaks {get; set;}
    global Boolean showDelegateTableValue {get; set;}
    global Boolean hasPIRPDelegationRecords {
        get{
            return !getDataProvider().delegateLevelsPI.isEmpty() || !getDataProvider().delegateLevelsHCP.isEmpty();
        }
    }

    private String bodyParamValue;
    global String bodyValue {
        get{
            setDefaultValues();
            String resValue = TranslateHelper.replaceParams(bodyValue, PARAM_PREFIX, getDataProvider().parameters);
            return prepareLineBreaks(resValue);
        }
        set{
            bodyValue = value;
            bodyParamValue = value;
        }
    }
    
    global String headerValue {
        get{
            setDefaultValues();
            if(headerValue.contains(PARAM_PREFIX)){
                String resValue = TranslateHelper.replaceParams(headerValue, PARAM_PREFIX, getDataProvider().parameters);
                return prepareLineBreaks(resValue);  
            }
            else{
                return headerValue;
            }
        }
        set; 
    }
    
    global String titleValue {
        get{
            setDefaultValues();
            return titleValue;
        }
        set;
    }
    
    global String preSignatureValue {
        get{
            if(preSignatureValue == null) return null;
            return prepareLineBreaks(preSignatureValue);
        }
        set;
    }
    
    global String signatureValue {
        get{
            return prepareLineBreaks(signatureValue);
        }
        set;
    }
    
    global String userGreetingValue {
        get{
            setDefaultValues();
            System.debug(userGreetingValue);
            return prepareLineBreaks(TranslateHelper.replaceParams(userGreetingValue, PARAM_PREFIX, getDataProvider().parameters) +'\n\n');
        }
        set;
    }

    global String buttonLabelValue {
        get {
            return TranslateHelper.replaceParams(buttonLabelValue, PARAM_PREFIX, getDataProvider().parameters);
        }
        set;
    }

    global String buttonUrlValue {
        get {
           return TranslateHelper.replaceParams(buttonUrlValue, PARAM_PREFIX, getDataProvider().parameters);
        }
        set;
    }
    
    global String outputMode {get; set;}
    private ParametersDataProvider dataProvider;
    private String userLanguageCode;
    
    
    public ParametersDataProvider getDataProvider(){
        if (dataProvider == null) {
            dataProvider = new ParametersDataProvider(sourceRecordId, emailRecipientName, emailRecipientId, emailRecipientLanguage, emailParametersProvider, userCommunityType, outputMode);
        }
        return dataProvider;
    }
    
    global String getUserLanguageCode(){
        if(userLanguageCode == null) userLanguageCode = getDataProvider().getUserLanguage();
        return userLanguageCode;
    }
    
    global List<DelegateLevelWrapper> getDelegateLevelsPI() {
        return getDataProvider().delegateLevelsPI;
    }
    
    global List<DelegateLevelWrapper> getDelegateLevelsHCP() {
        return getDataProvider().delegateLevelsHCP;
    }
    
    global String getResultUserMode(){
        return getDataProvider().userMode;
    }
    
    global Boolean getIsDelegate(){
        return getDataProvider().isDelegate;
    }
    
    global String getUserName(){
        return getDataProvider().getUserName();
    }
    
    global Map<String, String> getParameters(){
        return getDataProvider().parameters;
    }
    
    private String prepareLineBreaks(String source){
        if(source == null) return null;
        if(replaceLineBreaksOnHTMLBreaks) return  source.replaceAll('\n', '<br/>');
        return source;
    }
    
    private void setDefaultValues(){
        if(sourceRecordId != null &&
                (sourceRecordId.getSobjectType() == User.getSObjectType() || sourceRecordId.getSobjectType() == Contact.getSObjectType())
                && bodyParamValue == null){
            String bodyLabel;
            String headerLabel;
            String titleLabel;
            String signatureLabel;
            String userGreetingLabel = LABEL_GREETING_VALUE_DEFAULT;
            if(getDataProvider().isDelegate){
                if(getDataProvider().userMode == CommunityService.USER_MODE_PARTICIPANT){
                    bodyLabel = LABEL_BODY_INITIAL_PATIENT_DELEGATE;
                    headerLabel = LABEL_HEADER_INITIAL_PATIENT_DELEGATE;
                    titleLabel = LABEL_TITLE_ALL;
                    signatureLabel = LABEL_SIGNATURE_PATIENT_DELEGATE;
                }else{
                    bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
                    headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
                    titleLabel = LABEL_TITLE_ALL;
                    signatureLabel = LABEL_SIGNATURE;
                }
            } else if(getDataProvider().userMode == CommunityService.USER_MODE_PARTICIPANT){
                String referralSource = getDataProvider().parameters.get('ReferralSource');
                if(referralSource == 'PI'){
                    bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_BY_PI;
                }else if(referralSource == 'HCP'){
                    bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT;
                }else{
                    bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_EPR;
                }
                headerLabel = LABEL_HEADER_INITIAL_PARTICIPANT;
                titleLabel = LABEL_TITLE_ALL;
                signatureLabel = LABEL_SIGNATURE_PATIENT;
            }else if(getDataProvider().userMode == CommunityService.USER_MODE_PI){
                bodyLabel = LABEL_BODY_INITIAL_PI;
                headerLabel = LABEL_HEADER_INITIAL_PI;
                titleLabel = LABEL_TITLE_ALL;
                signatureLabel = LABEL_SIGNATURE;
                userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
            }else if(getDataProvider().userMode == CommunityService.USER_MODE_HCP){
                Contact hcpContact;
                if (sourceRecordId.getSobjectType() == Contact.getSObjectType()) {
                    hcpContact = [SELECT Id, userCommunytyType__c, userCommunityMode__c FROM Contact WHERE Id = :sourceRecordId];
                } else if (sourceRecordId.getSobjectType() == User.getSObjectType()) {
                    User hcpUsr = [SELECT Id, ContactId FROM User WHERE Id = :sourceRecordId];
                    hcpContact = [SELECT Id, userCommunytyType__c, userCommunityMode__c FROM Contact WHERE Id = :hcpUsr.ContactId];
                }
                if (hcpContact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP) && hcpContact.userCommunityMode__c == CommunityService.USER_MODE_HCP) {
                    List<Healthcare_Provider__c> hcp = [SELECT Id FROM Healthcare_Provider__c WHERE HCP_Enrollment__c IN (SELECT Id FROM HCP_Enrollment__c WHERE HCP_Contact__c =:hcpContact.Id)];
                    List<HCP_Enrollment__c> hcpe = [
                            SELECT Id
                            FROM HCP_Enrollment__c
                            WHERE HCP_Contact__c = :hcpContact.Id AND
                            ( Status__c = :HCPEnrollmentService.HCP_S_INVITATION_SENT OR Status__c = :HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION )
                            ORDER BY CreatedDate DESC LIMIT 1
                    ];
                    if (!hcp.isEmpty()) {
                        bodyLabel = LABEL_BODY_INITIAL_PI_PT_HCP;
                        headerLabel = LABEL_HEADER_INITIAL_PI_PT_HCP;
                        titleLabel = LABEL_TITLE_ALL;
                        signatureLabel = LABEL_SIGNATURE;
                        userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
                    } else if (!hcpe.isEmpty()){
                        bodyLabel = LABEL_BODY_INITIAL_PI_HCP;
                        headerLabel = LABEL_HEADER_INITIAL_PI_HCP;
                        titleLabel = LABEL_TITLE_ALL;
                        signatureLabel = LABEL_SIGNATURE;
                        userGreetingLabel = LABEL_GREETING_VALUE_PI_HCP;
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
            
            if(bodyLabel != null) bodyValue = TranslateHelper.getLabelValue(bodyLabel, getUserLanguageCode());
            if(headerLabel != null) headerValue = TranslateHelper.getLabelValue(headerLabel, getUserLanguageCode());
            if(titleLabel != null) titleValue = TranslateHelper.getLabelValue(titleLabel, getUserLanguageCode());
            if(signatureLabel != null) signatureValue = TranslateHelper.getLabelValue(signatureLabel, getUserLanguageCode());
            if(userGreetingLabel != null) userGreetingValue = TranslateHelper.getLabelValue(userGreetingLabel, getUserLanguageCode());
        }
    }
    
}
