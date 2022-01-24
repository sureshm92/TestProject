public without sharing class rpPatientOutreachController {
    @AuraEnabled(cacheable=false)                          
    public static list<Clinical_Trial_Profile__c> fetchOutreachInfo(list<string> peIds) {
        set<Clinical_Trial_Profile__c> studies = new set<Clinical_Trial_Profile__c>();
        for(Participant_Enrollment__c pe : [select  Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c, Clinical_Trial_Profile__r.Patient_Outreach_Info__c FROM Participant_Enrollment__c where id in : peids]){
            studies.add(new Clinical_Trial_Profile__c(id=pe.Clinical_Trial_Profile__c,Study_Code_Name__c=pe.Clinical_Trial_Profile__r.Study_Code_Name__c, Patient_Outreach_Info__c=pe.Clinical_Trial_Profile__r.Patient_Outreach_Info__c ));
        }
        return  new list<Clinical_Trial_Profile__c>(studies);
    }
    @AuraEnabled(cacheable=false)                          
    public static List<Participant_Enrollment__c> getPatientInfo(String peId) {
        List<Participant_Enrollment__c> res = [SELECT id, Outreach_Email_Status__c,Patient_ID__c,Participant_Name__c, Participant_Surname__c, Email__c, Study_Name__c, Legal_Status__c, YOB__c, Patient_Auth__c, Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c
               FROM Participant_Enrollment__c where Id=:peId and Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c = true];
        res[0].Outreach_Email_Status__c = 'Submitted';
        update res;
       return res;
    }
    //GN: created for bulk validation of PE records.
    @AuraEnabled
    public static Map<String,String> peBulkValidate(List<Id> listOfPeIds){
        List<rpPatientOutreachAPIController.PatientOutreachWrapper> patientOutreachWrapperList 
        = new List<rpPatientOutreachAPIController.PatientOutreachWrapper>();

        Map<String, String> peValidationResultMap = new Map<String, String>();
        List<Participant_Enrollment__c> peDetails = [SELECT id,Name,Patient_ID__c, Participant_Name__c, Participant_Surname__c, Email__c,Study_Name__c, 
                                                     Legal_Status__c, YOB__c, Patient_Auth__c,Outreach_Email_Status__c,Primary_Delegate_Email__c,Primary_Delegate_First_Name__c,
                                                     Primary_Delegate_Last_Name__c,CreatedDate,Mailing_Country_Code__c,
                                                     PI_Contact__r.Name,PI_Contact__r.Phone,PI_Contact__r.Language__c,PI_Contact__r.Email,PI_Contact__r.MailingCity,PI_Contact__r.MailingState,
                                                     PI_Contact__r.MailingCountry, PI_Contact__r.MailingPostalCode, PI_Contact__r.MailingAddress,PI_Contact__r.MailingStreet,
                                                     Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c,
                                                     Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c,Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c

                                                     FROM Participant_Enrollment__c 
                                                     WHERE Id IN : listOfPeIds]; 

        List<Participant_Enrollment__c> submittedPEs = new  List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c peRec : peDetails){
            String peRecValidationMsgs = '';
            Boolean isError = false;
            if(!peRec.Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Outreach not Supported';
                isError = true;
            }
            if(String.isBlank(peRec.Patient_ID__c)){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Patient Id';
                isError = true;
            }
            if(String.isBlank(peRec.Participant_Name__c)){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'First Name';
                isError = true;
            }
            if(String.isBlank(peRec.Participant_Surname__c)){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Last Name';
                isError = true;
            }
            if(String.isBlank(peRec.Email__c)){
                if(String.isBlank(peRec.Primary_Delegate_Email__c)){
                    peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Email';
                    isError = true;
                }
            }
            if(String.isBlank(peRec.Study_Name__c)){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Study Name';
                isError = true;
            }
            if(peRec.Legal_Status__c != 'Yes'){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Legal Status';
                isError = true;
            }
            if(String.isBlank(peRec.YOB__c)){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'YOB';
                isError = true;
            }
            if(peRec.Patient_Auth__c != 'Yes'){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Patient Auth';
                isError = true;
            }
            if(peRec.Outreach_Email_Status__c == 'Submitted'){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Outreach already initiated';
                isError = true;
            }
            if(peRec.Outreach_Email_Status__c == 'Delivered'){
                peRecValidationMsgs = peRecValidationMsgs + ', ' + 'Outreach was sent';
                isError = true;
            }
            if(isError){          
                peValidationResultMap.put(peRec.Patient_ID__c,peRecValidationMsgs.substring(1));
            }     
            else if(!isError){
                peRec.Outreach_Email_Status__c = 'Submitted';
                peRec.Outreach_Mail_Sent__c = 'Yes';
                rpPatientOutreachAPIController.PatientOutreachWrapper outreachWrapper = rpPatientOutreachAPIController.generateObjectToJSON(peRec);
                patientOutreachWrapperList.add(outreachWrapper);
                submittedPEs.add(peRec);
            }
        }     
        try{
            if(!submittedPEs.isEmpty()){
                String json = JSON.serialize(patientOutreachWrapperList);
                rpPatientOutreachAPIController.sendDataToMuleSoft(json);
                update submittedPEs;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return peValidationResultMap;
    }


}