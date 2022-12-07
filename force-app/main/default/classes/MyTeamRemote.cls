/**
 * Created by Kryvolap on 14.09.2018.
 */

public without sharing class MyTeamRemote {
    //TODO:get only active Studies
    private static final String ACTIVE_STUDY_SITES_FILTER = 'AND (Override_PI_Referral_Status__c IN (\'Accepted\',\'Invitation Sent\',\'Accepted (Admin)\'))';
    private static final String ACTIVE_HCP_ENROLLMENTS_FILTER = 'AND (Status__c IN (\'Activated\',\'Activated (Admin)\'))';
    private static final String HAS_DELEGATE_LEVELS = 'True';
    private static final String HAS_NOT_DELEGATE_LEVELS = 'False';
    private static final String OLD_VALUES_DELEGATE_LEVELS = 'OldMap';
    private static final List<String> fields = new List<String>{'Id', 'Email', 'FirstName', 'LastName', 'Name', 'Language__c', 'Library_Primary_Language__c', 'Full_Name__c', 'Salutation', 'Suffix', 'HCP_Opt_In_Referral_Status_Emails__c'};
    private static Contact delContact = New Contact();
    private static Boolean hasStudyFilter = false;
     @AuraEnabled
    public static Map<String,Integer> getMaxLength(Sobject so,List<String> fieldNames) {
        return CommunityService.getMaxLength(so,fieldNames);
    }

    @AuraEnabled
    public static String getInitData(String userMode, String parentId) {
        try {
            MyTeamRemote.MyTeamDetail detail = new MyTeamRemote.MyTeamDetail();
            detail.currentUserContactId = CommunityService.getUserContact().Id;
            if (userMode == CommunityService.USER_MODE_PI) {
                detail.piDelegateParents = getDelegateParents();
                if (detail.piDelegateParents.size() > 0) {
                    if (parentId == null || parentId == '') {
                        detail.piSelectedParent = detail.piDelegateParents[0].value;
                        parentId = detail.piDelegateParents[0].value;
                    } else {
                        detail.piSelectedParent = parentId;
                        Contact parentContact = [
                            SELECT Id, Full_Name__c, Suffix, Salutation
                            FROM Contact
                            WHERE Id = :parentId
                            LIMIT 1
                        ];
                        detail.parentFullName =
                            (parentContact.Salutation == null
                                ? ''
                                : parentContact.Salutation + ' ') +
                            parentContact.Full_Name__c +
                            (parentContact.Suffix == null ? '' : ' ' + parentContact.Suffix);
                    }
                }
            }
            Boolean excludeCurrentUser = userMode.equals(CommunityService.USER_MODE_PARTICIPANT);
            detail.delegates = getDelegates(userMode, excludeCurrentUser, null, parentId);
            detail.delegateOptions = getDelegateOptions(userMode);
            if (userMode == CommunityService.USER_MODE_PI) {
                detail.hasStudies = !StudySiteService.getStudySitesWithDelegateLevelFiltered(
                        ACTIVE_STUDY_SITES_FILTER,
                        new Set<String>{ DelegateService.DELEGATE_LEVEL_1 },
                        parentId
                    )
                    .isEmpty();
            }
            if (userMode == CommunityService.USER_MODE_HCP) {
                detail.hasStudies =
                    String.isEmpty(parentId) ||
                    DelegateService.getHCPDelegateLevelMap().get(parentId) ==
                    DelegateService.DELEGATE_LEVEL_1;
            }
            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                detail.hasStudies =
                    ParticipantEnrollmentService.getPEnrolmentsCountCommon(userMode, '') != 0;
            }

            return JSON.serialize(detail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
	public static String getDelegateContactData(String userMode, String contactEmail, String parentId) {
        try {
            List<Contact> delegateContacts = new List<Contact>();
            List<Contact> contactsToProcess = new List<Contact>();

            if (contactEmail != '') {
                delegateContacts = [
                    SELECT Id, FirstName, LastName, Name, Email
                    FROM Contact
                    WHERE Email = :contactEmail AND userCommunityMode__c != 'CC'
                ];
            }

            if (delegateContacts.isEmpty()) {
                //if contact is not existing contact. 
                contactsToProcess.add(
                    new Contact(FirstName = '', LastName = '', Email = contactEmail)
                );
            } else {
                Set<Id> contactIdSet = new Set<Id>();
                for (Contact c : delegateContacts) {
                        contactIdSet.add(c.Id);
                }

                if (contactsToProcess.isEmpty())
                    contactsToProcess.addAll(delegateContacts);

                //Id contactId = delegateContacts[0].Id;
                List<Participant__c> participants = [
                    SELECT Id, First_Name__c, Last_Name__c,Contact__c
                    FROM Participant__c
                    WHERE Contact__c = :contactIdSet
                ];
                Map<Id, Participant__c> parConIdParticipantMap = new Map<Id, Participant__c>();  
                for(Participant__c par: participants){
                    parConIdParticipantMap.put(par.Contact__c, par);    
                }
                
                
                if (!participants.isEmpty()) {
                    for(Contact con: delegateContacts){
                        con.FirstName = parConIdParticipantMap.get(con.Id).First_Name__c;
                        con.LastName = parConIdParticipantMap.get(con.Id).Last_Name__c;
                    }
                }
            }

            MyTeamRemote.MyTeamDetail detail = new MyTeamRemote.MyTeamDetail();
            detail.currentUserContactId = CommunityService.getUserContact().Id;
            detail.delegates = getDelegates(userMode, false, contactsToProcess, parentId);
            detail.delegateOptions = getDelegateOptions(userMode);
            detail.hasStudies = true;
            
            return JSON.serialize(detail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
	public static String getContactData(String userMode, String contactEmail, String parentId) {
        try {
            List<Contact> delegateContacts = new List<Contact>();
            List<Contact> contactsToProcess = new List<Contact>();

            if (contactEmail != '') {
                //NewTeamMember.js.doSearchContact()
                delegateContacts = [
                    SELECT Id, FirstName, LastName, Name, Email
                    FROM Contact
                    WHERE Email = :contactEmail AND userCommunityMode__c != 'CC'
                ];
            }

            if (delegateContacts.isEmpty()) {
                //NewTeamMember.js.doInit()
                contactsToProcess.add(
                    new Contact(FirstName = '', LastName = '', Email = contactEmail)
                );
            } else {
                for (Contact c : delegateContacts) {
                    if (c.Id == CommunityService.getUserContact().Id)
                        contactsToProcess.add(c);
                }

                if (contactsToProcess.isEmpty())
                    contactsToProcess.add(delegateContacts[0]);

                Id contactId = delegateContacts[0].Id;
                List<Participant__c> participants = [
                    SELECT Id, First_Name__c, Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c = :contactId
                ];
                if (!participants.isEmpty()) {
                    delegateContacts[0].FirstName = participants[0].First_Name__c;
                    delegateContacts[0].LastName = participants[0].Last_Name__c;
                }
            }

            MyTeamRemote.MyTeamDetail detail = new MyTeamRemote.MyTeamDetail();
            detail.currentUserContactId = CommunityService.getUserContact().Id;
            detail.delegates = getDelegates(userMode, false, contactsToProcess, parentId);
            detail.delegateOptions = getDelegateOptions(userMode);
            detail.hasStudies = true;
            if (userMode == CommunityService.USER_MODE_PI && parentId != null && parentId != '') {
                List<Participant__c> parentParticipant = [
                    SELECT Id,Full_Name__c, Suffix__c, Salutation__c 
                    FROM Participant__c
                    WHERE Contact__c = :parentId
                ];
                Contact parentContact = [
                    SELECT Id, Full_Name__c, Suffix, Salutation
                    FROM Contact
                    WHERE Id = :parentId
                    LIMIT 1
                ];
                if(!parentParticipant.isEmpty()){
                    detail.parentFullName =
                    (parentParticipant[0].Salutation__c == null ? '' : parentParticipant[0].Salutation__c + ' ') +
                        parentParticipant[0].Full_Name__c +
                        (parentParticipant[0].Suffix__c == null ? '' : ' ' + parentParticipant[0].Suffix__c);
                }else{
                    detail.parentFullName =
                        (parentContact.Salutation == null ? '' : parentContact.Salutation + ' ') +
                        parentContact.Full_Name__c +
                        (parentContact.Suffix == null ? '' : ' ' + parentContact.Suffix);
                }
            }
            return JSON.serialize(detail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<DelegateWrapper> getDelegates(
        String userMode,
        Boolean excludeCurrentUser,
        List<Contact> delegatesToProcess,
        String parentId
    ) {
        if (String.isEmpty(parentId))
            parentId = CommunityService.getInstance().getCurrentContactId();

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        Boolean useProvidedContacts = delegatesToProcess != null && !delegatesToProcess.isEmpty();

        if (userMode == CommunityService.USER_MODE_PI) {
            delegates.addAll(
                getPIDelegates(
                    useProvidedContacts,
                    delegatesToProcess,
                    excludeCurrentUser,
                    parentId
                )
            );
        }
        if (userMode == CommunityService.USER_MODE_HCP) {
            delegates.addAll(
                getHCPDelegates(
                    useProvidedContacts,
                    delegatesToProcess,
                    excludeCurrentUser,
                    parentId
                )
            );
        }
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            delegates.addAll(getParticipantDelegates(useProvidedContacts, delegatesToProcess));
        }

        delegates.sort();
        return delegates;
    }

    private static List<DelegateWrapper> getParticipantDelegates(
        Boolean useProvidedContacts,
        List<Contact> delegatesToProcess
    ) {
        List<Contact> delegateContacts;
        if (useProvidedContacts) {
            delegateContacts = delegatesToProcess;
        } else {
            delegateContacts = PatientDelegateService.getInstance().getDelegates();
        }

        //Set names
        Map<Id, Contact> delegateContactsMap = new Map<Id, Contact>();
        if (delegateContacts != null && !delegateContacts.isEmpty()) {
            for (Contact delCont : delegateContacts) {
                if (delCont.Id != null)
                    delegateContactsMap.put(delCont.Id, delCont);
            }
            List<Participant__c> participants = [
                SELECT Id, Contact__c, First_Name__c, Last_Name__c
                FROM Participant__c
                WHERE Contact__c IN :delegateContacts
            ];
            for (Participant__c participant : participants) {
                Contact dc = delegateContactsMap.get(participant.Contact__c);
                if (dc != null) {
                    dc.FirstName = participant.First_Name__c;
                    dc.LastName = participant.Last_Name__c;
                }
            }
        }
        // List<Patient_Delegate__c> patientDelegates = [
        //     SELECT Contact__c, Status__c
        //     FROM Patient_Delegate__c
        //     WHERE
        //         Contact__c IN :delegateContactsMap.keySet()
        //         AND Participant__c = :ParticipantContext.getCurrentParticipant().Id
        //         //AND Status__c != 'Withdrawn'
        // ];
        //Get Patient Delegate Enrollments records
        List<Patient_Delegate_Enrollment__c> PDEList = getPDEList(delegateContactsMap.keySet());
        Boolean isActivePDE = false;
        Boolean isWithdrawnPDE = false;
        Boolean isDisconnectedPDE = false;
        Boolean isOnHoldPDE = false;
        Boolean isDeleted = false;
        Id existingDelegateContactId = null;
        Id existingPatientDelegateId = null;
        //check if one of the PDE list is active or not.
        for(Patient_Delegate_Enrollment__c pde: PDEList){
            existingDelegateContactId = pde.Patient_Delegate__r.Contact__c;
            existingPatientDelegateId =pde.Patient_Delegate__c;
            if(pde.Status__c=='Active'){
                isActivePDE = true;
                break;
            }else if(pde.Status__c=='Disconnected'){
                isDisconnectedPDE = true;
            }else if(pde.Status__c=='Withdrawn'){
                isWithdrawnPDE = true;
            }else if(pde.Status__c=='On Hold'){
                isOnHoldPDE = true;
            }else if(pde.Status__c=='Deleted'){
                isDeleted = true;
            }
        }
        String status = '';
        if(isActivePDE){
            //If at least one of the PDE is active then put that delegate in active list.
            status = 'Active';
        }else if(isWithdrawnPDE && !isDisconnectedPDE && !isOnHoldPDE && !isDeleted ){
            //If all the PDE List are withdrawn 
            status = 'Withdrawn';
        }else if(!isWithdrawnPDE && !isDisconnectedPDE && !isOnHoldPDE && isDeleted){
            //If all the PDE List are Deleted
            status = 'Deleted';
        }else if(!isWithdrawnPDE && isDisconnectedPDE && !isOnHoldPDE && !isDeleted){
            //If all the PDE List are disconnected
            status = 'Disconnected';
        }else if(!isWithdrawnPDE && !isDisconnectedPDE && isOnHoldPDE && !isDeleted){
            //If all the PDE List are On Hold
            status = 'On Hold';
        }

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        if(existingDelegateContactId!=null){
            DelegateWrapper dw = new DelegateWrapper();
            dw.delegateContact = delegateContactsMap.get(existingDelegateContactId);
            dw.isActive =
                status == PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
            dw.patientDelegateId = existingPatientDelegateId;
            dw.status = status;
            delegates.add(dw);
        }
        
        
        // List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        // Set<Id> isPatientDelegateCont = new Set<Id>();
        // for (Patient_Delegate__c pd : patientDelegates) {
        //     if (delegateContactsMap.containsKey(pd.Contact__c)) {
        //         DelegateWrapper dw = new DelegateWrapper();
        //         dw.delegateContact = delegateContactsMap.get(pd.Contact__c);
        //         dw.isActive =
        //             pd.Status__c == PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
        //         dw.patientDelegateId = pd.Id;
        //         dw.status = pd.Status__c;
        //         delegates.add(dw);
        //         isPatientDelegateCont.add(pd.Contact__c);
        //     }
        // }

        if (useProvidedContacts) {
            //When contact is not a delegate for current participant.
            //if (delegates.isEmpty() && delegatesToProcess != null) {
            if (delegatesToProcess != null) {
                for(Contact con: delegatesToProcess){
                    // if(!isPatientDelegateCont.contains(con.Id)){
                        //If contact is Delegate of current Participant or Initialize the contact on load.
                        if(con.Id!=existingDelegateContactId || con.Id==null){
                            DelegateWrapper dw1 = new DelegateWrapper();
                            dw1.delegateContact = con;
                            delegates.add(dw1);
                    }
                    
                }
                
            }
        }

        return delegates;
    }

    private static List<Patient_Delegate_Enrollment__c> getPDEList(Set<Id> delContactIdSet){
        List<Patient_Delegate_Enrollment__c> pdeList = new List<Patient_Delegate_Enrollment__c>();
        pdeList = [
            SELECT
                Id,
                Status__c,
                Patient_Delegate__c,
                Patient_Delegate__r.Contact__c,
                Patient_Delegate__r.Participant__r.Contact__c,
                Patient_Delegate__r.Participant__c,                 
                Participant_Enrollment__c
          FROM Patient_Delegate_Enrollment__c
        WHERE Patient_Delegate__r.Contact__c IN :delContactIdSet
        AND Patient_Delegate__r.Participant__c =:ParticipantContext.getCurrentParticipant().Id

        ];
        return pdeList;
     
    }

    private static List<DelegateWrapper> getHCPDelegates(
        Boolean useProvidedContacts,
        List<Contact> delegatesToProcess,
        Boolean excludeCurrentUser,
        String parentId
    ) {
        List<RP_Delegate_Relationship__c> delegatesQR = [
            SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c
            FROM RP_Delegate_Relationship__c
            WHERE Referring_Provider__c = :parentId
        ];

        List<Contact> delegateContacts;
        Map<Id, String> delegateLevels = new Map<Id, String>();
        Set<Id> delegateIds = new Set<Id>();
        for (RP_Delegate_Relationship__c delegate : delegatesQR) {
            delegateIds.add(delegate.Delegate__c);
            delegateLevels.put(delegate.Delegate__c, delegate.Delegate_Access_Level__c);
        }
        if (useProvidedContacts) {
            delegateContacts = delegatesToProcess;
        } else {
            /*RH-5680*/
            //delegateContacts = CommunityService.getContacts(delegateIds);
            delegateContacts = CommunityService.getContactsWithFields(delegateIds, fields);
            Map<Id, Contact> delegateContactMap = new Map<Id, Contact>(delegateContacts);
            for (Participant__c participant : [
                SELECT Contact__c, First_Name__c, Last_Name__c
                FROM Participant__c
                WHERE Contact__c IN :delegateContactMap.keySet()
            ]) {
                delegateContactMap.get(participant.Contact__c)
                    .FirstName = participant.First_Name__c;
                delegateContactMap.get(participant.Contact__c).LastName = participant.Last_Name__c;
            }
        }

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        for (Contact delegateContact : delegateContacts) {
            if (!excludeCurrentUser || delegateContact.Id != CommunityService.getUserContact().Id) {
                DelegateWrapper dw = new DelegateWrapper();
                dw.delegateContact = delegateContact;
                dw.trialLevel = new DelegateLevelWrapper();
                dw.trialLevel.delegateLevel = delegateLevels.get(delegateContact.Id) != null
                    ? delegateLevels.get(delegateContact.Id)
                    : '';
                dw.trialLevel.readOnly =
                    DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(
                        DelegateService.getHCPDelegateLevelMap().get(parentId)
                    ) || delegateContact.Id == CommunityService.getUserContact().Id;
                delegates.add(dw);
            }
        }

        return delegates;
    }

    private static List<DelegateWrapper> getPIDelegates(
        Boolean useProvidedContacts,
        List<Contact> delegatesToProcess,
        Boolean excludeCurrentUser,
        String parentId
    ) {
        List<Study_Site__c> studySites;
        if (!useProvidedContacts) {
            studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(
                ACTIVE_STUDY_SITES_FILTER,
                new Set<String>(DelegateService.DELEGATE_LEVEL_1_AND_LOW)
            );
        } else {
            studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(
                ACTIVE_STUDY_SITES_FILTER,
                new Set<String>{ DelegateService.DELEGATE_LEVEL_1 }
            );
        }

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        if (!studySites.isEmpty()) {
            Map<Id, Map<Id, Site_Staff__c>> staffTrialMap = DelegateService.getPITeamStaffTrialMap();
            List<Contact> delegateContacts;
            if (useProvidedContacts) {
                delegateContacts = delegatesToProcess;
            } else {
                delegateContacts = CommunityService.getContacts(staffTrialMap.keySet());
                Map<Id, Contact> delegateContactMap = new Map<Id, Contact>(delegateContacts);
                for (Participant__c participant : [
                    SELECT Contact__c, First_Name__c, Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c IN :delegateContactMap.keySet()
                ]) {
                    delegateContactMap.get(participant.Contact__c)
                        .FirstName = participant.First_Name__c;
                    delegateContactMap.get(participant.Contact__c)
                        .LastName = participant.Last_Name__c;
                }
            }

            for (Contact delegateContact : delegateContacts) {
                if (
                    !excludeCurrentUser ||
                    delegateContact.Id != CommunityService.getUserContact().Id
                ) {
                    DelegateWrapper dw = new DelegateWrapper();
                    dw.delegateContact = delegateContact;
                    Boolean isDelegate = false;
                    Map<Id, TrialDelegateWrapper> delegateTrialsMap = new Map<Id, TrialDelegateWrapper>();
                    for (Study_Site__c site : studySites) {
                        if (
                            parentId != null &&
                            parentId != '' &&
                            site.Principal_Investigator__c != parentId
                        ) {
                            continue;
                        }
                        TrialDelegateWrapper delegateTrial;
                        if (!delegateTrialsMap.containsKey(site.Clinical_Trial_Profile__c)) {
                            delegateTrial = new TrialDelegateWrapper();
                            delegateTrial.trialName = site.Clinical_Trial_Profile__r.Study_Code_Name__c;
                            delegateTrialsMap.put(site.Clinical_Trial_Profile__c, delegateTrial);
                        } else {
                            delegateTrial = delegateTrialsMap.get(site.Clinical_Trial_Profile__c);
                        }
                        DelegateLevelWrapper siteLevel = new DelegateLevelWrapper();
                        siteLevel.entityName = site.Name;
                        siteLevel.enrollmentOrStudySiteId = site.Id;
                        siteLevel.ReferralStatus = site.Override_PI_Referral_Status__c;
                        siteLevel.delegateLevel = '';
                        siteLevel.readOnly =
                            DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(
                                DelegateService.getPIStudySitesAccessLevelMap().get(site.Id)
                            ) || delegateContact.Id == CommunityService.getUserContact().Id;
                        Site_Staff__c delegateRecord = (staffTrialMap.get(delegateContact.Id) ==
                            null)
                            ? null
                            : (staffTrialMap.get(delegateContact.Id).get(site.Id));
                        if (delegateRecord != null) {
                            isDelegate = true;
                            siteLevel.delegateLevel = delegateRecord.Delegate_Level__c;
                        }
                        delegateTrial.siteLevels.add(siteLevel);
                    }
                    for (TrialDelegateWrapper tdw : delegateTrialsMap.values()) {
                        tdw.siteLevels.sort();
                        dw.delegateTrials.add(tdw);
                    }
                    dw.delegateTrials.sort();
                    if (useProvidedContacts || isDelegate) {
                        delegates.add(dw);
                    }
                }
            }
        }

        return delegates;
    }

    private static List<LabelValueItem> getDelegateOptions(String userMode) {
        List<LabelValueItem> delegateOptions = new List<LabelValueItem>();

        if (userMode == CommunityService.USER_MODE_HCP) {
            delegateOptions.add(new LabelValueItem(Label.No_Access, ''));
            for (
                Schema.PicklistEntry ple : RP_Delegate_Relationship__c.Delegate_Access_Level__c.getDescribe()
                    .getPicklistValues()
            ) {
                delegateOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            delegateOptions.add(new LabelValueItem(Label.No_Access, ''));
            for (
                Schema.PicklistEntry ple : Site_Staff__c.Delegate_Level__c.getDescribe()
                    .getPicklistValues()
            ) {
                delegateOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
        }

        return delegateOptions;
    }

    @testVisible
    private static List<LabelValueItem> getDelegateParents() {
        Set<Id> piDelegateParentIds = DelegateService.getPIDelegateParents();
        List<LabelValueItem> parents = new List<LabelValueItem>();
        if (StudySiteService.getStudySitesForPI(true).size() > 0) {
            parents.add(
                new LabelValueItem(Label.PG_MT_L_My_Team, CommunityService.getUserContact().Id)
            );
        }
        Boolean getParticipants = true;
        for (Contact parent : CommunityService.getContacts(piDelegateParentIds,getParticipants)) {
            String parentFullName;
            if(parent.Participants__r.isEmpty()){
                parentFullName = 
                    (parent.Salutation != null ? parent.Salutation + ' ' : '') +
                    parent.Full_Name__c +
                    (parent.Suffix != null ? ' ' + parent.Suffix : '');
            }else{
                parentFullName = 
                    (parent.Participants__r[0].Salutation__c != null ? parent.Participants__r[0].Salutation__c + ' ' : '') +
                    parent.Participants__r[0].Full_Name__c +
                    (parent.Participants__r[0].Suffix__c != null ? ' ' + parent.Participants__r[0].Suffix__c : '');
            }
            parents.add(
                new LabelValueItem(
                    Label.PG_MT_L_Team_for.replace('##PIName', parentFullName),
                    parent.Id
                )
            );
        }
        return parents;
    }

    @AuraEnabled
    public static void saveDelegateLevelChanges(String userMode, String delegate, String parentId) {
        Savepoint sp = Database.setSavepoint();
        Boolean newss = false;
        
        try {
            DelegateWrapper dw = (DelegateWrapper) JSON.deserialize(
                delegate,
                DelegateWrapper.class
            );
            List<Id> ConId = new List<Id>();
            List<Id> SiteId = new List<Id>();
            List<Site_Staff__c> lstss = new List<Site_Staff__c>();
            if (parentId == null || parentId == '') {
                parentId = CommunityService.getInstance().getCurrentContactId();
            }
            if (dw.delegateContact.Id == null) {
                createDelegate(dw, userMode, parentId);
            } else {
                checkAndCreateDelegateUser(dw.delegateContact, dw.delegateTrials, userMode);
                Map<String, LIst<Id>> hasDelegateLevelsPIMap = new Map<String, List<Id>>();
                hasDelegateLevelsPIMap.put(HAS_NOT_DELEGATE_LEVELS, new List<Id>());
                Boolean hasDelegateLevels = false;
                for (TrialDelegateWrapper delegateTrialRecord : dw.delegateTrials) {
                    for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {
                        ConId.add(dw.delegateContact.Id);
                        SiteId.add(delegateRecord.enrollmentOrStudySiteId);
                    }
                }            
                //To check existing data present or not
                lstss = [
                    SELECT id, Site_Contact__c, is_Invited__c, Study_Site__c
                    FROM Site_Staff__c
                    WHERE Site_Contact__c IN :ConId AND is_Invited__c = TRUE
                    LIMIT 5
                ];
                String PI = '';
                Boolean isHCP = false;
                List<Study_Site__c> lstSSites = new List<Study_Site__c>();
                List<Contact> lstHcpCont = new List<Contact>();
                List<user> lstUsr = new List<User>();
                lstSSites = [
                    SELECT id, Principal_Investigator__c
                    FROM Study_Site__c
                    WHERE Principal_Investigator__c IN :ConId
                    LIMIT 1
                ];
                lstHcpCont = [SELECT userCommunytyType__c FROM Contact WHERE id = :ConId LIMIT 1];
                // check whether hep or not
                if (!lstHcpCont.isEmpty()) {
                    isHCP = String.isNotBlank(lstHcpCont[0].userCommunytyType__c)
                        ? lstHcpCont[0].userCommunytyType__c.contains('HCP') ? true : false
                        : false;
                }
                if (lstSSites.size() > 0) {
                    PI = lstSSites[0].Principal_Investigator__c;
                    if (PI != null && PI != '') {
                        lstUsr = [SELECT id, Contactid FROM user WHERE Contactid = :PI LIMIT 1];
                    }
                }
                if (userMode == CommunityService.USER_MODE_PI) {
                    hasDelegatelevelMap hdmp = new hasDelegatelevelMap();
                    hdmp = savePIDelegate(dw);
                    hasDelegateLevelsPIMap = hdmp.hasdelegatelevelmp;
                    newss = hdmp.hasCreatedNewSS;
                    DelegateService.updateDelegatePermissionSetsPI(dw.delegateContact);
                } else if (userMode == CommunityService.USER_MODE_HCP) {
                    hasDelegateLevels = saveHCPDelegate(dw, parentId);
                    isHCP = true;     
                }
                
                if (lstss.size() > 0 || lstUsr.size() > 0 || isHCP) {
                    if (
                        (hasDelegateLevels ||
                        !hasDelegateLevelsPIMap.isEmpty()) /*&& delegateContact != null && !delegateContact.HasOptedOutOfEmail*/
                    ) {
                        sendEmailNotification(dw.delegateContact, userMode, hasDelegateLevelsPIMap);
                        system.debug('mailing');
                    }
                }
                //Contact delegateContact = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =:dw.delegateContact.Id LIMIT 1];
                List<User> delegateUsers = CommunityService.getCommunityUsersByContactIds(
                    new Set<Id>{ dw.delegateContact.Id }
                );
                if (!delegateUsers.isEmpty() && !delegateUsers[0].IsActive) {
                    DelegateService.activateDelegateUsers(new Set<Id>{ delegateUsers[0].Id });
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @testvisible
    private static void sendEmailNotification(
        Contact delegateContact,
        String userMode,
        Map<String, List<Id>> hasDelegateLevelsPIMap
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            notifications.add(
                new Notification__c(
                    Recipient__c = delegateContact.Id,
                    WhatId__c = delegateContact.Id,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ACCESS_LEVEL_CHANGED_TYPE
                )
            );
        } else if (userMode == CommunityService.USER_MODE_PI) {
            String whatId;
            List<Site_Staff__c> ssList = new List<Site_Staff__c>();
            List<Site_Staff__c> ssListWithSSId = new List<Site_Staff__c>();
            if (
                hasDelegateLevelsPIMap.containsKey(OLD_VALUES_DELEGATE_LEVELS) &&
                !hasDelegateLevelsPIMap.get(OLD_VALUES_DELEGATE_LEVELS).isEmpty()
            ) {
                ssListWithSSId = [
                    SELECT
                        Id,
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Site_Contact__c,
                        is_Invited__c
                    FROM Site_Staff__c
                    WHERE
                        Site_Contact__c = :delegateContact.Id
                        AND Study_Site__c IN :hasDelegateLevelsPIMap.get(OLD_VALUES_DELEGATE_LEVELS)
                ];
            } else {
                ssList = [
                    SELECT
                        Id,
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Site_Contact__c,
                        is_Invited__c
                    FROM Site_Staff__c
                    WHERE Site_Contact__c = :delegateContact.Id
                ];
            }

            if (ssList.isEmpty())
                ssList.addAll(ssListWithSSId);
            List<String> comTemplates = new List<String>();

            for (Site_Staff__c ss : ssList) {
                String commTemplate = ss.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                if (!comTemplates.contains(commTemplate))
                    comTemplates.add(commTemplate);
            }
            for (String cmTp : comTemplates) {
                for (Site_Staff__c ss : ssList) {
                    if (ss.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c == cmTp)
                        whatId = ss.Study_Site__c;
                }
                notifications.add(
                    new Notification__c(
                        Recipient__c = delegateContact.Id,
                        WhatId__c = whatId,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_ACCESS_LEVEL_CHANGED_TYPE
                    )
                );
                if (comTemplates.size() > 1) {
                    break;
                }
            }
        } else if (userMode == CommunityService.USER_MODE_HCP) {
            if(delegateContact.HCP_Opt_In_Referral_Status_Emails__c){
                notifications.add(
                    new Notification__c(
                        Recipient__c = delegateContact.Id,
                        WhatId__c = delegateContact.Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_HCP_ACCESS_LEVEL_CHANGED_TYPE
                    )
                );
            }
            
        }
        if (notifications != null) {
            insert notifications;
        }
    }
    
    @testVisible
    private static void sendEmailNotificationWelcome(Contact delegateContact) {
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        toSendNotificationMap.put(delegateContact.Id, delegateContact.Id);
        SendEmailTemplate.sendEmailNotification(
            CommunityService.COMMUNITY_ET_DELEGATE_WELCOME,
            toSendNotificationMap
        );
    }

    private static hasDelegatelevelMap savePIDelegate(DelegateWrapper dw) {
        Map<String, List<Id>> hasDelegateLevelsMap = new Map<String, List<Id>>();
        Map<Id, Site_Staff__c> delegateSiteStaffMap = DelegateService.getPITeamStaffTrialMap()
            .get(dw.delegateContact.Id);
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToUpdate = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToDelete = new List<Site_Staff__c>();
        Boolean hasNewSS = false;
        List<Id> ConId = new List<Id>();
        List<Id> SiteId = new List<Id>();
        Map<String, String> mapDuplicate = new Map<String, String>();
        for (TrialDelegateWrapper delegateTrialRecord : dw.delegateTrials) {
            for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {
                ConId.add(dw.delegateContact.Id);
                SiteId.add(delegateRecord.enrollmentOrStudySiteId);
            }
        }
        List<Site_Staff__c> dupSitestaffLst = new List<Site_Staff__c>();
        dupSitestaffLst = [
            SELECT id, Site_Contact__c, Study_Site__c, Delegate_Level__c
            FROM Site_Staff__c
            WHERE Study_Site__c IN :SiteId AND Site_Contact__c IN :ConId
        ];
        List<string> dupSiteStaff = new List<string>();
        List<Id> lstConId = new List<Id>();
        List<Site_Staff__c> lstss = new List<Site_Staff__c>();
        string duplicate = '';
        system.debug('dupsize' + dupSitestaffLst.size());
        for (Site_Staff__c dup : dupSitestaffLst) {
            duplicate = dup.Site_Contact__c + '' + dup.Study_Site__c;
            dupSiteStaff.add(duplicate);
            mapDuplicate.put(duplicate, dup.id);
            lstConId.add(dup.Site_Contact__c);
            duplicate = '';
        }
        string dupChk = '';
        for (TrialDelegateWrapper delegateTrialRecord : dw.delegateTrials) {
            for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {
                if (delegateRecord.delegateLevel != '') {
                    hasDelegateLevelsMap.put(HAS_DELEGATE_LEVELS, new List<Id>());
                }
                if (
                    delegateSiteStaffMap == null ||
                    delegateSiteStaffMap.get(delegateRecord.enrollmentOrStudySiteId) == null
                ) {
                    dupChk = dw.delegateContact.Id + '' + delegateRecord.enrollmentOrStudySiteId;
                    if (delegateRecord.delegateLevel != '' && !dupSiteStaff.contains(dupChk)) {
                        Site_Staff__c newDelegateRecord = new Site_Staff__c();
                        newDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                        newDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                        newDelegateRecord.Site_Contact__c = dw.delegateContact.Id;
                        newDelegateRecord.is_Invited__c = true;
                        delegateRecordsToInsert.add(newDelegateRecord);
                        //hasNewSS=true;
                    } else if (
                        delegateRecord.delegateLevel != '' && dupSiteStaff.contains(dupChk)
                    ) {
                        Site_Staff__c curDelegateRecord = new Site_Staff__c();
                        curDelegateRecord.id = mapDuplicate.get(dupChk);
                        curDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                        curDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                        curDelegateRecord.is_Invited__c = true;
                        delegateRecordsToUpdate.add(curDelegateRecord);
                    }
                } else {
                    Site_Staff__c curDelegateRecord = delegateSiteStaffMap.get(
                        delegateRecord.enrollmentOrStudySiteId
                    );
                    if (delegateRecord.delegateLevel == '') {
                        delegateRecordsToDelete.add(curDelegateRecord);
                    } else if (
                        delegateRecord.delegateLevel != curDelegateRecord.Delegate_Level__c
                    ) {
                        curDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                        curDelegateRecord.is_Invited__c = true;
                        delegateRecordsToUpdate.add(curDelegateRecord);
                    }
                }
            }
        }
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
            DelegateService.addConversationSharesForPITeam(delegateRecordsToInsert);
            hasDelegateLevelsMap.putall(hasDelegateLevelsMapUpdate(delegateRecordsToInsert));
        }
        if (!delegateRecordsToUpdate.isEmpty()) {
            hasDelegateLevelsMap.putall(hasDelegateLevelsMapUpdate(delegateRecordsToUpdate));
            update delegateRecordsToUpdate;
        }
        if (!delegateRecordsToDelete.isEmpty()) {
            delete delegateRecordsToDelete;
        }
        system.debug('Final--->' + hasNewSS);
        hasDelegatelevelMap wrphdlmp = new hasDelegatelevelMap();
        wrphdlmp.hasdelegatelevelmp = hasDelegateLevelsMap;
        wrphdlmp.hasCreatedNewSS = hasNewSS;
        return wrphdlmp;
    }

    private static Map<String, List<Id>> hasDelegateLevelsMapUpdate(
        List<Site_Staff__c> delegateRecords
    ) {
        List<Id> ssIds = new List<Id>();
        Map<String, List<Id>> hasDelegateLevelsMap = new Map<String, List<Id>>();
        for (Site_Staff__c ss : delegateRecords)
            ssIds.add(ss.Study_Site__c);
        List<Study_Site__c> listSS = [
            SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Study_Site__c
            WHERE Id IN :ssIds
        ];
        List<Id> ssIdsForNotification = new List<Id>();
        List<String> communityNames = new List<String>();
        for (Study_Site__c ss : listSS)
            if (!communityNames.contains(ss.Clinical_Trial_Profile__r.CommunityTemplate__c))
                communityNames.add(ss.Clinical_Trial_Profile__r.CommunityTemplate__c);

        for (String cmN : communityNames) {
            for (Study_Site__c ss : listSS) {
                if (ss.Clinical_Trial_Profile__r.CommunityTemplate__c == cmN)
                    ssIdsForNotification.add(ss.Id);
            }
        }
        hasDelegateLevelsMap.put(OLD_VALUES_DELEGATE_LEVELS, ssIdsForNotification);
        return hasDelegateLevelsMap;
    }

    private static Boolean saveHCPDelegate(DelegateWrapper dw, String parentId) {
        Boolean hasDelegateLevels = dw.trialLevel.delegateLevel != '';
        List<RP_Delegate_Relationship__c> delegates = [
            SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c
            FROM RP_Delegate_Relationship__c
            WHERE Delegate__c = :dw.delegateContact.Id AND Referring_Provider__c = :parentId
        ];
        if (delegates.isEmpty()) {
            RP_Delegate_Relationship__c newDelegate = new RP_Delegate_Relationship__c();
            newDelegate.Delegate__c = dw.delegateContact.Id;
            newDelegate.Referring_Provider__c = parentId;
            newDelegate.Delegate_Access_Level__c = dw.trialLevel.delegateLevel;
            insert newDelegate;
        } else if (dw.trialLevel.delegateLevel == '') {
            delete delegates;
        } else {
            delegates[0].Delegate_Access_Level__c = dw.trialLevel.delegateLevel;
            update delegates[0];
        }
        return hasDelegateLevels;
    }
    @AuraEnabled
    public static Boolean isExistingDelegate(String delegate) {
        Contact contactDelegate = (Contact) JSON.deserialize(delegate, Contact.class);
        return PatientDelegateService.getInstance().delegateAlreadyExists(contactDelegate);
    }

    @AuraEnabled
    public static void savePatientDelegate(String delegate, String delegateFilterData) {
        savePatientDelegate(delegate);
        if(delegateFilterData!=null){
            //Read the list of selected studies for Delegate.
            //PEFilterData filterData = (PEFilterData) JSON.deserialize(delegateFilterData, PEFilterData.class);
            //List<LabelValueItem> studiesSelected = filterData.studiesSelected;
            // System.debug('studiesSelected[0].Value: '+studiesSelected[0].Value);  
            // System.debug('studiesSelected[0].Label: '+studiesSelected[0].Label);
            hasStudyFilter = true;
            PatientDelegateService.getInstance().createPatientDelegate(delContact,delegateFilterData);  
        }
    }

    @AuraEnabled
    public static void savePatientDelegate(String delegate) {
        try {
            System.debug('savePatientDelegate:');
            List<User> existingUserPatientDelegate = new List<User>();
            User user;
            Contact contactDelegate = (Contact) JSON.deserialize(delegate, Contact.class);
            user = [
                    SELECT Contact.AccountId, ContactId, TimeZoneSidKey
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                ];
            Boolean isNewContact = contactDelegate.Id == null;
            if (isNewContact) {
                /*User user = [
                    SELECT Contact.AccountId, ContactId, TimeZoneSidKey
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                ];*/
                Participant__c participant = ParticipantService.getInstance()
                    .getState()
                    .participant;
                contactDelegate.AccountId = user.Contact.AccountId;
                contactDelegate.Current_Participant_Enrollment__c = null;
                contactDelegate.Language__c = UserInfo.getLanguage();
                contactDelegate.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                contactDelegate.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                contactDelegate.UserCommunityIsDelegate__c = true;
                contactDelegate.MailingCountryCode = participant.Mailing_Country_Code__c;
                if (participant.Mailing_State_Code__c != null) {
                    contactDelegate.MailingStateCode = participant.Mailing_State_Code__c;
                }
                //contactDelegate.MailingCountry = participant.Mailing_Country__c;
                //contactDelegate.MailingState = participant.Mailing_State__c;
                contactDelegate.MailingPostalCode = participant.Mailing_Zip_Postal_Code__c;
                contactDelegate.Landing_Community__c = Site.getMasterLabel() == 'IQVIA RH'
                    ? CommunityService.IQVIA_NETWORK_NAME
                    : Site.getMasterLabel();
                contactDelegate.Participant_Opt_In_Status_Emails__c=true;
                insert contactDelegate;
                Participant__c participantDelegate = new Participant__c(
                    Adult__c = true,
                    Contact__c = contactDelegate.Id,
                    First_Name__c = contactDelegate.FirstName,
                    Last_Name__c = contactDelegate.LastName,
                    Email__c = contactDelegate.Email,
                    Phone__c = contactDelegate.Phone,
                    Mailing_Zip_Postal_Code__c = contactDelegate.MailingPostalCode,
                    Preferred_Language__c=contactDelegate.Language__c
                    //Mailing_City__c = contactDelegate.MailingCity,
                    //Mailing_Country_Code__c = contactDelegate.MailingCountryCode,
                    //Mailing_State_Code__c = contactDelegate.MailingStateCode
                );
                participantDelegate.Mailing_Country_Code__c = contactDelegate.MailingCountryCode;
                participantDelegate.Mailing_Country__c = CountryStateUtil.getCountryName(
                    contactDelegate.MailingCountryCode
                );
                if (contactDelegate.MailingStateCode != null) {
                    participantDelegate.Mailing_State_Code__c = contactDelegate.MailingStateCode;
                }
                participantDelegate.Mailing_City__c = contactDelegate.MailingCity;
                insert participantDelegate;
                List<User> participantUser = new List<User>();
                User delegateUser = CommunityService.createUser(
                    contactDelegate,
                    null,
                    null,
                    user.TimeZoneSidKey
                );
                insert delegateUser;
            }else{
                if(contactDelegate.Id != null){
                        existingUserPatientDelegate = [SELECT ID, Email FROM User WHERE ContactId = :contactDelegate.Id];
                        
                        //update email consent for the exiting delegate contact.
                        contact delexistingContact = new contact();
                        delexistingContact.Id = contactDelegate.Id;
                        delexistingContact.Participant_Opt_In_Status_Emails__c = true;
                        update delexistingContact;
                    }
                 if(existingUserPatientDelegate.isEmpty()){
                User delegateUser = CommunityService.createUser(
                    contactDelegate,
                    null,
                    null,
                    user.TimeZoneSidKey
                );
                insert delegateUser;
              }
           }/*else if (!CommunityService.isUserInCommunity(contactDelegate.Id)) {
                contactDelegate.UserCommunityIsDelegate__c = true;
                Boolean check =
                    contactDelegate.userCommunytyType__c.contains('PI') ||
                    contactDelegate.userCommunytyType__c.contains('HCP');
                if (check)
                    contactDelegate.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                update contactDelegate;
                CommunityService.setUserToCommunity(contactDelegate.Id);
                sendEmailNotification(
                    contactDelegate,
                    CommunityService.USER_MODE_PARTICIPANT,
                    null
                );
            }*/
            String ParticipantContactId = UserContext.getUserContactId();
            List<Participant_Enrollment__c> particpantEnrollList = [
                SELECT
                    Id,
                    Study_Site__c,
                    Study_Site__r.Study_Site_Type__c,
                    Study_Site__r.Suppress_Participant_Emails__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c = :ParticipantContactId
            ];
            Boolean isSuppressed = true;
            for (Participant_Enrollment__c objPE : particpantEnrollList) {
                if (
                    objPE.Study_Site__r.Study_Site_Type__c ==
                    StudySiteService.SS_TYPE_TRADITIONAL &&
                    (objPE.Study_Site__r.Suppress_Participant_Emails__c == false &&
                    objPE.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ==
                    false)
                ) {
                    isSuppressed = false;
                    break;
                }
            }
            if (isSuppressed) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
            }
            //If Study filter is not sent as parameter in the method.
            if(!hasStudyFilter){
                PatientDelegateService.getInstance().createPatientDelegate(contactDelegate);
            }
            delContact = contactDelegate;
            
            
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static void createDelegate(DelegateWrapper delegate, String userMode, String parentId) {
        Contact delegateContact = createDelegateContact(delegate, userMode);
        List<Site_Staff__c> piDelegates = new List<Site_Staff__c>();
        List<TrialDelegateWrapper> dlw = delegate.delegateTrials;

        if (userMode == CommunityService.USER_MODE_PI) {
            piDelegates = createPIDelegationRecord(delegate, delegateContact);
        }

        if (userMode == CommunityService.USER_MODE_HCP) {
            createHCPDelegationRecord(delegate, delegateContact, parentId);
        }

        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            delegate.delegateContact = delegateContact;
        }
        checkAndCreateDelegateUser(delegateContact, dlw, userMode);
        if (!piDelegates.isEmpty()) {
            DelegateService.addConversationSharesForPITeam(piDelegates);
        }
    }

    public static void checkAndCreateDelegateUser(
        Contact delegateContact,
        List<TrialDelegateWrapper> dlw,
        String userMode
    ) {
        if (
            CommunityService.getCommunityUsersByContactIds(new Set<Id>{ delegateContact.Id })
                .size() > 0
        ) {
            return;
        }
        Boolean createUser = doCreateUser(dlw, userMode);
        if (createUser) {
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createPortalUsers(new Set<Id>{ delegateContact.Id });
        }
    }

    public static Boolean doCreateUser(List<TrialDelegateWrapper> dlw, String userMode) {
        if (userMode != CommunityService.USER_MODE_PI) {
            return true;
        } else {
            for (MyTeamRemote.TrialDelegateWrapper t : dlw) {
                for (MyTeamRemote.DelegateLevelWrapper d : t.siteLevels) {
                    if (
                        (d.ReferralStatus == StudySiteService.PI_S_ACCEPTED ||
                        d.ReferralStatus == StudySiteService.PI_S_ACCEPTED_A) &&
                        String.isNotBlank(d.delegateLevel)
                    ) {
                        return true;
                    }
                }
            }
            return false;
        }
    }

    private static Contact createDelegateContact(DelegateWrapper delegate, String userMode) {
        Contact delegateContact = new Contact();
        delegateContact.FirstName = delegate.delegateContact.FirstName;
        delegateContact.LastName = delegate.delegateContact.LastName;
        delegateContact.Email = delegate.delegateContact.Email;
        User currentUser = [
            SELECT
                Contact.AccountId,
                Contact.MailingCity,
                Contact.MailingCountry,
                Contact.MailingState,
                Contact.MailingStreet,
                Contact.MailingPostalCode,
                Contact.userCommunytyType__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        if (currentUser.Contact.AccountId == null)
            throw new CommunityServiceException('User Contact Account can not be NULL');
        delegateContact.AccountId = currentUser.Contact.AccountId;
        delegateContact.userCommunityMode__c = userMode;
        delegateContact.userCommunityIsDelegate__c = true;
        delegateContact.Current_Participant_Enrollment__c = ParticipantContext.getCurrentPEId();
        delegateContact.Language__c = UserInfo.getLanguage();
        delegateContact.userCommunytyType__c = userMode;
        delegateContact.MailingCity = currentUser.Contact.MailingCity;
        delegateContact.MailingCountry = currentUser.Contact.MailingCountry;
        delegateContact.MailingState = currentUser.Contact.MailingState;
        delegateContact.MailingStreet = currentUser.Contact.MailingStreet;
        delegateContact.MailingPostalCode = currentUser.Contact.MailingPostalCode;
        insert delegateContact;
        return delegateContact;
    }

    private static List<Site_Staff__c> createPIDelegationRecord(
        DelegateWrapper delegate,
        Contact delegateContact
    ) {
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        for (TrialDelegateWrapper delegateTrialRecord : delegate.delegateTrials) {
            for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {
                if (delegateRecord.delegateLevel != '') {
                    Site_Staff__c newDelegateRecord = new Site_Staff__c();
                    newDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                    newDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                    newDelegateRecord.Site_Contact__c = delegateContact.Id;
                    newDelegateRecord.is_Invited__c = true;
                    delegateRecordsToInsert.add(newDelegateRecord);
                }
            }
        }
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
        }
        return delegateRecordsToInsert;
    }

    private static void createHCPDelegationRecord(
        DelegateWrapper delegate,
        Contact delegateContact,
        String parentId
    ) {
        RP_Delegate_Relationship__c delegateRecord = new RP_Delegate_Relationship__c();

        delegateRecord.Delegate__c = delegateContact.Id;
        delegateRecord.Referring_Provider__c = parentId;
        delegateRecord.Delegate_Access_Level__c = delegate.trialLevel.delegateLevel;
        insert delegateRecord;

        Contact parentContactUpgrade = new Contact();
        parentContactUpgrade.Id = delegateContact.Id;
        parentContactUpgrade.userCommunityDelegateId__c = parentId;
        update parentContactUpgrade;
    }

    public class MyTeamDetail {
        public List<LabelValueItem> piDelegateParents;
        public String piSelectedParent;
        public List<LabelValueItem> delegateOptions;
        public List<DelegateWrapper> delegates;
        public Id currentUserContactId;
        public Boolean hasStudies;
        public String parentFullName;
        public MyTeamDetail() {
            delegates = new List<DelegateWrapper>();
        }
    }
    public class hasDelegatelevelMap {
        public Map<String, List<Id>> hasdelegatelevelmp;
        public Boolean hasCreatedNewSS;
    }
    public class DelegateWrapper implements Comparable {
        public Contact delegateContact;
        public Boolean isActive;
        public List<TrialDelegateWrapper> delegateTrials;
        public List<DelegateLevelWrapper> trialLevels;
        public DelegateLevelWrapper trialLevel;
        public string patientDelegateId;
        public String status;
        public DelegateWrapper() {
            delegateTrials = new List<TrialDelegateWrapper>();
        }
        
        public Integer compareTo(Object compareTo) {
            DelegateWrapper compareToDelegate = (DelegateWrapper) compareTo;
            if (delegateContact.Id == CommunityService.getUserContact().Id)
                return -1;
            if (compareToDelegate.delegateContact.Id == CommunityService.getUserContact().Id)
                return 1;
            if (
                (delegateContact.FirstName + ' ' + delegateContact.LastName) >
                (compareToDelegate.delegateContact.FirstName +
                ' ' +
                compareToDelegate.delegateContact.LastName)
            ) {
                return 1;
            } else if (
                (delegateContact.FirstName + ' ' + delegateContact.LastName) <
                (compareToDelegate.delegateContact.FirstName +
                ' ' +
                compareToDelegate.delegateContact.LastName)
            ) {
                return -1;
            }
            return 0;
        }
    }
    public class DelegateLevelWrapper implements Comparable {
        public String delegateLevel;
        public String entityName;
        public String enrollmentOrStudySiteId;
        public Boolean readOnly;
        public String ReferralStatus;

        public Integer compareTo(Object compareTo) {
            if (entityName > ((DelegateLevelWrapper) compareTo).entityName) {
                return 1;
            } else if (entityName < ((DelegateLevelWrapper) compareTo).entityName) {
                return -1;
            }
            return 0;
        }
    }

    public class TrialDelegateWrapper implements Comparable {
        public String trialName;
        public List<DelegateLevelWrapper> siteLevels;
        public TrialDelegateWrapper() {
            siteLevels = new List<DelegateLevelWrapper>();
        }
        public Integer compareTo(Object compareTo) {
            if (trialName > ((TrialDelegateWrapper) compareTo).trialName) {
                return 1;
            } else if (trialName < ((TrialDelegateWrapper) compareTo).trialName) {
                return -1;
            }
            return 0;
        }
    }
    public class PEFilterData {
        @AuraEnabled
        public List<LabelValueItem> studies;
        @AuraEnabled
        public List<LabelValueItem> studiesSelected;
        
    }
    public class SelectedStudiesData {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean assigned = false;
        @AuraEnabled
        public Boolean active = false;
        @AuraEnabled
        public String pdEnrollmentId;
        
    }
    
    /**
     * @description: This Method return the List of available PER records for the Participant.
     * @author: Krishna Mahto
     * @param: userMode
     * @return: PEFilterData
     **/
    @AuraEnabled
    public static PEFilterData getFilterData(String userMode){
        PEFilterData peFilterData =new MyTeamRemote.PEFilterData();
        peFilterData.studies = new List<LabelValueItem>();
        List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
        
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
                        .getState();
            List<Id> peIds = new List<Id>();
            peIds = PatientDelegateService.getAvailablePEIdsForContact(
                participantState.participant.Contact__c
            );

            List<Participant_Enrollment__c> availablePEs = AccountSettingsController.getPERRecords(peIds);

            if (availablePEs != null)
                participantEnrollments.addAll(availablePEs);
            List<Participant_Enrollment__c> pastEnrollments = ContactService.getPastEnrollments(
                participantState.participant.Contact__c
            );

            if (pastEnrollments != null)
                participantEnrollments.addAll(pastEnrollments);
            }
            for(Participant_Enrollment__c per: participantEnrollments) {
                peFilterData.studies.add(new LabelValueItem(per.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c, per.Id));
            } 
        
        return PEFilterData;
        } 
}