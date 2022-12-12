/**
 * Created by Rushikesh Kadam on 03.10.2022.
 */
global without sharing class PP_EmailWireframeController {
    global String titleValue { get; set; }
    global String headerValue { get; set; }
    global Boolean isPreBodyButtonValue { get; set; }
    global String preBodyButtonNameValue { get; set; }
    global String preBodyButtonURLValue { get; set; }
    global String greetingValue { get; set; }
    global String preSignatureValue { get; set; }
    global String signatureValue { get; set; }
    global String shareTemplate { get; set; }
    global Id sourceRecordId { get; set; }
    global String emailRecipientName { get; set; }
    global String emailRecipientId { get; set; }
    global String emailRecipientLanguage { get; set; }
    global String communityTemplateValue { get; set; }
    global String specificEmailProviderValue { get; set; }
    global String outputMode { get; set; }
    global String displayOptOut { get; set; }
    global String userModeValue { get; set; }
    global Id surveyIdString { get; set; }
    private EmailTemplateProvider templateProvider;

    global String getUserLanguageCode() {
        return getProvider().getUserLanguage();
    }

    global string communityTypeURL {
        get {
            if (communityTemplateValue == 'PatientPortal')
                communityTypeURL = '/pp';
            else
                communityTypeURL = '';
            return communityTypeURL;
        }
        set;
    }
    global String userMode {
        get {
            try {
                if (userMode == null)
                    userMode = getProvider().getUserMode();
                return userMode;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return null;
            }
        }
        set;
    }
    global Id recipientcntId {
        get {
            try {
                if (recipientcntId == null)
                    recipientcntId = getProvider().getRecipientId();
                if (recipientcntId == null)
                    recipientcntId = getProvider().getParameters().get('RecipientContactId');
                return recipientcntId;
            } catch (Exception e) {
                EmailService.sendException(e, null);
                return e.getMessage();
            }
        }
        set;
    }

    public Boolean getEnableNewStyle() {
        List<New_Style_Enablement__mdt> nseList = [
            SELECT Id, CommunityName__c
            FROM New_Style_Enablement__mdt
        ];
        List<String> communitiesList = new List<String>();
        for (New_Style_Enablement__mdt ns : nseList)
            communitiesList.add(ns.CommunityName__c);
        return communitiesList.contains(getProvider().getCommunityName());
    }

    public Map<String, String> getTemplateMap() {
        return getProvider().getParameters();
    }

    public Boolean getisRTL() {
        return ((System.Label.RTL_Languages).contains(UserInfo.getLanguage()) ||
        (System.Label.RTL_Languages).contains(getUserLanguageCode()));
    }
    //Labels: ----------------------------------------------------------------------------------------------------------
    public String getHeaderText() {
        String headerLabelValue = getLabelValue(headerValue);
        if (headerLabelValue.contains(EmailTemplateProvider.PARAM_PREFIX)) {
            headerLabelValue = prepareLineBreaks(replaceParams(headerLabelValue));
        }
        return headerLabelValue;
    }

    public String getHeaderBackgroundUrl() {
        Document[] topBackground = [
            SELECT Id, LastModifiedDate
            FROM Document
            WHERE DeveloperName = 'PP_Community_Email_Top_Background'
        ];
        if (topBackground.isEmpty()) {
            return null;
        } else {
            return URL.getSalesforceBaseUrl().toExternalForm() +
                '/servlet/servlet.ImageServer?id=' +
                topBackground[0].Id +
                '&oid=' +
                UserInfo.getOrganizationId() +
                '&lastMod=' +
                topBackground[0].LastModifiedDate.getTime();
        }
    }

    public String getFooterLogoUrl() {
        Document[] footerLogo = [
            SELECT Id, LastModifiedDate
            FROM Document
            WHERE DeveloperName = 'PP_IQVIA_Logo'
        ];
        if (footerLogo.isEmpty()) {
            return null;
        } else {
            return URL.getSalesforceBaseUrl().toExternalForm() +
                '/servlet/servlet.ImageServer?id=' +
                footerLogo[0].Id +
                '&oid=' +
                UserInfo.getOrganizationId() +
                '&lastMod=' +
                footerLogo[0].LastModifiedDate.getTime();
        }
    }

    public String getTitleText() {
        String titleLabelValue;
        if (String.isNotEmpty(titleValue)) {
            if (titleValue.startsWith('##')) {
                titleLabelValue = getProvider().getParameters().get(titleValue.substring(2));
            } else {
                titleLabelValue = getLabelValue(titleValue);
            }
        } else {
            if (communityTemplateValue != CommunityTemplateService.TEMPLATE_JANSSEN) {
                if (getProvider().getUserMode() == CommunityService.USER_MODE_PARTICIPANT) {
                    titleLabelValue = getProvider()
                        .getParameters()
                        .get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL);
                } else if (
                    getProvider().getUserMode() == CommunityService.USER_MODE_PI ||
                    getProvider().getUserMode() == CommunityService.USER_MODE_HCP
                ) {
                    titleLabelValue = getProvider()
                        .getParameters()
                        .get(TemplatePropertiesCatalog.TEMPLATE_PROP_TEAM_RH);
                } else {
                    getProvider()
                        .getParameters()
                        .get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM);
                }
            } else {
                titleLabelValue = getProvider()
                    .getParameters()
                    .get(TemplatePropertiesCatalog.TEMPLATE_PROP_TEAM_RH);
            }
        }

        return titleLabelValue;
    }

    public String getGreetingText() {
        return prepareLineBreaks(replaceParams(getLabelValue(greetingValue)) + '\n');
    }

    public String getPreSignatureText() {
        return prepareLineBreaks(getLabelValue(preSignatureValue));
    }

    public String getpreBodyButtonNameText() {
        return prepareLineBreaks(getLabelValue(preBodyButtonNameValue));
    }

    public String getSignatureText() {
        String signatureLabelValue = replaceParams(getLabelValue(signatureValue));
        return prepareLineBreaks(signatureLabelValue);
    }

    public String getEmailCommunityURL() {
        return CommunityTemplateService.getCommunityURL(
            getProvider().getParameters().get(TemplatePropertiesCatalog.COMM_TEMPLATE_URL)
        );
    }

    public Boolean getIsInitialized() {
        return getProvider().isInitialized();
    }
    @TestVisible
    private EmailTemplateProvider getProvider() {
        if (templateProvider == null) {
            EmailTemplateProviderService.setProviderType(
                specificEmailProviderValue,
                emailRecipientId,
                emailRecipientName,
                emailRecipientLanguage,
                communityTemplateValue,
                sourceRecordId,
                outputMode,
                shareTemplate
            );
            templateProvider = EmailTemplateProviderService.getProvider();
        }
        return templateProvider;
    }

    //Service logic: ---------------------------------------------------------------------------------------------------
    private String getLabelValue(String label) {
        return TranslateHelper.getLabelValue(label, getProvider().getUserLanguage());
    }

    private String replaceParams(String labelValue) {
        return TranslateHelper.replaceParams(
            labelValue,
            EmailTemplateProvider.PARAM_PREFIX,
            getProvider().getParameters()
        );
    }

    private String prepareLineBreaks(String source) {
        if (source == null)
            return null;
        if (getProvider().isHTML())
            return source.replaceAll('\n', '<br/>');
        return source;
    }
}
