public without sharing class Batch_UpsertEprParticipantAndPE implements Database.Batchable<sObject> {
    
    private Account tempAccount; 
    public static boolean eprBatchRunning = false;
    
    public Batch_UpsertEprParticipantAndPE(){
        tempAccount = new Account();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        tempAccount.Name = guid;
        insert tempAccount;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        return Database.getQueryLocator(
            [SELECT Comorbidities__c,UTM_campaignSource__c,UTM_campaignTerm__c,UTM_campaignCookie__c,UTM_GCLID__c,Atid__c,HighRisk_Indicator__c,
             Id,UTM_campaignMedium__c,UTM_campaignContent__c,UTM_campaignName__c,Referred_Date__c,acceptedTermsAndConditions__c,
             MRR_Survey_Results_URL__c,ePRPatient_ID_Number__c, Pass_Fail__c,Name,Ethnicity__c, Batch_consideration__c, Is_retry_required__c,
             Address_AddressLine1__c, Address_City__c, Address_Country__c, Address_State__c, Address_ZipCode__c, BirthDate__c, birthYear__c, BMI__c,Preferred_Contact_Time__c, 
             Data_Source__c, Delegate_Alternative_Phone_Number__c, Delegate_Daytime_Phone_Number__c, Delegate_Email_Address__c, Delegate_First_Name__c, 
             Delegate_Last_Name__c, Delegate_Mailing_City__c, Delegate_Mailing_State__c, Delegate_Middle_Name__c, Delegate_Phone_Number_Type__c, 
             Delegate_Zip_Postal_Code__c, email__c, firstName__c, Language_Preference__c, lastName__c, Middle_Initial__c, Participant_MobileNumber__c, 
             phone__c, Phone_Type__c, protocolId__c, referralID__c, sex__c, siteSelected__c,Human_Id__c,Additional_Information__c FROM Integration_Patient_Referral__c 
             WHERE Batch_consideration__c = 'Not completed' limit 1000 ]
        );
        
    }
    
	public void execute(Database.BatchableContext bc, List<Integration_Patient_Referral__c> initialScope) {
        eprBatchRunning = true;
        Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        Map<String, Integration_Patient_Referral__c> newMap = new Map<String, Integration_Patient_Referral__c>();
        Map<String, Participant__c> newParticipantsMap = new Map<String, Participant__c>();
        Map<String, Participant__c> dupParticipantsMap = new Map<String, Participant__c>();
        Map<String, IprEprTriggerHandler.ContactAndSiteType> newDelegateContactsMap = new Map<String, IprEprTriggerHandler.ContactAndSiteType>();
        Map<String,string> referralAccMap = new Map<String,string>();
        Map<String, String> IPRContDupKeyPhoneTypeMap = new Map<String, String>(); 
        Map<string,string> IPRContDupKeyDelDayTimePhoneNoMap = new map<string,string>(); 
        Map<string,string> IPRContDupKeyDelAltPhoneNoMap = new map<string,string>(); 
        
        List<String> protocolIds = new List<String>();
        List<String> ssNumbersList = new List<String>();
        Set<Participant__c> duplicatePatientsList = new Set<Participant__c>();
        Set<Id> duplicatePatientsSet = new Set<Id>();
        List<String> uniqueIPRList = new List<String>();
        List<String> uniqueDelList = new List<String>();
        Map<String,Integration_Patient_Referral__c> iprRPMap = new Map<String,Integration_Patient_Referral__c>();
        List<Integration_Patient_Referral__c> scope = new List<Integration_Patient_Referral__c>();
        //For Patient Outreach Flow
        List<String> patientOutrachProtocolIds = new List<String>();
        List<String> patientOutrachSSNumbersList = new List<String>();
        Map<String, Integration_Patient_Referral__c> patientOutrachNewMap = new Map<String, Integration_Patient_Referral__c>();

        for (Integration_Patient_Referral__c ipr : initialScope) {
            if(!uniqueIPRList.contains(ipr.firstName__c+'_'+ipr.lastName__c+'_'+ipr.BirthDate__c+'_'+ipr.email__c+'_'+ipr.phone__c+'_'+ipr.protocolId__c)){
                if(!uniqueDelList.contains(ipr.Delegate_Email_Address__c) || ipr.Delegate_Email_Address__c== null){
                    //ipr.Batch_consideration__c = 'Completed';
                    //protocolIds.add(ipr.protocolId__c);
                    //ssNumbersList.add(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
                    //newMap.put(ipr.referralID__c, ipr);
                    //scope.add(ipr);
                    if(ipr.Delegate_Email_Address__c != null) uniqueDelList.add(ipr.Delegate_Email_Address__c);
                    uniqueIPRList.add(ipr.firstName__c+'_'+ipr.lastName__c+'_'+ipr.BirthDate__c+'_'+ipr.email__c+'_'+ipr.phone__c+'_'+ipr.protocolId__c);
                    //Store IPR records which are coming from Patient outreach
                    if(!String.isBlank(ipr.UTM_campaignName__c) && ipr.UTM_campaignName__c.startsWith('REF')) {
                        ipr.Batch_consideration__c = 'Completed';
                        patientOutrachProtocolIds.add(ipr.protocolId__c);
                        patientOutrachSSNumbersList.add(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
                        patientOutrachNewMap.put(ipr.referralID__c, ipr);
                        iprRPMap.put(ipr.UTM_campaignName__c,ipr);
                    }
                    else {
                        ipr.Batch_consideration__c = 'Completed';
                        protocolIds.add(ipr.protocolId__c);
                        ssNumbersList.add(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
                        newMap.put(ipr.referralID__c, ipr);
                        scope.add(ipr);
                    }
                }
            }
        }

        //Process IPR sepratly based on PER records which comes from patient outreach and alreday present in the RH
        if(!iprRPMap.isEmpty()) {
            ProcessIPRForPatientOutreachHelper.processIPRForPatientOutreach(
                iprRPMap,
                tempAccount,
                patientOutrachProtocolIds,
                patientOutrachSSNumbersList,
                patientOutrachNewMap
            );
        }

        //SS Map
        List<Study_Site__c> ssList = [
            SELECT
            Id,
            Protocol_ID__c,
            Primary_Key_ePR__c,
            Study_Site_Type__c,
            Site__c,
            Override_PI_Referral_Status__c,
            Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
            Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
            Suppress_Participant_Emails__c,
            Participant_DOB_format__c 
            FROM Study_Site__c
            WHERE Primary_Key_ePR__c IN :ssNumbersList
        ];
        for (Study_Site__c ss : ssList)
            ssByPrimaryKeyEPRMap.put(ss.Primary_Key_ePR__c, ss);
        
        //CTP Map
        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, Override_Recruitment_Status__c, Protocol_ID__c
            FROM Clinical_Trial_Profile__c
            WHERE Protocol_ID__c IN :protocolIds
        ];
        for (Clinical_Trial_Profile__c ctp : ctpList)
            ctpByProtocolIdMap.put(ctp.Protocol_ID__c, ctp);    
        
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Participant__c participantExisting;
        list<ParticipantDuplicateService.ParticipantWithDelegate> partDelegateWrapperList =  new list<ParticipantDuplicateService.ParticipantWithDelegate>();
        for (Integration_Patient_Referral__c ipr : scope) { 
            ParticipantDuplicateService.ParticipantWithDelegate partDelegateWrapper = new ParticipantDuplicateService.ParticipantWithDelegate();
            partDelegateWrapper.participant = new Participant__c();
            Study_Site__c ss = ssByPrimaryKeyEPRMap.get(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
            
            //if (!String.isBlank(ipr.BirthDate__c)) {
            List<String> dateOfBirth = ipr.BirthDate__c.split('-');
            String mmValue;
            String ddValue;
            String yyyyValue;
            if(string.isNotBlank(ss.Participant_DOB_format__c) && ss.Participant_DOB_format__c == 'DD-MM-YYYY'){
                if(dateOfBirth.size() > 2){
                    ddValue = dateOfBirth[2];
                    mmValue = dateOfBirth[1];
                }else if(dateOfBirth.size() > 1){
                    mmValue = dateOfBirth[1];
                }
            }else if(string.isNotBlank(ss.Participant_DOB_format__c) && ss.Participant_DOB_format__c == 'MM-YYYY'){
                if(dateOfBirth.size() > 1){
                    mmValue = dateOfBirth[1];
                }
            }
            yyyyValue = dateOfBirth[0];
            Integer mm = String.isNotBlank(mmValue) ? Integer.valueof(mmValue) : 12;
            Integer dd = String.isNotBlank(ddValue) ? Integer.valueof(ddValue) : Date.daysInMonth(Integer.valueOf(yyyyValue), mm);
            Date birthDate = Date.newInstance( 
                Integer.valueOf(yyyyValue),mm,dd
            );
            Integer participantAge = Date.newInstance(
                2000,
                birthDate.month(),
                birthDate.day()
            ) <= Date.newInstance(2000, Date.today().month(), Date.today().day())
            ? Date.today().year() - birthDate.year()
            : Date.today().year() - birthDate.year() - 1;
            mmValue = String.valueof(mm);
            ddValue = String.valueof(dd);
            if(mm < 10){
               mmValue = '0'+mm;
            }
            if(dd < 10){
                ddValue = '0'+dd;
            }
            string tempBrVar = ipr.BirthDate__c;
            ipr.BirthDate__c = yyyyValue + '-'+mmValue+'-'+ddValue;
            Participant__c objParticipant = IprEprTriggerHandler.convertToParticipant(ipr);
            ipr.BirthDate__c = tempBrVar ;
            objParticipant.Age__c = participantAge;
            if(string.isNotBlank(ss.Participant_DOB_format__c) && ss.Participant_DOB_format__c == 'DD-MM-YYYY'){
                if(dateOfBirth.size() > 2){
                    objParticipant.Birth_Day__c = ddValue;
                    objParticipant.Birth_Month__c = mmValue;
                }else if(dateOfBirth.size() > 1){
                    objParticipant.Birth_Month__c = mmValue;
                }
            }else if(string.isNotBlank(ss.Participant_DOB_format__c) && ss.Participant_DOB_format__c == 'MM-YYYY'){
                if(dateOfBirth.size() > 1){
                    objParticipant.Birth_Month__c = mmValue;
                }
            }
            objParticipant.Birth_Year__c = yyyyValue;
            objParticipant.Date_of_Birth__c = null;
            Account participantAccount = new Account(Id = ss.Site__c);
            objParticipant.Site__c = ss.Site__c;
            newParticipantsMap.put(ipr.referralID__c, objParticipant);
            partDelegateWrapper.participant = objParticipant;
            if (
                ss != null &&
                !String.isBlank(ipr.Delegate_First_Name__c) &&
                !String.isBlank(ipr.Delegate_Last_Name__c) &&
                !String.isEmpty(ipr.siteSelected__c) &&
                !String.isEmpty(ipr.protocolId__c) &&
                !String.isEmpty(ipr.firstName__c) &&
                !String.isEmpty(ipr.lastName__c) &&
                !String.isEmpty(ipr.Delegate_Daytime_Phone_Number__c) &&
                !String.isEmpty(ipr.Delegate_Email_Address__c))
            {
                newDelegateContactsMap.put(
                    ipr.referralID__c,
                    IprEprTriggerHandler.convertToDelegateContact(ipr, participantAccount, ss.Study_Site_Type__c)
                );
                //Populate Maps to udpate the duplicate delegate phone number if delegate comes with different Participant with updated delegate phone number
                String duplicateKey = ipr.Delegate_Email_Address__c?.toLowerCase() + ipr.Delegate_First_Name__c?.toLowerCase() + ipr.Delegate_Last_Name__c?.toLowerCase();
                IPRContDupKeyPhoneTypeMap.put(duplicateKey, ipr.Delegate_Phone_Number_Type__c); 
                IPRContDupKeyDelDayTimePhoneNoMap.put(duplicateKey, ipr.Delegate_Daytime_Phone_Number__c); 
                IPRContDupKeyDelAltPhoneNoMap.put(duplicateKey, ipr.Delegate_Alternative_Phone_Number__c);                 
                partDelegateWrapper.delegate = new Participant__c();
                partDelegateWrapper.delegate.Email__c = ipr.Delegate_Email_Address__c;
                partDelegateWrapper.delegate.First_Name__c = ipr.Delegate_First_Name__c;
                partDelegateWrapper.delegate.Last_Name__c = ipr.Delegate_Last_Name__c;
                partDelegateWrapper.delegate.Phone__c = ipr.Delegate_Daytime_Phone_Number__c;
            }
            partDelegateWrapperList.add(partDelegateWrapper);
        }

        //Duplicates check and upsert participant
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(
            partDelegateWrapperList
        );
        Map<String, String> participantsByEmailRefid = new Map<String, String>();
        Map<String,Contact> iprAndContactsToInsert = new Map<String,Contact>();
        Map<String, String> conEmailAccMap = new Map<String, String>();
        Map<Id, Id> dupPartContMap = new Map<Id, Id>();

        //REF-4741
        Map<Id, Participant__c> dupPartUpdateMap = new Map<Id, Participant__c>();
        list<Participant__c> dupPartToUpdateList = new list<Participant__c>();
        
        for (Integration_Patient_Referral__c ipr : scope) {
            Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
            Participant__c participantDuplicate = duplicateService.findDuplicate(participant);
            Contact contactDuplicate = duplicateService.findDuplicateContact(participant);
            if (participantDuplicate != null && contactDuplicate!= null){
                dupPartContMap.put(contactDuplicate.Id, participantDuplicate.Id);
            }
            
			//Append Referral Secondary Source to the duplicate Participant 
            if (participantDuplicate != null) {
                String refSourceStr = participantDuplicate.Secondary_Source__c;
                if (refSourceStr == null)
                    refSourceStr = '';
                Set<String> refSources = new Set<String>(refSourceStr.split(';'));
                refSources.add(ipr.Data_Source__c);
                participantDuplicate.Secondary_Source__c = String.join(
                    new List<String>(refSources),
                    ';'
                );
                if(participant.Birth_Day__c!=null){
                    participantDuplicate.Birth_Day__c = participant.Birth_Day__c;
                }
                if(participant.Birth_Month__c!=null){
                    participantDuplicate.Birth_Month__c = participant.Birth_Month__c;
                }
                if(participant.Birth_Year__c!=null){
                    participantDuplicate.Birth_Year__c = participant.Birth_Year__c;
                }
                newParticipantsMap.remove(ipr.referralID__c);
                dupParticipantsMap.put(ipr.referralID__c, participantDuplicate);
                duplicatePatientsSet.add(participantDuplicate.Id);
                //
                if (participantDuplicate.Contact__c == null) {
                    Contact newContact = new Contact();
                    newContact.LastName = participantDuplicate.Last_Name__c;
                    newContact.Email = participantDuplicate.Email__c;
                    newContact.AccountId = tempAccount.id;
                    newContact.Language__c = participantDuplicate.Preferred_Language__c;
                    newContact.Second_Choice_Language__c = '';
                    newContact.Third_Choice_Language__c = '';
                    newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.MailingCity = participantDuplicate.Mailing_City__c;
                    newContact.MailingCountryCode = participantDuplicate.Mailing_Country_Code__c;
                    newContact.MailingStateCode = participantDuplicate.Mailing_State_Code__c;
                    newContact.MailingPostalCode = participantDuplicate.Mailing_Zip_Postal_Code__c;
                    iprAndContactsToInsert.put(ipr.referralID__c,newContact);
                    participantsByEmailRefid.put(participantDuplicate.Email__c, ipr.referralID__c);
                    String duplicateKey = newContact.Email?.toLowerCase() + newContact.LastName?.toLowerCase();
                    conEmailAccMap.put(duplicateKey,participantDuplicate.Site__c);
                } 

                //REF-4741
                Participant__c dupPartToUdate = new Participant__c();
                dupPartToUdate.id = participantDuplicate.Id;
                if(participant.Preferred_Contact_Time__c != NULL || String.isNotBlank(participant.Preferred_Contact_Time__c))
                dupPartToUdate.Preferred_Contact_Time__c = participant.Preferred_Contact_Time__c;
                dupPartUpdateMap.put(dupPartToUdate.id,dupPartToUdate);
                //               
            } else {
                if (contactDuplicate != null)
                    participant.Contact__c = contactDuplicate.Id;
                newParticipantsMap.put(ipr.referralID__c, participant);
                //
                if (participant.Contact__c == null) {
                    Contact newContact = new Contact();
                    newContact.LastName = participant.Last_Name__c;
                    newContact.Email = participant.Email__c;
                    newContact.AccountId = tempAccount.id;
                    newContact.Language__c = participant.Preferred_Language__c;
                    newContact.Second_Choice_Language__c = '';
                    newContact.Third_Choice_Language__c = '';
                    newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.MailingCity = participant.Mailing_City__c;
                    newContact.MailingCountryCode = participant.Mailing_Country_Code__c;
                    newContact.MailingStateCode = participant.Mailing_State_Code__c;
                    newContact.MailingPostalCode = participant.Mailing_Zip_Postal_Code__c;
                    iprAndContactsToInsert.put(ipr.referralID__c,newContact);
                    participantsByEmailRefid.put(participant.Email__c, ipr.referralID__c);
                    String duplicateKey = newContact.Email?.toLowerCase() + newContact.LastName?.toLowerCase();
                    conEmailAccMap.put(duplicateKey,participant.Site__c);
                }
                //
            }
            
        }
        insert iprAndContactsToInsert.values();
        for(String ipr : iprAndContactsToInsert.keySet()) {
            if(newParticipantsMap.containsKey(ipr)){
                newParticipantsMap.get(ipr).Contact__c = iprAndContactsToInsert.get(ipr).Id;
            }
            if(dupParticipantsMap.containsKey(ipr)){
                dupParticipantsMap.get(ipr).Contact__c = iprAndContactsToInsert.get(ipr).Id;
            }
            
        }
        
        Set<Participant__c> newParticipantsSet = new Set<Participant__c>(newParticipantsMap.values());
        List<Participant__c> newParticipantsList = new List<Participant__c>(newParticipantsSet);
        insert newParticipantsList;
        
        //Insert PE
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        Map<Id, Id> participantIdByParticipantDelegateContactId = new Map<Id, Id>();
        Set<Id> delegateIds = new Set<Id>();
        List<Participant__c> delegateParticipants = new List<Participant__c>();
        for (Integration_Patient_Referral__c ipr : scope) {
            Participant__c participant = new Participant__c();
            if(newParticipantsMap.containsKey(ipr.referralID__c)){
                participant = newParticipantsMap.get(ipr.referralID__c);
            }
            if(dupParticipantsMap.containsKey(ipr.referralID__c)){
                participant = dupParticipantsMap.get(ipr.referralID__c);
            }
            
            Study_Site__c ss = ssByPrimaryKeyEPRMap.get(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
            participant.Site__c = ss.Site__c;
            if (ss != null)
                peList.add(IprEprTriggerHandler.createPE(ipr, participant.Id, ss.Id,ss,participant.Adult__c));
        }
        List<String> PEErrorMsg = new List<String>();
       List<Database.SaveResult> saveResults = Database.insert(peList, false);
        
        Set<Id> participantsWithoutErrors = new Set<Id>();
        list<Integration_Patient_Referral__c> iprListToUpdate = new list<Integration_Patient_Referral__c>();
        list<contact> contactsToDelete = new list<contact>();
        List<Participant_PrescreenerResponse__c> screenerResponseList = new List<Participant_PrescreenerResponse__c>();
        List<Patient_Delegate_Enrollment__c> patientDelEnrollList = new List<Patient_Delegate_Enrollment__c>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            Participant_Enrollment__c pe = peList[i];	
            Database.SaveResult sr = saveResults[i];
            Integration_Patient_Referral__c ipr = newMap.get(pe.Referral_ID__c);
            if (ipr != null) {
                if (sr.isSuccess()) {
                    participantsWithoutErrors.add(pe.Participant__c);
                    ipr.Batch_consideration__c = 'Completed';
                    ipr.Participant_Enrollment__c = sr.getId();

                    if(dupParticipantsMap.containsKey(pe.Referral_ID__c)){
                        Participant__c dupPart = dupParticipantsMap.get(ipr.referralID__c);
                        //REF-4741
                        if(dupPartUpdateMap.containsKey(pe.Participant__c)){
                            dupPart.Preferred_Contact_Time__c = dupPartUpdateMap.get(pe.Participant__c).Preferred_Contact_Time__c;
                        }
                        //
                        dupPartToUpdateList.add(dupPart);   
                        newParticipantsMap.put(ipr.referralID__c, dupPart);                     
                    }
                    if(String.isNotBlank(ipr.MRR_Survey_Results_URL__c)) {
                        screenerResponseList.add(
                            new Participant_PrescreenerResponse__c(
                                Completed_Date__c = Datetime.now(),
                                Participant_enrollment__c = sr.getId(),
                                Screener_Response__c = ipr.MRR_Survey_Results_URL__c,
                                Status__c = 'Pass',
                                MRR_EPR__c = true
                            )
                        );
                    }
                   if( !String.isBlank(ipr.Delegate_First_Name__c) &&
                       !String.isBlank(ipr.Delegate_Last_Name__c) &&
                       !String.isEmpty(ipr.Delegate_Daytime_Phone_Number__c) &&
                       !String.isEmpty(ipr.Delegate_Email_Address__c))
                    {
                    patientDelEnrollList.add(
                        new Patient_Delegate_Enrollment__c(
                            Status__c = 'Disconnected',
                            Participant_Enrollment__c = sr.getId(),
                            Primary_Delegate__c = true,
                            Study_info_storage_consent__c=true,
                            Study_Storage_Consent_Time__c = Datetime.now()
                        )
                    );
                }

                } else {
                    ipr.Batch_consideration__c = 'Completed';
                    ipr.Error_Message__c = EPR_Validation_Message__mdt.getinstance('enrollment_duplicate').Error_Message__c;
                    if(ipr.Error_Message__c != null){
                        PEErrorMsg.add(ipr.Error_Message__c);
                    }
                    if(dupParticipantsMap.containsKey(pe.Referral_ID__c)){
                        if(iprAndContactsToInsert.containsKey(pe.Referral_ID__c))
                            contactsToDelete.add(new contact(id = dupParticipantsMap.get(pe.Referral_ID__c).Contact__c));
                    }
                }
                iprListToUpdate.add(ipr);
            }
        }
        update iprListToUpdate;

        insert screenerResponseList;
        
        if(!patientDelEnrollList.isEmpty()){
            insert patientDelEnrollList;
        }
        //REF-4741
        if(!dupPartToUpdateList.isEmpty())
            update dupPartToUpdateList;

        if(!contactsToDelete.isEmpty()){
            delete contactsToDelete;
        }
        
        set<Contact> updateDelegateContacts = new set<Contact>();
        List<Contact> newDelegateContacts = new List<Contact>();
        Map<Id, Participant__c> delegateParticipantsMap = new Map<Id, Participant__c>();
        List<IprEprTriggerHandler.ContactAndSiteType> cntList = new List<IprEprTriggerHandler.ContactAndSiteType>();
        Set<String> duplicateRowCheckSet = new Set<String>(); 
        Map<string,Contact> IPRDupContKeyContMap = new Map<string,Contact>();
       
        
        if (!newDelegateContactsMap.isEmpty()) {
            for(String ref : newParticipantsMap.keySet()){
                if(!duplicatePatientsSet.contains(newParticipantsMap.get(ref).Id) || participantsWithoutErrors.contains(newParticipantsMap.get(ref).Id)){
                    if(newDelegateContactsMap.containsKey(ref)){
                        IprEprTriggerHandler.ContactAndSiteType cnt =  newDelegateContactsMap.get(ref); 
                        cntList.add(cnt);
                        newDelegateContacts.add(cnt.contactObj);
						//Create Dele
                        String duplicateKey = cnt.ContactObj.email?.toLowerCase() + 
                            				  cnt.ContactObj.firstName?.toLowerCase() + 
                            				  cnt.ContactObj.lastName?.toLowerCase();
                        
                        //For Duplicate Row check in current Payloads
                        if(!duplicateRowCheckSet.contains(duplicateKey)){
                            duplicateRowCheckSet.add(duplicateKey);
                            //Duplicate check participant and contact records for existing records in the system
                            ReferHealthcareProviderRemote.HealthcareProvider hp 
                                = ReferHealthcareProviderRemote.checkDuplicate(null,
                                                                               cnt.contactObj.Email,
                                                                               cnt.contactObj.FirstName,
                                                                               cnt.contactObj.LastName,
                                                                               null);
                            
                            
                            //If Duplicate contact found for delegate.
                            if(hp.contactId!=null){
                                String hpDuplicateKey = hp.email?.toLowerCase() + hp.firstName?.toLowerCase() + hp.lastName?.toLowerCase();
                                IPRDupContKeyContMap.put(hpduplicateKey, hp.conObject);
                               
                            }
                        }
                    }
                }
            }
            
        }
        
        contact contactUpdate ;
        for (Contact con : newDelegateContacts) {
            String duplicateKey = con.email?.toLowerCase() + con.firstName?.toLowerCase() + con.lastName?.toLowerCase();
            //Check if the Delegate contact is already present in system
            if(IPRDupContKeyContMap.containskey(duplicateKey)){
                con = IPRDupContKeyContMap.get(duplicateKey);
                //Update phone number of existing delegate if comes with defferent participant with Updated phone number
                String delDayTimePhoneNo = IPRContDupKeyDelDayTimePhoneNoMap.get(duplicateKey);
                String delAltPhoneNo = IPRContDupKeyDelAltPhoneNoMap.get(duplicateKey); 
                Boolean updateExistingContPhoneNo = false;
                
                if ('Home' ==IPRContDupKeyPhoneTypeMap.get(duplicateKey)) {
                    //Check if Duplicate delegate came with updated phone number,if yes Update the phone number on contact. 
                    if(!String.isEmpty(delDayTimePhoneNo) && delDayTimePhoneNo!=con.HomePhone){
                        con.HomePhone = delDayTimePhoneNo; 
                        updateExistingContPhoneNo=true;
                    }
                    if(!String.isEmpty(delAltPhoneNo) && delAltPhoneNo!=con.MobilePhone){
                        con.MobilePhone = delAltPhoneNo;
                        updateExistingContPhoneNo=true;
                    }   
                }else if ('Mobile' == IPRContDupKeyPhoneTypeMap.get(duplicateKey)) {
                     //Check if Duplicate delegate came with updated phone number,if yes Update the phone number on contact. 
                    if(!String.isEmpty(delDayTimePhoneNo) && delDayTimePhoneNo!=con.MobilePhone){
                        con.MobilePhone = delDayTimePhoneNo; 
                        updateExistingContPhoneNo=true;
                    }
                    if(!String.isEmpty(delAltPhoneNo) && delAltPhoneNo!=con.HomePhone){
                        con.HomePhone = delAltPhoneNo;
                        updateExistingContPhoneNo=true;
                    }   
                } else {
                    //Check if Duplicate delegate came with updated phone number,if yes Update the phone number on contact. 
                    if(!String.isEmpty(delDayTimePhoneNo) && delDayTimePhoneNo!=con.Phone){
                        con.Phone = delDayTimePhoneNo; 
                        updateExistingContPhoneNo=true;
                    }
                    if(!String.isEmpty(delAltPhoneNo) && delAltPhoneNo!=con.MobilePhone){
                        con.MobilePhone = delAltPhoneNo;
                        updateExistingContPhoneNo=true;
                    }  
                }
                //If phone number is updated on existing delegate 
                if(updateExistingContPhoneNo==true){
                    string participantAccountId = con.AccountId;
                    con.AccountId = tempAccount.id;	
                    String duplicateKeyoldCont = con.email?.toLowerCase() + con.firstName?.toLowerCase() + con.lastName?.toLowerCase();
                    //referralAccMap.put(con.FirstName+'_'+con.MiddleName+'_'+con.LastName+'_'+con.Email, participantAccountid);
                    referralAccMap.put(duplicateKeyoldCont, participantAccountid);
                    updateDelegateContacts.add(con);
                    
                }
            }else{
                string participantAccountId = con.AccountId;
                con.AccountId = tempAccount.id;	
                //referralAccMap.put(con.FirstName+'_'+con.MiddleName+'_'+con.LastName+'_'+con.Email, participantAccountid);
                referralAccMap.put(duplicateKey, participantAccountid);
                updateDelegateContacts.add(con);
            }
        }
        
        
        if (!updateDelegateContacts.isEmpty()) {
            upsert new list<contact>(updateDelegateContacts);
        }
 
        for (Integration_Patient_Referral__c ipr : scope) {
            if(newParticipantsMap.containsKey(ipr.referralID__c)){
                Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
                IprEprTriggerHandler.ContactAndSiteType participantDelegateContactAndSiteType = newDelegateContactsMap.get(ipr.referralID__c);
                
                if(participantsWithoutErrors.contains(participant.Id)){
                    if (participantDelegateContactAndSiteType != null){
                        contact con = participantDelegateContactAndSiteType.contactObj;
                        String duplicateKey = con.email?.toLowerCase() + con.firstName?.toLowerCase() + con.lastName?.toLowerCase();
                        if(!(IPRDupContKeyContMap.containsKey(duplicateKey))){
                            delegateParticipantsMap.put(
                                participant.Id,
                                IprEprTriggerHandler.createDelegateParticipant(
                                    participantDelegateContactAndSiteType.contactObj,
                                    ipr.Delegate_Phone_Number_Type__c
                                )
                            );
                            
                            Contact participantDelegateContact = participantDelegateContactAndSiteType.contactObj;

                            participantIdByParticipantDelegateContactId.put(
                                participantDelegateContact.Id,
                                participant.Id
                            );
                            delegateIds.add(participantDelegateContact.Id);
                        }
                        else {
                            string contactUpdateId = IPRDupContKeyContMap.get(duplicateKey).Id;
                            
                            participantIdByParticipantDelegateContactId.put(contactUpdateId, participant.Id);
                            delegateIds.add(contactUpdateId);
                            
                        }
                    }
                }
            }            
        }
        
        //Duplicate delegate logic
        if (!delegateParticipantsMap.values().isEmpty()) {
            ParticipantDuplicateService duplicateDelService = new ParticipantDuplicateService(delegateParticipantsMap.values());
            for (Id participantId : delegateParticipantsMap.keySet()) {
                Participant__c delegateParticipant = delegateParticipantsMap.get(participantId);
                Participant__c delParticipantDuplicate = duplicateService.findDuplicateDelegate(delegateParticipant);
                if (delParticipantDuplicate != null && !duplicatePatientsSet.contains(participantId)){
                    delegateParticipantsMap.put(participantId, delParticipantDuplicate);
                }
            }
            upsert delegateParticipantsMap.values();
        }
        
        
        
        //Patient Delegate logic 
        List<Patient_Delegate__c> ptDelegateList = new List<Patient_Delegate__c>();
        List<Patient_Delegate__c> ptDelegateRefs = new List<Patient_Delegate__c>();        
        Map<Id, Id> existingPdMap = new Map<Id, Id>();
        
        //If existing participant entering into system without delegate and different study
        if(!duplicatePatientsSet.isEmpty()){    
            for(Patient_Delegate__c pd:[SELECT Id,
                                        Contact__c,
                                        Participant__c,
                                        Participant__r.Id,
                                        Primary_Delegate__c
                                        FROM Patient_Delegate__c
                                        WHERE Participant__c IN: participantsWithoutErrors 
                                        AND Participant__c IN: duplicatePatientsSet
                                       ])
            {
                if(pd.Primary_Delegate__c == True && 
                   !(participantIdByParticipantDelegateContactId.values().contains(pd.Participant__r.Id))){
                       pd.Primary_Delegate__c = False;
                       ptDelegateList.add(pd);
                   } 
            }  
            update ptDelegateList;
        }             
        
        //Create Patient delegate
        if (!delegateIds.isEmpty()) {
            Set<Id> ptDelegateContSet = new Set<Id>();
            Set<Id> participantSet = new Set<Id>();
            Map<Id, Id> delegateUsersToCreate = new Map<Id, Id>();
            for (IprEprTriggerHandler.ContactAndSiteType ndc : cntList) {
                
                Contact participantDelegateContact = ndc.contactObj;
                string cntId = participantDelegateContact.Id;
                String duplicateKey = participantDelegateContact.email?.toLowerCase() + participantDelegateContact.firstName?.toLowerCase() + participantDelegateContact.lastName?.toLowerCase(); 
                if(cntId == null || cntId == ''){
                    cntId = IPRDupContKeyContMap.get(duplicateKey).Id;   
                }  
                Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                ptDelegateRef.Participant__c = participantIdByParticipantDelegateContactId.get(cntId);
                ptDelegateRef.Contact__c = cntId;
                ptDelegateRef.Primary_Delegate__c = True;
                ptDelegateRef.Status__c = 'Disconnected';
                if(!duplicatePatientsSet.contains(ptDelegateRef.Participant__c) && participantsWithoutErrors.contains(ptDelegateRef.Participant__c)){
                    ptDelegateRefs.add(ptDelegateRef);
                }    
                
                ptDelegateContSet.add(ptDelegateRef.Contact__r.Id); 
                participantSet.add(ptDelegateRef.Participant__r.Id);
                if (
                    ndc != null &&
                    ndc.siteType != 'Virtual' &&
                    ndc.siteType != 'Hybrid' &&
                    !IPRDupContKeyContMap.containsKey(duplicateKey)
                   
                ) {
                    delegateUsersToCreate.put(cntId, null);
                }
            }
            
            if (!participantSet.isEmpty()) {
                for(Participant_Enrollment__c particpantEnroll : [SELECT
                                                                  Id,
                                                                  Study_Site__r.Study_Site_Type__c,
                                                                  Study_Site__r.Suppress_Participant_Emails__c,
                                                                  Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                                                                  Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                                                                  FROM Participant_Enrollment__c
                                                                  WHERE Participant__c IN :participantSet
                                                                 ]){
                                                                     
                                                                     if (
                                                                         particpantEnroll.Study_Site__r.Study_Site_Type__c == StudySiteService.SS_TYPE_TRADITIONAL &&
                                                                         (particpantEnroll.Study_Site__r.Suppress_Participant_Emails__c ||
                                                                          particpantEnroll.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ||
                                                                          particpantEnroll.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_JANSSEN
                                                                         )
                                                                     ) {
                                                                         TriggerHandlerExecutor.bypassHandler(
                                                                             PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                                                                         );
                                                                     }
                                                                 }                                                     
                
            }
            if (!delegateUsersToCreate.isEmpty()) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(delegateUsersToCreate);
            }
            
            insert ptDelegateRefs;
            Map<id,id> participantToPatientDelMap = new map<id,id>();
            if (!participantsWithoutErrors.isEmpty()) {

            for(Patient_Delegate__c getPatientDelegate : [Select id, Participant__c from
                        Patient_Delegate__c where 
                        Participant__c IN :participantsWithoutErrors  and Primary_Delegate__c=true] ){

                         participantToPatientDelMap.put(getPatientDelegate.Participant__c,getPatientDelegate.id);
                        }
            
            List<Patient_Delegate_Enrollment__c> updatePatientDelEnroll= new List<Patient_Delegate_Enrollment__c> ();
            for( Patient_Delegate_Enrollment__c pder: [select id,Participant_Enrollment__c,Participant_Enrollment__r.Participant__c ,Patient_Delegate__c
                                                    from Patient_Delegate_Enrollment__c where 
                                                    Participant_Enrollment__r.Participant__c in : participantsWithoutErrors 
                                                    and Patient_Delegate__c=null]){
                                                        if(participantToPatientDelMap.containsKey(pder.Participant_Enrollment__r.Participant__c))
                                                        {
                                                            pder.Patient_Delegate__c=ParticipantToPatientDelMap.get(pder.Participant_Enrollment__r.Participant__c);
                                                            updatePatientDelEnroll.add(pder);
                                                        }
                                                        
            }
            if(!updatePatientDelEnroll.isEmpty()){
                update updatePatientDelEnroll;
            }
         }
            
            
        }
        
        Map <Id,Contact> contactsToUpdateMap = new Map <Id,Contact>();
        if (!updateDelegateContacts.isEmpty()) { 
            for(contact con : updateDelegateContacts){
                String duplicateKey = con.email?.toLowerCase() + con.firstName?.toLowerCase() + con.lastName?.toLowerCase();
                contact c = new contact();
                c.id = con.id;
                c.AccountId = referralAccMap.get(duplicateKey);
                if(!contactsToUpdateMap.containsKey(c.Id)){
					contactsToUpdateMap.put(c.Id,c);
				}
            }  
        }
        if (!iprAndContactsToInsert.values().isEmpty()) { 
            for(contact con : iprAndContactsToInsert.values()){
                String duplicateKey = con.Email?.toLowerCase() + con.LastName?.toLowerCase();
                contact c = new contact();
                c.id = con.id;
                c.AccountId = conEmailAccMap.get(duplicateKey);
               	if(!contactsToUpdateMap.containsKey(c.Id)){ 
					contactsToUpdateMap.put(c.Id,c);
				}
            }
        }
        
        if(!contactsToUpdateMap.values().isEmpty()){
			update contactsToUpdateMap.values();
		}     
        
    }
 
    public void finish(Database.BatchableContext bc) {
        //delete the temporary account
        try{
            delete tempAccount;
        } catch (Exception exp) {
            system.debug('ERROR during deleting records: ' + exp.getMessage());
        }
        finally {
			String isAbortJob =Label.Abort_Batch_UpsertEprParticipantAndPE;
           if(!test.isRunningTest() && isAbortJob!='True')
            	Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 7);
        }
        
    }
}
