/**
 * Created by Denis Z on 08-Jul-19.
 */

public without sharing class ParticipantEnrollmentFactory {

    public class PEWrapper{
        public Participant_Enrollment__c pe;
        public Participant__c participant;
        
        public PEWrapper(Participant__c participant, Participant_Enrollment__c pe){
            this.participant = participant;
            this.pe = pe;
        }
    }

    public static Map<String, Clinical_Trial_Profile__c> ctpMap = new Map<String, Clinical_Trial_Profile__c>();
    public static Map<String, Study_Site__c> ssMap = new Map<String, Study_Site__c>();
    //public static Id TA_ID = [SElECT Id FROM Therapeutic_Area__c LIMIT 1].Id;
    
    
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
        //participant.Mailing_Country__c = 'United States';
        insert participant;
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.Clinical_Trial_Profile__c = ctp.Id;
        pe.Study_Site__c = studySite.Id;
        pe.Screening_ID__c =screeningId;
        pe.Participant__c = participant.Id;
        pe.Participant_Status__c  = 'Enrollment Success';
        insert pe;
        pe.Participant_Status__c  = 'Received';
        update pe;
    }
    
    public static List<Id> createParticipantEnrollmentRecords(List<String> csvLines, String postfix){
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id, External_Key__c
                FROM Participant_Study_Enrollment__c
                WHERE External_Key__c IN: csvLines
        ];
        Set<String> createdItems = new Set<String>();
        for(Participant_Study_Enrollment__c pse : pseList) createdItems.add(pse.External_Key__c);
        if(postfix == null) postfix = '';
        List<PEWrapper> peWrappers = new List<PEWrapper>();
        for(String csvLine : csvLines){
            if(createdItems.contains(csvLine)) continue;
            List<String> lineItems = csvLine.split('~');
            String protocolId = lineItems[0].trim();
            String siteNumber = lineItems[1].trim();
            String screeningId = lineItems[2].trim();
            Clinical_Trial_Profile__c ctp = getClinicalTrialProfile(protocolId + postfix);
            peWrappers.add(
                    createPEWrapper(ctp, getStudySite(siteNumber + postfix, ctp), screeningId + postfix)
            );
        }
        List<Participant__c> participants = new List<Participant__c>();
        for(PEWrapper peWrapper : peWrappers) participants.add(peWrapper.participant);
        insert participants;
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(PEWrapper peWrapper : peWrappers){
            peWrapper.pe.Participant__c = peWrapper.participant.Id;
            peList.add(peWrapper.pe);
        }
        insert peList;
        for (Participant_Enrollment__c pe : peList){
            pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        }
        update peList;
        List<Id> peIds = new List<Id>();
        for(Participant_Enrollment__c pe : peList) peIds.add(pe.Id);
        return peIds;
    }

    private static PEWrapper createPEWrapper(Clinical_Trial_Profile__c ctp, Study_Site__c studySite, String screeningId){
        Participant__c participant = new Participant__c(
                First_Name__c = screeningId,
                Last_Name__c = screeningId + Datetime.now().getTime(),
                Phone__c = Datetime.now().getTime() + '',
                Email__c = screeningId + Datetime.now().getTime() + '@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatientId1',
                //Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
                Screening_ID__c = screeningId
        );
        return new PEWrapper(participant, pe);
    }

    private static Clinical_Trial_Profile__c getClinicalTrialProfile(String protocolId){
        Clinical_Trial_Profile__c ctp = ctpMap.get(protocolId);
        if(ctp != null) return ctp;
        List<Clinical_Trial_Profile__c> ctpList = [
                SELECT
                        Id,
                        Protocol_ID__c
                FROM    Clinical_Trial_Profile__c
                WHERE   Protocol_ID__c = : protocolId
        ];
        if(ctpList.isEmpty()){
            ctp = createClinicalTrialProfile(protocolId);
        }else{
            ctp = ctpList[0];
        }
        ctpMap.put(protocolId, ctp);
        return ctp;
    }

    private static Clinical_Trial_Profile__c createClinicalTrialProfile(String protocolId){
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
                Protocol_ID__c = protocolId,
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = generateNCTNumber(),
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title ' + protocolId,
                Study_Code_Name__c = 'Some Code Name ' + protocolId,
                Suppress_Participant_Emails__c = false,
                //Therapeutic_Area__c = TA_ID,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true,
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true
        );
        insert ctp;
        return ctp;
    }

    private static Study_Site__c getStudySite(String siteNumber, Clinical_Trial_Profile__c ctp){
        Study_Site__c ss = ssMap.get(siteNumber);
        if(ss != null) return ss;
        List<Study_Site__c> siteList = [
                SELECT
                        Id,
                        Study_Site_Number__c
                FROM    Study_Site__c
                WHERE   Study_Site_Number__c = : siteNumber
        ];
        if(siteList.isEmpty()){
            ss = createStudySite(siteNumber, ctp);
        }else{
            ss = siteList[0];
        }
        ssMap.put(siteNumber, ss);
        return ss;
    }

    private static Study_Site__c createStudySite(String siteNumber, Clinical_Trial_Profile__c ctp){
        Account siteAccount = new Account(
            Name = 'Account_' + siteNumber
        );
        insert siteAccount;
        Study_Site__c study = new Study_Site__c(
                Principal_Investigator__c = createPI().Id,
                Clinical_Trial_Profile__c = ctp.Id,
                Study_Site_Number__c = siteNumber,
                Study_Site_Key__c = System.now().getTime() + '',
                //Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = siteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
        );
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
    
    private static String generateNCTNumber(){
        String newNum = System.now().getTime() + '';
        newNum = 'NCT' + newNum.right(8);
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c =: newNum];
        if(ctpList.isEmpty()) return newNum;
        return generateNCTNumber();
    }


}