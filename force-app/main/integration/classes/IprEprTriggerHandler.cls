public without sharing class IprEprTriggerHandler {
    private static final List<String> SS_STATUSES_ACCEPT_REFERRALS = new List<String>{
        StudySiteService.PI_S_ACCEPTED,
            StudySiteService.PI_S_ACCEPTED_A,
            StudySiteService.PI_S_INVITATION_SENT
            };
                
    private static final Map<String, EPR_Validation_Message__mdt> err = EPR_Validation_Message__mdt.getAll();
    public static Map<String, Study_Site__c> ssByPrimaryKeyEPRMap_batch = new Map<String, Study_Site__c>();
    public static Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap_batch = new Map<String, Clinical_Trial_Profile__c>();
    
    public class ContactAndSiteType {
        public Contact contactObj;
        public String siteType;
        ContactAndSiteType() {
        }
        public ContactAndSiteType(Contact incon, String inSiteType) {
            this.contactObj = incon;
            this.siteType = inSiteType;
        }
    }
    
    public class CheckRequiredFieldsAndUpsertParticipantAndPEHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            validateReferralsV2(newList);
            //setNewList(newList);
            //validateReferrals();//boolean isValidateReferral = validateReferrals();
            //if(isValidateReferral)
            //checkFields();
        } 
        
        private Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        private Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        private List<Integration_Patient_Referral__c> newList;
        
        public void validateReferralsV2(List<Integration_Patient_Referral__c> newList) {
            List<String> protocolIds = new List<String>();
            List<String> ssNumbersList = new List<String>();
            this.newList = newList;
            for (Integration_Patient_Referral__c ipr : newList) {
                List<String> errorsLog = new List<String>();
                //Required fields check:
                if (String.isEmpty(ipr.siteSelected__c))
                    errorsLog.add(err.get('siteSelected_missing').Error_Message__c);
                if (String.isEmpty(ipr.protocolId__c))
                    errorsLog.add(err.get('protocolId_missing').Error_Message__c);
                if (String.isEmpty(ipr.firstName__c))
                    errorsLog.add(err.get('firstName_missing').Error_Message__c);
                if (String.isEmpty(ipr.lastName__c))
                    errorsLog.add(err.get('lastName_missing').Error_Message__c);
                if (String.isEmpty(ipr.email__c) &&
                    String.isEmpty(ipr.phone__c) &&
                    String.isEmpty(ipr.Delegate_Daytime_Phone_Number__c) &&
                    String.isEmpty(ipr.Delegate_Email_Address__c)) 
                    errorsLog.add(err.get('email_phone_missing').Error_Message__c);
                
                ipr.Success__c = true;
                if (errorsLog.size() > 0) {
                    ipr.Error_Message__c = String.join(errorsLog, '\n');
                    ipr.Is_retry_required__c = false;
                    ipr.Batch_consideration__c = 'Not considered';
                }
                else{
                    protocolIds.add(ipr.protocolId__c);
                    //DD:: ssNumbersList.add(getSitePrimaryKeyEPR(ipr));
                    ssNumbersList.add(ipr.protocolId__c + '_' + ipr.Address_Country__c + '_' + ipr.siteSelected__c);
                }
            }
            
            //SS Map
            for (Study_Site__c ss : [SELECT Id, Protocol_ID__c, Primary_Key_ePR__c, Study_Site_Type__c, Site__c, Override_PI_Referral_Status__c, 
                                     Clinical_Trial_Profile__r.Suppress_Participant_Emails__c, Suppress_Participant_Emails__c
                                     FROM Study_Site__c WHERE Primary_Key_ePR__c IN :ssNumbersList ])
            {ssByPrimaryKeyEPRMap.put(ss.Primary_Key_ePR__c, ss);}      
            
            //CTP Map
            for (Clinical_Trial_Profile__c ctp : [SELECT Id, Override_Recruitment_Status__c, Protocol_ID__c
                                                  FROM Clinical_Trial_Profile__c
                                                  WHERE Protocol_ID__c IN :protocolIds])
            {ctpByProtocolIdMap.put(ctp.Protocol_ID__c, ctp);}
            
            
            set<String> languageCodes = new set<String>();
            for (PicklistEntry ple : Participant__c.Language_Preference_Code__c.getDescribe().getPicklistValues()) 
            {languageCodes.add(ple.getValue());}
            
            
            for (Integration_Patient_Referral__c ipr : newList) {
                if(ipr.Error_Message__c == null || ipr.Error_Message__c == '' ){
                    List<String> errorsLog = new List<String>();
                    
                    // check country    
                    if(String.isNotBlank(ipr.Address_Country__c)) {
                        String countryName = CountryStateUtil.getCountryName(ipr.Address_Country__c);
                        if(String.isBlank(countryName))
                            errorsLog.add(err.get('country_invalid').Error_Message__c);
                    }   
                    
                    // check state 
                    Map<String,String> states = CountryStateUtil.getStateCodeByNameMap(ipr.Address_Country__c);       
                    if(String.isNotBlank(ipr.address_state__c)) 
                        if(!states.containskey(ipr.address_state__c))
                        errorsLog.add(err.get('state_invalid').Error_Message__c);
                    
                    // check state 
                    if(String.isNotBlank(ipr.Delegate_Mailing_State__c)) 
                        if(!states.containskey(ipr.Delegate_Mailing_State__c))
                        errorsLog.add(err.get('state_invalid').Error_Message__c);
                    
                    // check langauge  
                    if(String.isNotBlank(ipr.Language_Preference__c)) {                    
                        if(!languageCodes.contains(ipr.Language_Preference__c)) 
                            errorsLog.add(err.get('language_invalid').Error_Message__c);
                        
                    } 
                    
                    //Check SS
                    //D:: String studySiteNumber = getSitePrimaryKeyEPR(ipr);
                    String studySiteNumber = ipr.protocolId__c + '_' + ipr.Address_Country__c + '_' + ipr.siteSelected__c;
                    
                    Study_Site__c ss = ssByPrimaryKeyEPRMap.get(studySiteNumber);
                    if (ss == null) {
                        errorsLog.add(err.get('study_site_not_found').Error_Message__c.replace('SSNo',studySiteNumber));
                    } else if (
                        !SS_STATUSES_ACCEPT_REFERRALS.contains(ss.Override_PI_Referral_Status__c)
                    ) {
                        errorsLog.add(err.get('study_site_no_referrals').Error_Message__c);
                    }
                    
                    //Check CTP
                    Clinical_Trial_Profile__c ctp = ctpByProtocolIdMap.get(ipr.protocolId__c);
                    if (ctp == null) {
                        errorsLog.add(err.get('study_not_found').Error_Message__c.replace('SNo',ipr.protocolId__c));
                    } else if (
                        ctp.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING
                    ) {
                        errorsLog.add(err.get('study_no_referrals').Error_Message__c);
                    }
                    
                    if (errorsLog.size() > 0) {
                        ipr.Error_Message__c = String.join(errorsLog, '\n');
                        ipr.Is_retry_required__c = true;
                        ipr.Batch_consideration__c = 'Processing';
                        ipr.Retry_Count__c = 0;
                    }else{
                        ipr.Is_retry_required__c = false;
                        ipr.Batch_consideration__c = 'Not completed';
                    }
                }
            }
        }
        
        
        public void setCTP_PrimaryKey_forBatch(List<Integration_Patient_Referral__c> lstIPR){
            List<String> ssNumbersList = new List<String>();
            List<String> protocolIds = new List<String>();
            for(Integration_Patient_Referral__c objIPR : lstIPR){
                ssNumbersList.add(objIPR.protocolId__c + '_' + objIPR.Address_Country__c + '_' + objIPR.siteSelected__c);
                protocolIds.add(objIPR.protocolId__c);
            }
            for (Study_Site__c ss : [SELECT Id, Protocol_ID__c, Primary_Key_ePR__c, Study_Site_Type__c, Site__c, Override_PI_Referral_Status__c, 
                                     Clinical_Trial_Profile__r.Suppress_Participant_Emails__c, Suppress_Participant_Emails__c
                                     FROM Study_Site__c WHERE Primary_Key_ePR__c IN :ssNumbersList ])
            {	
                ssByPrimaryKeyEPRMap_batch.put(ss.Primary_Key_ePR__c, ss);
            } 
            for (Clinical_Trial_Profile__c ctp : [SELECT Id, Override_Recruitment_Status__c, Protocol_ID__c
                                                  FROM Clinical_Trial_Profile__c
                                                  WHERE Protocol_ID__c IN :protocolIds])
            {	
                ctpByProtocolIdMap_batch.put(ctp.Protocol_ID__c, ctp);
            }
            
        }
        
        
        
        
        public String checkFieldsForBatchValidation(Integration_Patient_Referral__c Ipr){
            List<String> errorsLog = new List<String>();
            // check country    
            if(String.isNotBlank(ipr.Address_Country__c)) {
                String countryName = CountryStateUtil.getCountryName(ipr.Address_Country__c);
                if(String.isBlank(countryName))
                    errorsLog.add(err.get('country_invalid').Error_Message__c);
            }   
            
            // check state 
            Map<String,String> states = CountryStateUtil.getStateCodeByNameMap(ipr.Address_Country__c);       
            if(String.isNotBlank(ipr.address_state__c)) 
                if(!states.containskey(ipr.address_state__c))
                       errorsLog.add(err.get('state_invalid').Error_Message__c);                
                
                // check state 
                if(String.isNotBlank(ipr.Delegate_Mailing_State__c)) 
					if(!states.containskey(ipr.Delegate_Mailing_State__c))
						errorsLog.add(err.get('state_invalid').Error_Message__c);
            
            // check langauge  
            if(String.isNotBlank(ipr.Language_Preference__c)) {
                set<String> languageCodes = new set<String>();
                for (PicklistEntry ple : Participant__c.Language_Preference_Code__c.getDescribe().getPicklistValues()) 
                    languageCodes.add(ple.getValue());
                if(!languageCodes.contains(ipr.Language_Preference__c)) 
                    errorsLog.add(err.get('language_invalid').Error_Message__c);
                
            } 
            
            //Check SS
            String studySiteNumber = getSitePrimaryKeyEPR(ipr);
            system.debug('>>studySiteNumber>'+studySiteNumber);
            Study_Site__c ss = ssByPrimaryKeyEPRMap_batch.get(studySiteNumber);
            system.debug('>>ss>'+ss);
            if (ss == null) {
                errorsLog.add(err.get('study_site_not_found').Error_Message__c.replace('SSNo',studySiteNumber));
            } else if (
                !SS_STATUSES_ACCEPT_REFERRALS.contains(ss.Override_PI_Referral_Status__c)
            ) {
                errorsLog.add(err.get('study_site_no_referrals').Error_Message__c);
            }
            
            //Check CTP
            Clinical_Trial_Profile__c ctp = ctpByProtocolIdMap_batch.get(ipr.protocolId__c);
            if (ctp == null) {
                errorsLog.add(err.get('study_not_found').Error_Message__c.replace('SNo',ipr.protocolId__c));
            } else if (
                ctp.Override_Recruitment_Status__c != TrialService.STATUS_ACTIVELY_ENROLLING
            ) {
                errorsLog.add(err.get('study_no_referrals').Error_Message__c);
            }
            system.debug('>>>errorsLog>>'+errorsLog);
            if (errorsLog.size() > 0) {
                String strError = String.join(errorsLog, '\n');
                return strError;
            }else{
                return 'True';
            } 
        }
        
    }
    
    
    public static String getSitePrimaryKeyEPR(Integration_Patient_Referral__c ipr) {
        return ipr.protocolId__c + '_' + ipr.Address_Country__c + '_' + ipr.siteSelected__c;
    }
    
    public static Participant__c convertToParticipant(Integration_Patient_Referral__c ipr) {
        Map<String, String> mapEthinicCodeToDescription = new Map<String, String>();
        String strEthnicityDescr = '';
        Participant__c participant = new Participant__c(
            First_Name__c = ipr.firstName__c,
            Middle_Name__c = ipr.Middle_Initial__c,
            Last_Name__c = ipr.lastName__c,
            Email__c = ipr.email__c,
            Phone__c = ipr.phone__c,
            Phone_Type__c = (!String.isEmpty(ipr.phone__c) && String.isEmpty(ipr.Phone_Type__c)) ? 'Home' : ipr.Phone_Type__c,
            Date_of_Birth__c = ipr.BirthDate__c,
            Birth_Year__c = ipr.birthYear__c,
            Mailing_Country_Code__c = ipr.Address_Country__c,
            Mailing_State__c = ipr.Address_State__c,
            Mailing_City__c = ipr.Address_City__c,
            Mailing_Zip_Postal_Code__c = ipr.Address_ZipCode__c,
            Mailing_Street__c = ipr.Address_AddressLine1__c,
            Gender__c = ipr.sex__c,
            Secondary_Source__c = ipr.Data_Source__c,
            Alternative_Phone_Number__c = ipr.Participant_MobileNumber__c,
            Language_Preference_Code__c = ipr.Language_Preference__c,
            Preferred_Language__c = ipr.Language_Preference__c,
            BMI__c = ipr.BMI__c,
            Preferred_Contact_Time__c = ipr.Preferred_Contact_Time__c
            //  Alternative_Phone_Type__c = 'Mobile'
        );
        
        /*
for (Ethnicity_Mapping_Participant__mdt objMT : [
SELECT Ethnicity_Code__c, Ethnicity_Description__c
FROM Ethnicity_Mapping_Participant__mdt
]) {
mapEthinicCodeToDescription.put(
objMT.Ethnicity_Code__c,
objMT.Ethnicity_Description__c
);
}
*/
        
        Map<String, Ethnicity_Mapping_Participant__mdt> mapEC = Ethnicity_Mapping_Participant__mdt.getAll();
        for(String ethinicCodeToDesc : mapEC.keySet()){
            mapEthinicCodeToDescription.put(
                mapEC.get(ethinicCodeToDesc).Ethnicity_Code__c,
                mapEC.get(ethinicCodeToDesc).Ethnicity_Description__c
            );
        }
        
        List<String> lstStringEthnicity_temp = new List<String>();
        if (ipr.Ethnicity__c != null) {
            lstStringEthnicity_temp = ipr.Ethnicity__c.split(';');
            for (String intEthinictyCode : lstStringEthnicity_temp) {
                if (mapEthinicCodeToDescription.get(intEthinictyCode) != null)
                    strEthnicityDescr += mapEthinicCodeToDescription.get(intEthinictyCode) + ';';
            }
            strEthnicityDescr.removeEnd(';');
            participant.Ethnicity__c = strEthnicityDescr;
        }
        
        if (ipr.Participant_MobileNumber__c != null)
            participant.Alternative_Phone_Type__c = 'Mobile';
        /*participant.Adult__c = !Boolean.valueOf(
ReferringRemote.checkNeedsGuardian(JSON.serialize(participant))
);*/
        
        participant.Adult__c = !Boolean.valueOf(checkNeedsGuardian(JSON.serialize(participant)));   
        

        //map participants country and state code
        String countryName = null;
        String countryCode = participant.Mailing_Country_Code__c;
        String stateName = participant.Mailing_State__c;
        String stateCode = null;
        if (countryCode != null && countryName == null) {
            if(CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCode)){  
                countryName = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCode);
                participant.Mailing_Country__c = countryName;
            }
        }
        if(stateCode == null && stateName != null) {
            if(CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.containsKey(countryCode) && CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).containsKey(stateName)){
                participant.Mailing_State_Code__c =CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).get(stateName);
                
            }
            
        }
 


        return participant;
    }
    
    public static String checkNeedsGuardian(String participantJSON) {
        Boolean needsGuardian = false;
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        if (!String.isEmpty(participant.Date_of_Birth__c)) {
            
            Map<String, Integer> ageByCountryCode = new Map<String, Integer>();
            Map<String, Age_of_Majority__mdt> mapAgeM = Age_of_Majority__mdt.getAll();
            for(String ageOfMajority : mapAgeM.keySet()){ 
                if (mapAgeM.get(ageOfMajority).Age__c != null) {
                    ageByCountryCode.put(
                        mapAgeM.get(ageOfMajority).DeveloperName,
                        mapAgeM.get(ageOfMajority).Age__c.intValue()
                    );
                }
            }
            
            Date birthDate = Date.valueOf(participant.Date_of_Birth__c);
            Integer participantAge = Date.newInstance(2000, birthDate.month(), birthDate.day()) <=
                Date.newInstance(2000, Date.today().month(), Date.today().day())
                ? Date.today().year() - birthDate.year()
                : Date.today().year() - birthDate.year() - 1;
            
            if (
                ageByCountryCode.get(
                    participant.Mailing_Country_Code__c +
                    '_' +
                    participant.Mailing_State_Code__c
                ) != null
            ) {
                needsGuardian =
                    participantAge <
                    ageByCountryCode.get(
                        participant.Mailing_Country_Code__c +
                        '_' +
                        participant.Mailing_State_Code__c
                    );
            } else if (ageByCountryCode.get(participant.Mailing_Country_Code__c) != null) {
                needsGuardian =
                    participantAge < ageByCountryCode.get(participant.Mailing_Country_Code__c);
            } else {
                needsGuardian = participantAge < 18;
            }
        }
        return '' + needsGuardian;
    }
    
    public static Participant__c createDelegateParticipant(
        Contact contactDelegate,
        String phoneType
    ) {
        Participant__c participantDelegate = new Participant__c(
            Adult__c = true,
            Contact__c = contactDelegate.Id,
            First_Name__c = contactDelegate.FirstName,
            Last_Name__c = contactDelegate.LastName,
            Email__c = contactDelegate.Email,
            Phone__c = contactDelegate.Phone,
            Mailing_City__c = contactDelegate.MailingCity,
            Mailing_Country_Code__c = contactDelegate.MailingCountryCode,
            Mailing_State__c = contactDelegate.MailingState,
            Mailing_Zip_Postal_Code__c = contactDelegate.MailingPostalCode,
            Phone_Type__c = phoneType
        );
        if (phoneType == 'Home') {
            participantDelegate.Phone__c = contactDelegate.HomePhone;
            participantDelegate.Alternative_Phone_Number__c = contactDelegate.MobilePhone;
        }
        if (phoneType == 'Mobile') {
            participantDelegate.Phone__c = contactDelegate.MobilePhone;
            participantDelegate.Alternative_Phone_Number__c = contactDelegate.HomePhone;
        } else {
            participantDelegate.Phone__c = contactDelegate.Phone;
            participantDelegate.Alternative_Phone_Number__c = contactDelegate.MobilePhone;
        }
        return participantDelegate;
    }
    
    public static ContactAndSiteType convertToDelegateContact(
        Integration_Patient_Referral__c ipr,
        Account participantAccount,
        String studySiteType
    ) {
        Contact newContact = new Contact(
            FirstName = ipr.Delegate_First_Name__c,
            MiddleName = ipr.Delegate_Middle_Name__c,
            LastName = ipr.Delegate_Last_Name__c,
            Email = ipr.Delegate_Email_Address__c,
            MailingCountryCode = ipr.Address_Country__c,
            MailingState = ipr.Delegate_Mailing_State__c==null && (ipr.Address_State__c!=null && 
                                                                   (ipr.Delegate_Zip_Postal_Code__c == null 
                                                                    ||(ipr.Delegate_Zip_Postal_Code__c!=null 
                                                                       && (ipr.Delegate_Zip_Postal_Code__c == ipr.Address_ZipCode__c)
                                                                      )
                                                                   )
                                                                  )?ipr.Address_State__c :ipr.Delegate_Mailing_State__c,
            MailingCity = ipr.Delegate_Mailing_City__c,
            MailingPostalCode = ipr.Delegate_Zip_Postal_Code__c==null && (ipr.Address_ZipCode__c!=null && 
                                                                          (ipr.Delegate_Mailing_State__c == null 
                                                                           ||(ipr.Delegate_Mailing_State__c!=null 
                                                                              && (ipr.Delegate_Mailing_State__c == ipr.Address_State__c)
                                                                             )
                                                                          )
                                                                         )?ipr.Address_ZipCode__c :ipr.Delegate_Zip_Postal_Code__c,
            AccountId = participantAccount.Id
        );
        if ('Home' == ipr.Delegate_Phone_Number_Type__c) {
            newContact.HomePhone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.MobilePhone = ipr.Delegate_Alternative_Phone_Number__c;
        }
        if ('Mobile' == ipr.Delegate_Phone_Number_Type__c) {
            newContact.MobilePhone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.HomePhone = ipr.Delegate_Alternative_Phone_Number__c;
        } else {
            newContact.Phone = ipr.Delegate_Daytime_Phone_Number__c;
            newContact.MobilePhone = ipr.Delegate_Alternative_Phone_Number__c;
        }
        newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
        newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
        newContact.UserCommunityIsDelegate__c = true;
        ContactAndSiteType conAndSt = new ContactAndSiteType(newContact, studySiteType);
        return conAndSt;
    }
    
    public static Participant_Enrollment__c createPE(
        Integration_Patient_Referral__c ipr,
        Id participantId,
        Id ssId,
        Study_Site__c ss,
        Boolean isAdult
    ) {
        
        Boolean filterCriteria =
            ss.Study_Site_Type__c!='Virtual'&& ss.Study_Site_Type__c!='Hybrid' &&
            ss != null &&
            ss.Clinical_Trial_Profile__c != null &&
            !ss.Suppress_Participant_Emails__c &&
            !ss.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
            ss.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c &&
            participantId != null ;
        
        
        Participant_Enrollment__c objPE = new Participant_Enrollment__c(
            Participant__c = participantId,
            Study_Site__c = ssId,
            Pre_Eligibility__c = ipr.Pass_Fail__c,
            Referral_Source__c = ipr.Data_Source__c,
            Patient_ID__c = ipr.ePRPatient_ID_Number__c,
            Referral_ID__c = ipr.referralID__c,
            Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
            Terms_and_Conditions_Accepted_Date__c = ipr.acceptedTermsAndConditions__c != null
                ? Date.valueOf(ipr.acceptedTermsAndConditions__c)
                : null,
            Referred_Date__c = ipr.Referred_Date__c != null
                ? Date.valueOf(ipr.Referred_Date__c)
                : null,
            Referred_By__c = 'Other',
            utm_campaign__c = ipr.UTM_campaignName__c,
            utm_content__c = ipr.UTM_campaignContent__c,
            utm_medium__c = ipr.UTM_campaignMedium__c,
            utm_source__c = ipr.UTM_campaignSource__c,
            utm_term__c = ipr.UTM_campaignTerm__c,
            utmz__c = ipr.UTM_campaignCookie__c,
            gclid__c = ipr.UTM_GCLID__c,
            Atid__c = ipr.Atid__c,
            HighRisk_Indicator__c = ipr.HighRisk_Indicator__c,
            Permit_IQVIA_to_contact_about_study__c = true,
            Study_PI_Storage_Consent_Time__c = Datetime.now(),
            Human_Id__c = ipr.Human_Id__c,
            Additional_Information__c = ipr.Additional_Information__c
        );
        if(filterCriteria && isAdult && String.isNotBlank(ipr.email__c)){
            objPE.Invited_To_PP_Date__c = DateTime.now(); 
        }
        if (ipr.Comorbidities__c == 'True')
            objPE.Comorbidities__c = 'Yes';
        else if (ipr.Comorbidities__c == 'False')
            objPE.Comorbidities__c = 'No';
        else
            objPE.Comorbidities__c = '';
        return objPE;
    }
}
