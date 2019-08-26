/**
 * Created by Leonid Bartenev
 */

public without sharing class IntegrationPatientReferralTriggerHandler {
    
    public class RequiredFieldsAndParticipantDuplicatesCheck extends TriggerHandler {
        
        public override void beforeInsert(List<SObject> newList) {
            checkRecords(newList);
        }
    }
    
    private static final List<String> SS_STATUSES_ACCEPT_REFERRALS = new List<String>{
            StudySiteService.PI_S_ACCEPTED,
            StudySiteService.PI_S_ACCEPTED_A,
            StudySiteService.PI_S_INVITATION_SENT
    };
    
    private static void checkRecords(List<Integration_Patient_Referral__c> newList) {
        List<String> protocolIds = new List<String>();
        List<String> ssNumberList = new List<String>();
        List<Participant__c> newParticipants = new List<Participant__c>();
        for (Integration_Patient_Referral__c record : newList) {
            protocolIds.add(record.protocolId__c);
            ssNumberList.add(record.protocolId__c + '_' + record.siteSelected__c);
            newParticipants.add(convertToParticipant(record));
        }
        //SS Map
        Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        List<Study_Site__c> ssList = [
                SELECT Id, Protocol_ID__c,
                        Override_PI_Referral_Status__c
                FROM Study_Site__c
                WHERE Primary_Key_ePR__c IN:ssNumberList
        ];
        for (Study_Site__c ss : ssList) ssByPrimaryKeyEPRMap.put(ss.Primary_Key_ePR__c, ss);
        
        //CTP Map
        Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> ctpList = [
                SELECT id, Override_Recruitment_Status__c
                FROM Clinical_Trial_Profile__c
                WHERE Protocol_Id__c IN:protocolIds
        ];
        for (Clinical_Trial_Profile__c ctp : ctpList) ctpByProtocolIdMap.put(ctp.Protocol_ID__c, ctp);
        
        //process items:
        for (Integration_Patient_Referral__c record : newList) {
            List<String> errorsLog = new List<String>();
            //Required fields check:
            if (String.isEmpty(record.siteSelected__c)) errorsLog.add('Required field is missing: siteSelected;');
            if (String.isEmpty(record.protocolId__c)) errorsLog.add('Required field is missing: protocolId;');
            if (String.isEmpty(record.firstName__c)) errorsLog.add('Required field is missing: firstName__c;');
            if (String.isEmpty(record.lastName__c)) errorsLog.add('Required field is missing: lastName__c;');
            if (String.isEmpty(record.email__c) &&
                    String.isEmpty(record.phone__c)) errorsLog.add('Either email or phone number must be provided;');
            
            //Check SS
            String studySiteNumber = record.protocolId__c + '_' + record.siteSelected__c;
            Study_Site__c ss = ssByPrimaryKeyEPRMap.get(studySiteNumber);
            if (ss == null) {
                errorsLog.add('Study Site: ' + studySiteNumber + ' not found;');
            } else if (!SS_STATUSES_ACCEPT_REFERRALS.contains(ss.Override_PI_Referral_Status__c)) {
                errorsLog.add('StudySite is not accepting referrals;');
            }
            
            //Check CTP
            Clinical_Trial_Profile__c ctp = ctpByProtocolIdMap.get(record.protocolId__c);
            if (ctp == null) {
                errorsLog.add('Study: ' + record.protocolId__c + ' not found;');
            } else if(ctp.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING) {
                errorsLog.add('Study is not accepting referrals;');
            }
            if (errorsLog.size() > 0) {
                throw new PatientIntegrationException(String.join(errorsLog, '\n'));
            }
            
            ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(newParticipants);
            for(Participant__c participant : newParticipants){
                if(duplicateService.findDuplicate(participant) != null){
                    //TODO
                }else{
                    //TODO
                }
            }
        
        }
    }
    
    private static Participant__c convertToParticipant(Integration_Patient_Referral__c ipr){
        return new Participant__c(
                First_Name__c = ipr.firstName__c,
                Last_Name__c = ipr.lastName__c,
                Email__c = ipr.email__c,
                Phone__c = ipr.phone__c,
                Phone_Type__c = ipr.Phone_Type__c,
                Date_of_Birth__c = ipr.BirthDate__c,
                Birth_Year__c = ipr.birthYear__c,
                Mailing_Country_Code__c = ipr.Address_Country__c,
                Mailing_State_Code__c = ipr.Address_State__c,
                Mailing_City__c = ipr.Address_City__c,
                Mailing_Zip_Postal_Code__c = ipr.Address_ZipCode__c,
                Mailing_Street__c = ipr.Address_AddressLine1__c,
                Gender__c = ipr.sex__c
        );
    }
    

}