/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String commTemplateStr { get; set; }

    public List<String> getDelegateStudyNames() {
        Id delConId = [SELECT Id, Contact.Id FROM User WHERE Id = :delegateUserId].Contact.Id;
        List<Id> partIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
        if (partIds == null || partIds.isEmpty()) {
            return new List<String>();
        }
        List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Id IN: partIds];

        List<Id> partConIds = new List<Id>();
        for (Participant__c p: participants) partConIds.add(p.Contact__c);

        List<String> delegateStudyNames = new List<String>();

        List<Participant_Enrollment__c> delegatePE = [
                SELECT Id, Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c =:partConIds
                AND Clinical_Trial_Profile__r.CommunityTemplate__c = :commTemplateStr
        ];
        for (Participant_Enrollment__c pe : delegatePE) delegateStudyNames.add(pe.Clinical_Trial_Profile__r.Study_Code_Name__c);

        return delegateStudyNames;
    }
}

