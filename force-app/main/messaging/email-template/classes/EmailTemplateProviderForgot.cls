/**
 * Created by Igor Malyuta on 06.05.2020.
 */
public without sharing class EmailTemplateProviderForgot extends EmailTemplateProvider {

    public override void initState(Id recipientId, String recipientName, String recipientLanguage,
            String communityTemplateName, Id whatId, String outputMode
    ) {
        super.initState(recipientId, recipientName, recipientLanguage, communityTemplateName, whatId, outputMode);

        List<Participant__c> participant = [SELECT Full_Name__c FROM Participant__c WHERE Contact__c = :recipientId];
        if(!parameters.isEmpty()) parameters.put('RecipientName', participant.get(0).Full_Name__c);

        CommunityTemplate communityTemplate = CommunityTemplateService.getTemplate(communityTemplateName);
        Id networkId = [SELECT Id FROM Network WHERE Name = :communityTemplate.communityName].Id;

        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
        String clinicalResearchCommunityForgotPasswordURL = isHTML ? '' : 'IQVIA Clinical Research Community Forgot password at';
        clinicalResearchCommunityForgotPasswordURL += authConfig.getForgotPasswordUrl();
        parameters.put('ForgotPasswordURL', clinicalResearchCommunityForgotPasswordURL);
    }
}