/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialHCPDel extends EmailTemplateInitial {

    public EmailTemplateInitialHCPDel(Id recipientId, String outputMode) {
        super(recipientId, outputMode, null);
        headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
        bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
        updateTemplateLabels();
    }
}