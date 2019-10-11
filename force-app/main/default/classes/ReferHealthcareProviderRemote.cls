/**
 * Created by Alexey Moseev on 2019-09-23.
 */

global without sharing class ReferHealthcareProviderRemote {

    @AuraEnabled
    public static List<Healthcare_Provider__c> getInitData(String peId) {
        List<Healthcare_Provider__c> healthcareProviders = [SELECT  Id,
                                                                    First_Name__c,
                                                                    Last_Name__c,
                                                                    Email__c,
                                                                    Status__c,
                                                                    Participant_Enrollment__c,
                                                                    HCP_Enrollment__c
                                                            FROM Healthcare_Provider__c
                                                            WHERE Participant_Enrollment__c = :peId];

        if(healthcareProviders.isEmpty()) healthcareProviders.add(new Healthcare_Provider__c());
        return healthcareProviders;
    }

    @AuraEnabled
    public static HealthcareProvider checkDuplicate(String peId, String email) {
        HealthcareProvider hp = new HealthcareProvider();
        hp.email = email;

        if (!String.isBlank(email)) {
            List<Contact> contacts = [
                    SELECT Id, FirstName, LastName, Name, Email, userCommunytyType__c
                    FROM Contact
                    WHERE Email = :email OR Email = :email.toLowerCase()
            ];

            if (!contacts.isEmpty()) {
                if (String.isBlank(contacts[0].FirstName) || String.isBlank(contacts[0].LastName)) {
                    List<Participant__c> participants = [SELECT  Id,
                                                                First_Name__c,
                                                                Last_Name__c
                                                        FROM Participant__c
                                                        WHERE Contact__c = :contacts[0].Id];
                    if (!participants.isEmpty()) {
                        hp.firstName = participants[0].First_Name__c;
                        hp.lastName = participants[0].Last_Name__c;
                        contacts[0].FirstName = participants[0].First_Name__c;
                        contacts[0].LastName = participants[0].Last_Name__c;
                        update contacts[0];
                    } else{
                        hp.firstName = contacts[0].FirstName;
                        hp.lastName = contacts[0].LastName;
                    }
                } else {
                    hp.firstName = contacts[0].FirstName;
                    hp.lastName = contacts[0].LastName;
                }
                hp.email = contacts[0].Email;
                if(peId != null) {
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
                } else{
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
        Healthcare_Provider__c newHP = (Healthcare_Provider__c) JSON.deserialize(hp,Healthcare_Provider__c.class);

        Participant_Enrollment__c pe = [SELECT Id, Study_Site__c FROM Participant_Enrollment__c WHERE Id = :peId];
        List<HCP_Enrollment__c> hcpe = new List<HCP_Enrollment__c>();

        if (!String.isBlank(peId) && newHP != null && String.isBlank(newHP.Id)) {
            newHP.Participant_Enrollment__c = peId;
            newHP.Status__c = HP_S_INVITED;
            insert newHP;

            createHCPinPlatform(pe.Study_Site__c, newHP.First_Name__c, newHP.Last_Name__c, newHP.Email__c, null, CommunityService.getUserContact(), newHP);
        } else if (!String.isBlank(newHP.Id) && newHP.Status__c == HP_S_NOSHARING) {
            hcpe = [SELECT Id,
                           HCP_Contact__c,
                           Status__c
                    FROM HCP_Enrollment__c
                    WHERE Id = :newHP.HCP_Enrollment__c];

            if (hcpe.isEmpty()) {
                List<Contact> contacts = [
                        SELECT Id, Email, AccountId
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
            }

            newHP.Status__c = HP_S_INVITED;
            update newHP;
        }

        if (!hcpe.isEmpty()) {
            hcpe[0].Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
            update hcpe;
            hcpe[0].Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
            update hcpe;
        }

        return getInitData(peId);
    }

    @AuraEnabled
    public static String stopSharing(String hpId) {
        Healthcare_Provider__c newHP = [SELECT Id, Status__c FROM Healthcare_Provider__c WHERE Id = :hpId];
        newHP.Status__c = HP_S_NOSHARING;
        update newHP;

        return newHP.Id;
    }

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone, Contact piContact) {
        return createHCPinPlatform(studySiteId, firstName, lastName, email, phone, piContact, null);
    }

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone, Contact piContact, Healthcare_Provider__c hp) {
        Boolean isNewUser = false;

        Study_Site__c studySite = [SELECT Id, Site__c, Site__r.BillingCountry FROM Study_Site__c WHERE Id = :studySiteId];
        List<Contact> cntList =
            [SELECT Id, userCommunityMode__c, userCommunytyType__c, MailingCountry, MailingCity,
                    MailingPostalCode, MailingState, MailingStreet, AccountId
             FROM Contact
             WHERE Email = :email OR
                   Email = :email.toLowerCase() LIMIT 1];

        if (cntList.isEmpty()) {
            Account newAcc = new Account(Name = lastName + ' temporary account', OwnerId = CommunityService.getUserContact().Account.OwnerId);
            insert newAcc;
            cntList.add(new Contact(FirstName = firstName,
                    LastName = lastName,
                    Phone = phone,
                    Email = email,
                    AccountId = newAcc.Id,
                    Language__c = UserInfo.getLanguage(),
                    RP_Invited_By_PI__c = true,
                    //MailingCountry = studySite.Site__r.BillingCountry));
                    MailingCountry = piContact.MailingCountry,
                    MailingState = piContact.MailingState));
            insert cntList;
        } else {
            cntList[0].RP_Invited_By_PI__c = true;
            update cntList[0];
        }

        HCP_Enrollment__c hcpe = new HCP_Enrollment__c(
                HCP_Contact__c = cntList[0].Id,
                HCP_Account__c = cntList[0].AccountId,
                Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION,
                Study_Site__c = (String.isBlank(studySiteId) ? null : studySiteId)
        );
        insert hcpe;

        if (hp != null) {
            hp.HCP_Enrollment__c = hcpe.Id;
            update hp;
        }

        List<User> usrs = CommunityService.getCommunityUsersByContactIds(new Set<Id> { cntList[0].Id });
        if (usrs.isEmpty()) {
            isNewUser = true;
            ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id> { cntList[0].Id });
        }
        if (cntList[0].userCommunytyType__c == null) {
            cntList[0].userCommunytyType__c = CommunityService.USER_MODE_HCP;
        } else if (!cntList[0].userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) {
            cntList[0].userCommunytyType__c = cntList[0].userCommunytyType__c + ';' + CommunityService.USER_MODE_HCP;
        }
        if (cntList[0].userCommunityMode__c != CommunityService.USER_MODE_HCP) {
            cntList[0].userCommunityMode__c = CommunityService.USER_MODE_HCP;
        }

        if (!isNewUser) {
            hcpe.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
            update hcpe;
        }
        if (!isNewUser) {
            hcpe.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
            update hcpe;
        }

        return hcpe.Id;
    }

    public final static String HP_S_INVITED = 'Invited';
    public final static String HP_S_REGISTRED = 'Registered';
    public final static String HP_S_NOSHARING = 'No Sharing';
    public final static String HP_S_DUPLICATE = 'Duplicate';

    public class HealthcareProvider {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public Boolean isDuplicate { get; set; }
    }

}
