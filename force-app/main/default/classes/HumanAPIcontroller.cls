public with sharing class HumanAPIcontroller {

    public class RequestWrapperToken{
        public String client_id;
        public String client_secret;
        public String client_user_id;
        public String type;
    }

    public class ResponseWrapperToken{
        public String access_token;
        public String expires_in;
        public String token_type;
        public String refresh_token;
    }

    public class ResponseWrapperReportList{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Datetime createdAt;
        @AuraEnabled
        public String updatedAt;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public ResponseWrapperReportListOrganization organization;
    }

    public class ResponseWrapperReportListOrganization{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String href;
    }

    public static String generateAccessToken(String client_id, String client_secret, String humanId) {
        String accessToken = null;
        RequestWrapperToken reqWrap = new RequestWrapperToken();
        reqWrap.client_id = client_id;
        reqWrap.client_secret = client_secret;
        reqWrap.client_user_id = humanId;
        reqWrap.type = 'access';
        
        String requestBody = JSON.serialize(reqWrap);

        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:HumanAPI_Connect');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('POST');
        req.setbody(requestBody);
        System.debug('###### request ' +req.getBody());
        HTTPResponse resp = h.send(req);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());
        if(resp.getStatusCode() == 200){
            ResponseWrapperToken deserializedResponseWrapperToken = (ResponseWrapperToken)JSON.deserialize(resp.getBody(), ResponseWrapperToken.class);
            accessToken = deserializedResponseWrapperToken.access_token;
        }
        return accessToken;
    }

    public static List<ReportListWrapperWithURL> getListOfReports(String accessToken, String reportUrl) {
        List<ReportListWrapperWithURL> reportUrlWrapperList = new List<ReportListWrapperWithURL>();
        Map<String, String> sourceToSourceName = getSources(accessToken);
        if(!sourceToSourceName.isEmpty()){
            Http h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint('callout:HumanAPI_ReportList');
            req.setHeader('Authorization', 'Bearer ' +accessToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setMethod('GET');
            HTTPResponse resp = h.send(req);
            System.debug('###### resp ' +resp);
            System.debug('###### resp ' +resp.getBody());
            if(resp.getStatusCode() == 200){
                List<ResponseWrapperReportList> deserializedResponseWrapperReportList = (List<ResponseWrapperReportList>)JSON.deserialize(resp.getBody(), List<ResponseWrapperReportList>.class);
                for (ResponseWrapperReportList var: deserializedResponseWrapperReportList){
                    ReportListWrapperWithURL wrap = new ReportListWrapperWithURL();
                    if(var.name == 'unity'){
                            String url = reportUrl;
                            String tail = '/raw?format=pdf&access_token='+accessToken;
                            String reportId     = var.id;
                            String finalUrl     = url + reportId + tail;
                            wrap.reportName     = 'Detailed Report';
                            wrap.reportUrl      = finalUrl;
                            wrap.createdAt      = var.createdAt.format('MM/dd/yyyy');
                            wrap.providerName   = sourceToSourceName.get(var.organization.id);
                        reportUrlWrapperList.add(wrap);
                        }else if(var.name == 'highlights'){
                            String url = reportUrl;
                            String tail = '/raw?format=pdf&access_token='+accessToken;
                            String reportId     = var.id;
                            String finalUrl     = url + reportId + tail;
                            wrap.reportName     = 'Highlights Report';
                            wrap.reportUrl      = finalUrl;
                        reportUrlWrapperList.add(wrap);
                        }
                    
                }
            }
            
        }
        
        return reportUrlWrapperList;
    }

    public class ReportListWrapperWithURL{
        @AuraEnabled
        public String providerName;
        @AuraEnabled
        public String reportName;
        @AuraEnabled
        public String reportUrl;
        @AuraEnabled
        public String createdAt;
    }

    public class SourceDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String sourceName;
        @AuraEnabled
        public SyncStatus syncStatus;
    }

    public class SyncStatus{
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String details;
    }

    @AuraEnabled
    public static Map<String,String> getSources(String accessToken) {
        Map<String, String> sourceToSourceName = new Map<String, String>();
        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:HumanAPI_Sources');
        req.setHeader('Authorization', 'Bearer ' +accessToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('GET');
        HTTPResponse resp = h.send(req);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());
        if(resp.getStatusCode() == 200){
            List<SourceDetails> deserializedSourceList = (List<SourceDetails>)JSON.deserialize(resp.getBody(), List<SourceDetails>.class);
            for (SourceDetails s: deserializedSourceList){
                if(s.syncStatus.status == 'ok'){
                    sourceToSourceName.put(s.source, s.sourceName);
                }
            }
        }

        return sourceToSourceName;
    }

    public class ReportListWrapper{
        @AuraEnabled
        public String accessToken;
        @AuraEnabled
        public List<ReportListWrapperWithURL> reportList;
    }

    @AuraEnabled
    public static ReportListWrapper getReportList(String humanId){
        try {
            String clientId;
            String clientSecret;
            List<App_Credential__mdt> appCreds = [
            Select Id,Client_Id__c, Client_Secret__c,DeveloperName, Label 
            from App_Credential__mdt 
            where DeveloperName = 'Human_API_Creds'
            ];
            
            if (appCreds.size() > 0)
            {
                clientId = appCreds[0].Client_Id__c;
                clientSecret = appCreds[0].Client_Secret__c;
            }

            String reportUrl;
            List<NamedCredential > reportUrlList = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName = 'HumanAPI_ReportList'];
            if(reportUrlList.size()> 0){
                reportUrl = reportUrlList[0].Endpoint +'/';
            }

            ReportListWrapper wrap = new ReportListWrapper();
            String accessToken = generateAccessToken(clientId,clientSecret,humanId);
            if (accessToken != null) {
                wrap.accessToken = accessToken;
                wrap.reportList  = getListOfReports(accessToken, reportUrl);
            }
            
            System.debug('##### wrap: ' + wrap);
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}