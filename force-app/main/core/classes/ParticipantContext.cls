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
    
    public static Id getCurrentParticipantId(){
        if(getCurrentParticipant() != null) return getCurrentParticipant().Id;
        return null;
    }
    
    public static Participant__c getOwnParticipant(){
        init();
        return ownParticipant;
    }
    
    public static Id getOwnParticipantId(){
        if(getOwnParticipant() != null) return getOwnParticipant().Id;
        return null;
    }
    
    public static Participant_Enrollment__c getCurrentPE(){
        init();
        return currentPE;
    }
    
    public static Id getCurrentPEId(){
        if(getCurrentPE() != null) return getCurrentPE().Id;
        return null;
    }
    
    public static Contact getCurrentContact(){
        init();
        return currentContact;
    }
    
    private static void init(){
        if(initialized) return;
        String userMode = UserContext.getCurrentUserMode().userMode;
        if(userMode == CommunityModeService.USER_MODE_PARTICIPANT){
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
        }
        initialized = true;
    }
    
}