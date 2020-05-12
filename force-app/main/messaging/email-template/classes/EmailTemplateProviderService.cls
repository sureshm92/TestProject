/**
 * Created by Igor Malyuta on 06.05.2020.
 */
public without sharing class EmailTemplateProviderService {

    public class EmailTemplateProviderServiceException extends Exception {
    }

    private static final String DEFAULT_PROVIDER_TYPE = 'EmailTemplateProvider';
    private static EmailTemplateProvider provider;

    public static void setProviderType(
            String providerTypeName, Id recipientId, String recipientName, String recipientLanguage,
            String communityTemplateName, Id whatId, String outputMode
    ) {
        String clsName = String.isNotEmpty(providerTypeName) ? providerTypeName : DEFAULT_PROVIDER_TYPE;
        try {
            provider = (EmailTemplateProvider) Type.forName(clsName).newInstance();
            provider.initState(recipientId, recipientName, recipientLanguage, communityTemplateName, whatId, outputMode);
        } catch (Exception e) {
            throw new EmailTemplateProviderServiceException(e.getCause() + '\n' + e.getMessage());
        }
    }

    public static EmailTemplateProvider getProvider() {
        while(!provider.isInitialized()) {}
        return provider;
    }
}