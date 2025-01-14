/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPT extends EmailTemplateInitial {
    public EmailTemplateInitialPT(
        Id recipientContactId,
        String outputMode,
        String communityTemplateName
    ) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'Participant Virtual';

        List<String> templates = new List<String>{ communityTemplateName };
        if (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT)
            templates.add(null);
        List<Participant_Enrollment__c> enrollments = [
            SELECT Id, Referral_Source__c, Study_Site__r.Study_Site_Type__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Contact__c = :recipientContactId
                AND Clinical_Trial_Profile__r.CommunityTemplate__c IN :templates
            ORDER BY CreatedDate DESC
        ];
        if (!enrollments.isEmpty()) {
            whatId = enrollments.get(0).Id;
            studySiteType = enrollments.get(0).Study_Site__r.Study_Site_Type__c;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
            if (enrollments.get(0).Referral_Source__c == 'PI') {
                userMode = 'Participant referred by PI';
            } else if (enrollments.get(0).Referral_Source__c == 'HCP') {
                userMode = 'Participant referred by HCP';
            }
        }
    }
}
