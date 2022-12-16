/**
 * Created by AlexKetch on 5/21/2019.
 */

public with sharing class ParticipantTrialBuilder extends TrialBuilder {
    private Participant_Enrollment__c pe;
    private string participantstate;
    private Boolean isNewPP;

    public ParticipantTrialBuilder(Boolean inputIsNewPP) {
        isNewPP = inputIsNewPP;
        initializeData();
    }

    public ParticipantTrialBuilder() {
        initializeData();
    }

    public void initializeData() {
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        pe = ps.pe;
        participantstate = JSON.serialize(ps);
        if (pe != null)
            setTrial(pe.Study_Site__r.Clinical_Trial_Profile__c);

        studyAction = getStudyActions();
        trialDetail.showVisits = ps.showVisits;
        trialDetail.tabs = getStudyTabs();
        trialDetail.communityName = ps.communityName;
        trialDetail.showTravelCardInPreEnrollment = ps.showTravelCardInPreEnrollment;
    }

    public override TrialDetail createTrial() {
        if (pe == null)
            return trialDetail;
        trialDetail.pe = pe;
        trialDetail.participantstate = participantstate;
        Map<Id, Study_Site__c> idToStudySiteMap = new Map<Id, Study_Site__c>();
        idToStudySiteMap.put(pe.Study_Site__r.Site__c, pe.Study_Site__r);
        List<Account> accounts = getAccounts(idToStudySiteMap.keySet());
        for (Integer i = 0; i < accounts.size(); i++) {
            Account acc = accounts.get(i);
            trialDetail.accountEnrollmentsList.add(createClinicWrapper(acc.Name, acc, null, null));
        }
        return trialDetail;
    }

    protected override StudyActions getStudyActions() {
        return new StudyActionsParticipant();
    }

    protected override List<TrialDetail.StudyTab> getStudyTabs() {
        List<TrialDetail.StudyTab> tabs = new List<TrialDetail.StudyTab>();
        List<StudyActions.Action> defaultActions = this.studyAction.studyDetailActions;
        List<StudyActions.Action> backHomeAction = new List<StudyActions.Action>();
        backHomeAction.add(
            new StudyActions.Action(
                StudyActions.ACT_HOME,
                Label.Link_Back_To_Home,
                'icon-home-brand-new',
                false
            )
        );

        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();

        if (participantState.value == ParticipantService.ParticipantStates.ALUMNI) {
            tabs.add(
                new TrialDetail.StudyTab('tab-tasks', 'task', Label.PG_SW_Tab_Tasks, backHomeAction)
            );
            tabs.add(
                new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Resources'),
                    backHomeAction
                )
            );
        } else if (
            participantState.value == ParticipantService.ParticipantStates.REFERRAL ||
            participantState.value == ParticipantService.ParticipantStates.PROSPECT
        ) {
            tabs.add(
                new TrialDetail.StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    participantState.ctp.Is_Program__c
                        ? Label.PG_SW_Tab_About_The_Program
                        : Label.PG_SW_Tab_About_The_Study,
                    defaultActions
                )
            );
            tabs.add(
                new TrialDetail.StudyTab('tab-tasks', 'task', Label.PG_SW_Tab_Tasks, backHomeAction)
            );
            //----------Visits---------------------
            Boolean shoVi =
                participantState.showVisits && participantState.ctp.Visits_are_Available__c;

            if (isNewPP == true && participantState.isPremium && shoVi) {
                        tabs.add(
                            new TrialDetail.StudyTab(
                                'tab-visits',
                                'referred-patient',
                                participantState.ctp.Is_Program__c
                                    ? Label.PG_SW_Tab_Events
                                    : Label.PG_SW_Tab_Visits,
                                backHomeAction
                            )
                        );
            } else if (
                isNewPP != true && participantState.isPremium &&
                (shoVi ||
                (participantState.ctp.Received_Until_Consent_Is_Available__c ||
                participantState.ctp.Enrolled_Or_Randomized_Consent_Available__c ||
                (participantState.ctp.Televisit_Vendor_is_Available__c &&
                participantState.showTeleVisits &&
                participantState.isTeleVendorEnabled)))
            ) {
                tabs.add(
                    new TrialDetail.StudyTab(
                        'tab-visits',
                        'referred-patient',
                        participantState.ctp.Is_Program__c
                            ? Label.PG_SW_Tab_Events
                            : Label.PG_SW_Tab_Visits,
                        backHomeAction
                    )
                );
            }
            //--------------Study Resource-----------------------------
            if (
                participantState.ctp.Study_Documents_Are_Available__c ||
                participantState.ctp.Video_And_Articles_Are_Available__c
            ) {
                tabs.add(
                    new TrialDetail.StudyTab(
                        'tab-resources',
                        'resources',
                        Label.PG_SW_Tab_Resources,
                        backHomeAction
                    )
                );
            }
        } else if (participantState.value == ParticipantService.ParticipantStates.PARTICIPANT) {
            tabs.add(
                new TrialDetail.StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    (isNewPP == true && participantState.ctp.Is_Program__c)
                        ? Label.PG_SW_Tab_About_The_Program
                        : Label.PG_SW_Tab_About_The_Study,
                    defaultActions
                )
            );
            Boolean showVisit = participantState.showVisits;
            Boolean shoVi =
                participantState.showVisits && participantState.ctp.Visits_are_Available__c;
            Boolean visitAvailable = showVisit && shoVi;

            tabs.add(
                new TrialDetail.StudyTab('tab-tasks', 'task', Label.PG_SW_Tab_Tasks, backHomeAction)
            );
            if (isNewPP == true && participantState.isPremium && shoVi) {
                tabs.add(
                    new TrialDetail.StudyTab(
                        'tab-visits',
                        'referred-patient',
                        participantState.ctp.Is_Program__c
                            ? Label.PG_SW_Tab_Events
                            : Label.PG_SW_Tab_Visits,
                        backHomeAction
                    )
                );
            } else {
                /**PEH-525*/
                if (
                    isNewPP != true && participantState.isPremium &&
                    (participantState.showTravelCardInPreEnrollment ||
                    participantState.ctp.Travel_Vendor_Is_Available__c ||
                    visitAvailable ||
                    (participantState.ctp.Televisit_Vendor_is_Available__c &&
                    participantState.showTeleVisits &&
                    participantState.isTeleVendorEnabled)) //Condition for Televisits
                ) {
                    tabs.add(
                        new TrialDetail.StudyTab(
                            'tab-visits',
                            'referred-patient',
                            participantState.ctp.Is_Program__c
                                ? Label.PG_SW_Tab_Events
                                : Label.PG_SW_Tab_Visits,
                            backHomeAction
                        )
                    );
                }
            }

            if (
                participantState.ctp.Study_Documents_Are_Available__c ||
                participantState.ctp.Video_And_Articles_Are_Available__c
            ) {
                tabs.add(
                    new TrialDetail.StudyTab(
                        'tab-resources',
                        'resources',
                        Label.PG_SW_Tab_Resources,
                        backHomeAction
                    )
                );
            }
            if (
                (isNewPP != true || 
                participantState.ctp.Is_Program__c != true) &&
                participantState.showVisits &&
                participantState.showResults &&
                VisitResultsRemote.isVisitResultAvailable()
            ) {
                tabs.add(
                    new TrialDetail.StudyTab(
                        'tab-lab-results',
                        'reports',
                        Label.PG_SW_Tab_Lab_Results,
                        backHomeAction
                    )
                );
            }
            
        } else {
            tabs.add(
                new TrialDetail.StudyTab('tab-tasks', 'task', Label.PG_SW_Tab_Tasks, backHomeAction)
            );
            tabs.add(
                new TrialDetail.StudyTab(
                    'tab-resources',
                    'resources',
                    Label.PG_SW_Tab_Resources,
                    backHomeAction
                )
            );
        }
        return tabs;
    }
}
