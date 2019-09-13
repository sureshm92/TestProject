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
        List<ContactService.PastStudyWrapper>  pastStudyWrapper = ContactService.getPastStudyWrappers(userContact.Id);
        List<ResourceService.ResourceWrapper> listOfDocuments = new List<ResourceService.ResourceWrapper>();
        for(Participant_Enrollment__c partEnroll : particEnrollmentList){
            for(ContactService.PastStudyWrapper pastStudy : pastStudyWrapper){
                if(pastStudy.pe.Id == partEnroll.Id){
                    listOfDocuments.addAll(pastStudy.resourceWrappers);
                    break;
                }
            }
            wrappedPEObject = new PastStudyWrapper(partEnroll, listOfDocuments);
            listOfWrappedValues.add(wrappedPEObject);
        }

        return listOfWrappedValues;
    }

    public class PastStudyWrapper{
        @AuraEnabled  public String studyNickname {get;set;}
        @AuraEnabled  public String therapeuticArea {get;set;}
        @AuraEnabled  public String studyDescription {get;set;}
        @AuraEnabled  public String investigatorName {get;set;}
        @AuraEnabled  public Date enrollmentDate {get;set;}
        @AuraEnabled  public String siteLocation {get;set;}
        @AuraEnabled  public String logoURL {get;set;}
        @AuraEnabled  public  List<ResourceService.ResourceWrapper> listOfDocuments {get;set;}

        public PastStudyWrapper(
                Participant_Enrollment__c participantEnrollObject,
                List<ResourceService.ResourceWrapper> listOfDocuments
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