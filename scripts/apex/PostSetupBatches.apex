Batch_SetDefaultPermissionSets.run();

//Add class name to this list if you want to get it to Batch Control Panel
List<String> defaultBatches = new List<String>{
        'Batch_DeleteProcessedNotifications',
        'Batch_ProcessActionSetupObjects',
        'Batch_ProcessNotifications'
};

List<Batch_Detail__c> batchDetails = new List<Batch_Detail__c>();
for (String batchCls : defaultBatches) {
    try {
        Type batchType = Type.forName(batchCls);
        if(batchType != null){
            Batch_ScheduledAbstract instance = (Batch_ScheduledAbstract) batchType.newInstance();
            batchDetails.add(new Batch_Detail__c(
                    Interval_Mode__c = instance.getRecommendedIntervalMode(),
                    Name = batchCls,
                    Panel_Label__c = batchCls.substring(6),
                    Relaunch_Interval__c = instance.getRecommendedRelaunchInterval(),
                    Scope_Size__c = instance.getRecommendedScopeSize()
            ));
        }
    } catch (Exception e) {
        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
}

insert batchDetails;
for (Batch_Detail__c batchDetail : batchDetails) {
    System.scheduleBatch((Database.Batchable<SObject>)
            Type.forName(batchDetail.Name).newInstance(),
            batchDetail.Name,
            1,
            batchDetail.Scope_Size__c.intValue()
    );
}