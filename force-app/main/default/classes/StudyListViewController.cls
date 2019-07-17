/**
 * Created by D.Yasinskyi on 14.02.2018
 */

public without sharing class StudyListViewController {

    private static final String DUMMY_ACCOUNT_NAME = 'Dummy Account For Location Check';

    class StudiesGroup {
        String name;
        List<StudyDetailItem> studies = new List<StudyDetailItem>();

        StudiesGroup(String name) {
            this.name = name;
        }
    }

    class InitData {
        List<StudyDetailItem> trialsNoLongerRecruiting = new List<StudyDetailItem>();
        List<StudyDetailItem> currentlyRecruitingTrials = new List<StudyDetailItem>();
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        List<ParticipantItem> peList = new List<ParticipantItem>();
        List<ParticipantItem> peListNoLongerRecr = new List<ParticipantItem>();
        List<Account> contactAccounts = new List<Account>();
        List<LabelValueItem> countries = new List<LabelValueItem>{
                new LabelValueItem('None', null)
        };
        Map<String, List<LabelValueItem>> statesByCountryMap;
        Map<String, String> countriesMap;
        Map<String, String> countryCodesMap;
    }

    @TestVisible
    class HCPInitData {
        public StudyTrialService.StudySortData sortData;
        public StudyTrialService.StudyFilterData filterData;
        public PaginationData paginationData;
        public List<StudyDetailItem> currentPageList;
        public String delegateAccessLevel;
    }

    @AuraEnabled
    public static String getStudyTrialList(String userMode) {
        try {
            returnAndRemoveAccount();
            InitData initData = new InitData();
            List<StudyDetailItem> studies;
            if (userMode == CommunityService.USER_MODE_HCP) {
                studies = getStudiesForHCP();
                groupTrials(initData, studies, userMode);
            } else if (userMode == CommunityService.USER_MODE_PI) {
                studies = getStudiesForPI();
                groupTrials(initData, studies, userMode);
                initData.countries.addAll(CountryStateUtil.getCountries());
                initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
                initData.countriesMap = CountryStateUtil.COUNTRY_MAP;
                initData.countryCodesMap = CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP;
            } else if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                Participant_Enrollment__c[] peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
                for (Participant_Enrollment__c pe : peList) {
                    if (pe.Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING) {
                        initData.peListNoLongerRecr.add(new ParticipantItem(pe));
                    } else {
                        initData.peList.add(new ParticipantItem(pe));
                    }
                }
            }
            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String searchStudies(String filterData, String sortData, String paginationData, Boolean isSearchResume) {
        try {
            String studiesJSON = StudyTrialService.getStudiesJSON(filterData, sortData, paginationData, isSearchResume);
            return studiesJSON;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getHCPInitData() {
        try {
            HCPInitData initData = new HCPInitData();

            //pagination:
            initData.paginationData = StudyTrialService.getPaginationData();

            //sort data:
            initData.sortData = StudyTrialService.getStudySortDataForHCP();

            //filters data:
            initData.filterData = StudyTrialService.getStudyFilterData();

            //records for current filter, sort and pagination:
            initData.currentPageList = StudyTrialService.getStudies(initData.filterData, initData.sortData, initData.paginationData);

            // refresh filter data with TA options list
            initData.filterData = StudyTrialService.getStudyFilterData();

            initData.delegateAccessLevel = CommunityService.getInstance().getUserAccessLevel();
            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public static List<StudyDetailItem> getStudiesForHCP() {
        // prepare map trialId -> HCPEnrollment:
        Map<Id, HCP_Enrollment__c> trialHCPEnrollmentMap = new Map<Id, HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrollment : HCPEnrollmentService.getHCPEnrollmentsForHCP()) {
            trialHCPEnrollmentMap.put(enrollment.Study_Site__r.Clinical_Trial_Profile__c, enrollment);
        }

        // get trials with fields and TC:
        List<Clinical_Trial_Profile__c> trials = StudyTrialService.getTrials(trialHCPEnrollmentMap.keySet());
        //prepare list of studies:
        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : trials) {
            HCP_Enrollment__c hcpe = trialHCPEnrollmentMap.get(trial.Id);
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            studyDetailItem.hcpe = hcpe;
            studyDetailItem.trial = trial;
            studyDetailItem.studyStatus = hcpe.Status__c;
            studyDetailItem.studyActions = new StudyActionsHCP(hcpe).studyListViewItemActions;
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            studies.add(studyDetailItem);
        }
        return studies;
    }

    public static List<StudyDetailItem> getStudiesForPI() {
        // prepare map trialId -> StudySite
        Map<Id, List<Study_Site__c>> trialStudySiteMap = new Map<Id, List<Study_Site__c>>();
        List<Study_Site__c> piStudySites = StudySiteService.getStudySitesForPI();
        Map<Id,Map<Id,Account>> piAccounts = getPiAccounts(piStudySites);
        for (Study_Site__c studySite : piStudySites) {
            if (!trialStudySiteMap.keySet().contains(studySite.Clinical_Trial_Profile__c)) {
                trialStudySiteMap.put(studySite.Clinical_Trial_Profile__c, new List<Study_Site__c>{
                        studySite
                });
            } else {
                trialStudySiteMap.get(studySite.Clinical_Trial_Profile__c).add(studySite);
            }
        }
        Map<String, List<Site_Staff__c>> delegatesMap = getDelegates(trialStudySiteMap.keySet());
        // get trials and TC:
        List<Clinical_Trial_Profile__c> trials = StudyTrialService.getTrials(trialStudySiteMap.keySet());
        Map<Id, Boolean> termsAcceptedMap;
        termsAcceptedMap = TermsAndConditions.getTrialsAcceptanceMap(trials);
        // prepare result list:
        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : trials) {
            List<Study_Site__c> ss = trialStudySiteMap.get(trial.Id);
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            studyDetailItem.trial = trial;
            studyDetailItem.delegatePicklist = getDelegatePickList(delegatesMap.get(trial.Id));
            Study_Site__c initionSS = new Study_Site__c();
            Map<String, Study_Site__c> statusMap = new Map<String, Study_Site__c>();
            for (Integer i = 0; i < ss.size(); i++) {
                StudyActionsPI act = new StudyActionsPI(ss[i]);
                studyDetailItem.ssList.add(new StudyDetailItem.StudySiteWithActions(ss[i], act.studySitePiActions, piAccounts.get(ss[i].Principal_Investigator__c).values()));
                if (ss[i].Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT) {
                    statusMap.put(StudySiteService.PI_S_INVITATION_SENT, ss[i]);
                } else if (ss[i].Override_PI_Referral_Status__c == StudySiteService.PI_S_DECLINED_ACCEPTANCE || ss[i].Override_PI_Referral_Status__c == StudySiteService.PI_S_NON_RESPONCIVE_A) {
                    statusMap.put(StudySiteService.PI_S_DECLINED_ACCEPTANCE, ss[i]);
                } else if (ss[i].Override_PI_Referral_Status__c == StudySiteService.PI_S_DEACTIVATED_A) {
                    statusMap.put(StudySiteService.PI_S_DEACTIVATED_A, ss[i]);
                } else {
                    statusMap.put(StudySiteService.PI_S_ACCEPTED, ss[i]);
                }
            }
            if (statusMap.containsKey(StudySiteService.PI_S_INVITATION_SENT)) {
                initionSS = statusMap.get(StudySiteService.PI_S_INVITATION_SENT);
            } else if (statusMap.containsKey(StudySiteService.PI_S_DECLINED_ACCEPTANCE)) {
                initionSS = statusMap.get(StudySiteService.PI_S_DECLINED_ACCEPTANCE);
            } else if (statusMap.size() == 1 && statusMap.containsKey(StudySiteService.PI_S_DEACTIVATED_A)) {
                initionSS = statusMap.get(StudySiteService.PI_S_DEACTIVATED_A);
            } else {
                initionSS = statusMap.get(StudySiteService.PI_S_ACCEPTED);
            }
            studyDetailItem.studyActions = new StudyActionsPI(initionSS).studyListViewItemActions;
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            studies.add(studyDetailItem);
        }
        return studies;
    }

    public static void groupTrials(InitData initData, List<StudyDetailItem> allStudies, String userMode) {
        StudiesGroup activated = new StudiesGroup(userMode == CommunityService.USER_MODE_PI ? Label.SGT_Accepted_and_active : Label.SGT_Activated);
        StudiesGroup pendingStudySiteAction = new StudiesGroup(Label.SGT_Pending_Study_Site_s_Action);
        StudiesGroup onHold = new StudiesGroup(Label.SGT_On_hold);
        StudiesGroup pendingYourAction = new StudiesGroup(Label.SGT_Pending_Your_Action);
        StudiesGroup declined = new StudiesGroup(Label.SGT_Declined_Acceptance);
        StudiesGroup declinedOther = new StudiesGroup(Label.SGT_Declined_by_Others);
        StudiesGroup deactivated = new StudiesGroup(Label.SGT_Deactivated);
        for (StudyDetailItem item : allStudies) {
            TranslateHelper.translate(item.trial);
            if (item.trial.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING) {
                initData.trialsNoLongerRecruiting.add(item);
            } else {
                initData.currentlyRecruitingTrials.add(item);
            }
        }
        StudyDetailItem.sortType = 'Name';
        initData.currentlyRecruitingTrials.sort();
        initData.trialsNoLongerRecruiting.sort();
        /*if (item.studyStatus.startsWith('Activated') || item.studyStatus.startsWith('Accepted')) {
                activated.studies.add(item);
            } else if (item.studyStatus == StudySiteService.PI_S_INVITATION_SENT) {
                pendingYourAction.studies.add(item);
            } else if (item.studyStatus.contains('Pending')) {
                pendingStudySiteAction.studies.add(item);
            } else if (item.studyStatus.startsWith('On Hold')) {
                onHold.studies.add(item);
            } else if (item.studyStatus == 'Declined (Acceptance)' || item.studyStatus == 'Non-Responsive (Admin)') {
                declined.studies.add(item);
            } else if (item.studyStatus.contains('Declined')) {
                declinedOther.studies.add(item);
            } else if (item.studyStatus == 'Deactivated (Admin)') {
                deactivated.studies.add(item);
            }
        }
        if (activated.studies.size() > 0) initData.currentlyRecruitingTrials.add(activated);
        if (pendingYourAction.studies.size() > 0) initData.currentlyRecruitingTrials.add(pendingYourAction);
        if (pendingStudySiteAction.studies.size() > 0) initData.currentlyRecruitingTrials.add(pendingStudySiteAction);
        if (onHold.studies.size() > 0) initData.currentlyRecruitingTrials.add(onHold);
        if (declined.studies.size() > 0) initData.currentlyRecruitingTrials.add(declined);
        if (declinedOther.studies.size() > 0) initData.currentlyRecruitingTrials.add(declinedOther);
        if (deactivated.studies.size() > 0) initData.currentlyRecruitingTrials.add(deactivated);*/
    }


    public static void loadStatistics(List<StudyDetailItem> studies) {
        Map<Id, Integer> referredCountMap = ParticipantEnrollmentService.getReferredByTrial();
        String allReviewedFilter = ' AND Participant_Status__c IN (\'' + String.join(new List<String>(PEStatusState.ALL_USED_STATUSES_WITH_REFERRING), '\',\'') + '\') ';
        Map<Id, Integer> allCountMap = ParticipantEnrollmentService.getPECountMapByTrialsForPI(allReviewedFilter);
        for (StudyDetailItem item : studies) {
            item.statistics.add(new StudyTotalPassed('all',
                    allCountMap.get(item.trial.Id),
                    referredCountMap.get(item.trial.Id)
            ));
        }
    }

    public static List<Account> getPIAccounts(List<StudyDetailItem> studies) {
        List<Account> accounts = StudyTrialService.getAccounts(studies);
        return accounts;
    }

    @AuraEnabled
    public static String saveSSChanges(String studySiteInfo) {
        try {
            StudyTrialService.saveSSChanges(studySiteInfo);
            String newInitData = getStudyTrialList(CommunityService.USER_MODE_PI);
            return newInitData;
        } catch (Exception e) {
            String status = (String) AuraHelper.throwException(e);
            return status;
        }
    }


    @AuraEnabled
    public static String saveSSAddress(String studySiteInfo) {
        try {
            StudyTrialService.saveSSAddress(studySiteInfo);
            String newInitData = getStudyTrialList(CommunityService.USER_MODE_PI);
            return newInitData;
        } catch (Exception e) {
            String status = (String) AuraHelper.throwException(e);
            return status;
        }
    }

    @AuraEnabled
    public static void checkAccountGeolocation(String account) {
        Account newAccount = (Account) JSON.deserialize(account, Account.class);
        Account accForCheck = new Account(Name = DUMMY_ACCOUNT_NAME + ' ' + UserInfo.getUserId(),
                BillingStreet = newAccount.BillingStreet,
                BillingCountry = newAccount.BillingCountry,
                BillingCity = newAccount.BillingCity);
        insert accForCheck;
    }

    @AuraEnabled
    public static String returnAndRemoveAccount() {
        List<Account> acc = [SELECT Id,Name,BillingLongitude,BillingCity,BillingLatitude FROM Account WHERE Name = :DUMMY_ACCOUNT_NAME + ' ' + UserInfo.getUserId()];
        String valueToReturn;
        if (acc.size() > 0) {
            valueToReturn = JSON.serialize(acc[0]);
            delete acc;
        }
        return valueToReturn;
    }


    private static Map<String, List<Site_Staff__c>> getDelegates(Set<Id> triaIds) {
        Map<String, List<Site_Staff__c>> delegatesMap = new Map<String, List<Site_Staff__c>>();
        for (Site_Staff__c ss : [
                SELECT Id,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__r.Clinical_Trial_Profile__c,
                        Site_Contact__r.Name,
                        Site_Contact__c
                FROM Site_Staff__c
                WHERE Study_Site__r.Clinical_Trial_Profile__c IN :triaIds
        ]) {
            if (delegatesMap.containsKey(ss.Study_Site__r.Principal_Investigator__c)) {
                delegatesMap.get(ss.Study_Site__r.Clinical_Trial_Profile__c).add(ss);
            } else {
                delegatesMap.put(ss.Study_Site__r.Clinical_Trial_Profile__c, new List<Site_Staff__c>{
                        ss
                });
            }
        }
        return delegatesMap;
    }

    private static List<LabelValueItem> getDelegatePickList(List<Site_Staff__c> ss) {
        Map<Id, LabelValueItem> delegates = new Map<Id, LabelValueItem>();
        try {
            if (!ss.isEmpty()) {
                for (Site_Staff__c delegatesSites : ss) {
                    delegates.put(delegatesSites.Site_Contact__c, new LabelValueItem(delegatesSites.Site_Contact__r.Name, delegatesSites.Id));
                }
            }
            List<LabelValueItem> labelList = new List<LabelValueItem>();
            if (!delegates.isEmpty()) {
                labelList.add(new LabelValueItem('None', ' '));
                labelList.addAll(delegates.values());
            }
            return labelList;
        } catch (Exception ex) {
            return null;
        }
    }

    private static Map<Id,Map<Id,Account>> getPiAccounts(List<Study_Site__c> studies) {
        Set<Id> piIds = new Set<Id>();
        for (Integer i = 0; i <studies.size() ; i++) {
            piIds.add(studies[i].Principal_Investigator__c);
        }
        try {
            Map<Id, Map<Id,Account>> accountMap = new Map<Id, Map<Id,Account>>();
            if(!piIds.isEmpty()) {
                for (AccountContactRelation piAccounts : [
                        SELECT Id,
                                Contact.Id,
                                Contact.Name,
                                Contact.primaryContact__c,
                                Account.Id,
                                Account.Name,
                                Account.ParentId,
                                Account.BillingCountry,
                                Account.BillingCity,
                                Account.BillingStreet,
                                Account.BillingPostalCode,
                                Account.BillingState,
                                Account.BillingStateCode,
                                Account.BillingLatitude,
                                Account.BillingLongitude,
                                Account.Driving_Directions__c,
                                Account.Parking_Instructions__c
                        FROM AccountContactRelation
                        WHERE ContactId IN :piIds
                ]) {
                    if (accountMap.containsKey(piAccounts.Contact.Id)) {
                        accountMap.get(piAccounts.Contact.Id).put(piAccounts.Account.Id,piAccounts.Account);
                    } else {
                        accountMap.put(piAccounts.Contact.Id, new Map<Id, Account>{piAccounts.Account.Id => piAccounts.Account});
                    }
                }

                for (Integer i = 0; i < studies.size(); i++) {
                    if (!studies[i].Account_Was_Changed__c) {
                        if (accountMap.containsKey(studies[i].Principal_Investigator__c)) {
                            Map<Id, Account> accMap = accountMap.get(studies[i].Principal_Investigator__c);
                                accMap.put(studies[i].Site__c,studies[i].Site__r);
                        } else {
                            accountMap.put(studies[i].Principal_Investigator__c, new Map<Id, Account>{
                                    studies[i].Site__c =>  studies[i].Site__r});
                        }
                    }
                }
            }
            return accountMap;
        } catch (Exception ex) {
            return null;
        }
    }
}