/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityMode {
    
    @AuraEnabled public String key;
    @AuraEnabled public String groupKey;
    @AuraEnabled public String userMode;
    @AuraEnabled public Id currentHCPDelegate;
    @AuraEnabled public Id currentPE;
    @AuraEnabled public Id currentDelegateId;
    @AuraEnabled public Boolean isDelegate = false;
    @AuraEnabled public String groupLabel;
    @AuraEnabled public String label;
    @AuraEnabled public Boolean isGroup = false;
    @AuraEnabled public Boolean isSplitter = false;
    @AuraEnabled public Boolean hasPastStudies = false;
    @AuraEnabled public List<CommunityMode> subModes = new List<CommunityMode>();
    @AuraEnabled public Boolean isOpen = false;
    @AuraEnabled public String participantState;
    
    public CommunityMode(String userMode, String label) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        generateKey();
    }
    
    public CommunityMode(String label) {
        this.isSplitter = true;
        this.label = label;
        this.groupLabel = label;
        generateKey();
    }
    
    public CommunityMode(String userMode, String label, Id delegateId) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        this.currentHCPDelegate = delegateId;
        generateKey();
    }
    
    public CommunityMode(String userMode, String label, Id delegateId, Participant_Enrollment__c pe) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        if(pe != null) {
            this.currentPE = pe.Id;
            if(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(pe.Participant_Status__c)) {
                participantState = ParticipantService.ParticipantStates.REFERRAL + '';
            }else{
                participantState = ParticipantService.ParticipantStates.PARTICIPANT + '';
            }
        }else{
            this.participantState = ParticipantService.ParticipantStates.ALUMNI + '';
        }
        this.currentDelegateId = delegateId;
        generateKey();
    }
    
    public void addSubMode(CommunityMode subMode){
        isGroup = true;
        subModes.add(subMode);
        subMode.groupLabel = label;
        subMode.groupKey = key;
        subMode.hasPastStudies = hasPastStudies;
    }
    
    public void setAsCurrentMode(Contact userContact){
        userContact.userCommunityMode__c = userMode;
        if(userMode == CommunityService.USER_MODE_HCP){
            userContact.userCommunityDelegateId__c = currentHCPDelegate;
        }else if (userContact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT){
            userContact.userCommunityDelegateId__c = currentDelegateId;
            userContact.Current_Participant_Enrollment__c = currentPE;
        }
        update userContact;
    }
    
    private void generateKey(){
        Id currentDelId = currentDelegateId;
        Id whatId;
        if(userMode == CommunityService.USER_MODE_HCP) currentDelId = currentHCPDelegate;
        if(userMode == CommunityService.USER_MODE_PARTICIPANT) whatId = currentPE;
        key = CommunityModeService.generateModeKey(userMode, currentDelId, whatId);
        groupKey = key;
    }

}