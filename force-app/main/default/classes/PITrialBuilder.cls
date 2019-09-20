public class PITrialBuilder extends TrialBuilder {
    
    private List<Study_Site__c> studySites;
    
    public PITrialBuilder(String trialId) {
        setTrial(trialId);
        this.studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
        if (studySites.size() == 0) throw new CommunityServiceException('Data not found');
        this.trialDetail.studySite = studySites[0];
        this.studyAction = this.getStudyActions();
        this.trialDetail.tabs = this.getStudyTabs();
    }
    
    public override TrialDetail createTrial() {
        this.trialDetail.isSSAccepted = StudySiteService.STATUS_GROUP_ACCEPTED.contains(studySites[0].Override_PI_Referral_Status__c);
        this.trialDetail.studyBottomBarActions = this.studyAction.studyDetailBottomBarActions;
        this.trialDetail.actions = this.studyAction.actions;
        trialDetail.resources = ResourceStudyDocumentService.getInstance().init(
                ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                null,
                null,
                trialDetail.trial.Id)
                .getResourceWrapperContainer().wrappers;
        //prepare account list
        List<HCP_Enrollment__c> enrollments = HCPEnrollmentService.getEnrollmentsForPIByStudySiteId(studySites[0].Id);
        Set<Id> accountIds = new Set<Id>();
        for (HCP_Enrollment__c hcpe : enrollments) accountIds.add(hcpe.HCP_Contact__r.AccountId);
        List<Account> accounts = this.getAccounts(accountIds);
        for (Account account : accounts) {
            this.trialDetail.accountEnrollmentsList.add(createClinicWrapper(account.Name, account, null, null));
        }
        return this.trialDetail;
    }
    
    public override StudyActions getStudyActions() {
        return new StudyActionsPI(studySites[0]);
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
                'tab-referrals',
                'referrals',
                Label.PG_SW_Tab_Referrals,
                defaultActions
        ));
        tabs.add(new TrialDetail.StudyTab(
                'tab-referred-clinics',
                'referred-clinic',
                Label.PG_SW_Tab_Referring_Clinics,
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