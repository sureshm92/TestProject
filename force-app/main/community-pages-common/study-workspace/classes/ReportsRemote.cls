/**
 * Created by Leonid Bartenev
 */

public without sharing class ReportsRemote {
    class InitData {
        ReportsFilterData filterData;
        Analitics analitics;
    }

    public class Analitics {
        List<DonutItem> mrrPassedFailed = new List<DonutItem>();
        List<DonutItem> preScreeningPassedFailed = new List<DonutItem>();
        List<DonutItem> studyOrientationAttVsNotAtt = new List<DonutItem>();
    }

    class ReportsFilterData {
        List<LabelValueItem> studies;
        List<LabelValueItem> studySites;
        List<LabelValueItem> referringClinics;
        List<LabelValueItem> dateRanges = DateRangeFilterData.getRanges();
    }

    @AuraEnabled
    public static String getInitData(String trialId, String userMode, String delegateId) {
        try {
            Id userContactId = CommunityService.getUserContact().Id;

            ReportsFilterData reportsFilterData = new ReportsFilterData();
            Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(
                TrialService.getAvailableTrials(userMode, delegateId)
            );
            //init trials
            reportsFilterData.studies = new List<LabelValueItem>();
            reportsFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
            for (String id : trialsMap.keySet()) {
                Clinical_Trial_Profile__c trial = trialsMap.get(id);
                reportsFilterData.studies.add(
                    new LabelValueItem(trial.Study_Code_Name__c, trial.Id)
                );
            }

            List<Id> trialIds;
            if (trialId != null) {
                trialIds = new List<Id>{ trialId };
            } else {
                trialIds = new List<Id>(trialsMap.keySet());
            }

            //init study sites:
            reportsFilterData.studySites = new List<LabelValueItem>();
            reportsFilterData.studySites.add(
                new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
            );
            if (userMode == CommunityService.USER_MODE_HCP) {
                List<Study_Site__c> studySites = StudySiteService.getStudySitesForHCP(
                    trialIds,
                    delegateId
                );
                for (Study_Site__c ss : studySites)
                    reportsFilterData.studySites.add(new LabelValueItem(ss.Name, ss.Id));
            }

            //init referring clinics
            reportsFilterData.referringClinics = new List<LabelValueItem>();
            reportsFilterData.referringClinics.add(
                new LabelValueItem(Label.PG_Report_L_All_referring_clinics, null)
            );
            for (Account clinic : HCPEnrollmentService.getReferringClinics(trialIds)) {
                reportsFilterData.referringClinics.add(new LabelValueItem(clinic.Name, clinic.Id));
            }

            InitData initData = new InitData();
            initData.filterData = reportsFilterData;
            initData.analitics = getAnaliticsData(trialId, null, null, null, userMode, delegateId);
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String getAnaliticsJSON(
        String studyId,
        String studySiteId,
        String referringClinicId,
        String dateRange,
        String userMode,
        String delegateId
    ) {
        try {
            return JSON.serialize(
                getAnaliticsData(
                    studyId,
                    studySiteId,
                    referringClinicId,
                    dateRange,
                    userMode,
                    delegateId
                )
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static Analitics getAnaliticsData(
        String studyId,
        String studySiteId,
        String referringClinicId,
        String dateRange,
        String userMode,
        String delegateId
    ) {
        String filter = '';
        String filterHCPE = '';
        if (studyId != null)
            studyId = studyId.trim();
        if (!String.isEmpty(studyId)) {
            filter += ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + studyId + '\'';
            filterHCPE += ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + studyId + '\'';
        }
        if (!String.isEmpty(studySiteId)) {
            filter += ' AND Study_Site__c=\'' + studySiteId + '\'';
            filterHCPE += ' AND Study_Site__c=\'' + studySiteId + '\'';
        }
        if (!String.isEmpty(referringClinicId)) {
            filter += ' AND HCP__R.HCP_Contact__r.AccountId=\'' + referringClinicId + '\'';
            filterHCPE += ' AND HCP_Contact__r.AccountId=\'' + referringClinicId + '\'';
        }
        if (!String.isEmpty(dateRange)) {
            filter += ' AND CreatedDate ' + dateRange;
            filterHCPE += ' AND CreatedDate ' + dateRange;
        }
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getPEnrolmentsCommon(
            userMode,
            filter,
            delegateId
        );

        Integer mrrPassed = 0;
        Integer mrrFailed = 0;
        Integer preScreeningPassed = 0;
        Integer preScreeningFailed = 0;
        Integer orAttended = 0;
        Integer orNoAttended = 0;

        System.debug('REC count: ' + peList.size());

       for(Participant_PrescreenerResponse__c screenerRes : [
            SELECT Id, MRR__c, Prescreener__c, Status__c, Participant_enrollment__c
            FROM  Participant_PrescreenerResponse__c
            WHERE Participant_enrollment__c IN :peList 
                AND (MRR__c = true OR Prescreener__c = true)
        ]) {

            if (screenerRes.MRR__c == true && screenerRes.Status__c == ParticipantEnrollmentService.MRR_STATUS_PASS)
                mrrPassed++;
            if (screenerRes.MRR__c == true && screenerRes.Status__c == ParticipantEnrollmentService.MRR_STATUS_FAIL)
                mrrFailed++;
            if (screenerRes.Prescreener__c == true && screenerRes.Status__c == ParticipantEnrollmentService.PES_STATUS_PASS)
                preScreeningPassed++;
            if (screenerRes.Prescreener__c == true && screenerRes.Status__c == ParticipantEnrollmentService.PES_STATUS_FAIL)
                preScreeningFailed++;
        }

        Analitics analitics = new Analitics();
        analitics.mrrPassedFailed.addAll(
            new List<DonutItem>{
                new DonutItem(Label.PG_MRR_R_Passed, mrrPassed, DonutItem.Type.SUCCSESS),
                new DonutItem(Label.PG_MRR_R_Failed, mrrFailed, DonutItem.Type.DECLINED)
            }
        );
        analitics.preScreeningPassedFailed.addAll(
            new List<DonutItem>{
                new DonutItem(Label.PG_PrS_R_Passed, preScreeningPassed, DonutItem.Type.SUCCSESS),
                new DonutItem(Label.PG_PrS_R_Failed, preScreeningFailed, DonutItem.Type.DECLINED)
            }
        );
        analitics.studyOrientationAttVsNotAtt.addAll(
            new List<DonutItem>{
                new DonutItem(
                    Label.PG_Or_R_Attended,
                    HCPEnrollmentService.getAttendedRequiredCount(
                        userMode,
                        delegateId,
                        true,
                        filterHCPE
                    ),
                    DonutItem.Type.SUCCSESS
                ),
                new DonutItem(
                    Label.PG_Or_R_Not_attended,
                    HCPEnrollmentService.getAttendedRequiredCount(
                        userMode,
                        delegateId,
                        false,
                        filterHCPE
                    ),
                    DonutItem.Type.DECLINED
                )
            }
        );

        return analitics;
    }
}
