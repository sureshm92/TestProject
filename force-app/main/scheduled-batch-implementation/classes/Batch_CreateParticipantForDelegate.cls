/**
 * Created by Olga Skrynnikova on 4/16/2020.
 */

public without sharing class Batch_CreateParticipantForDelegate implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Contact__c,
                        Participant__c
                FROM Patient_Delegate__c
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Patient_Delegate__c> patientDelegates) {
        List<Id> delegateConList = new List<Id>();
        for(Patient_Delegate__c pd: patientDelegates) if (!delegateConList.contains(pd.Contact__c)) delegateConList.add(pd.Contact__c);

        List<Participant__c> delegateWithParticipant = [SELECT Id, Contact__c FROM Participant__c WHERE Contact__c IN: delegateConList];
        System.debug('>>>delegateWithParticipant' + delegateWithParticipant);
        List<Id> delegateConIdsWithParticipants = new List<Id>();
        for(Participant__c p: delegateWithParticipant) if (p.Contact__c != null && !delegateConIdsWithParticipants.contains(p.Contact__c)) delegateConIdsWithParticipants.add(p.Contact__c);
        List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Phone, Email, MailingCity, MailingCountryCode, MailingStateCode
                FROM Contact
                WHERE Id IN:delegateConList
        ];
        System.debug('>>>contacts' + contacts);

        List<Participant__c> participantsForInsert = new List<Participant__c>();
        for (Contact contact : contacts) {

            if (!delegateConIdsWithParticipants.contains(contact.Id)) {
                participantsForInsert.add(new Participant__c(
                        Contact__c = contact.Id,
                        First_Name__c = contact.FirstName,
                        Last_Name__c = contact.LastName,
                        Email__c = contact.Email,
                        Phone__c = contact.Phone,
                        Mailing_City__c = contact.MailingCity,
                        Mailing_Country_Code__c = contact.MailingCountryCode,
                        Mailing_State_Code__c = contact.MailingStateCode

                ));
            }
        }
        System.debug('>>>participantsForInsert' + participantsForInsert);
        if (participantsForInsert.size() > 0) insert participantsForInsert;
    }
    public void finish(Database.BatchableContext param1) {
    }

}