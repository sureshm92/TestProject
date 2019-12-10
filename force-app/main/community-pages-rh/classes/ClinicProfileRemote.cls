/**
 * Created by Leonid Bartenev
 */

public without sharing class ClinicProfileRemote {

    class InitData{
        Account clinic;
        List<StudySiteDetail> myStudies = new List<StudySiteDetail>();
        List<String> physicians;
    }
    
    class StudySiteDetail{
        Study_Site__c studySite;
        List<HCP_Enrollment__c> hcpEnrollments = new List<HCP_Enrollment__c>();
        List<StudyTotalPassed> statistics = new List<StudyTotalPassed>();
    }


    @AuraEnabled
    public static String getClinicProfileData(String clinicId){
        
        InitData initData = new InitData();
        initData.clinic = [
                SELECT Id, Name, BillingAddress, ShippingAddress, Fax, Phone
                FROM Account
                WHERE Id =: clinicId
        ];

        List<Study_Site__c> studySites = StudySiteService.getStudySitesForPI();
        List<HCP_Enrollment__c> hcpeList = HCPEnrollmentService.getHCPEnrollmentsForPI();
        Map<Id, List<HCP_Enrollment__c>> hcpeListByStudyIdMap = new Map<Id, List<HCP_Enrollment__c>>();
        for(HCP_Enrollment__c hcpe : hcpeList){
            List<HCP_Enrollment__c> studyHCPEList = hcpeListByStudyIdMap.get(hcpe.Study_Site__c);
            if(studyHCPEList == null) studyHCPEList = new List<HCP_Enrollment__c>();
            studyHCPEList.add(hcpe);
            hcpeListByStudyIdMap.put(hcpe.Study_Site__c, studyHCPEList);
        }

        Map<Id, Integer> preScreeningAllMap = ParticipantEnrollmentService.getPreScreeningsAllByTrial(clinicId);
        Map<Id, Integer> preScreeningPassedMap = ParticipantEnrollmentService.getPreScreeningsPassedByTrial(clinicId);
        Map<Id, Integer> mrrAlldMap = ParticipantEnrollmentService.getMRRAllByTrial(clinicId);
        Map<Id, Integer> mrrPasseddMap = ParticipantEnrollmentService.getMRRPassedByTrial(clinicId);
    
    
        Set<String> names = new Set<String>();
        for(Study_Site__c studySite : studySites) {
            List<HCP_Enrollment__c> studyHCPEList = hcpeListByStudyIdMap.get(studySite.Id);
            if(studyHCPEList != null && studyHCPEList.size() > 0) {
                StudySiteDetail ssd = new StudySiteDetail();
                ssd.hcpEnrollments = studyHCPEList;
                for(HCP_Enrollment__c enrollment : studyHCPEList) names.add(enrollment.HCP_Contact__r.Name);
                ssd.studySite = studySite;
                // if pre screening available:
                if(studySite.Clinical_Trial_Profile__r.Link_to_Pre_screening__c != null){
                    Integer preScreenigAll = preScreeningAllMap.get(studySite.Clinical_Trial_Profile__c);
                    Integer preScreenigPassed = preScreeningPassedMap.get(studySite.Clinical_Trial_Profile__c);
                    ssd.statistics.add(new StudyTotalPassed('pre-screening', preScreenigAll, preScreenigPassed));
                }
                // if mrr available
                if(studySite.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c != null){
                    Integer mrrAll = mrrAlldMap.get(studySite.Clinical_Trial_Profile__c);
                    Integer mrrPassed = mrrPasseddMap.get(studySite.Clinical_Trial_Profile__c);
                    ssd.statistics.add(new StudyTotalPassed('mrr', mrrAll, mrrPassed));
                }
                initData.myStudies.add(ssd);
            }
        }

        initData.physicians = new List<String>();
        initData.physicians.addAll(names);
        initData.physicians.sort();

        return JSON.serialize(initData);
    }

}