/**
 * Created by AlexKetch on 5/21/2019.
 */

public with sharing class ParticipantTrialBuilder extends TrialBuilder {

    private Participant_Enrollment__c pe;

    public ParticipantTrialBuilder(String trialId) {
        super(trialId);
        List<Participant_Enrollment__c> participantEnrollments =
                ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
        if (participantEnrollments.size() == 0) throw new CommunityServiceException('Data not found');
        this.pe = participantEnrollments.get(0);
        this.studyAction = this.getStudyActions();
        this.trialDetail.tabs = this.getStudyTabs();
    }

    public override TrialDetail createTrial() {

        Map<Id, Study_Site__c> idToStudySiteMap = new Map<Id, Study_Site__c>();
        idToStudySiteMap.put(pe.Study_Site__r.Site__c, pe.Study_Site__r);
        List<Account> accounts = this.getAccounts(idToStudySiteMap.keySet());
        for (Integer i = 0; i < accounts.size(); i++) {
            Account acc = accounts.get(i);
            trialDetail.accountEnrollmentsList.add(
                    createClinicWrapper(acc.Name, acc, null, null)
            );
        }
        return this.trialDetail;
    }

    protected override StudyActions getStudyActions() {
        StudyActions s = new StudyActionsParticipant(pe.Study_Site__r.Clinical_Trial_Profile__r, pe.Study_Site__r, null, pe);
        return s;
    }

    protected override List<TrialDetail.StudyTab> getStudyTabs() {

        List<TrialDetail.StudyTab> tabs = new List<TrialDetail.StudyTab>();
        System.debug('getStudyTabs>>>' + this.studyAction);
        List<StudyActions.Action> defaultActions = this.studyAction.studyDetailActions;
        List<StudyActions.Action> backHomeAction = new List<StudyActions.Action>();
        backHomeAction.add(new StudyActions.Action(
                StudyActions.ACT_HOME,
                Label.Link_Back_To_Home,
                'icon-home-brand-new',
                false
        ));

        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();

        if (participantState.value == ParticipantService.ParticipantStates.ALUMNI) {
            tabs.add(new TrialDetail.StudyTab(
                    'tab-tasks',
                    'task',
                    Label.PG_SW_Tab_Tasks,
                    backHomeAction
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Resources'),
                    backHomeAction
            ));

        } else if (participantState.value == ParticipantService.ParticipantStates.REFERRAL
                || participantState.value == ParticipantService.ParticipantStates.PROSPECT) {

            tabs.add(new TrialDetail.StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    Label.PG_SW_Tab_About_The_Study,
                    defaultActions
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-tasks',
                    'task',
                    Label.PG_SW_Tab_Tasks,
                    backHomeAction
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    Label.PG_SW_Tab_Resources,
                    backHomeAction
            ));

        } else if (participantState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            tabs.add(new TrialDetail.StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    Label.PG_SW_Tab_About_The_Study,
                    defaultActions
            ));

            if (participantState.isPremium) {
                tabs.add(new TrialDetail.StudyTab(
                        'tab-visits',
                        'referred-patient',
                        Label.PG_SW_Tab_Visits,
                        backHomeAction
                ));
            }

            tabs.add(new TrialDetail.StudyTab(
                    'tab-tasks',
                    'task',
                    Label.PG_SW_Tab_Tasks,
                    backHomeAction
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    Label.PG_SW_Tab_Resources,
                    backHomeAction
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-lab-results',
                    'reports',
                    Label.PG_SW_Tab_Lab_Results,
                    backHomeAction
            ));
        } else {
            tabs.add(new TrialDetail.StudyTab(
                    'tab-tasks',
                    'task',
                    Label.PG_SW_Tab_Tasks,
                    backHomeAction
            ));
            tabs.add(new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    Label.PG_SW_Tab_Resources,
                    backHomeAction
            ));
        }
        return tabs;
    }
}