/**
 * Created by Kryvolap on 14.09.2018.
 */

public without sharing class MyTeamRemote {
    //TODO:get only active Studies
    private static final String ACTIVE_STUDY_SITES_FILTER = 'AND (Override_PI_Referral_Status__c IN (\'Accepted\',\'Invitation Sent\',\'Accepted (Admin)\'))';
    private static final String ACTIVE_HCP_ENROLLMENTS_FILTER = 'AND (Status__c IN (\'Activated\',\'Activated (Admin)\'))';
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
                        Contact parentContact = [SELECT Id, Full_Name__c, Suffix, Salutation FROM Contact WHERE Id = :parentId LIMIT 1];
                        detail.parentFullName = (parentContact.Salutation == null ? '' : parentContact.Salutation + ' ') + parentContact.Full_Name__c + (parentContact.Suffix == null ? '' : ' ' + parentContact.Suffix);
                    }
                }
            }
            Boolean excludeCurrentUser = userMode.equals(CommunityService.USER_MODE_PARTICIPANT);
            detail.delegates = getDelegates(userMode, excludeCurrentUser, null, parentId);
            detail.delegateOptions = getDelegateOptions(userMode);
            if (userMode == CommunityService.USER_MODE_PI) {
                detail.hasStudies = !StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>{
                        DelegateService.DELEGATE_LEVEL_1
                }, parentId).isEmpty();
            }
            if (userMode == CommunityService.USER_MODE_HCP) {
                detail.hasStudies = String.isEmpty(parentId) || DelegateService.getHCPDelegateLevelMap().get(parentId) == DelegateService.DELEGATE_LEVEL_1;
            }
            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                detail.hasStudies = ParticipantEnrollmentService.getPEnrolmentsCountCommon(userMode, '') != 0;
            }

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

            if (contactEmail != '') {//NewTeamMember.js.doSearchContact()
                delegateContacts = [
                        SELECT Id, FirstName, LastName, Name, Email
                        FROM Contact
                        WHERE Email = :contactEmail
                        AND userCommunityMode__c != 'CC'
                ];
            }

            if (delegateContacts.isEmpty()) {//NewTeamMember.js.doInit()
                contactsToProcess.add(new Contact(FirstName = '', LastName = '', Email = contactEmail));
            } else {
                for (Contact c : delegateContacts) {
                    if (c.Id == CommunityService.getUserContact().Id) contactsToProcess.add(c);
                }

                if (contactsToProcess.isEmpty()) contactsToProcess.add(delegateContacts[0]);

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
                Contact parentContact = [SELECT Id, Full_Name__c, Suffix, Salutation FROM Contact WHERE Id = :parentId LIMIT 1];
                detail.parentFullName = (parentContact.Salutation == null ? '' : parentContact.Salutation + ' ') + parentContact.Full_Name__c + (parentContact.Suffix == null ? '' : ' ' + parentContact.Suffix);
            }
            return JSON.serialize(detail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<DelegateWrapper> getDelegates(String userMode, Boolean excludeCurrentUser, List<Contact> delegatesToProcess, String parentId) {
        if (String.isEmpty(parentId)) parentId = CommunityService.getInstance().getCurrentContactId();

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        Boolean useProvidedContacts = delegatesToProcess != null && !delegatesToProcess.isEmpty();

        if (userMode == CommunityService.USER_MODE_PI) {
            delegates.addAll(getPIDelegates(useProvidedContacts, delegatesToProcess, excludeCurrentUser, parentId));
        }
        if (userMode == CommunityService.USER_MODE_HCP) {
            delegates.addAll(getHCPDelegates(useProvidedContacts, delegatesToProcess, excludeCurrentUser, parentId));
        }
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            delegates.addAll(getParticipantDelegates(useProvidedContacts, delegatesToProcess));
        }

        delegates.sort();
        return delegates;
    }

    private static List<DelegateWrapper> getParticipantDelegates(Boolean useProvidedContacts, List<Contact> delegatesToProcess) {
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
                if (delCont.Id != null) delegateContactsMap.put(delCont.Id, delCont);
            }
            List<Participant__c> participants = [
                    SELECT
                            Id,
                            Contact__c,
                            First_Name__c,
                            Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c IN:delegateContacts
            ];
            for (Participant__c participant : participants) {
                Contact dc = delegateContactsMap.get(participant.Contact__c);
                if (dc != null) {
                    dc.FirstName = participant.First_Name__c;
                    dc.LastName = participant.Last_Name__c;
                }
            }
        }
        List<Patient_Delegate__c> patientDelegates = [
                SELECT Contact__c, Status__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN:delegateContactsMap.keySet()
                AND Participant__c =: ParticipantContext.getCurrentParticipant().Id
        ];
        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        for (Patient_Delegate__c pd : patientDelegates) {
            if (delegateContactsMap.containsKey(pd.Contact__c)) {
                DelegateWrapper dw = new DelegateWrapper();
                dw.delegateContact = delegateContactsMap.get(pd.Contact__c);
                dw.isActive = pd.Status__c == PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
                delegates.add(dw);
            }
        }

        if (useProvidedContacts) {
            if (delegates.isEmpty() && delegatesToProcess != null) {
                DelegateWrapper dw = new DelegateWrapper();
                dw.delegateContact = delegateContacts.get(0);
                delegates.add(dw);
            }
        }

        return delegates;
    }

    private static List<DelegateWrapper> getHCPDelegates(Boolean useProvidedContacts, List<Contact> delegatesToProcess, Boolean excludeCurrentUser, String parentId) {
        List<RP_Delegate_Relationship__c> delegatesQR = [SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c FROM RP_Delegate_Relationship__c WHERE Referring_Provider__c = :parentId];

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
            delegateContacts = CommunityService.getContacts(delegateIds);
            Map<Id, Contact> delegateContactMap = new Map<Id, Contact>(delegateContacts);
            for (Participant__c participant : [
                    SELECT Contact__c, First_Name__c, Last_Name__c
                    FROM Participant__c
                    WHERE Contact__c IN :delegateContactMap.keySet()
            ]) {
                delegateContactMap.get(participant.Contact__c).FirstName = participant.First_Name__c;
                delegateContactMap.get(participant.Contact__c).LastName = participant.Last_Name__c;
            }
        }

        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        for (Contact delegateContact : delegateContacts) {
            if (!excludeCurrentUser || delegateContact.Id != CommunityService.getUserContact().Id) {
                DelegateWrapper dw = new DelegateWrapper();
                dw.delegateContact = delegateContact;
                dw.trialLevel = new DelegateLevelWrapper();
                dw.trialLevel.delegateLevel = delegateLevels.get(delegateContact.Id) != null ? delegateLevels.get(delegateContact.Id) : '';
                dw.trialLevel.readOnly = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(DelegateService.getHCPDelegateLevelMap().get(parentId))
                        || delegateContact.Id == CommunityService.getUserContact().Id;
                delegates.add(dw);
            }
        }

        return delegates;
    }

    private static List<DelegateWrapper> getPIDelegates(Boolean useProvidedContacts, List<Contact> delegatesToProcess, Boolean excludeCurrentUser, String parentId) {
        List<Study_Site__c> studySites;
        if (!useProvidedContacts) {
            studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>(DelegateService.DELEGATE_LEVEL_1_AND_LOW));
        } else {
            studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>{
                    DelegateService.DELEGATE_LEVEL_1
            });
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
                    delegateContactMap.get(participant.Contact__c).FirstName = participant.First_Name__c;
                    delegateContactMap.get(participant.Contact__c).LastName = participant.Last_Name__c;
                }
            }

            for (Contact delegateContact : delegateContacts) {
                if (!excludeCurrentUser || delegateContact.Id != CommunityService.getUserContact().Id) {
                    DelegateWrapper dw = new DelegateWrapper();
                    dw.delegateContact = delegateContact;
                    Boolean isDelegate = false;
                    Map<Id, TrialDelegateWrapper> delegateTrialsMap = new Map<Id, TrialDelegateWrapper>();
                    for (Study_Site__c site : studySites) {
                        if (parentId != null && parentId != '' && site.Principal_Investigator__c != parentId) {
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
                        siteLevel.readOnly = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(DelegateService.getPIStudySitesAccessLevelMap().get(site.Id))
                                || delegateContact.Id == CommunityService.getUserContact().Id;
                        Site_Staff__c delegateRecord =
                                (staffTrialMap.get(delegateContact.Id) == null)
                                        ? null : (staffTrialMap.get(delegateContact.Id).get(site.Id));
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
            for (Schema.PicklistEntry ple : RP_Delegate_Relationship__c.Delegate_Access_Level__c.getDescribe().getPicklistValues()) {
                delegateOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            delegateOptions.add(new LabelValueItem(Label.No_Access, ''));
            for (Schema.PicklistEntry ple : Site_Staff__c.Delegate_Level__c.getDescribe().getPicklistValues()) {
                delegateOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
        }

        return delegateOptions;
    }

    private static List<LabelValueItem> getDelegateParents() {
        Set<Id> piDelegateParentIds = DelegateService.getPIDelegateParents();
        List<LabelValueItem> parents = new List<LabelValueItem>();
        if (StudySiteService.getStudySitesForPI(true).size() > 0) {
            parents.add(new LabelValueItem(Label.PG_MT_L_My_Team, CommunityService.getUserContact().Id));
        }
        for (Contact parent : CommunityService.getContacts(piDelegateParentIds)) {
            String parentFullName = (parent.Salutation != null ? parent.Salutation + ' ' : '') + parent.Full_Name__c + (parent.Suffix != null ? ' ' + parent.Suffix : '');
            parents.add(new LabelValueItem(Label.PG_MT_L_Team_for.replace('##PIName', parentFullName), parent.Id));
        }
        return parents;
    }

    @AuraEnabled
    public static void saveDelegateLevelChanges(String userMode, String delegate, String parentId) {
        Savepoint sp = Database.setSavepoint();
        try {
            DelegateWrapper dw = (DelegateWrapper) JSON.deserialize(delegate, DelegateWrapper.class);
            if (parentId == null || parentId == '') {
                parentId = CommunityService.getInstance().getCurrentContactId();
            }
            if (dw.delegateContact.Id == null) {
                createDelegate(dw, userMode, parentId);
            } else {
                Boolean hasDelegateLevels = false;

                if (userMode == CommunityService.USER_MODE_PI) {
                    hasDelegateLevels = savePIDelegate(dw);
                } else if (userMode == CommunityService.USER_MODE_HCP) {
                    hasDelegateLevels = saveHCPDelegate(dw, parentId);

                }
                //Contact delegateContact = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =:dw.delegateContact.Id LIMIT 1];
                if (hasDelegateLevels/*&& delegateContact != null && !delegateContact.HasOptedOutOfEmail*/) {
                    sendEmailNotification(dw.delegateContact, userMode);
                }
                List<User> delegateUsers = CommunityService.getCommunityUsersByContactIds(new Set<Id>{
                        dw.delegateContact.Id
                });

                if (!delegateUsers.isEmpty() && !delegateUsers[0].IsActive) {
                    DelegateService.activateDelegateUsers(new Set<Id>{
                            delegateUsers[0].Id
                    });
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    private static void sendEmailNotification(Contact delegateContact, String userMode) {

        Notification__c notification;
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            notification = new Notification__c(
                    Recipient__c = delegateContact.Id,
                    WhatId__c = delegateContact.Id,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ACCESS_LEVEL_CHANGED_TYPE
            );
        } else if (userMode == CommunityService.USER_MODE_PI) {
            notification = new Notification__c(
                    Recipient__c = delegateContact.Id,
                    WhatId__c = delegateContact.Id,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_ACCESS_LEVEL_CHANGED_TYPE
            );
        } else if (userMode == CommunityService.USER_MODE_HCP) {
            notification = new Notification__c(
                    Recipient__c = delegateContact.Id,
                    WhatId__c = delegateContact.Id,
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_HCP_ACCESS_LEVEL_CHANGED_TYPE
            );
        }
        if (notification != null) {
            insert notification;
        }
    }

    private static void sendEmailNotificationWelcome(Contact delegateContact) {
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        toSendNotificationMap.put(delegateContact.Id, delegateContact.Id);
        SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_DELEGATE_WELCOME, toSendNotificationMap);
    }

    private static Boolean savePIDelegate(DelegateWrapper dw) {
        Boolean hasDelegateLevels = false;
        Map<Id, Site_Staff__c> delegateSiteStaffMap =
                DelegateService.getPITeamStaffTrialMap().get(dw.delegateContact.Id);
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToUpdate = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToDelete = new List<Site_Staff__c>();
        for (TrialDelegateWrapper delegateTrialRecord : dw.delegateTrials) {
            for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {

                if (delegateRecord.delegateLevel != '') {
                    hasDelegateLevels = true;
                }
                if (delegateSiteStaffMap == null ||
                        delegateSiteStaffMap.get(delegateRecord.enrollmentOrStudySiteId) == null) {
                    if (delegateRecord.delegateLevel != '') {
                        Site_Staff__c newDelegateRecord = new Site_Staff__c();
                        newDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                        newDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                        newDelegateRecord.Site_Contact__c = dw.delegateContact.Id;
                        delegateRecordsToInsert.add(newDelegateRecord);
                    }
                } else {
                    Site_Staff__c curDelegateRecord =
                            delegateSiteStaffMap.get(delegateRecord.enrollmentOrStudySiteId);
                    if (delegateRecord.delegateLevel == '') {
                        delegateRecordsToDelete.add(curDelegateRecord);
                    } else if (delegateRecord.delegateLevel != curDelegateRecord.Delegate_Level__c) {
                        curDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                        delegateRecordsToUpdate.add(curDelegateRecord);
                    }
                }
            }
        }
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
            DelegateService.addConversationSharesForPITeam(delegateRecordsToInsert);
        }
        if (!delegateRecordsToUpdate.isEmpty()) {
            update delegateRecordsToUpdate;
        }
        if (!delegateRecordsToDelete.isEmpty()) {
            delete delegateRecordsToDelete;
        }
        return hasDelegateLevels;
    }

    private static Boolean saveHCPDelegate(DelegateWrapper dw, String parentId) {
        Boolean hasDelegateLevels = dw.trialLevel.delegateLevel != '';
        List<RP_Delegate_Relationship__c> delegates = [
                SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :dw.delegateContact.Id
                AND Referring_Provider__c = :parentId
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
    public static void savePatientDelegate(String delegate) {
        try {
            System.debug('savePatientDelegate:');
            Contact contactDelegate = (Contact) JSON.deserialize(delegate, Contact.class);
            Boolean isNewContact = contactDelegate.Id == null;
            if (isNewContact) {
                User user = [
                        SELECT Contact.AccountId
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                ];
                Participant__c participant = ParticipantService.getInstance().getState().participant;
                contactDelegate.AccountId = user.Contact.AccountId;
                contactDelegate.Current_Participant_Enrollment__c = null;
                contactDelegate.Language__c = UserInfo.getLanguage();
                contactDelegate.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                contactDelegate.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                contactDelegate.UserCommunityIsDelegate__c = true;
                contactDelegate.MailingCountryCode = participant.Mailing_Country_Code__c;
                contactDelegate.MailingStateCode = participant.Mailing_State_Code__c;
                contactDelegate.Landing_Community__c = Site.getMasterLabel().equals('IQVIA RH') ? CommunityService.IQVIA_NETWORK_NAME : Site.getMasterLabel();
                insert contactDelegate;

                User delegateUser = CommunityService.createUser(contactDelegate, null, null, null);
                insert delegateUser;

                Participant__c participantDelegate = new Participant__c(
                        Adult__c = true,
                        Contact__c = contactDelegate.Id,
                        First_Name__c = contactDelegate.FirstName,
                        Last_Name__c = contactDelegate.LastName,
                        Email__c = contactDelegate.Email,
                        Phone__c = contactDelegate.Phone,
                        Mailing_City__c = contactDelegate.MailingCity,
                        Mailing_Country_Code__c = contactDelegate.MailingCountryCode,
                        Mailing_State_Code__c = contactDelegate.MailingStateCode

                );
                insert participantDelegate;

            } else if (!CommunityService.isUserInCommunity(contactDelegate.Id)) {
                contactDelegate.UserCommunityIsDelegate__c = true;
                update contactDelegate;
                CommunityService.setUserToCommunity(contactDelegate.Id);
                sendEmailNotification(contactDelegate, CommunityService.USER_MODE_PARTICIPANT);
            }
            PatientDelegateService.getInstance().createPatientDelegate(contactDelegate);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static void createDelegate(DelegateWrapper delegate, String userMode, String parentId) {
        Contact delegateContact = createDelegateContact(delegate, userMode);
        List<Site_Staff__c> piDelegates = new List<Site_Staff__c>();
        List<TrialDelegateWrapper> dlw = delegate.delegateTrials;
        Boolean createUser = doCreateUser(dlw, userMode);
        if (userMode == CommunityService.USER_MODE_PI) {
            piDelegates = createPIDelegationRecord(delegate, delegateContact);
        }

        if (userMode == CommunityService.USER_MODE_HCP) {
            createHCPDelegationRecord(delegate, delegateContact, parentId);
        }

        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            delegate.delegateContact = delegateContact;
        }
        if (createUser) {
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{
                    delegateContact.Id
            });
        }
        if (!piDelegates.isEmpty()) {
            DelegateService.addConversationSharesForPITeam(piDelegates);
        }
    }

    public static Boolean doCreateUser(List<TrialDelegateWrapper> dlw, String userMode) {
        if(userMode != CommunityService.USER_MODE_PI){
          return true;
        }
        else{
            for (MyTeamRemote.TrialDelegateWrapper t : dlw) {
                for (MyTeamRemote.DelegateLevelWrapper d : t.siteLevels) {
                    if (d.ReferralStatus == 'Accepted' &&  String.isNotBlank(d.delegateLevel)) {
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
                SELECT Contact.AccountId,
                        Contact.MailingCity,
                        Contact.MailingCountry,
                        Contact.MailingState,
                        Contact.MailingStreet,
                        Contact.MailingPostalCode
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
        delegateContact.MailingCity = currentUser.Contact.MailingCity;
        delegateContact.MailingCountry = currentUser.Contact.MailingCountry;
        delegateContact.MailingState = currentUser.Contact.MailingState;
        delegateContact.MailingStreet = currentUser.Contact.MailingStreet;
        delegateContact.MailingPostalCode = currentUser.Contact.MailingPostalCode;
        insert delegateContact;
        return delegateContact;
    }

    private static List<Site_Staff__c> createPIDelegationRecord(DelegateWrapper delegate, Contact delegateContact) {
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        for (TrialDelegateWrapper delegateTrialRecord : delegate.delegateTrials) {
            for (DelegateLevelWrapper delegateRecord : delegateTrialRecord.siteLevels) {
                if (delegateRecord.delegateLevel != '') {
                    Site_Staff__c newDelegateRecord = new Site_Staff__c();
                    newDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                    newDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                    newDelegateRecord.Site_Contact__c = delegateContact.Id;
                    delegateRecordsToInsert.add(newDelegateRecord);
                }
            }
        }
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
        }
        return delegateRecordsToInsert;
    }

    private static void createHCPDelegationRecord(DelegateWrapper delegate, Contact delegateContact, String parentId) {
        RP_Delegate_Relationship__c delegateRecord = new RP_Delegate_Relationship__c();

        delegateRecord.Delegate__c = delegateContact.Id;
        delegateRecord.Referring_Provider__c = parentId;
        delegateRecord.Delegate_Access_Level__c = delegate.trialLevel.delegateLevel;
        insert delegateRecord;
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
    public class DelegateWrapper implements Comparable {
        public Contact delegateContact;
        public Boolean isActive;
        public List<TrialDelegateWrapper> delegateTrials;
        public List<DelegateLevelWrapper> trialLevels;
        public DelegateLevelWrapper trialLevel;
        public DelegateWrapper() {
            delegateTrials = new List<TrialDelegateWrapper>();
        }
        public Integer compareTo(Object compareTo) {
            DelegateWrapper compareToDelegate = (DelegateWrapper) compareTo;
            if (delegateContact.Id == CommunityService.getUserContact().Id)
                return -1;
            if (compareToDelegate.delegateContact.Id == CommunityService.getUserContact().Id)
                return 1;
            if ((delegateContact.FirstName + ' ' + delegateContact.LastName) > (compareToDelegate.delegateContact.FirstName + ' ' + compareToDelegate.delegateContact.LastName)) {
                return 1;
            } else if ((delegateContact.FirstName + ' ' + delegateContact.LastName) < (compareToDelegate.delegateContact.FirstName + ' ' + compareToDelegate.delegateContact.LastName)) {
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

}