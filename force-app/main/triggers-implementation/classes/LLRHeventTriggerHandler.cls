public with sharing class LLRHeventTriggerHandler{
    
    public class SendFOVtoAPI extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            sendtoAPIafterInsert((List<LL_RH_event__e>) newList);
        }
    }
    
    @TestVisible
    private static void sendtoAPIafterInsert(
        List<LL_RH_event__e> newList
    ){
        System.debug('### newList ' +newList);
        Map<String,String> perIdToStatus = new Map<String,String>();
        Map<String,String> perIdToAppointmentId = new Map<String,String>();
        List<Id> allPerId = new List<Id>();
        for (LL_RH_event__e evnt : newList) {
            allPerId.add(Id.valueOf(evnt.ParticipantEnrollment_ID__c));
            perIdToStatus.put(evnt.ParticipantEnrollment_ID__c, evnt.Status__c);
            perIdToAppointmentId.put(evnt.ParticipantEnrollment_ID__c, evnt.Appointment_Id__c);
        }

        List<Llwrapper> llwrapList = new List<Llwrapper>();
        List<Id> conIdList = new List<Id>();
        Map<Id,Id> conIdToPerId = new Map<Id,Id>();
        List<Participant_Enrollment__c> perList = [SELECT Id, Name, Referral_ID__c, Study_Site__c, Study_Site__r.Name, Study_Site__r.Scheduling_vendors__c, LastModifiedById, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c, Permit_SMS_Text_for_this_study__c, Permit_Mail_Email_contact_for_this_study__c, Participant__r.Language_Preference_Code__c,Participant_Contact__c, Participant_Contact__r.Participant_Opt_In_Status_Emails__c, Participant_Contact__r.Participant_Opt_In_Status_SMS__c, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Protocol_ID__c, CreatedDate, Participant_Contact__r.CreatedDate FROM Participant_Enrollment__c where Id IN :allPerId];
        List<Participant_Enrollment__History> perHistory = [SELECT ParentId, CreatedDate,DataType,Field,NewValue,OldValue FROM Participant_Enrollment__History WHERE Field = 'Permit_Mail_Email_contact_for_this_study__c' OR Field = 'Permit_SMS_Text_for_this_study__c' ORDER BY CreatedDate DESC];
        
        Map<Id,Datetime> perIdToDateEmail = new Map<Id,Datetime>();
        Map<Id,Datetime> perIdToDateSms = new Map<Id,Datetime>();
        List<String> refName = new List<String>();

        for (Participant_Enrollment__c p: perList){
            conIdList.add(p.Participant_Contact__c);
            conIdToPerId.put(p.Participant_Contact__c,p.Id);
            Boolean ifPermitEmailFound = false;
            Boolean ifPermitSmsFound = false;
            refName.add(p.Name);

            for (Participant_Enrollment__History peh: perHistory){
                if(!ifPermitEmailFound && peh.Field == 'Permit_Mail_Email_contact_for_this_study__c' && p.Id == peh.ParentId){
                    perIdToDateEmail.put(peh.ParentId, peh.CreatedDate);
                    ifPermitEmailFound = true;
                    // break;
                }

                if(!ifPermitSmsFound && peh.Field == 'Permit_SMS_Text_for_this_study__c' && p.Id == peh.ParentId){
                    perIdToDateSms.put(peh.ParentId, peh.CreatedDate);
                    ifPermitSmsFound = true;
                    // break;
                }
            }
        }

        List<Integration_Patient_Referral__c> eprList = [SELECT ePRPatient_ID_Number__c, Participant_Enrollment__c, Participant_Enrollment__r.Name FROM Integration_Patient_Referral__c where Participant_Enrollment__r.Name In :refName];
        Map<String,String> refNameToEprId = new Map<String,String>();
        for (Integration_Patient_Referral__c ep: eprList){
            refNameToEprId.put(ep.Participant_Enrollment__r.Name, ep.ePRPatient_ID_Number__c);
        }

        List<ContactHistory> conHistory = [SELECT ContactId,CreatedDate,DataType,Field,NewValue,OldValue FROM ContactHistory WHERE ContactId In :conIdList AND (Field = 'Participant_Opt_In_Status_Emails__c' OR Field = 'Participant_Opt_In_Status_SMS__c') ORDER BY CreatedDate DESC];

        Map<Id,Datetime> conIdToDateEmail = new Map<Id,Datetime>();
        Map<Id,Datetime> conIdToDateSms = new Map<Id,Datetime>();

        for (Id c: conIdList){
            Boolean ifOptInEmailFound = false;
            Boolean ifOptInSmsFound = false;
            for (ContactHistory conH: conHistory){
                if(!ifOptInEmailFound && conH.Field == 'Participant_Opt_In_Status_Emails__c' && c == conH.ContactId){
                    conIdToDateEmail.put(conIdToPerId.get(c), conH.CreatedDate);
                    ifOptInEmailFound = true;
                    // break;
                }

                if(!ifOptInSmsFound && conH.Field == 'Participant_Opt_In_Status_SMS__c' && c == conH.ContactId){
                    conIdToDateSms.put(conIdToPerId.get(c), conH.CreatedDate);
                    ifOptInSmsFound = true;
                    // break;
                }
            }
            
        }

        for (Participant_Enrollment__c pe : perList){

            String email = getParticipantEmailPreference(pe,perIdToDateEmail,conIdToDateEmail);
            String sms = getParticipantSmsPreference(pe,perIdToDateSms,conIdToDateSms);

            Llwrapper llwrap = new Llwrapper();
            llwrap.referalId                        = pe.Name;
            llwrap.status                           = perIdToStatus.get(String.valueOf(pe.Id));
            llwrap.appointmentId                    = perIdToAppointmentId.get(String.valueOf(pe.Id));
            llwrap.protocolId                       = pe.Clinical_Trial_Profile__r.Protocol_ID__c;
            llwrap.eprId                            = ((refNameToEprId.get(pe.Name) != null)? (refNameToEprId.get(pe.Name)) : (pe.Name));
            llwrap.initialVisitDate                 = pe.Initial_visit_scheduled_date__c;
            llwrap.initialVisitTime                 = pe.Initial_visit_scheduled_time__c;
            llwrap.schedulingSponsor                = pe.Study_Site__r.Scheduling_vendors__c;
            llwrap.participantPreferredLanguage     = pe.Participant__r.Language_Preference_Code__c;
            llwrap.communicationPreference          = email + ',' + sms;

            llwrapList.add(llwrap);

        }
        String fovDetails = JSON.serialize(llwrapList);
        sendToLL(fovDetails);
        
    }

    @future(callout=true)
    public static void sendToLL(String fovDetails){
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint('callout:LL_RH_integration');
        r.setHeader('Content-Type', 'application/json;charset=UTF-8');
        r.setMethod('POST');
        r.setbody(fovDetails);
        System.debug('###### request ' +r.getBody());
        HTTPResponse resp = h.send(r);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());

        List<Integration_Callout_Log__c> apiCalloutList = new List<Integration_Callout_Log__c>();
        JsonParser parser = JSON.createParser(resp.getBody());
        List<ResponseWrapper> deserializedResponseWrapper = (List<ResponseWrapper>)JSON.deserialize(resp.getBody(), List<ResponseWrapper>.class);
        
        for (ResponseWrapper wrap: deserializedResponseWrapper){
            Integration_Callout_Log__c apiCall      = new Integration_Callout_Log__c();
            apiCall.Reference_Id__c         = wrap.rhId;
            apiCall.Status_Code__c          = Integer.valueOf(wrap.statusCode);
            apiCall.Comment__c              = wrap.message;
            apiCall.success__c              = wrap.success;
            apiCall.third_party_Id__c       = wrap.redoxId;
            apiCall.Server_Status_Code__c   = resp.getStatusCode();
            apiCall.Server_Status__c        = resp.getStatus();

            apiCalloutList.add(apiCall);
        }

        try {
           if(apiCalloutList.size() > 0){
               insert apiCalloutList;
           }
        } catch (Exception  e) {
           System.debug('e.getMessage(): ' + e.getMessage());
           System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
        }
    }

    private static String getParticipantEmailPreference(Participant_Enrollment__c pe, Map<Id,Datetime> perIdToDateEmail, Map<Id,Datetime> conIdToDateEmail) {
        String s = null;
        Datetime d1 = perIdToDateEmail.get(pe.Id);
        Datetime d2 = conIdToDateEmail.get(pe.Id);
        if(d1 != null && d2 != null){
            if(d1>=d2){
                if(pe.Permit_Mail_Email_contact_for_this_study__c){
                    s = 'Email';
                }
            }else{
                if(pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c){
                    s = 'Email';
                }
            }
        }else{
            if(d1 == null && d2 != null){
                if(pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c){
                    s = 'Email';
                }
            }else if(d1 != null && d2 == null){
                if(pe.Permit_Mail_Email_contact_for_this_study__c){
                    s = 'Email';
                }
            }else{
                if(pe.CreatedDate >= pe.Participant_Contact__r.CreatedDate){
                    if(pe.Permit_Mail_Email_contact_for_this_study__c){
                        s = 'Email';
                    }
                }else{
                    if(pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c){
                        s = 'Email';
                    }
                }
            }
        }
        
        return s;
    }

    private static String getParticipantSmsPreference(Participant_Enrollment__c pe, Map<Id,Datetime> perIdToDateSms, Map<Id,Datetime> conIdToDateSms) {
        String s = null;
        Datetime d1 = perIdToDateSms.get(pe.Id);
        Datetime d2 = conIdToDateSms.get(pe.Id);

        if(d1 != null && d2 != null){
            if(d1>=d2){
                if(pe.Permit_SMS_Text_for_this_study__c){
                    s = 'SMS';
                }
            }else{
                if(pe.Participant_Contact__r.Participant_Opt_In_Status_SMS__c){
                    s = 'SMS';
                }
            }
        }else{
            if(d1 == null && d2 != null){
                if(pe.Participant_Contact__r.Participant_Opt_In_Status_SMS__c){
                    s = 'SMS';
                }
            }else if(d1 != null && d2 == null){
                if(pe.Permit_SMS_Text_for_this_study__c){
                    s = 'SMS';
                }
            }else{
                if(pe.CreatedDate >= pe.Participant_Contact__r.CreatedDate){
                    if(pe.Permit_SMS_Text_for_this_study__c){
                        s = 'SMS';
                    }
                }else{
                    if(pe.Participant_Contact__r.Participant_Opt_In_Status_SMS__c){
                        s = 'SMS';
                    }
                }
            }
        }
        
        return s;
    }

    public class Llwrapper{
        public String referalId;
        public String status;
        public Date initialVisitDate;
        public Time initialVisitTime;
        public String schedulingSponsor;
        public String communicationPreference;
        public String participantPreferredLanguage;
        public String appointmentId;
        public String protocolId;
        public String eprId;
    }

    public class ResponseWrapper{
        public Boolean success;
        public String rhId;
        public String redoxId;
        public String statusCode;
        public String message;
    }

}