public without sharing class PIR_ParticipantDetailController {
  @AuraEnabled
  public static map<String, sObject> getParticipantData(String PEid) {
    map<String, sObject> dataMap = new Map<String, sObject>();
    dataMap.put(
      'pe',
      [
        SELECT
          id,
          MRN_Id__c,
          Permit_Mail_Email_contact_for_this_study__c,
          Permit_SMS_Text_for_this_study__c,
          Permit_Voice_Text_contact_for_this_study__c,
          Referral_Source__c,
          Patient_ID__c,
          Source_Type__c,
          Referral_ID__c,
          Screening_ID__c,
          Participant_Status__c,
          Visit_Plan__r.Name,
          Participant__r.id,
          Participant__r.Adult__c,
          Participant__r.Ethnicity__c,
          Participant__r.First_Name__c,
          Participant__r.Last_Name__c,
          Participant__r.Middle_Name__c,
          Participant__r.Nickname__c,
          Participant__r.Suffix__c,
          Participant__r.Preferred_Language__c,
          Participant__r.Date_of_Birth__c,
          Participant__r.Gender__c,
          Participant__r.Email__c,
          Participant__r.Phone__c,
          Participant__r.Phone_Type__c,
          Participant__r.Alternative_Phone_Number__c,
          Participant__r.Alternative_Phone_Type__c,
          Participant__r.Preferred_Contact_Time__c,
          Participant__r.Mailing_State__c,
          Participant__r.Mailing_State_Code__c,
          Participant__r.Mailing_Country__c,
          Participant__r.Mailing_Country_Code__c,
          Participant__r.Mailing_Zip_Postal_Code__c,
          Participant__r.Emancipation_in_progress__c,
          Clinical_Trial_Profile__r.IQVIA_Outreach__c,
          Participant_Contact__c,
          Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
          Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
          Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c
        FROM Participant_Enrollment__c
        WHERE id = :PEid
      ]
    );
    try {
      dataMap.put(
        'delegate',
        [
          SELECT
            id,
            Contact__c,
            Participant_Delegate__r.First_Name__c,
            Participant_Delegate__r.Last_Name__c,
            Participant_Delegate__r.Phone__c,
            Participant_Delegate__r.Email__c,
            Participant_Delegate__r.Birth_Year__c,
            Participant_Delegate__r.Attestation__c
          FROM Patient_Delegate__c
          WHERE
            Participant__c = :((Participant_Enrollment__c) dataMap.get('pe'))
              .Participant__r.id
            AND Primary_Delegate__c = TRUE
          LIMIT 1
        ]
      );
    } catch (Exception e) {
      dataMap.put('delegate', null);
    }
    return dataMap;
  }
  public class MyPickListInfo {
    public String validFor;
  }
  public class labelVal {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    public labelVal(string l, string v) {
      this.label = l;
      this.value = v;
    }
  }
  public class CountyrStateInfo {
    @AuraEnabled
    public Map<String, List<labelVal>> stateMap = new Map<String, List<labelVal>>();
    @AuraEnabled
    public List<labelVal> countryMap = new List<labelVal>();
    @AuraEnabled
    public Map<String, Integer> adultAgeByCountryStateCode = new Map<String, Integer>();
  }
  @AuraEnabled(cacheable=true)
  public static CountyrStateInfo getCnData() {
    CountyrStateInfo wrap = new CountyrStateInfo();
    Schema.SObjectType objUser = Schema.getGlobalDescribe().get('User');
    Schema.DescribeSObjectResult fieldResult = objUser.getDescribe();
    Schema.DescribeFieldResult cont = fieldResult.fields.getMap()
      .get('Countrycode')
      .getDescribe();
    Schema.DescribeFieldResult stat = fieldResult.fields.getMap()
      .get('Statecode')
      .getDescribe();
    List<Schema.PicklistEntry> countVals = cont.getPicklistValues();
    List<Schema.PicklistEntry> statVals = stat.getPicklistValues();
    for (Schema.PicklistEntry contVal : countVals) {
      wrap.countryMap.add(new labelVal(contVal.getLabel(), contVal.getValue()));
      wrap.stateMap.put(contVal.getValue(), new List<labelVal>());
    }
    for (Schema.PicklistEntry statVal : statVals) {
      String jsonString = JSON.serialize(statVal);
      MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
        jsonString,
        MyPickListInfo.class
      );
      String hexString = EncodingUtil.convertToHex(
          EncodingUtil.base64Decode(info.validFor)
        )
        .toUpperCase();
      Integer baseCount = 0;
      for (Integer curr : hexString.getChars()) {
        Integer val = 0;
        if (curr >= 65) {
          val = curr - 65 + 10;
        } else {
          val = curr - 48;
        }
        if ((val & 8) == 8) {
          wrap.stateMap.get(countVals[baseCount + 0].getValue())
            .add(new labelVal(statVal.getLabel(), statVal.getValue()));
        }
        if ((val & 4) == 4) {
          wrap.stateMap.get(countVals[baseCount + 1].getValue())
            .add(new labelVal(statVal.getLabel(), statVal.getValue()));
        }
        if ((val & 2) == 2) {
          wrap.stateMap.get(countVals[baseCount + 2].getValue())
            .add(new labelVal(statVal.getLabel(), statVal.getValue()));
        }
        if ((val & 1) == 1) {
          wrap.stateMap.get(countVals[baseCount + 3].getValue())
            .add(new labelVal(statVal.getLabel(), statVal.getValue()));
        }
        baseCount += 4;
      }
    }
    Map<String, Age_of_Majority__mdt> mapAgeM = Age_of_Majority__mdt.getAll();
    for (String ageOfMajority : mapAgeM.keySet()) {
      if (mapAgeM.get(ageOfMajority).Age__c != null) {
        wrap.adultAgeByCountryStateCode.put(
          mapAgeM.get(ageOfMajority).DeveloperName,
          mapAgeM.get(ageOfMajority).Age__c.intValue()
        );
      }
    }
    return wrap;
  }

  @AuraEnabled
  public static Boolean doSaveParticipantDetails(
    Participant_Enrollment__c perRecord,
    String peDeligateString,
    Boolean isPeUpdated,
    Boolean isPartUpdated,
    Boolean isDelUpdated,
    Boolean isOutreachUpdated,
    String delegateCriteria
  ) {
    Boolean bol = true;
    try {
      Participant_Enrollment__c perToUpdate = new Participant_Enrollment__c();
      Participant__c piToUpdate = new Participant__c();
      Patient_Delegate__c peDeligate = (Patient_Delegate__c) JSON.deserialize(peDeligateString, Patient_Delegate__c.class);
      //Update Participant enrollment record
      if (isPeUpdated) {
        perToUpdate.Id = perRecord.Id;
        perToUpdate.Permit_Mail_Email_contact_for_this_study__c = perRecord.Permit_Mail_Email_contact_for_this_study__c;
        perToUpdate.Permit_SMS_Text_for_this_study__c = perRecord.Permit_SMS_Text_for_this_study__c;
        perToUpdate.Permit_Voice_Text_contact_for_this_study__c = perRecord.Permit_Voice_Text_contact_for_this_study__c;
        perToUpdate.MRN_Id__c = perRecord.MRN_Id__c;

        update perToUpdate;
      }

      //Update Participant record
      if (isPartUpdated) {
        piToUpdate = perRecord.Participant__r;

        update piToUpdate;
      }
      //delegate operation
      if (isDelUpdated) {

        if(delegateCriteria == 'insertDelegate'){
          Participant__c piToInsertDelegate = new Participant__c();
          piToInsertDelegate = peDeligate.Participant_Delegate__r;
           piToInsertDelegate.id=null;
          insert piToInsertDelegate;
          List<Participant__c> parti = [SELECT Id, Contact__c FROM Participant__c WHERE Id = : piToInsertDelegate.Id];
          Patient_Delegate__c pdToupdateAfterInsert = new Patient_Delegate__c(
            Primary_Delegate__c = true,
            Participant_Delegate__c = piToInsertDelegate.Id,
            Participant__c = perRecord.Participant__c,
            Contact__c = parti[0].Contact__c
          );
          insert pdToupdateAfterInsert;
        }else if(delegateCriteria == 'updateParticipant'){
          Participant__c piToUpdateDelegate = new Participant__c();
          piToUpdateDelegate = peDeligate.Participant_Delegate__r;

          update piToUpdateDelegate;
        }else if(delegateCriteria == 'updateDeligate'){
          Patient_Delegate__c pdToupdateAfterInsertDuplicate = new Patient_Delegate__c(
            Primary_Delegate__c = true,
            Participant_Delegate__c = peDeligate.Participant_Delegate__r.Id,
            Participant__c = perRecord.Participant__c,
            Contact__c = peDeligate.Participant_Delegate__r.Contact__c
          );
          insert pdToupdateAfterInsertDuplicate;
        }else if(string.isBlank(peDeligate.Participant_Delegate__r.First_Name__c)){//if(delegateCriteria == 'deleteDelegate'){
          Patient_Delegate__c pdToupdate = new Patient_Delegate__c(
            Id = peDeligate.Id,
            Primary_Delegate__c = false
          );
          update pdToupdate;
        }
        else{
          Participant__c piToUpdateDelegate = new Participant__c();
          piToUpdateDelegate = peDeligate.Participant_Delegate__r;

          update piToUpdateDelegate;
        }
      }

      if(isOutreachUpdated){
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.PopulateOverrideFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
        contact con = new Contact(Id = perRecord.Participant_Contact__r.Id,
        Participant_Opt_In_Status_Emails__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
        Participant_Opt_In_Status_SMS__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
        Participant_Phone_Opt_In_Permit_Phone__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c);
        update con;
      }
    } catch (Exception e) {
      bol = false;
      System.debug('e.getMessage(): ' + e.getMessage());
      System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
      throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
    }

    return bol;
  }
}