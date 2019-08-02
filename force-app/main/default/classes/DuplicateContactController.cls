/**
 * Created by Denis Shpilevsky
 */
public without sharing class  DuplicateContactController {

    public static Boolean isPERCreated = false;
    public static void checkDuplicates(Integration_Patient_Referral__c record){
        primaryPhoneEmailCheck(record);
    }

	public static Participant__c communityReffering(Participant__c participant, Participant_Enrollment__c participantEnrollment){
        Integration_Patient_Referral__c tempRecord = new Integration_Patient_Referral__c(
			firstName__c = participant.First_Name__c,
			lastName__c = participant.Last_Name__c,
			email__c = participant.email__c,
			phone__c = participant.phone__c,
            Phone_Type__c = participant.Phone_Type__c,
            birthYear__c = participant.Date_of_Birth__c != null && participant.Date_of_Birth__c != '' ?  participant.Date_of_Birth__c.substring(0,4) : '',
            Address_Country__c = participant.Mailing_Country_Code__c,
            Address_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, participant.Mailing_State_Code__c),
            Data_Source__c = participantEnrollment.Referral_Source__c,
            sex__c = participant.Gender__c,
            Address_ZipCode__c = participant.Mailing_Zip_Postal_Code__c,
            BirthDate__c = participant.Date_of_Birth__c
		);
        Participant__c participantRecord = primaryPhoneEmailCheck(tempRecord);
        isPERCreated = false;
		return participantRecord;
	}
    
    private static Participant__c primaryPhoneEmailCheck(Integration_Patient_Referral__c record){
        Participant__c participant = new Participant__c();
        List<Contact> contactRecords = new List<Contact>();
		List<Participant__c> participantRecords = new List<Participant__c>();
		List<Id> contactsIds = new List<Id>();
        String email = record.email__c == null ? '+' : record.email__c;
        String phone = record.phone__c == null ? '+' : record.phone__c;
        
		participantRecords = [
            SELECT 	id,
            		Contact__c
            FROM	Participant__c
            WHERE 	(Email__c = :email OR
            		Phone__c = :phone)
        ];
		for(Participant__c item : participantRecords){
			contactsIds.add(item.Contact__c);
		}

		contactRecords = [
            SELECT 	id,
            		BirthDate,
            		FirstName,
            		LastName,
            		userCommunityMode__c,
					userCommunytyType__c,
					(
						SELECT	id,
								First_Name__c,
								Last_Name__c,
								Phone__c,
								Email__c,
                                Date_of_Birth__c
						FROM	Participants__r
					)
            FROM	Contact
            WHERE 	(Email = :email OR
            		Phone = :phone OR Id IN:contactsIds)
        ];

		Integer recordsContactCount = contactRecords.size();
		if(recordsContactCount != 0){
			if((record.BirthYear__c != null && record.BirthYear__c != '') || (record.BirthDate__c != null && record.BirthDate__c != '')){
                for(Integer i = 0; i < recordsContactCount; i++){
                    if(checkBirthDate(record, contactRecords[i])){
                        System.debug('Passed checkBirthDate');
                        if(checkFirstName(record, contactRecords[i])){
                            System.debug('Passed checkFirstName');
                            participant = processedDuplicate(contactRecords[i].id, record);
							break;
                        }else if(recordsContactCount == (i + 1)){
                            participant = createNewRecords(record);
							break;
                        }
                    }else if(contactRecords[i].BirthDate == null && checkBirthDateWeak(record)){
                       System.debug('BirthDate null');
                       if(checkFirstName(record, contactRecords[i])){
                            System.debug('Passed checkBirthDate');
                           	contactRecords[i].BirthDate = record.BirthDate__c != null ? convertBirthDate(record.BirthDate__c) : Date.newInstance(Integer.valueOf(record.BirthYear__c), 1, 1);
                            participant = processedDuplicate(contactRecords[i].id, record);
							break;
                        }else if(recordsContactCount == (i + 1)){
                            participant = createNewRecords(record);
							break;
                        } 	
                    }else if(recordsContactCount == (i + 1)){
                        participant = createNewRecords(record);
						break;
                    }
                }
            }else{
                for(Integer i = 0; i < recordsContactCount; i++){
                    if(checkFirstName(record, contactRecords[i])){
                        System.debug('Passed checkFirstName');
                        if(checkLastName(record,contactRecords[i])){
                            System.debug('Passed checkLastName');
                            if(contactRecords[i].userCommunytyType__c == null  || !contactRecords[i].userCommunytyType__c.contains(CommunityService.USER_MODE_PARTICIPANT)){
                                participant = ParticipantDeduplicationController.checkPER(contactRecords[i].id, record);
								break;
							}else{
                             	participant = processedDuplicate(contactRecords[i].id, record);  
								break;
						    }
                            
                        }else if(recordsContactCount == (i + 1)){
                            participant = createNewRecords(record);
							break;
                        }
                    }else if(recordsContactCount == (i + 1)){
                         participant = createNewRecords(record);
						 break;
                    }
                }
            }
        }else{
            participant = createNewRecords(record);
        }
        if(!isPERCreated){
            update contactRecords;
        }
        return participant;
    }
    
    private static Participant__c createNewRecords(Integration_Patient_Referral__c record){
        System.debug('createNewRecords');
        return ParticipantDeduplicationController.checkPER(record);
    }
    
    private static Participant__c processedDuplicate(String contactId, Integration_Patient_Referral__c record){
        System.debug('processedDuplicate');
        List<Participant__c> listOfParticipants = new List<Participant__c>();
        listOfParticipants = [SELECT id, Secondary_Source__c FROM Participant__c WHERE Contact__c = :contactId];
        if(listOfParticipants.size() != 0){
            if(!isPERCreated){
                return ParticipantDeduplicationController.checkPER(contactId, listOfParticipants[0], record);
            }else{
                return listOfParticipants[0];
            }
        }else{
            return ParticipantDeduplicationController.checkPER(contactId, record);
        }
    }

    private static boolean checkFirstName(Integration_Patient_Referral__c record, Contact contactRecord){
        System.debug('checkFirstName');
        return  record.firstName__c  == contactRecord.FirstName || 
                (   contactRecord.Participants__r != null && 
                    contactRecord.Participants__r.size() != 0 && 
                    contactRecord.Participants__r[0].First_Name__c == record.firstName__c
                );
    }

    private static boolean checkLastName(Integration_Patient_Referral__c record, Contact contactRecord){
        System.debug('checkLastName');
        return  record.lastName__c == contactRecord.LastName || 
                (
                    contactRecord.Participants__r != null && 
                    contactRecord.Participants__r.size() != 0 && 
                    contactRecord.Participants__r[0].Last_Name__c == record.lastName__c
                );
    }

    private static boolean checkBirthDate(Integration_Patient_Referral__c record, Contact contactRecord){
        System.debug('checkBirthDate');
        if(record.BirthDate__c != null && record.BirthDate__c != ''){
            return  (   
                        contactRecord.BirthDate != null && 
                        contactRecord.BirthDate == convertBirthDate(record.BirthDate__c)
                    ) ||  
                    (   
                        contactRecord.Participants__r != null && 
                        contactRecord.Participants__r.size() != 0 &&
                        contactRecord.Participants__r[0].Date_of_Birth__c != null &&
                        contactRecord.Participants__r[0].Date_of_Birth__c != '' &&   
                        contactRecord.Participants__r[0].Date_of_Birth__c == String.valueOf(convertBirthDate(record.BirthDate__c))
                    );
        }else{
            return  (
                        contactRecord.BirthDate != null && record.BirthYear__c == String.valueOf(contactRecord.BirthDate.year())
                    ) ||
                    (
                        contactRecord.Participants__r != null && 
                        contactRecord.Participants__r.size() != 0 &&
                        contactRecord.Participants__r[0].Date_of_Birth__c != null &&
                        contactRecord.Participants__r[0].Date_of_Birth__c != '' &&  
                        record.BirthYear__c == contactRecord.Participants__r[0].Date_of_Birth__c.substring(0,4)
                    );
        }
    }


    private static boolean checkBirthDateWeak(Integration_Patient_Referral__c record){
        System.debug('checkBirthDate');
        if(record.BirthDate__c != null && record.BirthDate__c != ''){
           return !checkBirthDate(record.BirthDate__c.substring(6));
        }else{
            return !checkBirthDate(record.BirthYear__c);
        }
    }

    private static boolean checkBirthDate(String birthYear){
        System.debug('birthYear:' + birthYear);
        if(birthYear == null || birthYear == ''){
            System.debug('empty birthdate');
            return true;
        }
        Integer referralDateYear = Integer.valueOf(birthYear);
        Integer currentYear = Date.today().year();
        if((currentYear - referralDateYear) > 18){
            System.debug('+18');
            return false;
        }else{
            System.debug('-18');
            return true;
        }

    }

    private static Date convertBirthDate(String birthDate){
        if(birthDate.length() == 10){
            String updatedDateString = birthDate.substring(8) + '-' + birthDate.substring(5,7) + '-' + birthDate.substring(0,4);
            Date newDate = Date.valueOf(updatedDateString);
            return newDate;
        }else{
            return null;
        }
    }
}