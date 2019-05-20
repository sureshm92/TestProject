global class UpdateDelegatesBatch implements Database.Batchable<sObject>, Database.Stateful{

   	global final String Query;
    global List<Referring_HCP_Staff__c> listOfReferringStaff;
	global List<Id> rpContacts;
   
    global UpdateDelegatesBatch(){
    	Query = 'SELECT id, userCommunytyType__c, (SELECT id, Delegate_Level__c FROM Referring_HCP_Staffs__r), LastName FROM Contact'; 
   	}
    
   	global Database.QueryLocator start(Database.BatchableContext BC){
       	listOfReferringStaff = new List<Referring_HCP_Staff__c>();
        rpContacts = new List<Id>();
  		return Database.getQueryLocator(query);
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
       	listOfReferringStaff = new List<Referring_HCP_Staff__c>();
     	for(sObject s : scope){
            Contact contactRecords = (Contact)s;
            Boolean isDelegate = iterateStaff(contactRecords.Referring_HCP_Staffs__r);
            if(isDelegate && contactRecords.userCommunytyType__c != null && contactRecords.userCommunytyType__c.contains('HCP')){
                rpContacts.add(contactRecords.id);
            }
            
     	}
        update listOfReferringStaff;
     	
    }
    
    global boolean iterateStaff(List<Referring_HCP_Staff__c> staffs){
        String highLevel = '';
        if(staffs != null && staffs.size() != 0){
        	for(Referring_HCP_Staff__c item : staffs){
                highLevel = (highLevel == '' || highLevel == 'Level 2') ? item.Delegate_Level__c : highLevel;
                if(highLevel == 'Level 1'){
                    break;
                }
            }
            for(Referring_HCP_Staff__c item : staffs){
                item.Delegate_Level__c = highLevel;
            }
            listOfReferringStaff.addAll(staffs);
          	return true;
        }
        return false; 
        
    }
    
    global void  sendingEmail() {
		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
		String[] sendingTo = new String[]{'R&DSReferralHubSupport@quintiles.com'};
		semail.setToAddresses(sendingTo);
		String[] sendingTocAdd = new String[]{'Olena.Usoltseva@highpointsolutions.com', 'mikhail.pochkin@highpointsolutions.com', 'diana.antonyan@highpointsolutions.com'};
		semail.setCcAddresses(sendingTocAdd);
		semail.setSubject('RP Delegates');
		semail.setPlainTextBody('List of Ids RP Delegates' + JSON.serialize(rpContacts));
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
	}

   	global void finish(Database.BatchableContext BC){
        sendingEmail();
    }
}