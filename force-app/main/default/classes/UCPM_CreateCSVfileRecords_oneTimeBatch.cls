global without sharing class UCPM_CreateCSVfileRecords_oneTimeBatch implements Database.Batchable<SObject>, Database.Stateful {
  public Set<ID> conUniqueID = new Set<ID>();
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          PPMID__c,
          UCPM_Status__c,
          Permit_Voice_Text_contact_for_this_study__c,
          Study_Phone_Consent_Time__c,
          Permit_Mail_Email_contact_for_this_study__c,
          Study_Email_Consent_Time__c,
          Permit_SMS_Text_for_this_study__c,
          Study_SMS_Consent_Time__c,
          Study_Direct_Mail_Consent__c,
          Study_Direct_Mail_Consent_Time__c,
          Participant__c,
          Participant__r.Mailing_Country_Code__c,
          Participant_Contact__c,
          Participant_Contact__r.PPM_ID__c,
          Participant_Contact__r.UCPM_Status__c,
          Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
          Participant_Contact__r.IQVIA_Phone_Consent_Time__c,
          Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
          Participant_Contact__r.IQVIA_Email_Consent_Time__c,
          Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
          Participant_Contact__r.IQVIA_SMS_Consent_Time__c,
          Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
          Participant_Contact__r.IQVIA_Direct_Mail_Consent_Time__c,
          Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
          Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
          Clinical_Trial_Profile__r.Study_Code_Name__c,
          Clinical_Trial_Profile__r.NCT_Number__c,
          Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c,
          (
            SELECT
              id,
              PPM_ID__c,
              UCPM_Status__c,
              Patient_Delegate__c,
              Patient_Delegate__r.Participant_Delegate__c,
              Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c,
              Study_Phone_Consent__c,
              Study_Phone_Consent_Time__c,
              Study_Email_Consent__c,
              Study_Email_Consent_Time__c,
              Study_SMS_Consent__c,
              Study_SMS_Consent_Time__c,
              Study_Direct_Mail_Consent__c,
              Study_Direct_Mail_Consent_Time__c,
              Patient_Delegate__r.Contact__c,
              Patient_Delegate__r.Contact__r.PPM_ID__c,
              Patient_Delegate__r.Contact__r.UCPM_Status__c,
              Patient_Delegate__r.Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
              Patient_Delegate__r.Contact__r.IQVIA_Phone_Consent_Time__c,
              Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
              Patient_Delegate__r.Contact__r.IQVIA_Email_Consent_Time__c,
              Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
              Patient_Delegate__r.Contact__r.IQVIA_SMS_Consent_Time__c,
              Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent__c,
              Patient_Delegate__r.Contact__r.IQVIA_Direct_Mail_Consent_Time__c
            FROM Patient_Delegate_Enrollments__r
            WHERE
              (PPM_ID__c != NULL
              AND UCPM_Status__c != 'Completed')
              OR (Patient_Delegate__r.Contact__r.PPM_ID__c != NULL
              AND Patient_Delegate__r.Contact__r.UCPM_Status__c != 'Completed')
          )
        FROM Participant_Enrollment__c
        WHERE
          Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != NULL
          AND Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != NULL
          AND ((PPMID__c != NULL
          AND UCPM_Status__c != 'Completed')
          OR (Participant_Contact__r.PPM_ID__c != NULL
          AND Participant_Contact__r.UCPM_Status__c != 'Completed'))
      ]
    );
  }

  global void execute(
    Database.BatchableContext bc,
    List<Participant_Enrollment__c> scope
  ) {
    List<Participant_Enrollment__c> perListToUpdate = new List<Participant_Enrollment__c>();
    List<Patient_Delegate_Enrollment__c> pderListToUpdate = new List<Patient_Delegate_Enrollment__c>();
    List<Contact> conListToUpdate = new List<Contact>();

    List<Historical_Consent_Staging__c> hcsToCreate = new List<Historical_Consent_Staging__c>();

    for (Participant_Enrollment__c per : scope) {
      if (per.PPMID__c != null && per.UCPM_Status__c != 'Completed') {
        per.UCPM_Status__c = 'Completed';
        Historical_Consent_Staging__c hcsPER = new Historical_Consent_Staging__c();
        hcsPER.OTSponsorId__c = per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c;
        hcsPER.OTPurposeId__c = per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c;
        hcsPER.ApplicationId__c = per.Id;
        hcsPER.Sponsor__c = per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
        hcsPER.Study__c = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
        hcsPER.NctId__c = per.Clinical_Trial_Profile__r.NCT_Number__c;
        if (per.Participant__c != null) {
          hcsPER.Country__c = per.Participant__r.Mailing_Country_Code__c;
        }
        hcsPER.Source__c = 'RH';
        hcsPER.PPName__c = 'Communication-Consents';
        hcsPER.PPMID__c = per.PPMID__c;
        hcsPER.ConsentData__c = generateJSONstringPER(per);

        hcsToCreate.add(hcsPER);
        perListToUpdate.add(per);
      }

      if (
        per.Participant_Contact__c != null &&
        per.Participant_Contact__r.PPM_ID__c != null &&
        per.Participant_Contact__r.UCPM_Status__c != 'Completed' &&
        !conUniqueID.contains(per.Participant_Contact__c)
      ) {
        Contact con = new Contact();
        con.Id = per.Participant_Contact__c;
        con.UCPM_Status__c = 'Completed';
        conListToUpdate.add(con);
        conUniqueID.add(per.Participant_Contact__c);

        Historical_Consent_Staging__c hcsPERcon = new Historical_Consent_Staging__c();
        hcsPERcon.OTSponsorId__c = per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c;
        hcsPERcon.OTPurposeId__c = per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c;
        hcsPERcon.ApplicationId__c = per.Participant_Contact__c;
        hcsPERcon.Sponsor__c = 'IQVIA';
        hcsPERcon.Study__c = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
        hcsPERcon.NctId__c = per.Clinical_Trial_Profile__r.NCT_Number__c;
        if (per.Participant__c != null) {
          hcsPERcon.Country__c = per.Participant__r.Mailing_Country_Code__c;
        }
        hcsPERcon.Source__c = 'RH';
        hcsPERcon.PPName__c = 'IQVIA-Outreach-Consents';
        hcsPERcon.PPMID__c = per.Participant_Contact__r.PPM_ID__c;
        hcsPERcon.ConsentData__c = generateJSONstringContact(
          per.Participant_Contact__r
        );

        hcsToCreate.add(hcsPERcon);
      }
      for (
        Patient_Delegate_Enrollment__c pder : per.Patient_Delegate_Enrollments__r
      ) {
        if (pder.PPM_ID__c != null && pder.UCPM_Status__c != 'Completed') {
          Patient_Delegate_Enrollment__c pd = new Patient_Delegate_Enrollment__c();
          pd.ID = pder.ID;
          pd.UCPM_Status__c = 'Completed';
          pderListToUpdate.add(pd);

          Historical_Consent_Staging__c hcsPDER = new Historical_Consent_Staging__c();
          hcsPDER.OTSponsorId__c = per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c;
          hcsPDER.OTPurposeId__c = per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c;
          hcsPDER.ApplicationId__c = pder.Id;
          hcsPDER.Sponsor__c = per.Clinical_Trial_Profile__r.MDM_Parent_Sponsor_Name__c;
          hcsPDER.Study__c = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
          hcsPDER.NctId__c = per.Clinical_Trial_Profile__r.NCT_Number__c;
          if (
            pder.Patient_Delegate__r != null &&
            pder.Patient_Delegate__r.Participant_Delegate__c != null
          ) {
            hcsPDER.Country__c = pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c;
          }
          hcsPDER.Source__c = 'RH';
          hcsPDER.PPName__c = 'Communication-Consents';
          hcsPDER.PPMID__c = pder.PPM_ID__c;
          hcsPDER.ParticipantPPMID__c = per.PPMID__c;
          hcsPDER.ConsentData__c = generateJSONstringPDER(pder);
          hcsToCreate.add(hcsPDER);
          if (
            pder.Patient_Delegate__r != null &&
            pder.Patient_Delegate__r.Contact__c != null &&
            pder.Patient_Delegate__r.Contact__r.PPM_ID__c != null &&
            pder.Patient_Delegate__r.Contact__r.UCPM_Status__c != 'Completed' &&
            !conUniqueID.contains(pder.Patient_Delegate__r.Contact__c)
          ) {
            Contact con1 = new Contact();
            con1.Id = pder.Patient_Delegate__r.Contact__c;
            con1.UCPM_Status__c = 'Completed';
            conListToUpdate.add(con1);
            conUniqueID.add(pder.Patient_Delegate__r.Contact__c);

            Historical_Consent_Staging__c hcsPDERcon = new Historical_Consent_Staging__c();
            hcsPDERcon.OTSponsorId__c = per.Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c;
            hcsPDERcon.OTPurposeId__c = per.Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c;
            hcsPDERcon.ApplicationId__c = pder.Patient_Delegate__r.Contact__c;
            hcsPDERcon.Sponsor__c = 'IQVIA';
            hcsPDERcon.Study__c = per.Clinical_Trial_Profile__r.Study_Code_Name__c;
            hcsPDERcon.NctId__c = per.Clinical_Trial_Profile__r.NCT_Number__c;
            if (
              pder.Patient_Delegate__c != null &&
              pder.Patient_Delegate__r.Participant_Delegate__c != null
            ) {
              hcsPDERcon.Country__c = pder.Patient_Delegate__r.Participant_Delegate__r.Mailing_Country_Code__c;
            }
            hcsPDERcon.Source__c = 'RH';
            hcsPDERcon.PPName__c = 'IQVIA-Outreach-Consents';
            hcsPDERcon.PPMID__c = pder.Patient_Delegate__r.Contact__r.PPM_ID__c;
            hcsPDERcon.ConsentData__c = generateJSONstringContact(
              pder.Patient_Delegate__r.Contact__r
            );
            hcsToCreate.add(hcsPDERcon);
          }
        }
      }
    }
    if (!hcsToCreate.isEmpty()) {
      insert hcsToCreate;
    }
    // if (!perListToUpdate.isEmpty()) {
    //   update perListToUpdate;
    // }
    // if (!pderListToUpdate.isEmpty()) {
    //   update pderListToUpdate;
    // }
    // if (!conListToUpdate.isEmpty()) {
    //   update conListToUpdate;
    // }
  }

  global void finish(Database.BatchableContext bc) {
    //send an email with confirmation
    System.debug('conUniqueID: ' + conUniqueID);
  }

  public static String generateJSONstringPER(Participant_Enrollment__c per) {
    String finalString;
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartObject();
    gen.writeStringField('PP_Name', 'Communication-Consents');
    gen.writeFieldName('consentPurpose');
    gen.writeStartArray();
    if (per.Study_Phone_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'phone');
      gen.writeBooleanField(
        'value',
        per.Permit_Voice_Text_contact_for_this_study__c
      );
      gen.writeDateTimeField('time', per.Study_Phone_Consent_Time__c);
      gen.writeEndObject();
    }
    if (per.Study_Email_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'email');
      gen.writeBooleanField(
        'value',
        per.Permit_Mail_Email_contact_for_this_study__c
      );
      gen.writeDateTimeField('time', per.Study_Email_Consent_Time__c);
      gen.writeEndObject();
    }
    if (per.Study_SMS_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'sms');
      gen.writeBooleanField('value', per.Permit_SMS_Text_for_this_study__c);
      gen.writeDateTimeField('time', per.Study_SMS_Consent_Time__c);
      gen.writeEndObject();
    }
    if (per.Study_Direct_Mail_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'directMail');
      gen.writeBooleanField('value', per.Study_Direct_Mail_Consent__c);
      gen.writeDateTimeField('time', per.Study_Direct_Mail_Consent_Time__c);
      gen.writeEndObject();
    }
    gen.writeEndArray();
    gen.writeEndObject();
    String jsonString = gen.getAsString();
    System.debug(jsonString);
    jsonString = jsonString.escapeJava();
    // finalString = '"' + jsonString + '"';
    finalString = jsonString;
    System.debug('finalString per ' + finalString);
    return finalString;
  }

  public static String generateJSONstringPDER(
    Patient_Delegate_Enrollment__c pder
  ) {
    String finalString;
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartObject();
    gen.writeStringField('PP_Name', 'Communication-Consents');
    gen.writeFieldName('consentPurpose');
    gen.writeStartArray();
    if (pder.Study_Phone_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'phone');
      gen.writeBooleanField('value', pder.Study_Phone_Consent__c);
      gen.writeDateTimeField('time', pder.Study_Phone_Consent_Time__c);
      gen.writeEndObject();
    }
    if (pder.Study_Email_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'email');
      gen.writeBooleanField('value', pder.Study_Email_Consent__c);
      gen.writeDateTimeField('time', pder.Study_Email_Consent_Time__c);
      gen.writeEndObject();
    }
    if (pder.Study_SMS_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'sms');
      gen.writeBooleanField('value', pder.Study_SMS_Consent__c);
      gen.writeDateTimeField('time', pder.Study_SMS_Consent_Time__c);
      gen.writeEndObject();
    }
    if (pder.Study_Direct_Mail_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'directMail');
      gen.writeBooleanField('value', pder.Study_Direct_Mail_Consent__c);
      gen.writeDateTimeField('time', pder.Study_Direct_Mail_Consent_Time__c);
      gen.writeEndObject();
    }
    gen.writeEndArray();
    gen.writeEndObject();
    String jsonString = gen.getAsString();
    System.debug(jsonString);
    jsonString = jsonString.escapeJava();
    // finalString = '"' + jsonString + '"';
    finalString = jsonString;
    System.debug('finalString per ' + finalString);
    return finalString;
  }

  public static String generateJSONstringContact(Contact con) {
    String finalString;
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartObject();
    gen.writeStringField('PP_Name', 'IQVIA-Outreach-Consents');
    gen.writeFieldName('consentPurpose');
    gen.writeStartArray();
    if (con.IQVIA_Phone_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'phone');
      gen.writeBooleanField(
        'value',
        con.Participant_Phone_Opt_In_Permit_Phone__c
      );
      gen.writeDateTimeField('time', con.IQVIA_Phone_Consent_Time__c);
      gen.writeEndObject();
    }
    if (con.IQVIA_Email_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'email');
      gen.writeBooleanField('value', con.Participant_Opt_In_Status_Emails__c);
      gen.writeDateTimeField('time', con.IQVIA_Email_Consent_Time__c);
      gen.writeEndObject();
    }
    if (con.IQVIA_SMS_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'sms');
      gen.writeBooleanField('value', con.Participant_Opt_In_Status_SMS__c);
      gen.writeDateTimeField('time', con.IQVIA_SMS_Consent_Time__c);
      gen.writeEndObject();
    }
    if (con.IQVIA_Direct_Mail_Consent_Time__c != null) {
      gen.writeStartObject();
      gen.writeStringField('name', 'directMail');
      gen.writeBooleanField('value', con.IQVIA_Direct_Mail_Consent__c);
      gen.writeDateTimeField('time', con.IQVIA_Direct_Mail_Consent_Time__c);
      gen.writeEndObject();
    }
    gen.writeEndArray();
    gen.writeEndObject();
    String jsonString = gen.getAsString();
    jsonString = jsonString.escapeJava();
    System.debug(jsonString);
    // finalString = '"' + jsonString + '"';
    finalString = jsonString;
    System.debug('finalString con ' + finalString);
    return finalString;
  }
}