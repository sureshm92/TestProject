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
        public String createdAt;
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

    public static String generateAccessToken(String humanId) {
        String accessToken;
        RequestWrapperToken reqWrap = new RequestWrapperToken();
        reqWrap.client_id = '72cd1f1f7b36cc80e104efd2a9332e74372fcb24';
        reqWrap.client_secret = '8338fd6645b6b430fe186729a1a873e7cd57a839';
        reqWrap.client_user_id = humanId;
        reqWrap.type = 'access';
        
        String requestBody = JSON.serialize(reqWrap);

        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://auth.humanapi.co/v1/connect/token');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('POST');
        req.setbody(requestBody);
        System.debug('###### request ' +req.getBody());
        HTTPResponse resp = h.send(req);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());

        ResponseWrapperToken deserializedResponseWrapperToken = (ResponseWrapperToken)JSON.deserialize(resp.getBody(), ResponseWrapperToken.class);
        accessToken = deserializedResponseWrapperToken.access_token;
        return accessToken;
    }

    public static List<ReportListWrapperWithURL> getListOfReports(String accessToken) {
        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://api.humanapi.co/v1/human/medical/reports');
        req.setHeader('Authorization', 'Bearer ' +accessToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('GET');
        HTTPResponse resp = h.send(req);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());

        List<ResponseWrapperReportList> deserializedResponseWrapperReportList = (List<ResponseWrapperReportList>)JSON.deserialize(resp.getBody(), List<ResponseWrapperReportList>.class);
        List<ReportListWrapperWithURL> reportUrlWrapperList = new List<ReportListWrapperWithURL>();
        for (ResponseWrapperReportList var: deserializedResponseWrapperReportList){
            ReportListWrapperWithURL wrap = new ReportListWrapperWithURL();
            String url = 'https://api.humanapi.co/v1/human/medical/reports/';
            String tail = '/raw?format=pdf&access_token='+accessToken;
            String reportId = var.id;
            String finalUrl = url + reportId + tail;
            wrap.reportName = var.name;
            wrap.reportUrl  = finalUrl;
            reportUrlWrapperList.add(wrap);
        }
        return reportUrlWrapperList;
    }

        public class ReportListWrapperWithURL{
        @AuraEnabled
        public String reportName;
        @AuraEnabled
        public String reportUrl;
    }
/*
    @AuraEnabled
    public static String getReports(String accessToken, String reportId) {
        String url = 'https://api.humanapi.co/v1/human/medical/reports/';
        String tail = '/raw?format=pdf';
        String finalUrl = url + reportId + tail;
        System.debug('@@@@@@@@finalUrl: ' + finalUrl);
        Http h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(finalUrl);
        req.setHeader('Authorization', 'Bearer ' +accessToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod('GET');
        HTTPResponse resp = h.send(req);
        System.debug('###### resp ' +resp);
        System.debug('###### resp ' +resp.getBody());

        return EncodingUtil.base64encode(resp.getBodyAsBlob());
    }
*/
    public class ReportListWrapper{
        @AuraEnabled
        public String accessToken;
        @AuraEnabled
        public List<ReportListWrapperWithURL> reportList;
    }

    @AuraEnabled
    public static ReportListWrapper getReportList(String humanId){
        try {
            String accessToken = generateAccessToken(humanId);
            ReportListWrapper wrap = new ReportListWrapper();
            wrap.accessToken = accessToken;
            wrap.reportList  = getListOfReports(accessToken);
            System.debug('##### wrap: ' + wrap);
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}