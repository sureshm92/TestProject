/**
 * Created by Igor Malyuta on 31.03.2020.
 */
public with sharing class EmailTemplateInitialPT extends EmailTemplateInitial {
    public EmailTemplateInitialPT(
        Id recipientContactId,
        String outputMode,
        String communityTemplateName
    ) {
        super(recipientContactId, outputMode, communityTemplateName);
        userMode = 'Participant Virtual';
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c> ();
        List<String> templates = new List<String>{ communityTemplateName };
        if (communityTemplateName == CommunityTemplateService.TEMPLATE_DEFAULT)
            templates.add(null);
        if(templates.contains('PatientPortal')){
            enrollments = [
            SELECT Id, Referral_Source__c, Study_Site__r.Study_Site_Type__c,Invited_to_PP_Date__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Contact__c = :recipientContactId
                AND (Clinical_Trial_Profile__r.CommunityTemplate__c IN :templates
                        OR Clinical_Trial_Profile__r.PPTemplate__c ='PP 2.0')
            ORDER BY CreatedDate DESC
        ];
        }
        else{
            enrollments = [
            SELECT Id, Referral_Source__c, Study_Site__r.Study_Site_Type__c,Invited_to_PP_Date__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Contact__c = :recipientContactId
                AND Clinical_Trial_Profile__r.CommunityTemplate__c IN :templates
            ORDER BY CreatedDate DESC
        ];
       }
        Participant_Enrollment__c enrollment;        
        if (!enrollments.isEmpty()) {
            for(Participant_Enrollment__c pe: enrollments){
                if(pe.Invited_to_PP_Date__c !=null){
                    enrollment = pe;
                    break;
                }
            }
            if(enrollment ==null){
                enrollment = enrollments.get(0);
            }
            whatId = enrollment.Id;
            studySiteType = enrollment.Study_Site__r.Study_Site_Type__c;
            parametersProviderName = 'Email_Template_Parameters_From_PE';
            if (enrollment.Referral_Source__c == 'PI') {
                userMode = 'Participant referred by PI';
            } else if (enrollment.Referral_Source__c == 'HCP') {
                userMode = 'Participant referred by HCP';
            }
        }
    }
}
