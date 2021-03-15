public without sharing class UploadParticipantsDelegateHelper { 
    
    public static ErrorPatientDelegateWrapper createDelegateRecords(List<ParticipantsDelegateWrapper> ParticipantsDelegateWrapperList,Study_Site__c studySiteDetails, 
    List<List<String>> csvLines) {
        Map<Integer,Contact> mapContact = new Map<Integer,Contact>();
        Map<Integer,Integer> mapContactTrack = new Map<Integer,Integer>();
        Map<Integer,Participant__c> mapParticipant = new Map<Integer,Participant__c>();
        Map<Integer,Patient_Delegate__c> patientDelegateMap = new Map<Integer,Patient_Delegate__c>();
        Map<String,String> duplicateDelegateMainParticipantMap = new Map<String,String>();
        Set<Id> successfullyInsertedContactSet = new Set<Id>();
        Integer trackingNumberSuccess = 0;
        ErrorPatientDelegateWrapper errorwrap = new ErrorPatientDelegateWrapper();
        for(ParticipantsDelegateWrapper pWrapper : ParticipantsDelegateWrapperList) {   
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
            if('Home' == pWrapper.DelegatePhoneType) {
                delegateContact.HomePhone = pWrapper.DelegatePhoneNo;
            }
            if('Mobile' == pWrapper.DelegatePhoneType) {
                delegateContact.MobilePhone = pWrapper.DelegatePhoneNo;
            } 
            else {
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
            /*if a Phone number has been provided for minor, we will use that as delegate phone number; addtionally, we have a Primary Delegate phone number - 
            if one is provided there additionally, we will store it as alternate phone number for the delegate.*/
            if(!pWrapper.mainparticipant.Adult__c && !String.isBlank(pWrapper.DelegatePhoneNo)) {
                participantDelegate.Phone__c = pWrapper.DelegatePhoneNo;
                participantDelegate.Phone_Type__c = pWrapper.DelegatePhoneType;
                participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                participantDelegate.Alternative_Phone_Type__c = 'Home';
                
            }else if(!pWrapper.mainparticipant.Adult__c && String.isBlank(pWrapper.DelegatePhoneNo)){
                participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                participantDelegate.Phone_Type__c = 'Home';
                participantDelegate.Alternative_Phone_Number__c = pWrapper.ParticipantPhoneNo;
                participantDelegate.Alternative_Phone_Type__c = 'Home';
            }else if(pWrapper.mainparticipant.Adult__c && String.isBlank(pWrapper.DelegatePhoneNo)){
                participantDelegate.Phone__c = pWrapper.ParticipantPhoneNo;
                participantDelegate.Phone_Type__c = pWrapper.ParticipantPhoneType;
            }
            //Patient Delegate initiation 
            Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
            ptDelegateRef.Participant__c = pWrapper.mainparticipant.Id;
            //Duplicate check participant and contact records
            ReferHealthcareProviderRemote.HealthcareProvider ddInfo = 
                ReferHealthcareProviderRemote.checkDuplicate(null, pWrapper.DelegateEmail, pWrapper.DelegateFirstName, pWrapper.DelegateLastName, null); 
             trackingNumberSuccess++;

            if(ddInfo == null || String.isBlank(ddInfo.contactId) || ddInfo.participantId == null) {
                mapContact.put(pWrapper.totalRecordCount,delegateContact);
                mapContactTrack.put(trackingNumberSuccess,pWrapper.totalRecordCount);
                mapParticipant.put(pWrapper.totalRecordCount,participantDelegate);
                patientDelegateMap.put(pWrapper.totalRecordCount,ptDelegateRef);
            }
            else {
                duplicateDelegateMainParticipantMap.put(ddInfo.contactId,pWrapper.mainparticipant.Id);
            }
        }

        //Insert the non-duplicate contact and assign the contact ID's to Participant list.
        List<Contact> contactToBeInserted = mapContact.values();
        Integer countIndex;
        //START :: Contact Insertion
        Database.SaveResult[] saveRes = Database.insert(contactToBeInserted,false);
        for(Integer i=0;i<saveRes.size();i++) {
            List<Integer> setToListCon = new List<Integer>(mapContactTrack.values());
            countIndex = setToListCon[i];
            if(saveRes[i].isSuccess()) {
                mapParticipant.get(countIndex).Contact__c = saveRes[i].getId();
                patientDelegateMap.get(countIndex).Contact__c = saveRes[i].getId();
                successfullyInsertedContactSet.add(saveRes[i].getId());
            }
            else {
                errorwrap.errorRecordCount++;
                Database.Error error = saveRes[i].getErrors().get(0);
                errorwrap.listOfFailedRecordsWithMsg.add('' +countIndex +', ERROR on Participant Contact record insert: ' +error.getFields() +' ' + error.getMessage() );
                errorwrap.listOfFailedRecords.add(('' + csvLines.get(countIndex - 1)).removeStart('(').removeEnd(')') +', ' +countIndex);
                mapParticipant.remove(countIndex);
            }
        }
        //END :: Contact insertion
        
        //START :: participants Insertion
        Map<Integer,Integer> mapParticipantTrack = new Map<Integer,Integer>();
        Integer j=0;
        for(Integer i:mapParticipant.keySet()) {
            mapParticipantTrack.put(j,i);
            j++;
        }
        Integer countIndexParticipant;
        Database.SaveResult[] partiSR = Database.insert(mapParticipant.values(),false);
        for(Integer k=0; k<partiSR.size(); k++) {
            List<Integer> setToListPart = new List<Integer>(mapParticipantTrack.keySet());
            countIndexParticipant = mapParticipantTrack.get(setToListPart[k]);
            if(!partiSR[k].isSuccess()) {
                errorwrap.errorRecordCount++;
                Database.Error error = partiSR[k].getErrors().get(0);
                errorwrap.listOfFailedRecordsWithMsg.add(
                                    '' +
                                    countIndexParticipant +
                                    ', ERROR on Participant record insert: ' +
                                    error.getFields() +
                                    ' ' +
                                    error.getMessage()
                                );
                errorwrap.listOfFailedRecords.add(('' + csvLines.get(countIndexParticipant - 1)).removeStart('(').removeEnd(')') +', ' +countIndexParticipant);
                mapParticipant.remove(countIndexParticipant);
            }
        }
        //END :: participants Insertion
        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>(patientDelegateMap.values());
        for(String contactIdKey  : duplicateDelegateMainParticipantMap.keySet()) {
            Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
            ptDelegateRef.Contact__c = contactIdKey;
            ptDelegateRef.Participant__c = duplicateDelegateMainParticipantMap.get(contactIdKey);
            pdList.add(ptDelegateRef);
        }   
        
        if(!pdList.isEmpty()) {
            String communityTemplateName = UserContext.getCurrentCommunityTemplate().templateName;
            if(studySiteDetails.Study_Site_Type__c == StudySiteService.SS_TYPE_TRADITIONAL && 
                (studySiteDetails.Suppress_Participant_Emails__c || studySiteDetails.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c) && 
                communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT) {
                TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class);
            }
            Database.SaveResult[] perSR = Database.insert(pdList,false);
            for(Integer k=0; k<perSR.size(); k++) {
                if(!perSR[k].isSuccess()){
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
                    errorwrap.listOfFailedRecords.add(
                        ('' + csvLines.get(countIndexParticipant - 1)).removeStart('(').removeEnd(')') +', ' +countIndexParticipant);
                }
            }
        }
        //Update the delegate contact with Delegate Participant Name 
        Map<Id,Participant__c> contactToPart = new Map<Id, Participant__c>();
        for (Participant__c p: [SELECT Id, Name, Contact__c FROM Participant__c where Contact__c IN :successfullyInsertedContactSet]){
            contactToPart.put(p.Contact__c,p);
        }
        List<Contact> conListtoBeUpdated = new List<Contact>();
        for (Id c: successfullyInsertedContactSet){
            Contact cc = new Contact();
            cc.Id = c;
            cc.FirstName = null;
            cc.LastName = contactToPart.get(c).Name;
            conListtoBeUpdated.add(cc);
        }
        if(!conListtoBeUpdated.isEmpty()) {
            update conListtoBeUpdated;
        }
       return errorwrap;
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
    }
}