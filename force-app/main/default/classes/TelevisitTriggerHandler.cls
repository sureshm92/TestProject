Public Class TelevisitTriggerHandler{
    @Future(callout=true)
    Public Static Void SendRequestToVonageAPI(list<Id> listTelevisitId){
        Televisit__c televisitRecord = [SELECT Id FROM Televisit__c WHERE Id = :listTelevisitId[0]];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.opentok.com/session/create');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('X-OPENTOK-AUTH', new OpenTokJWT('https://api.opentok.com', '47459271', 'eb094c1b6355f340f708c92f6151cc8377097f24').getAuthJWTHeader());
        req.setHeader('Accept', 'application/json');
        //req.setBody(null);    
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        TelevisitWrapper wrap = new TelevisitWrapper();
        wrap = (TelevisitWrapper)System.JSON.deserialize(res.getBody().substring(1, res.getBody().length() - 1), TelevisitWrapper.class);
        system.debug('Wrap Session Id :'+ wrap.session_id);
        
        Televisit__c updateTelevisitRecord = new Televisit__c();
        updateTelevisitRecord.Id = televisitRecord.Id;
        updateTelevisitRecord.Televisit_Request__c = String.valueOf(req);
        updateTelevisitRecord.Televisit_Response__c = res.getBody();
        updateTelevisitRecord.Session_Id__c = wrap.session_id;
        updateTelevisitRecord.Meeting_URL__c = '/apex/televisit?sessionId='+wrap.session_id;
        update updateTelevisitRecord;
    }
    
    public class TelevisitWrapper
    {
        public string session_id{ get; set; }
    }
}