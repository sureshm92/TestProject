/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public without sharing class EmailTemplateInitialPI extends EmailTemplateInitial {

    public EmailTemplateInitialPI(Id recipientContactId, String outputMode, String communityTemplateName) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'PI';

        List<Study_Site__c> studySites = [
                SELECT Id
                FROM Study_Site__c
                WHERE Principal_Investigator__c =: recipientContactId
                AND Clinical_Trial_Profile__r.CommunityTemplate__c =: communityTemplateName
                ORDER BY CreatedDate DESC
        ];
        if(!studySites.isEmpty()) {
            whatId = studySites.get(0).Id;
            parametersProviderName = 'PP_Study_Site';
        }
    }
}