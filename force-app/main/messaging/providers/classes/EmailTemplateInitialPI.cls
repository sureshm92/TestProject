/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public without sharing class EmailTemplateInitialPI extends EmailTemplateInitialAbstract{

    public EmailTemplateInitialPI(Map<String, String> templateLabels, Id recipientId, String outputMode) {
        super(templateLabels, recipientId, outputMode, null);
        bodyLabel = LABEL_BODY_INITIAL_PI;
        headerLabel = LABEL_HEADER_INITIAL_PI;
        greetingLabel = LABEL_GREETING_VALUE_PI_HCP;
    }

}