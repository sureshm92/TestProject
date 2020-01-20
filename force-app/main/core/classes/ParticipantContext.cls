/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantContext {
    
    private static Participant__c currentParticipant;
    private static Contact currentContact;
    private static Participant_Enrollment__c currentPE;
    private static Boolean initialized = false;
    private static Participant__c ownParticipant;
    
    public static Boolean isCurrentDelegate(){
        return UserContext.getUserContact().userCommunityDelegateId__c != null;
    }
    
    public static Participant__c getCurrentParticipant(){
        init();
        return currentParticipant;
    }
    
    public static Participant_Enrollment__c getCurrentPE(){
        init();
        return currentPE;
    }
    
    public static Contact getCurrentContact(){
        init();
        return currentContact;
    }
    
    private static void init(){
        if(initialized) return;
        UserContext.getCurrentUserMode();
        ownParticipant = ParticipantService.getParticipant(UserContext.getUserContact().Id);
        //current contact
        if(UserContext.getUserContact().userCommunityDelegateId__c != null){
            currentContact = ContactService.getContact(UserContext.getUserContact().userCommunityDelegateId__c);
        }else{
            currentContact = UserContext.getUserContact();
        }
        //current PT
        currentParticipant = ParticipantService.getParticipant(currentContact.Id);
        //current PE
        if(currentContact.Current_Participant_Enrollment__c != null) {
            currentPE = ParticipantEnrollmentService.getParticipantEnrollment(currentContact.Current_Participant_Enrollment__c, CommunityModeService.USER_MODE_PARTICIPANT);
        }
        initialized = true;
    }
    
}