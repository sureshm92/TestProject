/**
 * Created by Igor Malyuta on 06.04.2020.
 */
public without sharing class EmailTemplateInitialDefault extends EmailTemplateInitial {

    public EmailTemplateInitialDefault(Id whatId, Id recipientId, String recipientName,
            String recipientLanguage, String outputMode, String communityTemplateName
    ) {
        super(recipientId, outputMode, communityTemplateName);
        this.whatId = whatId;
        this.recipientName = recipientName;
        this.recipientLanguage = recipientLanguage;
        this.parametersProviderName = PARAM_PROVIDER_BY_TYPE.get(String.valueOf(whatId.getSobjectType()));
    }
}