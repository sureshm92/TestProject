/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialHCPDel extends EmailTemplateInitial {

    public EmailTemplateInitialHCPDel(Id recipientId, String outputMode) {
        super(recipientId, outputMode, null);
        userMode = 'HCP Delegate';
    }
}