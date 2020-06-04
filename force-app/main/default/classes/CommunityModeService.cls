/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModeService {
    
    public static final String USER_MODE_HCP = 'HCP';
    public static final String USER_MODE_PI = 'PI';
    public static final String USER_MODE_PARTICIPANT = 'Participant';
    
    
    public static List<CommunityMode> getUserCommunityModes(Id contactId) {
        List<CommunityMode> modes = new List<CommunityMode>();
        Contact userContact = ContactService.getContact(contactId);
        String availableModes = userContact.userCommunytyType__c == null ? '' : userContact.userCommunytyType__c;
        if ((availableModes != null && availableModes.contains(USER_MODE_PI))
                || !DelegateService.getPIDelegateParents().isEmpty()) {
            modes.add(new CommunityMode(USER_MODE_PI, Label.CTL_L_PI_MODE, null));
        }

        if (availableModes != null && availableModes.contains(USER_MODE_HCP)) {
            modes.add(new CommunityMode(USER_MODE_HCP, Label.CTL_L_HCP_MODE, null));
        }
        //TODO contactId param into DelegateService.getHCPDelegates()
        for (RP_Delegate_Relationship__c delegate : DelegateService.getHCPDelegates()) {
            String rpFullName = (delegate.Referring_Provider__r.Salutation != null?delegate.Referring_Provider__r.Salutation + ' ':'') +
                    delegate.Referring_Provider__r.Full_Name__c +
                    (delegate.Referring_Provider__r.Suffix != null?' ' + delegate.Referring_Provider__r.Suffix:'');
            String itemLabel = Label.CTL_L_HCP_DELEGATE_MODE.replaceAll('##RPName', rpFullName);
            modes.add(new CommunityMode(USER_MODE_HCP, itemLabel, delegate.Referring_Provider__c));
        }

        modes.addAll(getParticipantModes());
        return modes;
    }
    
    public static CommunityMode getCurrentCommunityMode(Contact contact, List<CommunityMode> allModes){
        CommunityMode resMode = findMode(generateModeKey(contact), allModes);
        if((resMode == null || resMode.template.communityName != UserContext.getCurrentCommunityName()) && allModes.size() > 0){
            resMode = getFirstMode(allModes);
            if(resMode != null){
                resMode.setAsCurrentMode(contact);
                return resMode;
            }
        }
        return resMode;
    }
    
    private static List<CommunityMode> getParticipantModes(){
        List<CommunityMode> modes = new List<CommunityMode>();
        List<Participant__c> userParticipants = [
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
                WHERE Contact__c =: CommunityService.getInstance().getCurrentContactId() LIMIT 1
        ];
        Participant__c userParticipant;
        if(userParticipants.size() > 0) userParticipant = userParticipants[0];
        List<Id> delegatedParticipantIds = PatientDelegateService.getDelegatedParticipantIds(UserContext.getUserContactId());
        if(delegatedParticipantIds == null) delegatedParticipantIds = new List<Id>();
        
        Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c WHERE Id IN: delegatedParticipantIds
        ]);
        Map<Id, List<Participant_Enrollment__c>> peListByParticipantIdMap = getPEMap(
                userParticipant,
                delegatedParticipantIds,
                DatabaseService.fieldNotInValues('Participant_Status__c', PEStatusState.PE_STATUS_GROUP_ALUMNI)
        );
        Map<Id, List<Participant_Enrollment__c>> pePastMap = getPEMap(
                userParticipant,
                delegatedParticipantIds,
                DatabaseService.fieldInValues('Participant_Status__c', PEStatusState.PE_STATUS_GROUP_ALUMNI)
        );
        //user studies:
        if(userParticipant != null){
            List<Participant_Enrollment__c> peList = peListByParticipantIdMap.get(userParticipant.Id);
            List<Participant_Enrollment__c> pastPEList = pePastMap.get(userParticipant.Id);
            Boolean hasPastStudies = pastPEList != null && pastPEList.size() > 0;

            CommunityMode mode = new CommunityMode(
                    USER_MODE_PARTICIPANT,
                    userParticipant.First_Name__c + ' ' + userParticipant.Last_Name__c,
                    null,
                    null,
                    CommunityTemplateService.getTemplateByCommunityName(UserContext.getCurrentCommunityName())
            );
            mode.hasPastStudies = hasPastStudies;
            modes.add(mode);
            if(peList != null){
                for(Participant_Enrollment__c pe : peList){
                    mode.addSubMode(new CommunityMode(
                            USER_MODE_PARTICIPANT,
                            pe.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            null,
                            pe,
                            CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.CommunityTemplate__c)
                    ));
                }
            }
        }
        //delegated studies:
        if(delegatedParticipantIds.size() > 0){
            CommunityMode splitter = new CommunityMode(null, 'Participants');
            splitter.isSplitter = true;
            modes.add(splitter);
        }

        Map<Id, String> firstCommunityPermSetMap = getFirstPermissionSetMap(delegatedParticipantIds);
        for(Id participantId : delegatedParticipantIds){
            Participant__c participant = participantsMap.get(participantId);
            List<Participant_Enrollment__c> peList = peListByParticipantIdMap.get(participantId);
            List<Participant_Enrollment__c> pastPEList = pePastMap.get(participantId);
            Boolean hasPastStudies = pastPEList != null && pastPEList.size() > 0;
            CommunityMode mode = new CommunityMode(
                    USER_MODE_PARTICIPANT,
                    participant.First_Name__c + ' ' + participant.Last_Name__c,
                    participant.Contact__c,
                    null,
                    hasPastStudies ? CommunityTemplateService.getTemplate(pastPEList[0].Clinical_Trial_Profile__r.CommunityTemplate__c) :
                            CommunityTemplateService.getTemplateByPermissionSetName(firstCommunityPermSetMap.get(participantId))
            );
            mode.hasPastStudies = hasPastStudies;
            modes.add(mode);
            if(peList != null){
                for(Participant_Enrollment__c pe : peList){
                    mode.addSubMode(new CommunityMode(
                            USER_MODE_PARTICIPANT,
                            pe.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            pe.Participant__r.Contact__c,
                            pe,
                            CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.CommunityTemplate__c)
                    ));
                }
            }
        }
        return modes;
    }
    
    private static CommunityMode findMode(String key, List<CommunityMode> modes){
        for(CommunityMode communityMode : modes){
            if( ( communityMode.participantState == 'ALUMNI' ) && ( communityMode.subModes.isEmpty() ) )  return communityMode; 
            if(!communityMode.isGroup && communityMode.key == key && !communityMode.isSplitter){
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
        CommunityMode firstMode;
        for(CommunityMode communityMode : modes){
            if(!communityMode.isGroup && !communityMode.isSplitter){
                if(firstMode == null) firstMode = communityMode;
                if(communityMode.template.communityName == UserContext.getCurrentCommunityName()) return communityMode;
            }
            for(CommunityMode subMode : communityMode.subModes){
                if(firstMode == null) firstMode = subMode;
                if(subMode.template.communityName == UserContext.getCurrentCommunityName()) return subMode;
            }
        }
        return firstMode;
    }
    
    private static Map<Id, List<Participant_Enrollment__c>> getPEMap(Participant__c userParticipant, List<Id> delegatedParticipantIds, String filter){
        String baseFilter = ' (' +DatabaseService.fieldInValues('Participant__c', delegatedParticipantIds);
        if(userParticipant != null) baseFilter += ' OR ' + DatabaseService.fieldEqual('Participant__c', userParticipant.Id);
        baseFilter += ') ';
        if(filter != null) baseFilter += ' AND ' + filter;
        
        List<Participant_Enrollment__c> peList = (List<Participant_Enrollment__c>)DatabaseService.query(new List<String>{
                'Id',
                'Clinical_Trial_Profile__r.Study_Title__c',
                'Clinical_Trial_Profile__r.Study_Code_Name__c',
                'Clinical_Trial_Profile__r.CommunityTemplate__c',
                'Participant__c',
                'Participant__r.Contact__c',
                'Participant_Status__c'
        }, Participant_Enrollment__c.getSObjectType(), baseFilter);
        Map<Id, List<Participant_Enrollment__c>> peMap = new Map<Id, List<Participant_Enrollment__c>>();
        for(Participant_Enrollment__c pe : peList){
            List<Participant_Enrollment__c> participantPEList = peMap.get(pe.Participant__c);
            if(participantPEList == null) participantPEList = new List<Participant_Enrollment__c>();
            participantPEList.add(pe);
            peMap.put(pe.Participant__c, participantPEList);
        }
        return peMap;
    }
    
    public static String generateModeKey(String userMode, Id currentDelegateId, Id currentWhatId){
        return userMode + '_' + currentDelegateId + '_' + currentWhatId; 
    }
    
    public static String generateModeKey(Contact contact){
        Id currentWhatId;
        if(contact.userCommunityMode__c == USER_MODE_PARTICIPANT) currentWhatId = contact.Current_Participant_Enrollment__c;
        return generateModeKey(contact.userCommunityMode__c, contact.userCommunityDelegateId__c, currentWhatId);
    }
    
    public static Map<Id, String> getFirstPermissionSetMap(List<Id> participantIds){
        //return first permission set for every participant from participantId list
        Participant__c[] participants = [
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Id IN: participantIds
        ];
        Map<Id, Id> participantIdByContactId = new Map<Id, Id>();
        for(Participant__c participant : participants) {
            if(participant.Contact__c != null) {
                participantIdByContactId.put(Participant.Contact__c, participant.Id);
            }
        }
        List<User> users = [
                SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User
                WHERE ContactId IN: participantIdByContactId.keySet()
        ];
        Map<Id, String> resMap = new Map<Id, String>();
        for(User user : users){
            for(PermissionSetAssignment psa : user.PermissionSetAssignments){
                if(CommunityTemplateService.getAllPermissionSets().contains(psa.PermissionSet.Name)){
                    Id participantId = participantIdByContactId.get(user.ContactId);
                    if(participantId != null){
                        resMap.put(participantId, psa.PermissionSet.Name);
                        continue;
                    }
                }
            }
        }
        return resMap;
    }
 




}