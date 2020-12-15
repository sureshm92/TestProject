public class Batch_SendAttachmentsToNYBC //implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts
{
    /*
	public List<String> failedRecords = new List<String>();
    public List<String> passedRecords = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String soqlQuery = 'SELECT Id,Participant_Enrollment__r.Name FROM Form_Results__c where Participant_Enrollment__c != null';
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Form_Results__c> scope) 
    {
        Map<String, String> mapFormResult = new Map<String, String>();
        for(Form_Results__c fr : scope)
        {
            mapFormResult.put(fr.Id, fr.Participant_Enrollment__r.Name);
        }
        
        for(Attachment attach: [select Body,ContentType,Name, CreatedDate, ParentId from Attachment WHERE ParentId IN: mapFormResult.keySet()])
        {
            String attachmentBody = EncodingUtil.base64Encode(attach.Body);
            String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            String key = 'AKIA4RWDYIYEUGG7G6GR'; //AWS key
            String secret = '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'; //AWS Secret key
            String bucketname = 's-46892'; //AWS bucket name
            String host = 's3.us-east-1.amazonaws.com';
            String method = 'PUT';
            String filename = 'attachments'+'/'+mapFormResult.get(attach.ParentId);
            HttpRequest req = new HttpRequest();
            req.setMethod(method);
            string fileUrl='https://' + bucketName + '.' + host + '/' + filename.toLowerCase()+ '.'+attach.ContentType.toLowerCase();
            req.setEndpoint(fileUrl);
            req.setHeader('Host', bucketname + '.' + host);
            req.setHeader('Access-Control-Allow-Origin', '*');
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', attach.ContentType);
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', formattedDateString);
            req.setHeader('ACL', 'public-read');
            req.setBodyAsBlob(attach.Body);
            String stringToSign = 'PUT\n\n' + attach.ContentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename.toLowerCase()+ '.'+attach.ContentType.toLowerCase();
            Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
            String signedKey  = EncodingUtil.base64Encode(mac);
            String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;
            req.setHeader('Authorization',authHeader);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() != 200)
            {
                failedRecords.add(mapFormResult.get(attach.ParentId));
            }
            else
            {
                passedRecords.add(mapFormResult.get(attach.ParentId));
            }
            System.debug('RESPONSE STRING: ' + res.getBody());
            System.debug('RESPONSE STRING: ' + res.toString());
            System.debug('RESPONSE STATUS: ' +res.getStatus());
            System.debug('STATUS_CODE: '+res.getStatusCode());
            //failedRecords.add(mapFormResult.get(attach.ParentId));
            //passedRecords.add(mapFormResult.get(attach.ParentId));
        }   
    }
    
   public void finish(Database.BatchableContext bc)
   {
        String documentFolder = System.Label.PE_History_Report; 
         /*List<String> toAddresses = new List<String>();
       RH_Email_Address__mdt[] emailAddresses = [SELECT MasterLabel, Email__c FROM RH_Email_Address__mdt]; 
        
        for(RH_Email_Address__mdt email : emailAddresses)
        {
            toAddresses.add(email.Email__c);
        }
        
        Folder folder = [SELECT Id, Name FROM Folder WHERE Name =: documentFolder LIMIT 1];
        List<String> csvRowValues = new List<String>();
        String documentName = 'NYBCAttachment'+ DateTime.now().formatGMT('MMM_d_yyyy_HH_mm');
        String CSV_COLUMN_HEADER = 'REFERAL ID, STATUS \n';
        
        if(!failedRecords.isEmpty())
        {
            for(String str : failedRecords)
            {
                String rowStr = str + ',' + 'Failed';
                csvRowValues.add(rowStr);
            }
            String csvFile = CSV_COLUMN_HEADER + String.join(csvRowValues,'\n');
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folder.Id, Type = 'csv', ContentType ='application/vnd.ms-excel');
            insert doc;
            
            String url = '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+doc.Id+'">'+'Click to download the attachment'+'</a></html>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'gulamsabir.khan@iqvia.com','sumit.surve@iqvia.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Failed NYBC Attachment');
            mail.setHtmlBody('Please click on the link to download NYBC Attachment \n' + url);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }
        
        if(!passedRecords.isEmpty())
        {
            for(String str : passedRecords)
            {
                String rowStr = str + ',' + 'Passed';
                csvRowValues.add(rowStr);
            }
            String csvFile = CSV_COLUMN_HEADER + String.join(csvRowValues,'\n');
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folder.Id, Type = 'csv', ContentType ='application/vnd.ms-excel');
            insert doc;
            
            String url = '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+doc.Id+'">'+'Click to download the attachment'+'</a></html>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'gulamsabir.khan@iqvia.com','sumit.surve@iqvia.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Passed NYBC Attachment');
            mail.setHtmlBody('Please click on the link to download NYBC Attachment \n' + url);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }
   }
*/
}