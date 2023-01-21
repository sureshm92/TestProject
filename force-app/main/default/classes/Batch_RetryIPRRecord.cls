public class Batch_RetryIPRRecord   extends Batch_ScheduledAbstract implements Database.AllowsCallouts{
    
    public static final EPR_Validation_Message__mdt objMetadataRecord = [SELECT Retry_Count__c,Batch_Run_Frequency__c
                                                                         FROM EPR_Validation_Message__mdt WHERE Error_Message__c = '' 
                                                                         and Batch_Run_Frequency__c != Null LIMIT 1];
    public static final List<EPR_Validation_Message__mdt> lstEmailRecord = [SELECT SendFailedIPRReport__c FROM EPR_Validation_Message__mdt 
                                                                            WHERE SendFailedIPRReport__c != Null
                                                                            And Error_Message__c = ''];
     
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = 'SELECT ID,Batch_consideration__c,Is_retry_required__c,Error_Message__c,Address_Country__c,address_state__c,Retry_Count__c';
        strQuery += ' ,Delegate_Mailing_State__c,Language_Preference__c,protocolId__c,siteSelected__c,Report_Count_Days__c FROM Integration_Patient_Referral__c';
        strQuery += ' WHERE Is_retry_required__c = True AND Batch_consideration__c = \'Processing\' ' ;
        
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Integration_Patient_Referral__c> lstIPRrecords) {
        List<Integration_Patient_Referral__c> lstIPRToUpdate = new List<Integration_Patient_Referral__c> ();
        IprEprTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler objCheckReq = new IprEprTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler();
        objCheckReq.setCTP_PrimaryKey_forBatch(lstIPRrecords);
        for(Integration_Patient_Referral__c objIPR : lstIPRrecords){ 
            
            String strcheckValid = objCheckReq.checkFieldsForBatchValidation(objIPR);
            if(strcheckValid == 'True'){
                objIPR.Is_retry_required__c = false;
                objIPR.Batch_consideration__c = 'Not completed';
                objIPR.Error_Message__c = '';
            } 
            else{
                objIPR.Is_retry_required__c = True;
                objIPR.Retry_Count__c = objIPR.Retry_Count__c + 1;
                Decimal reportCountDays = objIPR.Retry_Count__c / objMetadataRecord.Batch_Run_Frequency__c;
                objIPR.Batch_consideration__c  = reportCountDays >= objMetadataRecord.Retry_Count__c ? 'Archieved' : 'Processing';
                objIPR.Error_Message__c = strcheckValid;
            }
            lstIPRToUpdate.add(objIPR); 
        }
        
        if(!lstIPRToUpdate.isEmpty()){
            try {
                update lstIPRToUpdate;    
            }catch(Exception ex){
                system.debug('>>Issue with update in Batch_RetryIPRRecord '+ex.getMessage());
            }
        }
        
    } 
    
    public override virtual void finalAction() {    
        
        List<Integration_Patient_Referral__c> lstIntegrationPatient = new List<Integration_Patient_Referral__c> ();
        lstIntegrationPatient = [SELECT ID FROM Integration_Patient_Referral__c Where 
                                 Is_retry_required__c = True AND Batch_consideration__c != 'Archieved' LIMIT 10];
        if(lstIntegrationPatient.size() > 0){
            List<Report> lstReport = [SELECT Id, Name, DeveloperName FROM Report where 
                              DeveloperName = 'IPR_validation_Report_PwY' ]; 
            Report report1 = !lstReport.isEmpty() ? lstReport[0] : new Report();
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List< Messaging.EmailFileAttachment> lstAttachment = new List< Messaging.EmailFileAttachment>();
            
            ApexPages.PageReference report22 = new ApexPages.PageReference('/'+report1.id+'?csv=1&isdtp=p1');
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('EPRFailedReport.csv');
            if(!test.isRunningTest()){
            attachment.setBody(report22.getContent());
            }
            else{
                attachment.setBody(blob.valueof('TEST'));
            }
            attachment.setContentType('text/csv');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            message.setSubject(System.Label.Send_IPREmailReport_Subject);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'updates@mail.clinicalresearch.com'];
            if ( owea.size() > 0 ) {
                message.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            message.setHtmlBody(System.Label.Send_IPREmailReport_Body); 
            List<String> lstTooAddress = new List<String> ();
            for(EPR_Validation_Message__mdt objMt : lstEmailRecord){
                lstTooAddress.add(objMt.SendFailedIPRReport__c);
            }
            if(test.isRunningTest()){
                lstTooAddress.add('someone@sendFailedRecTo.com');
            }
            message.setToAddresses(lstTooAddress);
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } ); 
        }
    }
    
    
    public override Type getType() {
        return Batch_RetryIPRRecord.class;
    } 
    
    public override virtual String getBatchDescription() {
        return 'Retry Failed IPR records';
    }
   /* public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }
    
    public override Integer getRecommendedRelaunchInterval() {
        return 4;
    } */
    
}