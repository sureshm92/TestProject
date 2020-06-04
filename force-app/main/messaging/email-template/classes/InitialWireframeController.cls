/**
 * Created by Igor Malyuta on 29.04.2020.
 */
global without sharing class InitialWireframeController {

    global Id recordId { get; set; }
    global String commTemplate { get; set; }
    global String outputMode { get; set; }
    global String buttonLabelValue { get; set; }

    private EmailTemplateInitial templateInitial;

    public String getUserMode() {
        return getTemplateInitial().userMode;
    }

    public Id getSourceId() {
        return getTemplateInitial().whatId;
    }

    public String getTitleLabel() {
        return commTemplate == 'Default' ? Label.Email_Title_Initial_All_IQVIA : Label.Email_Title_Initial_All_GSK;
    }

    public String getSpecificProvider() {
        return (getTemplateInitial().useAllPINames ? 'EmailTemplateProviderHCPMultiPI' : '');
    }

    public String getBTNLabel() {
        return ContactService.checkVisitedCommunity(getTemplateInitial().recipientId) ? Label.Email_Action_Login_now : buttonLabelValue;
    }

    private EmailTemplateInitial getTemplateInitial() {
        if (templateInitial == null) {
            templateInitial = EmailTemplateInitialFactory.getTemplateInitial(recordId, outputMode, commTemplate);
        }
        return templateInitial;
    }
}