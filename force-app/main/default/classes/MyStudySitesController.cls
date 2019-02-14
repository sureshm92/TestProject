/**
 * Created by D.Yasinskyi on 22.03.2018
 */
public without sharing class MyStudySitesController {

    @AuraEnabled
    public static String getStudySiteDetail(String trialId) {
        MyStudySitesController.StudySiteDetail studySiteDetail = new MyStudySitesController.StudySiteDetail();
        List<HCP_Enrollment__c> enrollments = new List<HCP_Enrollment__c>();
        try {
            enrollments = HCPEnrollmentService.getEnrollmentsForHCPOnStudySite(trialId);
            studySiteDetail = setStudySiteDetail(enrollments);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return JSON.serialize(studySiteDetail);
    }

    private static List<Study_Site__c> getStudySites(Set<Id> ids) {
        return [
                SELECT Id,
                        Name,
                        Override_PI_Referral_Status__c,
                        Site__c, Site__r.Name,
                        Site__r.BillingStreet,
                        Site__r.BillingState,
                        Site__r.BillingPostalCode,
                        Site__r.BillingCity,
                        Site__r.Phone
                FROM Study_Site__c
                WHERE Id IN :ids
        ];
    }

    private static MyStudySitesController.StudySiteDetail setStudySiteDetail(List<HCP_Enrollment__c> enrollments) {
        MyStudySitesController.StudySiteDetail studySiteDetail = new MyStudySitesController.StudySiteDetail();
        Map<Id, List<HCPEWrapper>> studySiteEnrolmentMap = new Map<Id, List<HCPEWrapper>>();
        //HCP_Enrollments groups
        Integer pending = 0, activated = 0, onHold = 0, deactivated = 0, declined = 0;

        for (HCP_Enrollment__c enroll : enrollments) {

            if (!studySiteEnrolmentMap.containsKey(enroll.Study_Site__c)) {
                studySiteEnrolmentMap.put(enroll.Study_Site__c, new List<HCPEWrapper>());
            }
            HCPEWrapper enrollWrapper = new HCPEWrapper();
            enrollWrapper.enrollment = enroll;
            enrollWrapper.statusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c, enroll.Status__c);
            studySiteEnrolmentMap.get(enroll.Study_Site__c).add(enrollWrapper);

            String status = enroll.Status__c;

            if (status == HCPEnrollmentService.HCP_S_ACTIVATED || status == HCPEnrollmentService.HCP_S_ACTIVATED_A){
                activated++;
            } else if(status == HCPEnrollmentService.HCP_S_DEACTIVATED_A) {
                deactivated++;
            } else if(status.contains('On Hold')) {
                onHold++;
            } else if(status.contains('Declined') || status == HCPEnrollmentService.HCP_S_NON_RESPONCIVE_A) {
                declined++;
            } else if (status.contains('Pending')) {
                pending++;
            }
        }

        //set filter info and summaries
        studySiteDetail.filterInfo = new FilterPillInfo(pending, Label.PG_MSS_L_Pending_approval_pending_activation);
        studySiteDetail.summrayContainers.add(new SummaryContainer(Label.PG_MSS_L_Study_sites_overall, String.valueOf(studySiteEnrolmentMap.keySet().size())));
        SummaryContainer PIOverall = new SummaryContainer(Label.PG_MSS_L_Principal_investigators_overall, String.valueOf(enrollments.size()));
        PIOverall.items.add(new LabelValueItem(Label.PG_MSS_L_Activations, String.valueOf(activated)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MSS_L_On_hold, String.valueOf(onHold)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MSS_L_Deactivation, String.valueOf(deactivated)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MSS_L_Decline, String.valueOf(declined)));
        studySiteDetail.summrayContainers.add(PIOverall);

        //set sorted enrollments
        for (Study_Site__c studySite : getStudySites(studySiteEnrolmentMap.keySet())) {

            MyStudySitesController.StudySiteWrapper newWrapper = new MyStudySitesController.StudySiteWrapper();
            newWrapper.studySite = studySite;
            newWrapper.enrollments = studySiteEnrolmentMap.get(studySite.Id);
            studySiteDetail.studySitesDetail.add(newWrapper);
        }

        return studySiteDetail;
    }

    public class StudySiteDetail {
        List<MyStudySitesController.StudySiteWrapper> studySitesDetail;
        List<SummaryContainer> summrayContainers;
        FilterPillInfo filterInfo;

        public StudySiteDetail() {
            studySitesDetail = new List<MyStudySitesController.StudySiteWrapper>();
            summrayContainers = new List<SummaryContainer>();
        }
    }

    public class StudySiteWrapper {
        Study_Site__c studySite;
        List<HCPEWrapper> enrollments;
    }
    public class HCPEWrapper {
        String statusLabel;
        HCP_Enrollment__c enrollment;
    }
}