/**
 * Created by Nargiz Mamedova on 12/13/2019.
 */

public with sharing class RelevantLinksRemote {
    @AuraEnabled
    public static List<TravelVendor__c> getInitData() {
        try {
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            return TravelSupportHelper.getVendors(ps.pe.Study_Site__c);
        } catch (Exception e) {
            return (List<TravelVendor__c>) AuraHelper.throwException(e);
        }
    }
}