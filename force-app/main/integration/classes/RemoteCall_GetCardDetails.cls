/**
 * Created by Nargiz Mamedova on 1/20/2020.
 */

public without sharing class RemoteCall_GetCardDetails extends RemoteCall {
    public class Card {
        @AuraEnabled
        public String balance;
        @AuraEnabled
        public String status;
    }

    public RemoteCall_GetCardDetails(String protocolId, String patientId) {
        this.endPointURL =
            'callout:PaymentCredentials?protNbr=' +
            protocolId +
            '&patientId=' +
            patientId;
        this.httpMethod = METHOD_GET;
        this.headersMap.putAll(new Map<String, String>{ 'Content-Type' => 'application/json' });
    }

    public override Type getType() {
        return RemoteCall_GetCardDetails.class;
    }

    protected override String buildRequestBody() {
        return null;
    }

    protected override Object parseResponse(String responseBody) {
       /* List<Card> responseCards = (List<Card>) JSON.deserialize(responseBody, List<Card>.class);
        for (Card card : responseCards) {
            if (card.balance.substring(card.balance.length() - 2).equals('.0'))
                card.balance = card.balance + '0';
            card.status =
                card.status.substring(0, 1).toUpperCase() + card.status.substring(1).toLowerCase();
        }
        return responseCards;*/
        List<Card>  responseCards = new List<Card>();
        if(responseCode==200){
            responseCards = (List<Card>) JSON.deserialize(responseBody, List<Card>.class);
            for (Card card : responseCards) {
                if (card.balance.substring(card.balance.length() - 2).equals('.0'))
                    card.balance = card.balance + '0';
                card.status =
                    card.status.substring(0, 1).toUpperCase() + card.status.substring(1).toLowerCase();
            }
        }

        return responseCards;
    }
}
