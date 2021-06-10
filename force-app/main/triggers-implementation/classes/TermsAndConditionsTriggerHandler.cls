/**
 * Created by Igor Malyuta on 17.04.2019.
 */

public without sharing class TermsAndConditionsTriggerHandler {
    public  final String FORM_HTML_START = '<HTML><BODY>';
    public  final String FORM_HTML_END = '</BODY></HTML>';
    public Static Boolean isPDFCreated= false;
    public class TCTriggerHandlerException extends Exception {
    }

    public class ActivePortalFieldsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            resetCheckBox(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            resetCheckBox(newList, (Map<Id, Terms_And_Conditions__c>) oldMap);
        }

        public void resetCheckBox(
            List<Terms_And_Conditions__c> newList,
            Map<Id, Terms_And_Conditions__c> oldMap
        ) {
            List<Terms_And_Conditions__c> activeTCList = new List<Terms_And_Conditions__c>();
            List<String> commNames = new List<String>();
            List<String> tcTypes = new List<String>();
            for (Terms_And_Conditions__c tc : newList) {
                if (
                    tc.Active__c == true &&
                    (oldMap == null || (oldMap != null && !oldMap.get(tc.Id).Active__c))
                ) {
                    activeTCList.add(tc);
                    commNames.add(tc.Community_Name__c);
                    tcTypes.add(tc.T_C_Type__c);
                }
            }
            if (activeTCList.size() > 1)
                throw new TCTriggerHandlerException('Only one Terms and Conditions can be active');

            if (!activeTCList.isEmpty()) {
                List<Terms_And_Conditions__c> termsAndConditions = [
                    SELECT Id, Active__c
                    FROM Terms_And_Conditions__c
                    WHERE
                        Active__c = TRUE
                        AND Id NOT IN :activeTCList
                        AND Community_Name__c IN :commNames
                        AND T_C_Type__c IN :tcTypes
                ];
                for (Terms_And_Conditions__c tc : termsAndConditions)
                    tc.Active__c = false;
                update termsAndConditions;
            }
        }
    }
    
    public void generateTCPDF(Map<Id,Terms_And_Conditions__c> tcRecords)
    {   System.debug('tcRecords: '+tcRecords);
        Map<Id,Terms_And_Conditions__c> ppMap = new Map<Id,Terms_And_Conditions__c>();
        Set<Id> contentDocIds = new Set<Id>(); // cd ids
        Map<Id,String> contentDocIdsToUpdate = new Map<Id,String>(); // cd ids
        Map<Id,ContentDocumentLink> cdlPpMap = new Map<Id,ContentDocumentLink>();
        Map<Id,ContentDocumentLink> cdIdcdlMap = new Map<Id,ContentDocumentLink>(); // cd id and cdl map
        Map<Id,String> ppPdfContentMap = new Map<Id,String>();
        Map<Id,String> cdIdTitleMap = new Map<Id,String>();
        for (Terms_And_Conditions__c tc : tcRecords.values()) {
            String pdfContent = '' + FORM_HTML_START;
            try
            {
                //pdfContent =+ '<img src="/resource/'+ timestamp+ '/Images/iqviaLogoo.png" />';
                pdfContent = '' + FORM_HTML_START;
                
                pdfContent = pdfContent + '<H2>Privacy Policy Information in PDF</H2>';

                pdfContent = pdfContent + tc.T_C_Text__c + FORM_HTML_END;
                ppPdfContentMap.put(tc.Id,pdfContent);
            }
            catch(Exception e)
            {
                pdfContent = '' + FORM_HTML_START;
                pdfContent = pdfContent + '<P>THERE WAS AN ERROR GENERATING PDF: ' + e.getMessage() + '</P>';
                pdfContent = pdfContent + FORM_HTML_END;
            }
        }
        System.debug('tcRecords.keySet(): '+tcRecords.keySet());
        for (ContentDocumentLink cdl :[SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Description,ContentDocument.FileType ,ContentDocument.Title 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId 
                                        IN :tcRecords.keySet() 
                                        AND ContentDocument.FileType = 'PDF'])
        {   
            //contentDocIds.add(cdl.ContentDocumentId);
            cdlPpMap.put(cdl.LinkedEntityId,cdl);
            cdIdTitleMap.put(cdl.ContentDocumentId,cdl.ContentDocument.Description);
            cdIdcdlMap.put(cdl.ContentDocumentId,cdl);
        }
        System.debug('cdlPpMap: '+cdlPpMap);
        System.debug('cdIdTitleMap: '+cdIdTitleMap);
        for(Terms_And_Conditions__c tc :tcRecords.values())
        {   
            if (cdlPpMap != null && !cdlPpMap.isEmpty()){
                if(cdlPpMap.containskey(tc.Id)){
                if(tc.Name == cdlPpMap.get(tc.Id).ContentDocument.Description)
                {
                    contentDocIdsToUpdate.put(cdlPpMap.get(tc.Id).ContentDocumentId,ppPdfContentMap.get(tc.Id));// cd ids for cv to be updated
                }
               }
               
                
            }
            else {
                    ppMap.put(tc.Id,tc);// pp ids to create new cd
                }
            
        }
        System.debug('contentDocIdsToUpdate: '+contentDocIdsToUpdate);
        System.debug('ppMap: '+ppMap);
        if (contentDocIdsToUpdate != null && !contentDocIdsToUpdate.isEmpty())
        {
            updateContentDocument(contentDocIdsToUpdate,cdIdTitleMap,cdIdcdlMap);// function to update cd 
        }
        if (ppMap != null && !ppMap.isEmpty())
        {
            insertPdfContent(ppMap,ppPdfContentMap);
        }
        
    }
    public void updateContentDocument(Map<Id,String> updateCdMap,Map<Id,String> cdIdTitleMap,Map<Id,ContentDocumentLink> cdlPpMap){
        System.debug('updateCdMap: '+updateCdMap);
        System.debug('cdlPpMap: '+cdlPpMap);
        List<ContentVersion> conVerList = new List<ContentVersion>();
        List<ContentDocumentLink> condlList = new List<ContentDocumentLink>();
        List<ContentDistribution> conDist = new List<ContentDistribution>();
        for(Id conDocId : updateCdMap.keySet())
        {
            
            Blob body;
            PageReference pdf = Page.ShowPrivacyPolicyAsPDF;
            pdf.getParameters().put('id', cdlPpMap.get(conDocId).LinkedEntityId);
            body=pdf.getContent();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient =  'PrivacyPolicy.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Description = cdIdTitleMap.get(conDocId); // Display name of the files
            conVer.Title = 'PrivacyPolicy';
            conVer.VersionData = body;//Blob.toPDF(updateCdMap.get(conDocId)); // converting your binary string to Blog
            conVer.ContentDocumentId = conDocId;
            conVerList.add(conVer);
            //insert conVer;    //Insert ContentVersion
        }
        try{
            if(conVerList!=null && !conVerList.isEmpty()){
                Insert conVerList;
            }
            for(ContentVersion conv : conVerList)
            {
                ContentDistribution cdist = new ContentDistribution(
                Name = conv.Title,
                ContentVersionId = conv.Id
                );
                conDist.add(cdist);
            }
            if(conDist!=null && !conDist.isEmpty()){
                insert conDist;
            }
        }catch(Exception e)
        {
           throw new TCTriggerHandlerException('ContentVersion insert error'+e.getMessage());
        }
    }
    public void insertPdfContent(Map<Id,Terms_And_Conditions__c> ppMap, Map<Id,String> ppPdfContentMap)
    {   System.debug('ppMap: '+ppMap);
        
        List<ContentVersion> conVerList = new List<ContentVersion>();
        List<ContentDocumentLink> condlList = new List<ContentDocumentLink>();
        List<ContentDistribution> conDist = new List<ContentDistribution>();
        Set<Id> contvIds = new Set<Id>();
        Map<String,ContentVersion> conDocMap = new Map<String,ContentVersion>();
        try
        {
            if(!isPDFCreated){
                for(Terms_And_Conditions__c tc : ppMap.values())
                {    Blob body;
                    PageReference pdf = Page.ShowPrivacyPolicyAsPDF;
                    pdf.getParameters().put('id', tc.Id);
                    body=pdf.getContent();
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                    conVer.PathOnClient = 'PrivacyPolicy.pdf';  // The files name, extension is very important here which will help the file in preview.
                    conVer.Description = tc.Name; // Display name of the files
                    conVer.Title = 'PrivacyPolicy';
                    conVer.VersionData = body; // converting your binary string to Blog
                    conVerList.add(conVer);
                    //insert conVer;    //Insert ContentVersion
                }
                if(conVerList!=null && !conVerList.isEmpty()){
                    insert conVerList;
                
                    for(ContentVersion conv : conVerList)
                    {
                        contvIds.add(conv.Id);
                        ContentDistribution cdist = new ContentDistribution(
                        Name = conv.Title,
                        ContentVersionId = conv.Id
                        );
                        conDist.add(cdist);
                    }
                }
                if(conDist!=null && !conDist.isEmpty()){
                    insert conDist;
                }
                System.debug('contvIds: '+contvIds);
                for(ContentVersion conDoc : [SELECT Id,ContentDocumentId,ContentDocument.Title,ContentDocument.Description FROM ContentVersion WHERE Id IN :contvIds])
                {
                    conDocMap.put(conDoc.ContentDocument.Description,conDoc);
                }
                System.debug('conDocMap: '+conDocMap); 
                for(Terms_And_Conditions__c tc : ppMap.values())
                {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = tc.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink.ContentDocumentId = conDocMap.get(tc.Name).ContentDocumentId;  //ContentDocumentId Id from ContentVersion
                    conDocLink.Visibility = 'AllUsers';
                    condlList.add(conDocLink);
                    //insert conDocLink;
                }
                if(condlList!=null && !condlList.isEmpty()){
                    insert condlList;
                }
                
                //insert attachmentPDF;
                isPDFCreated=true;
            }
        }catch(Exception e)
        {
           throw new TCTriggerHandlerException('PDF insert error'+e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void generatePDF(List<id> ids)
    {   System.debug('ids: '+ids);
         // Perform some operations
         Map<Id,Terms_And_Conditions__c> tcRecordsbyId= new Map<Id,Terms_And_Conditions__c>();
         List<Terms_And_Conditions__c> allTCRecords= new List<Terms_And_Conditions__c>();
         allTCRecords=[Select id,name,Active__c,Language__c,Master_Terms_And_Conditions__c,Policy_Headers__c,T_C_Text__c,T_C_Type__c,Unique_Id__c,Last_Updated_on__c 
                        from Terms_And_Conditions__c
                        WHERE id IN : ids];
         
         if(allTCRecords!=null && allTCRecords.size()>0){
             
             for(Terms_And_Conditions__c TC:allTCRecords){
                 tcRecordsbyId.put(TC.ID,TC);
             }
         }
         
         TermsAndConditionsTriggerHandler th= new TermsAndConditionsTriggerHandler();
         th.generateTCPDF(tcRecordsbyId);
         
    }
}