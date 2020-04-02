/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialHCP extends EmailTemplateInitialAbstract{

    private List<HCP_Enrollment__c> enrollments;

    public EmailTemplateInitialHCP(Map<String, String> templateLabels, Id recipientId, String outputMode) {
        super(templateLabels, recipientId, outputMode, null);
        headerLabel = LABEL_HEADER_INITIAL_HCP;
        greetingLabel = LABEL_GREETING_VALUE_PI_HCP;
        bodyLabel = LABEL_BODY_INITIAL_HCP;

        if (!getHealthCareProviders().isEmpty()) {
            bodyLabel = LABEL_BODY_INITIAL_PI_PT_HCP;
            headerLabel = LABEL_HEADER_INITIAL_PI_PT_HCP;
        } else if (hasEnrollments()) {
            bodyLabel = LABEL_BODY_INITIAL_PI_HCP;
            headerLabel = LABEL_HEADER_INITIAL_PI_HCP;
        }

//        if (isSameInvestigator()) parameters.put('PIName', getMultiplePINames(recipientId));
    }

    private List<Healthcare_Provider__c> getHealthCareProviders() {
            return [
                    SELECT Id, HCP_Enrollment__c
                    FROM Healthcare_Provider__c
                    WHERE HCP_Enrollment__c IN (
                            SELECT Id
                            FROM HCP_Enrollment__c
                            WHERE HCP_Contact__c = :recipientId
                    )
            ];
    }

    private List<HCP_Enrollment__c> getEnrollments() {
        if(enrollments == null) {
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
                SELECT
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Salutation
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__c = :hcpContId
        ];

        String piNames = '';
        for (HCP_Enrollment__c hcpE : hcpEnrollments) {
//            piNames += getFullContactName(hcpE.Study_Site__r.Principal_Investigator__r) + ', ';
        }
        return piNames.removeEnd(', ');
    }
}