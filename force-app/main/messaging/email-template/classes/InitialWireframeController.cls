/**
 * Created by Igor Malyuta on 29.04.2020.
 */
global without sharing class InitialWireframeController {

    global Id recordId { get; set; }
    global String commTemplate { get; set; }
    global String outputMode { get; set; }

    private String userMode;
    private Boolean isDelegate;
    private EmailTemplateInitial templateInitial;

    public Map<String, String> getTemplateLabels() {
        return getTemplateInitial().templateLabels;
    }

    public String getUserMode() {
        if(String.isEmpty(userMode)) initMode();
        return userMode;
    }

    public Boolean getIsDelegate() {
        if(isDelegate == null) initMode();
        return isDelegate;
    }

    private void initMode() {
        User user = [
                SELECT
                        Contact.UserCommunityIsDelegate__c,
                        Contact.userCommunityMode__c
                FROM User
                WHERE Id = :recordId
        ];
        userMode = user.Contact.userCommunityMode__c;
        isDelegate = user.Contact.UserCommunityIsDelegate__c;
    }

    private EmailTemplateInitial getTemplateInitial() {
        if (templateInitial == null) {
            templateInitial = EmailTemplateInitialFactory.getTemplateInitial(
                    recordId, recordId, null, null, outputMode, commTemplate
            );
            EmailTemplateProvider.setTemplateInitial(templateInitial);
        }
        return templateInitial;
    }
}