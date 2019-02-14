/**
 * Created by D.Yasinskyi on 14.02.2018
 */
public without sharing class StudyListViewController {
    
    class StudyDetailItem {
        Clinical_Trial_Profile__c trial;
        List<StudyActions.Action> studyActions;
        String studyStatus;
        Study_Site__c ss;
        HCP_Enrollment__c hcpe;
        List<StudyTotalPassed> statistics = new List<StudyTotalPassed>();
        String trialRecruitmentStatusLabel;
    }
    
    class StudiesGroup{
        String name;
        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        
        StudiesGroup(String name){
            this.name = name;
        }
    }
    
    class InitData{
        List<StudyDetailItem> trialsNoLongerRecruiting = new List<StudyDetailItem>();
        List<StudiesGroup> currentlyRecruitingTrials = new List<StudiesGroup>();
        Map<String, PEStatusState> peStatusStateMap = PEStatusState.STATUSES_MAP;
        List<String> peStatusesPathList = PEStatusState.STATUS_STEPS_LIST;
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__c> peListNoLongerRecr = new List<Participant_Enrollment__c>();
    }
    
    @AuraEnabled
    public static String getStudyTrialList(String userMode) {
        try{
            InitData initData = new InitData();
            List<StudyDetailItem> studies;
            if (userMode == CommunityService.USER_MODE_HCP) {
                studies = getStudiesForHCP();
                groupTrials(initData, studies, userMode);
            } else if (userMode == CommunityService.USER_MODE_PI) {
                studies = getStudiesForPI();
                groupTrials(initData, studies, userMode);
                loadStatistics(studies);
            } else if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                Participant_Enrollment__c[] peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
                for(Participant_Enrollment__c pe : peList){
                    if(pe.Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING){
                        initData.peListNoLongerRecr.add(pe);
                    }else{
                        initData.peList.add(pe);
                    }
                }
            }
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static List<StudyDetailItem> getStudiesForHCP() {
        // prepare map trialId -> HCPEnrollment:
        Map<Id, HCP_Enrollment__c> trialHCPEnrollmentMap = new Map<Id, HCP_Enrollment__c>();
        for(HCP_Enrollment__c enrollment : HCPEnrollmentService.getHCPEnrollmentsForHCP()){
            trialHCPEnrollmentMap.put(enrollment.Study_Site__r.Clinical_Trial_Profile__c, enrollment);
        }
        // get trials with fields and TC:
        List<Clinical_Trial_Profile__c> trials = SudyTrialService.getTrials(trialHCPEnrollmentMap.keySet());
        Map<Id, Boolean> termsAcceptedMap = TermsAndConditions.getTrialsAcceptanceMap(trials);
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
        Map<Id, Study_Site__c> trialStudySiteMap = new Map<Id, Study_Site__c>();
        for (Study_Site__c studySite : StudySiteService.getStudySitesForPI()) {
            trialStudySiteMap.put(studySite.Clinical_Trial_Profile__c, studySite);
        }
        // get trials and TC:
        List<Clinical_Trial_Profile__c> trials = SudyTrialService.getTrials(trialStudySiteMap.keySet());
        Map<Id, Boolean> termsAcceptedMap;
        termsAcceptedMap = TermsAndConditions.getTrialsAcceptanceMap(trials);
        // prepare result list:
        List<StudyDetailItem> studies = new List<StudyDetailItem>();
        for (Clinical_Trial_Profile__c trial : trials) {
            Study_Site__c ss = trialStudySiteMap.get(trial.Id);
            StudyDetailItem studyDetailItem = new StudyDetailItem();
            studyDetailItem.trial = trial;
            studyDetailItem.studyStatus = ss.Override_PI_Referral_Status__c;
            studyDetailItem.ss = ss;

            studyDetailItem.studyActions = new StudyActionsPI(trialStudySiteMap.get(trial.Id)).studyListViewItemActions;
            studyDetailItem.trialRecruitmentStatusLabel = TranslateHelper.getPickListLabel(Clinical_Trial_Profile__c.Override_Recruitment_Status__c, trial.Override_Recruitment_Status__c);
            studies.add(studyDetailItem);
        }
        return studies;
    }
    
    public static void groupTrials(InitData initData, List<StudyDetailItem> allStudies, String userMode){
        StudiesGroup activated = new StudiesGroup(userMode == CommunityService.USER_MODE_PI ? Label.SGT_Accepted_and_active : Label.SGT_Activated);
        StudiesGroup pendingStudySiteAction = new StudiesGroup(Label.SGT_Pending_Study_Site_s_Action);
        StudiesGroup onHold = new StudiesGroup(Label.SGT_On_hold);
        StudiesGroup pendingYourAction = new StudiesGroup(Label.SGT_Pending_Your_Action);
        StudiesGroup declined = new StudiesGroup(Label.SGT_Declined_Acceptance);
        StudiesGroup declinedOther = new StudiesGroup(Label.SGT_Declined_by_Others);
        StudiesGroup deactivated = new StudiesGroup(Label.SGT_Deactivated);
        for(StudyDetailItem item : allStudies){
            TranslateHelper.translate(item.trial);
            if(item.trial.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING){
                initData.trialsNoLongerRecruiting.add(item);
            }else if (item.studyStatus.startsWith('Activated') || item.studyStatus.startsWith('Accepted')){
                activated.studies.add(item);
            }else if(item.studyStatus == StudySiteService.PI_S_INVITATION_SENT){
                pendingYourAction.studies.add(item);
            }else if(item.studyStatus.contains('Pending')){
                pendingStudySiteAction.studies.add(item);
            }else if(item.studyStatus.startsWith('On Hold')){
                onHold.studies.add(item);
            }else if(item.studyStatus == 'Declined (Acceptance)' || item.studyStatus == 'Non-Responsive (Admin)'){
                declined.studies.add(item);
            }else if(item.studyStatus.contains('Declined')){
                declinedOther.studies.add(item);
            }else if(item.studyStatus == 'Deactivated (Admin)'){
                deactivated.studies.add(item);
            }
        }
        if(activated.studies.size() > 0) initData.currentlyRecruitingTrials.add(activated);
        if(pendingYourAction.studies.size() > 0) initData.currentlyRecruitingTrials.add(pendingYourAction);
        if(pendingStudySiteAction.studies.size() > 0) initData.currentlyRecruitingTrials.add(pendingStudySiteAction);
        if(onHold.studies.size() > 0) initData.currentlyRecruitingTrials.add(onHold);
        if(declined.studies.size() > 0) initData.currentlyRecruitingTrials.add(declined);
        if(declinedOther.studies.size() > 0) initData.currentlyRecruitingTrials.add(declinedOther);
        if(deactivated.studies.size() > 0) initData.currentlyRecruitingTrials.add(deactivated);
    }
    
    
    public static void loadStatistics(List<StudyDetailItem> studies){
        Map<Id, Integer> referredCountMap = ParticipantEnrollmentService.getReferredByTrial();
        String allReviewedFilter = ' AND Participant_Status__c IN (\'' + String.join(new List<String>(PEStatusState.ALL_USED_STATUSES_WITH_REFERRING), '\',\'') + '\') ';
        Map<Id, Integer> allCountMap = ParticipantEnrollmentService.getPECountMapByTrialsForPI(allReviewedFilter);
        for(StudyDetailItem item : studies){
            item.statistics.add(new StudyTotalPassed('all',
                    allCountMap.get(item.trial.Id),
                    referredCountMap.get(item.trial.Id)
            ));
        }
    }
    
}