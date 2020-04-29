/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public without sharing class EmailTemplateInitialPI extends EmailTemplateInitial {

    public EmailTemplateInitialPI(Id recipientContactId, String outputMode) {
        super(recipientContactId, outputMode, null);
        bodyLabel = 'Email_Body_Initial_PI';
        headerLabel = 'Email_Header_Initial_PI';
        greetingLabel = LABEL_GREETING_VALUE_PI_HCP;
        updateTemplateLabels();

        List<Study_Site__c> studySites = [
                SELECT Id
                FROM Study_Site__c
                WHERE Principal_Investigator__c =: recipientContactId
                ORDER BY CreatedDate DESC
        ];
        if(!studySites.isEmpty()) {
            whatId = studySites.get(0).Id;
            parametersProviderName = 'PP_Study_Site';
        }
    }
}