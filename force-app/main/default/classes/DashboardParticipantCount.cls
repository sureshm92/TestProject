public without sharing class DashboardParticipantCount {
    public DashboardParticipantCount() {

    }
    public static final String DELEGATE_STATUS_ACTIVE = 'Active'; // RH-5163
    public static final String DELEGATE_STATUS_DISCONNECTED = 'Disconnected';// RH-5163

    @AuraEnabled
    public static Map<String,Integer> participantInvitationDashboard(Id pIid,Id ctpId) {
        System.debug('parameters:'+piId+'  **'+ctpId);
        try {
            Map<String,Integer> invitationResponse = new Map<String,Integer>();
            Integer totalCount = 0;
            Integer invitedCount = 0;
            Integer notInvitedCount = 0;
            List<Id> participantIds = new List<Id>();
            List<Participant__c> participantList = new List<Participant__c>();

            List<Participant_Enrollment__c> perList = [
                SELECT
                    Id,
                    Invited_To_PP_Date__c,
                    Participant__c                
                FROM Participant_Enrollment__c
                WHERE Study_Site__c != NULL
                    AND study_Site__r.Clinical_Trial_Profile__c = :ctpId
                    AND Study_Site__r.Principal_Investigator__c = :piId
                ORDER BY Createddate DESC
            ];

            totalCount = perList.size();
            for(Participant_Enrollment__c per : perList) {

                if(per.Invited_To_PP_Date__c != null) { // If Adult and no Delegates
                    invitedCount++;
                } else { //If Adult / Minor with Delegates
                    participantIds.add(per.Participant__c);
                }
            }

            if(participantIds.size() > 0) {
                List<String> validStatus = new List<String>{DELEGATE_STATUS_ACTIVE,DELEGATE_STATUS_DISCONNECTED};
                participantList = [
                    SELECT Id,
                    (SELECT Id, Participant__c,Status__c,Primary_Delegate__c 
                        FROM Participants__r WHERE Status__c IN:validStatus AND isInviteToPP__c = true)
                    FROM Participant__c
                    WHERE Id IN: participantIds ];

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
            invitationResponse.put('TotalParticipants',totalCount);
            invitationResponse.put('Invited',invitedCount);
            invitationResponse.put('NotYetInvited',notInvitedCount);
            
            return invitationResponse;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}