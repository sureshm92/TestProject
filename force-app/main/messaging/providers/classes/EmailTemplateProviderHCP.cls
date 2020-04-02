/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public without sharing class EmailTemplateProviderHCP {
//
//    private List<DelegateLevelWrapper> hcpDelegateLevels = new List<DelegateLevelWrapper>();
//    private List<HCP_Enrollment__c> enrollments;
//    private List<Healthcare_Provider__c> healthCareProviders;
//
//    public EmailTemplateProviderHCP(Id sourceId, Id recipientId, String recipientName, String recipientLanguage,
//            String parametersProviderName, String outputMode
//    ) {
//
//        HCP_Enrollment__c hcpEnrollment = [
//                SELECT
//                        HCP_Contact__c,
//                        HCP_Contact__r.Name,
//                        HCP_Contact__r.Salutation
//                FROM HCP_Enrollment__c
//                WHERE Id = :sourceId
//        ];
////        parameters.put('HCPName', getFullContactName(hcpEnrollment.HCP_Contact__r));
//        if (isSameInvestigator()) parameters.put('PIName', getMultiplePINames(hcpEnrollment.HCP_Contact__c));
//    }
//
//    public Boolean hasEnrollments() {
//        return !getEnrollments().isEmpty();
//    }
//
//    public Boolean isSameInvestigator() {
//        List<HCP_Enrollment__c> hcpEnrollments = getEnrollments();
//        if (!hasEnrollments()) return false;
//
//        Map<Id, List<HCP_Enrollment__c>> hcpEnrollmentsByPI = new Map<Id, List<HCP_Enrollment__c>>();
//        for (HCP_Enrollment__c hcpe : hcpEnrollments) {
//            if (!hcpEnrollmentsByPI.containsKey(hcpe.Study_Site__r.Principal_Investigator__c)) {
//                hcpEnrollmentsByPI.put(hcpe.Study_Site__r.Principal_Investigator__c, new List<HCP_Enrollment__c>());
//            }
//            hcpEnrollmentsByPI.get(hcpe.Study_Site__r.Principal_Investigator__c).add(hcpe);
//        }
//        if (hcpEnrollmentsByPI.keySet().size() > 1) return true;
//
//        return false;
//    }
//
//    public Boolean hasHealCareProviders() {
//        return !getHealthCareProviders().isEmpty();
//    }
//
//    private List<Healthcare_Provider__c> getHealthCareProviders() {
//        if(healthCareProviders == null) {
//            healthCareProviders = [
//                    SELECT Id
//                    FROM Healthcare_Provider__c
//                    WHERE HCP_Enrollment__c IN (
//                            SELECT Id
//                            FROM HCP_Enrollment__c
//                            WHERE HCP_Contact__c = :recipientContactId
//                    )
//            ];
//        }
//        return healthCareProviders;
//    }
//
//    private List<HCP_Enrollment__c> getEnrollments() {
//        if(enrollments == null) {
//            enrollments = [
//                    SELECT Id, Study_Site__r.Principal_Investigator__c
//                    FROM HCP_Enrollment__c
//                    WHERE HCP_Contact__c = :recipientContactId AND
//                    (Status__c = :HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
//                    OR Status__c = :HCPEnrollmentService.HCP_S_ACTIVATED )
//            ];
//        }
//        return enrollments;
//    }
//
//    private String getMultiplePINames(Id hcpContId) {
//        List<HCP_Enrollment__c> hcpEnrollments = [
//                SELECT
//                        Study_Site__r.Principal_Investigator__r.Name,
//                        Study_Site__r.Principal_Investigator__r.Salutation
//                FROM HCP_Enrollment__c
//                WHERE HCP_Contact__c = :hcpContId
//        ];
//
//        String piNames = '';
//        for (HCP_Enrollment__c hcpE : hcpEnrollments) {
//            piNames += getFullContactName(hcpE.Study_Site__r.Principal_Investigator__r) + ', ';
//        }
//        return piNames.removeEnd(', ');
//    }
}