/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

public without sharing class PaymentsRemote {
    public class InitData{
        @AuraEnabled public List<RemoteCall_GetCardDetails.Card> cards;
        @AuraEnabled public String href;
        @AuraEnabled public Boolean informationAvailable;
    }

    @AuraEnabled
    public static InitData getPaymentData() {
        try {
            InitData initData = new InitData();
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            RemoteCall_GetCardDetails remoteCallGetCardDetails = new RemoteCall_GetCardDetails(
                    ps.pe.Clinical_Trial_Profile__r.Protocol_ID__c,
                    ps.pe.Screening_ID__c);
            List<RemoteCall_GetCardDetails.Card> result = (List<RemoteCall_GetCardDetails.Card>)remoteCallGetCardDetails.execute();
            initData.informationAvailable = false;
            initData.href = 'none';

            if(remoteCallGetCardDetails.log.Success__c) {
                initData.cards = result;
                if(!result.isEmpty()) initData.informationAvailable = true;
            }

            initData.href = PaymentService.getPaymentVendorLink(ps.pe.Study_Site__c);

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
    //@Krishna Mahto - PEH-2179 - Start 
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method will return the current communityName
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @Method:   getCommunityName
    * @param:    NA   
    * @return:   Strings  
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    @auraEnabled
    public static String getCommunityName(){
		String communityName=FindCommunityName.getCommunityName();
        return communityName;
    }
    
    //@Krishna Mahto - PEH-2179 - End
}