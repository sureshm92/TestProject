/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_ChangeHCPStatusByPIRemote {
    
    @AuraEnabled
    public static String getEnrollmentReasonOptions() {
        Map<String, List<LabelValueItem>> hcpChangeStatusReasons = new Map<String, List<LabelValueItem>>();
        List<LabelValueItem> hcpDeactivateReasons = new List<LabelValueItem>();
        List<LabelValueItem> hcpDeclineReasons = new List<LabelValueItem>();
        List<LabelValueItem> hcpOnHoldReasons = new List<LabelValueItem>();
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Deactivation_Reason__c.getDescribe().getPicklistValues()) {
            hcpDeactivateReasons.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Declining_Reason__c.getDescribe().getPicklistValues()) {
            hcpDeclineReasons.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.On_Hold_Reason__c.getDescribe().getPicklistValues()) {
            hcpOnHoldReasons.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        hcpChangeStatusReasons = new Map<String, List<LabelValueItem>>{
                'deactivateReasons' => hcpDeactivateReasons,
                'declineReasons' => hcpDeclineReasons,
                'onHoldReasons' => hcpOnHoldReasons
        };
        return JSON.serialize(hcpChangeStatusReasons);
    }
    
    @AuraEnabled
    public static String changeHCPEnrollmentStatus(String hcpeId, String actionId, String value) {
        Savepoint sp = Database.setSavepoint();
        try {
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentById(hcpeId, CommunityService.USER_MODE_PI);
            new StudyActionsPI(hcpEnrollment).checkAction(actionId);
            HCPEnrollmentService.changeStatus(hcpeId, CommunityService.USER_MODE_PI, actionId, value);
            String message = Label.TST_You_have_successfully + ' ';
            if (actionId == StudyActions.ACT_HCP_APPROVE){
                message += Label.TST_approved + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }else if(actionId == StudyActions.ACT_HCP_ACTIVATE){
                message += Label.TST_activated + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }else if(actionId == StudyActions.ACT_HCP_DECLINE){
                message += Label.TST_declined + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }else if(actionId == StudyActions.ACT_HCP_DEACTIVATE){
                message += Label.TST_deactivated + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }else if(actionId == StudyActions.ACT_HCP_ON_HOLD){
                message += Label.TST_put_On_Hold + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }else if(actionId == StudyActions.ACT_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE){
                message += Label.TST_attended_orientation_and_activated + ' '  + hcpEnrollment.HCP_Contact__r.Name + '.';
            }
            return  message;
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug(ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

}