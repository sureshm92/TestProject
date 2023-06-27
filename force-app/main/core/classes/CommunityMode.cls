/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityMode {
    @AuraEnabled
    public String key;
    @AuraEnabled
    public String groupKey;
    @AuraEnabled
    public String userMode;
    @AuraEnabled
    public String communityName;
    @AuraEnabled
    public Id currentHCPDelegate;
    @AuraEnabled
    public Id currentPE;
    @AuraEnabled
    public Id currentDelegateId;
    @AuraEnabled
    public Boolean isDelegate = false;
    @AuraEnabled
    public String groupLabel;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public Boolean isGroup = false;
    @AuraEnabled
    public Boolean isSplitter = false;
    @AuraEnabled
    public Boolean hasPastStudies = false;
    @AuraEnabled
    public List<CommunityMode> subModes = new List<CommunityMode>();
    @AuraEnabled
    public Boolean isOpen = false;
    @AuraEnabled
    public String participantState;
    @AuraEnabled
    public CommunityTemplate template = CommunityTemplateService.getDefaultTemplate();

    public CommunityMode(String userMode, String label) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        init();
    }

    public CommunityMode(String label) {
        this.isSplitter = true;
        this.label = label;
        this.groupLabel = label;
        init();
    }

    public CommunityMode(String userMode, String label, Id delegateId) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        this.currentHCPDelegate = delegateId;
        init();
    }

    public CommunityMode(String userMode, String label, Id delegateId, String communityName) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        this.communityName = communityName;
        init();
    }

    public CommunityMode(
        String userMode,
        String label,
        Id delegateId,
        Participant_Enrollment__c pe,
        CommunityTemplate template
    ) {
        this.userMode = userMode;
        this.label = label;
        this.groupLabel = label;
        this.template = template;
        if (pe != null) {
            this.currentPE = pe.Id;
            if (PEStatusState.PE_STATUS_GROUP_IN_PROGRESS.contains(pe.Participant_Status__c)) {
                participantState = ParticipantService.ParticipantStates.REFERRAL + '';
            } else {
                participantState = ParticipantService.ParticipantStates.PARTICIPANT + '';
            }
        } else {
            this.participantState = ParticipantService.ParticipantStates.ALUMNI + '';
        }
        this.currentDelegateId = delegateId;
        init();
    }

    public void addSubMode(CommunityMode subMode) {
        system.debug('subMode::' + subMode);
        isGroup = true;
        subModes.add(subMode);
        subMode.groupLabel = label;
        subMode.groupKey = key;
        subMode.hasPastStudies = hasPastStudies;
        system.debug('subMode final::' + subMode);
    }

    public void setAsCurrentMode(Contact userContact) {
        userContact.userCommunityMode__c = userMode;
        if (userMode == CommunityService.USER_MODE_HCP) {
            userContact.userCommunityDelegateId__c = currentHCPDelegate;
        } else if (userMode == CommunityService.USER_MODE_PI) {
            userContact.Current_Sponsor_Name__c = communityName;
        } else if (userContact.userCommunityMode__c == CommunityService.USER_MODE_PARTICIPANT) {
            userContact.userCommunityDelegateId__c = currentDelegateId;
            userContact.Current_Participant_Enrollment__c = currentPE;
        }
        update userContact;
    }

    public Boolean isParticipant() {
        return userMode == CommunityModeService.USER_MODE_PARTICIPANT;
    }

    public Boolean isPI() {
        return userMode == CommunityModeService.USER_MODE_PI;
    }

    public Boolean isHCP() {
        return userMode == CommunityModeService.USER_MODE_HCP;
    }

    private void init() {
        Id currentDelId = currentDelegateId;
        String whatId;
        if (userMode == CommunityService.USER_MODE_HCP) {
            currentDelId = currentHCPDelegate;
            isDelegate = currentHCPDelegate != null;
        }
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            whatId = currentPE;
            isDelegate = currentDelegateId != null;
        }
        if (userMode == CommunityService.USER_MODE_PI) {
            whatId = communityName;
            template = CommunityTemplateService.getTemplate(communityName);
        }

        key = CommunityModeService.generateModeKey(userMode, currentDelId, whatId);
        groupKey = key;
    }
}
