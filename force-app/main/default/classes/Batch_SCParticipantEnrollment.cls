public without sharing class Batch_SCParticipantEnrollment implements Database.Batchable<sObject>, Database.Stateful {
    
    // Study closure Id(CTP Id)
    public Id studyClosureId;
    // Batch process for Study closure review or delete 
    public Boolean isStudyToDelete = false;
    
    // Study Closure Process Id
    private Id studyClosureProcessId;
    // participant contact Ids
    private Set<Id> participantContactIds = new Set<Id>();
    // patient delegate contact Ids
    private Set<Id> patientDelegateContactIds = new Set<Id>();
    // delete Participant Ids
    private Set<Id> participantIds = new Set<Id>();
    // delete Delegate Participant Ids
    private Set<Id> delegateParticipantIds = new Set<Id>();
    
    private Set<Id> participantEnrollmentIds = new Set<Id>();
    private Set<Id> participantComorbiditiesIds = new Set<Id>();
    private Set<Id> taskIds = new Set<Id>();
    private Set<Id> therapeuticAreaPatientIds = new Set<Id>();
    private Set<Id> participantNoteIds = new Set<Id>();
    private Set<Id> participantAttachmentIds = new Set<Id>();
    private Set<Id> participantDocumentIds = new Set<Id>();
    
    public class BatchControlException extends Exception{}
    
    // Query the Participant Enrollment related with the current CTP
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
         
        String query = 'SELECT Id, Participant__c FROM Participant_Enrollment__c ';
        if(String.isNotBlank(studyClosureId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :studyClosureId';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> records) {
        
        // Mapping of Participant and related contact Id
        Map<Id,Id> participantandContactIdsMap = new Map<Id,Id>();
        // Mapping of Delegate Participant and related contact Id
        Map<Id,Id> delparticipantandContactIdsMap = new Map<Id,Id>();
        
        // Collect the participant Ids from the Participant Enrollment
        Set<Id> allParticipantIds = getAllParticipantIds(records);
        // Check participant enrolled with any other CTP and collect the participant and delegate Ids
        checkParticipantEnrollment(
            studyClosureId, allParticipantIds, participantContactIds, patientDelegateContactIds, 
            participantIds, delegateParticipantIds, participantandContactIdsMap, delparticipantandContactIdsMap
        );
        // Check Participant delegate enrolled with any other CTP
        checkParticipantDelegateEnrollment(
            delegateParticipantIds, patientDelegateContactIds
        );
        // Check Participant and delegates enrolled as delegate for any other CTP participants
        checkParticipantRoles(
            studyClosureId, participantContactIds, patientDelegateContactIds, participantIds, delegateParticipantIds, 
            participantandContactIdsMap, delparticipantandContactIdsMap
        );
        // Check participant and delegate contacts has any roles
        // (PI, Site staff, CC staff, HCP, RP Delegate and Patient delegate) in any other CTP
        checkContactRoles(
            studyClosureId, participantContactIds, patientDelegateContactIds
        );
        // Delete the Participant and delegate related records
        // (Participant_Comorbidities, Task, Therapeutic_Area_Patient, Note, Attachment)
        deleteParticipantRelatedRecords(
            isStudyToDelete, participantIds, delegateParticipantIds, participantComorbiditiesIds, taskIds,
            therapeuticAreaPatientIds, participantNoteIds, participantAttachmentIds, participantDocumentIds
        );
        if(isStudyToDelete){
            // Delete all independent participant and delegate participant records
            deleteParticipants(participantIds, delegateParticipantIds);
        }
        // Delete all the Participant Enrollment records
        deleteParticipantEnrollments(isStudyToDelete, records, participantEnrollmentIds);
    }
    public void finish(Database.BatchableContext bc) {
    
        System.debug('participantContactIds -->'+participantContactIds);
        System.debug('patientDelegateContactIds -->'+patientDelegateContactIds);
        
        if(isStudyToDelete == false) {
            List<ContentVersion> contentVersions =new List<ContentVersion>();
            
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Enrollment', participantEnrollmentIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participants', participantIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Delegates', delegateParticipantIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Contact', participantContactIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Delegate Contact', patientDelegateContactIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Comorbidities', participantComorbiditiesIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Task', taskIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Therapeutic Area Patient', therapeuticAreaPatientIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Notes', participantNoteIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Attachments', participantAttachmentIds));
            contentVersions.add(constructCsvFile(studyClosureId, 'Participant Documents', participantDocumentIds));
            
            insertContentVersions(studyClosureProcessId, contentVersions);
        }
        
        /*Batch_SCStudySite studySiteBatch = new Batch_SCStudySite();
        studySiteBatch.studyClosureId = studyClosureId;
        studySiteBatch.participantContactIds = participantContactIds;
        studySiteBatch.patientDelegateContactIds = patientDelegateContactIds;
        studySiteBatch.isStudyToDelete = isStudyToDelete;
        Database.executeBatch(studySiteBatch); */
        
        Set<Id> studyContactIds = new Set<Id>(participantContactIds);
        studyContactIds.addAll(patientDelegateContactIds);
        
        Batch_SCDeactivateUser userBatch = new Batch_SCDeactivateUser();
        userBatch.studyClosureId = studyClosureId;
        userBatch.studyContactIds = studyContactIds;
        userBatch.isStudyToDelete = isStudyToDelete;
        userBatch.executeFromPEBatch = true;
        Database.executeBatch(userBatch); 
    }
    // Collect the participant Ids from the Participant Enrollment
    public static Set<Id> getAllParticipantIds(List<Participant_Enrollment__c> records) {

        Set<Id> parIds = new Set<Id>();
        for(Participant_Enrollment__c parEnrRec: records){
            parIds.add(parEnrRec.Participant__c);
        }
        return parIds;
    }
    // Check participant enrolled with any other CTP and collect the participant and delegate Ids
    public static void checkParticipantEnrollment(
        Id studyClosureId, Set<Id> parIds, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds, 
        Set<Id> participantIds, Set<Id> delegateParticipantIds, Map<Id,Id> participantandContactIdsMap, 
        Map<Id,Id> delparticipantandContactIdsMap
    ) {
        
        for(Participant__c pRec: [
            SELECT Id, Contact__c,
                (SELECT Id, Contact__c, Participant_Delegate__c 
                 FROM Participants__r),
                (SELECT Id 
                 FROM Participant_Profile__r 
                 WHERE Clinical_Trial_Profile__c != :studyClosureId) 
            FROM Participant__c 
            WHERE Id IN :parIds ]){
            
            if(pRec.Participant_Profile__r.isEmpty()){
            
                participantIds.add(pRec.Id);
                if(pRec.Contact__c != null) {
                    participantContactIds.add(pRec.Contact__c);
                    participantandContactIdsMap.put(pRec.Id, pRec.Contact__c);
                }
                
                for(Patient_Delegate__c delRec: pRec.Participants__r){
                    
                    if(delRec.Contact__c != null) {
                        patientDelegateContactIds.add(delRec.Contact__c);
                    }
                    if(delRec.Participant_Delegate__c != null) {
                        delegateParticipantIds.add(delRec.Participant_Delegate__c);
                        delparticipantandContactIdsMap.put(delRec.Participant_Delegate__c, delRec.Contact__c);
                    }
                }
            }
        }
    }
    // Check Participant delegate enrolled with any other CTP
    public static void checkParticipantDelegateEnrollment(
        Set<Id> delegateParticipantIds, Set<Id> patientDelegateContactIds    
    ) {
        
        for(Participant_Enrollment__c parEnrRec: [
            SELECT Id, Participant__c, Participant_Contact__c 
            FROM Participant_Enrollment__c 
            WHERE Participant_Contact__c IN :patientDelegateContactIds
        ]){
            
            if(patientDelegateContactIds.contains(parEnrRec.Participant_Contact__c)){
                patientDelegateContactIds.remove(parEnrRec.Participant_Contact__c);
                delegateParticipantIds.remove(parEnrRec.Participant__c);
            }
        }
    }
    // Check Participant and delegates enrolled as delegate for any other CTP participants
    public static void checkParticipantRoles(
        Id studyClosureId, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds, Set<Id> participantIds, 
        Set<Id> delegateParticipantIds, Map<Id,Id> participantandContactIdsMap, Map<Id,Id> delparticipantandContactIdsMap  
    ) {
        
        // Participant(p1) as delegate in another participant(p2)
        Set<Id> otherParticipantIds = new Set<Id>();
        Map<Id,Id> otherParticipantWithCurrentParticipant=new Map<Id,Id>();
        
        for(Patient_Delegate__c pdUser:[
            SELECT Id, Participant_Delegate__c,Participant__c 
            FROM Patient_Delegate__c 
            WHERE (Participant_Delegate__c IN :participantIds OR Participant_Delegate__c IN :delegateParticipantIds)
                AND (Participant__c NOT IN :participantIds OR Participant__c NOT IN :delegateParticipantIds) 
        ]){
            
           otherParticipantIds.add(pdUser.Participant__c);
           otherParticipantWithCurrentParticipant.put(pdUser.Participant__c,pdUser.Participant_Delegate__c);
        }
        for(Participant__c oPar: [
            SELECT Id,
                (SELECT Id 
                 FROM Participant_Profile__r 
                 WHERE Clinical_Trial_Profile__c != :studyClosureId) 
            FROM Participant__c 
            WHERE Id IN :otherParticipantIds ]){
            
            if(!oPar.Participant_Profile__r.isEmpty()){
            
                if(otherParticipantWithCurrentParticipant.containsKey(oPar.Id)){
                    
                    Id participantId = otherParticipantWithCurrentParticipant.get(oPar.Id);
                    
                    if(participantIds.contains(participantId)){
                    
                        participantIds.remove(participantId);
                        participantContactIds.remove(participantandContactIdsMap.get(participantId));
                    }
                    if(delegateParticipantIds.contains(participantId)){
                    
                        delegateParticipantIds.remove(participantId);
                        patientDelegateContactIds.remove(delparticipantandContactIdsMap.get(participantId));
                    }
                }
                
            }
        }
    }
    // Check participant and delegate contacts has any roles
    // (PI, Site staff, CC staff, HCP, RP Delegate and Patient delegate) in any other CTP
    public static void checkContactRoles(
        Id studyClosureId, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
        
        checkContactAsPI(studyClosureId, participantContactIds, patientDelegateContactIds);
        checkContactAsSiteStaff(studyClosureId, participantContactIds, patientDelegateContactIds);
        checkContactAsCCStaff(participantContactIds, patientDelegateContactIds);
        checkContactAsRPDelegate(participantContactIds, patientDelegateContactIds);
        checkContactAsHCP(studyClosureId, participantContactIds, patientDelegateContactIds);
    }
    
    public static void checkContactAsPI(
        Id studyClosureId, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
    
        if(participantContactIds.isEmpty() == false) {
        
            For(Study_Site__c piUser:[
                SELECT Id, Principal_Investigator__c 
                FROM Study_Site__c 
                WHERE (Principal_Investigator__c IN :participantContactIds OR Principal_Investigator__c IN :patientDelegateContactIds)
                    AND Clinical_Trial_Profile__c != :studyClosureId
            ]){
            
                if(participantContactIds.contains(piUser.Principal_Investigator__c)){
                    participantContactIds.remove(piUser.Principal_Investigator__c);
                }
                if(patientDelegateContactIds.contains(piUser.Principal_Investigator__c)){
                    patientDelegateContactIds.remove(piUser.Principal_Investigator__c);
                }
            }
        }
    }
     
    public static void checkContactAsSiteStaff(
        Id studyClosureId, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
    
        if(participantContactIds.isEmpty() == false) {
        
            for(Site_Staff__c ssorRPUser:[
                SELECT Id, Site_Contact__c 
                FROM Site_Staff__c 
                WHERE (Site_Contact__c IN :participantContactIds OR Site_Contact__c IN :patientDelegateContactIds)
                    AND Study_Site__r.Clinical_Trial_Profile__c != :studyClosureId 
            ]){
                if(participantContactIds.contains(ssorRPUser.Site_Contact__c)){
                    participantContactIds.remove(ssorRPUser.Site_Contact__c);
                }
                if(patientDelegateContactIds.contains(ssorRPUser.Site_Contact__c)){
                    patientDelegateContactIds.remove(ssorRPUser.Site_Contact__c);
                }
            }
        }
    }
    
    public static void checkContactAsCCStaff(
        Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
        
        if(participantContactIds.isEmpty() == false) {
        
            for(CC_Staff__c ccUser:[
                SELECT Id, Contact__c 
                FROM CC_Staff__c 
                WHERE Contact__c IN :participantContactIds OR Contact__c IN :patientDelegateContactIds 
            ]){
                
                if(participantContactIds.contains(ccUser.Contact__c)){
                    participantContactIds.remove(ccUser.Contact__c);
                }
                if(patientDelegateContactIds.contains(ccUser.Contact__c)){
                    patientDelegateContactIds.remove(ccUser.Contact__c);
                }
            }
        }
    }
    
    public static void checkContactAsRPDelegate(
        Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
    
        if(participantContactIds.isEmpty() == false) {
        
            for(RP_Delegate_Relationship__c pdUser:[
                SELECT Id, Delegate__c 
                FROM RP_Delegate_Relationship__c 
                WHERE Delegate__c IN :participantContactIds OR Delegate__c IN :patientDelegateContactIds 
            ]){
                
                if(participantContactIds.contains(pdUser.Delegate__c)){
                    participantContactIds.remove(pdUser.Delegate__c);
                }
                if(patientDelegateContactIds.contains(pdUser.Delegate__c)){
                    patientDelegateContactIds.remove(pdUser.Delegate__c);
                }
            }
        }
    }
    
    public static void checkContactAsHCP(
        Id studyClosureId, Set<Id> participantContactIds, Set<Id> patientDelegateContactIds
    ) {
        
        if(participantContactIds.isEmpty() == false) {
        
            for(HCP_Enrollment__c hcpEnroll:[
                SELECT Id, HCP_Contact__c 
                FROM HCP_Enrollment__c 
                WHERE (HCP_Contact__c IN :participantContactIds OR HCP_Contact__c IN :patientDelegateContactIds)
                    AND Clinical_Trial_Profile__c != :studyClosureId 
            ]){
                
                if(participantContactIds.contains(hcpEnroll.HCP_Contact__c)){
                    participantContactIds.remove(hcpEnroll.HCP_Contact__c);
                }
                if(patientDelegateContactIds.contains(hcpEnroll.HCP_Contact__c)){
                    patientDelegateContactIds.remove(hcpEnroll.HCP_Contact__c);
                }
            }
        }
    }
    // Delete the Participant and delegate related records
    // (Participant_Comorbidities, Task, Therapeutic_Area_Patient, Note, Attachment)
    public static void deleteParticipantRelatedRecords(
        Boolean isStudyToDelete, Set<Id> participantIds, Set<Id> delegateParticipantIds, 
        Set<Id> participantComorbiditiesIds, Set<Id> taskIds, Set<Id> therapeuticAreaPatientIds, 
        Set<Id> participantNoteIds, Set<Id> participantAttachmentIds, Set<Id> participantDocumentIds
    ) {

        /* Delete Participant related Participant_Comorbidities, Task and Therapeutic_Area_Patient records */
        if(participantIds.isEmpty() == false) {
            
            if(isStudyToDelete) {
                delete [
                    SELECT Id 
                    FROM Participant_Comorbidities__c 
                    WHERE Participant__c IN :participantIds OR Participant__c IN :delegateParticipantIds limit 9999
                ];
                
                delete [
                    SELECT Id 
                    FROM Task 
                    WHERE whatId IN :participantIds OR whatId IN :delegateParticipantIds limit 9999
                ];
                
                delete [
                    SELECT Id 
                    FROM Therapeutic_Area_Patient__c 
                    WHERE Participant__c IN :participantIds OR Participant__c IN :delegateParticipantIds limit 9999
                ];
                
                delete [
                    SELECT Id 
                    FROM Note 
                    WHERE ParentId IN :participantIds OR ParentId IN :delegateParticipantIds limit 9999
                ];
                
                delete [
                    SELECT Id 
                    FROM Attachment 
                    WHERE ParentId IN :participantIds OR ParentId IN :delegateParticipantIds limit 9999
                ];
                
                delete [
                    SELECT Id 
                    FROM ContentDocument 
                    WHERE ParentId IN :participantIds OR ParentId IN :delegateParticipantIds limit 9999
                ];
                
            } else {
                
                participantComorbiditiesIds.addAll((new Map<Id,Participant_Comorbidities__c>([
                        SELECT Id 
                        FROM Participant_Comorbidities__c 
                        WHERE (Participant__c IN :participantIds OR Participant__c IN :delegateParticipantIds) AND ID NOT IN :participantComorbiditiesIds limit 49999
                ])).keySet());
                
                taskIds.addAll((new Map<Id,Task>([
                        SELECT Id 
                        FROM Task 
                        WHERE (whatId IN :participantIds OR whatId IN :delegateParticipantIds) AND ID NOT IN :taskIds limit 49999
                ])).keySet());
                
                therapeuticAreaPatientIds.addAll((new Map<Id,Therapeutic_Area_Patient__c>([
                        SELECT Id 
                        FROM Therapeutic_Area_Patient__c 
                        WHERE (Participant__c IN :participantIds OR Participant__c IN :delegateParticipantIds) AND ID NOT IN :therapeuticAreaPatientIds limit 49999
                ])).keySet());
                
                participantNoteIds.addAll((new Map<Id,Note>([
                        SELECT Id 
                        FROM Note 
                        WHERE (ParentId IN :participantIds OR ParentId IN :delegateParticipantIds) AND ID NOT IN :participantNoteIds limit 49999
                ])).keySet());
                
                participantAttachmentIds.addAll((new Map<Id,Attachment>([
                        SELECT Id 
                        FROM Attachment 
                        WHERE (ParentId IN :participantIds OR ParentId IN :delegateParticipantIds) AND ID NOT IN :participantAttachmentIds limit 49999
                ])).keySet());
                
                participantDocumentIds.addAll((new Map<Id, ContentDocument>([
                        SELECT Id 
                        FROM ContentDocument 
                        WHERE (ParentId IN :participantIds OR ParentId IN :delegateParticipantIds) AND ID NOT IN :participantDocumentIds limit 49999
                ])).keySet());
            }
        }
    }
    // Delete all the Participant Enrollment records
    public static void deleteParticipantEnrollments(
        Boolean isStudyToDelete, List<Participant_Enrollment__c> records, Set<Id> participantEnrollmentIds
    ) {
        
        if(isStudyToDelete) {
            delete records;
        } else {
            participantEnrollmentIds.addAll((new Map<Id,Participant_Enrollment__c>(records)).keySet());
        }
        System.debug('Participant_Enrollment -->'+records);
    }
    // Delete all independent participant and delegate participant records
    public static void deleteParticipants(Set<Id> participantIds, Set<Id> delegateParticipantIds) {

        if(participantIds.isEmpty() == false) {
            
            /*Set<Id> deleteParticipantIds = new Set<Id>(participantIds);
            deleteParticipantIds.addAll(delegateParticipantIds);
            List<Participant__c> deleteparticipantList = new List<Participant__c>();
            
            for(Id participantId : deleteParticipantIds) {
                
                deleteparticipantList.add(new Participant__c(Id = participantId));
            }*/
            delete [SELECT Id FROM Participant__c WHERE Id IN :participantIds OR Id IN :delegateParticipantIds];
            
            //System.debug('deleteparticipantList -->'+deleteparticipantList);
        }
    }
    //
    public static ContentVersion constructCsvFile(Id studyClosureId, String objectName, Set<Id> recordIds) {
    
        ContentVersion versionRec = new ContentVersion();
        versionRec.Title = objectName + '_' + recordIds.size(); 
        versionRec.PathOnClient = objectName + '_' + recordIds.size() + '.csv'; 
        versionRec.VersionData = Blob.valueOf(constructFileData(recordIds)); 
        versionRec.IsMajorVersion = true;
        return versionRec;
    }
    
    public static String constructFileData(Set<Id> recordIds) {
    
        String concantenatedStr = 'Id'+ '\n';
        concantenatedStr += String.join(new List<Id>(recordIds), '\n');
        return concantenatedStr;
    }
    
    public static void insertContentVersions(Id studyClosureId, List<ContentVersion> versionRecords) {
        
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class, TriggerOperation.AFTER_INSERT
        );
        
        insert versionRecords;

        List<ContentDocumentLink> contentDocumentLink = new List<ContentDocumentLink>();        
        for(ContentVersion versionRec : [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :versionRecords
        ]) {
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = studyClosureId;
            cdl.ContentDocumentId = versionRec.ContentDocumentId;
            cdl.shareType = 'V';
            contentDocumentLink.add(cdl);
        }
        
        insert contentDocumentLink;
        System.debug('contentDocumentLink -->'+contentDocumentLink);
    }
}