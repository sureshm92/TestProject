/**
 * Created by Leonid Bartenev
 */

trigger UserProcess on User (after insert, after update) {
    List<Contact> contactsForUpdate = new List<Contact>();
    List<Contact> changeEmailContacts = new List<Contact>();
    for(User user : Trigger.new){
        if(user.ContactId == null) continue;
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(user.Id).LanguageLocaleKey != user.LanguageLocaleKey)){
            contactsForUpdate.add(new Contact(
                    Id = user.ContactId,
                    Language__c = user.LanguageLocaleKey
            ));
        }
        if(Trigger.isUpdate && Trigger.oldMap.get(user.Id).Email != user.Email){
            if(user.ContactId != null){
                changeEmailContacts.add(new Contact(
                        Id = user.ContactId,
                        Email = user.Email
                ));
            }
        }
    }
    update contactsForUpdate;
    update changeEmailContacts;
}