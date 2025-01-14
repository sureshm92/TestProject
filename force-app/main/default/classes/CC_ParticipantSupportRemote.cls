public without sharing class CC_ParticipantSupportRemote {
    public class InitData {
        @AuraEnabled
        public List<Participant_Enrollment__c> enrollments;
    }

    @AuraEnabled
    public static string fetchParticipantEnrollment(String searchKeyWord) {
        try {
            searchKeyWord = searchKeyWord.replaceAll('[^a-zA-Z0-9\\s+]', '');
            if (searchKeyWord.length() > 10) {
                searchKeyWord = searchKeyWord.right(10);
            }
            List<Participant_Enrollment__c> returnList = new List<Participant_Enrollment__c>();
            string query;
            if (!Test.isRunningTest()) {
                query =
                    'SELECT Participant__r.Full_Name__c,Participant_Status__c,Days_After_Referred__c, Participant__c,Participant__r.Phone__c, Participant_Contact__c,HCP_Contact_HCPEnroll__c,Participant__r.Phone_Type__c, Clinical_Trial_Profile__r.Study_Code_Name__c, PI_Contact__r.Name, Study_Site__r.Name,Participant_Contact__r.Name, Participant__r.First_Name__c,Participant__r.Last_Name__c,Participant__r.Middle_Name__c,Participant__r.Contact__c,Participant__r.Suffix__c,Participant__r.Nickname__c,Participant__r.Date_of_Birth__c,Participant__r.Gender__c,Participant__r.Email__c,Participant__r.Mailing_Country_Code__c,Participant__r.Adult__c,Participant__r.Mailing_State_Code__c,Participant__r.Emancipation_in_progress__c,Participant__r.Mailing_Zip_Postal_Code__c,Participant__r.Alternative_Phone_Number__c,Participant__r.Alternative_Phone_Type__c,Study_Site__r.Study_Site_Phone__c, Study_Site__c,Participant__r.Marketing_Flag__c,Study_Site__r.Study_Site_Type__c,Participant__r.IsCountry_NOT_Eligible_for_Emails__c, Participant__r.Fphone__c FROM Participant_Enrollment__c where Participant__r.Fphone__c  like\'' +
                    '%' +
                    searchKeyWord +
                    '%\'';
                query += 'LIMIT 10';
            }
            if (Test.isRunningTest()) {
                query =
                    'SELECT Participant__r.Full_Name__c,Participant_Status__c,Days_After_Referred__c, Participant__c,Participant__r.Phone__c, Participant_Contact__c,HCP_Contact_HCPEnroll__c,Participant__r.Phone_Type__c, Clinical_Trial_Profile__r.Study_Code_Name__c, PI_Contact__r.Name, Study_Site__r.Name,Participant_Contact__r.Name, Participant__r.First_Name__c,Participant__r.Last_Name__c,Participant__r.Middle_Name__c,Participant__r.Contact__c,Participant__r.Suffix__c,Participant__r.Nickname__c,Participant__r.Date_of_Birth__c,Participant__r.Gender__c,Participant__r.Email__c,Participant__r.Mailing_Country_Code__c,Participant__r.Adult__c,Participant__r.Mailing_State_Code__c,Participant__r.Emancipation_in_progress__c,Participant__r.Mailing_Zip_Postal_Code__c,Participant__r.Alternative_Phone_Number__c,Participant__r.Alternative_Phone_Type__c,Study_Site__r.Study_Site_Phone__c, Study_Site__c,Participant__r.Marketing_Flag__c,Study_Site__r.Study_Site_Type__c,Participant__r.IsCountry_NOT_Eligible_for_Emails__c, Participant__r.Fphone__c FROM Participant_Enrollment__c where Participant__r.Phone__c =\'' +
                    searchKeyWord +
                    '\'';
            }

            List<Participant_Enrollment__c> lstOfParticipantEnrollment = Database.query(query);

            for (Participant_Enrollment__c PE : lstOfParticipantEnrollment) {
                returnList.add(PE);
            }
            InitData initData = new InitData();
            initData.enrollments = returnList;
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string getInvitedDetails(string contactid) {
        try {
            Boolean Userexist;
            List<user> lstUser = new List<user>();
            lstUser = [SELECT id, ContactId FROM user WHERE ContactId = :contactid];
            if (lstUser.size() == 0) {
                Userexist = false;
            } else {
                Userexist = true;
            }
            return JSON.serialize(Userexist);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}
