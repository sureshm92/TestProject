/**
 * Created by Nargiz Mamedova on 1/20/2020.
 */

public without sharing class RemoteCall_GetCardDetails extends RemoteCall {

    public class GetCardDetailsResponse {
        public String first_name;
        public String middle_name;
        public String last_name;
        public String email;
        public String date_of_birth;
        public String uuid;
        public String mobile_phone;
        public String home_phone;
        public List<Card> cards;
    }

    public class Card {
        public String token;
        public String balance;
        public String status;
        public String assigned_date;
    }

    public static String F_Name;
    public static String L_Name;
    public static String Mail;
    public static String Payment_ID;

    public RemoteCall_GetCardDetails(String paymentId, Participant__c participant) {
        this.endPointURL = 'http://iqvia-rds-gp-payments-exp-1-0-dev.us-e1.cloudhub.io/api/carddetails';
        this.httpMethod = METHOD_GET;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'application/json'
        });
        Payment_ID = paymentId;
        F_Name = participant.First_Name__c;
        L_Name = participant.Last_Name__c;
        Mail = participant.Email__c;
    }

    public override Type getType() {
        return RemoteCall_GetCardDetails.class;
    }

    protected override String buildRequestBody() {
        return null;
    }

    protected override Object parseResponse(String responseBody) {
        Card resCard = new Card();
        responseBody = responseBody.remove('#').replaceAll('[\u00a0|\\s]','');
        responseBody = responseBody.replaceAll('\\["', '[{"').replaceAll('\\]]', ']}]');
        List<GetCardDetailsResponse> results = (List<GetCardDetailsResponse>) JSON.deserialize(responseBody, List<GetCardDetailsResponse>.class);
        for(GetCardDetailsResponse r : results) {
            for(Card c : r.cards) resCard = c;
        }
        return resCard;
    }
}