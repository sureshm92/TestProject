/**
 * Created by AlexKetch on 5/17/2019.
 */

public with sharing class HCPTrialBuilder extends TrialBuilder {

    private HCP_Enrollment__c hcpEnrollment;

    public HCPTrialBuilder(String trialId){
        this(trialId,null);
    }
    public HCPTrialBuilder(String trialId, String delegateId) {
        setTrial(trialId);
        this.hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId,delegateId);
        this.studyAction = this.getStudyActions();
        this.trialDetail.tabs = this.getStudyTabs();
    }

    public override TrialDetail createTrial() {

        HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
        //if (hcpEnrollment == null) throw new CommunityServiceException('Data not found');
        if (hcpEnrollment != null) {
            this.trialDetail.hcpe = hcpEnrollment;
            this.trialDetail.studyBottomBarActions = this.studyAction.studyDetailBottomBarActions;
            this.trialDetail.actions = this.studyAction.actions;
            this.trialDetail.tabs = this.getStudyTabs();
            
        } else {
            this.trialDetail.tabs = new List<TrialDetail.StudyTab>();
        }
        trialDetail.resources = ResourceStudyDocumentService.getInstance().init(
                ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                null,
                null,
                trialDetail.trial.Id)
                .getResourceWrapperContainer().wrappers;
    
    
        //init study site accounts:
        Set<Id> accIds = new Set<Id>();
        List<Study_Site__c> hcpStudySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
        for (Study_Site__c ss : hcpStudySites) accIds.add(ss.Site__c);
        Map<Id, Account> accountsMap = new Map<Id, Account>(this.getAccounts(accIds));
        //init list of study sites accounts:
        List<String> hidedStatuses = new List<String>{
                HCPEnrollmentService.HCP_S_INVITATION_SENT,
                HCPEnrollmentService.HCP_S_DECLINED_ACCEPTANCE
        };
        for (Study_Site__c ss : hcpStudySites) {
            String hcpStatus;
            if (hcpEnrollment != null && hcpEnrollment.Study_Site__c == ss.Id && !hidedStatuses.contains(hcpEnrollment.Status__c)) hcpStatus = hcpEnrollment.Status__c;
            this.trialDetail.accountEnrollmentsList.add(createClinicWrapper(ss.Name, accountsMap.get(ss.Site__c), hcpStatus, ss.Id));
        }
        this.trialDetail.accountEnrollmentsList.sort();
        return this.trialDetail;
    }

    public override StudyActions getStudyActions() {
        if(hcpEnrollment == null){
            return new StudyActionsHCP();
        }
        return new StudyActionsHCP(hcpEnrollment);
    }

    public override List<TrialDetail.StudyTab> getStudyTabs() {

        List<TrialDetail.StudyTab> tabs = new List<TrialDetail.StudyTab>();
        List<StudyActions.Action> defaultActions = this.studyAction.studyDetailActions;
        tabs.add(new TrialDetail.StudyTab(
                'tab-about-the-study',
                'about-the-study',
                Label.PG_SW_Tab_About_The_Study,
                defaultActions
        ));
        tabs.add(new TrialDetail.StudyTab(
                'tab-referred-patients',
                'referred-patient',
                Label.PG_SW_Tab_Referred_Patients,
                defaultActions
        ));
        tabs.add(new TrialDetail.StudyTab(
                'tab-referred-study-sites',
                'referred-clinic',
                Label.PG_SW_Tab_Study_Sites,
                defaultActions
        ));
        tabs.add(new TrialDetail.StudyTab(
                'tab-reports',
                'reports',
                Label.PG_SW_Tab_Reports,
                defaultActions
        ));
        return tabs;
    }
}