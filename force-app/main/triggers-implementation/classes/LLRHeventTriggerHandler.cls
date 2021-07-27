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
        Map<String,String> perIdToOldAppointmentDate = new Map<String,String>();
        Map<String,String> perIdToOldAppointmentTime = new Map<String,String>();
        List<Id> allPerId = new List<Id>();
        for (LL_RH_event__e evnt : newList) {
            allPerId.add(Id.valueOf(evnt.ParticipantEnrollment_ID__c));
            perIdToStatus.put(evnt.ParticipantEnrollment_ID__c, evnt.Status__c);
            perIdToAppointmentId.put(evnt.ParticipantEnrollment_ID__c, evnt.Appointment_Id__c);
            perIdToOldAppointmentDate.put(evnt.ParticipantEnrollment_ID__c, evnt.OldAppointmentDate__c);
            perIdToOldAppointmentTime.put(evnt.ParticipantEnrollment_ID__c, evnt.OldAppointmentTime__c);
        }

        List<Llwrapper> llwrapList = new List<Llwrapper>();
        List<Id> conIdList = new List<Id>();
        Map<Id,Id> conIdToPerId = new Map<Id,Id>();
        List<Participant_Enrollment__c> perList = [SELECT Id, Name, Participant_Status__c, Referral_ID__c, Study_Site__c, Study_Site__r.Name, Study_Site__r.Scheduling_vendors__c, Study_Site__r.Study_Site_Number__c, LastModifiedById, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c, Permit_SMS_Text_for_this_study__c, Permit_Mail_Email_contact_for_this_study__c, Participant__r.Preferred_Language__c,Participant_Contact__c, Participant_Contact__r.Participant_Opt_In_Status_Emails__c, Participant_Contact__r.Participant_Opt_In_Status_SMS__c, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.Protocol_ID__c, CreatedDate, Participant_Contact__r.CreatedDate, Participant__r.First_Name__c, Participant__r.Last_Name__c, Participant__r.Date_of_Birth__c, Participant__r.Phone__c, Participant__r.Alternative_Phone_Number__c, Participant__r.Alternative_Phone_Type__c, Participant__r.Phone_Type__c , Site_Communication_Preference__c FROM Participant_Enrollment__c where Id IN :allPerId];
        List<Participant_Enrollment__History> perHistory = [SELECT ParentId, CreatedDate,DataType,Field,NewValue,OldValue FROM Participant_Enrollment__History WHERE Field = 'Permit_Mail_Email_contact_for_this_study__c' OR Field = 'Permit_SMS_Text_for_this_study__c' ORDER BY CreatedDate DESC];
        System.debug('### perList ' +perList);
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
            String email;
            String sms;
            // if(!pe.Site_Communication_Preference__c){
                email = getParticipantEmailPreference(pe,perIdToDateEmail,conIdToDateEmail);
                sms = getParticipantSmsPreference(pe,perIdToDateSms,conIdToDateSms);
            // }

            Llwrapper llwrap = new Llwrapper();
            Llwrapper llwrap1 = new Llwrapper();

            llwrap.referralId                       = pe.Name;
            llwrap.status                           = 'SubjectUpdate';
            llwrap.appointmentId                    = perIdToAppointmentId.get(String.valueOf(pe.Id));
            llwrap.oldInitialVisitDate               = perIdToOldAppointmentDate.get(String.valueOf(pe.Id));
            llwrap.oldInitialVisitTime               = perIdToOldAppointmentTime.get(String.valueOf(pe.Id));
            llwrap.protocolId                       = pe.Clinical_Trial_Profile__r.Protocol_ID__c;
            llwrap.eprId                            = (pe.Referral_ID__c != null ? pe.Referral_ID__c : pe.Name);
            llwrap.siteId                           = pe.Study_Site__r.Study_Site_Number__c;
            llwrap.initialVisitDate                 = pe.Initial_visit_scheduled_date__c;
            llwrap.initialVisitTime                 = pe.Initial_visit_scheduled_time__c;
            llwrap.schedulingSponsor                = pe.Study_Site__r.Scheduling_vendors__c;
            llwrap.participantPreferredLanguage     = pe.Participant__r.Preferred_Language__c;
            llwrap.communicationPreference          = email + ',' + sms;
            // llwrap.siteCommunicationPreference      = pe.Site_Communication_Preference__c;
            llwrap.participantFirstName             = pe.Participant__r.First_Name__c;
            llwrap.participantLastName              = pe.Participant__r.Last_Name__c;
            llwrap.participantDOB                   = pe.Participant__r.Date_of_Birth__c;
            if(pe.Participant__r.Alternative_Phone_Type__c == 'Mobile' && pe.Participant__r.Alternative_Phone_Number__c != null){
                llwrap.participantMobileNumber      = pe.Participant__r.Alternative_Phone_Number__c;
            }else if(pe.Participant__r.Phone_Type__c == 'Mobile'){
                llwrap.participantMobileNumber      = pe.Participant__r.Phone__c;
            }
            llwrap.participantStatus                = pe.Participant_Status__c;

            llwrap1.referralId                       = pe.Name;
            llwrap1.status                           = perIdToStatus.get(String.valueOf(pe.Id));
            llwrap1.appointmentId                    = perIdToAppointmentId.get(String.valueOf(pe.Id));
            llwrap1.oldInitialVisitDate               = perIdToOldAppointmentDate.get(String.valueOf(pe.Id));
            llwrap1.oldInitialVisitTime              = perIdToOldAppointmentTime.get(String.valueOf(pe.Id));
            llwrap1.protocolId                       = pe.Clinical_Trial_Profile__r.Protocol_ID__c;
            llwrap1.eprId                            = (pe.Referral_ID__c != null ? pe.Referral_ID__c : pe.Name);
            llwrap1.siteId                           = pe.Study_Site__r.Study_Site_Number__c;
            llwrap1.initialVisitDate                 = pe.Initial_visit_scheduled_date__c;
            llwrap1.initialVisitTime                 = pe.Initial_visit_scheduled_time__c;
            llwrap1.schedulingSponsor                = pe.Study_Site__r.Scheduling_vendors__c;
            llwrap1.participantPreferredLanguage     = pe.Participant__r.Preferred_Language__c;
            llwrap1.communicationPreference          = email + ',' + sms;
            // llwrap1.siteCommunicationPreference      = pe.Site_Communication_Preference__c;
            llwrap1.participantFirstName             = pe.Participant__r.First_Name__c;
            llwrap1.participantLastName              = pe.Participant__r.Last_Name__c;
            llwrap1.participantDOB                   = pe.Participant__r.Date_of_Birth__c;
            if(pe.Participant__r.Alternative_Phone_Type__c == 'Mobile' && pe.Participant__r.Alternative_Phone_Number__c != null){
                llwrap1.participantMobileNumber      = pe.Participant__r.Alternative_Phone_Number__c;
            }else if(pe.Participant__r.Phone_Type__c == 'Mobile'){
                llwrap1.participantMobileNumber      = pe.Participant__r.Phone__c;
            }
            llwrap1.participantStatus                = pe.Participant_Status__c;

            llwrapList.add(llwrap);
            llwrapList.add(llwrap1);

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
        public String referralId;
        public String status;
        public Date initialVisitDate;
        public Time initialVisitTime;
        public String schedulingSponsor;
        public String communicationPreference;
        public String participantPreferredLanguage;
        public String appointmentId;
        public String protocolId;
        public String eprId;
        public String siteId;
        public String participantFirstName;
        public String participantLastName;
        public String participantDOB;
        public String participantMobileNumber;
        public String participantStatus;
        public String oldInitialVisitDate;
        public String oldInitialVisitTime;
        // public Boolean siteCommunicationPreference;
    }

    public class ResponseWrapper{
        public Boolean success;
        public String rhId;
        public String redoxId;
        public String statusCode;
        public String message;
    }

}