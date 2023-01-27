public without sharing class UploadParticipantsDelegateHelper {
    public static ErrorPatientDelegateWrapper createDelegateRecords(
        List<ParticipantsDelegateWrapper> ParticipantsDelegateWrapperList,
        Study_Site__c studySiteDetails,
        List<List<String>> csvLines,
        Boolean outreachEmail,
        Boolean outreachPhone,
        Boolean outreachSMS,
        Boolean outreachDirectMail
    ) {
        Map<Integer, Contact> mapContact = new Map<Integer, Contact>();
        Map<Integer, Integer> mapContactTrack = new Map<Integer, Integer>();
        Map<Integer, Participant__c> mapParticipant = new Map<Integer, Participant__c>();
        Map<Integer, Patient_Delegate__c> patientDelegateMap = new Map<Integer, Patient_Delegate__c>();
        Map<String, String> duplicateDelegateMainParticipantMap = new Map<String, String>();
        Set<Id> successfullyInsertedContactSet = new Set<Id>();
        Integer trackingNumberSuccess = 0;
        Set<Id> iqviaOutReachSet = new Set<Id>();
        Map<String, String> participantEmailMap = new Map<String, String>();
        ErrorPatientDelegateWrapper errorwrap = new ErrorPatientDelegateWrapper();
        //Used for update the contact and participant records which were identified as duplicates.
        List<Contact> contactUpdateList = new List<Contact>();
        List<Participant__c> participantUpdateList = new List<Participant__c>();

        //For Duplicate Row check in same sheet
        Set<String> duplicateRowCheckSet = new Set<String>();
        Map<String, String> duplicateRowMap = new Map<String, String>();
        Map<String, String> duplicateContactRowMap = new Map<String, String>();
        List<Id> contactInsertedIds = new List<Id>();
        String duplicateKey = '';
        set<Id> setMainParticipantId = new set<Id> ();
        for (ParticipantsDelegateWrapper pWrapper : ParticipantsDelegateWrapperList) {
            //Duplicate check in the sheet
            duplicateKey =
                pWrapper.DelegateFirstName +
                pWrapper.DelegateLastName +
                pWrapper.DelegateEmail;
            setMainParticipantId.add(pWrapper.mainparticipant.Id);
            if (!duplicateRowCheckSet.contains(duplicateKey)) {
                duplicateRowCheckSet.add(duplicateKey);
                //Duplicate check participant and contact records for existing records in the system
                ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                    null,
                    pWrapper.DelegateEmail,
                    pWrapper.DelegateFirstName,
                    pWrapper.DelegateLastName,
                    null
                );
                trackingNumberSuccess++;

                //Contact initiation
                Contact delegateContact = new Contact();
                delegateContact.FirstName = pWrapper.DelegateFirstName;
                delegateContact.LastName = pWrapper.DelegateLastName;
                delegateContact.Email = pWrapper.DelegateEmail;
                delegateContact.AccountId = studySiteDetails.Site__c;
                delegateContact.Language__c = UserInfo.getLanguage();
                delegateContact.Second_Choice_Language__c = '';
                delegateContact.Third_Choice_Language__c = '';
                delegateContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                delegateContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                delegateContact.userCommunityIsDelegate__c = true;
                delegateContact.MailingCountryCode = pWrapper.mainparticipant.Mailing_Country_Code__c;
                delegateContact.MailingStateCode = pWrapper.mainparticipant.Mailing_State_Code__c;
                delegateContact.MailingPostalCode = pWrapper.mainparticipant.Mailing_Zip_Postal_Code__c;

                if ('Home' == pWrapper.DelegatePhoneType) {
                    delegateContact.HomePhone = pWrapper.DelegatePhoneNo;
                }
                if ('Mobile' == pWrapper.DelegatePhoneType) {
                    delegateContact.MobilePhone = pWrapper.DelegatePhoneNo;
                } else {
                    delegateContact.Phone = pWrapper.DelegatePhoneNo;
                }

                //Participant initiation
                Participant__c participantDelegate = new Participant__c();
                participantDelegate.Adult__c = true;
                participantDelegate.First_Name__c = pWrapper.DelegateFirstName;
                participantDelegate.Last_Name__c = pWrapper.DelegateLastName;
                participantDelegate.Email__c = pWrapper.DelegateEmail;
                participantDelegate.Phone__c = pWrapper.DelegatePhoneNo;
                participantDelegate.Phone_Type__c = pWrapper.DelegatePhoneType;
                participantDelegate.Mailing_Country_Code__c = pWrapper.mainparticipant.Mailing_Country_Code__c;
                participantDelegate.Mailing_State_Code__c = pWrapper.mainparticipant.Mailing_State_Code__c;
                participantDelegate.Mailing_Zip_Postal_Code__c = pWrapper.mainparticipant.Mailing_Zip_Postal_Code__c;
                if (String.isBlank(ddInfo.contactId)) {
                    participantDelegate.Birth_Year__c = pWrapper.DelegateYOB;
                    participantDelegate.Attestation__c = true;
                    participantDelegate.Attested_by__c = CommunityService.getInstance()
                        .getCurrentContactId();
                    participantDelegate.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                }

                /*if a Phone number has been provided for minor, we will use that as delegate's alternate phone number with phone type as Home; REF-3242*/
                if (
                    !pWrapper.mainparticipant.Adult__c && !String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.DelegatePhoneNo;
                    participantDelegate.Phone_Type__c = pWrapper.DelegatePhoneType;
                    participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Alternative_Phone_Type__c = 'Home';
                } else if (
                    !pWrapper.mainparticipant.Adult__c && String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Phone_Type__c = 'Home';
                    participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Alternative_Phone_Type__c = 'Home';
                } else if (
                    pWrapper.mainparticipant.Adult__c && String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Phone_Type__c = pWrapper.ParticipantPhoneType;
                }
                //Patient Delegate initiation
                participantEmailMap.put(
                    pWrapper.mainparticipant.Id,
                    pWrapper.mainparticipant.Email__c
                );
                Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                ptDelegateRef.Participant__c = pWrapper.mainparticipant.Id;
                ptDelegateRef.Status__c = 'Disconnected';
                ptDelegateRef.Primary_Delegate__c = true;
                ptDelegateRef.Is_Created_by_Bulk_Import__c = true;
                if (
                    ddInfo == null ||
                    (String.isBlank(ddInfo.contactId) || ddInfo.participantId == null)
                ) {
                    if (!String.isBlank(ddInfo.contactId)) {
                        delegateContact = new Contact(Id = ddInfo.contactId);
                    }
                    mapContact.put(pWrapper.totalRecordCount, delegateContact);
                    mapContactTrack.put(trackingNumberSuccess, pWrapper.totalRecordCount);
                    mapParticipant.put(pWrapper.totalRecordCount, participantDelegate);
                    patientDelegateMap.put(pWrapper.totalRecordCount, ptDelegateRef);
                } else {
                    duplicateDelegateMainParticipantMap.put(
                        ddInfo.contactId,
                        pWrapper.mainparticipant.Id
                    );
                    duplicateContactRowMap.put(duplicateKey, ddInfo.contactId);
                    contactInsertedIds.add(ddInfo.contactId);
                }
            } else {
                //duplicateRowMap.put(duplicateKey, pWrapper.mainparticipant.Id);
                 String dupkeyWithId = duplicateKey+ pWrapper.mainparticipant.Id;
                 dupkeyWithId = dupkeyWithId.toLowercase();
                 duplicateRowMap.put(dupkeyWithId, pWrapper.mainparticipant.Id);
                participantEmailMap.put(
                    pWrapper.mainparticipant.Id,
                    pWrapper.mainparticipant.Email__c
                );
            }
        }

        //Insert the non-duplicate contact and assign the contact ID's to Participant list.
        List<Contact> contactToBeInserted = mapContact.values();
        Integer countIndex;
        //START :: Contact Insertion
        Database.UpsertResult[] saveRes = Database.upsert(contactToBeInserted, false);
        for (Integer i = 0; i < saveRes.size(); i++) {
            List<Integer> setToListCon = new List<Integer>(mapContactTrack.values());
            countIndex = setToListCon[i];
            if (saveRes[i].isSuccess()) {
                mapParticipant.get(countIndex).Contact__c = saveRes[i].getId();
                patientDelegateMap.get(countIndex).Contact__c = saveRes[i].getId();
                if (
                    patientDelegateMap.get(countIndex) != null &&
                    studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c &&
                    (participantEmailMap.get(patientDelegateMap.get(countIndex).Participant__c) ==
                    null ||
                    string.isBlank(
                        participantEmailMap.get(patientDelegateMap.get(countIndex).Participant__c)
                    ))
                ) {
                    iqviaOutReachSet.add(saveRes[i].getId());
                }
                successfullyInsertedContactSet.add(saveRes[i].getId());
                contactInsertedIds.add(saveRes[i].getId());
                duplicateContactRowMap.put(duplicateKey, saveRes[i].getId());
            } else {
                errorwrap.errorRecordCount++;
                Database.Error error = saveRes[i].getErrors().get(0);
                errorwrap.listOfFailedRecordsWithMsg.add(
                    '' +
                    countIndex +
                    ', ERROR on Delegate Contact record insert: ' +
                    error.getFields() +
                    ' ' +
                    error.getMessage()
                );
                if (!test.isRunningTest()) {
                    errorwrap.listOfFailedRecords.add(getCleanMessage(csvLines, countIndex));
                }
                mapParticipant.remove(countIndex);
            }
        }
        //END :: Contact insertion

        //START :: participants Insertion
        Map<Integer, Integer> mapParticipantTrack = new Map<Integer, Integer>();
        Integer j = 0;
        for (Integer i : mapParticipant.keySet()) {
            mapParticipantTrack.put(j, i);
            j++;
        }
        Integer countIndexParticipant;
        Database.SaveResult[] partiSR = Database.insert(mapParticipant.values(), false);
        for (Integer k = 0; k < partiSR.size(); k++) {
            List<Integer> setToListPart = new List<Integer>(mapParticipantTrack.keySet());
            countIndexParticipant = mapParticipantTrack.get(setToListPart[k]);
            if (!partiSR[k].isSuccess()) {
                errorwrap.errorRecordCount++;
                Database.Error error = partiSR[k].getErrors().get(0);
                errorwrap.listOfFailedRecordsWithMsg.add(
                    '' +
                    countIndexParticipant +
                    ', ERROR on Delegate Participant record insert: ' +
                    error.getFields() +
                    ' ' +
                    error.getMessage()
                );
                if (!test.isRunningTest()) {
                    errorwrap.listOfFailedRecords.add(
                        getCleanMessage(csvLines, countIndexParticipant)
                    );
                }
                mapParticipant.remove(countIndexParticipant);
            }
        }

        //END :: participants Insertion

        Map<String, String> dupDelMainParticipantMap = new Map<String, String>();
        Map<String, String> dupDelegateMainParticipantMap = new Map<String, String>();
        Map<String, Patient_Delegate__c> dupDelOtherPatientPrimaryDelegates = new Map<String, Patient_Delegate__c>();
        Map<String, Patient_Delegate__c> dupDelPatientCurrentNonPrimaryDelegates = new Map<String, Patient_Delegate__c>();
        if (!duplicateDelegateMainParticipantMap.isEmpty()) {
            for (
                Patient_Delegate__c patientDel : [
                    SELECT
                        ID,
                        Participant__c,
                        Contact__c,
                        Primary_Delegate__c,
                        Contact__r.Id,
                        Participant__r.Id,
                        Participant__r.Email__c
                    FROM Patient_Delegate__c
                    WHERE Participant__c IN :duplicateDelegateMainParticipantMap.values()
                    //AND Contact__r.Id IN :duplicateDelegateMainParticipantMap.keySet()
                ]
            ) {
                if (
                    patientDel.Primary_Delegate__c &&
                    (patientDel.Participant__r.Email__c == null ||
                    string.isBlank(patientDel.Participant__r.Email__c)) &&
                    studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c
                ) {
                    iqviaOutReachSet.add(patientDel.Contact__r.Id);
                }
                if (
                    duplicateDelegateMainParticipantMap.keySet().contains(patientDel.Contact__r.Id)
                ) {
                    dupDelegateMainParticipantMap.put(
                        patientDel.Contact__r.Id,
                        patientDel.Participant__r.Id
                    );
                    if (!patientDel.Primary_Delegate__c) {
                        dupDelPatientCurrentNonPrimaryDelegates.put(
                            patientDel.Contact__r.Id,
                            patientDel
                        );
                    }
                } else if (patientDel.Primary_Delegate__c) {
                    dupDelOtherPatientPrimaryDelegates.put(
                        patientDel.Participant__r.Id,
                        patientDel
                    );
                }
            }
            List<Patient_Delegate__c> updatePDs = new List<Patient_Delegate__c>();
            for (String cntId : duplicateDelegateMainParticipantMap.keySet()) {
                if (
                    duplicateDelegateMainParticipantMap.get(cntId) != null &&
                    !(dupDelegateMainParticipantMap.keySet().contains(cntId)) &&
                    (dupDelegateMainParticipantMap.get(cntId) !=
                    duplicateDelegateMainParticipantMap.get(cntId))
                ) {
                    dupDelMainParticipantMap.put(
                        cntId,
                        duplicateDelegateMainParticipantMap.get(cntId)
                    );
                } else if (
                    duplicateDelegateMainParticipantMap.get(cntId) != null &&
                    dupDelegateMainParticipantMap.keySet().contains(cntId)
                ) {
                    if (
                        !dupDelPatientCurrentNonPrimaryDelegates.isEmpty() &&
                        dupDelPatientCurrentNonPrimaryDelegates.containsKey(cntId)
                    ) {
                        Patient_Delegate__c currentPd = dupDelPatientCurrentNonPrimaryDelegates.get(
                            cntId
                        );
                        currentPd.Primary_Delegate__c = true;
                        updatePDs.add(currentPd);
                        if (
                            !dupDelOtherPatientPrimaryDelegates.isEmpty() &&
                            dupDelOtherPatientPrimaryDelegates.containsKey(
                                dupDelPatientCurrentNonPrimaryDelegates.get(cntId).Participant__c
                            )
                        ) {
                            Patient_Delegate__c oldPd = dupDelOtherPatientPrimaryDelegates.get(
                                dupDelPatientCurrentNonPrimaryDelegates.get(cntId).Participant__c
                            );
                            oldPd.Primary_Delegate__c = false;
                            updatePDs.add(oldPd);
                        }
                    }
                }
            }
            if (!updatePDs.isEmpty()) {
                Database.update(updatePDs, false);
            }
        }

        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>(
            patientDelegateMap.values()
        );
        for (String contactIdKey : dupDelMainParticipantMap.keySet()) {
            Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
            ptDelegateRef.Contact__c = contactIdKey;
            ptDelegateRef.Participant__c = dupDelMainParticipantMap.get(contactIdKey);
            ptDelegateRef.Status__c = 'Disconnected';
            ptDelegateRef.Primary_Delegate__c = true;
            ptDelegateRef.Is_Created_by_Bulk_Import__c = true;
            pdList.add(ptDelegateRef);
            if (
                participantEmailMap != null &&
                studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c &&
                (participantEmailMap.get(ptDelegateRef.Participant__c) == null ||
                string.isBlank(participantEmailMap.get(ptDelegateRef.Participant__c)))
            ) {
                iqviaOutReachSet.add(contactIdKey);
            }
        }

        List<Patient_Delegate__c> pdDuplicateList = new List<Patient_Delegate__c>();
        
        List<Contact> dupContList = new List<Contact>();
        if(contactInsertedIds != null &&
           !contactInsertedIds.isEmpty() && contactInsertedIds.size() != 0)
         {   
            dupContList = [Select Id,FirstName,LastName,Email,(Select First_Name__c,Last_Name__c,Email__c from Participants__r) from Contact where Id IN:contactInsertedIds];         
         }
         Map<String,String> keyWithContactID = new Map<String,String>();
         if(dupContList != null && !dupContList.isEmpty() && dupContList.size() != 0){
            String contKey='';
            for(Contact c:dupContList){
                  if(c.FirstName != null && c.LastName != null){
                      contKey = c.FirstName+c.LastName+c.Email;
                      contKey = contKey.toLowercase(); 
                  }else{
                      if(c.Participants__r != null){
                         contKey = c.Participants__r[0].First_Name__c+c.Participants__r[0].Last_Name__c+c.Email;
                         contKey = contKey.toLowercase();
                      }
                  }    
                keyWithContactID.put(contKey,c.Id);
                contKey='';
            }
        }
        
        if (duplicateRowMap != null) {
            for (String key : duplicateRowMap.keySet()) {
                String contactId = '';
                String mainparticipantId = '';
                 String dupkey = key.substring(0, key.length()-18);
                if (
                    duplicateRowMap != null &&
                    duplicateRowMap.get(key) != null &&
                    keyWithContactID != null && 
                   !keyWithContactID.isEmpty()
                ) {
                    //contactId = duplicateContactRowMap.get(dupkey);
                     contactId = keyWithContactID.get(dupkey);
                    mainparticipantId = duplicateRowMap.get(key);
                    Patient_Delegate__c pd = createPatientDelegate(contactId, mainparticipantId);
                    pdDuplicateList.add(pd);
                    if (
                        participantEmailMap != null &&
                        studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c &&
                        (participantEmailMap.get(pd.Participant__c) == null ||
                        string.isBlank(participantEmailMap.get(pd.Participant__c)))
                    ) {
                        iqviaOutReachSet.add(contactId);
                    }
                }
            }
            if (!pdDuplicateList.isEmpty()) {
                pdList.addAll(pdDuplicateList);
            }
        }

        if (!pdList.isEmpty()) {
            String communityTemplateName = UserContext.getCurrentCommunityTemplate().templateName;
            if (
                studySiteDetails.Study_Site_Type__c == StudySiteService.SS_TYPE_TRADITIONAL &&
                (studySiteDetails.Suppress_Participant_Emails__c ||
                studySiteDetails.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c) &&
                (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT ||
                communityTemplateName == CommunityTemplateService.TEMPLATE_PP)
            ) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
            }
            Database.SaveResult[] perSR = Database.insert(pdList, false);
            for (Integer k = 0; k < perSR.size(); k++) {
                if (!perSR[k].isSuccess()) {
                    errorwrap.errorRecordCount++;
                    mapParticipant.remove(countIndexParticipant);
                    Database.Error error = perSR[k].getErrors().get(0);
                    errorwrap.listOfFailedRecordsWithMsg.add(
                        '' +
                        countIndexParticipant +
                        ', ERROR on patient delegate record insert: ' +
                        error.getFields() +
                        ' ' +
                        error.getMessage()
                    );
                    if (!test.isRunningTest()) {
                        errorwrap.listOfFailedRecords.add(
                            getCleanMessage(csvLines, countIndexParticipant)
                        );
                    }
                }
            }
        }
        Map<id,id> participantToPatientDelMap = new map<id,id>();
        
        for(Patient_Delegate__c getPatientDelegate : [Select id, Participant__c from Patient_Delegate__c where 
                                                      Participant__c IN :setMainParticipantId  
                                                      and Primary_Delegate__c=true] ){

                     participantToPatientDelMap.put(getPatientDelegate.Participant__c,getPatientDelegate.id);
                    }
        
        List<Patient_Delegate_Enrollment__c> updatePatientDelEnroll= new List<Patient_Delegate_Enrollment__c> ();
        for( Patient_Delegate_Enrollment__c pder: [select id,Participant_Enrollment__c,Participant_Enrollment__r.Participant__c ,Patient_Delegate__c
                                                from Patient_Delegate_Enrollment__c where 
                                                Participant_Enrollment__r.Participant__c in : setMainParticipantId 
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
        //Update the delegate contact with Delegate Participant Name
        Map<Id, Participant__c> contactToPart = new Map<Id, Participant__c>();
        for (Participant__c p : [
            SELECT Id, Name, Contact__c
            FROM Participant__c
            WHERE Contact__c IN :successfullyInsertedContactSet
        ]) {
            contactToPart.put(p.Contact__c, p);
        }
        List<Contact> conListtoBeUpdated = new List<Contact>();
        for (Id c : successfullyInsertedContactSet) {
            Contact cc = new Contact();
            cc.Id = c;
            cc.FirstName = null;
            if (!test.isRunningTest()) {
                cc.LastName = contactToPart.get(c).Name;
            }
            if (iqviaOutReachSet != null && iqviaOutReachSet.contains(c)) {
                cc.Participant_Opt_In_Status_Emails__c = outreachEmail;
                cc.Participant_Opt_In_Status_SMS__c = outreachSMS;
                cc.Participant_Phone_Opt_In_Permit_Phone__c = outreachPhone;
                cc.IQVIA_Artificial_Voice_Consent__c = outreachPhone;
                cc.IQVIA_Assisted_Dialing_Consent__c = outreachPhone;
                cc.IQVIA_Pre_recorded_Voice_Consent__c = outreachPhone;
                cc.IQVIA_Direct_Mail_Consent__c = outreachDirectMail;
                iqviaOutReachSet.remove(c);
            }
            conListtoBeUpdated.add(cc);
        }
        for (Id consent : iqviaOutReachSet) {
            Contact cc = new Contact();
            cc.Id = consent;
            cc.Participant_Opt_In_Status_Emails__c = outreachEmail;
            cc.Participant_Opt_In_Status_SMS__c = outreachSMS;
            cc.Participant_Phone_Opt_In_Permit_Phone__c = outreachPhone;
            cc.IQVIA_Artificial_Voice_Consent__c = outreachPhone;
            cc.IQVIA_Assisted_Dialing_Consent__c = outreachPhone;
            cc.IQVIA_Pre_recorded_Voice_Consent__c = outreachPhone;
            cc.IQVIA_Direct_Mail_Consent__c = outreachDirectMail;
            conListtoBeUpdated.add(cc);
        }
        if (!conListtoBeUpdated.isEmpty()) {
            update conListtoBeUpdated;
        }
        return errorwrap;
    }

    //This is a genric method which will be used to resolve data truncation issue in output file.
    public static String getCleanMessage(List<List<String>> csvString, Integer count) {
        String cleanMessage;
        String strValue = '';
        for (String str : csvString.get(count - 1)) {
            strValue = String.isNotBlank(strValue) ? strValue + ',' + str : str;
        }
        cleanMessage = ('' + strValue).removeStart('(').removeEnd(')') + ', ' + count;
        return cleanMessage;
    }

    public static Patient_Delegate__c createPatientDelegate(
        String contactId,
        String mainparticipantId
    ) {
        Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
        ptDelegateRef.Contact__c = contactId;
        ptDelegateRef.Participant__c = mainparticipantId;
        ptDelegateRef.Status__c = 'Disconnected';
        ptDelegateRef.Primary_Delegate__c = true;
        ptDelegateRef.Is_Created_by_Bulk_Import__c = true;
        return ptDelegateRef;
    }

    public static void updateDelegateRecords(
        List<ParticipantsDelegateWrapper> ParticipantsDelegateWrapperList
    ) {
        Map<Id, Participant__c> participantUpdateMap = new Map<Id, Participant__c>();

        ReferHealthcareProviderRemote.HealthcareProvider ddInfo;
        for (ParticipantsDelegateWrapper pWrapper : ParticipantsDelegateWrapperList) {
            ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                null,
                pWrapper.DelegateEmail,
                pWrapper.DelegateFirstName,
                pWrapper.DelegateLastName,
                null
            );
            //Participant initiation
            Participant__c participantDelegate = new Participant__c();
            Boolean isUpdateRequired = false;
            if (ddInfo != null && ddInfo.participantId != null) {
                participantDelegate.Id = ddInfo.participantId;
                if (!String.isBlank(pWrapper.DelegatePhoneNo)) {
                    participantDelegate.Phone__c = pWrapper.DelegatePhoneNo;
                    participantDelegate.Phone_Type__c = pWrapper.DelegatePhoneType;
                    isUpdateRequired = true;
                }
                if (
                    pWrapper.isParticipantAdult == false &&
                    !String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.DelegatePhoneNo;
                    participantDelegate.Phone_Type__c = pWrapper.DelegatePhoneType;
                    participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Alternative_Phone_Type__c = 'Home';
                    isUpdateRequired = true;
                } else if (
                    pWrapper.isParticipantAdult == false && String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Phone_Type__c = 'Home';
                    participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Alternative_Phone_Type__c = 'Home';
                    isUpdateRequired = true;
                } else if (
                    pWrapper.isParticipantAdult == true && String.isBlank(pWrapper.DelegatePhoneNo)
                ) {
                    participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                    participantDelegate.Phone_Type__c = pWrapper.ParticipantPhoneType;
                    isUpdateRequired = true;
                }
                if (isUpdateRequired == true) {
                    participantUpdateMap.put(participantDelegate.Id, participantDelegate);
                }
            }
        }
        try {
            if (!participantUpdateMap.values().isEmpty()) {
                Database.SaveResult[] delegateSR = Database.update(
                    participantUpdateMap.values(),
                    false
                );
                //Update participantUpdateMap.values();
            }
        } catch (Exception exp) {
            system.debug('Delegate Update::' + exp.getMessage() + ' ' + exp.getStackTraceString());
        }
    }

    public class ErrorPatientDelegateWrapper {
        public SET<String> listOfFailedRecordsWithMsg = new Set<String>();
        public SET<String> listOfFailedRecords = new Set<String>();
        public Integer errorRecordCount = 0;
    }

    public class ParticipantsDelegateWrapper {
        public Participant__c mainparticipant;
        public String DelegateFirstName;
        public String DelegateLastName;
        public String DelegateEmail;
        public String DelegatePhoneNo;
        public String DelegatePhoneType;
        public String ParticipantPhoneNo;
        public String ParticipantPhoneType;
        public Integer totalRecordCount;
        public String DelegateAgeOfMajority;
        public String DelegateYOB;
        public Boolean isParticipantAdult;
    }
}