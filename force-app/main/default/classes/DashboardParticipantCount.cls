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

    @AuraEnabled
    public static List<BarItem> participantInvitationDashboard(Id pIid,Id ctpId) {
        System.debug('parameters:'+piId+'  **'+ctpId);
        try {
            List<BarItem> resList = new List<BarItem>();
            Integer totalCount = 0;
            Integer invitedCount = 0;
            Integer notInvitedCount = 0;
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
            List<Id> InvitedContactIds = new List<Id>();

            List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(pIid,ctpId);
            totalCount = perList.size();
            for(Participant_Enrollment__c per : perList) {

                if(per.Invited_To_PP_Date__c != null) { // If Adult and no Delegates
                    invitedCount++;
                } else { //If Adult / Minor with Delegates
                    participantIds.add(per.Participant__c);
                }
            }

            if(participantIds.size() > 0) {                
                participantList = DashboardParticipantCount.fetchParticipantRecords(participantIds);

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
            Set<Id> contactIdSet;
            Map<Id,Id> contactUserMap = new Map<Id,Id>();
            Integer loggeduser = 0;
            Integer notLoggedUser = 0;
            Integer totalCount = 0;
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();
		
			List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(pIid,ctpId);
			for(Participant_Enrollment__c per : perList) {

				if(per.Invited_To_PP_Date__c != null) { // If Adult and no Delegates
					invitedParticipantMap.put(per.Participant__c,per.Participant_Contact__c);
				} //else { //If Adult / Minor with Delegates
				participantIds.add(per.Participant__c);
				//}
            }
				
            if(participantIds.size() > 0) {                
                participantList = fetchParticipantRecords(participantIds);

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
            
            //Fetch Users Who are LoggedIn
            Set<Id> contactLoggeduserSet = fetchUsersLoggedIn(contactIdSet);
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
            List<Id> totalCountIdList = new List<Id>();
            totalCountIdList.addAll(invitedDelegateParticipantMap.keyset());
            totalCountIdList.addAll(invitedParticipantMap.keySet());
            Set<Id> totalCountIdSet;
            
            //Convert List to set
            if(totalCountIdList.size() > 0) {
                totalCountIdSet = new set<Id>(totalCountIdList);
            }
            totalCount = totalCountIdSet.size();
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
	
	private static Set<Id> fetchUsersLoggedIn(Set<Id> contactIds) {
		Set<Id> contactLoggeduserSet = new Set<Id>();
		
		List<User> userList = [SELECT Id,isActive,ContactId,LastLoginDate 
                               	FROM User 
                               	WHERE LastLoginDate != null AND contactId IN : contactIds];
		for(User userRec: userList) {
			contactLoggeduserSet.add(userRec.contactId);	
		}
		return contactLoggeduserSet;
	}
    
    private static List<Participant_Enrollment__c> fetchPerRecords(Id pIid,Id ctpId) {        
        return ([
                SELECT
                    Id,
                    Invited_To_PP_Date__c,
                    Participant__c,
            		Participant_Contact__c,
                	Participant_Contact__r.Is_Patient_User_Created__c
                FROM Participant_Enrollment__c
                WHERE Study_Site__c != NULL
                    AND study_Site__r.Clinical_Trial_Profile__c = :ctpId
                    AND Study_Site__r.Principal_Investigator__c = :piId
                ORDER BY Createddate DESC
            ]);
    }
    
    private static List<Participant__c> fetchParticipantRecords(List<Id> participantIds) {
        return([
            SELECT Id,
            (SELECT Id, Participant__c,Status__c,Primary_Delegate__c,Contact__c
             FROM Participants__r WHERE isInviteToPP__c = true)
            FROM Participant__c
            WHERE Id IN: participantIds ]);
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
}