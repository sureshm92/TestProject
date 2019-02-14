/**
 * Created by D.Yasinskyi on 05.05.2018
 */
trigger ContactTrigger on Contact (before insert, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        for(Contact contact : Trigger.new){
            contact.userCommunity_ShowTour__c =
                    CommunityService.USER_MODE_PI + ';' +
                    CommunityService.USER_MODE_HCP + ';' +
                            CommunityService.USER_MODE_PARTICIPANT;
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContactTriggerHandler.onAfterinsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            ContactTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    
    ContactTriggerHandler.updateParticipantAndUserEmailsOnContactEmailChange();
}