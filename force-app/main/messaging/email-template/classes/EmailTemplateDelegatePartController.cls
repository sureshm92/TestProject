/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String commTemplateStr { get; set; }
    global Id sourceIdValue { get; set; }

    public List<String> getDelegateStudyNames() {
        List<Id> participantIds = new List<Id>();
        if(sourceIdValue != null && sourceIdValue.getSobjectType() == Participant__c.getSObjectType()) {
            participantIds.add(sourceIdValue);
        } else if(sourceIdValue != null && sourceIdValue.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
            List<Participant_Enrollment__c> pes = [
                    SELECT Id, Participant__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id =: sourceIdValue];
            for(Participant_Enrollment__c pe : pes) {
                participantIds.add(pe.Participant__c);
                commTemplateStr = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
        } else {
            Id delConId = delegateUserId;
            if(Id.valueOf(delegateUserId).getSobjectType() == User.getSObjectType()) {
                delConId = [SELECT ContactId FROM User WHERE Id = :delegateUserId].ContactId;
            }
            List<Id> delegatedParticipantIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
            if (delegatedParticipantIds != null) participantIds.addAll(delegatedParticipantIds);
        }

        List<String> delegateStudyNames = new List<String>();
        if (participantIds.isEmpty()) return delegateStudyNames;

        List<Participant_Enrollment__c> delegatePE = [
                SELECT  Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN:participantIds
                AND Clinical_Trial_Profile__r.CommunityTemplate__c = :commTemplateStr
        ];
        for (Participant_Enrollment__c pe : delegatePE) delegateStudyNames.add(pe.Clinical_Trial_Profile__r.Study_Code_Name__c);

        return delegateStudyNames;
    }
}

