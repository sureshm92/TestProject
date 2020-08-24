/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPIDel extends EmailTemplateInitial {

    public EmailTemplateInitialPIDel(Id recipientContactId, String outputMode, String communityTemplateName) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'PI Delegate';

        List<Site_Staff__c> siteStaffs = [
                SELECT Study_Site__c
                FROM Site_Staff__c
                WHERE Site_Contact__c = :recipientContactId
                AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c =: communityTemplateName
                ORDER BY CreatedDate DESC
        ];
        if(!siteStaffs.isEmpty()) {
            whatId = siteStaffs.get(0).Study_Site__c;
            parametersProviderName = 'PP_Study_Site';
        }
    }
}