/**
 * Created by Kryvolap on 14.09.2018.
 */

public without sharing class MyTeamRemote {
    //TODO:get only active Studies
    private static final String ACTIVE_STUDY_SITES_FILTER = 'AND (Override_PI_Referral_Status__c IN (\'Accepted\',\'Accepted (Admin)\'))';
    private static final String ACTIVE_HCP_ENROLLMENTS_FILTER = 'AND (Status__c IN (\'Activated\',\'Activated (Admin)\'))';
    @AuraEnabled
    public static String getInitData(String userMode, String parentId) {
        try {
            MyTeamRemote.MyTeamDetail detail = new MyTeamRemote.MyTeamDetail();
            detail.currentUserContactId = CommunityService.getUserContact().Id;
            detail.delegates = getDelegates(userMode, userMode != CommunityService.USER_MODE_HCP, null, parentId);
            detail.delegateOptions = getDelegateOptions(userMode);
            if (userMode == CommunityService.USER_MODE_PI) {
                detail.hasStudies = !StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>{
                        DelegateService.DELEGATE_LEVEL_1
                }).isEmpty();
            }
            if (userMode == CommunityService.USER_MODE_HCP) {
                detail.hasStudies =  parentId == '' || DelegateService.getHCPDelegateLevelMap().get(parentId) == DelegateService.DELEGATE_LEVEL_1;
            }
            if (userMode == CommunityService.USER_MODE_PARTICIPANT)
                detail.hasStudies = ParticipantEnrollmentService.getPEnrolmentsCountCommon(userMode, '') != 0;

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
            return JSON.serialize(detail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static List<DelegateWrapper> getDelegates(String userMode, Boolean excludeCurrentUser, List<Contact> delegatesToProcess, String parentId) {
        if(parentId == null || parentId == ''){
            parentId = CommunityService.getInstance().getCurrentContactId();
        }
        List<DelegateWrapper> delegates = new List<DelegateWrapper>();
        Boolean useProvidedContacts = delegatesToProcess != null && !delegatesToProcess.isEmpty();
        if (userMode == CommunityService.USER_MODE_PI) {
            List<Study_Site__c> studySites;
            if (!useProvidedContacts) {
                studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>(DelegateService.DELEGATE_LEVEL_1_AND_LOW));
            } else {
                studySites = StudySiteService.getStudySitesWithDelegateLevelFiltered(ACTIVE_STUDY_SITES_FILTER, new Set<String>{
                        DelegateService.DELEGATE_LEVEL_1
                });
            }
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
                        for (Study_Site__c study : studySites) {
                            TrialDelegateLevelWrapper trialLevel = new TrialDelegateLevelWrapper();
                            trialLevel.trialName = study.Clinical_Trial_Profile__r.Study_Code_Name__c + '(' + study.Name + ')';
                            trialLevel.enrollmentOrStudySiteId = study.Id;
                            trialLevel.delegateLevel = '';
                            trialLevel.readOnly = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(DelegateService.getPIStudySitesAccessLevelMap().get(study.Id));
                            Site_Staff__c delegateRecord =
                                    (staffTrialMap.get(delegateContact.Id) == null)
                                            ? null : (staffTrialMap.get(delegateContact.Id).get(study.Id));
                            if (delegateRecord != null) {
                                trialLevel.delegateLevel = delegateRecord.Delegate_Level__c;
                            }
                            dw.trialLevels.add(trialLevel);
                        }
                        dw.trialLevels.sort();

                        delegates.add(dw);
                    }
                }
            }
        }
        if (userMode == CommunityService.USER_MODE_HCP) {
//            List<HCP_Enrollment__c> hcpEnrollments;
//            if (!useProvidedContacts) {
//                hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsWithDelegateLevelFiltered(ACTIVE_HCP_ENROLLMENTS_FILTER, new Set<String>(DelegateService.DELEGATE_LEVEL_1_AND_LOW));
//            } else {
//                hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsWithDelegateLevelFiltered(ACTIVE_HCP_ENROLLMENTS_FILTER, new Set<String>{
//                        DelegateService.DELEGATE_LEVEL_1
//                });
//            }
            List<RP_Delegate_Relationship__c> delegatesQR = [SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c FROM RP_Delegate_Relationship__c WHERE Referring_Provider__c = :parentId];

            //Map<Id, Map<Id, Referring_HCP_Staff__c>> staffTrialMap = DelegateService.getHCPTeamStaffTrialMap();
            List<Contact> delegateContacts;
            Map<Id, String> delegateLevels = new Map<Id, String>();
            Set<Id> delegateIds = new Set<Id>();
            for(RP_Delegate_Relationship__c delegate:delegatesQR){
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
            for (Contact delegateContact : delegateContacts) {
                if (!excludeCurrentUser || delegateContact.Id != CommunityService.getUserContact().Id) {
                    DelegateWrapper dw = new DelegateWrapper();
                    dw.delegateContact = delegateContact;
//                        for (HCP_Enrollment__c enrollment : hcpEnrollments) {
//                            TrialDelegateLevelWrapper trialLevel = new TrialDelegateLevelWrapper();
//                            trialLevel.trialName = enrollment.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c + '(' + enrollment.Study_Site__r.Name + ')';
//                            trialLevel.enrollmentOrStudySiteId = enrollment.Id;
//                            trialLevel.delegateLevel = '';
//                            trialLevel.readOnly = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(DelegateService.getHCPEnrollmentAccessLevelMap().get(enrollment.Id)) ||
//                                    delegateContact.Id == CommunityService.getUserContact().Id;
//                            Referring_HCP_Staff__c delegateRecord =
//                                    (staffTrialMap.get(delegateContact.Id) == null) ?
//                                            null : (staffTrialMap.get(delegateContact.Id).get(enrollment.Id));
//                            if (delegateRecord != null) {
//                                trialLevel.delegateLevel = delegateRecord.Delegate_Level__c;
//                            }
//                            dw.trialLevels.add(trialLevel);
//                        }
//                        dw.trialLevels.sort();
                    dw.trialLevel = new TrialDelegateLevelWrapper();
                    dw.trialLevel.delegateLevel = delegateLevels.get(delegateContact.Id) != null ? delegateLevels.get(delegateContact.Id):'';
                    dw.trialLevel.readOnly = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(DelegateService.getHCPDelegateLevelMap().get(parentId))
                            || delegateContact.Id == CommunityService.getUserContact().Id;
                    dw.trialLevels.add(dw.trialLevel);
                    delegates.add(dw);
                }
            }

        }
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            List<Contact> delegateContacts;
            if (useProvidedContacts) {
                delegateContacts = delegatesToProcess;
            } else {
                delegateContacts = PatientDelegateService.getInstance().getDelegates();
            }

            for (Contact patientDelegate : delegateContacts) {
                DelegateWrapper dw = new DelegateWrapper();
                dw.delegateContact = patientDelegate;
                for (Participant_Enrollment__c partEnroll :
                        ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant()
                ) {
                    TrialDelegateLevelWrapper trialWrap = new TrialDelegateLevelWrapper();
                    trialWrap.trialName = partEnroll.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
                    trialWrap.enrollmentOrStudySiteId = partEnroll.Id;
                    trialWrap.delegateLevel = '';
                    dw.trialLevels.add(trialWrap);
                }

                delegates.add(dw);
            }
        }

        delegates.sort();
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

    @AuraEnabled
    public static void saveDelegateLevelChanges(String userMode, String delegate, String parentId) {
        Savepoint sp = Database.setSavepoint();
        try {
            DelegateWrapper dw = (DelegateWrapper) JSON.deserialize(delegate, DelegateWrapper.class);
            if(parentId == null || parentId == ''){
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
                    sendEmailNotification(dw.delegateContact);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    private static void sendEmailNotification(Contact delegateContact) {
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        toSendNotificationMap.put(delegateContact.Id, delegateContact.Id);
        SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_DELEGATE, toSendNotificationMap);
    }

    private static void sendEmailNotificationWelcome(Contact delegateContact) {
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        toSendNotificationMap.put(delegateContact.Id, delegateContact.Id);
        SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_DELEGATE_WELCOME, toSendNotificationMap);
    }

    private static Boolean savePIDelegate(DelegateWrapper dw){
        Boolean hasDelegateLevels = false;
        Map<Id, Site_Staff__c> delegateSiteStaffMap =
                DelegateService.getPITeamStaffTrialMap().get(dw.delegateContact.Id);
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToUpdate = new List<Site_Staff__c>();
        List<Site_Staff__c> delegateRecordsToDelete = new List<Site_Staff__c>();
        for (TrialDelegateLevelWrapper delegateRecord : dw.trialLevels) {
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
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
        }
        if (!delegateRecordsToUpdate.isEmpty()) {
            update delegateRecordsToUpdate;
        }
        if (!delegateRecordsToDelete.isEmpty()) {
            delete delegateRecordsToDelete;
        }
        return hasDelegateLevels;
    }

    private static Boolean saveHCPDelegate(DelegateWrapper dw, String parentId){
        Boolean hasDelegateLevels = dw.trialLevel.delegateLevel != '';
        List<RP_Delegate_Relationship__c> delegates =  [
                SELECT Id, Referring_Provider__c, Delegate__c, Delegate_Access_Level__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :dw.delegateContact.Id
                AND Referring_Provider__c = :parentId
        ];
        if(delegates.isEmpty()){
            RP_Delegate_Relationship__c newDelegate = new RP_Delegate_Relationship__c();
            newDelegate.Delegate__c = dw.delegateContact.Id;
            newDelegate.Referring_Provider__c = parentId;
            newDelegate.Delegate_Access_Level__c = dw.trialLevel.delegateLevel;
            insert newDelegate;
        }
        else if(dw.trialLevel.delegateLevel == ''){
            delete delegates;
        }
        else {
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
                contactDelegate.Language__c = UserInfo.getLanguage();
                contactDelegate.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                contactDelegate.UserCommunityIsDelegate__c = true;
                contactDelegate.MailingCountryCode = participant.Mailing_Country_Code__c;
                contactDelegate.MailingStateCode = participant.Mailing_State_Code__c;
                insert contactDelegate;
                insert CommunityService.createUser(contactDelegate, null, null, null);
            } else {
                if (CommunityService.isUserInCommunity(contactDelegate.Id)) {
                    throw new PatientDelegateService.PatientDelegateServiceException(Label.PG_PST_L_Delegates_CantAssign);
                }
                CommunityService.setUserToCommunity(contactDelegate.Id);
                sendEmailNotification(contactDelegate);
            }
            PatientDelegateService.getInstance().createPatientDelegate(contactDelegate);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static void createDelegate(DelegateWrapper delegate, String userMode, String parentId) {
        Contact delegateContact = createDelegateContact(delegate, userMode);

        if (userMode == CommunityService.USER_MODE_PI) {
            createPIDelegationRecord(delegate, delegateContact);
        }

        if (userMode == CommunityService.USER_MODE_HCP) {
            createHCPDelegationRecord(delegate, delegateContact, parentId);
        }

        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            delegate.delegateContact = delegateContact;
        }

        ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{
                delegateContact.Id
        });
    }

    private static Contact createDelegateContact(DelegateWrapper delegate, String userMode){
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
        delegateContact.Language__c = UserInfo.getLanguage();
        delegateContact.MailingCity = currentUser.Contact.MailingCity;
        delegateContact.MailingCountry = currentUser.Contact.MailingCountry;
        delegateContact.MailingState = currentUser.Contact.MailingState;
        delegateContact.MailingStreet = currentUser.Contact.MailingStreet;
        delegateContact.MailingPostalCode = currentUser.Contact.MailingPostalCode;
        insert delegateContact;
        return delegateContact;
    }

    private static void createPIDelegationRecord(DelegateWrapper delegate, Contact delegateContact) {
        List<Site_Staff__c> delegateRecordsToInsert = new List<Site_Staff__c>();
        for (TrialDelegateLevelWrapper delegateRecord : delegate.trialLevels) {
            if (delegateRecord.delegateLevel != '') {
                Site_Staff__c newDelegateRecord = new Site_Staff__c();
                newDelegateRecord.Delegate_Level__c = delegateRecord.delegateLevel;
                newDelegateRecord.Study_Site__c = delegateRecord.enrollmentOrStudySiteId;
                newDelegateRecord.Site_Contact__c = delegateContact.Id;
                delegateRecordsToInsert.add(newDelegateRecord);
            }
        }
        if (!delegateRecordsToInsert.isEmpty()) {
            insert delegateRecordsToInsert;
        }
    }

    private static void createHCPDelegationRecord(DelegateWrapper delegate, Contact delegateContact, String parentId){
        RP_Delegate_Relationship__c delegateRecord = new RP_Delegate_Relationship__c();

            delegateRecord.Delegate__c = delegateContact.Id;
            delegateRecord.Referring_Provider__c = parentId;
            delegateRecord.Delegate_Access_Level__c = delegate.trialLevel.delegateLevel;
            insert delegateRecord;
    }

    public class MyTeamDetail {
        public List<LabelValueItem> delegateOptions;
        public List<DelegateWrapper> delegates;
        public Id currentUserContactId;
        public Boolean hasStudies;
        public MyTeamDetail() {
            delegates = new List<DelegateWrapper>();
        }
    }
    public class DelegateWrapper implements Comparable {
        public Contact delegateContact;
        public List<TrialDelegateLevelWrapper> trialLevels;
        public TrialDelegateLevelWrapper trialLevel;
        public DelegateWrapper() {
            trialLevels = new List<TrialDelegateLevelWrapper>();
        }
        public Integer compareTo(Object compareTo) {
            DelegateWrapper compareToDelegate = (DelegateWrapper) compareTo;
            if ((delegateContact.FirstName + ' ' + delegateContact.LastName) > (compareToDelegate.delegateContact.FirstName + ' ' + compareToDelegate.delegateContact.LastName)) {
                return 1;
            } else if ((delegateContact.FirstName + ' ' + delegateContact.LastName) < (compareToDelegate.delegateContact.FirstName + ' ' + compareToDelegate.delegateContact.LastName)) {
                return -1;
            }
            return 0;
        }
    }
    public class TrialDelegateLevelWrapper implements Comparable {
        public String delegateLevel;
        public String trialName;
        public String enrollmentOrStudySiteId;
        public Boolean readOnly;

        public Integer compareTo(Object compareTo) {
            if (trialName > ((TrialDelegateLevelWrapper) compareTo).trialName) {
                return 1;
            } else if (trialName < ((TrialDelegateLevelWrapper) compareTo).trialName) {
                return -1;
            }
            return 0;
        }
    }

}