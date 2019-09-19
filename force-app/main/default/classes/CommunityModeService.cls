/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModeService {
    
    public class CommunityMode {
        
        @AuraEnabled public String userMode;
        @AuraEnabled public Id currentHCPDelegate;
        @AuraEnabled public Id currentPE;
        @AuraEnabled public Boolean isDelegate = false;
        @AuraEnabled public String label;
        
        public CommunityMode(String userMode, String label, Id sourceId) {
            this.userMode = userMode;
            this.label = label;
            if (sourceId != null) {
                if (sourceId.getSobjectType() == Contact.getSObjectType()) currentHCPDelegate = sourceId;
                if (sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) currentPE = sourceId;
            }
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

        List<Id> availablePEIds = PatientDelegateService.getAvailablePEIdsListByContactIdMap(new List<String>{userContact.Id}).get(userContact.Id);
        if(availableModes != null && availableModes.contains(CommunityService.USER_MODE_PARTICIPANT)){
            List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
    
            if(availablePEIds != null && availablePEIds.size() > 0){
                peList.addAll([
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.Study_Code_Name__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN :availablePEIds AND Participant_Contact__c = :userContact.Id
                ]);
                peList.addAll([
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.Study_Code_Name__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN :availablePEIds AND Participant_Contact__c != :userContact.Id
                ]);
            }
    
            if(peList.size() > 0){
                for(Participant_Enrollment__c pe : peList){
                    String label = Label.BTN_View + ' ' + pe.Clinical_Trial_Profile__r.Study_Code_Name__c + '';
                    modes.add(new CommunityMode(CommunityService.USER_MODE_PARTICIPANT, label, pe.Id ));
                }
            }else{
                modes.add(new CommunityMode(CommunityService.USER_MODE_PARTICIPANT, Label.CTL_L_Patricipant_MODE, null));
            }
        }
        
        return modes;
    }
    
    public static CommunityMode getCurrentCommunityMode(List<CommunityMode> allModes){
        String currentModeKey = getCurrentModeKey();
        for(CommunityMode communityMode : allModes){
            if(getModeKey(communityMode) == currentModeKey){
                return communityMode;
            }
        }
        if(!allModes.isEmpty()){
            return allModes[0];
        }
        return null;
    }
    
    private static String getCurrentModeKey(){
        Contact userContact = CommunityService.getUserContact();
        String key = userContact.userCommunityMode__c;
        if(key == CommunityService.USER_MODE_HCP && userContact.userCommunityDelegateId__c != null) {
            key += userContact.userCommunityDelegateId__c;
        }
        if(key == CommunityService.USER_MODE_PARTICIPANT && userContact.Current_Participant_Enrollment__c != null) {
            key += userContact.Current_Participant_Enrollment__c;
        }
        return key;
    }
    
    private static String getModeKey(CommunityMode communityMode){
        String key = communityMode.userMode;
        if(communityMode.userMode == CommunityService.USER_MODE_PARTICIPANT && communityMode.currentPE != null){
            key += communityMode.currentPE;
        }
        if(communityMode.userMode == CommunityService.USER_MODE_HCP && communityMode.currentHCPDelegate != null){
            key += communityMode.currentHCPDelegate;
        }
        return key;
    }

}