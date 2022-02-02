public without sharing class CreateBiomarkerRecords {
    public CreateBiomarkerRecords() {

    }
    @InvocableMethod(label='Insert Biomarker Records' description='Inserts Biomarker header and raleted records.' category= 'Integration_Biomarker__c')
    public static void saveBiomarkerRecords(List<Integration_Biomarker__c> stagingRecords) {
        System.debug('List<List<Integration_Biomarker__c>>:'+stagingRecords);
        List<RH_Biomarker__c> headersToBeInserted = new List<RH_Biomarker__c>();
        List<String> perReferrals = new List<String>();
        Map<Id,DataJSON> parsedDataMap = new Map<Id,DataJSON>();
        Map<Id,List<ResultJSON>> parsedResultMap = new Map<Id,List<ResultJSON>>();
        Map<Id,List<ResultJSON>> parsedFileMap = new Map<Id,List<ResultJSON>>();
        List<Biomarker_Result__c> resultList = new List<Biomarker_Result__c>();
        List<Id> integrationBiomarkerIds = new List<Id>();
        Map<String,Participant_Enrollment__c> permap = new Map<String,Participant_Enrollment__c>();
        Map<Id,List<ContentDocumentLink>> contentDocumentLinkMapDetails = new Map<Id,List<ContentDocumentLink>>();
        List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();

        for(Integration_Biomarker__c rec: stagingRecords) {
            //RH_Biomarker__c headerRec = new RH_Biomarker__c();
            String dataJson;
            integrationBiomarkerIds.add(rec.Id);
            if(String.isNotBlank(rec.Data_JSON1__c)) {
                dataJson = rec.Data_JSON1__c;
            } 
            if(String.isNotBlank(rec.Data_JSON2__c)) {
                dataJson += rec.Data_JSON2__c;
            }
            if(String.isNotBlank(dataJson)) { // parse data Json
                parsedDataMap.put(rec.Id,parseDataJSON(dataJson));
                perReferrals.add(parsedDataMap.get(rec.Id).referral_id);
            }
            String resultJson;
            if(String.isNotBlank(rec.Result_JSON1__c)) {
                resultJson = rec.Result_JSON1__c;
            }
            if(String.isNotBlank(rec.Result_JSON2__c)) {
                resultJson += rec.Result_JSON2__c;
            }

            if(String.isNotBlank(resultJson)) { // parse Result Json
                parsedResultMap.put(rec.Id,parseResultJSON(resultJson));
            }
        }

        
        if(!perReferrals.isEmpty()) {
            permap = fetchPERRecords(perReferrals);
        }

        for(Integration_Biomarker__c rec: stagingRecords) {
            RH_Biomarker__c headerRec = new RH_Biomarker__c();
            headerRec.Assessed_On__c = rec.Assessed_On__c;
            headerRec.Assessed_on_datetime__c = headerRec.Assessed_On__c .format('yyyy/MM/dd hh:mm a');
            headerRec.Error_Message__c = rec.Error_Message__c;
            headerRec.Integration_Biomarker__c = rec.Id;
            if(permap.containsKey(parsedDataMap.get(rec.Id).referral_id)) {
                headerRec.Participant_Enrollment__c = permap.get(parsedDataMap.get(rec.Id).referral_id).Id;
            }
            headerRec.Status__c = rec.Status__c;
            headerRec.Vendor_Source__c = rec.Vendor_Source__c;
            headerRec.Referral_Auto_Dialer_Consent__c = parsedDataMap.get(rec.Id).referral_auto_dialer_consent;
            headersToBeInserted.add(headerRec);
        }

        if(!headersToBeInserted.isEmpty()) {

            Database.insert(headersToBeInserted);
            //Fetch Files attached to Integration records
            contentDocumentLinkMapDetails = fetchContentLink(integrationBiomarkerIds);
            
            for(RH_Biomarker__c biomarkRec: headersToBeInserted) {
                
                if(parsedResultMap.containsKey(biomarkRec.Integration_Biomarker__c)) {
                    for(ResultJSON result:parsedResultMap.get(biomarkRec.Integration_Biomarker__c) ) {
                        Biomarker_Result__c resultDetail = new Biomarker_Result__c();
                        resultDetail.Biomarker__c = biomarkRec.Id;
                        resultDetail.Key__c = result.key;
                        resultDetail.Value__c = result.value;
                        resultDetail.Type__c = 'Data';
                        resultList.add(resultDetail);
                    }
                }

                /*if(contentDocumentLinkMap.containsKey(biomarkRec.Integration_Biomarker__c)) {
                    ContentDocumentLink contentLink = new ContentDocumentLink();
                    contentLink.LinkedEntityId = biomarkRec.Id;
                    contentLink.ContentDocumentId = contentDocumentLinkMap.get(biomarkRec.Integration_Biomarker__c).ContentDocumentId;
                    contentLink.ShareType = 'V';
                    contentLinkList.add(contentLink);
                }*/
                if(contentDocumentLinkMapDetails.containsKey(biomarkRec.Integration_Biomarker__c)) {
                    List<ContentDocumentLink> contentList = contentDocumentLinkMapDetails.get(biomarkRec.Integration_Biomarker__c);
                    for(ContentDocumentLink cdl:contentList) {
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.LinkedEntityId = biomarkRec.Id;
                        contentLink.ContentDocumentId = cdl.ContentDocumentId;
                        contentLink.ShareType = 'V';
                        contentLinkList.add(contentLink);
                    }
                }
            }
        }

        if(!contentLinkList.isEmpty()) {
            Database.insert(contentLinkList);
        }

        if(!resultList.isEmpty()) {
            database.insert(resultList);
        }

        
    }

    private static DataJSON parseDataJSON(String dataJson) {
        DataJSON parsedData = new DataJSON();
        parsedData = (DataJSON)JSON.deserialize(dataJson,DataJSON.class);
        return parsedData;

    }

    public static List<ResultJSON> parseResultJSON(String resultJson) {
        //List<ResultJSON> resultJsonList= (List<ResultJSON>)JSON.deserialize(resultJson,List<ResultJSON>.class);
        List<ResultJSON> resultJsonList = new List<ResultJSON>();
        Map<String, Object> parsedMap =   (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        for(String key:parsedMap.keyset()) {
            ResultJSON result = new ResultJSON();
            result.key = key;
            result.value = String.valueOf(parsedMap.get(key));
            resultJsonList.add(result);
        }
        return resultJsonList;
    }

    private static Map<String,Participant_Enrollment__c> fetchPERRecords(List<String> perReferrals) {
        Map<String,Participant_Enrollment__c> perMap = new Map<String,Participant_Enrollment__c>();

        for(Participant_Enrollment__c per: [SELECT Id,Name FROM Participant_Enrollment__c WHERE Name IN:perReferrals]) {
            perMap.put(per.Name,per);
        }

        return perMap;
    }

    private static Map<Id,List<ContentDocumentLink>> fetchContentLink(List<Id> integrationBiomarkerIds) {
        Map<Id,List<ContentDocumentLink>> contentDocumentLinkMap = new Map<Id,List<ContentDocumentLink>>();

        for(ContentDocumentLink cdl: [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType,Visibility 
                    FROM ContentDocumentLink WHERE LinkedEntityId IN : integrationBiomarkerIds]) {
            
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            if(contentDocumentLinkMap.containsKey(cdl.LinkedEntityId)) {
                
                cdlList = contentDocumentLinkMap.get(cdl.LinkedEntityId);
                cdlList.add(cdl);
                contentDocumentLinkMap.put(cdl.LinkedEntityId,cdlList);
            } else {
                cdlList.add(cdl);
                contentDocumentLinkMap.put(cdl.LinkedEntityId,cdlList);
            }            

        }
        return contentDocumentLinkMap;
    }

    public class DataJSON {
        public String referral_id;
        public String referral_language;        
        public String referral_country;
        public String site_id;
        public String protocol_id;
        public DateTime referral_auto_dialer_consent;
        public String user_feedback;
    }

    public class ResultJSON {
        public String key;
        public String value;
    }
}