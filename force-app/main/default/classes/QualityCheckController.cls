public class QualityCheckController {
    
    public static void checkStagingRecord(Integration_Patient_Referral__c record){
        System.debug('CheckRecord');
        String validationMessage = '';
		String requiredFieldMessages = checkRequiredFields(record);
		String checkStudyMessages = checkStudyId(record);
		String checkStudySiteMessages = checkStudySiteId(record);
        if(requiredFieldMessages != ''){
            validationMessage += requiredFieldMessages;
        }
        if(checkEmail(record)){
            validationMessage += 'Incorrect Email;';
        }
        if(checkStudyMessages != ''){
            validationMessage += checkStudyMessages;
        }
        if(checkStudySiteMessages != ''){
            validationMessage += checkStudySiteMessages;
        }
        if(validationMessage != ''){
            throw new PatientIntegrationException(validationMessage);
        }else{
            System.debug('Finish CheckRecord');
            DuplicateContactController.checkDuplicates(record);
        }
    }
    
    private static String checkRequiredFields(Integration_Patient_Referral__c record){
        String validationMessage = '';
        if(record.siteSelected__c == null || record.siteSelected__c == ''){
            validationMessage += 'Required field is missing: siteSelected;';   
        }
        if(record.protocolId__c == null || record.protocolId__c == ''){
			validationMessage += 'Required field is missing: protocolId;';   
        }
        if(record.firstName__c == null || record.firstName__c == ''){
            validationMessage += 'Required field is missing: firstName__c;';
        }
        if(record.lastName__c == null || record.lastName__c == ''){
            validationMessage += 'Required field is missing: lastName__c;';
        }
        if((record.email__c == null || record.email__c == '') && (record.phone__c == null || record.phone__c == '')){
            validationMessage += 'Either email or phone number must be provided;';
        }
        return validationMessage;
        
    }
    
    private static Boolean checkEmail(Integration_Patient_Referral__c record){
        return false;
    }
    
    private static String checkStudyId(Integration_Patient_Referral__c record){
        List<Clinical_Trial_Profile__c> checkRecords = new List<Clinical_Trial_Profile__c>();
        checkRecords = [
            SELECT	id,
					Override_Recruitment_Status__c
            FROM	Clinical_Trial_Profile__c
            WHERE 	Protocol_Id__c = :record.protocolId__c
        ];
        if(checkRecords.size() == 0){
            return 'Study: ' + record.protocolId__c +  ' not found;';
        }else if(checkRecords[0].Override_Recruitment_Status__c != 'Actively Enrolling'){
			return 'Study is not accepting referrals;';
		}  
         return '';
    }
    
    private static String checkStudySiteId(Integration_Patient_Referral__c record){
       String studySiteNumber = record.protocolId__c + '_' + record.siteSelected__c;
       List<Study_Site__c> checkRecords = new List<Study_Site__c>();
        checkRecords = [
            SELECT	id,
					Override_PI_Referral_Status__c
            FROM	Study_Site__c
            WHERE 	Primary_Key_ePR__c  = :studySiteNumber
        ];
        if(checkRecords.size() == 0){
            return 'Study Site: ' + studySiteNumber + ' not found;';
        }else if(   checkRecords[0].Override_PI_Referral_Status__c != 'Accepted' && 
                    checkRecords[0].Override_PI_Referral_Status__c != 'Invitation Sent' && 
                    checkRecords[0].Override_PI_Referral_Status__c != 'Accepted (Admin)'
                ){
			return 'StudySite is not accepting referrals;';
		}
        return '';
    }
    
    

}