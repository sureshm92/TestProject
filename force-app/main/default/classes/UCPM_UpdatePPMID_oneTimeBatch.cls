global without sharing class UCPM_UpdatePPMID_oneTimeBatch implements Database.Batchable<SObject>, Database.Stateful {
  public Set<ID> conUniqueIDppm = new Set<ID>();
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          PPMID__c,
          UCPM_Status__c,
          Participant_Contact__c,
          Participant_Contact__r.PPM_ID__c,
          Participant_Contact__r.UCPM_Status__c,
          Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c,
          Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c,
          (
            SELECT
              id,
              PPM_ID__c,
              UCPM_Status__c,
              Patient_Delegate__r.Contact__c,
              Patient_Delegate__r.Contact__r.PPM_ID__c,
              Patient_Delegate__r.Contact__r.UCPM_Status__c
            FROM Patient_Delegate_Enrollments__r
            WHERE
              PPM_ID__c = NULL
              OR Patient_Delegate__r.Contact__r.PPM_ID__c = NULL
          )
        FROM Participant_Enrollment__c
        WHERE
          Clinical_Trial_Profile__r.UCPM_Sponsor_Org_Id__c != NULL
          AND Clinical_Trial_Profile__r.UCPM_Study_Purpose_Id__c != NULL
          AND (PPMID__c = NULL
          OR Participant_Contact__r.PPM_ID__c = NULL)
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

    for (Participant_Enrollment__c per : scope) {
      if (per.PPMID__c == null) {
        per.PPMID__c = generateUUID();
        perListToUpdate.add(per);
      }
      if (
        per.Participant_Contact__c != null &&
        per.Participant_Contact__r.PPM_ID__c == null &&
        !conUniqueIDppm.contains(per.Participant_Contact__c)
      ) {
        Contact con = new Contact();
        con.Id = per.Participant_Contact__c;
        con.PPM_ID__c = generateUUID();
        conListToUpdate.add(con);
        conUniqueIDppm.add(per.Participant_Contact__c);
      }
      for (
        Patient_Delegate_Enrollment__c pder : per.Patient_Delegate_Enrollments__r
      ) {
        if (pder.PPM_ID__c == null) {
          Patient_Delegate_Enrollment__c pd = new Patient_Delegate_Enrollment__c();
          pd.Id = pder.ID;
          pd.PPM_ID__c = generateUUID();
          pderListToUpdate.add(pd);
        }
        if (
          pder.Patient_Delegate__r != null &&
          pder.Patient_Delegate__r.Contact__c != null &&
          pder.Patient_Delegate__r.Contact__r.PPM_ID__c == null &&
          !conUniqueIDppm.contains(pder.Patient_Delegate__r.Contact__c)
        ) {
          pder.Patient_Delegate__r.Contact__r.PPM_ID__c = generateUUID();
          Contact con1 = new Contact();
          con1.Id = pder.Patient_Delegate__r.Contact__c;
          con1.PPM_ID__c = generateUUID();
          conListToUpdate.add(con1);
          conUniqueIDppm.add(pder.Patient_Delegate__r.Contact__c);
        }
      }
    }

    if (!perListToUpdate.isEmpty()) {
      update perListToUpdate;
    }
    if (!pderListToUpdate.isEmpty()) {
      update pderListToUpdate;
    }
    if (!conListToUpdate.isEmpty()) {
      update conListToUpdate;
    }
  }
  global void finish(Database.BatchableContext bc) {
    //call another batch to create records for staging table
    Database.executeBatch(new UCPM_CreateCSVfileRecords_oneTimeBatch());
  }

  //UUID generator
  public static String generateUUID() {
    String finalUUID;
    String version = '01';
    String mappingRH = '004';
    UUID randomUuid = UUID.randomUUID();
    finalUUID = version + mappingRH + '_' + randomUuid;
    System.debug('finalUUID: ' + finalUUID);
    return finalUUID;
  }
}
//TODO: To execute this batch
// Database.executeBatch(new UCPM_UpdatePPMID_oneTimeBatch(), 30);