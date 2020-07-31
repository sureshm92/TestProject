/**
 * Created by D.Yasinskyi on 14.02.2018
 */

public without sharing class StudyListViewController {
    
    private static final String DUMMY_ACCOUNT_NAME = 'Dummy Account For Location Check';
    
//    class StudiesGroup {
//        String name;
//        List<StudyDetailItem> studies = new List<StudyDetailItem>();
//
//        StudiesGroup(String name) {
//            this.name = name;
//        }
//    }
    
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

    @TestVisible
    class PIInitData {
        public PIStudiesFilter piStudiesFilter;
        public PaginationData paginationData;
        public List<StudyDetailItem> currentPITrials;
        List<LabelValueItem> countries = new List<LabelValueItem>{
                new LabelValueItem('None', null)
        };
        Map<String, List<LabelValueItem>> statesByCountryMap;
        Map<String, String> countriesMap;
        Map<String, String> countryCodesMap;
        
        public PIInitData(){
            piStudiesFilter = new PIStudiesFilter();
            paginationData = new PaginationData();
            currentPITrials = new List<StudyDetailItem>();
        }
        
        public PIInitData(PIStudiesFilter.FilterData filterData, PIStudiesFilter.SortData sortData,  PaginationData paginationData){
            piStudiesFilter = new PIStudiesFilter(filterData, sortData);
            this.paginationData = paginationData;
            currentPITrials = new List<StudyDetailItem>();
        }
    }
    
    
    @AuraEnabled
    public static String getStudyTrialList(String userMode){
        return getStudyTrialList(userMode, null);
    }
    
    @AuraEnabled
    public static String getStudyTrialList(String userMode, String delegateId) {
        try {
            InitData initData = new InitData();
            List<StudyDetailItem> studies;
            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
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
        return searchStudies(filterData, sortData, paginationData, isSearchResume, null);
    }
    
    @AuraEnabled
    public static String searchStudies(String filterData, String sortData, String paginationData, Boolean isSearchResume, String delegateId) {
        try {
            String studiesJSON = StudyTrialService.getStudiesJSON(filterData, sortData, paginationData, isSearchResume, delegateId);
            return studiesJSON;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String searchStudiesPI(String filterDataJSON, String sortDataJSON, String paginationDataJSON) {
        try {
            PIStudiesFilter.FilterData filterData = (PIStudiesFilter.FilterData) JSON.deserialize(filterDataJSON, PIStudiesFilter.FilterData.class);
            PIStudiesFilter.SortData sortData = (PIStudiesFilter.SortData) JSON.deserialize(sortDataJSON, PIStudiesFilter.SortData.class);
            PaginationData paginationData = (PaginationData) JSON.deserialize(paginationDataJSON, PaginationData.class);
            PIInitData initDataInstance = new PIInitData(filterData, sortData, paginationData);
            getStudiesForPI(initDataInstance);
            Contact updateUserContact = new Contact();
            updateUserContact.Id = CommunityService.getUserContact().Id;
            filterData.save();
            update updateUserContact;
            return JSON.serialize(initDataInstance);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }


    @AuraEnabled
    public static String getHCPInitData(String delegateId) {
        try {
            HCPInitData initData = new HCPInitData();
            
            //pagination:
            initData.paginationData = StudyTrialService.getPaginationData();
            
            //sort data:
            initData.sortData = StudyTrialService.getStudySortDataForHCP();
            
            //filters data:
            initData.filterData = StudyTrialService.getStudyFilterData();
            
            //records for current filter, sort and pagination:
            System.debug('DELEGATEID getHCPInitData:'+delegateId);
            initData.currentPageList = StudyTrialService.getStudies(initData.filterData, initData.sortData, initData.paginationData, delegateId);
            System.debug('CURRENT PAGE LIST:' + initData.currentPageList);
            // refresh filter data with TA options list
            initData.filterData = StudyTrialService.getStudyFilterData();
            
            initData.delegateAccessLevel = CommunityService.getInstance().getUserAccessLevel(delegateId);
            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPIInitData(String communityName) {
        try {
            PIInitData initData = new PIInitData();
            initData.piStudiesFilter.filterData.communityName = communityName;
            getStudiesForPI(initData);
            initData.countries.addAll(CountryStateUtil.getCountries());
            initData.statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
            initData.countriesMap = CountryStateUtil.COUNTRY_MAP;
            initData.countryCodesMap = CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP;

            return JSON.serialize(initData);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    
//    public static List<StudyDetailItem> getStudiesForHCP(String delegateId) {
//        // prepare map trialId -> HCPEnrollment:
//        Map<Id, HCP_Enrollment__c> trialHCPEnrollmentMap = new Map<Id, HCP_Enrollment__c>();
//        for (HCP_Enrollment__c enrollment : HCPEnrollmentService.getHCPEnrollmentsForHCP(delegateId)) {
//            trialHCPEnrollmentMap.put(enrollment.Study_Site__r.Clinical_Trial_Profile__c, enrollment);
//        }
//
//        // get trials with fields and TC:
//        List<Clinical_Trial_Profile__c> trials = StudyTrialService.getTrials(trialHCPEnrollmentMap.keySet());
//        //prepare list of studies:
//        List<StudyDetailItem> studies = new List<StudyDetailItem>();
//        for (Clinical_Trial_Profile__c trial : trials) {
//            HCP_Enrollment__c hcpe = trialHCPEnrollmentMap.get(trial.Id);
//            StudyDetailItem studyDetailItem = new StudyDetailItem();
//            studyDetailItem.hcpe = hcpe;
//            studyDetailItem.trial = trial;
//            studyDetailItem.studyStatus = hcpe.Status__c;
//            studyDetailItem.studyActions = new StudyActionsHCP(hcpe, delegateId).studyListViewItemActions;
//            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
//            studies.add(studyDetailItem);
//        }
//        return studies;
//    }
    
    public static void getStudiesForPI(PIInitData initData) {
        // prepare map trialId -> StudySite
        Map<Id, List<Study_Site__c>> trialStudySiteMap = new Map<Id, List<Study_Site__c>>();
        List<Clinical_Trial_Profile__c> piTrials = SearchService.search(initData.piStudiesFilter,initData.paginationData );
        System.debug('piTRIALS'+ piTrials);
        List<Study_Site__c> piStudySites = new List<Study_Site__c>();
        Set<Id> ssIds = new Set<Id>();
        for(Clinical_Trial_Profile__c trial : piTrials){
            piStudySites.addAll(trial.Study_Site_Profiles__r);
            for(Study_Site__c site: trial.Study_Site_Profiles__r){
                ssIds.add(site.Id);
            }
        }
        Map<Id,Map<Id,Account>> piAccounts = getPiAccounts(piStudySites);
        Set<Id> siteContactIds = new Set<Id>();
        Map<String, List<Site_Staff__c>> delegatesMap = getDelegates(ssIds, siteContactIds);
        Map<Id, String> participantFullnameMap = getParticipantFullnameMap(siteContactIds);
        Map<String, List<LabelValueItem>> delegatesPicklistMap = convertDelegatesToLabelValue(delegatesMap, participantFullnameMap);
        // prepare result list:
        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : piTrials) {
            List<Study_Site__c> ss = trial.Study_Site_Profiles__r;
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            TranslateHelper.translate(trial);
            studyDetailItem.trial = trial;
            Map<String, Study_Site__c> statusMap = new Map<String, Study_Site__c>();
            for (Integer i = 0; i < ss.size(); i++) {
                if(ss[i].Study_Site_Type__c != null) {
                    ss[i].Study_Site_Type__c = TranslateHelper.getPickListLabel(Study_Site__c.Study_Site_Type__c, ss[i].Study_Site_Type__c);
                }
                StudyDetailItem.StudySiteWithActions ssWrapper = new StudyDetailItem.StudySiteWithActions(ss[i], new StudyActionsPI(ss[i]).studySitePiActions, piAccounts.get(ss[i].Principal_Investigator__c).values());
                ssWrapper.delegatePicklist = delegatesPicklistMap.get(ss[i].Id);
                studyDetailItem.ssList.add(ssWrapper);
            }
            if(ss!=null && ss.size()>0)
                studyDetailItem.studyActions = new StudyActionsPI(ss[0]).studyListViewItemActions;
            else
                studyDetailItem.studyActions = new List<StudyActions.Action>();
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            studies.add(studyDetailItem);
        }
        initData.currentPITrials = studies;
    }
    
//    public static void groupTrials(InitData initData, List<StudyDetailItem> allStudies, String userMode) {
////        StudiesGroup activated = new StudiesGroup(userMode == CommunityService.USER_MODE_PI ? Label.SGT_Accepted_and_active : Label.SGT_Activated);
////        StudiesGroup pendingStudySiteAction = new StudiesGroup(Label.SGT_Pending_Study_Site_s_Action);
////        StudiesGroup onHold = new StudiesGroup(Label.SGT_On_hold);
////        StudiesGroup pendingYourAction = new StudiesGroup(Label.SGT_Pending_Your_Action);
////        StudiesGroup declined = new StudiesGroup(Label.SGT_Declined_Acceptance);
////        StudiesGroup declinedOther = new StudiesGroup(Label.SGT_Declined_by_Others);
////        StudiesGroup deactivated = new StudiesGroup(Label.SGT_Deactivated);
//        for (StudyDetailItem item : allStudies) {
//            TranslateHelper.translate(item.trial);
//            if (item.trial.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING) {
//                initData.trialsNoLongerRecruiting.add(item);
//            } else {
//                initData.currentlyRecruitingTrials.add(item);
//            }
//        }
//        StudyDetailItem.sortType = 'Name';
//        initData.currentlyRecruitingTrials.sort();
//        initData.trialsNoLongerRecruiting.sort();
//    }

    @AuraEnabled
    public static void changeSSAccount(Id ssId, Id accountId) {
        try {
            update new Study_Site__c(Id = ssId, Site__c = accountId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveSSChanges(String studySiteInfo) {
        try {
            update (Study_Site__c) JSON.deserialize(studySiteInfo, Study_Site__c.class);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    private static Map<String, List<Site_Staff__c>> getDelegates(Set<Id> ssIds, Set<Id> outSiteContactIds) {
        Map<String, List<Site_Staff__c>> delegatesMap = new Map<String, List<Site_Staff__c>>();
        for (Site_Staff__c ss : [
                SELECT Id,
                        Study_Site__r.Principal_Investigator__c,
                        Study_Site__c,
                        Site_Contact__r.Name,
                        Site_Contact__c
                FROM Site_Staff__c
                WHERE Study_Site__c IN :ssIds
        ]) {
            if (delegatesMap.containsKey(ss.Study_Site__c)) {
                delegatesMap.get(ss.Study_Site__c).add(ss);
            } else {
                delegatesMap.put(ss.Study_Site__c, new List<Site_Staff__c>{ss});
            }
            outSiteContactIds.add(ss.Site_Contact__c);
        }
        return delegatesMap;
    }

    private static  Map<Id, String> getParticipantFullnameMap(Set<Id> delegateContactIds){

        List<Participant__c> participantDelegates = [
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
                WHERE Contact__c IN :delegateContactIds
        ];
        Map<Id, String> participantDelegateNames = new Map<Id, String>();
        for(Participant__c partDelegate : participantDelegates){
            participantDelegateNames.put(partDelegate.Contact__c, partDelegate.First_Name__c + ' ' + partDelegate.Last_Name__c);
        }
        return participantDelegateNames;
    }

    private static Map<String, List<LabelValueItem>> convertDelegatesToLabelValue(Map<String,List<Site_Staff__c>> delegateMap, Map<Id, String> participantFullnameMap){
        Map<String, List<LabelValueItem>> resultMap = new Map<String, List<LabelValueItem>>();
        for(String ssId : delegateMap.keySet()){
            resultMap.put(ssId,getDelegatePickList(delegateMap.get(ssId),participantFullnameMap));
        }
        return resultMap;
    }

    private static List<LabelValueItem> getDelegatePickList(List<Site_Staff__c> ss, Map<Id, String> participantFullnameMap) {
        Map<Id, LabelValueItem> delegates = new Map<Id, LabelValueItem>();
        try {
            if (!ss.isEmpty()) {
                for (Site_Staff__c delegatesSites : ss) {
                    if(participantFullnameMap.containsKey(delegatesSites.Site_Contact__c)){
                        delegates.put(delegatesSites.Site_Contact__c, new LabelValueItem(participantFullnameMap.get(delegatesSites.Site_Contact__c), delegatesSites.Id));
                    }
                    else{
                        delegates.put(delegatesSites.Site_Contact__c, new LabelValueItem(delegatesSites.Site_Contact__r.Name, delegatesSites.Id));
                    }

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

    private static Map<Id, Map<Id, Account>> getPiAccounts(List<Study_Site__c> studies) {
        try {
            Map<Id, Id> piIdsWithAccounts = new Map<Id,Id>();
            for (Integer i = 0; i < studies.size(); i++) {
                piIdsWithAccounts.put(studies[i].Principal_Investigator__c,studies[i].Principal_Investigator__r.AccountId);
            }
            Map<Id, Map<Id, Account>> accountMap = new Map<Id, Map<Id, Account>>();
            if (!piIdsWithAccounts.isEmpty()) {
                for (AccountContactRelation piAccounts : [
                        SELECT Id,
                                Contact.Id,
                                Contact.Name,
                                Contact.primaryContact__c,
                                Account.Id,
                                Account.Name,
                                Account.ParentId,
                                Account.BillingCountry,
                                Account.BillingCountryCode,
                                Account.BillingCity,
                                Account.BillingStreet,
                                Account.BillingPostalCode,
                                Account.BillingState,
                                Account.BillingStateCode,
                                Account.BillingGeocodeAccuracy,
                                Account.Driving_Directions__c,
                                Account.Parking_Instructions__c,
                                Account.BillingLatitude,
                                Account.BillingLongitude,
                                Account.OwnerId
                        FROM AccountContactRelation
                        WHERE ContactId IN :piIdsWithAccounts.keySet()
                ]) {
                    if (accountMap.containsKey(piAccounts.Contact.Id)) {
                        accountMap.get(piAccounts.Contact.Id).put(piAccounts.Account.Id,piAccounts.Account);
                    } else {
                        accountMap.put(piAccounts.Contact.Id, new Map<Id, Account>{piAccounts.Account.Id => piAccounts.Account});
                    }
                }
                for(Id piId : piIdsWithAccounts.keySet()){
                    Map<Id, Account> piAccs = accountMap.get(piId);
                    for(Account acc : piAccs.values()){
                        if(acc.ParentId == piIdsWithAccounts.get(piId)){
                            piAccs.remove(piIdsWithAccounts.get(piId));
                        }
                    }
                    accountMap.put(piId,piAccs);
                }

                for (Integer i = 0; i < studies.size(); i++) {
                    if (!studies[i].Account_Was_Changed__c) {
                        if (accountMap.containsKey(studies[i].Principal_Investigator__c)) {
                            Map<Id, Account> accMap = accountMap.get(studies[i].Principal_Investigator__c);
                            accMap.put(studies[i].Site__c, studies[i].Site__r);
                        } else {
                            accountMap.put(studies[i].Principal_Investigator__c, new Map<Id, Account>{
                                    studies[i].Site__c => studies[i].Site__r
                            });
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