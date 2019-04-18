/**
 * Created by Leonid Bartenev
 */
public without sharing class StudyDetailViewController {

    public class TrialDetail {
        public Clinical_Trial_Profile__c trial;
        public List<ClinicWrapper> accountEnrollmentsList;
        public Boolean isTCAccepted;
        public Boolean isSSAccepted;
        public Study_Site__c studySite; //for PI mode
        public HCP_Enrollment__c hcpe; //for HCP mode
        public List<StudyTab> tabs;
        public List<StudyActions.Action> shareActions;
    }

    public class ClinicWrapper implements Comparable {
        public Account clinic;  //If there is no completed BillingAddress, the clinic is not displayed on RRGoogleMap
        public String name;
        public String addrStreet;
        public String addrCity;
        public String hcpStatus;
        public String hcpStatusLabel;
        public String studySiteId;


        public Integer compareTo(Object compareTo) {
            ClinicWrapper compareToCW = (ClinicWrapper) compareTo;
            if (this.hcpStatus != null && compareToCW.hcpStatus == null) return -1;
            if (this.hcpStatus == null && compareToCW.hcpStatus != null) return 1;
            return 0;
        }
    }

    public class StudyTab {
        public String id;
        public String iconName;
        public String title;
        public List<StudyActions.Action> studyActions;

        public StudyTab(String id, String iconName, String title, List<StudyActions.Action> studyActions) {
            this.id = id;
            this.iconName = iconName;
            this.title = title;
            this.studyActions = studyActions;
        }
    }

    @AuraEnabled
    public static String getTrialDetail(String trialId, String userMode) {
        try {
            if (trialId == null && userMode == CommunityService.USER_MODE_PARTICIPANT) {
                List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
                if (peList.size() > 0) trialId = peList[0].Study_Site__r.Clinical_Trial_Profile__c;
            }
            TrialDetail trialDetail = new TrialDetail();
            trialDetail.trial = TrialService.getTrial(trialId);
            trialDetail.accountEnrollmentsList = new List<ClinicWrapper>();
            trialDetail.isTCAccepted = TermsAndConditions.isTCAccepted(trialDetail.trial.Terms_And_Conditions_ID__c);

            if (userMode == CommunityService.USER_MODE_PI) {
                List<Study_Site__c> studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
                if (studySites.size() == 0) throw new CommunityServiceException('Data not found');
                trialDetail.studySite = studySites[0];
                trialDetail.isSSAccepted = StudySiteService.STATUS_GROUP_ACCEPTED.contains(studySites[0].Override_PI_Referral_Status__c);
                StudyActions studyActions = new StudyActionsPI(studySites[0]);
                trialDetail.shareActions = new List<StudyActions.Action>(studyActions.actions.values());
                trialDetail.tabs = getStudyTabs(CommunityService.USER_MODE_PI, studyActions.studyDetailActions);
                //prepare account list
                List<HCP_Enrollment__c> enrollments = HCPEnrollmentService.getEnrollmentsForPIByStudySiteId(studySites[0].Id);
                Set<Id> accountIds = new Set<Id>();
                for (HCP_Enrollment__c hcpe : enrollments) accountIds.add(hcpe.HCP_Contact__r.AccountId);
                List<Account> accounts = getAccounts(accountIds);
                for (Account account : accounts) {
                    trialDetail.accountEnrollmentsList.add(createClinicWrapper(account.Name, account, null, null));
                }
            } else if (userMode == CommunityService.USER_MODE_HCP) {
                HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
                if (hcpEnrollment == null) throw new CommunityServiceException('Data not found');
                trialDetail.hcpe = hcpEnrollment;
                StudyActions studyActions = new StudyActionsHCP(hcpEnrollment);
                trialDetail.shareActions = new List<StudyActions.Action>(studyActions.actions.values());
                trialDetail.tabs = getStudyTabs(userMode, studyActions.studyDetailActions);
                //init study site accounts:
                Set<Id> accIds = new Set<Id>();
                List<Study_Site__c> hcpStudySites = StudySiteService.getStudySitesForHCPByTrialId(trialId);
                for (Study_Site__c ss : hcpStudySites) accIds.add(ss.Site__c);
                Map<Id, Account> accountsMap = new Map<Id, Account>(getAccounts(accIds));
                //init list of study sites accounts:
                List<String> hidedStatuses = new List<String>{
                        HCPEnrollmentService.HCP_S_INVITATION_SENT,
                        HCPEnrollmentService.HCP_S_DECLINED_ACCEPTANCE
                };
                for (Study_Site__c ss : hcpStudySites) {
                    String hcpStatus;
                    if (hcpEnrollment.Study_Site__c == ss.Id && !hidedStatuses.contains(hcpEnrollment.Status__c)) hcpStatus = hcpEnrollment.Status__c;
                    trialDetail.accountEnrollmentsList.add(createClinicWrapper(ss.Name, accountsMap.get(ss.Site__c), hcpStatus, ss.Id));
                }
                trialDetail.accountEnrollmentsList.sort();
            } else if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                List<Participant_Enrollment__c> participantEnrollments =
                        ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
                if (participantEnrollments.size() == 0) throw new CommunityServiceException('Data not found');
                Participant_Enrollment__c pe = participantEnrollments.get(0);
                StudyActionsParticipant studyActions =
                        new StudyActionsParticipant(pe.Study_Site__r.Clinical_Trial_Profile__r, pe.Study_Site__r, null, pe);
                trialDetail.shareActions = new List<StudyActions.Action>(studyActions.actions.values());
                trialDetail.tabs = getStudyTabs(userMode, studyActions.studyDetailActions);
                Map<Id, Study_Site__c> idToStudySiteMap = new Map<Id, Study_Site__c>();
                idToStudySiteMap.put(pe.Study_Site__r.Site__c, pe.Study_Site__r);

                List<Account> accounts = getAccounts(idToStudySiteMap.keySet());
                for (Integer i = 0; i < accounts.size(); i++) {
                    Account acc = accounts.get(i);
                    trialDetail.accountEnrollmentsList.add(
                            createClinicWrapper(idToStudySiteMap.get(acc.Id).Name, acc, null, null)
                    );
                }
            }

            return JSON.serialize(trialDetail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<Account> getAccounts(Set<Id> accIds) {
        return [
                SELECT Id,
                        Name,
                        BillingStreet,
                        BillingState,
                        BillingPostalCode,
                        BillingCity,
                        BillingCountry,
                        BillingCountryCode,
                        BillingStateCode,
                        Phone,
                        BillingLongitude,
                        BillingLatitude
                FROM Account
                WHERE Id IN :accIds
        ];
    }

    private static ClinicWrapper createClinicWrapper(String name, Account acc, String hcpStatus, Id studySiteId) {
        ClinicWrapper wrapper = new ClinicWrapper();
        wrapper.clinic = acc;
        wrapper.name = name;
        List<String> addressList = new List<String>();
        if (acc.BillingCity != null) addressList.add(acc.BillingCity);
        if (acc.BillingState != null) addressList.add(acc.BillingState);
        if (acc.BillingPostalCode != null) addressList.add(acc.BillingPostalCode);
        wrapper.addrStreet = acc.BillingStreet;
        if (addressList.size() > 0) wrapper.addrCity = String.join(addressList, ', ');
        wrapper.studySiteId = studySiteId;
        wrapper.hcpStatus = hcpStatus;
        wrapper.hcpStatusLabel = TranslateHelper.getPickListLabel(HCP_Enrollment__c.Status__c, hcpStatus);
        return wrapper;
    }

    public static List<StudyTab> getStudyTabs(String userMode, List<StudyActions.Action> studyActions) {
        List<StudyTab> tabs = new List<StudyTab>();
        if (userMode == CommunityService.USER_MODE_HCP) {
            tabs.add(new StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    TranslateHelper.getLabelValue('PG_SW_Tab_About_The_Study'),
                    studyActions
            ));
            tabs.add(new StudyTab(
                    'tab-referred-patients',
                    'referred-patient',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Referred_Patients'),
                    studyActions
            ));
//            tabs.add(new StudyTab(
//                    'tab-medical-record-review-log',
//                    'chart-review-sent',
//                    TranslateHelper.getLabelValue('PG_SW_Tab_Medical_Record_Review_Log')
//            ));
            tabs.add(new StudyTab(
                    'tab-referred-study-sites',
                    'referred-clinic',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Study_Sites'),
                    studyActions
            ));
            tabs.add(new StudyTab(
                    'tab-reports',
                    'reports',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Reports'),
                    studyActions
            ));
        } else if (userMode == CommunityService.USER_MODE_PI) {
            tabs.add(new StudyTab(
                    'tab-about-the-study',
                    'about-the-study',
                    TranslateHelper.getLabelValue('PG_SW_Tab_About_The_Study'),
                    studyActions
            ));
            tabs.add(new StudyTab(
                    'tab-referrals',
                    'referrals',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Referrals'),
                    studyActions
            ));
            tabs.add(new StudyTab(
                    'tab-referred-clinics',
                    'referred-clinic',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Referring_Clinics'),
                    studyActions
            ));
            tabs.add(new StudyTab(
                    'tab-reports',
                    'reports',
                    TranslateHelper.getLabelValue('PG_SW_Tab_Reports'),
                    studyActions
            ));
        } else if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            List<StudyActions.Action> backHomeAction = new List<StudyActions.Action>();
            backHomeAction.add(new StudyActions.Action(
                    'backHome',
                    TranslateHelper.getLabelValue('Link_Back_To_Home'),
                    'icon-home-brand-new',
                    false
            ));

            ParticipantService.ParticipantStates stateValue = ParticipantService.getParticipantState().value;

            if (stateValue == ParticipantService.ParticipantStates.ALUMNI) {
                tabs.add(new StudyTab(
                        'tab-tasks',
                        'task',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Tasks'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-resources',
                        'resources',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Visits'),
                        backHomeAction
                ));

            } else if (stateValue == ParticipantService.ParticipantStates.REFERRAL) {
                tabs.add(new StudyTab(
                        'tab-about-the-study',
                        'about-the-study',
                        TranslateHelper.getLabelValue('PG_SW_Tab_About_The_Study'),
                        studyActions
                ));
                tabs.add(new StudyTab(
                        'tab-tasks',
                        'task',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Tasks'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-resources',
                        'resources',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Resources'),
                        backHomeAction
                ));

            } else if (stateValue == ParticipantService.ParticipantStates.PARTICIPANT) {
                tabs.add(new StudyTab(
                        'tab-about-the-study',
                        'about-the-study',
                        TranslateHelper.getLabelValue('PG_SW_Tab_About_The_Study'),
                        studyActions
                ));

                tabs.add(new StudyTab(
                        'tab-visits',
                        'referred-patient',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Visits'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-tasks',
                        'task',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Tasks'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-resources',
                        'resources',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Resources'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-lab-results',
                        'reports',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Lab_Results'),
                        backHomeAction
                ));
            } else {
                tabs.add(new StudyTab(
                        'tab-tasks',
                        'task',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Tasks'),
                        backHomeAction
                ));
                tabs.add(new StudyTab(
                        'tab-resources',
                        'resources',
                        TranslateHelper.getLabelValue('PG_SW_Tab_Resources'),
                        backHomeAction
                ));
            }

        }

        return tabs;
    }

}