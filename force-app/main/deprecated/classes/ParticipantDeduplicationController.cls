/**
 * Created by Denis Shpilevsky
 */

//TODO !!! DEPRECATED MUST BE REMOVED!!!

public without sharing class ParticipantDeduplicationController {
  /*  public static Boolean changeLastName = true;
    public static Boolean checkLastName(){
        return changeLastName;
    }

    private static String updateSecondarySource(String ssString, String newValue){
        List<String> listOfSources = new List<String>();
        Boolean isDuplicate = false;
        listOfSources = ssString.split(';');
        for(String item : listOfSources){
            if(item == newValue){
                isDuplicate = true;
            }
        }
        return isDuplicate ? ssString : ssString + ';' + newValue;
    }
    
    public static Participant__c checkPER(String contactId, Participant__c participant, Integration_Patient_Referral__c referralRecord){
        List<Study_Site__c> listOfStudySite = new List<Study_Site__c>();
        String erpKey = referralRecord.protocolId__c + '_' + referralRecord.Address_Country__c + '_' + referralRecord.siteSelected__c;
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
            		Participant__c =:participant.Id
        ];
        if(listOfEnrollments.size() != 0){
            if(listOfEnrollments[0].Participant_Status__c ==  ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI){
               participant.Secondary_Source__c = updateSecondarySource(participant.Secondary_Source__c, referralRecord.Data_Source__c);
            }
            
        }else{
            List<Participant_Enrollment__c> listOfEnrollmentsWithoutStudy  = new List<Participant_Enrollment__c>();
            listOfEnrollmentsWithoutStudy = [
                SELECT	id,
                        Clinical_Trial_Profile__c,
                        Participant__c,
                        Participant_Status__c
                FROM	Participant_Enrollment__c
                WHERE 	Participant__c =:participant.Id
            ];
            if(listOfEnrollmentsWithoutStudy.size() != 0 && !DuplicateContactController.isPERCreated){
                String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c; 
                Participant_Enrollment__c newPER = createParticipantEnrollment(contactId, participant.Id, studySiteNumber, referralRecord);
                participant.Secondary_Source__c = updateSecondarySource(participant.Secondary_Source__c, referralRecord.Data_Source__c);
                update participant;
            }else{
                //Error Message
            }
        }
        update participant;
        return null;
    }

    
    
    public static Participant__c checkPER(String contactId, Integration_Patient_Referral__c referralRecord){
        changeLastName = false;
        Participant__c newParticipant = createParticipant(contactId, referralRecord);
        String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.siteSelected__c;
        if(!DuplicateContactController.isPERCreated){ 
            Participant_Enrollment__c newPER = createParticipantEnrollment(contactId, newParticipant.Id, studySiteNumber, referralRecord);
        }
        changeLastName =true;
        return newParticipant;
    }
    
    public static Participant__c checkPER(Integration_Patient_Referral__c referralRecord){
        //changeLastName = false;
         Contact newContact = new Contact();
         if(!DuplicateContactController.isPERCreated){ 
            newContact = new Contact(
        	    LastName 				=	referralRecord.lastName__c,
                userCommunytyType__c	=	CommunityService.USER_MODE_PARTICIPANT,
                userCommunityMode__c	=	CommunityService.USER_MODE_PARTICIPANT,
			    Email					=	referralRecord.email__c,
			    Phone					=	referralRecord.phone__c,
			    AccountId				=	[SELECT id FROM Account WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME].id
            );
            insert newContact;
        }
        Participant__c newParticipant = createParticipant(newContact.Id, referralRecord);
        String studySiteNumber = referralRecord.protocolId__c + '_' + referralRecord.Address_Country__c + '_' + referralRecord.siteSelected__c;
        if(!DuplicateContactController.isPERCreated){ 
            Participant_Enrollment__c newPER = createParticipantEnrollment(newContact.Id, newParticipant.Id, studySiteNumber, referralRecord);
        }
		return newParticipant;
    }

    private static Contact createContact(Integration_Patient_Referral__c referralRecord){
        return null;
    }

     private static Participant__c createParticipant(String contactId, Integration_Patient_Referral__c referralRecord){
         Participant__c newParticipant = new Participant__c(
        	Contact__c	                = 	contactId == null ? null : contactId,
			First_Name__c               = referralRecord.firstName__c,
			Last_Name__c                = referralRecord.lastName__c,
			Email__c                    = referralRecord.email__c,
			Phone__c                    = referralRecord.phone__c,
			Mailing_State__c            = referralRecord.Address_State__c,
            Mailing_State_Code__c       = CountryStateUtil.getStateCode(referralRecord.Address_Country__c, referralRecord.Address_State__c),
			Mailing_Street__c           = referralRecord.Address_AddressLine1__c,
			Mailing_Zip_Postal_Code__c  = referralRecord.Address_ZipCode__c,
			Mailing_Country_Code__c     = referralRecord.Address_Country__c,
			Mailing_City__c             = referralRecord.Address_City__c,
            Preferred_Language__c       = LanguagePreferenceService.getLanguageCode(referralRecord.Language_Preference__c),
			Condition_of_Interest_s__c  = referralRecord.Condition_of_Interests__c,
            Secondary_Source__c         = referralRecord.Data_Source__c,
            Gender__c                   = referralRecord.sex__c,
            Birth_Year__c               = referralRecord.BirthYear__c,
            Phone_Type__c               = referralRecord.Phone_Type__c
         );
         if(referralRecord.BirthDate__c != null && referralRecord.BirthDate__c.length() == 10){
             if(referralRecord.BirthDate__c.indexOf('-') == 2 || referralRecord.BirthDate__c.indexOf('/') == 2){
                 System.debug('Here');
                 System.debug(referralRecord.BirthDate__c.substring(6) + '-' + referralRecord.BirthDate__c.substring(0,2) + '-' + referralRecord.BirthDate__c.substring(3,5));
                 newParticipant.Date_of_Birth__c = referralRecord.BirthDate__c.substring(6) + '-' + referralRecord.BirthDate__c.substring(0,2) + '-' + referralRecord.BirthDate__c.substring(3,5);
             } else {
                 System.debug('Here');
                 System.debug(referralRecord.BirthDate__c.replaceAll('/','-'));
                 newParticipant.Date_of_Birth__c = referralRecord.BirthDate__c.replaceAll('/','-');
             }
         }
         insert newParticipant;
         return newParticipant;
    }

     private static Participant_Enrollment__c createParticipantEnrollment(String contactId, String participantId,  String studySiteNumber, Integration_Patient_Referral__c referralRecord){
         Participant_Enrollment__c newPER = new Participant_Enrollment__c(
        	    Clinical_Trial_Profile__c	            = 	[SELECT id FROM Clinical_Trial_Profile__c WHERE Protocol_ID__c  = :referralRecord.protocolId__c].id,
                Participant__c				            =	participantId,
                Participant_Contact__c		            =	contactId,
                Study_Site__c				            = 	[SELECT id FROM Study_Site__c WHERE Primary_Key_ePR__c  = :studySiteNumber].id,
			    Pre_Eligibility__c                      =   referralRecord.Pass_Fail__c,
			    Referral_Source__c                      =   referralRecord.Data_Source__c,
			    Participant_ID_randomized_ID__c         =   referralRecord.ePRPatient_ID_Number__c,
			    Referral_ID__c                          =   referralRecord.referralID__c,
			    Participant_Status__c                   =   ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Terms_and_Conditions_Accepted_Date__c   =   referralRecord.acceptedTermsAndConditions__c != null ? Date.valueOf(referralRecord.acceptedTermsAndConditions__c) : null,
                Referred_Date__c                        =   referralRecord.Referred_Date__c != null ? Date.valueOf(referralRecord.Referred_Date__c) : null,
                 Referred_By__c                         =   'Other',
                 utm_campaign__c = referralRecord.UTM_campaignName__c,
                 utm_content__c = referralRecord.UTM_campaignContent__c,
                 utm_medium__c = referralRecord.UTM_campaignMedium__c,
                 utm_source__c = referralRecord.UTM_campaignSource__c,
                 utm_term__c = referralRecord.UTM_campaignTerm__c,
                 utmz__c = referralRecord.UTM_campaignCookie__c,
                 gclid__c = referralRecord.UTM_GCLID__c
            );
        insert newPer;
        return newPer;
    }
*/
}