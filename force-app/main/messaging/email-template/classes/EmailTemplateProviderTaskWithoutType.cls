/**
 * Created by Igor Malyuta on 29.05.2020.
 */
public without sharing class EmailTemplateProviderTaskWithoutType extends EmailTemplateProvider {

    protected override void initYourParticipantFirstName() {
        if (whatId == null) return;

        List<Task> task = [SELECT WhatId FROM Task WHERE Id = :whatId];
        if (!task.isEmpty()) {
            Participant__c participant;
            Id taskWhatId = task.get(0).WhatId;
            if (taskWhatId.getSobjectType() == Participant__c.getSObjectType()) {
                participant = [SELECT First_Name__c FROM Participant__c WHERE Id = :taskWhatId];
            } else if (taskWhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                List<Participant_Enrollment__c> enrollment = [
                        SELECT Participant__r.First_Name__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :taskWhatId
                ];
                if (!enrollment.isEmpty()) participant = enrollment.get(0).Participant__r;
            }

            if (participant != null) parameters.put('ParticipantFirstName', participant.First_Name__c);
        }
    }
}