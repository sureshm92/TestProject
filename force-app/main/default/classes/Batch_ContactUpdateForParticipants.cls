public without sharing class Batch_ContactUpdateForParticipants implements Database.Batchable<SObject>{
public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id,ContactId,Contact.userCommunityMode__c  From User where ContactId!=null and Contact.userCommunityMode__c ='Participant']
        );
    }
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<Id> conListId = New List<Id>();
        List<Contact> cList = New List<Contact>();
        List<Contact> lstContact = New List<Contact>();
        try{
            for(User u :  (List<User>) records){
                conListId.add(u.ContactId);
            }
            lstContact = [Select Id,Is_Patient_User_Created__c,userCommunytyType__c from Contact where Id IN:conListId];
            
            for(Contact c: lstContact ){ 
                  if(c.Is_Patient_User_Created__c == false){
                  cList.add(new Contact(Id = c.Id,Is_Patient_User_Created__c=true));}
            }
            if(cList.size() > 0)
            {
              update cList;
            }
        }
        catch (Exception e) {
            System.debug(e);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}