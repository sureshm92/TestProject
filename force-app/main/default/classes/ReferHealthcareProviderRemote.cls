/**
 * Created by Alexey Moseev on 2019-09-23.
 */

global class ReferHealthcareProviderRemote {

    @AuraEnabled
    public static List<Healthcare_Provider__c> getInitData(String peId) {
        List<Healthcare_Provider__c> healthcareProviders = [SELECT  Id,
                                                                    First_Name__c,
                                                                    Last_Name__c,
                                                                    Email__c,
                                                                    Status__c,
                                                                    Participant_Enrollment__c
                                                            FROM Healthcare_Provider__c
                                                            WHERE Participant_Enrollment__c = :peId];

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

                return hp;
            }
        }

        return hp;
    }

    @AuraEnabled
    public static List<Healthcare_Provider__c> inviteHP(String peId, HealthcareProvider hp) {
        Healthcare_Provider__c newHP = new Healthcare_Provider__c();
        newHP.Participant_Enrollment__c = peId;
        newHP.Email__c = hp.email;
        newHP.First_Name__c = hp.firstName;
        newHP.Last_Name__c = hp.lastName;
        newHP.Status__c = HP_S_INVITED;
        insert newHP;

        return getInitData(peId);
    }

    @AuraEnabled
    public static String stopSharing(String hpId) {
        Healthcare_Provider__c newHP = [SELECT Id, Status__c FROM Healthcare_Provider__c WHERE Id = :hpId];
        newHP.Status__c = HP_S_NOSHARING;
        update newHP;

        return newHP.Id;
    }

    public final static String HP_S_INVITED = 'Invited';
    public final static String HP_S_REGISTRED = 'Registered';
    public final static String HP_S_NOSHARING = 'No Sharing';
    public final static String HP_S_DUPLICATE = 'Duplicate';

    public class HealthcareProvider {
        public String email { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
    }

}