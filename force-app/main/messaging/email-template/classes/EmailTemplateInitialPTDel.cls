/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPTDel extends EmailTemplateInitial {

    public EmailTemplateInitialPTDel(Id recipientContactId, String outputMode, String communityTemplateName) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'Participant Delegate';

        List<Patient_Delegate__c> patientDelegate = [
                SELECT
                        Id,
                        Participant__c,
                        Participant__r.Contact__r.Current_Participant_Enrollment__c,
                        Participant__r.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :recipientContactId
        ];
        if (!patientDelegate.isEmpty()) {
            Set<Id> participantIds = new Set<Id>();
            for(Patient_Delegate__c pd : patientDelegate) participantIds.add(pd.Participant__c);
            Id peId;
            Participant__c participant = patientDelegate.get(0).Participant__r;
            if (participant.Contact__r.Current_Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == communityTemplateName) {
                peId = participant.Contact__r.Current_Participant_Enrollment__c;
            } else {
                List<Participant_Enrollment__c> enrollment = [
                        SELECT Id
                        FROM Participant_Enrollment__c
                        WHERE Participant__c IN:participantIds
                        AND Clinical_Trial_Profile__r.CommunityTemplate__c = :communityTemplateName
                        ORDER BY CreatedDate DESC
                ];
                if (!enrollment.isEmpty()) peId = enrollment.get(0).Id;
            }

            whatId = peId;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
        }
    }
}