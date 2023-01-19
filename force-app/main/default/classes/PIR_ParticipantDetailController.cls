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
          Study_Site__c,
          Study_Site__r.Site__c,
          Study_Site__r.Participant_DOB_format__c,
          Visit_Plan__c,
          Permit_IQVIA_to_contact_about_study__c,
          Permit_Mail_Email_contact_for_this_study__c,
          Permit_SMS_Text_for_this_study__c,
          Permit_Voice_Text_contact_for_this_study__c,
          Study_Direct_Mail_Consent__c,
          Additional_Information__c,
          Referral_Source__c,
          Patient_ID__c,
          Source_Type__c,
          Referral_ID__c,
          Screening_ID__c,
          Participant_Status__c,
          Is_Participant_DOB_Valid__c,
          Visit_Plan__r.Name,
          Participant__r.id,
          Participant__r.Adult__c,
          Participant__r.Age__c,
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
          Participant__r.Birth_Day__c,
          Participant__r.Birth_Month__c,
          Participant__r.Birth_Year__c,
          Clinical_Trial_Profile__r.IQVIA_Outreach__c,
          Participant_Contact__c,
          Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
          Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
          Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
          Study_Site__r.Site__r.BillingCountryCode
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
            Study_Email_Consent__c,
            Study_info_storage_consent__c,
            Study_Phone_Consent__c,
            Study_SMS_Consent__c,
            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Phone__c,
            Patient_Delegate__r.Participant_Delegate__r.Email__c,
            Patient_Delegate__r.Participant_Delegate__r.Birth_Year__c,
            Patient_Delegate__r.Participant_Delegate__r.Attestation__c
          FROM Patient_Delegate_Enrollment__c
          WHERE
            Participant_Enrollment__c = :PEid
            AND Primary_Delegate__c = TRUE
          LIMIT 1
        ]
      );
    } catch (Exception e) {
      dataMap.put('delegate', null);
    }
    return dataMap;
  }
  public static Map<Id, List<StudySiteVisitPlan__c>> getStudySiteVisitPlansMap(
    List<Id> ssIds
  ) {
    List<StudySiteVisitPlan__c> studySiteVisitPlans = [
      SELECT Id, Visit_Plan__r.Name, Study_Site__c
      FROM StudySiteVisitPlan__c
      WHERE Study_Site__c IN :ssIds
    ];

    Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlansBySSId = new Map<Id, List<StudySiteVisitPlan__c>>();
    for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
      if (!ssVisitPlansBySSId.containsKey(ssVP.Study_Site__c)) {
        ssVisitPlansBySSId.put(
          ssVP.Study_Site__c,
          new List<StudySiteVisitPlan__c>()
        );
      }
      ssVisitPlansBySSId.get(ssVP.Study_Site__c).add(ssVP);
    }

    return ssVisitPlansBySSId;
  }
  @AuraEnabled
  public static List<LabelValueItem> getVisitPlansLVList(Id ssId) {
    Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlanMap = getStudySiteVisitPlansMap(
      new List<Id>{ ssId }
    );
    List<StudySiteVisitPlan__c> ssVisitPlans = ssVisitPlanMap.get(ssId);
    List<LabelValueItem> resList = new List<LabelValueItem>();
    if (ssVisitPlans != null) {
      for (StudySiteVisitPlan__c ssVisitPlan : ssVisitPlans) {
        resList.add(
          new LabelValueItem(
            ssVisitPlan.Visit_Plan__r.Name,
            ssVisitPlan.Visit_Plan__c
          )
        );
      }
    }
    return resList;
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
  
  public class ConsentDetailsWrapper {
    @AuraEnabled
    public Boolean Study_Email_Consent { get; set; }
    @AuraEnabled
    public Boolean Study_info_storage_consent { get; set; }
    @AuraEnabled
    public Boolean Study_Phone_Consent { get; set; }
    @AuraEnabled
    public Boolean Study_SMS_Consent { get; set; }
  }

  @AuraEnabled
  public static Boolean doSaveParticipantDetails(
    Participant_Enrollment__c perRecord,
    String peDeligateString,
    Boolean isPeUpdated,
    Boolean isPartUpdated,
    Boolean isDelUpdated,
    Boolean isOutreachUpdated,
    String delegateCriteria,
    String visitPlan,
    Boolean useDup,
    String consentJSON
  ) {
    Boolean bol = true;
    try {
      Participant_Enrollment__c perToUpdate = new Participant_Enrollment__c();
      Participant__c piToUpdate = new Participant__c();
      Patient_Delegate__c peDeligate = (Patient_Delegate__c) JSON.deserialize(peDeligateString, Patient_Delegate__c.class);
      ConsentDetailsWrapper consentWrapper = (ConsentDetailsWrapper) JSON.deserialize(consentJSON, ConsentDetailsWrapper.class);
      //Update Participant enrollment record
      if (isPeUpdated) {
        perToUpdate.Id = perRecord.Id;
        perToUpdate.Permit_Mail_Email_contact_for_this_study__c = perRecord.Permit_Mail_Email_contact_for_this_study__c;
        perToUpdate.Permit_SMS_Text_for_this_study__c = perRecord.Permit_SMS_Text_for_this_study__c;
        perToUpdate.Permit_Voice_Text_contact_for_this_study__c = perRecord.Permit_Voice_Text_contact_for_this_study__c;
                perToUpdate.Study_Artificial_Voice_Consent__c = perRecord.Permit_Voice_Text_contact_for_this_study__c;
                perToUpdate.Study_Assisted_Dialing_Consent__c = perRecord.Permit_Voice_Text_contact_for_this_study__c;
                perToUpdate.Study_Pre_recorded_Voice_Consent__c = perRecord.Permit_Voice_Text_contact_for_this_study__c;
                perToUpdate.Study_Direct_Mail_Consent__c = perRecord.Study_Direct_Mail_Consent__c;
        perToUpdate.MRN_Id__c = perRecord.MRN_Id__c;
        if(visitPlan != null && visitPlan != '' && visitPlan != 'null' && !String.isBlank(visitPlan)){
           perToUpdate.Visit_Plan__c = visitPlan;
        }else{
            perToUpdate.Visit_Plan__c = null;
        }

        update perToUpdate;
      }else{
        perToUpdate.Id = perRecord.Id;
        if(visitPlan != null && visitPlan != '' && visitPlan != 'null' && !String.isBlank(visitPlan)){
          perToUpdate.Visit_Plan__c = visitPlan;
        }else{
            perToUpdate.Visit_Plan__c = null;
        }
        update perToUpdate;
      }

      //Update Participant record
      if (isPartUpdated) {
        piToUpdate = perRecord.Participant__r;

        update piToUpdate;
      }
      //delegate operation
      Id contactId ;
      if (isDelUpdated) {

        if(delegateCriteria == 'insertDelegate'){
          Participant__c piToInsertDelegate = new Participant__c();
          piToInsertDelegate = peDeligate.Participant_Delegate__r;
          piToInsertDelegate.Attested_by__c = CommunityService.getInstance().getCurrentContactId();
          piToInsertDelegate.Attestation_TimeStamp__c = ParticipantService.getFormattedTime();
           piToInsertDelegate.id=null;
          insert piToInsertDelegate;
          List<Participant__c> parti = [SELECT Id, Contact__c FROM Participant__c WHERE Id = : piToInsertDelegate.Id];
          Patient_Delegate__c pdToupdateAfterInsert = new Patient_Delegate__c(
            Primary_Delegate__c = true,
            Participant_Delegate__c = piToInsertDelegate.Id,
            Participant__c = perRecord.Participant__c,
            Contact__c = parti[0].Contact__c,
            Status__c = 'Disconnected'
          );
          if(pdToupdateAfterInsert.Participant__c == null && perRecord.Participant__r.Id != null){
                pdToupdateAfterInsert.Participant__c = perRecord.Participant__r.Id;
          }
          contactId = parti[0].Contact__c;
          insert pdToupdateAfterInsert;
          createPDE(parti[0].Contact__c,pdToupdateAfterInsert,perRecord,consentWrapper);
        }else if(delegateCriteria == 'updateParticipant'){
          Participant__c piToUpdateDelegate = new Participant__c();
          piToUpdateDelegate = peDeligate.Participant_Delegate__r;

          update piToUpdateDelegate;

          Patient_Delegate_Enrollment__c pdenrollment = new Patient_Delegate_Enrollment__c();
          pdenrollment  = [Select Id,Primary_Delegate__c,Participant_Enrollment__c,Study_info_storage_consent__c from Patient_Delegate_Enrollment__c where Primary_Delegate__c=:true and Participant_Enrollment__c=:perRecord.Id limit 1];
          if(pdenrollment != null){
             Patient_Delegate_Enrollment__c pdenroll = new Patient_Delegate_Enrollment__c();
             pdenroll.Id = pdenrollment.Id;
             pdenroll.Study_info_storage_consent__c =consentWrapper.Study_info_storage_consent;
             if(consentWrapper.Study_SMS_Consent != null){
              pdenroll.Study_SMS_Consent__c=consentWrapper.Study_SMS_Consent;
             }
             pdenroll.Study_Phone_Consent__c=consentWrapper.Study_Phone_Consent;
             pdenroll.Study_Email_Consent__c=consentWrapper.Study_Email_Consent;
             Update pdenroll;
          }
           
        }else if(delegateCriteria == 'updateDeligate'){
          if(useDup){
            List<Patient_Delegate__c> pd = new List<Patient_Delegate__c>();
            List<Patient_Delegate__c> pds = new List<Patient_Delegate__c>();
            pd = [Select Id,Participant__c,Contact__c, Participant_Delegate__c,Contact__r.Participant_Opt_In_Status_SMS__c from Patient_Delegate__c where Participant__c=: perRecord.Participant__c and Participant_Delegate__c=:peDeligate.Participant_Delegate__r.Id];
            if(pd != null && !pd.isEmpty()){
                  Patient_Delegate__c pdToupdateDuplicate = new Patient_Delegate__c(
                  Id = pd[0].Id,
                  Primary_Delegate__c = true
                );
                pds = [Select Id,Participant__c,Participant_Delegate__c,Primary_Delegate__c  from Patient_Delegate__c where Participant__c=: perRecord.Participant__c and Primary_Delegate__c =:true];
                if(pds != null && !pds.isEmpty()){
                    List<Patient_Delegate__c> pdUpd = new List<Patient_Delegate__c>();
                    for(Patient_Delegate__c p:pds){
                        Patient_Delegate__c patdel = new Patient_Delegate__c();
                        patdel.Id = p.Id;
                        patdel.Primary_Delegate__c = false;
                        pdUpd.add(patdel);
                    }
                    update pdUpd;
                }
                update pdToupdateDuplicate;   
          
                List<Patient_Delegate_Enrollment__c> updSecondaryPDE = new List<Patient_Delegate_Enrollment__c>();
                updSecondaryPDE = [Select Id,Patient_Delegate__c,Primary_Delegate__c,Participant_Enrollment__c from  Patient_Delegate_Enrollment__c where Patient_Delegate__c=:pd[0].Id AND Participant_Enrollment__c=:perRecord.Id];
                
                if(updSecondaryPDE != null && !updSecondaryPDE.isEmpty()){
                        Patient_Delegate_Enrollment__c pdeToupdateDuplicate = new Patient_Delegate_Enrollment__c();
                        pdeToupdateDuplicate.Id = updSecondaryPDE[0].Id;
                        pdeToupdateDuplicate.Primary_Delegate__c = true;
                        pdeToupdateDuplicate.Study_Email_Consent__c = consentWrapper.Study_Email_Consent;
                        pdeToupdateDuplicate.Study_info_storage_consent__c = consentWrapper.Study_info_storage_consent;
                        pdeToupdateDuplicate.Study_Phone_Consent__c = consentWrapper.Study_Phone_Consent;
                        if(consentWrapper.Study_SMS_Consent != null){ 
                        pdeToupdateDuplicate.Study_SMS_Consent__c = consentWrapper.Study_SMS_Consent;
                        }  
                        List<Patient_Delegate_Enrollment__c> getPDE = new List<Patient_Delegate_Enrollment__c>();
                        List<Patient_Delegate_Enrollment__c> updPDE = new List<Patient_Delegate_Enrollment__c>();
                        getPDE = [Select Id,Participant_Enrollment__c,Primary_Delegate__c,Patient_Delegate__c from Patient_Delegate_Enrollment__c where Participant_Enrollment__c=:perRecord.Id AND Primary_Delegate__c=:true];
                        if(getPDE != null && !getPDE.isEmpty() && getPDE.size() != 0){
                        for(Patient_Delegate_Enrollment__c pdes:getPDE){
                        pdes.Primary_Delegate__c = false;
                        updPDE.add(pdes);
                        } 
                        }
                        if(updPDE != null && !updPDE.isEmpty() && updPDE.size() != 0){
                        update updPDE;
                        }
                        
                        update pdeToupdateDuplicate;    
                 }else{
                      contactId = peDeligate.Participant_Delegate__r.Contact__c;
                      Patient_Delegate__c patdelgate = new Patient_Delegate__c();
                      patdelgate = [Select Id,Participant__c,Contact__c, Participant_Delegate__c,Contact__r.Participant_Opt_In_Status_SMS__c,Attestation__c,
                            Attestation_TimeStamp__c,Attested_by__c,isInviteToPP__c,Primary_Delegate__c from Patient_Delegate__c where Id=:pd[0].Id];
                      createPDE(contactId,patdelgate ,perRecord,consentWrapper );
                 }
                  
            }else{
                Patient_Delegate__c pdToupdateAfterInsertDuplicate = new Patient_Delegate__c(
                Primary_Delegate__c = true,
                Participant_Delegate__c = peDeligate.Participant_Delegate__r.Id,
                Participant__c = perRecord.Participant__c,
                Contact__c = peDeligate.Participant_Delegate__r.Contact__c,
                Status__c = 'Disconnected'
                );
                contactId = peDeligate.Participant_Delegate__r.Contact__c;
                insert pdToupdateAfterInsertDuplicate;
                
                createPDE(contactId,pdToupdateAfterInsertDuplicate,perRecord,consentWrapper);
                 
              }
          }else{
            Patient_Delegate__c pdToupdateAfterInsertDuplicate = new Patient_Delegate__c(
              Primary_Delegate__c = true,
              Participant_Delegate__c = peDeligate.Participant_Delegate__r.Id,
              Participant__c = perRecord.Participant__c,
              Contact__c = peDeligate.Participant_Delegate__r.Contact__c,
              Status__c = 'Disconnected'
            );
            contactId = peDeligate.Participant_Delegate__r.Contact__c;
            insert pdToupdateAfterInsertDuplicate;
            createPDE(contactId,pdToupdateAfterInsertDuplicate,perRecord,consentWrapper);
             
          }
        }else if(string.isBlank(peDeligate.Participant_Delegate__r.First_Name__c)){//if(delegateCriteria == 'deleteDelegate'){
          Patient_Delegate__c pdToupdate = new Patient_Delegate__c(
            Id = peDeligate.Id,
            Primary_Delegate__c = false
          );
          update pdToupdate;
          
           List<Patient_Delegate_Enrollment__c> updPrimaryPDE = new List<Patient_Delegate_Enrollment__c>();
           updPrimaryPDE = [Select Id,Patient_Delegate__c,Primary_Delegate__c,Participant_Enrollment__c from  Patient_Delegate_Enrollment__c where Primary_Delegate__c=true AND Patient_Delegate__c=:peDeligate.Id AND Participant_Enrollment__c=:perRecord.Id limit 1];
           if(!updPrimaryPDE.isEmpty() && updPrimaryPDE != null){ 
           Patient_Delegate_Enrollment__c pderToupdate = new Patient_Delegate_Enrollment__c(
            Id = updPrimaryPDE[0].Id,
            Primary_Delegate__c = false
          );
          update pderToupdate;    }
          
          
        }
        else{
          Participant__c piToUpdateDelegate = new Participant__c();
          piToUpdateDelegate = peDeligate.Participant_Delegate__r;

          update piToUpdateDelegate;
        }
      }

      List<Patient_Delegate__c> patientDelegate;
      if(peDeligate != null && peDeligate.id != null){
            patientDelegate = [Select id ,Primary_Delegate__c,Contact__c,Participant__r.Email__c from Patient_Delegate__c where Id =:peDeligate.id ];
      }
      if(isOutreachUpdated == null){
        isOutreachUpdated = false;
      }
      
      if(isOutreachUpdated){
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.createNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
        TriggerHandlerExecutor.bypassHandler(
          ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
        );
        List<Contact> conlist = new List<Contact>();
        contact con = new Contact(Id = perRecord.Participant_Contact__r.Id,
        Participant_Opt_In_Status_Emails__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
        Participant_Opt_In_Status_SMS__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
                IQVIA_Artificial_Voice_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Assisted_Dialing_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Pre_recorded_Voice_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
                IQVIA_Direct_Mail_Consent__c = perRecord.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
        Participant_Phone_Opt_In_Permit_Phone__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c);
    conlist.add(con);
    if(
        ( isDelUpdated && contactId != null && (delegateCriteria == 'updateDeligate' || delegateCriteria == 'insertDelegate' ) && 
        (perRecord.Participant__r.Email__c == null || string.isEmpty(perRecord.Participant__r.Email__c))) || 
        (patientDelegate != null && !patientDelegate.isEmpty() && patientDelegate[0].Primary_Delegate__c && 
         patientDelegate[0].Contact__c != null && patientDelegate[0].Participant__r.Email__c == null )){
                    contact delegateContact = new Contact();    
  
                      delegateContact.Participant_Opt_In_Status_Emails__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_Emails__c;   
                      delegateContact.Participant_Opt_In_Status_SMS__c = perRecord.Participant_Contact__r.Participant_Opt_In_Status_SMS__c; 
                      delegateContact.Participant_Phone_Opt_In_Permit_Phone__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c; 
                      delegateContact.IQVIA_Artificial_Voice_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c;    
                      delegateContact.IQVIA_Assisted_Dialing_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c;    
                      delegateContact.IQVIA_Pre_recorded_Voice_Consent__c = perRecord.Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c;  
                      delegateContact.IQVIA_Direct_Mail_Consent__c = perRecord.Participant_Contact__r.IQVIA_Direct_Mail_Consent__c; 
                  
                    if((delegateCriteria == 'updateDeligate' || delegateCriteria == 'insertDelegate') && isDelUpdated ){
                        delegateContact.id = contactId;
                    }else{
                        delegateContact.id = patientDelegate[0].Contact__c;
                    }
                    conlist.add(delegateContact);
                }
            
            update conlist;
        }
    } catch (Exception e) {
      bol = false;
      System.debug('e.getMessage(): ' + e.getMessage());
      System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
      throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
    }

    return bol;
  }
  public static void updateDelContact(Id delcon, Patient_Delegate__c peDeligate, Participant_Enrollment__c perRecord){
    contact con = new Contact();
    con.id =delcon;
    Contact getsms=[Select id,Participant_Opt_In_Status_SMS__c from Contact where id=:delcon  ];
    Boolean getSMSValue=getsms.Participant_Opt_In_Status_SMS__c;
    Study_Site__c ss = [SELECT Id, Site__c from Study_Site__c Where Id =: perRecord.Study_Site__c];
      con.AccountId = ss.Site__c;
      con.IQVIA_Contact_info_storage_consent__c =peDeligate.contact__r.IQVIA_Contact_info_storage_consent__c;
      con.Participant_Phone_Opt_In_Permit_Phone__c =peDeligate.contact__r.Participant_Phone_Opt_In_Permit_Phone__c;
      con.IQVIA_Assisted_Dialing_Consent__c =peDeligate.contact__r.IQVIA_Assisted_Dialing_Consent__c;
      con.Participant_Opt_In_Status_Emails__c =peDeligate.contact__r.Participant_Opt_In_Status_Emails__c;
      con.IQVIA_Artificial_Voice_Consent__c =peDeligate.contact__r.IQVIA_Artificial_Voice_Consent__c;
      con.IQVIA_Pre_recorded_Voice_Consent__c =peDeligate.contact__r.IQVIA_Pre_recorded_Voice_Consent__c;
      con.Participant_Opt_In_Status_SMS__c=peDeligate.contact__r.Participant_Opt_In_Status_SMS__c;
      con.IQVIA_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
      con.IQVIA_PI_Storage_Consent_Time__c = Datetime.now();
      con.IQVIA_Phone_Consent_Time__c = Datetime.now();
      con.IQVIA_Email_Consent_Time__c = Datetime.now();
      con.IQVIA_Assisted_Dialing_Consent_Time__c = Datetime.now();
      con.IQVIA_Artificial_Voice_Consent_Time__c = Datetime.now();
      if(peDeligate.contact__r.Participant_Opt_In_Status_SMS__c){
        con.IQVIA_SMS_Consent_Time__c = Datetime.now();
       }
      else if(getSMSValue!=con.Participant_Opt_In_Status_SMS__c){
        con.IQVIA_SMS_Consent_Time__c = Datetime.now();
        }
      
      update con;
    
  }
  public static void createPDE(Id delcon, Patient_Delegate__c peDeligate, Participant_Enrollment__c perRecord,ConsentDetailsWrapper consentWrapper){
      contact con = new Contact();
      con.id =delcon;
      con.AccountId = [Select Id,Participant__c,Participant__r.Contact__r.AccountId from Participant_Enrollment__c where Id=:perRecord.Id].Participant__r.Contact__r.AccountId;
      if(con.AccountId != null){
      update con;
      }
       
      List<Patient_Delegate_Enrollment__c> getPDE = new List<Patient_Delegate_Enrollment__c>();
      List<Patient_Delegate_Enrollment__c> updPDE = new List<Patient_Delegate_Enrollment__c>();
      getPDE = [Select Id,Participant_Enrollment__c,Primary_Delegate__c from Patient_Delegate_Enrollment__c where Participant_Enrollment__c=:perRecord.Id AND Primary_Delegate__c= TRUE];
      if(getPDE != null && !getPDE.isEmpty() && getPDE.size() != 0){
      for(Patient_Delegate_Enrollment__c pdes:getPDE){
        pdes.Primary_Delegate__c = false;
        updPDE.add(pdes);
      } 
      }
      if(updPDE != null && !updPDE.isEmpty() && updPDE.size() != 0){
          //update updPDE;
      }
     
      Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
      pde.Participant_Enrollment__c = perRecord.Id;
      pde.Patient_Delegate__c = peDeligate.Id;
      pde.Attested_By__c = peDeligate.Attested_by__c;
      pde.isInviteToPP__c = peDeligate.isInviteToPP__c;
      pde.Primary_Delegate__c = true;
      pde.Status__c =  'Disconnected';
      pde.Study_Email_Consent__c = consentWrapper.Study_Email_Consent;
      pde.Study_info_storage_consent__c = consentWrapper.Study_info_storage_consent;
      pde.Study_Phone_Consent__c = consentWrapper.Study_Phone_Consent;
      pde.Study_SMS_Consent__c = consentWrapper.Study_SMS_Consent;
     
      Insert pde;
    
  }
  @AuraEnabled
  public static Boolean getDupDelegateConsent(Id PEid,Id PartDelId,Boolean isCountryUs) {
    List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
    pder = [select id,Primary_Delegate__c,Participant_Enrollment__c,Patient_Delegate__c,Study_info_storage_consent__c,Study_Email_Consent__c,Study_Phone_Consent__c,Study_SMS_Consent__c
             from Patient_Delegate_Enrollment__c where Patient_Delegate__r.Participant_Delegate__c=:PartDelId AND Primary_Delegate__c = false AND Participant_Enrollment__c=:PEid limit 1];
    Boolean pderConsent = false;
    if(pder != null && pder.size() != 0){
       if(isCountryUs){
            if(pder[0].Study_info_storage_consent__c && pder[0].Study_Email_Consent__c  && pder[0].Study_Phone_Consent__c && pder[0].Study_SMS_Consent__c){
                 pderConsent = true;
                }
       }else{
            if(pder[0].Study_info_storage_consent__c && pder[0].Study_Email_Consent__c  && pder[0].Study_Phone_Consent__c){
                 pderConsent = true;
             }
       }
     
    }
    return pderConsent;
  }
   @AuraEnabled
  public static Boolean getDupDelegateExistingConsent(Id PEid,Id PartDelId,Boolean isCountryUs) {
    List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
    pder = [select id,Primary_Delegate__c,Participant_Enrollment__c,Patient_Delegate__c,Study_info_storage_consent__c,Study_Email_Consent__c,Study_Phone_Consent__c,Study_SMS_Consent__c
             from Patient_Delegate_Enrollment__c where Patient_Delegate__r.Participant_Delegate__c=:PartDelId AND Primary_Delegate__c = true AND Participant_Enrollment__c=:PEid limit 1];
    Boolean pderConsent = false;
    if(pder != null && pder.size() != 0){
       if(isCountryUs){
            if(pder[0].Study_info_storage_consent__c && pder[0].Study_Email_Consent__c  && pder[0].Study_Phone_Consent__c && pder[0].Study_SMS_Consent__c){
                 pderConsent = true;
                }
       }else{
            if(pder[0].Study_info_storage_consent__c && pder[0].Study_Email_Consent__c  && pder[0].Study_Phone_Consent__c){
                 pderConsent = true;
             }
       }
     
    }
    return pderConsent;
  }
  @AuraEnabled
  public static Boolean getPDERConsent(Id PEid) {
    List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
    pder = [select id,Primary_Delegate__c,Participant_Enrollment__c,Study_info_storage_consent__c from Patient_Delegate_Enrollment__c where Primary_Delegate__c = true AND Participant_Enrollment__c=:PEid limit 1];
    Boolean pderConsent = false;
    if(pder != null && pder.size() != 0){
      if(pder[0].Study_info_storage_consent__c){
      pderConsent = true;}
    }
    return pderConsent;
  }
}