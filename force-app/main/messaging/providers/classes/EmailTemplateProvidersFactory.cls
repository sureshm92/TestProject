/**
 * Created by Igor Malyuta on 23.03.2020.
 */

public without sharing class EmailTemplateProvidersFactory {

    private static final List<String> DEPRECATED_EMAILS = new List<String>{
            'Medication_Task_Reminder',
            'Trial_Alert_Match_Delegate',
            'Trial_Alert_Received_Delegate',
            'Visit_Task_Reminder',
            'Visit_task_Reminder_Type_not_selected'
    };

    private Map<String, String> providers;
    private Map<String, EmailTemplateWrapper> templateWrapperByEmail;

    private static EmailTemplateProvidersFactory instance;

    private EmailTemplateProvidersFactory() {
        providers = getParameterProviders();
        templateWrapperByEmail = getEmailTemplateWrappers();
    }

    public static EmailTemplateProvidersFactory getFactory() {
        if (instance == null) instance = new EmailTemplateProvidersFactory();
        return instance;
    }

    public EmailTemplateProviderAbstract getProvider(String currentEmailName, Id sourceId, Id recipientId, String recipientName,
            String recipientLanguage, String outputMode, String communityTemplateName
    ) {
        EmailTemplateProviderAbstract provider;
        if(String.isEmpty(currentEmailName)) return provider;

        EmailTemplateWrapper templateWrapper = templateWrapperByEmail.get(currentEmailName);
        if(templateWrapper == null) return provider;


        if (templateWrapper.relatedType == null) {
            provider = new EmailTemplateProviderInitial(sourceId, outputMode, communityTemplateName).getProvider();
        } else {
            String userMode;
            if (recipientId.getSobjectType() == User.getSObjectType()) {
                User user = [SELECT Id, Contact.userCommunityMode__c FROM User WHERE Id = :recipientId];
                userMode = user.Contact.userCommunityMode__c;
            } else {
                Contact contact = [SELECT Id, userCommunityMode__c FROM Contact WHERE Id = :recipientId];
                userMode = contact.userCommunityMode__c;
            }
            switch on userMode {
                when 'PI' {
                    provider = new EmailTemplateProviderPI(
                            sourceId, recipientId, recipientName, recipientLanguage, templateWrapper.paramProvider, outputMode
                    );
                }
                when 'HCP' {
                    provider = new EmailTemplateProviderHCP(
                            sourceId, recipientId, recipientName, recipientLanguage, templateWrapper.paramProvider, outputMode
                    );
                }
                when else {
                    provider = new EmailTemplateProviderPT(sourceId, recipientId, recipientName, recipientLanguage,
                            templateWrapper.paramProvider, outputMode, communityTemplateName
                    );
                }
            }
        }

        return provider;
    }

    private Map<String, String> getParameterProviders() {
        List<Parameters_Provider__mdt> parametersProviders = [
                SELECT DeveloperName, Source_Object_Type__c
                FROM Parameters_Provider__mdt
        ];
        Map<String, String> providerByObjType = new Map<String, String>();
        for (Parameters_Provider__mdt provider : parametersProviders) {
            providerByObjType.put(provider.Source_Object_Type__c, provider.DeveloperName);
        }
        return providerByObjType;
    }

    private Map<String, EmailTemplateWrapper> getEmailTemplateWrappers() {
        Map<String, EmailTemplateWrapper> templateWrapperByEmail = new Map<String, EmailTemplateWrapper>();
        List<EmailTemplate> emailTemplates = [
                SELECT
                        DeveloperName,
                        Markup
                FROM EmailTemplate
                WHERE TemplateType = 'visualforce'
                AND DeveloperName NOT IN:DEPRECATED_EMAILS
        ];
        for (EmailTemplate template : emailTemplates) {
            Integer recipientStart = template.Markup.indexOf('recipientType="') + 15;
            Integer recipientEnd = template.Markup.indexOf('"', recipientStart);
            String recipientType = template.Markup.substring(recipientStart, recipientEnd);

            String relatedToType;
            Integer relatedStart = template.Markup.indexOf('relatedToType="');
            if (relatedStart > 0) {
                relatedStart += 15;
                Integer relatedEnd = template.Markup.indexOf('"', relatedStart);
                relatedToType = template.Markup.substring(relatedStart, relatedEnd);
            }

            EmailTemplateWrapper emailTemplateWrapper = new EmailTemplateWrapper(
                    template.DeveloperName,
                    recipientType,
                    relatedToType,
                    providers.get(relatedToType)
            );
            templateWrapperByEmail.put(emailTemplateWrapper.emailName, emailTemplateWrapper);
        }

        return templateWrapperByEmail;
    }

    public class EmailTemplateWrapper {
        public String emailName;
        public String recipientType;
        public String relatedType;
        public String paramProvider;

        public EmailTemplateWrapper(String emailName, String recipientType, String relatedType, String paramProvider) {
            this.emailName = emailName;
            this.recipientType = recipientType;
            this.relatedType = relatedType;
            this.paramProvider = paramProvider;
        }
    }
}