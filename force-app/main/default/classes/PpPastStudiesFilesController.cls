public with sharing class PpPastStudiesFilesController {
    public PpPastStudiesFilesController() {

    }
        @AuraEnabled                            
        public static pastStudyFileWrapper getData(Id contID, Boolean isDelegate){
                Set<id> perIDs= new Set<id>();
                Set<id> studyIDs= new Set<id>();
                String getUserContact=UserContext.getUserContactId();
                List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c> ();
                pastStudyFileWrapper wrap = new pastStudyFileWrapper();

                List<Participant_Enrollment__c> alumiPerList= [ SELECT id, Participant_Status__c ,
                                    Clinical_Trial_Profile__c, 
                                    Clinical_Trial_Profile__r.Study_Code_Name__c
                                    FROM Participant_Enrollment__c 
                                   WHERE Participant_Status__c IN: PEStatusState.PE_STATUS_GROUP_ALUMNI
                                   AND Participant_Contact__c =: contID LIMIT 10000];
                //logged in contact ka per alumi more thn 1 meaning ki multiple studies alumi hai.
                
                for( Participant_Enrollment__c per : alumiPerList){
                    perIDs.add(per.id);
                    studyIDs.add(per.Clinical_Trial_Profile__c);
                }
                if(isDelegate){
                     pder= [SELECT id, Participant_Enrollment__c FROM Patient_Delegate_Enrollment__c
                                        WHERE Participant_Enrollment__c IN : perIDs
                                        AND Participant_Enrollment__r.Participant_Contact__c =: contID 
                                        AND Primary_Delegate__c =TRUE 
                                         LIMIT 10000 ];
                }

                List<ContentDocumentLink> getFiles= 
                                    [SELECT id, ContentDocument.CreatedBy.name, 
                                    ContentDocument.FileType, ContentDocument.Title, 
                                    ContentDocument.CreatedDate from 
                                    ContentDocumentLink WHERE LinkedEntityId in: perIDs];

                wrap.fileList=getFiles;
                wrap.perList=alumiPerList;
                if(!pder.isEmpty()){
                    wrap.isPrimary=true;
                }
                //wrap.isPrimary=getFiles;
                return wrap;

        }
    
    public class pastStudyFileWrapper{
        @AuraEnabled
        public Boolean isPrimary =false;
        @AuraEnabled
        public List<ContentDocumentLink> fileList =new List<ContentDocumentLink>();
        @AuraEnabled
        public List<Clinical_Trial_Profile__c> alumiStudy =new List<Clinical_Trial_Profile__c>();
        @AuraEnabled
        public List<Participant_Enrollment__c> perList =new List<Participant_Enrollment__c>();

       
        
        
    }
}