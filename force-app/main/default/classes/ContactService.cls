/**
 * Created by Leonid Bartenev
 */

public without sharing class ContactService {
    public static Map<Id, Patient_Delegate__c> patientdelList = new Map<Id, Patient_Delegate__c>(); // Added by Anitha
    public class PastStudyWrapper {
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public Participant_Enrollment__c pe;
        @AuraEnabled
        public List<ResourceService.ResourceWrapper> resourceWrappers;
        @AuraEnabled
        public Boolean showReport;

        public PastStudyWrapper(
            Clinical_Trial_Profile__c ctp,
            Participant_Enrollment__c pe,
            List<ResourceService.ResourceWrapper> resourceWrappers,
            Boolean hadEnrolmentSuccess
        ) {
            this.ctp = ctp;
            this.pe = pe;
            this.resourceWrappers = resourceWrappers;
            this.showReport =
                hadEnrolmentSuccess &&
                ctp.Visit_Data_Shareback__c &&
                pe.Study_Site__r.Visit_Results_Sharing__c &&
                ctp.Patient_Portal_Enabled__c;
        }
    }

    /**
     * applyRelevantNames() this method substitutes the FirstName and LastName field values in all related objects of type Contact
     * found in the specified SObject (or List<SObject>) with the relevant values in fields FirstName and LastName from object Participant
     * in case if it exists for the parent Contact
     *
     * @param obj
     */
    public static void applyRelevantNames(SObject obj) {
        applyRelevantNames(new List<SObject>{ obj });
    }
    public static void applyRelevantNames(List<SObject> objects) {
        try {
            // collecting all related objects including all nested ones
            List<SObject> aggregateObjects = SObjectHelper.getAllSObjects(objects);

            /* for (SObject obj : objects) {
                aggregateObjects.addAll(SObjectHelper.getAllSObjects(obj));
            }*/

            // select SObjects only of type Contact
            SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
            Map<Id, Contact> contacts = new Map<Id, Contact>();
            for (SObject obj : aggregateObjects) {
                if (obj.getSObjectType() != contactType)
                    continue; // skip SObjects of non Contact type
                contacts.put(obj.Id, (Contact) obj);
            }

            // query Participants and replace FirstName and LastName fields if they exist
            for (Participant__c participant : [
                SELECT First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
                WHERE Contact__c IN :contacts.keySet()
            ]) {
                contacts.get(participant.Contact__c).FirstName = participant.First_Name__c;
                contacts.get(participant.Contact__c).LastName = participant.Last_Name__c;
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static Participant_Enrollment__c getCurrentPE(Id contactId) {
        Contact contact = [
            SELECT
                Id,
                Current_Participant_Enrollment__r.Participant__r.Full_Name__c,
                Current_Participant_Enrollment__r.Participant__r.First_Name__c,
                Current_Participant_Enrollment__r.Participant__r.Last_Name__c,
                Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Contact
            WHERE Id = :contactId
        ];
        return contact.Current_Participant_Enrollment__r;
    }

    public static List<PastStudyWrapper> getPastStudyWrappers(Id contactId) {
        List<Id> peIds = PatientDelegateService.getPastPEIdsForContact(contactId);
        if (peIds == null)
            return new List<PastStudyWrapper>();
        List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getPEnrolmentsCommon(
            CommunityService.USER_MODE_PARTICIPANT,
            ' AND Id IN ' + DatabaseService.listToString(peIds)
        );
        Set<Id> ctpIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peList) {
            ctpIds.add(pe.Study_Site__r.Clinical_Trial_Profile__c);
        }
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>(
            TrialService.getTrials(new List<Id>(ctpIds))
        );
        List<Res_study__c> resStudyList = [
            SELECT
                Id,
                Name,
                Active_On_Status__c,
                Expires_On_Status__c,
                Active_After_Days__c,
                Expires_After_Days__c,
                Notify_On_Availability__c,
                Resource__c,
                Resource__r.Title__c,
                Resource__r.RecordType.DeveloperName,
                Resource__r.Content_Type__c,
                Visible_In_Alumni__c,
                Visible_To_Delegates__c,
                Clinical_Trial_Profile__c,
                Visible_To_Participant__c,
                Visible_To_PI__c,
                Visible_To_RP__c
            FROM Res_study__c
            WHERE Clinical_Trial_Profile__c IN :ctpIds
        ];
        List<Id> resourceIds = new List<Id>();
        for (Res_study__c resStudy : resStudyList)
            resourceIds.add(resStudy.Resource__c);
        Map<Id, List<ContentDocumentLinkService.TranslatedContentItem>> translatedItemsMap = ((ContentDocumentLinkService) ClassFactory.newInstance(
                ContentDocumentLinkService.class
            ))
            .getTranslatedItemsForResources(resourceIds);
        List<String> COIsOfParticipant = new List<String>();
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatients = [
            SELECT Therapeutic_Area__r.Name
            FROM Therapeutic_Area_Patient__c
            WHERE Participant__r.Contact__c = :contactId
        ];
        for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatients) {
            COIsOfParticipant.add(tap.Therapeutic_Area__r.Name);
        }
        Map<Id, Resource__c> relatedResources = new Map<Id, Resource__c>(
            [
                SELECT
                    Id,
                    Title__c,
                    RecordType.DeveloperName,
                    Content_Type__c,
                    (
                        SELECT Id
                        FROM Therapeutic_Area_Assignments__r
                        WHERE Therapeutic_Area__r.Name IN :COIsOfParticipant
                    )
                FROM Resource__c
                WHERE Id IN :resourceIds
            ]
        );

        Map<Id, List<Res_study__c>> resStudyByCtpIdMap = new Map<Id, List<Res_study__c>>();
        Set<Id> resStudyResourceIds = new Set<Id>();
        for (Res_study__c resStudy : resStudyList) {
            List<Res_study__c> ctpResStudyList = resStudyByCtpIdMap.get(
                resStudy.Clinical_Trial_Profile__c
            );
            if (ctpResStudyList == null)
                ctpResStudyList = new List<Res_study__c>();
            ctpResStudyList.add(resStudy);
            resStudyByCtpIdMap.put(resStudy.Clinical_Trial_Profile__c, ctpResStudyList);
            resStudyResourceIds.add(resStudy.Resource__c);
        }
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        if (resStudyResourceIds.size() > 0) {
            contentDocumentLinks = [
                SELECT
                    Id,
                    ContentDocument.Title,
                    LinkedEntityId,
                    ContentDocument.LatestPublishedVersion.LanguageCode__c
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :resStudyResourceIds
            ];
        }

        Map<Id, List<String>> contentLangByResId = new Map<Id, List<String>>();
        for (ContentDocumentLink content : contentDocumentLinks) {
            if (!contentLangByResId.containsKey(content.LinkedEntityId)) {
                contentLangByResId.put(content.LinkedEntityId, new List<String>());
            }
            if (
                content.ContentDocument.LatestPublishedVersion.LanguageCode__c != '' &&
                content.ContentDocument.LatestPublishedVersion.LanguageCode__c != null
            ) {
                contentLangByResId.get(content.LinkedEntityId)
                    .add(content.ContentDocument.LatestPublishedVersion.LanguageCode__c);
            } else {
                contentLangByResId.get(content.LinkedEntityId).add(content.ContentDocument.Title);
            }
        }
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        if (!peList.isEmpty()) {
            peshList = [
                SELECT ParticipantEnrollment__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN :peList
            ];
        }
        Map<Id, Set<String>> historyStatusesByPEIdMap = new Map<Id, Set<String>>();
        for (Participant_Enrollment_Status_History__c pesh : peshList) {
            Set<String> statuses = historyStatusesByPEIdMap.get(pesh.ParticipantEnrollment__c);
            if (statuses == null)
                statuses = new Set<String>();
            statuses.add(pesh.Status__c);
            historyStatusesByPEIdMap.put(pesh.ParticipantEnrollment__c, statuses);
        }

        List<PastStudyWrapper> pastWrappersList = new List<ContactService.PastStudyWrapper>();
        for (Participant_Enrollment__c pe : peList) {
            List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
            List<Res_study__c> resStudyForCtpList = resStudyByCtpIdMap.get(
                pe.Study_Site__r.Clinical_Trial_Profile__c
            );
            if (resStudyForCtpList != null) {
                for (Res_study__c resStudy : resStudyForCtpList) {
                    Boolean isDelegate =
                        pe.Participant__r.Contact__c != CommunityService.getUserContact().Id;
                    if (
                        StudyResourceVisibilityService.isResourceVisibleForPE(
                            resStudy,
                            pe,
                            contentLangByResId.get(resStudy.Resource__c),
                            CommunityService.USER_MODE_PARTICIPANT,
                            isDelegate
                        )
                    ) {
                        resources.add(
                            new ResourceService.ResourceWrapper(
                                relatedResources.get(resStudy.Resource__c),
                                translatedItemsMap.get(resStudy.Resource__c)
                            )
                        );
                    }
                }
            }
            Set<String> peHistoryStatuses = historyStatusesByPEIdMap.get(pe.Id);
            resources = ResourceService.sortResourcesByCOI(resources);
            resources = ResourceService.removeTranslations(resources);
            Boolean hadEnrolmentSuccess =
                peHistoryStatuses != null &&
                (peHistoryStatuses.contains(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) ||
                peHistoryStatuses.contains(PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS));
            pastWrappersList.add(
                new PastStudyWrapper(
                    ctpMap.get(pe.Clinical_Trial_Profile__c),
                    pe,
                    resources,
                    hadEnrolmentSuccess
                )
            );
        }
        return pastWrappersList;
    }

    public static List<Participant_Enrollment__c> getPastEnrollments(Id contactId) {
        String filter =
            DatabaseService.fieldEqual('Participant_Contact__c', contactId) +
            'AND' +
            DatabaseService.fieldInValues(
                'Participant_Status__c',
                PEStatusState.PE_STATUS_GROUP_ALUMNI
            );
        return (List<Participant_Enrollment__c>) DatabaseService.query(
            ParticipantEnrollmentService.PE_COMMON_FIELDS,
            Participant_Enrollment__c.getSObjectType(),
            filter
        );
    }

    public static void updateNextNotifyDate(Id cntId, Datetime lastLoginDateByContactId) {
        Id participantCnt = ParticipantContext.getCurrentContactId();

        Map<Id, Integer> notifyDayByPartCnt = ParticipantService.getNearestLogOutNotification(
            new List<Id>{ participantCnt }
        );
        if (!notifyDayByPartCnt.containsKey(participantCnt))
            return;

        update new Contact(
            Id = cntId,
            Next_Notify_Date__c = lastLoginDateByContactId.addDays(
                    notifyDayByPartCnt.get(participantCnt)
                )
                .date()
        );
    }

    public static List<String> getPreferredLanguages() {
        Contact contact = CommunityService.getUserContact();
        List<String> preferredLaguages = new List<String>();
        preferredLaguages.add(contact.Language__c);
        if (!String.isEmpty(contact.Second_Choice_Language__c))
            preferredLaguages.add(contact.Second_Choice_Language__c);
        if (!String.isEmpty(contact.Third_Choice_Language__c))
            preferredLaguages.add(contact.Third_Choice_Language__c);
        return preferredLaguages;
    }
    @AuraEnabled
    public static Contact getContact(Id contactId) {
        if (contactId == null)
            return null;
        return [
            SELECT
                Id,
                Name,
                Is_First_Logon__c,
                Full_Name__c,
                Salutation,
                FirstName,
                MiddleName,
                LastName,
                Suffix,
                Fax,
                primaryContact__c,
                userCommunityMode__c,
                userCommunityDelegateId__c,
                userCommunytyType__c,
                UserCommunityIsDelegate__c,
                HCP_DelegateAccessLevel__c,
                PI_DelegateAccessLevel__c,
                userCommunity_ShowTour__c,
                Current_Participant_Enrollment__c,
                Current_Sponsor_Name__c,
                Next_Notify_Date__c,
                Last_Session_Id__c,
                Language__c,
                Second_Choice_Language__c,
                MailingLatitude,
                MailingCountryCode,
                MailingStateCode,
                MailingLongitude,
                MailingCountry,
                MailingCity,
                MailingPostalCode,
                MailingState,
                MailingStreet,
                PI_My_Studies_Filters__c,
                Third_Choice_Language__c,
                Participant_Opt_In_Status_Emails__c,
                Participant_Opt_In_Status_SMS__c,
                Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Direct_Mail_Consent__c,
                Visit_Results_OptIn__c,
                Visited_Communities__c,
                Email,
                Account.OwnerId,
                Account.Name,
                Account.Phone,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.Fax,
                Account.BillingCountry,
                Account.BillingPostalCode,
                Account.BillingCountryCode,
                Phone,
                MobilePhone,
                Phone_Type__c,
                HCP_Opt_In_Patient_Status_Emails__c,
                HCP_Opt_In_Referral_Status_Emails__c,
                HCP_Opt_In_Study_Emails__c,
                Cookies_Agreed_on_Reg__c
            FROM Contact
            WHERE Id = :contactId
        ];
    }
    public static void updateVisitedCommunity(Contact contact, CommunityTemplate template) {
        List<String> communities = new List<String>();
        String commStr = contact.Visited_Communities__c;
        if (String.isNotEmpty(commStr))
            communities.addAll(commStr.split(';'));
        if (!communities.contains(template.templateName)) {
            communities.add(template.templateName);
            commStr = String.join(communities, ';');
            update new Contact(Id = contact.Id, Visited_Communities__c = commStr);
        }
    }

    public static Boolean checkVisitedCommunity(Id conId) {
        Contact con = [SELECT Id, Visited_Communities__c FROM Contact WHERE Id = :conId];
        return String.isNotEmpty(con.Visited_Communities__c);
    }
    public static void updateContactSite(List<Participant__c> participants) {
        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Participant__c,
                Participant_Status__c,
                Study_Site__r.Site__c,
                Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Participant__c IN :participants
            ORDER BY Participant__c
        ];
        Set<Id> conIds = new Set<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            conIds.add(pe.Participant_Contact__c);
        }
        List<Contact> consToBeUpdated = new List<Contact>();
        List<Contact> consToUpdate = [SELECT Id, AccountId FROM Contact WHERE Id IN :conIds];
        List<Patient_Delegate__c> pds = [
            SELECT Id, Contact__c, Participant__c, Participant__r.Contact__r.AccountId
            FROM Patient_Delegate__c
            WHERE Contact__c IN :conIds
        ];
        for (Contact con : consToUpdate) {
            for (Participant_Enrollment__c pe : enrollments) {
                if (pe.Participant_Contact__c == con.Id) {
                    con.AccountId = pe.Study_Site__r.Site__c;
                }
            }
            consToBeUpdated.add(con);
        }
        if (consToBeUpdated.size() > 0)
            update consToBeUpdated;
        if (pds.size() > 0) {
            updatePatientDelegates(pds);
        }
    }

    public static void updatePatientDelegates(List<Patient_Delegate__c> patientDelegates) {
        Set<Id> conIds = new Set<Id>();
        for (Patient_Delegate__c pds : patientDelegates) {
            conIds.add(pds.Contact__c);
        }
        List<Contact> consToBeUpdated = new List<Contact>();
        List<Contact> consToUpdate = [SELECT Id, AccountId FROM Contact WHERE Id IN :conIds];
        for (Contact con : consToUpdate) {
            for (Patient_Delegate__c pd : patientDelegates) {
                if (pd.Contact__c == con.Id) {
                    con.AccountId = pd.Participant__r.Contact__r.AccountId;
                }
            }
            consToBeUpdated.add(con);
        }
        if (consToBeUpdated.size() > 0)
            update consToBeUpdated;
    }

    /**
     * @description: This method will be used adding up the notifications for the welcome Message story.
     * @author: Anitha Chavva
     * @param: recepientId
     * @param: whatid
     * @param: notificationtype
     **/
    public static List<Notification__c> addwelcomeNotifications(
        String recepientId,
        String whatId,
        String notificationtype,
        Boolean isDelegate
    ) {
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        welcomemsgnotifications.add(
            new Notification__c(
                Recipient__c = recepientId, //per.Participant_contact__c,
                WhatId__c = whatId,
                Notification_Type__c = notificationtype,
                IsDelegate__c = isDelegate
            )
        );
        return welcomemsgnotifications;
    }
}
