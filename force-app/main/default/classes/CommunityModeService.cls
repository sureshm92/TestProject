/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityModeService {

    public static final String USER_MODE_HCP = 'HCP';
    public static final String USER_MODE_PI = 'PI';
    public static final String USER_MODE_PARTICIPANT = 'Participant';
	public static final String USER_MODE_CC = 'CC';
    
    

    public static final Map<String, String> labelByMode = new Map<String, String>{
            USER_MODE_HCP => Label.CTL_L_HCP_MODE,
            USER_MODE_PI => Label.CTL_L_PI_MODE
    };
    public static final Map<String, String> itemTypeByMode = new Map<String, String>{
            USER_MODE_HCP => CommunityModes.RH_ITEM_TYPE_RP,
            USER_MODE_PI => CommunityModes.RH_ITEM_TYPE_PI
    };

    public static List<CommunityModes.RHCommunityModeItem> getReferralModeItems(Id contactId) {
        List<CommunityModes.RHCommunityModeItem> modes = new List<CommunityModes.RHCommunityModeItem>();
        Contact userContact = ContactService.getContact(contactId);
        List<String> availableModes = userContact.userCommunytyType__c == null ? new List<String>() : userContact.userCommunytyType__c.split(';');
        if (availableModes.contains(USER_MODE_PI) || !DelegateService.getPIDelegateParents().isEmpty()) {
            modes.add(new CommunityModes.RHCommunityModeItem(
                    USER_MODE_PI, labelByMode.get(USER_MODE_PI), itemTypeByMode.get(USER_MODE_PI),
                    null, false, false));
        }
        List<RP_Delegate_Relationship__c> rpDelegates = DelegateService.getHCPDelegates();
        if (availableModes.contains(USER_MODE_HCP) && rpDelegates.isEmpty()) {
            modes.add(new CommunityModes.RHCommunityModeItem(
                    USER_MODE_HCP, labelByMode.get(USER_MODE_HCP), itemTypeByMode.get(USER_MODE_HCP),
                    null, false, false));
        } else if (!rpDelegates.isEmpty()) {
            Set<Id> contactIds = new Set<Id>{userContact.Id};
            for (RP_Delegate_Relationship__c delegate : rpDelegates){
                contactIds.add(delegate.Referring_Provider__c);
            }
            Map<Id, Participant__c> participantByContactMap = new Map<Id, Participant__c>();
            for (Participant__c participantRecord : [
                    SELECT Id, First_Name__c, Last_Name__c, Contact__c
                    FROM Participant__c
                    WHERE Contact__c IN :contactIds

            ]){
                participantByContactMap.put(participantRecord.Contact__c, participantRecord);
            }
            CommunityModes.RHCommunityModeItem modeItem = new CommunityModes.RHCommunityModeItem(
                    USER_MODE_HCP, labelByMode.get(USER_MODE_HCP), itemTypeByMode.get(USER_MODE_HCP),
                    null, true, true);
            if (availableModes.contains(USER_MODE_HCP)) {
                String rpName = getRPName(userContact, participantByContactMap);
                modeItem.subItems.add(new CommunityModes.RHCommunityModeItem(
                        USER_MODE_HCP, rpName, itemTypeByMode.get(USER_MODE_HCP),
                        null, false, false));
            }
            for (RP_Delegate_Relationship__c delegate : rpDelegates) {
                String rpName = getRPName(delegate.Referring_Provider__r, participantByContactMap);
                modeItem.subItems.add(new CommunityModes.RHCommunityModeItem(
                        USER_MODE_HCP, rpName, itemTypeByMode.get(USER_MODE_HCP),
                        delegate.Referring_Provider__c, false, false));
            }
            modes.add(modeItem);
        }
        return modes;
    }

    public static List<CommunityModes.PPCommunityModeItem> getParticipantModeItems(Id contactId) {
        List<CommunityModes.PPCommunityModeItem> modes = new List<CommunityModes.PPCommunityModeItem>();
        List<Participant__c> userParticipants = [
                SELECT Id, First_Name__c, Last_Name__c, Contact__c, Contact__r.Landing_Community__c
                FROM Participant__c
                WHERE Contact__c = :contactId
                LIMIT 1
        ];
        Participant__c userParticipant;
        if (!userParticipants.isEmpty()) userParticipant = userParticipants[0];
        List<Id> delegatedParticipantIds = PatientDelegateService.getDelegatedParticipantIds(contactId);
        if (delegatedParticipantIds == null) delegatedParticipantIds = new List<Id>();

        Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                SELECT Id, First_Name__c, Last_Name__c, Contact__c
                FROM Participant__c
                WHERE Id IN:delegatedParticipantIds
        ]);
        Map<Id, List<Participant_Enrollment__c>> peListByParticipantIdMap = getPEMap(
                userParticipant, delegatedParticipantIds,
                DatabaseService.fieldNotInValues('Participant_Status__c', PEStatusState.PE_STATUS_GROUP_ALUMNI)
        );
        Map<Id, List<Participant_Enrollment__c>> pePastMap = getPEMap(
                userParticipant,
                delegatedParticipantIds,
                DatabaseService.fieldInValues('Participant_Status__c', PEStatusState.PE_STATUS_GROUP_ALUMNI)
        );

        if (!userParticipants.isEmpty()) {
            List<Participant_Enrollment__c> peList = peListByParticipantIdMap.get(userParticipant.Id);
            List<Participant_Enrollment__c> pePastList = pePastMap.get(userParticipant.Id);
            CommunityModes.PPCommunityModeItem modeItem = new CommunityModes.PPCommunityModeItem(
                    false, peList != null || pePastList != null
            );

            if (peList != null) {
                for (Participant_Enrollment__c pe : peList) {
                    String participantName = userParticipant.First_Name__c + ' ' + userParticipant.Last_Name__c;
                    modeItem.subItems.add(new CommunityModes.PPCommunityModeItem(
                            USER_MODE_PARTICIPANT, participantName, pe.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            pe.Id, null, false
                    ));
                }
            } else {
                String participantName = userParticipant.First_Name__c + ' ' + userParticipant.Last_Name__c;
                modeItem.subItems.add(new CommunityModes.PPCommunityModeItem(
                        USER_MODE_PARTICIPANT, participantName, Label.No_active_studies,
                        null, null, false
                ));
            }
            modes.add(modeItem);
        }

        for (Id participantId : delegatedParticipantIds) {
            Participant__c participant = participantsMap.get(participantId);
            List<Participant_Enrollment__c> peList = peListByParticipantIdMap.get(participantId);
            CommunityModes.PPCommunityModeItem modeItem = new CommunityModes.PPCommunityModeItem(
                    false, false
            );

            if (peList != null) {
                for (Participant_Enrollment__c pe : peList) {
                    String participantName = participant.First_Name__c + ' ' + participant.Last_Name__c;
                    modeItem.subItems.add(new CommunityModes.PPCommunityModeItem(
                            USER_MODE_PARTICIPANT, participantName, pe.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            pe.Id, participant.Contact__c, true
                    ));
                }
            } else {
                String participantName = participant.First_Name__c + ' ' + participant.Last_Name__c;
                modeItem.subItems.add(new CommunityModes.PPCommunityModeItem(
                        USER_MODE_PARTICIPANT, participantName, Label.No_active_studies,
                        null, participant.Contact__c, true
                ));
            }
            modes.add(modeItem);
        }
        return modes;
    }

    public static String getSwitcherType(List<CommunityModes.RHCommunityModeItem> rhModes, List<CommunityModes.PPCommunityModeItem> ppModes) {
        if (rhModes.isEmpty()) {
            return CommunityModes.MODE_TYPE_PP_ONLY;
        } else if (ppModes.isEmpty()) {
            if(rhModes.size() == 1 && rhModes[0].subItems.size() < 2) {
                return CommunityModes.MODE_TYPE_RH_SINGLE_VIEW;
            }
            return CommunityModes.MODE_TYPE_RH_ONLY;
        } else {
            return CommunityModes.MODE_TYPE_PP_AND_RH;
        }
    }

    public static void getCurrentItemMode(Contact contact, CommunityModes communityModes) {
        clearAllItemModeValues(communityModes);
        if (contact.userCommunityMode__c == USER_MODE_PARTICIPANT) {
            for (CommunityModes.PPCommunityModeItem item : communityModes.ppModeItems) {
                for (CommunityModes.PPCommunityModeItem subItem : item.subItems) {
                    if (subItem.peId == contact.Current_Participant_Enrollment__c && subItem.delegateId == contact.userCommunityDelegateId__c) {
                        communityModes.isPPItemsSelected = true;
                        subItem.isSelected = true;
                    }
                }
            }
        } else if (contact.userCommunityMode__c == USER_MODE_HCP || contact.userCommunityMode__c == USER_MODE_PI) {
            for (CommunityModes.RHCommunityModeItem item : communityModes.rhModeItems) {
                if(item.mode == contact.userCommunityMode__c) {
                    for (CommunityModes.RHCommunityModeItem subItem : item.subItems) {
                        if (subItem.itemId == contact.userCommunityDelegateId__c) {
                            subItem.isSelected = true;
                        }
                    }
                    item.isSelected = true;
                    communityModes.isRHItemsSelected = true;
                }
            }
        } else {
            if (!communityModes.ppModeItems.isEmpty()) {
                communityModes.ppModeItems[0].subItems[0].isSelected = true;
            } else if (!communityModes.rhModeItems.isEmpty()) {
                communityModes.rhModeItems[0].isSelected = true;
                if (!communityModes.rhModeItems[0].subItems.isEmpty()) {
                    communityModes.rhModeItems[0].subItems[0].isSelected = true;
                }
            }
        }
    }

    private static void clearAllItemModeValues(CommunityModes communityModes) {
        communityModes.isRHItemsSelected = false;
        communityModes.isRHItemsCollapsed = true;
        communityModes.isPPItemsSelected = false;
        communityModes.isPPItemsCollapsed = true;
        for (CommunityModes.PPCommunityModeItem ppItem : communityModes.ppModeItems) {
            for (CommunityModes.PPCommunityModeItem ppSubItem : ppItem.subItems) {
                ppSubItem.isSelected = false;
            }
        }
        for (CommunityModes.RHCommunityModeItem rhItem : communityModes.rhModeItems) {
            rhItem.isSelected = false;
            for (CommunityModes.RHCommunityModeItem rhSubItem : rhItem.subItems) {
                rhSubItem.isSelected = false;
            }
        }
    }

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
		//For CC
        if (availableModes != null && availableModes.contains(USER_MODE_CC)) {
            modes.add(new CommunityMode(USER_MODE_CC, Label.CTL_L_CC_MODE, null));
        }
        //
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
        if((resMode == null /*|| resMode.template.communityName != UserContext.getCurrentCommunityName()*/) && allModes.size() > 0){
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
                SELECT Id, First_Name__c, Last_Name__c, Contact__c, Contact__r.Landing_Community__c
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
            //PEH-2038: For prospect view check the Landing_Community__c
            CommunityTemplate initTemplate =  !String.isBlank(userParticipant.Contact__r.Landing_Community__c) ?
            		CommunityTemplateService.getTemplateByCommunityName(userParticipant.Contact__r.Landing_Community__c) :
            		CommunityTemplateService.getTemplateByCommunityName(UserContext.getCurrentCommunityName());
            CommunityMode mode = new CommunityMode(
                    USER_MODE_PARTICIPANT,
                    userParticipant.First_Name__c + ' ' + userParticipant.Last_Name__c,
                    null,
                    null,
                    initTemplate
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

    public static CommunityMode findMode(String key, List<CommunityMode> modes){
        for(CommunityMode communityMode : modes){
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

    private static String getRPName(Contact rpContact, Map<Id, Participant__c> participantsByContactIdsMap){
        if (!participantsByContactIdsMap.containsKey(rpContact.Id)) {
            return (rpContact.Salutation != null ? rpContact.Salutation + ' ' : '') +
            rpContact.Full_Name__c + (rpContact.Suffix != null ? ' ' + rpContact.Suffix : '');
        }
        else{
            Participant__c rpParticipantRecord = participantsByContactIdsMap.get(rpContact.Id);
            return (rpContact.Salutation != null ? rpContact.Salutation + ' ' : '') +
                    rpParticipantRecord.First_Name__c + ' ' + rpParticipantRecord.Last_Name__c
                    + (rpContact.Suffix != null ? ' ' + rpContact.Suffix : '');
        }

    }
}