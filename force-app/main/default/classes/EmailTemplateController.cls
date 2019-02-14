/**
 * Created by Leonid Bartenev
 */


global without sharing class EmailTemplateController {
    
    public static final String LABEL_HEADER = 'Email_Header';
    public static final String LABEL_EMAIL_USER_GREETING = 'Email_User_Greeting';
    public static final String LABEL_BODY = 'Email_Body';
    public static final String LABEL_EMAIL_SIGNATURE = 'Email_Signature';
    public static final String LABEL_TITLE = 'Email_Title';
    
    public static final String TEMPLATE_ID_INITIAL_PARTICIPANT = 'Initial_Patient';
    public static final String TEMPLATE_ID_INITIAL_DELEGATE = 'Initial_Delegate';
    public static final String TEMPLATE_ID_INITIAL_PI = 'Initial_PI';
    public static final String TEMPLATE_ID_INITIAL_HCP = 'Initial_HCP';
    
    public static final String PARAM_PREFIX = '##';
    
    global String userCommunityType {get; set;}
    global Id sourceRecordId {get; set;}
    global Boolean replaceLineBreaksOnHTMLBreaks {get; set;}
    
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
            return headerValue;
        }
        set;
    }
    
    global String titleValue {
        get;
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
            return prepareLineBreaks(userGreetingValue + ' ' + getUserName() + ',\n\n');
        }
        set;
    }
    
    global String outputMode {get; set;}
    private ParametersDataProvider dataProvider;
    private String userLanguageCode;
    
    
    public ParametersDataProvider getDataProvider(){
        if (dataProvider == null) {
            dataProvider = new ParametersDataProvider(sourceRecordId, userCommunityType, outputMode);
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
        if(replaceLineBreaksOnHTMLBreaks) return  source.replaceAll('\n', '<br/>');
        return source;
    }
    
    private void setDefaultValues(){
        if(sourceRecordId != null &&
                (sourceRecordId.getSobjectType() == User.getSObjectType() || sourceRecordId.getSobjectType() == Contact.getSObjectType())
                && bodyParamValue == null){
            String bodyLabel;
            String headerLabel;
            if(getDataProvider().isDelegate){
                bodyLabel = LABEL_BODY + '_' + TEMPLATE_ID_INITIAL_DELEGATE;
                headerLabel = LABEL_HEADER + '_' + TEMPLATE_ID_INITIAL_DELEGATE;
            } else if(getDataProvider().userMode == CommunityService.USER_MODE_PARTICIPANT){
                bodyLabel = LABEL_BODY + '_' + TEMPLATE_ID_INITIAL_PARTICIPANT;
                headerLabel = LABEL_HEADER + '_' + TEMPLATE_ID_INITIAL_PARTICIPANT;
            }else if(getDataProvider().userMode == CommunityService.USER_MODE_PI){
                bodyLabel = LABEL_BODY + '_' + TEMPLATE_ID_INITIAL_PI;
                headerLabel = LABEL_HEADER + '_' + TEMPLATE_ID_INITIAL_PI;
            }else if(getDataProvider().userMode == CommunityService.USER_MODE_HCP){
                bodyLabel = LABEL_BODY + '_' + TEMPLATE_ID_INITIAL_HCP;
                headerLabel = LABEL_HEADER + '_' + TEMPLATE_ID_INITIAL_HCP;
            }
            if(bodyLabel != null){
                if(bodyLabel.contains(TEMPLATE_ID_INITIAL_PARTICIPANT) && getDataProvider().parameters.get('HCP') == null){
                    bodyLabel += '_virtual';
                }
                bodyValue = TranslateHelper.getLabelValue(bodyLabel, getUserLanguageCode());
            }
            if(headerLabel != null){
                headerValue = TranslateHelper.getLabelValue(headerLabel, getUserLanguageCode());
            }
        }
    }
    
}