/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId {get; set;}

    public List<StudySiteWrapper> getDelegateStudySites(){
        Id delConId = [SELECT Id, Contact.Id FROM User WHERE Id =: delegateUserId].Contact.Id;
        List<Id> partIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
        Id partCon = [SELECT Id, Contact__c FROM Participant__c WHERE Id =: partIds[0]].Contact__c;
        List<Id> availablePeIds = PatientDelegateService.getAvailablePEIdsForContact(partCon);
        List<Participant_Enrollment__c> delegatePE;
        if(!availablePeIds.isEmpty()) delegatePE = [SELECT Id, Study_Site__c FROM Participant_Enrollment__c WHERE Id IN: availablePeIds];
        List<Id> delegateStudySiteIds = new List<Id>();
        for (Participant_Enrollment__c pe: delegatePE) delegateStudySiteIds.add(pe.Study_Site__c);

        List<Study_Site__c> delegateStudySites = [SELECT Id, Name FROM Study_Site__c WHERE Id IN: delegateStudySiteIds];
        List<StudySiteWrapper> studySiteWrappers = new List<StudySiteWrapper>();
        for (Study_Site__c ss: delegateStudySites) studySiteWrappers.add(new StudySiteWrapper(ss.Name));
        return studySiteWrappers;
    }
}