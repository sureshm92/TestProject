trigger ParticipantComorbiditiesTrigger on Participant_Comorbidities__c (after insert, after delete) {
    
    if (Trigger.isInsert && Trigger.isAfter) {
        List<Participant_Comorbidities__c> pcListnew = Trigger.new;
        ParticipantComorbiditiesTriggerHelper.updatePERafterInsert(pcListnew);
    }
    else if (Trigger.isDelete && Trigger.isAfter) {
        List<Participant_Comorbidities__c> pcList = Trigger.old;
        ParticipantComorbiditiesTriggerHelper.updatePERafterDelete(pcList);
    }
}