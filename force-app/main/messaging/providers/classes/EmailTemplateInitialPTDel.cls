/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPTDel extends EmailTemplateInitialAbstract{

    public EmailTemplateInitialPTDel(Map<String, String> templateLabels, Id recipientContactId, String outputMode,
            String communityTemplateName) {
        super(templateLabels, recipientContactId, outputMode, communityTemplateName);
        headerLabel = LABEL_HEADER_INITIAL_PATIENT_DELEGATE;
        bodyLabel = LABEL_BODY_INITIAL_PATIENT_DELEGATE;
        signatureLabel = LABEL_SIGNATURE_NEW;

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