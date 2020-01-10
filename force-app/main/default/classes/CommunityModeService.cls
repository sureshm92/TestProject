/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModeService {
    
    public class CommunityMode {
        
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
        @AuraEnabled public List<CommunityMode> subModes = new List<CommunityMode>();
        @AuraEnabled public Boolean isOpen = false;
    
        public CommunityMode(String userMode, String label) {
            this.userMode = userMode;
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
    
        public CommunityMode(String userMode, String label, Id delegateId, Id peId) {
            this.userMode = userMode;
            this.label = label;
            this.groupLabel = label;
            this.currentPE = peId;
            this.currentDelegateId = delegateId;
            generateKey();
        }
    
        public void addSubMode(CommunityMode subMode){
            isGroup = true;
            subModes.add(subMode);
            subMode.groupLabel = label;
            subMode.groupKey = key;
        }
        
        public void setAsCurrentMode(){
            Contact userContact = CommunityService.getUserContact();
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
            key = userMode;
            if(userMode == CommunityService.USER_MODE_PARTICIPANT){
                key += '' + currentDelegateId + currentPE;
            }
            if(userMode == CommunityService.USER_MODE_HCP){
                key += currentHCPDelegate;
            }
            groupKey = key;
        }
    
    }
    
    
    public static List<CommunityMode> getUserCommunityModes() {
        List<CommunityMode> modes = new List<CommunityMode>();
        Contact userContact = CommunityService.getUserContact();
        String availableModes = userContact.userCommunytyType__c == null ? '' : userContact.userCommunytyType__c;
        if ((availableModes != null && availableModes.contains(CommunityService.USER_MODE_PI))
                || !DelegateService.getPIDelegateParents().isEmpty()) {
            modes.add(new CommunityMode(CommunityService.USER_MODE_PI, Label.CTL_L_PI_MODE, null));
        }

        if (availableModes != null && availableModes.contains(CommunityService.USER_MODE_HCP)) {
            modes.add(new CommunityMode(CommunityService.USER_MODE_HCP, Label.CTL_L_HCP_MODE, null));
        }
        for (RP_Delegate_Relationship__c delegate : DelegateService.getHCPDelegates()) {
            String rpFullName = (delegate.Referring_Provider__r.Salutation != null?delegate.Referring_Provider__r.Salutation + ' ':'') +
                    delegate.Referring_Provider__r.Full_Name__c +
                    (delegate.Referring_Provider__r.Suffix != null?' ' + delegate.Referring_Provider__r.Suffix:'');
            String itemLabel = Label.CTL_L_HCP_DELEGATE_MODE.replaceAll('##RPName', rpFullName);
            modes.add(new CommunityMode(CommunityService.USER_MODE_HCP, itemLabel, delegate.Referring_Provider__c));
        }

        modes.addAll(getParticipantModes());
        return modes;
    }
    
    public static CommunityMode getCurrentCommunityMode(List<CommunityMode> allModes){
        CommunityMode currentMode = getCurrentCommunityMode(); //from DB
        CommunityMode resMode = findMode(currentMode.key, allModes); // find in available modes
        System.debug('KEY: ' + currentMode.key);
        System.debug('Find MODE: ' + JSON.serializePretty(resMode));
        if(resMode == null && allModes.size() > 0){
            resMode = getFirstMode(allModes);
            if(resMode != null){
                resMode.setAsCurrentMode();
                return resMode;
            }
        }
        return resMode;
    }
    
    private static CommunityMode getCurrentCommunityMode(){
        CommunityMode currentMode;
        Contact userContact = CommunityService.getUserContact();
        if(userContact.userCommunityMode__c == CommunityService.USER_MODE_PI){
            currentMode = new CommunityMode(
                    CommunityService.USER_MODE_PI,
                    null);
        }else if (userContact.userCommunityMode__c == CommunityService.USER_MODE_HCP){
            currentMode = new CommunityMode(
                    CommunityService.USER_MODE_HCP,
                    null,
                    userContact.userCommunityDelegateId__c);
        }else{
            currentMode = new CommunityMode(
                    CommunityService.USER_MODE_PARTICIPANT,
                    null,
                    userContact.userCommunityDelegateId__c,
                    userContact.Current_Participant_Enrollment__c
            );
        }
        return currentMode;
    }
    
    private static List<CommunityMode> getParticipantModes(){
        List<CommunityMode> modes = new List<CommunityMode>();
        List<Participant__c> userParticipant = [
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
                WHERE Contact__c =: CommunityService.getInstance().getCurrentContactId() LIMIT 1
        ];
        List<Id> delegatedParticipantIds = PatientDelegateService.getDelegatedParticipantIds(CommunityService.getInstance().getCurrentContactId());
        if(delegatedParticipantIds == null) delegatedParticipantIds = new List<Id>();
        List<Participant_Enrollment__c> peList = [
                SELECT Id, Clinical_Trial_Profile__r.Study_Title__c,
                        Participant__c,
                        Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE (Participant__c IN :delegatedParticipantIds OR Participant__c IN :userParticipant)
                AND Participant_Status__c NOT IN :PEStatusState.PE_STATUS_GROUP_ALUMNI
        ];
        Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
        ]);
        Map<Id, List<Participant_Enrollment__c>> peListByParticipantIdMap = new Map<Id, List<Participant_Enrollment__c>>();
        for(Participant_Enrollment__c pe : peList){
            List<Participant_Enrollment__c> participantPEList = peListByParticipantIdMap.get(pe.Participant__c);
            if(participantPEList == null) participantPEList = new List<Participant_Enrollment__c>();
            participantPEList.add(pe);
            peListByParticipantIdMap.put(pe.Participant__c, participantPEList);
        }
        if(userParticipant.size() > 0){
            peList = peListByParticipantIdMap.get(userParticipant[0].Id);
            
            CommunityMode mode = new CommunityMode(
                    CommunityService.USER_MODE_PARTICIPANT,
                    userParticipant[0].First_Name__c + ' ' + userParticipant[0].Last_Name__c,
                    userParticipant[0].Contact__c,
                    null
            );
            modes.add(mode);
            if(peList != null){
                for(Participant_Enrollment__c pe : peList){
                    mode.addSubMode(new CommunityMode(
                            CommunityService.USER_MODE_PARTICIPANT,
                            pe.Clinical_Trial_Profile__r.Study_Title__c,
                            pe.Participant__r.Contact__c,
                            pe.Id
                    ));
                }
            }
        }
        for(Id participantId : delegatedParticipantIds){
            Participant__c participant = participantsMap.get(participantId);
            peList = peListByParticipantIdMap.get(participantId);
            CommunityMode mode = new CommunityMode(
                    CommunityService.USER_MODE_PARTICIPANT,
                    participant.First_Name__c + ' ' + participant.Last_Name__c,
                    participant.Contact__c,
                    null
            );
            modes.add(mode);
            if(peList != null){
                for(Participant_Enrollment__c pe : peList){
                    mode.addSubMode(new CommunityMode(
                            CommunityService.USER_MODE_PARTICIPANT,
                            pe.Clinical_Trial_Profile__r.Study_Title__c,
                            pe.Participant__r.Contact__c,
                            pe.Id
                    ));
                }
            }
        }
        return modes;
    }
    
    private static CommunityMode findMode(String key, List<CommunityMode> modes){
        for(CommunityMode communityMode : modes){
            if(!communityMode.isGroup && communityMode.key == key){
                return communityMode;
            }
            for(CommunityMode subMode : communityMode.subModes){
                if(subMode.key == key){
                    return subMode;
                }
            }
        }
        return null;
    }
    
    private static CommunityMode getFirstMode(List<CommunityMode> modes){
        for(CommunityMode communityMode : modes){
            if(!communityMode.isGroup){
                return communityMode;
            }
            for(CommunityMode subMode : communityMode.subModes){
                return subMode;
            }
        }
        return null;
    }




}