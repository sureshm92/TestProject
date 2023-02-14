/**
 * Created by Alexey Moseev on 2019-09-23.
 */

global without sharing class ReferHealthcareProviderRemote {
    public class InitData {
        @AuraEnabled
        public List<Healthcare_Provider__c> healthcareProviders;
        @AuraEnabled
        public List<ReferHealthcareProviderRemote.PDWrapper> listWrapp;
        @AuraEnabled
        public List<LabelValueItem> yearOfBirth;

        public initData(
            List<Healthcare_Provider__c> healthcareProviders,
            List<ReferHealthcareProviderRemote.PDWrapper> wrap,
            List<LabelValueItem> yearOfBirth
        ) {
            this.healthcareProviders = healthcareProviders;
            this.listWrapp = wrap;
            this.yearOfBirth = yearOfBirth;
        }
    }

    @AuraEnabled
    public static InitData getInitData(String peId, String participantId) {
        List<Healthcare_Provider__c> healthcareProviders = [
            SELECT
                Id,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Participant_Enrollment__c,
                HCP_Enrollment__c
            FROM Healthcare_Provider__c
            WHERE Participant_Enrollment__c = :peId
        ];
        /*if (healthcareProviders.isEmpty())
         healthcareProviders.add(new Healthcare_Provider__c()); */

        /*List<Contact> listContDelegates = PatientDelegateService.getPatientDelegates(participantId);
         if (listContDelegates.isEmpty()) listContDelegates.add(new Contact());*/

        List<ReferHealthcareProviderRemote.PDWrapper> wrap = getWrapPD(participantId,peId);
        List<LabelValueItem> yearOfBirth = ParticipantService.getYearofBirthList();
        /* if (wrap.isEmpty())
         wrap.add(new PDWrapper()); */

        return new InitData(healthcareProviders, wrap, yearOfBirth);
    }

    @AuraEnabled
    public static List<ReferHealthcareProviderRemote.PDWrapper> getWrapPD(String participantId, String peId) {
        Map<Id, Patient_Delegate_Enrollment__c> mapDelEnroll = new Map<Id, Patient_Delegate_Enrollment__c>();
        Map<Id, Patient_Delegate__c> mapDel = new Map<Id, Patient_Delegate__c>();
        List<ReferHealthcareProviderRemote.PDWrapper> wrapPD = new List<ReferHealthcareProviderRemote.PDWrapper>();

        for (Patient_Delegate_Enrollment__c pdelEnoll : [
            SELECT Id, Patient_Delegate__c, Status__c, Participant_Enrollment__c,
            Patient_Delegate__r.Contact__c
            FROM Patient_Delegate_Enrollment__c
            WHERE
            Participant_Enrollment__c = :peId
                AND (Status__c = 'Active'
                OR Status__c = 'Disconnected')
        ]) {
            mapDelEnroll.put(pdelEnoll.Patient_Delegate__r.Contact__c, pdelEnoll);
        }

        for (Participant__c par : [
            SELECT Id, Contact__c, First_Name__c, Last_Name__c, Email__c, Site__c
            FROM Participant__c
            WHERE Contact__c IN :mapDelEnroll.keySet()
        ]) {
            if (mapDelEnroll.keySet().contains(par.Contact__c)) {
                wrapPD.add(
                    new PDWrapper(
                        mapDelEnroll.get(par.Contact__c).Id,
                        par.First_Name__c,
                        par.Last_Name__c,
                        par.Email__c,
                        mapDelEnroll.get(par.Contact__c).Status__c
                    )
                );
                mapDelEnroll.remove(par.Contact__c);
            }
        }
        return wrapPD;
    }

    @AuraEnabled
    public static String checkDelegateAge(String participantJSON, String delegateParticipantJSON) {
        return ReferringRemote.checkDelegateAge(participantJSON, delegateParticipantJSON);
    }

    @AuraEnabled
    public static Participant__c getDelegateParticipant(String delegateContactId) {
        List<Participant__c> participantDelegate = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Site__c
            FROM Participant__c
            WHERE Contact__c = :delegateContactId
        ];
        if (participantDelegate.isEmpty())
            participantDelegate.add(new Participant__c());
        return participantDelegate[0];
    }

    @AuraEnabled
    public static HealthcareProvider checkDuplicate(
        String peId,
        String email,
        String firstName,
        String lastName,
        String participantId
    ) {
        HealthcareProvider hp = new HealthcareProvider();
        if (!String.isBlank(email)) {
            String contactQuery = 'SELECT Id, FirstName, LastName, Name, Email, Phone, HomePhone, MobilePhone, AccountId, userCommunytyType__c FROM Contact WHERE userCommunityMode__c != \'CC\'';
            if (!String.isBlank(firstName) && !String.isBlank(lastName)) {
                email = String.escapeSingleQuotes(email);
                firstName = String.escapeSingleQuotes(firstName);
                lastName = String.escapeSingleQuotes(lastName);
                contactQuery +=
                    ' AND ((Email = \'' +
                    email +
                    '\' OR Email = \'' +
                    email.toLowerCase() +
                    '\')' +
                    +' AND (FirstName = \'' +
                    firstName +
                    '\' OR FirstName = \'' +
                    firstName.toLowerCase() +
                    '\')' +
                    +' AND (LastName = \'' +
                    lastName +
                    '\' OR LastName = \'' +
                    lastName.toLowerCase() +
                    '\'))';
            } else if (String.isBlank(firstName) && String.isBlank(lastName)) {
                contactQuery +=
                    ' AND (Email = \'' +
                    String.escapeSingleQuotes(email) +
                    '\'' +
                    ' OR Email = \'' +
                    String.escapeSingleQuotes(email.toLowerCase()) +
                    '\')';
            }
            List<Participant__c> delegateParticipants = new List<Participant__c>();
            List<Contact> contacts = Database.query(contactQuery);
            if (contacts.isEmpty() && !String.isBlank(firstName) && !String.isBlank(lastName)) {
                delegateParticipants = [
                    SELECT Id, First_Name__c, Last_Name__c, Phone__c, Phone_Type__c, Contact__c,Birth_Year__c
                    FROM Participant__c
                    WHERE
                        (First_Name__c = :firstName
                        OR First_Name__c = :firstName.toLowerCase())
                        AND (Last_Name__c = :lastName
                        OR Last_Name__c = :lastName.toLowerCase())
                        AND (Email__c = :email
                        OR Email__c = :email.toLowerCase())
                ];
                if (!delegateParticipants.isEmpty()) {
                    contacts = [
                        SELECT Id, FirstName, LastName, Name, Email, Phone,HomePhone, MobilePhone,AccountId, userCommunytyType__c
                        FROM Contact
                        WHERE
                            userCommunityMode__c != 'CC'
                            AND Id = :delegateParticipants[0].Contact__c
                    ];
                }
            }
            if (!contacts.isEmpty()) {
                hp.contactId = contacts[0].Id;
                hp.contactPhoneNumber = contacts[0].Phone;
                hp.firstName = contacts[0].FirstName;
                hp.lastName = contacts[0].LastName;
                firstName = contacts[0].FirstName;
                lastName = contacts[0].LastName; 
                //Added for ePR batch fix
                if(Batch_UpsertEprParticipantAndPE.eprBatchRunning==true){
                    hp.conObject = contacts[0]; 
                } 
                // if (String.isBlank(contacts[0].FirstName) || String.isBlank(contacts[0].LastName)) {
                List<Participant__c> participants;
                if (delegateParticipants.isEmpty()) {
                    participants = [
                        SELECT Id, First_Name__c, Last_Name__c, Phone__c, Phone_Type__c,Birth_Year__c
                        FROM Participant__c
                        WHERE Contact__c = :contacts[0].Id
                    ];
                } else
                    participants = delegateParticipants;
                if (!participants.isEmpty()) {
                    hp.participantId = participants[0].Id;
                    hp.DelegateYOB =  participants[0].Birth_Year__c;
                    hp.contactPhoneNumber = participants[0].Phone__c;
                    hp.contactPhoneType = participants[0].Phone_Type__c;
                    hp.firstName = participants[0].First_Name__c;
                    hp.lastName = participants[0].Last_Name__c;
                    firstName = participants[0].First_Name__c;
                    lastName = participants[0].Last_Name__c;
                    update contacts[0];
                } else {
                    hp.participantId = null;
                }
                /* } else {
                     hp.firstName = contacts[0].FirstName;
                     hp.lastName = contacts[0].LastName;
                 }*/
                hp.email = contacts[0].Email;
                hp.hcpContactId = contacts[0].Id;
                if (peId != null) {
                    List<Healthcare_Provider__c> isDuplicate = [
                        SELECT Id
                        FROM Healthcare_Provider__c
                        WHERE Participant_Enrollment__c = :peId AND Email__c = :email
                    ];
                    if (!isDuplicate.isEmpty()) {
                        hp.healthcareProviderId = isDuplicate[0].Id;
                        hp.isDuplicate = true;
                    } else {
                        hp.healthcareProviderId = null;
                        hp.isDuplicate = false;
                    }
                }
                if (participantId == null && peId != null) {
                    participantId = [
                        SELECT Participant__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :peId
                        LIMIT 1
                    ]
                    .Participant__c;
                }
                if (participantId != null) {
                    List<Patient_Delegate__c> duplicateDelegates = checkDuplicatePDelegates(
                        participantId,
                        String.escapeSingleQuotes(email),
                        String.escapeSingleQuotes(firstName),
                        String.escapeSingleQuotes(lastName)
                    );
                    if (!duplicateDelegates.isEmpty()) {
                        hp.isDuplicateDelegate = true;
                    } else {
                        hp.isDuplicateDelegate = false;
                    }
                }
            } else {
                hp.contactId = null;
                hp.isDuplicateDelegate = false;
                //hp.isDuplicate = contacts[0].get('userCommunytyType__c') != null && contacts[0].userCommunytyType__c.contains('HCP');
            }
        }
        return hp;
    }
    @AuraEnabled
    public static HealthcareProvider checkDuplicateNew(
        String peId,
        String email,
        String firstName,
        String lastName,
        String participantId
    ) {
        HealthcareProvider hp = new HealthcareProvider();
        if (!String.isBlank(email)) {
            String contactQuery = 'SELECT Id, FirstName, LastName, Name, Email, Phone, HomePhone, MobilePhone, AccountId, userCommunytyType__c FROM Contact WHERE userCommunityMode__c != \'CC\'';
            if (!String.isBlank(firstName) && !String.isBlank(lastName)) {
                email = String.escapeSingleQuotes(email);
                firstName = String.escapeSingleQuotes(firstName);
                lastName = String.escapeSingleQuotes(lastName);
                contactQuery +=
                    ' AND ((Email = \'' +
                    email +
                    '\' OR Email = \'' +
                    email.toLowerCase() +
                    '\')' +
                    +' AND (FirstName = \'' +
                    firstName +
                    '\' OR FirstName = \'' +
                    firstName.toLowerCase() +
                    '\')' +
                    +' AND (LastName = \'' +
                    lastName +
                    '\' OR LastName = \'' +
                    lastName.toLowerCase() +
                    '\'))';
            } else if (String.isBlank(firstName) && String.isBlank(lastName)) {
                contactQuery +=
                    ' AND (Email = \'' +
                    String.escapeSingleQuotes(email) +
                    '\'' +
                    ' OR Email = \'' +
                    String.escapeSingleQuotes(email.toLowerCase()) +
                    '\')';
            }
            List<Participant__c> delegateParticipants = new List<Participant__c>();
            List<Contact> contacts = Database.query(contactQuery);
            if (contacts.isEmpty() && !String.isBlank(firstName) && !String.isBlank(lastName)) {
                delegateParticipants = [
                    SELECT Id, First_Name__c, Last_Name__c, Phone__c, Phone_Type__c, Contact__c,Birth_Year__c
                    FROM Participant__c
                    WHERE
                        (First_Name__c = :firstName
                        OR First_Name__c = :firstName.toLowerCase())
                        AND (Last_Name__c = :lastName
                        OR Last_Name__c = :lastName.toLowerCase())
                        AND (Email__c = :email
                        OR Email__c = :email.toLowerCase())
                ];
                if (!delegateParticipants.isEmpty()) {
                    contacts = [
                        SELECT Id, FirstName, LastName, Name, Email, Phone,HomePhone, MobilePhone,AccountId, userCommunytyType__c
                        FROM Contact
                        WHERE
                            userCommunityMode__c != 'CC'
                            AND Id = :delegateParticipants[0].Contact__c
                    ];
                }
            }
            if (!contacts.isEmpty()) {
                hp.contactId = contacts[0].Id;
                hp.contactPhoneNumber = contacts[0].Phone;
                hp.firstName = contacts[0].FirstName;
                hp.lastName = contacts[0].LastName;
                firstName = contacts[0].FirstName;
                lastName = contacts[0].LastName; 
                //Added for ePR batch fix
                if(Batch_UpsertEprParticipantAndPE.eprBatchRunning==true){
                    hp.conObject = contacts[0]; 
                } 
                // if (String.isBlank(contacts[0].FirstName) || String.isBlank(contacts[0].LastName)) {
                List<Participant__c> participants;
                if (delegateParticipants.isEmpty()) {
                    participants = [
                        SELECT Id, First_Name__c, Last_Name__c, Phone__c, Phone_Type__c,Birth_Year__c
                        FROM Participant__c
                        WHERE Contact__c = :contacts[0].Id
                    ];
                } else
                    participants = delegateParticipants;
                if (!participants.isEmpty()) {
                    hp.participantId = participants[0].Id;
                    hp.DelegateYOB =  participants[0].Birth_Year__c;
                    hp.contactPhoneNumber = participants[0].Phone__c;
                    hp.contactPhoneType = participants[0].Phone_Type__c;
                    hp.firstName = participants[0].First_Name__c;
                    hp.lastName = participants[0].Last_Name__c;
                    firstName = participants[0].First_Name__c;
                    lastName = participants[0].Last_Name__c;
                    update contacts[0];
                } else {
                    hp.participantId = null;
                }
                /* } else {
                     hp.firstName = contacts[0].FirstName;
                     hp.lastName = contacts[0].LastName;
                 }*/
                hp.email = contacts[0].Email;
                hp.hcpContactId = contacts[0].Id;
                if (peId != null) {
                    List<Healthcare_Provider__c> isDuplicate = [
                        SELECT Id
                        FROM Healthcare_Provider__c
                        WHERE Participant_Enrollment__c = :peId AND Email__c = :email
                    ];
                    if (!isDuplicate.isEmpty()) {
                        hp.healthcareProviderId = isDuplicate[0].Id;
                        hp.isDuplicate = true;
                    } else {
                        hp.healthcareProviderId = null;
                        hp.isDuplicate = false;
                    }
                }
                if (participantId == null && peId != null) {
                    participantId = [
                        SELECT Participant__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :peId
                        LIMIT 1
                    ]
                    .Participant__c;
                }
                if (participantId != null) {
                    List<Patient_Delegate_Enrollment__c> duplicateDelegates = checkDuplicatePDERDelegates(
                        participantId,
                        String.escapeSingleQuotes(email),
                        String.escapeSingleQuotes(firstName),
                        String.escapeSingleQuotes(lastName),
                        peId
                    );
                    if (!duplicateDelegates.isEmpty()) {
                        hp.isDuplicateDelegate = true;
                    } else {
                        hp.isDuplicateDelegate = false;
                    }
                }
            } else {
                hp.contactId = null;
                hp.isDuplicateDelegate = false;
                //hp.isDuplicate = contacts[0].get('userCommunytyType__c') != null && contacts[0].userCommunytyType__c.contains('HCP');
            }
        }
        return hp;
    }


    @AuraEnabled
    public static List<Healthcare_Provider__c> inviteHP(String peId, String hp) {
        try {
            Healthcare_Provider__c newHP = (Healthcare_Provider__c) JSON.deserialize(
                hp,
                Healthcare_Provider__c.class
            );

            Participant_Enrollment__c pe = [
                SELECT Id, Study_Site__c, Participant__c
                FROM Participant_Enrollment__c
                WHERE Id = :peId
            ];
            List<HCP_Enrollment__c> hcpe = new List<HCP_Enrollment__c>();

            if (!String.isBlank(peId) && newHP != null && String.isBlank(newHP.Id)) {
                newHP.Participant_Enrollment__c = peId;
                newHP.Status__c = HP_S_INVITED;
                insert newHP;
                try {
                    createHCPinPlatform(
                        pe.Study_Site__c,
                        newHP.First_Name__c,
                        newHP.Last_Name__c,
                        newHP.Email__c,
                        null,
                        CommunityService.getUserContact(),
                        newHP,
                        null,
                        null
                    );
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
                }
            } else if (!String.isBlank(newHP.Id) && newHP.Status__c == HP_S_NOSHARING) {
                hcpe = [
                    SELECT Id, HCP_Contact__c, Status__c
                    FROM HCP_Enrollment__c
                    WHERE Id = :newHP.HCP_Enrollment__c
                ];

                if (hcpe.isEmpty()) {
                    List<Contact> contacts = [
                        SELECT Id, Email, AccountId
                        FROM Contact
                        WHERE Email = :newHP.Email__c OR Email = :newHP.Email__c.toLowerCase()
                    ];

                    hcpe.add(
                        new HCP_Enrollment__c(
                            HCP_Contact__c = contacts[0].Id,
                            HCP_Account__c = contacts[0].AccountId,
                            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
                        )
                    );
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
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void invitePatientDelegate(
        String participant,
        String delegateContact,
        String delegateId,
        String ddInfo,
        Boolean createUser,
        String YearOfBirth,
        Id perID
    ) {
        try {
            HealthcareProvider delegateDuplicate;
            if (ddInfo != null)
                delegateDuplicate = (HealthcareProvider) JSON.deserialize(
                    ddInfo,
                    HealthcareProvider.class
                );
            Participant__c participantObj = (Participant__c) JSON.deserialize(
                participant,
                Participant__c.class
            );
            PDWrapper delegateObj = (PDWrapper) JSON.deserialize(delegateContact, PDWrapper.class);
            List<Patient_Delegate__c> lstPatientDelegate = new List<Patient_Delegate__c>();
            List<Patient_Delegate__c> lstPatientDelegateWithdrwan = new List<Patient_Delegate__c>();
            List<Patient_Delegate_Enrollment__c> lstPatientDelegateEnroll = new List<Patient_Delegate_Enrollment__c>();
            if (
                delegateDuplicate != null &&
                delegateDuplicate.contactId != null &&
                delegateDuplicate.participantId != null
            ) {
                lstPatientDelegate = [
                    SELECT ID, Status__c
                    FROM Patient_Delegate__c
                    WHERE
                        Participant__c = :participantObj.id
                        AND Contact__c = :delegateDuplicate.contactId
                        
                ];
               
            }
            system.debug('>>>lstPatientDelegate>>' + lstPatientDelegate);
            Boolean boolisUserCreated;
            Id ContactId;
			Id delegateContactId;
            Patient_Delegate__c delContact; 
            Patient_Delegate_Enrollment__c delEnrollContact;
			List<User> existingUserPatientDelegate = new List<User>();
			Id delegateUser;
            Id participantShareIds;
            List<User> particpantUser = new List<User>();
            set<Id> participantAndDelIds = new set<Id>();
            if (delegateId != null) {
                delEnrollContact = [SELECT ID, Patient_Delegate__r.Contact__c,Is_Created_by_Bulk_Import__c,Patient_Delegate__c
                                    FROM Patient_Delegate_Enrollment__c 
                                    WHERE id=:delegateId]; // Changed query to fetch Is_Created_by_Bulk_Import__c field
                ContactId =delEnrollContact == null ? null : delEnrollContact.Patient_Delegate__r.Contact__c; 
                List<User> lstUser = [SELECT ID, Email FROM User WHERE ContactId = :ContactId];
                boolisUserCreated = lstUser.isEmpty() ? false : true;
            }
			//Contact newContact;
            if (delegateId == null) {
                String countryCode = participantObj.Mailing_Country_Code__c;
                String stateCode = participantObj.Mailing_State_Code__c;
                String countryName;
                String stateName;

                if (CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCode)) {
                    countryName = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCode);
                }

                if (
                    CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.containsKey(countryCode) &&
                    CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(countryCode)
                        .containsKey(stateCode)
                ) {
                    stateName = CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(countryCode)
                        .get(stateCode);
                }

                Contact newContact;
                if (delegateDuplicate == null || delegateDuplicate.contactId == null) {
                    newContact = new Contact();
                    newContact.FirstName = delegateObj.firstName;
                    newContact.LastName = delegateObj.lastName;
                    newContact.Email = delegateObj.email;
                    /* newContact.AccountId = [
                            SELECT Id
                            FROM Account
                            WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
                            LIMIT 1
                            FOR UPDATE
                    ].Id;*/
                    //newContact.AccountId = participantObj.Site__c;
                    newContact.AccountId = [
                        SELECT AccountId
                        FROM Contact
                        WHERE Id = :participantObj.Contact__c
                        LIMIT 1
                        FOR UPDATE
                    ]
                    .AccountId;
                    newContact.Language__c = UserInfo.getLanguage();
                    newContact.Second_Choice_Language__c = '';
                    newContact.Third_Choice_Language__c = '';
                    newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityIsDelegate__c = true;
                    newContact.MailingCountryCode = participantObj.Mailing_Country_Code__c;
                    newContact.MailingStateCode = participantObj.Mailing_State_Code__c;
                    newContact.MailingCountry = countryName;
                    newContact.MailingState = stateName;
                    newContact.MailingPostalCode = participantObj.Mailing_Zip_Postal_Code__c;
                    if ('Home' == participantObj.Phone_Type__c) {
                        newContact.HomePhone = participantObj.Phone__c;
                    }
                    if ('Mobile' == participantObj.Phone_Type__c) {
                        newContact.MobilePhone = participantObj.Phone__c;
                    } else {
                        newContact.Phone = participantObj.Phone__c;
                    }
                    insert newContact;
                } else {
                    newContact = [
                        SELECT Id, FirstName, LastName, Email, MailingCity,
                        IQVIA_Contact_info_storage_consent__c,
                        Participant_Opt_In_Status_Emails__c,
                        IQVIA_PI_Storage_Consent_Time__c,
                        IQVIA_Email_Consent_Time__c
                        FROM Contact
                        WHERE Id = :delegateDuplicate.contactId
                    ];
					if(delegateDuplicate.contactId != null){
                        existingUserPatientDelegate = [SELECT ID, Email FROM User WHERE ContactId = :delegateDuplicate.contactId];
                    }
                    //createUser = false;
                }

                Participant__c participantDelegate;
                if (delegateDuplicate == null || delegateDuplicate.participantId == null) {
                    participantDelegate = new Participant__c(
                        Adult__c = true,
                        Contact__c = newContact.Id,
                        First_Name__c = newContact.FirstName,
                        Last_Name__c = newContact.LastName,
                        Email__c = newContact.Email,
                        Phone__c = participantObj.Phone__c,
                        Mailing_City__c = newContact.MailingCity,
                        Mailing_Country_Code__c = participantObj.Mailing_Country_Code__c,
                        Mailing_State_Code__c = participantObj.Mailing_State_Code__c,
                        Mailing_Zip_Postal_Code__c = participantObj.Mailing_Zip_Postal_Code__c,
                        Birth_Year__c = String.isNotBlank(YearOfBirth) ? YearOfBirth : ''
                    );
                    if (String.isNotBlank(YearOfBirth)) {
                        participantDelegate.Attestation__c = true;
                        participantDelegate.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
                        participantDelegate.Attested_by__c = CommunityService.getInstance()
                            .getCurrentContactId();
                    }
                    insert participantDelegate;
                }
                if (!participantObj.Adult__c) {
                    update new Participant__c(
                        Id = participantObj.Id,
                        Phone_Type__c = null,
                        Phone__c = null
                    );
                }

                Patient_Delegate__c ptDelegateRef = new Patient_Delegate__c();
                Patient_Delegate_Enrollment__c ptDelegateEnroll = new Patient_Delegate_Enrollment__c();
                if (lstPatientDelegate.isEmpty()) {
                    ptDelegateRef.Participant__c = participantObj.Id;
                    ptDelegateRef.Contact__c = newContact.Id;
                } else {
                    ptDelegateRef.ID = lstPatientDelegate[0].ID;
                    ptDelegateRef.Status__c = DEL_ACTIVE;  
                }
                if(createUser) { //RH-5163
                	ptDelegateRef.isInviteToPP__c = true;
                    ptDelegateEnroll.isInviteToPP__c = true;
                }
                upsert ptDelegateRef;
				delegateContactId = newContact.Id;

                if (
                delegateDuplicate != null &&
                delegateDuplicate.contactId != null &&
                delegateDuplicate.participantId != null
            ){
                lstPatientDelegateEnroll = [
                    SELECT ID, Status__c,Patient_Delegate__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE
                        Patient_Delegate__r.Participant__c = :participantObj.id
                        AND Participant_Enrollment__c = :perID
                        AND Patient_Delegate__r.Contact__c = :delegateDuplicate.contactId
                        AND Patient_Delegate__c = :ptDelegateRef.id
                ];
            }

                if (!lstPatientDelegateEnroll.isEmpty()) {
                    if(lstPatientDelegateEnroll[0].Status__c == 'Withdrawn'){	
                        ptDelegateEnroll.ID = lstPatientDelegateEnroll[0].ID;	
                        ptDelegateEnroll.Status__c = DEL_ACTIVE;	
                        ptDelegateEnroll.Study_Email_Consent__c = true;	
                        ptDelegateEnroll.Study_Email_Consent_Time__c = Datetime.now();	
                   }else{	
                        ptDelegateEnroll.ID = lstPatientDelegateEnroll[0].ID;
                        ptDelegateEnroll.Status__c ='Active';	
                   }
                   update ptDelegateEnroll;
                }
                else{
                    ptDelegateEnroll.Patient_Delegate__c=ptDelegateRef.ID;
                    ptDelegateEnroll.Status__c = DEL_ACTIVE;
                    ptDelegateEnroll.Participant_Enrollment__c=perID;
                    ptDelegateEnroll.Study_info_storage_consent__c= true;
                    ptDelegateEnroll.Study_Email_Consent__c = true;
                
                insert ptDelegateEnroll;
                }
                
                if(createUser && delegateDuplicate == null) {
                    //system.debug('INSIDEFIRST');
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsers(new Map<Id, Id>{ newContact.Id => null });
                }else if(createUser && existingUserPatientDelegate.isEmpty()) {
                    //system.debug('INSIDEFIFTH');
                     ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsers(new Map<Id, Id>{ newContact.Id => null });
                  }
            } else {
                if (!boolisUserCreated) {
                    if (ContactId != null && createUser) {
                        ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                            .createParticipantUsers(new Map<Id, Id>{ ContactId => null });
                        //User of the patient delegate created when we click on connect to Patient for bulk import
                        //so creating survey task for the delegate when user gets created
                            if(delEnrollContact.Is_Created_by_Bulk_Import__c){
                                createSurveyTaskforpatientDelegate(participantObj.id);
                            }
                    }
                }
                if (!createUser) {
                    TriggerHandlerExecutor.bypassHandler(
                        PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                    );
                }
                Patient_Delegate_Enrollment__c getPtDelegateEnroll = [Select id, Patient_Delegate__c, Status__c,isInviteToPP__c
                            from  Patient_Delegate_Enrollment__c where id=:delegateId];
                getPtDelegateEnroll.Status__c = DEL_ACTIVE;

                if(createUser) { //RH-5163
                	update new Patient_Delegate__c(Id = getPtDelegateEnroll.Patient_Delegate__c, Status__c = DEL_ACTIVE, isInviteToPP__c=true);
                    getPtDelegateEnroll.isInviteToPP__c = true;
                } else {
                    update new Patient_Delegate__c(Id = getPtDelegateEnroll.Patient_Delegate__c, Status__c = DEL_ACTIVE);
                }
                update getPtDelegateEnroll;
            }
			if(participantObj != null && participantObj.Contact__c != null && (delegateContactId != null || ContactId != null)){
                participantAndDelIds.add(participantObj.Contact__c);
                if(delegateContactId != null){
                participantAndDelIds.add(delegateContactId);
                }else{
                    participantAndDelIds.add(ContactId);
                }
               }
            if(participantAndDelIds != null){
                particpantUser = [SELECT ID, Email, ContactId FROM User WHERE ContactId IN :participantAndDelIds];
            }
            List<Conversation__c> patientConversation = new List<Conversation__c>();
			
            for(User usr: particpantUser){
                if(participantObj != null && participantObj.Contact__c != null && usr.ContactId == participantObj.Contact__c){
                    participantShareIds = usr.Id;
                }else{
                    delegateUser = usr.Id;  
                }
            }
			if(participantShareIds != null){
			patientConversation = ConversationService.getSharedConversations(
                        participantShareIds
                    );
			}
            if (patientConversation != null && delegateUser != null) {
                List<Id> conversationIds = new List<Id>();
                for (Conversation__c conversation : patientConversation)
                    conversationIds.add(conversation.Id);
                
                insert ConversationService.createConversationSharesForUser(
                    conversationIds,
                    delegateUser
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void stopSharing(String hpId, String delegateId) {
        if (hpId != null) {
            Healthcare_Provider__c newHP = [
                SELECT Id, Status__c
                FROM Healthcare_Provider__c
                WHERE Id = :hpId
            ];
            newHP.Status__c = HP_S_NOSHARING;
            update newHP;
        } else {
            Patient_Delegate_Enrollment__c pder = 
                    [Select Id ,Status__c, Patient_Delegate__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE id=:delegateId ];
                    pder.Status__c = DEL_ON_DISCONNECTED;
                    update pder;
            update new Patient_Delegate__c(Id = pder.Patient_Delegate__c, Status__c = DEL_ON_DISCONNECTED);
        }
    }

    @AuraEnabled
    public static void showOrHideProvider(String peId) {
        Participant_Enrollment__c participant = [
            SELECT Id, Show_Referring_Provider__c
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

    private static List<Study_Site__c> getStudySitesForMatchedRP(
        Id hcpContactId,
        List<String> piIds
    ) {
        try {
            if (String.isBlank(hcpContactId)) {
                return new List<Study_Site__c>();
            }

            Map<Id, HCP_Enrollment__c> hcpEnrollmentByStudySiteId = new Map<Id, HCP_Enrollment__c>();
            for (HCP_Enrollment__c hcpEnrollment : [
                SELECT Id, Study_Site__c
                FROM HCP_Enrollment__c
                WHERE HCP_Contact__c = :hcpContactId
            ]) {
                hcpEnrollmentByStudySiteId.put(hcpEnrollment.Study_Site__c, hcpEnrollment);
            }
            List<Study_Site__c> studySites = new List<Study_Site__c>();
            if (piIds != null && !piIds.isEmpty()) {
                piIds.add(CommunityService.getUserContact().Id);
                String filter =
                    ' Principal_Investigator__c IN (\'' +
                    String.join(piIds, '\',\'') +
                    '\' )';
                studySites = StudySiteService.getStudySitesCommon(filter);
            } else {
                studySites = StudySiteService.getStudySitesForPI();
            }
            List<Study_Site__c> studySitesForInvitation = new List<Study_Site__c>();
            if (studySites != null && !studySites.isEmpty()) {
                Set<Id> studyIds = new Set<Id>();
                for (Study_Site__c site : studySites) {
                    if (
                        !studyIds.contains(site.Id) &&
                        StudySiteService.STATUS_GROUP_ACCEPTED.contains(
                            site.Override_PI_Referral_Status__c
                        ) &&
                        !hcpEnrollmentByStudySiteId.containsKey(site.Id) &&
                        site.Clinical_Trial_Profile__r.CommunityTemplate__c !=
                        CommunityTemplateService.TEMPLATE_JANSSEN
                    ) {
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

    public static String createHCPinPlatform(
        String studySiteId,
        String firstName,
        String lastName,
        String email,
        String phone,
        Contact piContact
    ) {
        return createHCPinPlatform(
            studySiteId,
            firstName,
            lastName,
            email,
            phone,
            piContact,
            null,
            null,
            null
        );
    }

    public static String createHCPinPlatform(
        String studySiteId,
        String firstName,
        String lastName,
        String email,
        String phone,
        Contact piContact,
        List<String> piIds
    ) {
        return createHCPinPlatform(
            studySiteId,
            firstName,
            lastName,
            email,
            phone,
            piContact,
            null,
            null,
            piIds
        );
    }

    public static String createHCPinPlatform(Id piContactId, Id hcpContactId, List<String> piIds) {
        return createHCPinPlatform(
            null,
            null,
            null,
            null,
            null,
            new Contact(Id = piContactId),
            null,
            hcpContactId,
            piIds
        );
    }

    public static String createHCPinPlatform(
        String studySiteId,
        String firstName,
        String lastName,
        String email,
        String phone,
        Contact piContact,
        Healthcare_Provider__c hp,
        Id hcpContactId,
        List<String> piIds
    ) {
        Boolean isNewUser = false;
        List<HCP_Enrollment__c> hcpes = new List<HCP_Enrollment__c>();
        List<Study_Site__c> studySitesToInvite = new List<Study_Site__c>();
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();

        List<Contact> cntList = new List<Contact>();
        if (!String.isBlank(hcpContactId)) {
            cntList = [
                SELECT
                    Id,
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
                SELECT
                    Id,
                    userCommunityMode__c,
                    userCommunytyType__c,
                    MailingCountry,
                    MailingCity,
                    MailingPostalCode,
                    MailingState,
                    MailingStreet,
                    AccountId
                FROM Contact
                WHERE
                    (Email = :email
                    OR Email = :email.toLowerCase())
                    AND userCommunityMode__c != 'CC'
                LIMIT 1
            ];
        }

        if (cntList.isEmpty()) {
            Account newAcc = new Account(
                Name = lastName + ' temporary account',
                OwnerId = CommunityService.getUserContact().Account.OwnerId
            );
            insert newAcc;
            cntList.add(
                new Contact(
                    FirstName = firstName,
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
                    MailingState = piContact.MailingState
                )
            );
            insert cntList;
        } else {
            cntList[0].RP_Invited_By_PI__c = true;
        }
        if (String.isBlank(studySiteId)) {
            studySitesToInvite = getStudySitesForMatchedRP(cntList[0].Id, piIds);
        } else {
            studySitesToInvite.add(new Study_Site__c(Id = studySiteId));
        }
        List<User> usrs = CommunityService.getCommunityUsersByContactIds(
            new Set<Id>{ cntList[0].Id }
        );
        if (cntList[0].userCommunytyType__c == null) {
            cntList[0].userCommunytyType__c = CommunityService.USER_MODE_HCP;
        } else if (!cntList[0].userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) {
            cntList[0].userCommunytyType__c =
                cntList[0].userCommunytyType__c +
                ';' +
                CommunityService.USER_MODE_HCP;
        }
        if (cntList[0].userCommunityMode__c != CommunityService.USER_MODE_HCP) {
            cntList[0].userCommunityMode__c = CommunityService.USER_MODE_HCP;
        }
        update cntList[0];

        if (usrs.isEmpty()) {
            isNewUser = true;
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createPortalUsers(new Set<Id>{ cntList[0].Id });
        }

        for (Study_Site__c stdSite : studySitesToInvite) {
            hcpes.add(
                new HCP_Enrollment__c(
                    HCP_Contact__c = cntList[0].Id,
                    HCP_Account__c = cntList[0].AccountId,
                    Status__c = stdSite.Clinical_Trial_Profile__r.Orientation_Required__c
                        ? HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
                        : HCPEnrollmentService.HCP_S_ACTIVATED,
                    Study_Site__c = (String.isBlank(stdSite.Id) ? null : stdSite.Id)
                )
            );
        }
        if (hp != null) {
            if (!isNewUser) {
                String permissionSetName = UserContext.getCurrentCommunityTemplate().permissionSet;
                actionAssignContactPermissions.addPermission(usrs[0].ContactId, permissionSetName);
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
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
                    piRPList.add(
                        new PI_RP_Relationship__c(
                            PI_Contact__c = piId,
                            RP_Contact__c = cntList[0].Id
                        )
                    );
                }
                insert piRPList;
            } else {
                insert new PI_RP_Relationship__c(
                    PI_Contact__c = studySitesToInvite[0].Principal_Investigator__c,
                    RP_Contact__c = cntList[0].Id
                );
            }
            if (!isNewUser) {
                String permissionSetName = UserContext.getCurrentCommunityTemplate().permissionSet;
                actionAssignContactPermissions.addPermission(usrs[0].ContactId, permissionSetName);
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
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

    public static void sendNotificationForRPInvite(
        Id hcpEnrollId,
        Id hcpContactId,
        List<String> piIds
    ) {
        insert new Notification__c(
            Recipient__c = hcpContactId,
            WhatId__c = hcpEnrollId,
            Notification_Type__c = piIds.isEmpty()
                ? NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TYPE
                : NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TO_MULTIPI_TYPE
        );
    }

    public final static String HP_S_INVITED = 'Invited';
    public final static String HP_S_REGISTRED = 'Registered';
    public final static String HP_S_NOSHARING = 'No Sharing';
    public final static String HP_S_DUPLICATE = 'Duplicate';
    public final static String DEL_ON_DISCONNECTED = 'Disconnected';
    public final static String DEL_ACTIVE = 'Active';

    public class HealthcareProvider {
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public String participantId { get; set; }
        @AuraEnabled
        public String healthcareProviderId { get; set; }
        @AuraEnabled
        public Boolean isDuplicate { get; set; }
        @AuraEnabled
        public Boolean isDuplicateDelegate { get; set; }
        @AuraEnabled
        public String hcpContactId { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
        @AuraEnabled
        public String contactPhoneNumber { get; set; }
        @AuraEnabled
        public String contactPhoneType { get; set; }
        @AuraEnabled
        public String DelegateYOB { get; set; }
        @AuraEnabled 
        public Contact conObject { get; set; } // Added for ePR batch Fix
    }

    public class PDWrapper {
        @AuraEnabled
        public String delegateId;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String status;

        public PDWrapper(
            String delegateId,
            String firstName,
            String lastName,
            String email,
            String status
        ) {
            this.delegateId = delegateId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.email = email;
            this.status = status;
        }
        public PDWrapper() {
        }
    }

    public static List<Patient_Delegate__c> checkDuplicatePDelegates(
        String participantId,
        String email,
        String firstName,
        String lastName
    ) {
        String duplicateDelegatesQuery =
            'SELECT Id FROM Patient_Delegate__c WHERE Participant__c = \'' +
            participantId +
            '\' AND Contact__r.Email = \'' +
            email +
            '\' AND (Status__c = \'Active\' OR Status__c = \'Disconnected\')';

        if (firstName != null || lastName != null) {
            duplicateDelegatesQuery += 'AND Contact__c IN (SELECT Contact__c FROM Participant__c WHERE ';

            if (firstName != null) {
                duplicateDelegatesQuery +=
                    '( First_Name__c = \'' +
                    firstName +
                    '\' OR First_Name__c = \'' +
                    firstName.toLowerCase() +
                    '\')';
            }
            if (firstName != null && lastName != null) {
                duplicateDelegatesQuery += ' AND ';
            }
            if (lastName != null) {
                duplicateDelegatesQuery +=
                    ' ( Last_Name__c = \'' +
                    lastName +
                    '\' OR Last_Name__c = \'' +
                    lastName.toLowerCase() +
                    '\')';
            }
            if (firstName != null || lastName != null) {
                duplicateDelegatesQuery += ' ) ';
            }
        }
        return Database.query(duplicateDelegatesQuery);
    }
    public static List<Patient_Delegate_Enrollment__c> checkDuplicatePDERDelegates(
        String participantId,
        String email,
        String firstName,
        String lastName,
        String peId
    ) {
       List< Participant__c> partList;
       if (firstName != null && lastName != null) {
        partList= [SELECT Contact__c FROM Participant__c WHERE
                                (First_Name__c =:firstName OR First_Name__c = :firstName.toLowerCase())
                                 AND 
                                (Last_Name__c =:lastName OR Last_Name__c =:lastName.toLowerCase() )];
       }
       else  if (firstName != null){
        partList= [SELECT Contact__c FROM Participant__c WHERE
        (First_Name__c =:firstName OR First_Name__c = :firstName.toLowerCase())
        ];
       }
       else if(lastName != null){
        partList= [SELECT Contact__c FROM Participant__c WHERE
        (Last_Name__c =:lastName OR Last_Name__c =:lastName.toLowerCase() )];

       }


        List<Id> delegateContactIds = new List<Id>();
          for(Participant__c part : partList)
          {
            delegateContactIds.add(part.Contact__c);
          }
          String duplicateDelegatesQuery =
            'SELECT Id, Patient_Delegate__c FROM Patient_Delegate_Enrollment__c WHERE Participant_Enrollment__c = \'' +
            peId +
            '\' AND Patient_Delegate__r.Contact__r.Email = \'' +
            email +
            '\' AND (Status__c = \'Active\' OR Status__c = \'Disconnected\')';

        if (firstName != null || lastName != null) {
                duplicateDelegatesQuery += 'AND Patient_Delegate__r.Contact__c IN: delegateContactIds ';
    
        }
        return Database.query(duplicateDelegatesQuery);
    }
    //Create survey task for Patient delegates which got created via bulk import. 
    public static void createSurveyTaskforpatientDelegate(id participantId){
        Map<Id, String> invitationsVisibleMap = new Map<Id, String>();
         List<SurveyInvitation> surveyInvitationList = [
            SELECT
                Id,
                ExpireDateTime__c,
                Participant_Enrollment__r.Participant_Contact__c,
                Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                Reminder_Schedule__c,
                Reminder_Schedule__r.First_Reminder_day__c,
                Survey.Name,
             	Trial_Survey__r.Whose_response_needed__c
            FROM SurveyInvitation
            WHERE
                Participant_Enrollment__r.Participant__c =: participantId
             	AND Participant_Enrollment__r.Is_Created_by_Bulk_Import__c = TRUE
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Tasks_Are_Available__c = TRUE
                AND Trial_Survey__r.Active_On_Status__c !=NULL
        ];
        for(surveyInvitation sr: surveyInvitationList){
            if(sr.Trial_Survey__r.Whose_response_needed__c=='Each Delegate' || 
            sr.Trial_Survey__r.Whose_response_needed__c=='Patient and each Delegate'){
             invitationsVisibleMap.put(sr.id,sr.Trial_Survey__r.Whose_response_needed__c);
         } 
        }
        if (invitationsVisibleMap != null && !invitationsVisibleMap.isEmpty()){
                //Recalling createSurveyTasks method to create survey task for Patient Delegates
                TaskService.createSurveyTasksforDelegate(invitationsVisibleMap,false);
            }
    }
}