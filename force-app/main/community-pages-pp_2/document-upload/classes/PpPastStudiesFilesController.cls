public with sharing class PpPastStudiesFilesController {
    public PpPastStudiesFilesController() {
    }
    @AuraEnabled
    public static pastStudyFileWrapper getData(Id contID, Boolean isDelegate) {
        Set<id> perIDs = new Set<id>();
        Set<id> studyIDs = new Set<id>();
        String getUserContact = UserContext.getUserContactId();
        List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
        set<Id> setPrimaryPER = new set<Id> ();
        pastStudyFileWrapper wrap = new pastStudyFileWrapper();
        List<Participant_Enrollment__c> alumiPerList =  new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__c> PrimaryalumniPERList = new List<Participant_Enrollment__c> ();

        for(Participant_Enrollment__c objPER :  [
            SELECT
                id,
                Participant_Status__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_ALUMNI
                AND Participant_Contact__c = :contID
            LIMIT 10000
        ])
        {
            perIDs.add(objPER.id);
            studyIDs.add(objPER.Clinical_Trial_Profile__c);
            alumiPerList.add(objPER);
        }
       
        //logged in contact ka per alumi more thn 1 meaning ki multiple studies alumi hai.

        if (isDelegate) {
            for(Patient_Delegate_Enrollment__c objPDER : [SELECT id, Participant_Enrollment__c
            FROM Patient_Delegate_Enrollment__c
            WHERE
                Participant_Enrollment__c IN :perIDs
                AND Patient_Delegate__r.Contact__c = :getUserContact
                AND Primary_Delegate__c = TRUE
            LIMIT 10000])
            {
                setPrimaryPER.add(objPDER.Participant_Enrollment__c);
                pder.add(objPDER);

            } 

            for(Participant_Enrollment__c objPER : alumiPerList)
            {
                if(setPrimaryPER.contains(objPER.Id))
                {
                    PrimaryalumniPERList.add(objPER);
                }

            } 
             
        }


        List<ContentDocumentLink> getFiles = new List<ContentDocumentLink> ();
        wrap.fileList = getFiles;
        wrap.perList = isDelegate ? PrimaryalumniPERList : alumiPerList  ;
        if (!pder.isEmpty()) {
            wrap.isPrimary = true;
        }
        //wrap.isPrimary=getFiles;
        return wrap;
    }

    public class pastStudyFileWrapper {
        @AuraEnabled
        public Boolean isPrimary = false;
        @AuraEnabled
        public List<ContentDocumentLink> fileList = new List<ContentDocumentLink>();
        @AuraEnabled
        public List<Clinical_Trial_Profile__c> alumiStudy = new List<Clinical_Trial_Profile__c>();
        @AuraEnabled
        public List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
    }
}
