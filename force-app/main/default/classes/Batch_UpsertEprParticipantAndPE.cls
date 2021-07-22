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
             Address_AddressLine1__c, Address_City__c, Address_Country__c, Address_State__c, Address_ZipCode__c, BirthDate__c, birthYear__c, BMI__c, 
             Data_Source__c, Delegate_Alternative_Phone_Number__c, Delegate_Daytime_Phone_Number__c, Delegate_Email_Address__c, Delegate_First_Name__c, 
             Delegate_Last_Name__c, Delegate_Mailing_City__c, Delegate_Mailing_State__c, Delegate_Middle_Name__c, Delegate_Phone_Number_Type__c, 
             Delegate_Zip_Postal_Code__c, email__c, firstName__c, Language_Preference__c, lastName__c, Middle_Initial__c, Participant_MobileNumber__c, 
             phone__c, Phone_Type__c, protocolId__c, referralID__c, sex__c, siteSelected__c FROM Integration_Patient_Referral__c 
             WHERE Batch_consideration__c = 'Not completed' limit 1000 ]
        );
        
    }
    
	public void execute(Database.BatchableContext bc, List<Integration_Patient_Referral__c> initialScope) {
        eprBatchRunning = true;
        Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        Map<String, Integration_Patient_Referral__c> newMap = new Map<String, Integration_Patient_Referral__c>();
        Map<String, Participant__c> newParticipantsMap = new Map<String, Participant__c>();
        Map<String, IprEprTriggerHandler.ContactAndSiteType> newDelegateContactsMap = new Map<String, IprEprTriggerHandler.ContactAndSiteType>();
        Map<String,string> referralAccMap = new Map<String,string>();
        
        List<String> protocolIds = new List<String>();
        List<String> ssNumbersList = new List<String>();
        Set<Participant__c> duplicatePatientsList = new Set<Participant__c>();
        Set<Id> duplicatePatientsSet = new Set<Id>();
        List<String> uniqueIPRList = new List<String>();
        List<String> uniqueDelList = new List<String>();
        List<Integration_Patient_Referral__c> scope = new List<Integration_Patient_Referral__c>();
        for (Integration_Patient_Referral__c ipr : initialScope) {
            if(!uniqueIPRList.contains(ipr.firstName__c+'_'+ipr.lastName__c+'_'+ipr.BirthDate__c+'_'+ipr.email__c+'_'+ipr.phone__c+'_'+ipr.protocolId__c)){
                if(!uniqueDelList.contains(ipr.Delegate_Email_Address__c) || ipr.Delegate_Email_Address__c== null){
                    ipr.Batch_consideration__c = 'Completed';
                    protocolIds.add(ipr.protocolId__c);
                    ssNumbersList.add(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
                    newMap.put(ipr.referralID__c, ipr);
                    scope.add(ipr);
                    if(ipr.Delegate_Email_Address__c != null) uniqueDelList.add(ipr.Delegate_Email_Address__c);
                    uniqueIPRList.add(ipr.firstName__c+'_'+ipr.lastName__c+'_'+ipr.BirthDate__c+'_'+ipr.email__c+'_'+ipr.phone__c+'_'+ipr.protocolId__c);
                }
            }
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
            Suppress_Participant_Emails__c
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
        
        for (Integration_Patient_Referral__c ipr : scope) { 
            
            Study_Site__c ss = ssByPrimaryKeyEPRMap.get(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
            Participant__c objParticipant = IprEprTriggerHandler.convertToParticipant(ipr);
            Account participantAccount = new Account(Id = ss.Site__c);
            objParticipant.Site__c = ss.Site__c;
            newParticipantsMap.put(ipr.referralID__c, objParticipant);
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
            }
        }
        //Duplicates check and upsert participant
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(
            newParticipantsMap.values()
        );
        Map<String, String> participantsByEmailRefid = new Map<String, String>();
        List<Contact> contactsToInsert = new List<Contact>();
        Map<String, String> conEmailAccMap = new Map<String, String>();
        Map<Id, Id> dupPartContMap = new Map<Id, Id>();
        //REF-4338
        Map<Id, Participant__c> dupPartUpdateMap = new Map<Id, Participant__c>();
        list<Participant__c> dupPartToUpdateList = new list<Participant__c>();

        for (Integration_Patient_Referral__c ipr : scope) {
            Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
            Participant__c participantDuplicate = duplicateService.findDuplicate(participant);
            Contact contactDuplicate = duplicateService.findDuplicateContact(participant);
            if (participantDuplicate != null && contactDuplicate!= null){
                dupPartContMap.put(contactDuplicate.Id, participantDuplicate.Id);
            }
            
            if (participantDuplicate != null) {
                String refSourceStr = participantDuplicate.Secondary_Source__c;
                if (refSourceStr == null)
                    refSourceStr = '';
                Set<String> refSources = new Set<String>(refSourceStr.split(';'));
                refSources.add(ipr.Data_Source__c);                
                newParticipantsMap.put(ipr.referralID__c, participantDuplicate);
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
                    contactsToInsert.add(newContact);
                    participantsByEmailRefid.put(participantDuplicate.Email__c, ipr.referralID__c);
                    conEmailAccMap.put(newContact.Email,participantDuplicate.Site__c);
                }
                //REF-4338
                Participant__c dupPartToUdate = new Participant__c();
                dupPartToUdate.id = participantDuplicate.Id;
                dupPartToUdate.Secondary_Source__c = String.join(
                    new List<String>(refSources),
                    ';'
                );
                dupPartToUdate.email__c = participant.email__c;
                dupPartToUdate.phone__c = participant.phone__c;
                dupPartUpdateMap.put(dupPartToUdate.id,dupPartToUdate);
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
                    contactsToInsert.add(newContact);
                    participantsByEmailRefid.put(participant.Email__c, ipr.referralID__c);
                    conEmailAccMap.put(newContact.Email,participant.Site__c);
                }
                //
            }
            
        }
        insert contactsToInsert;
        
        for (Contact newContact : contactsToInsert) {
            newParticipantsMap.get(participantsByEmailRefid.get(newContact.Email)).Contact__c = newContact.Id;    
        }
        
        Set<Participant__c> newParticipantsSet = new Set<Participant__c>(newParticipantsMap.values());
        List<Participant__c> newParticipantsList = new List<Participant__c>(newParticipantsSet);
        upsert newParticipantsList;
        
        //Insert PE
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        Map<Id, Id> participantIdByParticipantDelegateContactId = new Map<Id, Id>();
        Set<Id> delegateIds = new Set<Id>();
        List<Participant__c> delegateParticipants = new List<Participant__c>();
        for (Integration_Patient_Referral__c ipr : scope) {
            Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
            Study_Site__c ss = ssByPrimaryKeyEPRMap.get(IprEprTriggerHandler.getSitePrimaryKeyEPR(ipr));
            participant.Site__c = ss.Site__c;
            if (ss != null)
                peList.add(IprEprTriggerHandler.createPE(ipr, participant.Id, ss.Id,ss,participant.Adult__c));
        }
        List<String> PEErrorMsg = new List<String>();
        List<Database.SaveResult> saveResults = Database.insert(peList, false);
        Set<Id> participantsWithoutErrors = new Set<Id>();
        list<Integration_Patient_Referral__c> iprListToUpdate = new list<Integration_Patient_Referral__c>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            Participant_Enrollment__c pe = peList[i];	
            Database.SaveResult sr = saveResults[i];
            Integration_Patient_Referral__c ipr = newMap.get(pe.Referral_ID__c);
            if (ipr != null) {
                if (sr.isSuccess()) {
                    participantsWithoutErrors.add(pe.Participant__c);
                    ipr.Batch_consideration__c = 'Completed';
                    ipr.Participant_Enrollment__c = sr.getId();
                    //REF-4338
                    if(dupPartUpdateMap.containsKey(pe.Participant__c))
                        dupPartToUpdateList.add(dupPartUpdateMap.get(pe.Participant__c));
                } else {
                    ipr.Batch_consideration__c = 'Completed';
                    ipr.Error_Message__c = EPR_Validation_Message__mdt.getinstance('enrollment_duplicate').Error_Message__c;
                    if(ipr.Error_Message__c != null){
                        PEErrorMsg.add(ipr.Error_Message__c);
                    }
                }
                iprListToUpdate.add(ipr);
            }
        }
        update iprListToUpdate;
        //REF-4338
        update dupPartToUpdateList;
        
        set<string> emails = new Set<string>();
        set<Contact> updateDelegateContacts = new set<Contact>();
        List<Contact> newDelegateContacts = new List<Contact>();
        Map<Id, Participant__c> delegateParticipantsMap = new Map<Id, Participant__c>();
        List<IprEprTriggerHandler.ContactAndSiteType> cntList = new List<IprEprTriggerHandler.ContactAndSiteType>();
        
        if (!newDelegateContactsMap.isEmpty()) {
            for(String ref : newParticipantsMap.keySet()){
                if(!duplicatePatientsSet.contains(newParticipantsMap.get(ref).Id) || participantsWithoutErrors.contains(newParticipantsMap.get(ref).Id)){
                    if(newDelegateContactsMap.containsKey(ref)){
                        IprEprTriggerHandler.ContactAndSiteType cnt =  newDelegateContactsMap.get(ref); 
                        cntList.add(cnt);
                    }
                }
            }
            
            for (IprEprTriggerHandler.ContactAndSiteType newDelCon : cntList){
                newDelegateContacts.add(newDelCon.contactObj);
                emails.add(newDelCon.contactObj.Email);
            }
        }
        map<string,contact> oldContactEmailMap = new map<string,contact> ();
        for(contact con : [SELECT Id, FirstName, Email, Phone,MiddleName,LastName, AccountId FROM Contact	WHERE Email IN :emails	LIMIT :limitRows]){
            oldContactEmailMap.put(con.email,con);
        }
        
        contact contactUpdate ;
        for (Contact con : newDelegateContacts) {
            if(oldContactEmailMap.keyset().contains(con.email)){
                //con.id = oldContactEmailMap.get(con.email).id;
                con = oldContactEmailMap.get(con.email);
            }
            string participantAccountId = con.AccountId ;
            con.AccountId = tempAccount.id;	
            referralAccMap.put(con.FirstName+'_'+con.MiddleName+'_'+con.LastName+'_'+con.Email, participantAccountid);
            updateDelegateContacts.add(con);
        }
        
        if (!updateDelegateContacts.isEmpty()) {
            upsert new list<contact>(updateDelegateContacts);
        }
        for (Integration_Patient_Referral__c ipr : scope) {
            Participant__c participant = newParticipantsMap.get(ipr.referralID__c);
            IprEprTriggerHandler.ContactAndSiteType participantDelegateContactAndSiteType = newDelegateContactsMap.get(ipr.referralID__c);
            
            if(participantsWithoutErrors.contains(participant.Id)){
                if (participantDelegateContactAndSiteType != null){
                    if(!(oldContactEmailMap.keyset().contains(participantDelegateContactAndSiteType.contactObj.email))){
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
                        string contactUpdateId = oldContactEmailMap.get(participantDelegateContactAndSiteType.contactObj.email).id;
                        participantIdByParticipantDelegateContactId.put(contactUpdateId, participant.Id);
                        delegateIds.add(contactUpdateId);
                        
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
                if(cntId == null || cntId == '') cntId = oldContactEmailMap.get(participantDelegateContact.email).Id;
                
                Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                ptDelegateRef.Participant__c = participantIdByParticipantDelegateContactId.get(cntId);
                ptDelegateRef.Contact__c = cntId;
                ptDelegateRef.Primary_Delegate__c = True;
                ptDelegateRef.Status__c = 'Disconnected';
                if(!duplicatePatientsSet.contains(ptDelegateRef.Participant__c) || participantsWithoutErrors.contains(ptDelegateRef.Participant__c)){
                    ptDelegateRefs.add(ptDelegateRef);
                }    
                
                ptDelegateContSet.add(ptDelegateRef.Contact__r.Id); 
                participantSet.add(ptDelegateRef.Participant__r.Id);
                if (
                    ndc != null &&
                    ndc.siteType != 'Virtual' &&
                    ndc.siteType != 'Hybrid' &&
                    !oldContactEmailMap.containsKey(participantDelegateContact.email)
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
        }
        
        list<contact> contactsToUpdate = new list<contact>();
        if (!updateDelegateContacts.isEmpty()) { 
            for(contact con : updateDelegateContacts){
                contact c = new contact();
                c.id = con.id;
                c.AccountId = referralAccMap.get(con.FirstName+'_'+con.MiddleName+'_'+con.LastName+'_'+con.Email);
                contactsToUpdate.add(c);
            }
        }   
        if (!contactsToInsert.isEmpty()) { 
            for(contact con : contactsToInsert){
                contact c = new contact();
                c.id = con.id;
                c.AccountId = conEmailAccMap.get(con.email);
                contactsToUpdate.add(c);
            }
        }
        
        update contactsToUpdate;           
        
    }
    
    public void finish(Database.BatchableContext bc) {
        //delete the temporary account
        try{
            delete tempAccount;
        } catch (Exception exp) {
            system.debug('ERROR during deleting records: ' + exp.getMessage());
        }
        finally {
            Database.executeBatch(new Batch_UpsertEprParticipantAndPE(), 50);
        }
        
    }
}