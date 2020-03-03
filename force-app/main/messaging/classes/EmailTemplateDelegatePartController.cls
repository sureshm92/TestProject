/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String dataParams {get; set;}

    public List<StudySiteWrapper> getDelegateStudySites() {
        Id delConId = [SELECT Id, Contact.Id FROM User WHERE Id = :delegateUserId].Contact.Id;
        List<Id> partIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
        if(partIds == null || partIds.isEmpty()){
            return  new List<StudySiteWrapper>();
        }
        Id partCon = [SELECT Id, Contact__c FROM Participant__c WHERE Id = :partIds[0]].Contact__c;
        List<Id> availablePeIds = PatientDelegateService.getAvailablePEIdsForContact(partCon);

        List<Id> delegateStudySiteIds = new List<Id>();
        if (!availablePeIds.isEmpty()) {
            List<Participant_Enrollment__c> delegatePE = [
                    SELECT Id, Study_Site__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN:availablePeIds
            ];
            for (Participant_Enrollment__c pe : delegatePE) delegateStudySiteIds.add(pe.Study_Site__c);
        }

        List<Study_Site__c> delegateStudySites = [SELECT Id, Name FROM Study_Site__c WHERE Id IN:delegateStudySiteIds];
        List<StudySiteWrapper> studySiteWrappers = new List<StudySiteWrapper>();
        for (Study_Site__c ss : delegateStudySites) studySiteWrappers.add(new StudySiteWrapper(ss.Name));
        return studySiteWrappers;
    }

    global String getAfterText() {
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(dataParams, Map<String, String>.class);
        return TranslateHelper.replaceParams(Label.Email_Body_Initial_Patient_Delegate_AfterText, EmailTemplateController.PARAM_PREFIX, paramsMap);
    }
}

