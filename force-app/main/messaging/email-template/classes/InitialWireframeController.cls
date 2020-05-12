/**
 * Created by Igor Malyuta on 29.04.2020.
 */
global without sharing class InitialWireframeController {

    global Id recordId { get; set; }
    global String commTemplate { get; set; }
    global String outputMode { get; set; }

    private EmailTemplateInitial templateInitial;

    public String getUserMode() {
        return getTemplateInitial().userMode;
    }

    public Id getSourceId() {
        return getTemplateInitial().whatId;
    }

    public String getSpecificProvider() {
        return (getTemplateInitial().useAllPINames ? 'EmailTemplateProviderHCPMultiPI' : '');
    }

    private EmailTemplateInitial getTemplateInitial() {
        if (templateInitial == null) {
            templateInitial = EmailTemplateInitialFactory.getTemplateInitial(recordId, outputMode, commTemplate);
        }
        return templateInitial;
    }
}