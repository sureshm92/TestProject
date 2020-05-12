/**
 * Created by Igor Malyuta on 06.05.2020.
 */
public without sharing class EmailTemplateProviderForgot extends EmailTemplateProvider{

    public override void initState(Id recipientId, String recipientName, String recipientLanguage,
            String communityTemplateName, Id whatId, String outputMode
    ) {
        super.initState(recipientId, recipientName, recipientLanguage, communityTemplateName, whatId, outputMode);

        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(Network.getNetworkId(), '');
        String clinicalResearchCommunityForgotPasswordURL = isHTML ? '' : 'IQVIA Clinical Research Community Forgot password at';
        clinicalResearchCommunityForgotPasswordURL += authConfig.getForgotPasswordUrl();
        parameters.put('ForgotPasswordURL', clinicalResearchCommunityForgotPasswordURL);
    }
}