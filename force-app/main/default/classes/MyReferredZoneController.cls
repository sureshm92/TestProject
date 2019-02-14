/**
 * Created by D.Yasinskyi on 30.03.2018
 */
public without sharing class MyReferredZoneController {

    @AuraEnabled
    public static String getStatusOptions(String userMode){

        Map<String, List<LabelValueItem>> options = new Map<String, List<LabelValueItem>>();
        List<LabelValueItem> enrollmentStatusOptions = new List<LabelValueItem>();
        List<LabelValueItem> studySitesOptions = new List<LabelValueItem>();
        List<String> invisibleEnrollmentStatuses = new List<String>();

        if(userMode == CommunityService.USER_MODE_PI){
            invisibleEnrollmentStatuses = HCPEnrollmentService.HCP_E_S_INVISIBLE_ON_STUDY_SITE_P;
        } else if (userMode == CommunityService.USER_MODE_HCP) {
            invisibleEnrollmentStatuses = new List<String>{null};
        }

        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Status__c.getDescribe().getPicklistValues()) {
            if(invisibleEnrollmentStatuses.contains(ple.getValue())) continue;
            enrollmentStatusOptions.add(new LabelValueItem(ple.getLabel(),ple.getValue()));
        }
        for (Schema.PicklistEntry ple : Study_Site__c.Override_PI_Referral_Status__c.getDescribe().getPicklistValues()) {
            studySitesOptions.add(new LabelValueItem(ple.getLabel(),ple.getValue()));
        }
        options.put('HCP_Enrollment__c', enrollmentStatusOptions);
        options.put('Study_Site__c', studySitesOptions);

        return JSON.serialize(options);
    }
}