public with sharing class Integration_UCPM_TriggerHandler {
  public class ProcessResponse extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {
      try {
        Integer maxSize = 1000;
        for (
          Integration_UCPM_Org_PP__c res : (List<Integration_UCPM_Org_PP__c>) newList
        ) {
          String S1;
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
        }
      } catch (Exception e) {
        System.debug('e.getMessage(): ' + e.getMessage());
        System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
      }
    }

    public override void afterInsert(List<SObject> newList) {
      try {
        List<Clinical_Trial_Profile__c> ctpToUpdate = new List<Clinical_Trial_Profile__c>();
        for (
          Integration_UCPM_Org_PP__c res : (List<Integration_UCPM_Org_PP__c>) newList
        ) {
          if (res.Processing_Status__c != 'Failed') {
            String fullresponse;
            if (res.JSON2__c != null) {
              fullresponse = res.JSON1__c + res.JSON2__c;
            } else {
              fullresponse = res.JSON1__c;
            }
            System.debug('fullresponse: ' + fullresponse);
            List<ResponseWrapper> response = (List<ResponseWrapper>) JSON.deserialize(
              fullresponse,
              List<ResponseWrapper>.class
            );
            System.debug('response: ' + response);
            for (ResponseWrapper re : response) {
              String organizationId = re.Org.organizationId;
              for (ProcessingPurpose pp : re.ProcessingPurpose) {
                Clinical_Trial_Profile__c ct = new Clinical_Trial_Profile__c();
                System.debug('pp.applicationId: ' + pp.applicationId);
                ct.Id = pp.applicationId;
                ct.UCPM_Sponsor_Org_Id__c = organizationId;
                ct.UCPM_Study_Purpose_Id__c = pp.purposeId;
                ct.MDM_trigger_status__c = 'Completed';
                ctpToUpdate.add(ct);
              }
            }
          }
          // res.Processing_Status__c = 'Completed';
        }
        System.debug('######ctpToUpdate: ' + ctpToUpdate);
        update ctpToUpdate;
        //   update newList;
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