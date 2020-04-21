/**
 * Created by Alexey Moseev on 2019-09-23.
 */

global without sharing class ReferHealthcareProviderRemote {

    public class InitData {
        @AuraEnabled public List<Healthcare_Provider__c> healthcareProviders;
        @AuraEnabled public List<Patient_Delegate__c> listDelegates;

        public initData(List<Healthcare_Provider__c> healthcareProviders, List<Patient_Delegate__c> listDelegates) {
            this.healthcareProviders = healthcareProviders;
            this.listDelegates = listDelegates;
        }

    }

    @AuraEnabled
    public static InitData getInitData(String peId, String participantId) {
        List<Healthcare_Provider__c> healthcareProviders = [
                SELECT Id,
                        First_Name__c,
                        Last_Name__c,
                        Email__c,
                        Status__c,
                        Participant_Enrollment__c,
                        HCP_Enrollment__c
                FROM Healthcare_Provider__c
                WHERE Participant_Enrollment__c = :peId
        ];
        if (healthcareProviders.isEmpty()) healthcareProviders.add(new Healthcare_Provider__c());

        List<Patient_Delegate__c> listDelegates = PatientDelegateService.getPatientDelegates(participantId);
        if (listDelegates.isEmpty()) listDelegates.add(new Patient_Delegate__c());

        return new InitData(healthcareProviders, listDelegates);
    }

    @AuraEnabled
    public static HealthcareProvider checkDuplicate(String peId, String email) {
        HealthcareProvider hp = new HealthcareProvider();
        hp.email = email;

        if (!String.isBlank(email)) {
            List<Contact> contacts = [
                    SELECT Id,
                            FirstName,
                            LastName,
                            Name,
                            Email,
                            userCommunytyType__c
                    FROM Contact
                    WHERE Email = :email OR Email = :email.toLowerCase()
            ];

            if (!contacts.isEmpty()) {
                if (String.isBlank(contacts[0].FirstName) || String.isBlank(contacts[0].LastName)) {
                    List<Participant__c> participants = [
                            SELECT Id,
                                    First_Name__c,
                                    Last_Name__c
                            FROM Participant__c
                            WHERE Contact__c = :contacts[0].Id
                    ];
                    if (!participants.isEmpty()) {
                        hp.firstName = participants[0].First_Name__c;
                        hp.lastName = participants[0].Last_Name__c;
                        contacts[0].FirstName = participants[0].First_Name__c;
                        contacts[0].LastName = participants[0].Last_Name__c;
                        update contacts[0];
                    } else {
                        hp.firstName = contacts[0].FirstName;
                        hp.lastName = contacts[0].LastName;
                    }
                } else {
                    hp.firstName = contacts[0].FirstName;
                    hp.lastName = contacts[0].LastName;
                }
                hp.email = contacts[0].Email;
                hp.hcpContactId = contacts[0].Id;
                if (peId != null) {
                    List<Healthcare_Provider__c> isDuplicate = [
                            SELECT Id
                            FROM Healthcare_Provider__c
                            WHERE Participant_Enrollment__c = :peId
                            AND Email__c = :email
                    ];
                    if (!isDuplicate.isEmpty()) {
                        hp.isDuplicate = true;
                    } else {
                        hp.isDuplicate = false;
                    }

                    List<Patient_Delegate__c> duplicateDelegates = [
                            SELECT Id
                            FROM Patient_Delegate__c
                            WHERE Participant__c = :
                                    [
                                            SELECT Participant__c
                                            FROM Participant_Enrollment__c
                                            WHERE Id = :peId
                                            LIMIT 1
                                    ].Participant__c
                            AND Contact__r.Email = :email
                    ];
                    if (!duplicateDelegates.isEmpty()) {
                        hp.isDuplicateDelegate = true;
                    } else {
                        hp.isDuplicateDelegate = false;
                    }
                } else {
                    hp.isDuplicate = contacts[0].get('userCommunytyType__c') != null && contacts[0].userCommunytyType__c.contains('HCP');
                }

                /*Healthcare_Provider__c newHP = new Healthcare_Provider__c();
                newHP.Participant_Enrollment__c = peId;
                newHP.Email__c = hp.email;
                newHP.First_Name__c = hp.firstName;
                newHP.Last_Name__c = hp.lastName;
                newHP.Status__c = HP_S_DUPLICATE;
                insert newHP;*/
            }
        }

        return hp;
    }

    @AuraEnabled
    public static List<Healthcare_Provider__c> inviteHP(String peId, String hp) {
        Healthcare_Provider__c newHP = (Healthcare_Provider__c) JSON.deserialize(hp, Healthcare_Provider__c.class);

        Participant_Enrollment__c pe = [
                SELECT Id,
                        Study_Site__c,
                        Participant__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
        ];
        List<HCP_Enrollment__c> hcpe = new List<HCP_Enrollment__c>();

        if (!String.isBlank(peId) && newHP != null && String.isBlank(newHP.Id)) {
            newHP.Participant_Enrollment__c = peId;
            newHP.Status__c = HP_S_INVITED;
            insert newHP;
            try {
                createHCPinPlatform(pe.Study_Site__c, newHP.First_Name__c, newHP.Last_Name__c, newHP.Email__c, null, CommunityService.getUserContact(), newHP, null, null);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }
        } else if (!String.isBlank(newHP.Id) && newHP.Status__c == HP_S_NOSHARING) {
            hcpe = [
                    SELECT Id,
                            HCP_Contact__c,
                            Status__c
                    FROM HCP_Enrollment__c
                    WHERE Id = :newHP.HCP_Enrollment__c
            ];

            if (hcpe.isEmpty()) {
                List<Contact> contacts = [
                        SELECT Id,
                                Email,
                                AccountId
                        FROM Contact
                        WHERE Email = :newHP.Email__c OR Email = :newHP.Email__c.toLowerCase()
                ];

                hcpe.add(new HCP_Enrollment__c(
                        HCP_Contact__c = contacts[0].Id,
                        HCP_Account__c = contacts[0].AccountId,
                        Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
                ));
                insert hcpe;

                newHP.HCP_Enrollment__c = hcpe[0].Id;

                newHP.Status__c = HP_S_INVITED;
                update newHP;

                hcpe[0].Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
                update hcpe;
                hcpe[0].Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
                update hcpe;
            } else {
                newHP.Status__c = HP_S_INVITED;
                update newHP;
            }
        }

        return getInitData(peId, pe.Participant__c).healthcareProviders;
    }

    @AuraEnabled
    public static void invitePatientDelegate(String participant, String delegateContact, String delegateId) {
        Participant__c participantObj = (Participant__c) JSON.deserialize(participant, Participant__c.class);
        Contact delegateObj = (Contact) JSON.deserialize(delegateContact, Contact.class);
        if (delegateId == null) {
            Contact newContact = new Contact();
            newContact.FirstName = delegateObj.FirstName;
            newContact.LastName = delegateObj.LastName;
            newContact.Email = delegateObj.Email;
            newContact.AccountId = [
                    SELECT Id
                    FROM Account
                    WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                    LIMIT 1
                    FOR UPDATE
            ].Id;
            newContact.Language__c = UserInfo.getLanguage();
            newContact.Second_Choice_Language__c = '';
            newContact.Third_Choice_Language__c = '';
            newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
            newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            newContact.userCommunityIsDelegate__c = true;
            newContact.MailingCountryCode = participantObj.Mailing_Country_Code__c;
            newContact.MailingStateCode = participantObj.Mailing_State_Code__c;
            newContact.MailingCountry = participantObj.Mailing_Country__c;
            newContact.MailingState = participantObj.Mailing_State__c;
            if ('Home' == participantObj.Phone_Type__c) {
                newContact.HomePhone = participantObj.Phone__c;
            } if ('Mobile' == participantObj.Phone_Type__c) {
                newContact.MobilePhone = participantObj.Phone__c;
            } else {
                newContact.Phone = participantObj.Phone__c;
            }
            insert newContact;

            Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
            ptDelegateRef.Participant__c = participantObj.Id;
            ptDelegateRef.Contact__c = newContact.Id;
            insert ptDelegateRef;
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(new Map<Id, Id>{
                    newContact.Id => null
            });

        } else {
            update new Patient_Delegate__c(Id = delegateId, Status__c = DEL_ACTIVE);
        }
    }

    @AuraEnabled
    public static void stopSharing(String hpId, String delegateId) {
        if (hpId != null) {
            Healthcare_Provider__c newHP = [
                    SELECT Id,
                            Status__c
                    FROM Healthcare_Provider__c
                    WHERE Id = :hpId
            ];
            newHP.Status__c = HP_S_NOSHARING;
            update newHP;
        } else {
            update new Patient_Delegate__c(Id = delegateId, Status__c = DEL_ON_DISCONNECTED);
        }
    }

    @AuraEnabled
    public static void showOrHideProvider(String peId) {
        Participant_Enrollment__c participant = [
                SELECT Id,
                        Show_Referring_Provider__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
        ];
        if (participant.Show_Referring_Provider__c == true) {
            participant.Show_Referring_Provider__c = false;
        } else {
            participant.Show_Referring_Provider__c = true;
        }
        update participant;
    }

    private static List<Study_Site__c> getStudySitesForMatchedRP(Id hcpContactId, List<String> piIds) {
        try {
            if (String.isBlank(hcpContactId)) {
                return new List<Study_Site__c>();
            }

            Map<Id, HCP_Enrollment__c> hcpEnrollmentByStudySiteId = new Map<Id, HCP_Enrollment__c>();
            for (HCP_Enrollment__c hcpEnrollment : [
                    SELECT Id,
                            Study_Site__c
                    FROM HCP_Enrollment__c
                    WHERE HCP_Contact__c = :hcpContactId
            ]) {
                hcpEnrollmentByStudySiteId.put(hcpEnrollment.Study_Site__c, hcpEnrollment);
            }
            List<Study_Site__c> studySites = new List<Study_Site__c>();
            if (piIds != null && !piIds.isEmpty()) {
                String filter = ' Principal_Investigator__c IN (\'' + String.join(piIds, '\',\'') + '\')';
                studySites = StudySiteService.getStudySitesCommon(filter);
            } else {
                studySites = StudySiteService.getStudySitesForPI();
            }
            List<Study_Site__c> studySitesForInvitation = new List<Study_Site__c>();
            if (studySites != null && !studySites.isEmpty()) {
                Set<Id> studyIds = new Set<Id>();
                for (Study_Site__c site : studySites) {
                    if (!studyIds.contains(site.Id) && StudySiteService.STATUS_GROUP_ACCEPTED.contains(site.Override_PI_Referral_Status__c) &&
                            !hcpEnrollmentByStudySiteId.containsKey(site.Id)) {
                        studySitesForInvitation.add(site);
                        studyIds.add(site.Id);
                    }
                }
            }
            return studySitesForInvitation;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone, Contact piContact) {
        return createHCPinPlatform(studySiteId, firstName, lastName, email, phone, piContact, null, null, null);
    }

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone, Contact piContact, List<String> piIds) {
        return createHCPinPlatform(studySiteId, firstName, lastName, email, phone, piContact, null, null, piIds);
    }

    public static String createHCPinPlatform(Id piContactId, Id hcpContactId, List<String> piIds) {
        return createHCPinPlatform(null, null, null, null, null, new Contact(Id = piContactId), null, hcpContactId, piIds);
    }

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone, Contact piContact, Healthcare_Provider__c hp, Id hcpContactId, List<String> piIds) {
        Boolean isNewUser = false;
        List<HCP_Enrollment__c> hcpes = new List<HCP_Enrollment__c>();
        List<Study_Site__c> studySitesToInvite = new List<Study_Site__c>();

        List<Contact> cntList = new List<Contact>();
        if (!String.isBlank(hcpContactId)) {
            cntList = [
                    SELECT Id,
                            userCommunityMode__c,
                            userCommunytyType__c,
                            MailingCountry,
                            MailingCity,
                            MailingPostalCode,
                            MailingState,
                            MailingStreet,
                            AccountId
                    FROM Contact
                    WHERE Id = :hcpContactId
            ];
        } else {
            cntList = [
                    SELECT Id,
                            userCommunityMode__c,
                            userCommunytyType__c,
                            MailingCountry,
                            MailingCity,
                            MailingPostalCode,
                            MailingState,
                            MailingStreet,
                            AccountId
                    FROM Contact
                    WHERE Email = :email OR
                    Email = :email.toLowerCase()
                    LIMIT 1
            ];
        }

        if (cntList.isEmpty()) {
            Account newAcc = new Account(Name = lastName + ' temporary account', OwnerId = CommunityService.getUserContact().Account.OwnerId);
            insert newAcc;
            cntList.add(new Contact(FirstName = firstName,
                    LastName = lastName,
                    Phone = phone,
                    Email = email,
                    AccountId = newAcc.Id,
                    Language__c = UserInfo.getLanguage(),
                    HCP_Opt_In_Referral_Status_Emails__c = true,
                    RP_Invited_By_PI__c = true,
                    userCommunityMode__c = CommunityService.USER_MODE_HCP,
                    userCommunytyType__c = CommunityService.USER_MODE_HCP,
                    //MailingCountry = studySite.Site__r.BillingCountry));
                    MailingCountry = piContact.MailingCountry,
                    MailingState = piContact.MailingState));
            insert cntList;
        } else {
            cntList[0].RP_Invited_By_PI__c = true;
        }
        if (String.isBlank(studySiteId)) {
            studySitesToInvite = getStudySitesForMatchedRP(cntList[0].Id, piIds);
        } else {
            studySitesToInvite.add(new Study_Site__c(Id = studySiteId));
        }
        List<User> usrs = CommunityService.getCommunityUsersByContactIds(new Set<Id>{
                cntList[0].Id
        });
        if (usrs.isEmpty()) {
            isNewUser = true;
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{
                    cntList[0].Id
            });
        }
        if (cntList[0].userCommunytyType__c == null) {
            cntList[0].userCommunytyType__c = CommunityService.USER_MODE_HCP;
        } else if (!cntList[0].userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) {
            cntList[0].userCommunytyType__c = cntList[0].userCommunytyType__c + ';' + CommunityService.USER_MODE_HCP;
        }
        if (cntList[0].userCommunityMode__c != CommunityService.USER_MODE_HCP) {
            cntList[0].userCommunityMode__c = CommunityService.USER_MODE_HCP;
        }
        update cntList[0];
        for (Study_Site__c stdSite : studySitesToInvite) {
            hcpes.add(new HCP_Enrollment__c(
                    HCP_Contact__c = cntList[0].Id,
                    HCP_Account__c = cntList[0].AccountId,
                    Status__c = stdSite.Clinical_Trial_Profile__r.Orientation_Required__c ? HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O : HCPEnrollmentService.HCP_S_ACTIVATED,
                    Study_Site__c = (String.isBlank(stdSite.Id) ? null : stdSite.Id)
            ));
        }
        if (hp != null) {
            if (!isNewUser) {
                hcpes[0].Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
                insert hcpes[0];
                hcpes[0].Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
                update hcpes[0];
            } else {
                hcpes[0].Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION;
                insert hcpes;
            }
            hp.HCP_Enrollment__c = hcpes[0].Id;
            update hp;
        } else {
            if (!piIds.isEmpty()) {
                List<PI_RP_Relationship__c> piRPList = new List<PI_RP_Relationship__c>();
                for (String piId : piIds) {
                    piRPList.add(new PI_RP_Relationship__c(PI_Contact__c = piId, RP_Contact__c = cntList[0].Id));
                }
                insert piRPList;
            } else {
                insert new PI_RP_Relationship__c(PI_Contact__c = studySitesToInvite[0].Principal_Investigator__c, RP_Contact__c = cntList[0].Id);
            }
            if (!isNewUser) {
                if (!hcpes.isEmpty()) {
                    insert hcpes;
                    sendNotificationForRPInvite(hcpes[0].Id, cntList[0].Id, piIds);
                } else {
                    throw new AuraHandledException(Label.RP_Is_Already_Invited);
                }
            } else {
                if (!hcpes.isEmpty()) {
                    insert hcpes;
                }
            }
        }
        return hcpes[0].Id;
    }

    public static void sendNotificationForRPInvite(Id hcpEnrollId, Id hcpContactId, List<String> piIds) {
        insert new Notification__c(
                Recipient__c = hcpContactId,
                WhatId__c = hcpEnrollId,
                Notification_Type__c = piIds.isEmpty() ? NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TYPE : NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TO_MULTIPI_TYPE
        );
    }

    public final static String HP_S_INVITED = 'Invited';
    public final static String HP_S_REGISTRED = 'Registered';
    public final static String HP_S_NOSHARING = 'No Sharing';
    public final static String HP_S_DUPLICATE = 'Duplicate';
    public final static String DEL_ON_DISCONNECTED = 'Disconnected';
    public final static String DEL_ACTIVE = 'Active';

    public class HealthcareProvider {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public Boolean isDuplicate { get; set; }
        @AuraEnabled public Boolean isDuplicateDelegate { get; set; }
        @AuraEnabled public String hcpContactId { get; set; }
    }

}
