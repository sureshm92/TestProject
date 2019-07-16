/**
 * Created by Denis Z on 08-Jul-19.
 */

public without sharing class ParticipantEnrollmentFactory {

    //1st Study_ID__c/ClinicaТl_Trial_Profile__r.Protocol_ID__c
    //2nd Study_Site__r.Study_Site_Number__c
    //3rd Screening ID - startValue, endValue

    public static void createParticipantEnrollmentRecords(String protocolId, String siteNumber, String screeningId){
        Clinical_Trial_Profile__c ctp = getClinicalTrialProfile(protocolId);
        createParticipantEnrollment(ctp, getStudySite(siteNumber, ctp), screeningId);
    }

    private static void createParticipantEnrollment(Clinical_Trial_Profile__c ctp, Study_Site__c studySite, String screeningId){
        Contact contact = new Contact();
        contact.LastName = screeningId;
        contact.Email = 'dz@hp.com';
        contact.AccountId = [SELECT Id FROM Account WHERE Name =: CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME].Id;
        insert contact;
        Participant__c participant = new Participant__c();
        participant.Contact__c = contact.Id;
        participant.Mailing_Country_Code__c = 'US';
        participant.Mailing_Country__c = 'United States';
        insert participant;
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.Clinical_Trial_Profile__c = ctp.Id;
        pe.Study_Site__c = studySite.Id;
        pe.Screening_ID__c =screeningId;
        pe.Participant__c = participant.Id;
        pe.Participant_Status__c  = 'Enrollment Success';
        insert pe;
        pe.Participant_Status__c  = 'Referral Sent to PI';
        update pe;
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
        ctp.Participating_in_Patient_Portal__c = 'Yes';
        insert ctp;
        return ctp;
    }

    private static Study_Site__c getStudySite(String siteNumber, Clinical_Trial_Profile__c ctp){
        List<Study_Site__c> siteList = [
                SELECT
                        Id,
                        Study_Site_Number__c
                FROM    Study_Site__c
                WHERE   Study_Site_Number__c = : siteNumber
        ];
        if(siteList.isEmpty()){
            return createStudySite(siteNumber, ctp);
        }
        return siteList[0];
    }

    private static Study_Site__c createStudySite(String siteNumber, Clinical_Trial_Profile__c ctp){
        Study_Site__c study = new Study_Site__c();
        study.Study_Site_Number__c = siteNumber;
        study.Site__c = getSite().Id;
        study.Clinical_Trial_Profile__c = ctp.Id;
        study.Principal_Investigator__c = createPI().Id;
        insert study;
        return study;
    }

    private static Contact createPI(){
        Contact pi = new Contact();
        pi.LastName = 'New Pi';
        pi.Email = 'dz@hp.com';
        insert pi;
        return pi;
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