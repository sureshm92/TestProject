/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPTDel extends EmailTemplateInitial {
    public EmailTemplateInitialPTDel(
        Id recipientContactId,
        String outputMode,
        String communityTemplateName
    ) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'Participant Delegate';

        
       /*
        * commenting this as previous logic was based on patient delegates
        * 
        *  List<Patient_Delegate__c> patientDelegate = [
            SELECT
                Id,
                Participant__c,
                Participant__r.Contact__r.Current_Participant_Enrollment__c,
                Participant__r.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :recipientContactId order by lastModifiedDate desc
        ];
        
        if (!patientDelegate.isEmpty()) {
            Set<Id> participantIds = new Set<Id>();
            for (Patient_Delegate__c pd : patientDelegate){
                participantIds.add(pd.Participant__c);
                //if(pd.)
            }
            
            Participant__c participant = patientDelegate.get(0).Participant__r;
            if (
                participant.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                communityTemplateName
            ) {
                peId = participant.Contact__r.Current_Participant_Enrollment__c;
            } else {
                List<Participant_Enrollment__c> enrollment = [
                    SELECT Id
                    FROM Participant_Enrollment__c
                    WHERE
                        Participant__c IN :participantIds
                        AND Clinical_Trial_Profile__r.CommunityTemplate__c = :communityTemplateName
                    ORDER BY CreatedDate DESC
                ];
                if (!enrollment.isEmpty())
                    peId = enrollment.get(0).Id;
            } */
           
           // now what Id is assigned based on latest PDER record.
           Id peId;
           
           List<Patient_Delegate_Enrollment__c> pder =  [SELECT Id,Participant_Enrollment__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,LastModifiedDate
            FROM Patient_Delegate_Enrollment__c where Patient_delegate__r.contact__c =: recipientContactId
            ORDER By LastModifiedDate DESC];
        	if(!pder.isEmpty()){
            	peId = pder[0].Participant_Enrollment__c;
        	}
            whatId = peId;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
        }
    }
