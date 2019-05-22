global class DelegateAddressesBatch implements Database.Batchable<sObject>, Database.Stateful{

   	global final String Query;
    global Map<Id,Id> mapDelegates;
    global List<Id> listOfContacts;
	global List<Id> rpContacts;
   
    global DelegateAddressesBatch(){
    	Query = 'SELECT id, Delegate_Level__c, HCP_Enrollment__r.HCP_Contact__c, Contact__c, Contact__r.MailingCity, Contact__r.MailingCountry, Contact__r.MailingState, Contact__r.MailingStreet, Contact__r.MailingPostalCode  FROM Referring_HCP_Staff__c'; 
   	}
    
   	global Database.QueryLocator start(Database.BatchableContext BC){
       mapDelegates = new Map<Id,Id>();
       listOfContacts = new List<Id>();
       return Database.getQueryLocator(query); 
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject item : scope){
            Referring_HCP_Staff__c element = (Referring_HCP_Staff__c)item;
            mapDelegates.put(element.Contact__c, element.HCP_Enrollment__r.HCP_Contact__c);
            listOfContacts.add(element.Contact__c);
            listOfContacts.add(element.HCP_Enrollment__r.HCP_Contact__c);
            
        }
        Map<Id, Contact> cons = new Map<Id, Contact>([
            SELECT	id,
            		MailingCity, 
            		MailingCountry, 
            		MailingState, 
            		MailingStreet,
            		MailingPostalCode
        	FROM	Contact
            WHERE	id IN :listOfContacts
        ]);
        for(Id delegateId : mapDelegates.keySet()){
            Contact delegate = cons.get(delegateId);
            Contact rpContact = cons.get(mapDelegates.get(delegateId));
            
            delegate.MailingCity = rpContact.MailingCity;
            delegate.MailingCountry = rpContact.MailingCountry;
            delegate.MailingState = rpContact.MailingState;
            delegate.MailingStreet = rpContact.MailingStreet;
            delegate.MailingPostalCode = rpContact.MailingPostalCode;
        }
        update cons.values();
        
    }
    
    

   	global void finish(Database.BatchableContext BC){
    }
}