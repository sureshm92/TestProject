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
                        Participant__r.Contact__r.Current_Participant_Enrollment__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :recipientContactId
                ORDER BY CreatedDate DESC
        ];
        if(!patientDelegate.isEmpty()) {
            Id peId = patientDelegate.get(0).Participant__r.Contact__r.Current_Participant_Enrollment__c;
            if(peId == null) {
                List<Participant_Enrollment__c> enrollment = [
                        SELECT Id
                        FROM Participant_Enrollment__c
                        WHERE Participant__c = :patientDelegate.get(0).Participant__c
                ];
                if(!enrollment.isEmpty()) peId = enrollment.get(0).Id;
            }

            whatId = peId;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
        }
    }
}