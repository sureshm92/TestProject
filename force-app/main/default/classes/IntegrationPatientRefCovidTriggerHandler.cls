/**
 * Created by Sumit/Sabir/Sabir
 */

public without sharing class IntegrationPatientRefCovidTriggerHandler 
{
    private static final List<String> SS_STATUSES_ACCEPT_REFERRALS = new List<String>{
            StudySiteService.PI_S_ACCEPTED,
            StudySiteService.PI_S_ACCEPTED_A,
            StudySiteService.PI_S_INVITATION_SENT
    };
     
    public without sharing class CheckRequiredFieldsAndUpsertParticipantAndPEHandler extends TriggerHandler {
        
        public override void beforeInsert(List<SObject> newList) {
            setNewList(newList);
            checkFields();
            upsertParticipantAndPE();
        }
        
        private Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        private Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        private List<Integration_Patient_Referral__c> newList;
        private Map<String, Integration_Patient_Referral__c> newMap = new Map<String, Integration_Patient_Referral__c>();
    
    
        private void setNewList(List<Integration_Patient_Referral__c> newList){
            this.newList = newList;
            List<String> protocolIds = new List<String>();
            List<String> ssNumbersList = new List<String>();
            for (Integration_Patient_Referral__c ipr : newList) {
                protocolIds.add(ipr.protocolId__c);
                ssNumbersList.add(getSitePrimaryKeyEPR(ipr));
                newMap.put(ipr.referralID__c, ipr);
            }
            //SS Map
            List<Study_Site__c> ssList = [
                    SELECT Id, Protocol_ID__c, Primary_Key_ePR__c,
                            Override_PI_Referral_Status__c
                    FROM Study_Site__c
                    WHERE Primary_Key_ePR__c IN: ssNumbersList
            ];
            for (Study_Site__c ss : ssList) ssByPrimaryKeyEPRMap.put(ss.Primary_Key_ePR__c, ss);
    
            //CTP Map
            List<Clinical_Trial_Profile__c> ctpList = [
                    SELECT Id, Override_Recruitment_Status__c, Protocol_ID__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Protocol_ID__c IN: protocolIds
            ];
            for (Clinical_Trial_Profile__c ctp : ctpList) ctpByProtocolIdMap.put(ctp.Protocol_ID__c, ctp);
        }
    
        private void checkFields() {
            //process items:
            for (Integration_Patient_Referral__c ipr : newList) {
                List<String> errorsLog = new List<String>();
                //Required fields check:
                if (String.isEmpty(ipr.siteSelected__c)) errorsLog.add('Required field is missing: siteSelected;');
                if (String.isEmpty(ipr.protocolId__c)) errorsLog.add('Required field is missing: protocolId;');
                if (String.isEmpty(ipr.firstName__c)) errorsLog.add('Required field is missing: firstName__c;');
                if (String.isEmpty(ipr.lastName__c)) errorsLog.add('Required field is missing: lastName__c;');
                if (String.isEmpty(ipr.email__c) &&
                        String.isEmpty(ipr.phone__c) &&
                        String.isEmpty(ipr.Delegate_Daytime_Phone_Number__c) &&
                        String.isEmpty(ipr.Delegate_Email_Address__c) &&
                        String.isEmpty(ipr.Delegate_Alternative_Phone_Number__c)) errorsLog.add('Either email or phone number must be provided;');
            
                //Check SS
                String studySiteNumber = getSitePrimaryKeyEPR(ipr);
                Study_Site__c ss = ssByPrimaryKeyEPRMap.get(studySiteNumber);
                if (ss == null) {
                    errorsLog.add('Study Site: ' + studySiteNumber + ' not found;');
                } else if (!SS_STATUSES_ACCEPT_REFERRALS.contains(ss.Override_PI_Referral_Status__c)) {
                    errorsLog.add('StudySite is not accepting referrals;');
                }
            
                //Check CTP
                Clinical_Trial_Profile__c ctp = ctpByProtocolIdMap.get(ipr.protocolId__c);
                if (ctp == null) {
                    errorsLog.add('Study: ' + ipr.protocolId__c + ' not found;');
                } else if (ctp.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING) {
                    errorsLog.add('Study is not accepting referrals;');
                }
                if (errorsLog.size() > 0) ipr.addError(String.join(errorsLog, '\n'));
            }
        }

        private void upsertParticipantAndPE() {
            Map<String, Participant__c> newParticipantsMap = new Map<String, Participant__c>();
            Map<String, Contact> newDelegateContactsMap = new Map<String, Contact>();
            Account participantAccount = [SELECT Id FROM Account WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME LIMIT 1 FOR UPDATE ];
            for (Integration_Patient_Referral__c ipr : newList) {
                newParticipantsMap.put(ipr.referralID__c, convertToParticipant(ipr));
                if (!String.isBlank(ipr.Delegate_First_Name__c) && !String.isBlank(ipr.Delegate_Last_Name__c)) {
                    newDelegateContactsMap.put(ipr.referralID__c, convertToDelegateContact(ipr, participantAccount));
                }
            }

            System.debug('before duplicateService');
            //Duplicates check and upsert participant
            ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(newParticipantsMap.values());
            for (Integration_Patient_Referral__c ipr : newList) {
                Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
                Participant__c participantDuplicate = duplicateService.findDuplicate(participant);
                System.debug('participantDuplicate---> ' + participantDuplicate);
                if (participantDuplicate != null) {
                    String refSourceStr = participantDuplicate.Secondary_Source__c;
                    if (refSourceStr == null) refSourceStr = '';
                    Set<String> refSources = new Set<String>(refSourceStr.split(';'));
                    refSources.add(ipr.Data_Source__c);
                    participantDuplicate.Secondary_Source__c = String.join(new List<String>(refSources), ';');
                    newParticipantsMap.put(ipr.referralID__c, participantDuplicate);
                } else {
                    Contact contactDuplicate = duplicateService.findDuplicateContact(participant);
                    if (contactDuplicate != null) participant.Contact__c = contactDuplicate.Id;
                    newParticipantsMap.put(ipr.referralID__c, participant);
                }
            }

            upsert newParticipantsMap.values();
            if (!newDelegateContactsMap.isEmpty()) {
                insert newDelegateContactsMap.values();
            }

            //Insert PE
            List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
            Map<Id, Id> participantIdByParticipantDelegateContactId = new Map<Id, Id>();
            Set<Id> delegateIds = new Set<Id>();
            for (Integration_Patient_Referral__c ipr : newList) {
                Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
                Study_Site__c ss = ssByPrimaryKeyEPRMap.get(getSitePrimaryKeyEPR(ipr));
                if (ss != null) peList.add(createPE(ipr, participant.Id, ss.Id));

                Contact participantDelegateContact = newDelegateContactsMap.get(ipr.referralID__c);
                if (participantDelegateContact != null) {
                    participantIdByParticipantDelegateContactId.put(participantDelegateContact.Id, participant.Id);
                    delegateIds.add(participantDelegateContact.Id);
                }
            }
            List<Database.SaveResult> saveResults = Database.insert(peList, false);
            Set<Id> participantsWithoutErrors = new Set<Id>();
            for (Integer i = 0; i < saveResults.size(); i++) {
                Participant_Enrollment__c pe = peList[i];
                Database.SaveResult sr = saveResults[i];
                Integration_Patient_Referral__c ipr = newMap.get(pe.Referral_ID__c);
                if (ipr != null) {
                    if (sr.isSuccess()) {
                        participantsWithoutErrors.add(pe.Participant__c);
                        ipr.Success__c = true;
                        ipr.Participant_Enrollment__c = sr.getId();
                    } else {
                        ipr.Success__c = false;
                        ipr.Error_Message__C = 'Participant Enrollment Duplicate Error';
                    }
                }
            }

            if (!delegateIds.isEmpty()) {
                List<Patient_Delegate__c> ptDelegateRefs = new List<Patient_Delegate__c>();
                Map<Id, Id> delegateUsersToCreate = new Map<Id, Id>();
                for (Contact participantDelegateContact : newDelegateContactsMap.values()) {
                    Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                    ptDelegateRef.Participant__c = participantIdByParticipantDelegateContactId.get(participantDelegateContact.Id);
                    ptDelegateRef.Contact__c = participantDelegateContact.Id;
                    if (participantsWithoutErrors.contains(ptDelegateRef.Participant__c)) {
                        ptDelegateRefs.add(ptDelegateRef);
                        delegateUsersToCreate.put(participantDelegateContact.Id, null);
                    }
                }
                if (!ptDelegateRefs.isEmpty()) {
                    insert ptDelegateRefs;
                }
                if (!delegateUsersToCreate.isEmpty()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(delegateUsersToCreate);
                }
            }
        }
    }

    private static Participant__c convertToParticipant(Integration_Patient_Referral__c ipr) {
        Participant__c participant = new Participant__c(
                First_Name__c = ipr.firstName__c,
                Middle_Name__c = ipr.Middle_Initial__c,
                Last_Name__c = ipr.lastName__c,
                Email__c = ipr.email__c,
                Phone__c = ipr.phone__c,
                Phone_Type__c = ipr.Phone_Type__c,
                Date_of_Birth__c = ipr.BirthDate__c,
                Birth_Year__c = ipr.birthYear__c,
                Mailing_Country_Code__c = ipr.Address_Country__c,
                Mailing_State__c = ipr.Address_State__c,
                Mailing_City__c = ipr.Address_City__c,
                Mailing_Zip_Postal_Code__c = ipr.Address_ZipCode__c,
                Mailing_Street__c = ipr.Address_AddressLine1__c,
                Gender__c = ipr.sex__c,
                Secondary_Source__c = ipr.Data_Source__c,
                Suffix__c = ipr.Suffix__c,
            	Alternative_Phone_Number__c = ipr.Participant_MobileNumber__c,
                Alternative_Phone_Type__c = 'Mobile'

        );
        participant.Adult__c = !Boolean.valueOf(ReferringRemote.checkNeedsGuardian(JSON.serialize(participant)));

        return participant;
    }

    public static Contact convertToDelegateContact(Integration_Patient_Referral__c ipr, Account participantAccount) {
        Contact newContact = new Contact(
                FirstName = ipr.Delegate_First_Name__c,
                MiddleName = ipr.Delegate_Middle_Name__c,
                LastName = ipr.Delegate_Last_Name__c,
                Email = ipr.Delegate_Email_Address__c,
                MailingCountryCode = ipr.Address_Country__c,
                MailingState = ipr.Delegate_Mailing_State__c,
                MailingCity = ipr.Delegate_Mailing_City__c,
                MailingPostalCode = ipr.Delegate_Zip_Postal_Code__c,
                Current_Participant_Enrollment__c = ipr.Participant_Enrollment__c,
                AccountId = participantAccount.Id
        );
        if ('Home' == ipr.Delegate_Phone_Number_Type__c) {
            newContact.HomePhone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.MobilePhone = ipr.Delegate_Alternative_Phone_Number__c;
        } if ('Mobile' == ipr.Delegate_Phone_Number_Type__c) {
            newContact.MobilePhone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.HomePhone = ipr.Delegate_Alternative_Phone_Number__c;
        } else {
            newContact.Phone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.MobilePhone = ipr.Delegate_Alternative_Phone_Number__c;
        }

        return newContact;
    }

    private static Participant_Enrollment__c createPE(Integration_Patient_Referral__c ipr, Id participantId, Id ssId) {
        return new Participant_Enrollment__c(
                Participant__c = participantId,
                Study_Site__c = ssId,
                Pre_Eligibility__c = ipr.Pass_Fail__c,
                Referral_Source__c = ipr.Data_Source__c,
                Patient_ID__c = ipr.ePRPatient_ID_Number__c,
                Referral_ID__c = ipr.referralID__c,
                MRR_Survey_Results_URL__c = ipr.MRR_Survey_Results_URL__c,
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
                Terms_and_Conditions_Accepted_Date__c = ipr.acceptedTermsAndConditions__c != null ? Date.valueOf(ipr.acceptedTermsAndConditions__c) : null,
                Referred_Date__c = ipr.Referred_Date__c != null ? Date.valueOf(ipr.Referred_Date__c) : null,
                Referred_By__c = 'Other',
                utm_campaign__c = ipr.UTM_campaignName__c,
                utm_content__c = ipr.UTM_campaignContent__c,
                utm_medium__c = ipr.UTM_campaignMedium__c,
                utm_source__c = ipr.UTM_campaignSource__c,
                utm_term__c = ipr.UTM_campaignTerm__c,
                utmz__c = ipr.UTM_campaignCookie__c,
                gclid__c = ipr.UTM_GCLID__c,
                Atid__c = ipr.Atid__c,

                HighRisk_Indicator__c = ipr.HighRisk_Indicator__c

        );
    }
    
    private static String getSitePrimaryKeyEPR(Integration_Patient_Referral__c ipr){
        return ipr.protocolId__c + '_' + ipr.Address_Country__c + '_' + ipr.siteSelected__c;
    }
}