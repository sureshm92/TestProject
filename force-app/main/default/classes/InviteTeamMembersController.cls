/**
 * Created by D.Yasinskyi on 03.05.2018
 */
public without sharing class InviteTeamMembersController {


    //TODO DEPRECATED CLASS!!!
//    @AuraEnabled
//    public static Boolean addDelegateContact(String contact, String userMode) {
//
//        //email / (contactId) if has NO primary contact
//        Map<String, Id> duplicateEmails = new Map<String, Id>();
//        //valid(can be delegated) existing contacts by email
//        Map<String, Id> existingContactsByEmail = new Map<String, Id>();
//
//        Contact userContact = CommunityService.getUserContact();
//
//        List<Account> delegateAccount = [SELECT Id FROM Account WHERE Name = :CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME];
//        if (delegateAccount.isEmpty() || delegateAccount.size() > 1) {
//            System.debug('Error: NO or several Participant Account !!!!');
//            throw new AuraHandledException('Error: NO or several Delegate Account ! account.size=' + delegateAccount.size());
//        }
//        Contact newContact;
//        try {
//            newContact = (Contact) JSON.deserialize(contact, Contact.class);
//        } catch (Exception e) {
//            throw new AuraHandledException('Wrong data!');
//        }
//
//        duplicateEmails = getDuplicatedContactEmails(newContact);
//
//        if (!duplicateEmails.isEmpty()) {
//
//            for (String email : duplicateEmails.keySet()) {
//
//                if (duplicateEmails.get(email) != null) {
//                    existingContactsByEmail.put(email, duplicateEmails.get(email));
//                } else {
//                    //return new delegeat contact emails that duplicated(can`t be delegate)
//                    return false;
//                }
//            }
//        }
//
//        newContact.Id = existingContactsByEmail.get(newContact.Email);
//        newContact.primaryContact__c = userContact.Id;
//        newContact.AccountId = delegateAccount[0].Id;
//        newContact.userCommunytyType__c = userMode;
//        newContact.userCommunityMode__c = userMode;
//
//        try {
//            upsert newContact;
//            return true;
//        } catch (Exception e) {
//            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
//        }
//    }
//
//    private static Map<String, Id> getDuplicatedContactEmails(Contact contact) {
//
//        Map<String, Id> duplicateEmails = new Map<String, Id>();
//
//        for (Contact dupContact : [SELECT Id, Email, primaryContact__c, userCommunytyType__c, userCommunityMode__c FROM Contact WHERE Email = :contact.Email]) {
//
//            if (dupContact.userCommunytyType__c == null && dupContact.userCommunityMode__c == null && dupContact.primaryContact__c == null) {
//                duplicateEmails.put(dupContact.Email, dupContact.Id);
//            } else {
//                duplicateEmails.put(dupContact.Email, null);
//            }
//        }
//
//        return duplicateEmails;
//    }
}