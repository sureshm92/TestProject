public class ParticipantDeduplicationController {
    public static Boolean changeLastName = true;
    public static Boolean checkLastName(){
        return changeLastName;
    }
    
    public static void checkPER(String contactId, String participantId, Integration_Patient_Referral__c referralRecord){
        List<Study_Site__c> listOfStudySite = new List<Study_Site__c>();
        String erpKey = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c;
        String study = '';
        listOfStudySite = [
            SELECT	id,
            		Clinical_Trial_Profile__c
            FROM 	Study_Site__c
        	WHERE 	Primary_Key_ePR__c = :erpKey
        ];
        study = listOfStudySite[0].Clinical_Trial_Profile__c;
		
        List<Participant_Enrollment__c> listOfEnrollments = new List<Participant_Enrollment__c>();
        listOfEnrollments = [
        	SELECT	id,
            		Clinical_Trial_Profile__c,
            		Participant__c,
            		Participant_Status__c
            FROM	Participant_Enrollment__c
            WHERE 	Clinical_Trial_Profile__c = :study AND
            		Participant__c =:participantId
        ];
        if(listOfEnrollments.size() != 0){
            if(listOfEnrollments[0].Participant_Status__c == 'Test'){
                //Success
            }else{
                //Error message
            }
        }else{
            List<Participant_Enrollment__c> listOfEnrollments2 = new List<Participant_Enrollment__c>();
            listOfEnrollments2 = [
                SELECT	id,
                        Clinical_Trial_Profile__c,
                        Participant__c,
                        Participant_Status__c
                FROM	Participant_Enrollment__c
                WHERE 	Participant__c =:participantId
            ];
            if(listOfEnrollments2.size() != 0){
                String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c; 
                Participant_Enrollment__c newPER = new Participant_Enrollment__c(
                    Clinical_Trial_Profile__c	= 	[SELECT id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c  = :referralRecord.protocolId__c].id,
                    Participant__c				=	participantId,
                    Participant_Contact__c		=	contactId,
                    Study_Site__c				= 	[SELECT id FROM Study_Site__c WHERE Primary_Key_ePR__c  = :studySiteNumber].id,
					Pre_Eligibility__c = referralRecord.Pass_Fail__c,
					Referral_Source__c = referralRecord.Data_Source__c,
					Participant_ID_randomized_ID__c = referralRecord.ePRPatient_ID_Number__c,
					Referral_ID__c = referralRecord.referralID__c,
					Participant_Status__c = 'Referral Sent to PI'
                );
                insert newPer;
            }else{
                //Error Message
            }
        }
    }
    
    public static void checkPER(String contactId, Integration_Patient_Referral__c referralRecord){
        //changeLastName = false;
        Participant__c newParticipant = new Participant__c(
        	Contact__c	= 	contactId,
			First_Name__c = referralRecord.firstName__c,
			Last_Name__c = referralRecord.lastName__c,
			Email__c = referralRecord.email__c,
			Phone__c = referralRecord.phone__c,
			Mailing_State_Province__c = referralRecord.Address_State__c,
			Mailing_Street__c = referralRecord.Address_AddressLine1__c,
			Mailing_Zip_Postal_Code__c = referralRecord.Address_ZipCode__c,
			Mailing_Country_Code__c = referralRecord.Address_Country__c,
			Mailing_City__c = referralRecord.Address_City__c,
			Language_Preference_Code__c = referralRecord.Language_Preference__c,
			Condition_of_Interest_s__c = referralRecord.Condition_of_Interests__c
        );
        insert newParticipant;
        String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c; 
        Participant_Enrollment__c newPER = new Participant_Enrollment__c(
        	Clinical_Trial_Profile__c	= 	[SELECT id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c  = :referralRecord.protocolId__c].id,
            Participant__c				=	newParticipant.id,
            Participant_Contact__c		=	contactId,
            Study_Site__c				= 	[SELECT id FROM Study_Site__c WHERE Primary_Key_ePR__c  = :studySiteNumber].id,
			Pre_Eligibility__c = referralRecord.Pass_Fail__c,
			Referral_Source__c = referralRecord.Data_Source__c,
			Participant_ID_randomized_ID__c = referralRecord.ePRPatient_ID_Number__c,
			Referral_ID__c = referralRecord.referralID__c,
			Participant_Status__c = 'Referral Sent to PI'
        );
        insert newPer;

    }
    
    public static void checkPER(Integration_Patient_Referral__c referralRecord){
        //changeLastName = false;
    	Contact newContact = new Contact(
        	//FirstName 				= 	referralRecord.firstName__c,
            LastName 				=	referralRecord.lastName__c,
            userCommunytyType__c	=	'Participant',
            userCommunityMode__c	=	'Participant',
			Email					=	referralRecord.email__c,
			Phone					=	referralRecord.phone__c
        );
        insert newContact;
        System.debug('Limit' + Limits.getQueries());
        
        Participant__c newParticipant = new Participant__c(
        	Contact__c	= 	newContact.id,
			First_Name__c = referralRecord.firstName__c,
			Last_Name__c = referralRecord.lastName__c,
			Email__c = referralRecord.email__c,
			Phone__c = referralRecord.phone__c,
			Mailing_State_Province__c = referralRecord.Address_State__c,
			Mailing_Street__c = referralRecord.Address_AddressLine1__c,
			Mailing_Zip_Postal_Code__c = referralRecord.Address_ZipCode__c,
			Mailing_Country_Code__c = referralRecord.Address_Country__c,
			Mailing_City__c = referralRecord.Address_City__c,
			Language_Preference_Code__c = referralRecord.Language_Preference__c,
			Condition_of_Interest_s__c = referralRecord.Condition_of_Interests__c
        );
        insert newParticipant;
        System.debug('Limit' + Limits.getQueries());
        String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c; 
        Participant_Enrollment__c newPER = new Participant_Enrollment__c(
        	Clinical_Trial_Profile__c	= 	[SELECT id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c  = :referralRecord.protocolId__c].id,
            Participant__c				=	newParticipant.id,
            Participant_Contact__c		=	newContact.id,
            Study_Site__c				= 	[SELECT id FROM Study_Site__c WHERE Primary_Key_ePR__c  = :studySiteNumber].id,
			Pre_Eligibility__c = referralRecord.Pass_Fail__c,
			Referral_Source__c = referralRecord.Data_Source__c,
			Participant_ID_randomized_ID__c = referralRecord.ePRPatient_ID_Number__c,
			Referral_ID__c = referralRecord.referralID__c,
			Participant_Status__c = 'Referral Sent to PI'
        );
        insert newPer;
        System.debug('Limit' + Limits.getQueries());
    }
    
}