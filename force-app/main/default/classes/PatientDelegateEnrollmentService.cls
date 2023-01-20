/*
Created By: Ranjit Ravindranath
*/
public without sharing class PatientDelegateEnrollmentService {
    private static PatientDelegateEnrollmentService instance;
    private Boolean isDelegate = false;
    public Boolean hasDelegates = false;
    private Participant__c participant;
    public list<PatientDelegateEnrollmentsWrapper> listPDEWrapper = new List<PatientDelegateEnrollmentsWrapper>();
    public PatientDelegateEnrollmentsWrapperMain pdeWrapperMain = new PatientDelegateEnrollmentsWrapperMain();
    
    public list<PatientDelegateEnrollmentsWrapper> PdeWrapper;
    public static PatientDelegateEnrollmentService getInstance() {
        if (instance == null)
            instance = new PatientDelegateEnrollmentService();
        return instance;
    }
    public static void setMock(StubProvider stubProvider) {
        instance = (PatientDelegateEnrollmentService) Test.createStub(
            PatientDelegateEnrollmentService.class,
            stubProvider
        );
    }
    public PatientDelegateEnrollmentService() {
        system.debug('called');
        list<Patient_Delegate_Enrollment__c> lstPDE = DatabaseService.query(
            new List<String>{
                'Id',
                    'Patient_Delegate__r.Participant__r.Full_Name__c',
                    'Patient_Delegate__r.Id',
                    'Welcome_Message_Sent__c',
                    'Welcome_Message_Delivered__c',
                    'Patient_Delegate__r.Participant__r.Contact__c',
                    'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                    'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                    'Patient_Delegate__r.Participant__r.First_Name__c',
                    'Patient_Delegate__r.Participant__r.Last_Name__c',
                    'Patient_Delegate__r.Contact__c',
                    'Patient_Delegate__r.Participant_Delegate__r.Id',
                    'Patient_Delegate__r.Participant_Delegate__r.First_Name__c',
                    'Patient_Delegate__r.Participant_Delegate__r.Last_Name__c',
                    'Patient_Delegate__r.Participant_Delegate__r.Email__c',
                    'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                    'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                    'Patient_Delegate__r.Attestation_TimeStamp__c',
                    'Patient_Delegate__r.Attested_by__c',
                    'Status__c',
                    'Participant_Enrollment__c',
                    'Participant_Enrollment__r.Name',
                    'Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
                    },
            Patient_Delegate_Enrollment__c.getSObjectType(),
            DatabaseService.fieldEqual(
                'Patient_Delegate__r.Participant__r.Contact__c',
                CommunityService.getInstance().getCurrentContactId()
            ) +
            ' AND ' +
            DatabaseService.fieldNotEqual('Status__c', 'Deleted')
        );
        isDelegate = lstPDE.size() > 0;
        participant = ParticipantContext.getCurrentParticipant();
        map<id, list<Patient_Delegate_Enrollment__c>> mapIdPDE = new Map<id, list<Patient_Delegate_Enrollment__c>>();
        for (Patient_Delegate_Enrollment__c pde : lstPDE) {
            //PatientDelegateEnrollmentsWrapper pdw = new PatientDelegateEnrollmentsWrapper(); //TODO: Do we need this??
            if (mapIdPDE.containsKey(pde.Patient_Delegate__r.Participant_Delegate__r.Id)) {
                mapIdPDE.get(pde.Patient_Delegate__r.Participant_Delegate__r.Id).add(pde);
            } else {
                mapIdPDE.put(
                    pde.Patient_Delegate__r.Participant_Delegate__r.Id,
                    new List<Patient_Delegate_Enrollment__c>{ pde }
                );
            }
        }
        list<FormerPatientDelegateEnrollmentsWrapper> formerListPDEWrapper = new List<FormerPatientDelegateEnrollmentsWrapper>();
        for (Id ide : mapIdPDE.keyset()) {
            Participant__c del = new Participant__c();
            del.Id = ide;
            del.First_Name__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.First_Name__c;
            del.Last_Name__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.Last_Name__c;
            del.Email__c = mapIdPDE.get(ide)[0]
                .Patient_Delegate__r.Participant_Delegate__r.Email__c;
            // pdw.PatientDelegate = del;
            // pdw.PDEEnrollments = mapIdPDE.get(ide);
            // listPDEWrapper.add(pdw);
            Boolean isActivePDE = false;
            Boolean isWithdrawnPDE = false;
            Boolean isDisconnectedPDE = false;
            Boolean isOnHoldPDE = false;
            //check if one of the PDE list is active or not.
            for(Patient_Delegate_Enrollment__c pde: mapIdPDE.get(ide)){
                if(pde.Status__c=='Active'){
                    isActivePDE = true;
                    break;
                }else if(pde.Status__c=='Disconnected'){
                    isDisconnectedPDE = true;
                }else if(pde.Status__c=='Withdrawn'){
                    isWithdrawnPDE = true;
                }else if(pde.Status__c=='On Hold'){
                    isOnHoldPDE = true;
                }
            }
            if(isActivePDE){
                //If at least one of the PDE is active then put that delegate in active list.
                PatientDelegateEnrollmentsWrapper pdw = new PatientDelegateEnrollmentsWrapper();
                pdw.PatientDelegate = del;
                pdw.PDEEnrollments = mapIdPDE.get(ide);
                pdw.pdId = mapIdPDE.get(ide)[0].Patient_Delegate__c;
                pdw.delAttestationTimeStamp = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attestation_TimeStamp__c;
                pdw.delAttestedBy = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attested_by__c;
                listPDEWrapper.add(pdw);
            }else if(isWithdrawnPDE && !isDisconnectedPDE && !isOnHoldPDE ){
                //If all the PDE List are withdrawn 
                FormerPatientDelegateEnrollmentsWrapper fpdw = new FormerPatientDelegateEnrollmentsWrapper();
                fpdw.PatientDelegate = del;
                fpdw.isWithdrawn = true;
                fpdw.pdId = mapIdPDE.get(ide)[0].Patient_Delegate__c;
                fpdw.delAttestationTimeStamp = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attestation_TimeStamp__c;
                fpdw.delAttestedBy = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attested_by__c;
                //fpdw.PDEEnrollmentsFormer = mapIdPDE.get(ide);
                formerListPDEWrapper.add(fpdw);
            }else {
                //If Disconected/OnHold/Mixed among withdrawn/Disconnected
                FormerPatientDelegateEnrollmentsWrapper fpdw = new FormerPatientDelegateEnrollmentsWrapper();
                fpdw.PatientDelegate = del;
                fpdw.isWithdrawn = false;
                fpdw.pdId = mapIdPDE.get(ide)[0].Patient_Delegate__c;
                fpdw.delAttestationTimeStamp = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attestation_TimeStamp__c;
                fpdw.delAttestedBy = mapIdPDE.get(ide)[0].Patient_Delegate__r.Attested_by__c;
                fpdw.PDEEnrollmentsFormer = mapIdPDE.get(ide);
                formerListPDEWrapper.add(fpdw);
            }
        }
        pdeWrapperMain.activePDEWrapperList.addAll(listPDEWrapper);
        pdeWrapperMain.formerPDEWrapperList.addAll(formerListPDEWrapper);

    }
    
    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain getPDE() {
        //return listPDEWrapper;
        return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
    }
    public static Boolean isActiveDelegate(Id delContactId){
        List<Patient_Delegate_Enrollment__c> pdeList = getPDEnrollmentforDelContact(delContactId);
        for (Patient_Delegate_Enrollment__c pde : pdeList) {
            if(pde.Status__c == 'Active'){
                return true;
            }
        }
        return false;

    }
    @AuraEnabled
    public static List<parAndStdAssociatedListWrapper> getParAndStdAssociatedList() {
        //List<Patient_Delegate_Enrollment__c> = new List<Patient_Delegate_Enrollment__c>();
        List<parAndStdAssociatedListWrapper> parAndStdAssociatedList = New List<parAndStdAssociatedListWrapper>();
        Id loggedInContactId =  CommunityService.getInstance().getCurrentContactId();
        List<Patient_Delegate_Enrollment__c> pdeList = getPDEnrollmentforDelContact(loggedInContactId);
        map<id, list<Patient_Delegate_Enrollment__c>> pardIdPDEMap = new Map<id, list<Patient_Delegate_Enrollment__c>>();
        for (Patient_Delegate_Enrollment__c pde : pdeList) {
            if(pde.Status__c == 'Active'){
                if (pardIdPDEMap.containsKey(pde.Patient_Delegate__r.Participant__c)) {
                    pardIdPDEMap.get(pde.Patient_Delegate__r.Participant__c).add(pde);
                } else {
                    pardIdPDEMap.put(
                        pde.Patient_Delegate__r.Participant__c,
                        new List<Patient_Delegate_Enrollment__c>{ pde }
                    );
                }
            }
        }
        for(Id parId: pardIdPDEMap.keyset()){
                parAndStdAssociatedListWrapper parAndpdelistObj = New parAndStdAssociatedListWrapper();
                Participant__c par = new Participant__c();
                par.Id = parId;
                par.First_Name__c = pardIdPDEMap.get(parId)[0]
                    .Patient_Delegate__r.Participant__r.First_Name__c;
                par.Last_Name__c = pardIdPDEMap.get(parId)[0]
                    .Patient_Delegate__r.Participant__r.Last_Name__c;
                par.Email__c = pardIdPDEMap.get(parId)[0]
                    .Patient_Delegate__r.Participant__r.Email__c;
                parAndpdelistObj.Participant = par;
                parAndpdelistObj.PDEEnrollments = pardIdPDEMap.get(parId);
                parAndStdAssociatedList.Add(parAndpdelistObj);
        }
        return parAndStdAssociatedList;
    }
    @AuraEnabled
    public static List<parAndStdAssociatedListWrapper> WithdrawAssignment(String pdeId) {
        try {
            Patient_Delegate_Enrollment__c pde = [
                SELECT id, Status__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Id = :pdeId
            ][0];
            if (pde!=null) {
                pde.Status__c = 'Withdrawn';
                update pde;
                return getParAndStdAssociatedList();
            }
            return getParAndStdAssociatedList();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     /**
     * @description: This Method will return PD record if Participant is Minor or adult without email. 
     * @author: Krishna Mahto
     * @param: pdContactId
     * @return: List<Patient_Delegate_Enrollment__c> 
     **/
    public static List<Patient_Delegate_Enrollment__c>  getPDForMinorOrAdultWithoutEmailPar(Id pdContactId) {
        List<Patient_Delegate_Enrollment__c> pdList = new List<Patient_Delegate_Enrollment__c>();
        pdList = [
            SELECT
            Id,
                Patient_Delegate__r.Participant__r.Full_Name__c,
                Patient_Delegate__r.Id,
                Welcome_Message_Sent__c,
                Study_Email_Consent__c,
                Study_SMS_Consent__c,
                Welcome_Message_Delivered__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Patient_Delegate__r.Participant__r.First_Name__c,
                Patient_Delegate__r.Participant__r.Last_Name__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,   
                Patient_Delegate__r.Participant_Delegate__r.Id,
                Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                Patient_Delegate__r.Participant_Delegate__r.Email__c,
                Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Status__c,
                Participant_Enrollment__c,
                Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                Participant_Enrollment__r.Name,
                Participant_Enrollment__r.Clinical_Trial_Profile__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
          FROM Patient_Delegate_Enrollment__c
        WHERE (Participant_Enrollment__r.Participant__r.Adult__c = false OR Participant_Enrollment__r.Participant__r.Email__c = null)
           AND Patient_Delegate__r.Contact__c = : pdContactId
        ];
        return pdList;
    }   
    public static List<Patient_Delegate_Enrollment__c>  getPDEnrollmentforDelContact(Id pdContactId) {
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        pdeList = [
            SELECT
                Id,
                Patient_Delegate__c,
                Welcome_Message_Sent__c,
                Study_Email_Consent__c,
                Study_SMS_Consent__c,
                Welcome_Message_Delivered__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Patient_Delegate__r.Participant__r.First_Name__c,
                Patient_Delegate__r.Participant__r.Last_Name__c,
                Patient_Delegate__r.Participant__r.Email__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,   
                Patient_Delegate__r.Participant_Delegate__r.Id,
                Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
                Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
                Patient_Delegate__r.Participant_Delegate__r.Email__c,
                Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
                Status__c,
                Participant_Enrollment__c,
                Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                Participant_Enrollment__r.Name,
                Participant_Enrollment__r.Clinical_Trial_Profile__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                Primary_Delegate__c
          FROM Patient_Delegate_Enrollment__c
          WHERE Patient_Delegate__r.Contact__c = : pdContactId

        ];
        return pdeList;
    }   
    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain doAddAssignment(String delegateStr, String studyPERData){
        try {
            PatientDelegateWrapper pdData = (PatientDelegateWrapper) JSON.deserialize(
                delegateStr,
                PatientDelegateWrapper.class
            );
            Patient_Delegate__c pd= pdData.convertToPD();
            //Assign Studies.
            //PatientDelegateEnrollmentService.getInstance().createPatientDelegateEnrollment(pd,studyPERData);
            //Bypass old code writted in Patient Delegate Trigger.
            TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
            );
            TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateReactivatedNotification.class
            );
            createPatientDelegateEnrollment(pd,studyPERData);
            return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void createPatientDelegateEnrollment(
        Patient_Delegate__c newDelegate,
        String studyPERData
    ) {
        //get the list of selected studies for Delegate.
        List<MyTeamRemote.SelectedStudiesData> SelectedStudiesData = (List<MyTeamRemote.SelectedStudiesData>) JSON.deserialize(
            studyPERData,
            List<MyTeamRemote.SelectedStudiesData>.class
        );
        //List<LabelValueItem> studiesSelected = SelectedStudiesData;
        List<Patient_Delegate_Enrollment__c> pdEnrollments = new List<Patient_Delegate_Enrollment__c>();
        list<Id> pDEIdList =  New List<Id>();
        List<Id> perIDList =  New List<Id>();
        for (MyTeamRemote.SelectedStudiesData studyPER : SelectedStudiesData) {
            //if Study is not assigned then create new PDEnrollment Record otherwise reactive the existing PDEnrollment record.
            if(studyPER.assigned ==null || (studyPER.assigned!=null && !studyPER.assigned)){
                
                Patient_Delegate_Enrollment__c pde = createPDEObject(newDelegate,(Id)studyPER.Value);
                pdEnrollments.add(pde);
            } else if(studyPER.assigned!=null && studyPER.assigned && !studyPER.active){
                if(studyPER.pdEnrollmentId!=null){
                    //if Study is assigned to delegate but it is not active(Former/Active Delegate). 
                    pDEIdList.add(studyPER.pdEnrollmentId);
                }else{
                    //When deleted/Withdrawn delegate is added. pdEnrollmentId comes null from Add New Delegate page.
                    perIDList.add(studyPER.Value);
                }
               

            }
        }
        if (pdEnrollments.size() > 0) {
            insert pdEnrollments;
        }
        //Re activate the study assignment for Former/Active delegates.
        if (pDEIdList.size() > 0) {
            reActivateAssignment(pDEIdList);
        }
        //Re activate the study assignment for Deleted/Withdrawn Delegates.
        if (perIDList.size() > 0) {
            reActivateAssignmentForDeletedOrWithDrawnDel(newDelegate,perIDList);
        }

    }
    public static Patient_Delegate_Enrollment__c createPDEObject(
        Patient_Delegate__c newDelegate,
        Id perId
    ) {
        Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = perId; 
        pde.Patient_Delegate__c = newDelegate.Id;
        //pde.Attestation_c__c = newDelegate.Attestation__c;
        pde.Attestation_TimeStamp__c = newDelegate.Attestation_TimeStamp__c;
        pde.Attested_by__c = newDelegate.Attested_by__c;
        pde.Status__c = 'Active';
        pde.Study_Email_Consent__c = true;
        return pde;
    }
    //This Method will reactive the study assignments for the active/Former delegates.
    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain reActivateAssignment(List<String> pDEIdList) {
        list<Patient_Delegate_Enrollment__c> pdeList = [
            SELECT id, Status__c
            FROM Patient_Delegate_Enrollment__c
            WHERE id = :pDEIdList
        ];
        for(Patient_Delegate_Enrollment__c pde: pdeList) {
            pde.Status__c = 'Active';
            
        }
        
        try{
            update pdeList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
    }

    //This Method will reactive/Add the study assignments for the deleted/Withdrawn delegates.
    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain reActivateAssignmentForDeletedOrWithDrawnDel(Patient_Delegate__c newDelegate, List<Id> perIDList) {
        list<Patient_Delegate_Enrollment__c> pdeList = [
            SELECT id, Status__c, Participant_Enrollment__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c = :perIDList
            AND Patient_Delegate__c =: newDelegate.Id
        ];
        Set<Id> perIdSetForExistingPDE = new Set<Id>();
        for(Patient_Delegate_Enrollment__c pde: pdeList) {
            pde.Status__c = 'Active';  
            perIdSetForExistingPDE.add(pde.Participant_Enrollment__c);
        }
        for(Id perId: perIDList){
            //When PDE record is not existing, create new PDE record for that study.
            if(!perIdSetForExistingPDE.contains(perId)){
                Patient_Delegate_Enrollment__c pde = createPDEObject(newDelegate,perId);
                pdeList.Add(pde);
            }
        }
        
        try{
            upsert pdeList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
    }


    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain removeAssignment(String pDEId) {
        list<Patient_Delegate_Enrollment__c> lst = [
            SELECT Id, Status__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id = :pDEId
        ];
        if (lst.size() > 0) {
            Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
            pde.Id = lst[0].Id;
            pde.Status__c = 'Disconnected';
            update pde;
            return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
        }
        return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
    }

    @AuraEnabled
    public static PatientDelegateEnrollmentsWrapperMain deleteDelegates(String pdId) {
        try {
            list<Patient_Delegate_Enrollment__c> pdeList = [
                SELECT id, Status__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__c = :pdId
            ];
            if (pdeList!=null && !pdeList.isEmpty()) {
                for(Patient_Delegate_Enrollment__c pde: pdeList){
                    pde.Status__c = 'Deleted';
                }
                update pdeList;
                return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
            }
            return PatientDelegateEnrollmentService.getInstance().pdeWrapperMain;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Map<Id, List<Id>> getDelegateContactIdsByPAContactIs(
        List<Id> participantContIds
    ) {
        if (participantContIds.size() == 0) {
            return new Map<Id, List<Id>>();
        }
        List<Patient_Delegate_Enrollment__c> patientDelegates = new List<Patient_Delegate_Enrollment__c>();
        if (!participantContIds.isEmpty()) {
            patientDelegates = [
                SELECT
                Id,
                Participant_Enrollment__c,
                Patient_Delegate__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Name,
                Status__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c,
                Participant_Enrollment__r.study__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__r.Participant__r.Contact__c IN : participantContIds AND Status__c = 'Active'            ];
        }
        Map<Id, List<Id>> delContIdsByPAContId = new Map<Id, List<Id>>();
        if (patientDelegates.isEmpty())
            return delContIdsByPAContId;

        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            Id paConId = pd.Patient_Delegate__r.Participant__r.Contact__c;
            if (!delContIdsByPAContId.containsKey(paConId))
                delContIdsByPAContId.put(paConId, new List<Id>());

            delContIdsByPAContId.get(paConId).add(pd.Patient_Delegate__r.Contact__c);
        }

        return delContIdsByPAContId;
    }
     /**
     * @param partContactsIds List with participant contact ids
     * @param delegatedCntFields List with required contact fields
     */
    public static Map<Id, List<Contact>> getDelegatedCntsByParticipantCnt(
        List<Id> partContactsIds,
        List<String> delegatedCntFields
    ) {
        if (partContactsIds.isEmpty()) {
            return new Map<Id, List<Contact>>();
        }
        List<String> pdFields = new List<String>();
        pdFields.add('Patient_Delegate__r.Participant__r.Contact__c');
        for (String cntField : delegatedCntFields)
            pdFields.add('Patient_Delegate__r.Contact__r.' + cntField);

        // Removing Active Status for Platform Level from Batch_MassEmailDelegate   
        List<Patient_Delegate_Enrollment__c> pdePatientDelegates = (List<Patient_Delegate_Enrollment__c>) DatabaseService.query(
            pdFields,
            Patient_Delegate_Enrollment__c.getSObjectType(),
            DatabaseService.fieldInValues('Patient_Delegate__r.Participant__r.Contact__c', partContactsIds) +
            ' AND ' +
            DatabaseService.fieldInValues('Status__c', new List<String>{ 'Active' })
        
        );

        Map<Id, List<Contact>> delContactsByPartCnt = new Map<Id, List<Contact>>();
        for (Patient_Delegate_Enrollment__c pd : pdePatientDelegates) {
            Id partCntId = pd.Patient_Delegate__r.Participant__r.Contact__c;
            if (!delContactsByPartCnt.containsKey(partCntId)) {
                delContactsByPartCnt.put(partCntId, new List<Contact>());
            }

            delContactsByPartCnt.get(partCntId).add(pd.Patient_Delegate__r.Contact__r);
        }

        return delContactsByPartCnt;
    }

    public static list<Patient_Delegate_Enrollment__c> getPatientEnrollmentList(List<Id> idlst, String fieldFilter) {
        list<Patient_Delegate_Enrollment__c> pdedelegatesList = new list<Patient_Delegate_Enrollment__c>();
        if(idlst != null){
            pdedelegatesList = DatabaseService.query(
                new List<String>{
                    'Id',
                        'Patient_Delegate__r.Participant__r.Full_Name__c',
                        'Patient_Delegate__r.Id',
                        'Welcome_Message_Sent__c',
                        'Welcome_Message_Delivered__c',
                        'Patient_Delegate__r.Participant__r.Contact__c',
                        'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                        'Patient_Delegate__r.Participant__r.First_Name__c',
                        'Patient_Delegate__r.Participant__r.Last_Name__c',
                        'Patient_Delegate__r.Contact__c',
                        'Patient_Delegate__r.Participant__c',   
                        'Patient_Delegate__r.Participant_Delegate__r.Id',
                        'Patient_Delegate__r.Participant_Delegate__r.First_Name__c',
                        'Patient_Delegate__r.Participant_Delegate__r.Last_Name__c',
                        'Patient_Delegate__r.Participant_Delegate__r.Email__c',
                        'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c',
                        'Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c',
                        'Status__c',
                        'Participant_Enrollment__c',
                        'Participant_Enrollment__r.Name',
                        'Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
                        },
                Patient_Delegate_Enrollment__c.getSObjectType(),
                DatabaseService.fieldInValues(
                    fieldFilter,
                    idlst
                ) +
                ' AND ' +
                DatabaseService.fieldEqual('Status__c', 'Active') 
            );
            
        }
        return pdedelegatesList;
    }
    public static PDEWrapper getDelegatedContactIdsByParticipantIdMap(List<Id> idlst, String fieldFilter){
        List<Patient_Delegate_Enrollment__c> pdlst = getPatientEnrollmentList(idlst,fieldFilter);
        PDEWrapper delConMap = new PDEWrapper();
        if(pdlst != null && !pdlst.isEmpty()){
            Map<Id, List<Id>> delegatedContactsByParticipantMap = new Map<Id, List<Id>>();
            Map<Id, List<Id>> pdercrdslst = new Map<Id, List<Id>>();
            for (Patient_Delegate_Enrollment__c pd : pdlst) {
                List<Id> delegatedContacts = delegatedContactsByParticipantMap.get(pd.Patient_Delegate__r.Participant__c);
                List<Id> pdercrds = pdercrdslst.get(pd.Patient_Delegate__r.Participant__c);
                if (delegatedContacts == null)
                    delegatedContacts = new List<Id>();
                if (pdercrds == null)
                    pdercrds = new List<Id>();
                    
                if (!delegatedContacts.contains(pd.Patient_Delegate__r.Contact__c))
                    delegatedContacts.add(pd.Patient_Delegate__r.Contact__c);
                if (!pdercrds.contains(pd.Participant_Enrollment__c))
                    pdercrds.add(pd.Participant_Enrollment__c);
                
                delegatedContactsByParticipantMap.put(pd.Patient_Delegate__r.Participant__c, delegatedContacts);
                pdercrdslst.put(pd.Patient_Delegate__r.Participant__c, pdercrds);
                
                //ContactService.patientdelList.put(pd.Patient_Delegate__r.Contact__c, pd);
                
                if (!delegatedContactsByParticipantMap.isEmpty() && delegatedContactsByParticipantMap != null)
                    delConMap.delParticipantIds = delegatedContactsByParticipantMap;
                if (!pdercrdslst.isEmpty() && pdercrdslst != null)
                    delConMap.pdercrds = pdercrdslst;
            }
        }
        return delConMap;
    }
    public static PDEWrapper getDelegatedParticipantIdsMap(Id contactId) {
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        if (contactId != null) {
            pdeList = [
                SELECT
                Id,
                Participant_Enrollment__c,
                Patient_Delegate__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__c,
                Name,
                Status__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c,
                Participant_Enrollment__r.study__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Patient_Delegate__r.Contact__c = :contactId AND Status__c = 'Active'
            ];
        }
        PDEWrapper delConMap = new PDEWrapper();
        Map<Id, List<Id>> delParticipantIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> pdercrdslst = new Map<Id, List<Id>>();
        for (Patient_Delegate_Enrollment__c pd : pdeList) {
            List<Id> participantIds = delParticipantIds.get(pd.Patient_Delegate__r.Contact__c);
            List<Id> pdercrds = pdercrdslst.get(pd.Patient_Delegate__r.Contact__c);
            if (participantIds == null)
                participantIds = new List<Id>();
            if (pdercrds == null)
                pdercrds = new List<Id>();
            
            if (!participantIds.contains(pd.Patient_Delegate__r.Participant__c))
                participantIds.add(pd.Patient_Delegate__r.Participant__c);
            if (!pdercrds.contains(pd.Participant_Enrollment__c))
                pdercrds.add(pd.Participant_Enrollment__c);
            delParticipantIds.put(pd.Patient_Delegate__r.Contact__c, participantIds); /// Delegate contat with list of  actual participant Ids
            pdercrdslst.put(pd.Patient_Delegate__r.Contact__c, pdercrds);
        }
        if (!delParticipantIds.isEmpty() && delParticipantIds != null)
            delConMap.delParticipantIds = delParticipantIds;
        if (!pdercrdslst.isEmpty() && pdercrdslst != null)
            delConMap.pdercrds = pdercrdslst;
        
        return delConMap;
    }
    
    // define our wrapper
    public class PDEWrapper {
        public Map<Id, List<Id>> delParticipantIds = new Map<Id, List<Id>>();
        //public Map<Id,List<Patient_Delegate_Enrollment__c>> pdercrds = new Map<Id,List<Patient_Delegate_Enrollment__c>>();
        public Map<Id, List<Id>> pdercrds = new Map<Id, List<Id>>();
    }
    
    public class PatientDelegateEnrollmentsWrapper {
        @AuraEnabled
        public Participant__c PatientDelegate;
        @AuraEnabled
        public list<Patient_Delegate_Enrollment__c> PDEEnrollments;
        @AuraEnabled
        public String delAttestationTimeStamp;
        @AuraEnabled
        public String delAttestedBy;
        @AuraEnabled
        public String pdId;
    }
    public class FormerPatientDelegateEnrollmentsWrapper {
        @AuraEnabled
        public Participant__c PatientDelegate;
        @AuraEnabled
        public Boolean isWithdrawn = false;
        @AuraEnabled
        public String delAttestationTimeStamp;
        @AuraEnabled
        public String delAttestedBy;
        @AuraEnabled
        public String pdId;
        @AuraEnabled
        public list<Patient_Delegate_Enrollment__c> PDEEnrollmentsFormer;

    }
    public class PatientDelegateEnrollmentsWrapperMain {
        @AuraEnabled
        public List<PatientDelegateEnrollmentsWrapper> activePDEWrapperList = new List<PatientDelegateEnrollmentsWrapper>();
        @AuraEnabled
        public List<FormerPatientDelegateEnrollmentsWrapper> formerPDEWrapperList = new List<FormerPatientDelegateEnrollmentsWrapper>();
    }
    public class parAndStdAssociatedListWrapper {
        @AuraEnabled
        public Participant__c Participant;
        @AuraEnabled
        public list<Patient_Delegate_Enrollment__c> PDEEnrollments;
    }
    public class PatientDelegateWrapper {
        @AuraEnabled
        public String pdId;
        @AuraEnabled
        public String delAttestedBy;
        @AuraEnabled
        public String delAttestationTimeStamp;

        public Patient_Delegate__c convertToPD() {
            Patient_Delegate__c pd = new Patient_Delegate__c();
            pd.Id = pdId;
            pd.Attested_by__c = delAttestedBy;
            pd.Attestation_TimeStamp__c = delAttestationTimeStamp;
            return pd;
        }
    }
}