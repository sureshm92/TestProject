/**
 * Created by user on 11-Sep-19.
 */

public without sharing class PastStudiesController {

    @AuraEnabled
    public static List<PastStudyWrapper> getPastStudyRecords(){
        List<PastStudyWrapper> listOfWrappedValues = new List<PastStudyWrapper>();
        Contact userContact = CommunityService.getUserContact();
        Set<String> clinicalTrialIds = new Set<String>();
        Map<Id, List<Id>> mapOfPastPEIds = PatientDelegateService.getPastPEIdsListByContactIdMap(new List<String>{userContact.Id});

        List<Participant_Enrollment__c> particEnrollmentList = [
                SELECT Id, Name, Enrolled_Date__c,
                        Clinical_Trial_Profile__r.Id,
                        Clinical_Trial_Profile__r.Study_Title__c,
                        Clinical_Trial_Profile__r.Therapeutic_Area__r.Name,
                        Clinical_Trial_Profile__r.Detailed_Description__c,
                        Study_Site__r.Site__r.Name,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Clinical_Trial_Profile__r.Profile_Picture__c
                FROM Participant_Enrollment__c
                WHERE Id IN: mapOfPastPEIds.get(userContact.Id)
        ];

        List<Contact> contactList = [
             SELECT Language__c
             FROM Contact
             WHERE Id =:userContact.Id
             LIMIT 1
        ];

        PastStudyWrapper wrappedPEObject;
        for(Participant_Enrollment__c partEnroll : particEnrollmentList){
            clinicalTrialIds.add(partEnroll.Clinical_Trial_Profile__r.Id);
        }
        List<DocumentWrapper> docWrapperList = getContentDocumentForStudy(clinicalTrialIds, String.isBlank(contactList[0].Language__c)
                ? ResourceService.DEFAULT_LANGUAGE : contactList[0].Language__c);
        for(Participant_Enrollment__c partEnroll : particEnrollmentList){
            wrappedPEObject = new PastStudyWrapper(partEnroll, docWrapperList);
            listOfWrappedValues.add(wrappedPEObject);
        }

        return listOfWrappedValues;
    }

    public static  List<DocumentWrapper> getContentDocumentForStudy(Set<String> clinicalTrial, String language){
        List<DocumentWrapper> documentsToShow = new List<DocumentWrapper>();
        DocumentWrapper docWrapperObj;
        Set<Id> resourceIds = new Set<Id>();
        List<Res_study__c> resourceStudyList = [
                SELECT Resource__r.Id
                FROM Res_study__c
                WHERE Clinical_Trial_Profile__c IN: clinicalTrial AND Resource__r.Content_Type__c =: ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
                      AND Resource__r.Language__c =: language
        ];

        for(Res_study__c resStudy : resourceStudyList){
            resourceIds.add(resStudy.Resource__r.Id);
        }
        List<Resource__c> contentDocLinkList = [
                SELECT  Id,
                        Title__c,
                        (SELECT  ContentDocumentId, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLinks)
                FROM    Resource__c
                WHERE   Id IN: resourceIds
        ];

        for(Resource__c contentDoc : contentDocLinkList){
            for(ContentDocumentLink contDocLink : contentDoc.ContentDocumentLinks){
                //if(contDocLink.ContentDocument.Title.removeStart('_') == language){
                    docWrapperObj = new DocumentWrapper (contDocLink.ContentDocumentId, contentDoc.Title__c);
                    documentsToShow.add(docWrapperObj);
                //}
            }
        }
        return documentsToShow;
    }

    public class DocumentWrapper{
        @AuraEnabled public Id documentId;
        @AuraEnabled public String title;

        public DocumentWrapper(Id documentId, String title){
            this.documentId = documentId;
            this.title = title;
        }
    }


    public class PastStudyWrapper{
        @AuraEnabled  public String studyNickname {get;set;}
        @AuraEnabled  public String therapeuticArea {get;set;}
        @AuraEnabled  public String studyDescription {get;set;}
        @AuraEnabled  public String investigatorName {get;set;}
        @AuraEnabled  public Date enrollmentDate {get;set;}
        @AuraEnabled  public String siteLocation {get;set;}
        @AuraEnabled  public String logoURL {get;set;}
        @AuraEnabled  public List<DocumentWrapper> listOfDocuments {get;set;}

        public PastStudyWrapper(
                Participant_Enrollment__c participantEnrollObject,
                List<DocumentWrapper> listOfDocuments
        ){
            this.studyNickname = participantEnrollObject.Clinical_Trial_Profile__r.Study_Title__c != null ? participantEnrollObject.Clinical_Trial_Profile__r.Study_Title__c : '';
            this.therapeuticArea = participantEnrollObject.Clinical_Trial_Profile__r.Therapeutic_Area__r.Name != null
                                   ? participantEnrollObject.Clinical_Trial_Profile__r.Therapeutic_Area__r.Name : '';
            this.studyDescription = participantEnrollObject.Clinical_Trial_Profile__r.Detailed_Description__c != null
                                    ? participantEnrollObject.Clinical_Trial_Profile__r.Detailed_Description__c : '';
            this.investigatorName = participantEnrollObject.Study_Site__r.Principal_Investigator__r.Name != null
                                    ? participantEnrollObject.Study_Site__r.Principal_Investigator__r.Name : '';
            this.enrollmentDate = participantEnrollObject.Enrolled_Date__c;
            this.siteLocation = participantEnrollObject.Study_Site__r.Site__r.Name != null ? participantEnrollObject.Study_Site__r.Site__r.Name: '';
            this.logoURL = participantEnrollObject.Study_Site__r.Clinical_Trial_Profile__r.Profile_Picture__c != null
                            ? participantEnrollObject.Study_Site__r.Clinical_Trial_Profile__r.Profile_Picture__c : '';
            this.listOfDocuments = listOfDocuments;
        }
    }

}