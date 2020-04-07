/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialHCP extends EmailTemplateInitial {

    private List<Healthcare_Provider__c> healthcareProviders;
    private List<HCP_Enrollment__c> enrollments;

    public EmailTemplateInitialHCP(Map<String, String> templateLabels, Id recipientId, String outputMode) {
        super(templateLabels, recipientId, outputMode, null);
        headerLabel = 'Email_Header_Initial_HCP';
        greetingLabel = LABEL_GREETING_VALUE_PI_HCP;
        bodyLabel = 'Email_Body_Initial_HCP';

        if (!getHealthCareProviders().isEmpty()) {
            bodyLabel = 'Email_Body_Initial_PI_PT_HCP';

            whatId = getHealthCareProviders().get(0).Id;
            parametersProviderName = 'PP_Healthcare_Provider';
        } else if (hasEnrollments()) {
            bodyLabel = 'Email_Body_Initial_PI_HCP';

            whatId = getEnrollments().get(0).Id;
            parametersProviderName = 'Email_Template_Parameters_From_HCPE';
        }
        updateTemplateLabels();

        if (isSameInvestigator()) additionalParams.put('PIName', getMultiplePINames(recipientId));
    }

    private List<Healthcare_Provider__c> getHealthCareProviders() {
        if (healthcareProviders == null) {
            healthcareProviders = [
                    SELECT Id, HCP_Enrollment__c
                    FROM Healthcare_Provider__c
                    WHERE HCP_Enrollment__c IN (
                            SELECT Id
                            FROM HCP_Enrollment__c
                            WHERE HCP_Contact__c = :recipientId
                    )
            ];
        }
        return healthcareProviders;
    }

    private List<HCP_Enrollment__c> getEnrollments() {
        if (enrollments == null) {
            enrollments = [
                    SELECT Id, Study_Site__r.Principal_Investigator__c
                    FROM HCP_Enrollment__c
                    WHERE HCP_Contact__c = :recipientId
                    AND (Status__c = :HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
                    OR Status__c = :HCPEnrollmentService.HCP_S_ACTIVATED )
                    ORDER BY CreatedDate DESC
            ];
        }
        return enrollments;
    }

    private Boolean hasEnrollments() {
        return !getEnrollments().isEmpty();
    }

    private Boolean isSameInvestigator() {
        List<HCP_Enrollment__c> hcpEnrollments = getEnrollments();
        if (!hasEnrollments()) return false;

        Map<Id, List<HCP_Enrollment__c>> hcpEnrollmentsByPI = new Map<Id, List<HCP_Enrollment__c>>();
        for (HCP_Enrollment__c hcpe : hcpEnrollments) {
            if (!hcpEnrollmentsByPI.containsKey(hcpe.Study_Site__r.Principal_Investigator__c)) {
                hcpEnrollmentsByPI.put(hcpe.Study_Site__r.Principal_Investigator__c, new List<HCP_Enrollment__c>());
            }
            hcpEnrollmentsByPI.get(hcpe.Study_Site__r.Principal_Investigator__c).add(hcpe);
        }
        if (hcpEnrollmentsByPI.keySet().size() > 1) return true;

        return false;
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