/**
 * Created by Igor Malyuta on 06.05.2020.
 */
public without sharing class EmailTemplateProviderHCPMultiPI extends EmailTemplateProvider {

    public override void initState(Id recipientId, String recipientName, String recipientLanguage,
            String communityTemplateName, Id whatId, String outputMode
    ) {
        super.initState(recipientId, recipientName, recipientLanguage, communityTemplateName, whatId, outputMode);
        parameters.put('PIName', getMultiplePINames(recipientContactId));
    }

    private String getMultiplePINames(Id hcpContId) {
        List<HCP_Enrollment__c> hcpEnrollments = [
                SELECT Study_Site__r.Principal_Investigator__r.Salutation_With_Name__c
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__c = :hcpContId
        ];

        String piNames = '';
        for (HCP_Enrollment__c hcpE : hcpEnrollments) {
            piNames += hcpE.Study_Site__r.Principal_Investigator__r.Salutation_With_Name__c + ', ';
        }
        return piNames.removeEnd(', ');
    }
}