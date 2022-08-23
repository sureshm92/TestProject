public without sharing class Batch_SCDeleteContact implements Database.Batchable<sObject>, Database.Stateful {

    // Study closure Id(CTP Id)
    public Id studyClosureId;
    // Study related contact Ids(Patient, Patient Delegate, Site PI, Site staff)
    public Set<Id> studyContactIds = new Set<Id>();
    // Batch process for Study closure review or delete 
    public Boolean isStudyToDelete = false;
    // Batch executed from the Participant enrollment/Studysite 
    public Boolean executeFromPEBatch = false;
    
    // Study Closure Process Id
    private Id studyClosureProcessId;
    public class BatchControlException extends Exception{}
    private Set<Id> alertIds = new Set<Id>();
    private Set<Id> notificationIds = new Set<Id>();
    private Set<Id> caseIds = new Set<Id>();
    private Set<Id> contactNotesIds = new Set<Id>();
    private Set<Id> contactAttachmentIds = new Set<Id>();
    private Set<Id> emailMessageIds = new Set<Id>();
    private Set<Id> documentIds = new Set<Id>();
    
    // Query the study site related with the current CTP
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        if(isStudyToDelete == false && String.isNotBlank(studyClosureId)) {
            
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :studyClosureId LIMIT 1
            ];
            
            if(studyClosureProcessList.isEmpty() == false) {
                
                studyClosureProcessId = studyClosureProcessList[0].Id;
            } else {
                throw new BatchControlException('Please check the studyClosureId and created studyClosure record.');
            }
        }   
        
        String query = 'SELECT Id FROM Contact WHERE Id IN :studyContactIds';
        return Database.getQueryLocator(query);
    }
    // Check the study site related contact(PI and site staff) roles and initiate delete independant contcat records
    public void execute(Database.BatchableContext bc, List<Contact> records) {
        
        // Delete the Contact related records
        // (Alert, Task, Notification, Case, EmailMessage, Note, Attachment)
        deleteContactRelatedRecords(
            isStudyToDelete, records, alertIds, notificationIds, caseIds, contactNotesIds, 
            contactAttachmentIds, emailMessageIds, documentIds
        );
        // Delete all independent contact records
        deleteContacts(isStudyToDelete, records);
    }
    public void finish(Database.BatchableContext bc) {
    
        System.debug('studyContactIds -->'+studyContactIds);
        if(isStudyToDelete == false) {
            
            List<ContentVersion> contentVersions =new List<ContentVersion>();
            
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Alerts', alertIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Notifications', notificationIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Cases', caseIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Notes', contactNotesIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Attachments', contactAttachmentIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Email messages', emailMessageIds
            ));
            contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                studyClosureId, (executeFromPEBatch ? 'PE-' : 'SS-') + 'Contact Content Documents', documentIds
            ));
            Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessId, contentVersions);
        }
    }
    // Delete the Contact related records
    // (Alert, Task, Notification, Case, EmailMessage, Note, Attachment)
    public static void deleteContactRelatedRecords(
        Boolean isStudyToDelete, List<Contact> contactRecords, Set<Id> alertIds, Set<Id> notificationIds, 
        Set<Id> caseIds, Set<Id> contactNotesIds, Set<Id> contactAttachmentIds, Set<Id> emailMessageIds,
        Set<Id> documentIds
    ) {
            
        if(contactRecords.isEmpty() == false) {
            
            Set<Id> contactIds = (new Map<Id,Contact>(contactRecords)).keySet();
            
            if(isStudyToDelete) {
            
                delete [ SELECT Id FROM Alert__c WHERE Contact__c IN :contactRecords];
                
                delete [SELECT Id FROM Notification__c WHERE Recipient__c IN :contactRecords];
                
                delete [SELECT Id FROM Case WHERE ContactId IN :contactRecords];
                
                delete [SELECT Id FROM Note WHERE ParentId IN :contactRecords];
                
                delete [SELECT Id FROM Attachment WHERE ParentId IN :contactRecords];
                
                delete [SELECT Id FROM EmailMessage WHERE RelatedToId IN :contactIds];
                
                delete [SELECT Id FROM ContentDocument WHERE ParentId IN :contactIds];
                
            } else {
                
                alertIds.addAll((new Map<Id,Alert__c>([
                    SELECT Id FROM Alert__c WHERE Contact__c IN :contactRecords
                ])).keySet());
                
                notificationIds.addAll((new Map<Id,Notification__c>([
                    SELECT Id FROM Notification__c WHERE Recipient__c IN :contactRecords
                ])).keySet());
                
                caseIds.addAll((new Map<Id,Case>([
                    SELECT Id FROM Case WHERE ContactId IN :contactRecords
                ])).keySet());
                
                contactNotesIds.addAll((new Map<Id,Note>([
                    SELECT Id FROM Note WHERE ParentId IN :contactRecords
                ])).keySet());
                
                contactAttachmentIds.addAll((new Map<Id,Attachment>([
                    SELECT Id FROM Attachment WHERE ParentId IN :contactRecords
                ])).keySet());
                
                emailMessageIds.addAll((new Map<Id,EmailMessage>([
                    SELECT Id FROM EmailMessage WHERE RelatedToId IN :contactIds
                ])).keySet());
                
                documentIds.addAll((new Map<Id,ContentDocument>([
                    SELECT Id FROM ContentDocument WHERE ParentId IN :contactIds
                ])).keySet());
            }
            
        }
    }
    
    // Delete all independent contact records
    public static void deleteContacts(Boolean isStudyToDelete, List<Contact> records) {
        
        if(isStudyToDelete && Test.isRunningTest() == false) {
            delete records;
            System.debug('Contacts list -->'+records);
        }
    }
}