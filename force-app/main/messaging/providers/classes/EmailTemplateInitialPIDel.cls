/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPIDel extends EmailTemplateInitial {

    public EmailTemplateInitialPIDel(Map<String, String> templateLabels, Id recipientContactId, String outputMode) {
        super(templateLabels, recipientContactId, outputMode, null);
        headerLabel = LABEL_HEADER_INITIAL_DELEGATE;
        bodyLabel = LABEL_BODY_INITIAL_DELEGATE;
        updateTemplateLabels();

        List<Site_Staff__c> siteStaffs = [
                SELECT Study_Site__c
                FROM Site_Staff__c
                WHERE Site_Contact__c = :recipientContactId
                ORDER BY CreatedDate DESC
        ];
        if(!siteStaffs.isEmpty()) {
            whatId = siteStaffs.get(0).Study_Site__c;
            parametersProviderName = 'PP_Study_Site';
        }
    }
}