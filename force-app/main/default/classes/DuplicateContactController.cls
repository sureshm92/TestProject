public class DuplicateContactController {
    public static void checkDuplicates(Integration_Patient_Referral__c record){
        primaryPhoneEmailCheck(record);
    }
    
    private static void primaryPhoneEmailCheck(Integration_Patient_Referral__c record){
        System.debug('Check Record');
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
								Email__c
						FROM	Participants__r
					)
            FROM	Contact
            WHERE 	(Email = :email OR
            		Phone = :phone)
        ];

		
        
		Integer recordsContactCount = contactRecords.size();
		if(recordsContactCount != 0){
			if(record.BirthYear__c != null && record.BirthYear__c != ''){
                System.debug('BirthDate__c Check');
				for(Integer i = 0; i < recordsContactCount; i++){
                    if((contactRecords[i].BirthDate != null && record.BirthYear__c == String.valueOf(contactRecords[i].BirthDate.year()))){
                        System.debug('BirthDate__c Check Match');
                        if(record.firstName__c  == contactRecords[i].FirstName || (contactRecords[i].Participants__r != null && contactRecords[i].Participants__r[0].First_Name__c == record.firstName__c)){
                            System.debug('FirstName Check Match' + contactRecords[i].id);
                            contactRecords[i].Phone = record.phone__c;
                            processedDuplicate(contactRecords[i].id, record);
							break;
                        }else if(recordsContactCount == (i + 1)){
                            System.debug('New Records Done');
                            createNewRecords(record);
							break;
                        }
                    }else if(contactRecords[i].BirthDate == null){
                       if(record.firstName__c  == contactRecords[i].FirstName || (contactRecords[i].Participants__r != null && contactRecords[i].Participants__r[0].First_Name__c == record.firstName__c)){
                            System.debug('FirstName Check Match');
                           	contactRecords[i].BirthDate = Date.newInstance(Integer.valueOf(record.BirthYear__c), 1, 1);
                           	contactRecords[i].Phone = record.phone__c;
                            processedDuplicate(contactRecords[i].id, record);
							break;
                        }else if(recordsContactCount == (i + 1)){
                            System.debug('New Records Done');
                            createNewRecords(record);
							break;
                        } 	
                    }else if(recordsContactCount == (i + 1)){
                        System.debug('New Records Done');
                        createNewRecords(record);
						break;
                    }
                }
            }else{
                for(Integer i = 0; i < recordsContactCount; i++){
                    if(record.firstName__c  == contactRecords[i].FirstName || (contactRecords[i].Participants__r != null && contactRecords[i].Participants__r[0].First_Name__c == record.firstName__c)){
                        System.debug('FirstName Check Match');
                        if(record.lastName__c == contactRecords[i].LastName || (contactRecords[i].Participants__r != null && contactRecords[i].Participants__r[0].Last_Name__c == record.firstName__c)){
                            System.debug('LastName Check Match');
                            if(!contactRecords[i].userCommunytyType__c.contains('Participant')){
                                ParticipantDeduplicationController.checkPER(contactRecords[i].id, record);
								break;
							}else{
                             	processedDuplicate(contactRecords[i].id, record);  
								break;
						    }
                            
                        }else if(recordsContactCount == (i + 1)){
                            System.debug('New Records');
                            createNewRecords(record);
							break;
                        }
                    }else if(recordsContactCount == (i + 1)){
                         System.debug('New Records Done');
                         createNewRecords(record);
						 break;
                    }
                }
            }
        }else{
            System.debug('New Records Done');
            createNewRecords(record);
        }
        update contactRecords;
    }
    
    public static void createNewRecords(Integration_Patient_Referral__c record){
        System.debug('Create New Records');
        ParticipantDeduplicationController.checkPER(record);
    }
    
    public static void processedDuplicate(String contactId, Integration_Patient_Referral__c record){
        System.debug('Duplicate');
        List<Participant__c> listOfParticipants = new List<Participant__c>();
        listOfParticipants = [SELECT id FROM Participant__c WHERE Contact__c = :contactId];
        if(listOfParticipants.size() != 0){
        	ParticipantDeduplicationController.checkPER(contactId, listOfParticipants[0].id, record);
        }else{
            ParticipantDeduplicationController.checkPER(contactId, record);
        }
    }
}