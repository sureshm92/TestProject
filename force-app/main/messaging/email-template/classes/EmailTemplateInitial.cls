/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public abstract without sharing class EmailTemplateInitial {

    public Id whatId;
    public Id recipientId;
    public String userMode;
    public String recipientName;
    public String recipientLanguage;
    public Boolean useAllPINames = false;
    public String outputMode;
    public String communityTemplateName;
    public String parametersProviderName;

    public EmailTemplateInitial(Id recipientId, String outputMode, String communityTemplateName) {
        this.recipientId = recipientId;
        this.outputMode = outputMode;
        this.communityTemplateName = communityTemplateName;
    }
}