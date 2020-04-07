/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPT extends EmailTemplateInitial {

    public EmailTemplateInitialPT(Map<String, String> templateLabels, Id recipientContactId, String outputMode,
            String communityTemplateName) {
        super(templateLabels, recipientContactId, outputMode, communityTemplateName);
        bodyLabel = 'Email_Body_Initial_Patient_Virtual';
        headerLabel = 'Email_Header_Initial_Patient';
        signatureLabel = 'Email_Signature_Patient';

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
                bodyLabel = 'Email_Body_Initial_Patient_Created_By_PI';
            } else if (enrollments.get(0).Referral_Source__c == 'HCP') {
                bodyLabel = 'Email_Body_Initial_Patient';
            }
        }
        updateTemplateLabels();
    }
}