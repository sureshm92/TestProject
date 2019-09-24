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
                                                                    Participant_Enrollment__c
                                                            FROM Healthcare_Provider__c
                                                            WHERE Participant_Enrollment__c = :peId AND
                                                                  Status__c != :HP_S_NOSHARING];

        if (healthcareProviders.isEmpty()) healthcareProviders.add(new Healthcare_Provider__c());

        return healthcareProviders;
    }

    @AuraEnabled
    public static HealthcareProvider checkDuplicate(String peId, String email) {
        HealthcareProvider hp = new HealthcareProvider();
        hp.email = email;

        if (!String.isBlank(email)) {
            List<Contact> contacts = [
                    SELECT Id, FirstName, LastName, Name, Email
                    FROM Contact
                    WHERE Email = :email OR Email = :email.toLowerCase()
            ];

            if (!contacts.isEmpty()) {
                hp.email = contacts[0].Email;
                hp.firstName = contacts[0].FirstName;
                hp.lastName = contacts[0].LastName;

                Healthcare_Provider__c newHP = new Healthcare_Provider__c();
                newHP.Participant_Enrollment__c = peId;
                newHP.Email__c = hp.email;
                newHP.First_Name__c = hp.firstName;
                newHP.Last_Name__c = hp.lastName;
                newHP.Status__c = HP_S_DUPLICATE;
                insert newHP;
            }
        }

        return hp;
    }

    public static List<Healthcare_Provider__c> inviteHP(String peId, String hp) {
        Healthcare_Provider__c newHP = (Healthcare_Provider__c) JSON.deserialize(hp,Healthcare_Provider__c.class);

        Participant_Enrollment__c pe = [SELECT Id, Study_Site__c FROM Participant_Enrollment__c WHERE Id = :peId];

        if (!String.isBlank(peId) && newHP != null) {
            newHP.Participant_Enrollment__c = peId;
            newHP.Status__c = HP_S_INVITED;
            insert newHP;

            newHP.HCP_Enrollment__c = createHCPinPlatform(pe.Study_Site__c, hp.firstName, hp.lastName, hp.email, null);
            update newHP;
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

    public static String createHCPinPlatform(String studySiteId, String firstName, String lastName, String email, String phone) {
        Study_Site__c studySite = [SELECT Id, Site__c, Site__r.BillingCountry FROM Study_Site__c WHERE Id = :studySiteId];
        List<Contact> cntList =
        [SELECT Id, userCommunityMode__c, userCommunytyType__c
        FROM Contact
        WHERE Email = :email OR
        Email = :email.toLowerCase() LIMIT 1];

        if (cntList.isEmpty()) {
            cntList.add(new Contact(FirstName = firstName,
                    LastName = lastName,
                    Phone = phone,
                    Email = email,
                    AccountId = studySite.Site__c,
                    Language__c = UserInfo.getLanguage(),
                    MailingCountry = studySite.Site__r.BillingCountry));
            insert cntList;
        }

        List<User> usrs = CommunityService.getCommunityUsersByContactIds(new Set<Id> { cntList[0].Id });

        if (usrs.isEmpty()) {
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

        HCP_Enrollment__c hcpe = new HCP_Enrollment__c(
                HCP_Contact__c = cntList[0].Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT,
                Study_Site__c = studySiteId
        );
        insert hcpe;

        hcpe.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpe;

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
    }

}