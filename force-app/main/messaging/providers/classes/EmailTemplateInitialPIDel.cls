/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPIDel extends EmailTemplateInitialAbstract{

    public EmailTemplateInitialPIDel(Map<String, String> templateLabels, Id recipientId, String outputMode) {
        super(templateLabels, recipientId, outputMode, null);
        headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
        bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
    }
}