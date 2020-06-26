public without sharing class CC_ParticipantSupportRemote {
    
    public class InitData {
        @AuraEnabled
        public List < Participant_Enrollment__c > enrollments;
    }
    
    @AuraEnabled
    public static string fetchParticipantEnrollment(String searchKeyWord) {
        try {
            
            List < Participant_Enrollment__c > returnList = new List < Participant_Enrollment__c > ();
            List < Participant_Enrollment__c > lstOfParticipantEnrollment = [SELECT Participant__r.Full_Name__c,
                                                                             Days_After_Referred__c, Participant__c, 
                                                                             Participant__r.Phone__c, 
                                                                             Participant__r.Phone_Type__c, 
                                                                             Clinical_Trial_Profile__r.Study_Code_Name__c, 
                                                                             PI_Contact__r.Name, Study_Site__r.Name,
                                                                             Participant_Contact__r.Name, 
                                                                             Participant__r.First_Name__c,
                                                                             Participant__r.Last_Name__c,
                                                                             Participant__r.Middle_Name__c,
                                                                             Participant__r.Contact__c,
                                                                             Participant__r.Suffix__c,
                                                                             Participant__r.Nickname__c,
                                                                             Participant__r.Date_of_Birth__c,
                                                                             Participant__r.Gender__c,
                                                                             Participant__r.Email__c,
                                                                             Participant__r.Mailing_Country_Code__c,
                                                                             Participant__r.Adult__c,
                                                                             Participant__r.Mailing_State_Code__c,
                                                                             Participant__r.Emancipation_in_progress__c,
                                                                             Participant__r.Mailing_Zip_Postal_Code__c,
                                                                             Participant__r.Alternative_Phone_Number__c,
                                                                             Participant__r.Alternative_Phone_Type__c,
                                                                             Study_Site__r.Study_Site_Phone__c, Study_Site__c 
                                                                             FROM Participant_Enrollment__c 
                                                                             where Participant__r.Phone__c =: searchKeyWord
                                                                            ];
            
            for (Participant_Enrollment__c PE: lstOfParticipantEnrollment) {
                returnList.add(PE);
            }
            InitData initData = new InitData();
            initData.enrollments= returnList;
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}