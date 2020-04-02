/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPT extends EmailTemplateInitialAbstract{

    public EmailTemplateInitialPT(Map<String, String> templateLabels, Id recipientContactId, String outputMode,
            String communityTemplateName) {
        super(templateLabels, recipientContactId, outputMode, communityTemplateName);
        bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_EPR;
        headerLabel = LABEL_HEADER_INITIAL_PARTICIPANT;
        signatureLabel = LABEL_SIGNATURE_PATIENT;

        List<String> templates = new List<String>{communityTemplateName};
        if(communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT) templates.add(null);
        List<Participant_Enrollment__c> enrollments = [
                SELECT Id, Referral_Source__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c = :recipientContactId
                AND Clinical_Trial_Profile__r.CommunityTemplate__c IN:templates
                ORDER BY CreatedDate DESC
        ];
        if(!enrollments.isEmpty()) {
            whatId = enrollments.get(0).Id;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
            if (enrollments.get(0).Referral_Source__c == 'PI') {
                bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT_BY_PI;
            } else if (enrollments.get(0).Referral_Source__c == 'HCP') {
                bodyLabel = LABEL_BODY_INITIAL_PARTICIPANT;
            }
        }
    }
}