/**
 * Created by Nargiz Mamedova on 1/20/2020.
 */

public without sharing class RemoteCall_GetCardDetails extends RemoteCall {

    public class Card {
        public String balance;
        public String status;
    }

    public RemoteCall_GetCardDetails(String protocolId, String patientId) {
        this.endPointURL = 'callout:PaymentCredentials?protNbr=' + protocolId + '&patientId=' + patientId;
        this.httpMethod = METHOD_GET;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'application/json'
        });
    }

    public override Type getType() {
        return RemoteCall_GetCardDetails.class;
    }

    protected override String buildRequestBody() {
        return null;
    }

    protected override Object parseResponse(String responseBody) {
        List<Card> responseCards = (List<Card>) JSON.deserialize(responseBody, List<Card>.class);
        Card result = null;
        if(responseCards.size() > 0) result = responseCards[0];
        return result;
    }
}