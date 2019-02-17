/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantTriggerHandler {
    
    public static void createContactsForParticipantsBeforeInsert(){
        if(Trigger.isBefore && Trigger.isInsert){
            List<Participant__c> participants = (List<Participant__c>)Trigger.new;
            Id participantAccountId = getParticipantAccountId();
            Map<String, Participant__c> participantsByEmail = new Map<String, Participant__c>();
            List<Contact> contactsToInsert = new List<Contact>();
    
            List<String> emails = new List<String>();
            for(Participant__c participant : participants){
                if(participant.Contact__c == null && participant.Email__c != null){
                    emails.add(participant.Email__c);
                    Contact newContact = new Contact();
                    newContact.LastName = participant.Last_Name__c;
                    newContact.Email = participant.Email__c;
                    newContact.AccountId = participantAccountId;
                    newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                    newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
                    contactsToInsert.add(newContact);
                    participantsByEmail.put(participant.Email__c, participant);
        
                }
            }
            System.debug('CONTACTS TO INSERT: ' + contactsToInsert);
            insert contactsToInsert;
    
            for(Contact newContact : contactsToInsert){
                Participant__c participant = participantsByEmail.get(newContact.Email);
                if(participant != null) participant.Contact__c = newContact.Id;
            }
        }
    }
    
    public static void updatePEAndContactLastNameAfterInsert(){
        if(Trigger.isAfter && Trigger.isInsert){
            List<Contact> contacts = new List<Contact>();
            for(Participant__c participant : (List<Participant__c>)Trigger.new){
                contacts.add(new Contact(
                        Id = participant.Contact__c,
                        LastName = participant.Name
                ));
            }
            update contacts;
            update [SELECT Id FROM Participant_Enrollment__c WHERE Participant__c IN: Trigger.newMap.keySet()];
        }
    }
    
    public static void changeUserEmailOnParticipantEmailChange(){
        if(Trigger.isAfter && Trigger.isUpdate){
            List<Participant__c> participants = (List<Participant__c>)Trigger.new;
            Set<Id> contactIds = new Set<Id>();
            for(Participant__c participant : participants) {
                if(participant.Contact__c != null) contactIds.add(participant.Contact__c);
            }
            List<User> users = [SELECT Id, ContactId, Email FROM User WHERE ContactId IN: contactIds];
            Map<Id, User> usersByContactIdMap = new Map<Id, User>();
            for(User user : users){
                usersByContactIdMap.put(user.ContactId, user);
            }
            List<User> usersForUpdate = new List<User>();
            for(Participant__c participant : participants){
                Participant__c oldParticipant = (Participant__c)Trigger.oldMap.get(participant.Id);
                if(oldParticipant.Email__c != participant.Email__c && Participant__c.Contact__c != null){
                    User user = usersByContactIdMap.get(participant.Contact__c);
                    if(user != null){
                        user.Email = participant.Email__c;
                        usersForUpdate.add(user);
                    }
                }
            }
            update usersForUpdate;
        }
    }
    
    
    public static void prepareCityStateFieldsBeforeInsertOrUpdate(){
        if(Trigger.isBefore){
            List<Participant__c> newList = (List<Participant__c>)Trigger.new;
            for(Participant__c participant : newList){
        
                String countryName = participant.Mailing_Country__c;
                String countryCode = participant.Mailing_Country_Code__c;
                String stateName = participant.Mailing_State__c;
                String stateCode = participant.Mailing_State_Code__c;
        
                if(Trigger.isInsert){
            
                    if(countryCode == null && countryName != null){
                        participant.Mailing_Country_Code__c = CountryStateUtil.getCountryCode(countryName);
                        if(participant.Mailing_Country_Code__c == null){
                            participant.addError('Invalid Country');
                        }
                    }else if (countryCode != null && countryName == null){
                        participant.Mailing_Country__c = CountryStateUtil.getCountryName(countryCode);
                        if(participant.Mailing_Country__c == null){
                            participant.addError('Invalid Country Code');
                        }
                    }else if (countryCode != null && countryName != null){
                        if(countryCode != CountryStateUtil.getCountryCode(countryName)){
                            participant.addError('Invalid County and Country Code');
                        }
                    }
                    if(stateCode == null && stateName != null){
                        participant.Mailing_State_Code__c = CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName);
                        if(participant.Mailing_State_Code__c == null){
                            participant.addError('Invalid State Province');
                        }
                    }else if (stateCode != null && stateName == null){
                        participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, stateCode);
                        if(participant.Mailing_State__c == null){
                            participant.addError('Invalid State Province Code');
                        }
                    }else if (stateCode != null && stateName != null){
                        if(stateCode != CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName)){
                            participant.addError('Invalid State Province and State Province Code');
                        }
                    }
                }
                if(Trigger.isUpdate){
                    Map<Id, Participant__c> oldMap = (Map<Id, Participant__c>)Trigger.oldMap;
                    Map<Id, Participant__c> newMap = (Map<Id, Participant__c>)Trigger.newMap;
                    Boolean countryNameChanged = oldMap.get(participant.Id).Mailing_Country__c != countryName;
                    Boolean countryCodeChanged = oldMap.get(participant.Id).Mailing_Country_Code__c != countryCode;
                    Boolean stateNameChanged = oldMap.get(participant.Id).Mailing_State__c != stateName;
                    Boolean stateCodeChanged = oldMap.get(participant.Id).Mailing_State_Code__c != stateCode;
            
                    if(countryCodeChanged && !countryNameChanged){
                        participant.Mailing_Country__c = CountryStateUtil.getCountryName(countryCode);
                        if(participant.Mailing_Country__c == null && countryCode != null){
                            participant.addError('Invalid Country Code');
                        }
                    }else if(!countryCodeChanged && countryNameChanged){
                        participant.Mailing_Country_Code__c = CountryStateUtil.getCountryCode(countryName);
                        if(participant.Mailing_Country_Code__c == null && countryName != null){
                            participant.addError('Invalid Country');
                        }
                    }else if(countryCodeChanged && countryNameChanged){
                        if(countryCode != CountryStateUtil.getCountryCode(countryName)){
                            participant.addError('Invalid County and Country Code');
                        }
                    }
            
                    if(stateCodeChanged && !stateNameChanged){
                        participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, stateCode);
                        if(participant.Mailing_State__c == null && stateCode != null){
                            participant.addError('Invalid State Province Code');
                        }
                    }else if(!stateCodeChanged && stateNameChanged){
                        participant.Mailing_State_Code__c = CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName);
                        if(participant.Mailing_State_Code__c == null && stateName != null){
                            participant.addError('Invalid State Province');
                        }
                    }else if(stateCodeChanged && stateNameChanged){
                        if(stateCode != CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName)){
                            participant.addError('Invalid State Province and State Province Code');
                        }
                    }
        
                }
            }
        }
    }
    
    
    private static Id getParticipantAccountId(){
        return [
                SELECT Id
                FROM Account
                WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME LIMIT 1
        ].Id ;
    }
    
    
    

}