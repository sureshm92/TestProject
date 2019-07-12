/**
 * Created by Denis Z on 08-Jul-19.
 */

public without sharing class ParticipantEnrollmentFactory {

    //1st Study_ID__c/ClinicaТl_Trial_Profile__r.Protocol_ID__c
    //2nd Study_Site__r.Study_Site_Number__c
    //3rd Screening ID - startValue, endValue

    public static void createParticipantEnrollmentRecords(String protocolId, Integer siteNumber, Integer startValue, Integer endValue){
        System.debug('Here');
        Clinical_Trial_Profile__c ctp = getClinicalTrialProfile(protocolId);
        createParticipantEnrollment(ctp, getStudySite(siteNumber, ctp), startValue, endValue);
    }

    private static void createParticipantEnrollment(Clinical_Trial_Profile__c ctp, Study_Site__c studySite, Integer startValue, Integer endValue){
        Integer tmp = startValue;
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        List<Contact> contacts = new List<Contact>();
        for(; startValue <= endValue; startValue++){
            Contact con = new Contact();
            con.LastName = '' + startValue;
            con.Email = 'dz@hp.com';
            contacts.add(con);
        }
        insert contacts;
        List<Participant__c> participants = new List<Participant__c>();
        for(Contact con : contacts){
            Participant__c p = new Participant__c();
            p.Contact__c = con.Id;
            participants.add(p);
        }
        System.debug(participants);
        insert participants;
        startValue = tmp;
        Integer i = 0;
        for(; startValue <= endValue; startValue++){
            Participant_Enrollment__c pe = new Participant_Enrollment__c();
            pe.Clinical_Trial_Profile__c = ctp.Id;
            pe.Study_Site__c = studySite.Id;
            pe.Screening_ID__c = '' + startValue;
            pe.Participant__c = participants[i].Id;
            i++;
            pe.Participant_Status__c  = 'Enrollment Success';
            peList.add(pe);
        }
        System.debug(peList);
        insert peList;
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