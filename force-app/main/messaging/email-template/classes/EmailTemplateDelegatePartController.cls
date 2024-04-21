/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {
    global Id sourceIdValue { get; set; }
    global Id delegateId { get; set; }
    global String templateName{get; set;}
    //DEPRECATED
    global String delegateUserId { get; set; }
    global String commTemplateStr { get; set; }

    public List<String> getDelegateStudyNames() {
        List<Id> participantIds = new List<Id>();
        if (sourceIdValue != null) {
            if (sourceIdValue.getSobjectType() == Participant__c.getSObjectType()) {
                participantIds.add(sourceIdValue);
            } else if (
                sourceIdValue.getSobjectType() == Participant_Enrollment__c.getSObjectType()
            ) {
                List<Participant_Enrollment__c> pes = [
                    SELECT Id, Participant__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :sourceIdValue
                ];
                for (Participant_Enrollment__c pe : pes) {
                    participantIds.add(pe.Participant__c);
                }
            }
        } else {
            List<Id> delegatedParticipantIds = PatientDelegateEnrollmentService.getDelegatedParticipantIds(
                EmailTemplateProviderService.getProvider().getRecipientId()
            );
            if (delegatedParticipantIds != null)
                participantIds.addAll(delegatedParticipantIds);
        }

        List<String> delegateStudyNames = new List<String>();
        if (participantIds.isEmpty())
            return delegateStudyNames;

        /*List<Participant_Enrollment__c> delegatePE = [
            SELECT Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Participant_Enrollment__c
            WHERE
                Participant__c IN :participantIds
                AND Clinical_Trial_Profile__r.CommunityTemplate__c = :EmailTemplateProviderService.getProvider()
                    .getCommunityTemplateName()
				AND Study_Site__r.Study_Site_Type__c ='Traditional'
            	AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
            	AND Study_Site__r.Suppress_Participant_Emails__c = FALSE 
            	AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
            ORDER BY CreatedDate
        ];*/
        String contactIds;
        list<User> c;
        if (delegateId != null) {
            String objType = String.valueOf(delegateId.getSobjectType());
            system.debug('objType:::' + objType);
            if (objType == 'User') {
                c = [SELECT contactid FROM user WHERE id = :delegateId];
                contactIds = c[0].contactid;
            } else if (objType == 'Contact') {
                contactIds = delegateId;
            }
        }
        List<Patient_Delegate_Enrollment__c> pde = new List<Patient_Delegate_Enrollment__c> ();
        pde = [
            SELECT Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Patient_Delegate_Enrollment__c
            WHERE
                Participant_Enrollment__r.Participant__c IN :participantIds
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = :EmailTemplateProviderService.getProvider()
                    .getCommunityTemplateName() 
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen'
                AND Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c = 'Traditional'
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                AND Patient_Delegate__r.Contact__c = :contactIds
                AND Status__c = 'Active'
            ORDER BY CreatedDate
        ]; //1.0 
        String janssenTemplate; //1.0  janssen  2.0 pp
        if(pde.isEmpty()){            
            if(getTemplateText() =='Janssen'){
                janssenTemplate='PP 1.0';
            }
          
            pde = [
            SELECT Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Patient_Delegate_Enrollment__c
            WHERE
                Participant_Enrollment__r.Participant__c IN :participantIds
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen'
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c = : janssenTemplate
                AND Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c = 'Traditional'
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                AND Patient_Delegate__r.Contact__c = :contactIds
                AND Status__c = 'Active'
            ORDER BY CreatedDate
        ];

        }
        for (Patient_Delegate_Enrollment__c pe : pde)
            delegateStudyNames.add(
                pe.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            );

        return delegateStudyNames;
    }
    
    public String getTemplateText(){
        return templateName;
    }

    public String getBottomText() {
        return EmailTemplateProviderService.getProvider().getDelegateBottomTxt();
    }
}
