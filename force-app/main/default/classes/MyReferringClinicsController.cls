/**
 * Created by D.Yasinskyi on 30.03.2018
 */
public without sharing class MyReferringClinicsController {

    @AuraEnabled
    public static String getClinicDetail(String trialId, String userMode) {

        MyReferringClinicsController.ClinicDetail clinicDetail = new MyReferringClinicsController.ClinicDetail();
        try {
            Set<Id> trialIds = new Set<Id>();
            List<Study_Site__c> studySites;
            List<Study_Site__c> studySitesNotDelegate;
            if (String.isEmpty(trialId)) {
                studySites = StudySiteService.getStudySitesForPI();
                studySitesNotDelegate = StudySiteService.getStudySitesCommon(CommunityService.USER_MODE_PI,null,true);
            } else {
                studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
            }
            for (Study_Site__c studySite : studySites) {
                trialIds.add(studySite.Clinical_Trial_Profile__c);
            }
            clinicDetail = getClinicDetail(HCPEnrollmentService.getEnrollmentsForPIByTrialIds(
                    trialIds, new List<String>{HCPEnrollmentService.HCP_S_INVITATION_SENT}
            ), userMode);
            clinicDetail.studySitesForInvitation = new List<MyReferringClinicsController.SiteWrapper>();
            if(studySitesNotDelegate != null && !studySitesNotDelegate.isEmpty()){
                Set<Id> studyIds = new Set<Id>();
                for(Study_Site__c site: studySitesNotDelegate){
                    if(!studyIds.contains(site.Clinical_Trial_Profile__c) && StudySiteService.STATUS_GROUP_ACCEPTED.contains(site.Override_PI_Referral_Status__c)){
                        SiteWrapper sw = new SiteWrapper(site.Clinical_Trial_Profile__r.Study_Code_Name__c,site.Id);
                        clinicDetail.studySitesForInvitation.add(sw);
                        studyIds.add(site.Clinical_Trial_Profile__c);
                    }
                }
            }


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return JSON.serialize(clinicDetail);
    }

    @AuraEnabled
    public static String getEnrollmentData(Id hcpEnrollmentId, String userMode) {
        try{
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentById(hcpEnrollmentId, userMode);
            return JSON.serialize(createEnrollmentWrapper(hcpEnrollment));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void inviteHCP(String firstName, String lastName, String clinicName, String phone, String studySiteId){
        try{
            List<Group> invitationQueues = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :CommunityService.INVITATION_QUEUE];
            AssignmentRule ar = new AssignmentRule();
            ar = [
                SELECT 	id 
            	FROM 	AssignmentRule 
                WHERE 	SobjectType = 'Lead' AND 
                		Active = true AND 
                		Name = 'SPNL Assignment Rule' 
                LIMIT 1
            ];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
            
            Lead l = new Lead();
            l.FirstName = firstName;
            l.LastName = lastName;
            l.Phone = phone;
            l.Company = clinicName;
            l.Language__c = UserInfo.getLanguage();
            if(studySiteId!= null && studySiteId != '')
                l.Study_Site__c = studySiteId;
            l.Status = 'New';
            l.Invited_by_PI__c = CommunityService.getUserContact().Id;
            if(invitationQueues.size() > 0){
                l.OwnerId = invitationQueues[0].Id;
            }
            l.setOptions(dmlOpts);
            insert l;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }


    private static MyReferringClinicsController.ClinicDetail getClinicDetail(List<HCP_Enrollment__c> enrollments, String userMode) {
        MyReferringClinicsController.ClinicDetail clinicDetail = new MyReferringClinicsController.ClinicDetail();
        Map<Id, List<HCP_Enrollment__c>> clinicEnrolmentMap = new Map<Id, List<HCP_Enrollment__c>>();
        //HCP_Enrollments groups
        Integer pending = 0, activated = 0, onHold = 0, deactivated = 0, declined = 0;
        for (HCP_Enrollment__c enroll :enrollments) {
            if (!clinicEnrolmentMap.containsKey(enroll.HCP_Contact__r.AccountId)) {
                clinicEnrolmentMap.put(enroll.HCP_Contact__r.AccountId, new List<HCP_Enrollment__c>());
            }
            clinicEnrolmentMap.get(enroll.HCP_Contact__r.AccountId).add(enroll);
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

        for (Account acc : getAccounts(clinicEnrolmentMap.keySet())) {
            clinicDetail.referringClinics.add(new ClinicWrapper(acc, clinicEnrolmentMap.get(acc.Id)));
        }

        //set filter info and summaries
        clinicDetail.filterInfo = new FilterPillInfo(pending, Label.PG_MRC_L_Providers_pending_approval_pending_activation);
        clinicDetail.summrayContainers.add(new SummaryContainer(Label.PG_MRC_L_Referring_clinics_overall, String.valueOf(clinicEnrolmentMap.keySet().size())));
        SummaryContainer PIOverall = new SummaryContainer(Label.PG_MRC_L_Referring_providers_overall, String.valueOf(enrollments.size()));
        PIOverall.items.add(new LabelValueItem(Label.PG_MRC_L_Providers_activated, String.valueOf(activated)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MRC_L_Providers_on_hold, String.valueOf(onHold)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MRC_L_Providers_deactivated, String.valueOf(deactivated)));
        PIOverall.items.add(new LabelValueItem(Label.PG_MRC_L_Providers_declined, String.valueOf(declined)));
        clinicDetail.summrayContainers.add(PIOverall);

        return clinicDetail;
    }

    private static List<Account> getAccounts(Set<Id> accountIds) {
        return [
                SELECT Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, Phone
                FROM Account
                WHERE Id IN :accountIds
        ];
    }

    private static MyReferringClinicsController.HCPEnrollmentWrapper createEnrollmentWrapper(HCP_Enrollment__c hcpEnrollment){
        Map<String, StudyActions.Action> actionsMap = new StudyActionsPI(hcpEnrollment).actions;
        MyReferringClinicsController.HCPEnrollmentWrapper wrapper = new MyReferringClinicsController.HCPEnrollmentWrapper();
        wrapper.status = CommunityService.getConvertedStatus(hcpEnrollment.Status__c);
        wrapper.statusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c,hcpEnrollment.Status__c);
        wrapper.enrollment = hcpEnrollment;

        Map<String, String> actionToStatusesMap = HCPEnrollmentService.HCP_CHANGE_STATUS_MAP.get(hcpEnrollment.Status__c);
        if(actionToStatusesMap != null){
            for(String actionId : actionToStatusesMap.keySet()) {
                wrapper.buttonList.add(actionsMap.get(actionId));
            }
        }
        return wrapper;
    }

    public class ClinicDetail {
        public List<MyReferringClinicsController.ClinicWrapper> referringClinics;
        public List<SummaryContainer> summrayContainers;
        public FilterPillInfo filterInfo;

        public  List<SiteWrapper> studySitesForInvitation;

        public ClinicDetail() {
            referringClinics = new List<MyReferringClinicsController.ClinicWrapper>();
            summrayContainers = new List<SummaryContainer>();
        }
    }

    public class ClinicWrapper {
        public Account clinic;
        public List<MyReferringClinicsController.HCPEnrollmentWrapper> enrollments = new List<MyReferringClinicsController.HCPEnrollmentWrapper>();

        public ClinicWrapper(Account clinic, List<HCP_Enrollment__c> enrollments) {
            this.clinic = clinic;
            if(enrollments != null){
                for(HCP_Enrollment__c enrollment : enrollments){
                    this.enrollments.add(createEnrollmentWrapper(enrollment));
                }
            }
        }
    }

    public class SiteWrapper{
        public String StudyName;
        public String Id;
        public Boolean selected;
        public SiteWrapper(String StudyName, String Id){
            this.StudyName = StudyName;
            this.Id = Id;
            this.selected = false;
        }
    }

    public class  HCPEnrollmentWrapper {
        HCP_Enrollment__c enrollment;
        String status;
        String statusLabel;
        List<StudyActions.Action> buttonList = new List<StudyActions.Action>();
    }

}