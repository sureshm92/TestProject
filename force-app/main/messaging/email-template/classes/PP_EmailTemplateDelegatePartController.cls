global without sharing class PP_EmailTemplateDelegatePartController {
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
        List<String> delegateCommunitytyNames = new List<String>();
        if (participantIds.isEmpty())
            return delegateStudyNames;
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
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
            LastModifiedDate
            FROM Patient_Delegate_Enrollment__c
            WHERE
                Participant_Enrollment__r.Participant__c IN :participantIds
                AND Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c = 'Traditional'
            	AND (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'PatientPortal' OR
                (Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = 'Janssen' AND 
                 Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c ='PP 2.0' ) )  
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                AND Patient_Delegate__r.Contact__c = :contactIds
                AND Status__c = 'Active'
            ORDER BY LastmodifiedDate DESC
        ]; 
        for (Patient_Delegate_Enrollment__c pe : filterPatientDelegates(pde)){           
                    delegateStudyNames.add(
                    pe.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                );
            
        }
        return delegateStudyNames;
    }
    
    public List<Patient_Delegate_Enrollment__c> filterPatientDelegates(List<Patient_Delegate_Enrollment__c> pdeList){
        Set<Id> latestPdes = new Set<Id>();
		List<Patient_Delegate_Enrollment__c> filteredPdes = new List<Patient_Delegate_Enrollment__c>();        
        Datetime latestDate;
        Set<String> templates  = new Set<String>();
        for(Integer i=0;i<pdeList.size();i++){
            if(i==0)
              latestDate = pdeList[i].LastmodifiedDate;
            if(pdeList[i].LastModifiedDate == latestDate){
                latestPdes.add(pdeList[i].id);
                templates.add(pdeList[i].Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
            }
        }
        if(!latestPdes.isEmpty() && latestPdes.size() > 1 && templates.size() >1 ){
           return  pdeList;
        }
        String templatename = (!templates.isEmpty()) ? new List<String>(templates)[0] : '';
        for(Patient_Delegate_Enrollment__c pd : pdeList){
            if(pd.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c == templatename )
                filteredPdes.add(pd);
        }
        return filteredPdes;
    }
    
    
    public String getTemplateText(){
        return templateName;
    }
    public String getSourceTemplateText(){
       List<Patient_Delegate_Enrollment__c> pdes =  [SELECT Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.PPTemplate__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Patient_Delegate_Enrollment__c where Id=: sourceIdValue];
        system.debug('enrollments:'+pdes[0].Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
        
        return pdes[0].Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
    }

    public String getBottomText() {
        return EmailTemplateProviderService.getProvider().getDelegateBottomTxt();
    }
}