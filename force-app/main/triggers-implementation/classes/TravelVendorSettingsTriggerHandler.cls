public with sharing class TravelVendorSettingsTriggerHandler {
    public class CreatePreEnrollmentVisits extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createPreEnrollVisits((List<TravelVendorSettings__c>) newList);
        }
    }

    /**
     * @description: This method will create Pre Enrollment patient Visits for existing Participants whenever travel vendor is configured for their study site
     *               and Pre Enrollment Patient Visit is not created for them
     * @author: Krishna Mahto
     * @param: tvSettings
     * @return:
     **/
    private static void createPreEnrollVisits(List<TravelVendorSettings__c> tvSettings) {
        Set<Id> ssIds = new Set<Id>();
        for (TravelVendorSettings__c tvs : tvSettings) {
            ssIds.add(tvs.Study_Site__c);
        }

        //Invoke Batch to create Pre Enrollment Visits
        if (ssIds != null && !ssIds.isEmpty()) {
            Batch_CreatePreEnrollVistsForExtngPERs objBatch = new Batch_CreatePreEnrollVistsForExtngPERs(
                ssIds,
                true
            );
            Database.executeBatch(objBatch, 50);
        }
    }
}
