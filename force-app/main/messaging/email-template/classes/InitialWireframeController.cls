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

    public Boolean getPhyscian() {
        User objUser = [SELECT ID, ContactId FROM User WHERE Id = :recordId];
        Contact objCon = [
            SELECT ID, Suppress_Physician_Outreach_Email__c
            FROM Contact
            WHERE Id = :objUser.ContactId
        ];
        return objCon.Suppress_Physician_Outreach_Email__c;
    }

    public String getCommunityUrl() {
        Network myNetwork = [SELECT Id FROM Network WHERE Name = 'IQVIA Referral Hub'];
        return Network.getLoginUrl(myNetwork.id);
    }

    public String getStudySiteType() {
        return getTemplateInitial().studySiteType;
    }

    public String getTitleLabel() {
        return commTemplate == CommunityTemplateService.TEMPLATE_DEFAULT
            ? Label.Email_Title_Initial_All_IQVIA
            : commTemplate == CommunityTemplateService.TEMPLATE_JANSSEN
                  ? Label.Email_Title_Initial_All_Janssen
                  : commTemplate == CommunityTemplateService.TEMPLATE_PP
                        ? Label.Email_Title_PH
                        : Label.Email_Title_Initial_All_GSK;
    }

    public String getSpecificProvider() {
        return (getTemplateInitial().useAllPINames ? 'EmailTemplateProviderHCPMultiPI' : '');
    }

    public String getBTNLabel() {
        return ContactService.checkVisitedCommunity(getTemplateInitial().recipientId)
            ? Label.Email_Action_Login_now
            : buttonLabelValue;
    }

    public Boolean getCheckVisitedCommunity() {
        return ContactService.checkVisitedCommunity(getTemplateInitial().recipientId);
    }

    private EmailTemplateInitial getTemplateInitial() {
        if (templateInitial == null) {
            templateInitial = EmailTemplateInitialFactory.getTemplateInitial(
                recordId,
                outputMode,
                commTemplate
            );
        }
        return templateInitial;
    }
}
