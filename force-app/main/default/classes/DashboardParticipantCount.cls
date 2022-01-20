public without sharing class DashboardParticipantCount {
    public DashboardParticipantCount() {

    }
    private static String DB_Invited_Count = Label.Site_DB_Invited;
    private static String DB_Not_Yet_Invited_Count = Label.Site_DB_Not_Yet_Invited;

    public class BarItem {
        @AuraEnabled
        public String color;
        @AuraEnabled
        public String width;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String count;
        
        public BarItem(String color, String width, String title, String count) {
            this.color = color;
            this.width = width;
            this.title = title;
            this.count = count;
        }
    }

    public class ParticipantDetails {
        @AuraEnabled
        public Id participantId;
        @AuraEnabled
        public String participantName;
        @AuraEnabled
        public Id delegateId;
        @AuraEnabled
        public String delegateParticipantName;
        @AuraEnabled
        public Boolean isChecked;
        @AuraEnabled
        public String datasetId;
    }

    @AuraEnabled
    public static List<BarItem> participantInvitationDashboard(Id pIid,Id ctpId) {
        try {
            List<BarItem> resList = new List<BarItem>();
            Integer totalCount = 0;
            Integer invitedCount = 0;
            Integer notInvitedCount = 0;
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
            List<Id> InvitedContactIds = new List<Id>();
            String perWhereClause = 'AND study_Site__r.Clinical_Trial_Profile__c =\''+ String.escapeSingleQuotes(ctpId)+'\' AND Study_Site__r.Principal_Investigator__c = \''+String.escapeSingleQuotes(piId)+'\'';
            List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause, new List<Id>());
            totalCount = perList.size();
            for(Participant_Enrollment__c per : perList) {

                if(per.Invited_To_PP_Date__c != null) { // If Adult and no Delegates
                    invitedCount++;
                } else { //If Adult / Minor with Delegates
                    participantIds.add(per.Participant__c);
                }
            }

            if(participantIds.size() > 0) {      
                String whereClause = 'Where isInviteToPP__c = true' ;       
                participantList = DashboardParticipantCount.fetchParticipantRecords(participantIds,whereClause);          
                //participantList = DashboardParticipantCount.fetchParticipantRecords(participantIds);

                for(Participant__c participant:participantList) {
                    List<Patient_Delegate__c> delegateList = new List<Patient_Delegate__c>();
                    delegateList = participant.Participants__r;
                    if(delegateList.size() == 0) { // If no Delegates a participant is not invited
                        notInvitedCount++;
                    } else { // If any of the delegate is invited, Participant is invited
                        invitedCount++;                        
                    }

                }

            }
            resList.add(
                prepareBarItem(
                    '#D8EBF7',
                    'topBar',
                    invitedCount,                    
                    totalCount,
                    ''+totalCount
                )
            );
            resList.add(
                prepareBarItem(
                    '#83C7F4',                    
                    'secondBar',
                    notInvitedCount,
                    totalCount,
                    ''+totalCount
                )
            );
            
            return resList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static List<BarItem> participantLoginDashboard(Id pIid,Id ctpId) {
        try {
            List<BarItem> resList = new List<BarItem>();        
            Map<Id,List<Id>> invitedDelegateParticipantMap = new Map<Id,List<Id>>();
            Map<Id,Id> invitedParticipantMap = new Map<Id,Id>();
            List<Id> contactIdList = new List<Id>();
            Set<Id> contactIdSet = new set<Id>();
            Map<Id,Id> contactUserMap = new Map<Id,Id>();
            Integer loggeduser = 0;
            Integer notLoggedUser = 0;
            Integer totalCount = 0;
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
            String perWhereClause = 'AND study_Site__r.Clinical_Trial_Profile__c =\''+ String.escapeSingleQuotes(ctpId)+'\' AND Study_Site__r.Principal_Investigator__c = \''+String.escapeSingleQuotes(piId)+'\'';
			List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause, new List<Id>());
			for(Participant_Enrollment__c per : perList) {

				if(per.Invited_To_PP_Date__c != null) { // If Adult and no Delegates
					invitedParticipantMap.put(per.Participant__c,per.Participant_Contact__c);
				} //else { //If Adult / Minor with Delegates
				participantIds.add(per.Participant__c);
				//}
            }
				
            if(participantIds.size() > 0) {        
                String whereClause = 'Where isInviteToPP__c = true' ;       
                participantList = fetchParticipantRecords(participantIds,whereClause);

                for(Participant__c participant:participantList) {
                    List<Patient_Delegate__c> delegateList = new List<Patient_Delegate__c>();
                    delegateList = participant.Participants__r;
                    for(Patient_Delegate__c pd : delegateList) {
                        if(invitedDelegateParticipantMap.containsKey(pd.Participant__c)) {
                            List<Id> contactIds = new List<Id>();
                            contactIds = invitedDelegateParticipantMap.get(pd.Participant__c);
                            contactIds.add(pd.Contact__c);
                            invitedDelegateParticipantMap.put(pd.Participant__c,contactIds);
                        } else {
                            invitedDelegateParticipantMap.put(pd.Participant__c,new List<Id>{pd.Contact__c});
                        }						
                    }
                }

            }
            
            //Collate all contact IDs
            for(Id contactId:invitedParticipantMap.values()) {
                contactIdList.add(contactId);
            }
            
            for(List<Id> contactIds:invitedDelegateParticipantMap.values()) {
                contactIdList.addAll(contactIds);
            }

            //Convert List to set
            if(contactIdList.size() > 0) {
                contactIdSet = new set<Id>(contactIdList);
            }
            
            if(!contactIdSet.isEmpty()) {
            //Fetch Users Who are LoggedIn
                String whereClause = 'AND IsCommunityUserRegistered__c = true';
                Set<Id> contactLoggeduserSet = fetchUsersLoggedIn(contactIdSet,whereClause);
                Set<Id> perParticipantsinvLoggedIds = new set<Id>();
                
                
                //Process PER records
                for(Id participantId:invitedParticipantMap.keyset()) {
                    //contactIdList.add(contactId);
                    Id contactId = invitedParticipantMap.get(participantId);
                    if(contactLoggeduserSet.contains(contactId)) {
                        loggeduser++;   
                        perParticipantsinvLoggedIds.add(participantId);                 
                    }else {
                        if(!invitedDelegateParticipantMap.containsKey(participantId)) {
                            notLoggedUser++;
                        }
                    }
                }
                
                //Process Delegate Records
                //for(List<Id> contactIds:invitedDelegateParticipantMap.values()) {
                for(Id participantId : invitedDelegateParticipantMap.keyset()) {
                    List<Id> contactIds = new List<Id>();
                    contactIds = invitedDelegateParticipantMap.get(participantId);
                    Integer count = 0;
                    for(Id contactId:contactIds) {
                        if(contactLoggeduserSet.contains(contactId)) {
                            if(!perParticipantsinvLoggedIds.contains(participantId)) {
                                loggeduser++;
                                break;
                            }
                        } else {
                            count++;
                        }                  
                    }
                    if(count > 0 && count == contactIds.size() && !perParticipantsinvLoggedIds.contains(participantId)) {
                        notLoggedUser++;
                    }
                }
            }
            List<Id> totalCountIdList = new List<Id>();
            totalCountIdList.addAll(invitedDelegateParticipantMap.keyset());
            totalCountIdList.addAll(invitedParticipantMap.keySet());
            Set<Id> totalCountIdSet = new set<Id>();
            
            //Convert List to set
            if(totalCountIdList.size() > 0) {
                totalCountIdSet = new set<Id>(totalCountIdList);
            }
            if(!totalCountIdSet.isEmpty()) {
                totalCount = totalCountIdSet.size();
            } else {
                totalCount = 0;
            }
			//totalCount = invitedDelegateParticipantMap.keyset().size() + invitedParticipantMap.keySet().size();	
			resList.add(
                prepareBarItem(
                    '#D8EBF7',
                    'topBar',
                    loggeduser,                    
                    totalCount,
                    ''+totalCount
                )
            );
            resList.add(
                prepareBarItem(
                    '#83C7F4',                    
                    'secondBar',
                    notLoggedUser,
                    totalCount,
                    ''+totalCount
                )
            );
            
            return resList;
		} catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	
	private static Set<Id> fetchUsersLoggedIn(Set<Id> contactIds, String whereClause) {
		Set<Id> contactLoggeduserSet = new Set<Id>();
        String query = 'SELECT Id,isActive,ContactId,IsCommunityUserRegistered__c FROM USER'
                +' WHERE ContactId IN: contactIds ' + whereClause;
		
        List<User> userList = Database.query(query);
		/*List<User> userList = [SELECT Id,isActive,ContactId,IsCommunityUserRegistered__c 
                               	FROM User 
                               	WHERE IsCommunityUserRegistered__c = true AND contactId IN : contactIds];*/
		for(User userRec: userList) {
			contactLoggeduserSet.add(userRec.contactId);	
		}
		return contactLoggeduserSet;
	}
    
    public static List<Participant_Enrollment__c> fetchPerRecords(String whereClause,List<Id> participantIds) { 
        
        String query = 'SELECT Id,Invited_To_PP_Date__c,Participant__c,Participant__r.First_Name__c,Participant__r.Last_Name__c,'
            +'Participant_Contact__c,Participant_Contact__r.Is_Patient_User_Created__c,Participant__r.Email__c,Participant__r.Adult__c'
            +' FROM Participant_Enrollment__c'
            +' WHERE Study_Site__c != NULL'
            +' '+whereClause
            +' ORDER BY Createddate DESC';
        return Database.query(query);
    }
    
    private static List<Participant__c> fetchParticipantRecords(List<Id> participantIds, String whereClause) {
        String query = 'SELECT Id,Last_Name__c,First_Name__c,(SELECT Id, Participant__c,Status__c,Primary_Delegate__c,Contact__c,Participant_delegate__r.First_Name__c,'
                +'Participant_delegate__r.Last_Name__c,Participant_delegate__c,isInviteToPP__c,Participant_delegate__r.Email__c,Participant__r.First_Name__c,Participant__r.Last_Name__c'
                +' FROM Participants__r'
                +' '+whereClause+') FROM Participant__c WHERE Id IN: participantIds';
        return Database.query(query);        
    }

    private static BarItem prepareBarItem(
        String color,
        String title,
        Integer count,
        Integer maxPInD,
        String maxD
    ) {
        String width = title == maxD
            ? '60%'
            : count != 0 ? '' + Math.Round(70 / Math.Round(maxPInD / count)) + '%' : '1%';
        return new BarItem(color, width, title, '' + count);
    }

    @AuraEnabled
    public static List<ParticipantDetails> fetchParticipantsNotYetInvitedDetails(Id pIid,Id ctpId) {
        try {
            List<ParticipantDetails> resList = new List<ParticipantDetails>();
           
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
            String perWhereClause = ' AND study_Site__r.Study_Site_Type__c != \'Virtual\' AND study_Site__r.Study_Site_Type__c != \'Hybrid\' AND study_Site__r.Suppress_Participant_Emails__c=false';  
            perWhereClause += ' AND study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c =false AND study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true';
            perWhereClause += ' AND study_Site__r.Clinical_Trial_Profile__c =\''+ String.escapeSingleQuotes(ctpId)+'\' AND Study_Site__r.Principal_Investigator__c = \''+String.escapeSingleQuotes(piId)+'\'';
            
            List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause, new List<Id>());
            for(Participant_Enrollment__c per : perList) {
                ParticipantDetails parDetail = new ParticipantDetails();
                participantIds.add(per.Participant__c);
                if(per.Invited_To_PP_Date__c == null && per.Participant__r.Email__c != null && per.Participant__c != null && per.Participant__r.Adult__c) { // If Adult
                    parDetail.participantId = per.Participant__c;
                    parDetail.participantName = per.Participant__r.First_Name__c+' '+per.Participant__r.Last_Name__c;
                    parDetail.isChecked = false;
                    parDetail.datasetId = per.Participant__c;
                    resList.add(parDetail);
                } 
                
            }

            if(participantIds.size() > 0) {                
                participantList = DashboardParticipantCount.fetchParticipantRecords(participantIds,'');

                for(Participant__c participant:participantList) {
                    List<Patient_Delegate__c> delegateList = new List<Patient_Delegate__c>();
                    delegateList = participant.Participants__r;
                    for(Patient_Delegate__c pd:delegateList) {
                        ParticipantDetails parDetail = new ParticipantDetails();
                        if(!pd.isInviteToPP__c && participant.Id != null && pd.Participant_delegate__r.Email__c != null) {
                            parDetail.participantId = participant.Id;
                            parDetail.participantName = participant.First_Name__c+' '+participant.Last_Name__c;
                            parDetail.delegateId = pd.Participant_delegate__c;
                            parDetail.delegateParticipantName = pd.Participant_delegate__r.First_Name__c+' '+pd.Participant_delegate__r.Last_Name__c;
                            parDetail.isChecked = false;
                            parDetail.datasetId = (String)participant.Id+(String)pd.Participant_delegate__c;
                            resList.add(parDetail);
                        }
                    }
                }

            }            
            return resList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static Map<String,String> sendInviteToNotInvitedParticipants(String participantJson) {

        List<ParticipantDetails> participantDetails = (List<ParticipantDetails>)JSON.deserialize(participantJson,List<ParticipantDetails>.class);
        Map<String,String> resMap = new Map<String,String>();
        try {
            List<Id> participantIds = new List<Id>();
            List<Id> delegateParticipntIds = new List<Id>();
            for(ParticipantDetails parDetail:participantDetails) {
                if(parDetail.delegateId != null) {
                        delegateParticipntIds.add(parDetail.delegateId);
                } else {
                        participantIds.add(parDetail.participantId);
                }
            }
            if(!participantIds.isEmpty()) {
                BatchSendInviteToPP participantBatch = new BatchSendInviteToPP(participantIds);
                Database.executeBatch(participantBatch);
            }

            if(!delegateParticipntIds.isEmpty()) {
                BatchSendInviteToDelegates delegateBatch = new BatchSendInviteToDelegates(delegateParticipntIds);
                Database.executeBatch(delegateBatch);
            }
            resMap.put('message','Success');
            return resMap;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        /*for(ParticipantDetails parDetail:ParticipantDetails) {
           
            participantIds.add(parDetail.participantId);
           
        }
        String perWhereClause = ' AND Participant__c IN :participantIds';
        List<String> perIds = new List<String>();
        List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause,participantIds);
        for(Participant_Enrollment__c per:perList) {
            perIds.add(per.Id);
        }
        ListViewParticipantController.createUserForPatientProtal(perIds,true);*/
    }

    @AuraEnabled
    public static List<ParticipantDetails> fetchParticipantsNotYetLogInDetails(Id pIid,Id ctpId) {
        try {
            List<ParticipantDetails> resList = new List<ParticipantDetails>();
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
            Map<Id,Id> participantContactMap = new Map<Id,Id>();
            Map<Id,Participant__c> participantMap = new Map<Id,Participant__c>();
            Map<Id,Patient_Delegate__c> participantDelMap = new Map<Id,Patient_Delegate__c>();

            String perWhereClause = ' AND study_Site__r.Study_Site_Type__c != \'Virtual\' AND study_Site__r.Study_Site_Type__c != \'Hybrid\' AND study_Site__r.Suppress_Participant_Emails__c=false';  
            perWhereClause += ' AND study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c =false AND study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true';
            perWhereClause += ' AND study_Site__r.Clinical_Trial_Profile__c =\''+ String.escapeSingleQuotes(ctpId)+'\' AND Study_Site__r.Principal_Investigator__c = \''+String.escapeSingleQuotes(piId)+'\'';
            
            List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause, new List<Id>());
            for(Participant_Enrollment__c per : perList) {
                ParticipantDetails parDetail = new ParticipantDetails();
                participantIds.add(per.Participant__c);
                if(per.Invited_To_PP_Date__c != null && per.Participant__r.Email__c != null && per.Participant__c != null && per.Participant__r.Adult__c) { // If Adult
                    participantContactMap.put(per.Participant__c,per.Participant_Contact__c);
                    Participant__c part = new Participant__c(Id =per.Participant__c,
                                                            First_Name__c=per.Participant__r.First_Name__c,
                                                            Last_Name__c = per.Participant__r.Last_Name__c );
                    participantMap.put(per.Participant__c,part);
                } 
                
            }

            if(participantIds.size() > 0) {                
                participantList = DashboardParticipantCount.fetchParticipantRecords(participantIds,'');

                for(Participant__c participant:participantList) {
                    List<Patient_Delegate__c> delegateList = new List<Patient_Delegate__c>();
                    delegateList = participant.Participants__r;
                    for(Patient_Delegate__c pd:delegateList) {
                        ParticipantDetails parDetail = new ParticipantDetails();
                        if(pd.isInviteToPP__c && participant.Id != null && pd.Participant_delegate__r.Email__c != null) {
                            participantContactMap.put(pd.Participant_delegate__c,pd.Contact__c);
                            participantDelMap.put(pd.Participant__c,pd);
                        }
                    }
                }

            }
            Set<Id> usersNotLogged = new Set<Id>();
            if(!participantContactMap.isEmpty()) {
                String whereClause = 'AND IsCommunityUserRegistered__c = false';
                Set<Id> contactIds = new Set<Id>(participantContactMap.values());
                usersNotLogged = fetchUsersLoggedIn(contactIds,whereClause);
            }

            if(!usersNotLogged.isEmpty()) {
                for(Id participantId:participantContactMap.keySet()){
                    ParticipantDetails parDetail = new ParticipantDetails();
                    if(usersNotLogged.contains(participantContactMap.get(participantId))) {
                        if(participantMap.get(participantId) != null) {
                            parDetail.participantId = participantId;
                            parDetail.participantName = participantMap.get(participantId).First_Name__c+' '+participantMap.get(participantId).Last_Name__c;
                            parDetail.isChecked = false;
                            parDetail.datasetId = participantId;
                            resList.add(parDetail);
                        } else if(participantDelMap.get(participantId) != null) {
                            Patient_Delegate__c pd = participantDelMap.get(participantId);
                            parDetail.participantId = pd.participant__c;
                            parDetail.participantName = pd.participant__r.First_Name__c+' '+pd.participant__r.Last_Name__c;
                            parDetail.delegateId = participantId;
                            parDetail.delegateParticipantName = pd.Participant_delegate__r.First_Name__c+' '+pd.Participant_delegate__r.Last_Name__c;
                            parDetail.isChecked = false;
                            parDetail.datasetId = (String)pd.participant__c+(String)participantId;
                            resList.add(parDetail);
                        }

                    }
                }

            }

            return resList;

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}