/**
 * Created by Nargiz Mamedova on 11/19/2019.
 */

public with sharing class SendPEToStudyHub extends RemoteCall{
    public Id participantEnrollmentId;

    public class IntegrationMessage{
        public String protocolId;
        public String rrid;
        public SubjectDetails subjectDetails;
        public ReferralDetails referralDetails;
        public AuditLog auditLog;
    }

    public class CommunicationPreferences {
        public String Language;
    }

    public class Address {
        public String Street;
        public String Street2;
        public String City;
        public String State;
        public String PostalCode;
        public String Country;
        public String CountryCode;
    }

    public class ReferralDetails {
        public String ReferralId;
        public Date ReferralDate;
        public Date AcceptedDate;
    }

    public class SubjectDetails {
        public String FirstName;
        public String LastName;
        public Address Address;
        public Contact Contact;
    }

    public class AuditLog {
        public String UserId;
        public Datetime Timestamp;
    }

    public class Contact {
        public String Email;
        public String Phone;
        public CommunicationPreferences CommunicationPreferences;
    }

    public SendPEToStudyHub(Id participantEnrollmentId) {
        this.endPointURL = 'callout:ServiceNowAndStudyHub';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'application/json'
        });
        this.participantEnrollmentId = participantEnrollmentId;
    }

    public override Type getType() {
        return SendPEToStudyHub.class;
    }

    protected override String buildRequestBody() {
        Participant_Enrollment__c pe = [
                SELECT Id,
                        Name,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Participant__r.Phone__c,
                        Participant__r.Email__c,
                        Participant__r.Mailing_City__c,
                        Participant__r.Mailing_State__c,
                        Participant__r.Mailing_State_Code__c,
                        Participant__r.Mailing_Zip_Postal_Code__c,
                        Participant__r.Mailing_Country__c,
                        Participant__r.Mailing_Country_Code__c,
                        Participant__r.Country_Code__c,
                        Participant__r.Country__c,
                        Participant__r.Mailing_Street__c,
                        Participant__r.Preferred_Language__c,
                        Referral_ID__c,
                        Referred_Date__c,
                        Study_Site__r.Protocol_ID__c,
                        Study_Site__r.Study_Site_Type__c
                FROM Participant_Enrollment__c
                WHERE Id =: participantEnrollmentId
        ];

        if(!StudySiteService.SS_TYPE_VT_INTEGRATION.contains(pe.Study_Site__r.Study_Site_Type__c)) return null;

        Address addr = new Address();
        addr.Street = pe.Participant__r.Mailing_Street__c;
        addr.Street2 = pe.Participant__r.Mailing_Street__c;
        addr.City = pe.Participant__r.Mailing_City__c;
        addr.State = pe.Participant__r.Mailing_State_Code__c;
        addr.PostalCode = pe.Participant__r.Mailing_Zip_Postal_Code__c;
        addr.Country = pe.Participant__r.Mailing_Country__c;
        addr.CountryCode = pe.Participant__r.Mailing_Country_Code__c;

        CommunicationPreferences communicationPreferences = new CommunicationPreferences();
        communicationPreferences.Language = pe.Participant__r.Preferred_Language__c;

        Contact contact = new Contact();
        contact.Email = pe.Participant__r.Email__c;
        contact.Phone = pe.Participant__r.Phone__c;
        contact.CommunicationPreferences = communicationPreferences;

        ReferralDetails referralDetails = new ReferralDetails();
        referralDetails.ReferralId = pe.Name;
        referralDetails.ReferralDate =  pe.Referred_Date__c;
        referralDetails.AcceptedDate = Date.today();

        SubjectDetails subjectDetails = new SubjectDetails();
        subjectDetails.FirstName = pe.Participant__r.First_Name__c;
        subjectDetails.LastName = pe.Participant__r.Last_Name__c;
        subjectDetails.Address = addr;
        subjectDetails.Contact = contact;

        AuditLog auditLog = new AuditLog();
        auditLog.UserId = UserInfo.getUserId();
        auditLog.Timestamp = Datetime.now();

        IntegrationMessage integrationMessage = new IntegrationMessage();
        integrationMessage.protocolId = pe.Study_Site__r.Protocol_ID__c;
        integrationMessage.rrid = pe.Id;
        integrationMessage.subjectDetails = subjectDetails;
        integrationMessage.referralDetails = referralDetails;
        integrationMessage.auditLog = auditLog;

        return JSON.serializePretty(integrationMessage, true);
    }

    protected override Object parseResponse(String responseBody) {
        return null;
    }

}