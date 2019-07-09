/**
 * Created by Denis Z on 08-Jul-19.
 */

public without sharing class ParticipantEnrollmentFactory {

    //1st Study_ID__c/ClinicaТl_Trial_Profile__r.Protocol_ID__c
    //2nd Study_Site__r.Study_Site_Number__c
    //3rd Screening ID - startValue, endValue

    public static void createParticipantEnrollmentRecords(String protocolId, Integer siteNumber, Integer startValue, Integer endValue){
        Clinical_Trial_Profile__c ctp = getClinicalTrialProfile(protocolId);
        createParticipantEnrollment(ctp, getStudySite(siteNumber, ctp), startValue, endValue);
    }

    public static void createParticipantStudyEnrollmentRecords(String protocolId, Integer siteNumber, Integer startValue, Integer endValue){
        Clinical_Trial_Profile__c ctp = getClinicalTrialProfile(protocolId);
        createParticipantStrudyEnrollment(ctp, getStudySite(siteNumber, ctp), startValue, endValue);
    }

    private static void createParticipantEnrollment(Clinical_Trial_Profile__c ctp, Study_Site__c studySite, Integer startValue, Integer endValue){
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(; startValue <= endValue; startValue++){
            Participant_Enrollment__c pe = new Participant_Enrollment__c();
            pe.Clinical_Trial_Profile__c = ctp.Id;
            pe.Study_Site__c = studySite.Id;
            pe.Screening_ID__c = '' + startValue;
            peList.add(pe);
        }
        insert peList;
    }

    private static void createParticipantStrudyEnrollment(Clinical_Trial_Profile__c ctp, Study_Site__c studySite, Integer startValue, Integer endValue){
        List<Participant_Study_Enrollment__c> pseList = new List<Participant_Study_Enrollment__c>();
        TestData.loadTestData();
        Participant__c participant = getParticipant();
        for(; startValue <= endValue; startValue++){
            Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c();
            pse.Clinical_Trial_Profile__c = ctp.Id;
            pse.Study_Site__c = studySite.Id;
            pse.Screening_ID__c = '' + startValue;
            pse.Participant__c = participant.Id;
            pse.Participant_Enrollment__c = getPE().Id;
            pseList.add(pse);
        }
        insert pseList;
    }

    private static Participant_Enrollment__c getPE(){
        List<Participant_Enrollment__c> pes = [
                SELECT  Id
                FROM    Participant_Enrollment__c
                LIMIT   1
        ];
        return pes[0];
    }

    private static Participant__c getParticipant(){
        List<Participant__c> participants = [
                SELECT
                        Id,
                        Name
                FROM    Participant__c
        ];
        if(participants.isEmpty()){
            return createParticipant();
        }
        return participants[0];
    }

    private static Participant__c createParticipant(){
        Participant__c participant = new Participant__c();
        insert participant;
        return participant;
    }

    private static Clinical_Trial_Profile__c getClinicalTrialProfile(String protocolId){
        List<Clinical_Trial_Profile__c> ctpList = [
                SELECT
                        Id,
                        Protocol_ID__c
                FROM    Clinical_Trial_Profile__c
                WHERE   Protocol_ID__c = : protocolId
        ];
        if(ctpList.isEmpty()){
            return createClinicalTrialProfile(protocolId);
        }
        return ctpList[0];
    }

    private static Clinical_Trial_Profile__c createClinicalTrialProfile(String protocolId){
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp.Protocol_ID__c = protocolId;
        insert ctp;
        return ctp;
    }

    private static Study_Site__c getStudySite(Integer siteNumber, Clinical_Trial_Profile__c ctp){
        List<Study_Site__c> siteList = [
                SELECT
                        Id,
                        Study_Site_Number__c
                FROM    Study_Site__c
                WHERE   Study_Site_Number__c = : String.valueOf(siteNumber)
        ];
        if(siteList.isEmpty()){
            return createStudySite(siteNumber, ctp);
        }
        return siteList[0];
    }

    private static Study_Site__c createStudySite(Integer siteNumber, Clinical_Trial_Profile__c ctp){
        Study_Site__c study = new Study_Site__c();
        study.Study_Site_Number__c = '' + siteNumber;
        study.Site__c = getSite().Id;
        study.Clinical_Trial_Profile__c = ctp.Id;
        insert study;
        return study;
    }


    private static Account getSite(){
        List<Account> accounts = [
                SELECT
                        Id,
                        Name
                FROM    Account
                WHERE   Name = : 'Study'
        ];
        if(accounts.isEmpty()){
            return createSite();
        }
        return accounts[0];
    }

    private static Account createSite(){
        Account acc = new Account();
        acc.Name = 'Study';
        insert acc;
        return acc;
    }


}