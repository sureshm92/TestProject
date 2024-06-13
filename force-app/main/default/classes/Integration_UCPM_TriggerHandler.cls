public with sharing class Integration_UCPM_TriggerHandler {
  public class ProcessResponse extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {
      Integer maxSize = 100000;
      for (
        Integration_UCPM_Org_PP__c res : (List<Integration_UCPM_Org_PP__c>) newList
      ) {
        if (
          res.Processing_Status__c != 'Failed' &&
          res.Processing_Status__c != 'Completed'
        ) {
          String S1;
          try {
            if (res.JSON1__c.length() <= maxSize) {
              res.Processing_Status__c = 'In Progress';
            } else if (
              res.JSON1__c.length() > maxSize &&
              res.JSON1__c.length() <= 200000
            ) {
              S1 = res.JSON1__c.substring(0, maxSize);
              res.JSON2__c = res.JSON1__c.substring(
                maxSize,
                res.JSON1__c.length()
              );
              res.JSON1__c = S1;
              res.Processing_Status__c = 'In Progress';
            } else {
              S1 = res.JSON1__c.substring(0, maxSize);
              res.JSON2__c = res.JSON1__c.substring(maxSize, 200000);
              res.JSON1__c = S1;
              res.Error_message__c = 'JSON String too large';
              res.Processing_Status__c = 'Failed';
            }
          } catch (Exception e) {
            S1 = res.JSON1__c.substring(0, maxSize);
            res.JSON2__c = res.JSON1__c.substring(maxSize, 200000);
            res.JSON1__c = S1;
            res.Error_message__c = e.getMessage();
            res.Processing_Status__c = 'Failed';
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
          }
        }
      }
    }

    public override void afterInsert(List<SObject> newList) {
      try {
        List<Integration_UCPM_Org_PP__c> resListTobeUpdated = new List<Integration_UCPM_Org_PP__c>();
        List<Clinical_Trial_Profile__c> ctpToUpdate = new List<Clinical_Trial_Profile__c>();
        List<Integration_UCPM_Org_PP__c> newListStagging = (List<Integration_UCPM_Org_PP__c>) newList;
        for (Integration_UCPM_Org_PP__c res : newListStagging) {
          Integration_UCPM_Org_PP__c tempStagging = new Integration_UCPM_Org_PP__c();
          if (
            res.Processing_Status__c != 'Failed' &&
            res.Processing_Status__c != 'Completed'
          ) {
            try {
              tempStagging.Id = res.Id;
              tempStagging.Processing_Status__c = 'Completed';
              String fullresponse;
              if (res.JSON2__c != null) {
                fullresponse = res.JSON1__c + res.JSON2__c;
              } else {
                fullresponse = res.JSON1__c;
              }
              List<ResponseWrapper> response = (List<ResponseWrapper>) JSON.deserialize(
                fullresponse,
                List<ResponseWrapper>.class
              );
              for (ResponseWrapper re : response) {
                if (String.isNotBlank(re.Org.organizationId)) {
                  String organizationId = re.Org.organizationId;
                  for (ProcessingPurpose pp : re.ProcessingPurpose) {
                    Clinical_Trial_Profile__c ct = new Clinical_Trial_Profile__c();
                    if (pp.applicationId != null && pp.purposeId != null) {
                      ct.Id = pp.applicationId;
                      ct.UCPM_Sponsor_Org_Id__c = organizationId;
                      ct.UCPM_Study_Purpose_Id__c = pp.purposeId;
                      ct.MDM_trigger_status__c = 'Completed';
                      ctpToUpdate.add(ct);
                    } else if (
                      pp.applicationId != null &&
                      pp.purposeId == null
                    ) {
                      //error handling when processing purpose creation has failed
                      ct.Id = pp.applicationId;
                      ct.MDM_trigger_status__c = 'Failed';
                      ct.UCPM_error_message__c =
                        'CODE: ' +
                        re.code +
                        ' STATUS ' +
                        re.status +
                        ' ORG.MESSAGE ' +
                        re.Org.message +
                        ' PP.MESSAGE ' +
                        pp.message;
                      ctpToUpdate.add(ct);
                      tempStagging.Processing_Status__c = 'Failed';
                    }
                  }
                } else {
                  //error handling when org creation has failed
                  if (!re.ProcessingPurpose.isEmpty()) {
                    for (ProcessingPurpose pp : re.ProcessingPurpose) {
                      Clinical_Trial_Profile__c ct = new Clinical_Trial_Profile__c();
                      if (pp.applicationId != null) {
                        ct.Id = pp.applicationId;
                        ct.MDM_trigger_status__c = 'Failed';
                        ct.UCPM_error_message__c =
                          'CODE: ' +
                          re.code +
                          ' STATUS ' +
                          re.status +
                          ' ORG.MESSAGE ' +
                          re.Org.message;
                        ctpToUpdate.add(ct);
                        tempStagging.Processing_Status__c = 'Failed';
                      }
                    }
                  }else{
                    tempStagging.Processing_Status__c = 'Failed';
                    tempStagging.Error_message__c = re.Org.message;
                  }
                }
              }
            } catch (Exception e) {
              tempStagging.Processing_Status__c = 'Failed';
              tempStagging.Error_message__c = e.getMessage();
              System.debug('e.getMessage(): ' + e.getMessage());
              System.debug(
                'e.getStackTraceString(): ' + e.getStackTraceString()
              );
            }
          }
          resListTobeUpdated.add(tempStagging);
        }
        //TODO: need to write all CTP bypass trigger logic
        if (!ctpToUpdate.isEmpty()) {
          update ctpToUpdate;
        }
        if (!resListTobeUpdated.isEmpty()) {
          update resListTobeUpdated;
        }
      } catch (Exception e) {
        System.debug('e.getMessage(): ' + e.getMessage());
        System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
      }
    }
  }

  //Response wrapper class
  public class ResponseWrapper {
    public Integer code;
    public String status;
    public String transactionId;
    public Org Org;
    public List<ProcessingPurpose> ProcessingPurpose;
  }

  public class Org {
    public String organizationId;
    public String name;
    public String externalId;
    public String message;
  }

  public class ProcessingPurpose {
    public String name;
    public String purposeId;
    public String applicationId;
    public String message;
  }
}