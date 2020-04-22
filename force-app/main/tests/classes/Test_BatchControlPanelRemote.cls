/**
 * Created by Igor Iosifov on 2020-03-04.
 */

@IsTest
public class Test_BatchControlPanelRemote {
    @IsTest
    static void allMethodsTest() {
        BatchControlPanelRemote.PanelWrapper panelWrapper;
        Test.startTest();
        List<ApexClass> batchesSOQL = [
                SELECT Id,
                        Name,
                        Body
                FROM ApexClass
                WHERE Name LIKE 'Batch%'
        ];

        List<String> batchesId = new List<String>();
        List<Batch_Detail__c> batchDetails = new List<Batch_Detail__c>();

        //add some amount of batches to Batch Details
        for (Integer i = 0; i < batchesSOQL.size(); i++) {
            if(batchesSOQL[i].Body.contains('extends Batch_ScheduledAbstract')){
                batchesId.add(batchesSOQL[i].Id);
                if (i >=  batchesSOQL.size() / 2) {
                    batchDetails.add(new Batch_Detail__c(
                            Name = batchesSOQL[i].Name,
                            Interval_Mode__c = 'Minutes',
                            Panel_Label__c = 'User' + batchesSOQL[i].Name,
                            Relaunch_Interval__c = 1,
                            Scope_Size__c = 200));
                }
            }
        }
        insert batchDetails;

        Test.setFixedSearchResults(batchesId);
        panelWrapper = BatchControlPanelRemote.getData();

        Test.stopTest();

        System.assertEquals(batchesId.size() - batchDetails.size() - 1, panelWrapper.availableBatches.size()); // '-1' because BatchControlPanel also contains 'extends Batch_ScheduledAbstract'
        System.assertEquals(String.valueOf(batchDetails.get(0).Interval_Mode__c), panelWrapper.intervalMods.get(0));
        System.assertEquals(batchDetails.size(), BatchControlPanelRemote.getJobs().size());

        Batch_Detail__c batchDetail = [
                SELECT Id,
                        Name
                FROM Batch_Detail__c
                ORDER BY Name
                LIMIT 1
        ];
        String batchName = batchDetail.Name;
        BatchControlPanelRemote.JobWrapper jobWrapper = BatchControlPanelRemote.getState(batchName);

        System.assertNotEquals(null, jobWrapper);

        //deleteBatch
        List <Batch_Detail__c> batchDetailsBeforeDelete = [
                SELECT Id,
                        Name
                FROM Batch_Detail__c
                ORDER BY Name
        ];
        Batch_Detail__c batchDetailToDelete = batchDetailsBeforeDelete.get(1); // index 1 because index 0 using later in runBatch checking
        BatchControlPanelRemote.deleteBatch(batchDetailToDelete.Id);

        List <Batch_Detail__c> batchDetailsAfterDelete = [
                SELECT Id
                FROM Batch_Detail__c
        ];
        System.assertEquals(batchDetailsBeforeDelete.size() - 1, batchDetailsAfterDelete.size());

        //addBatch
        Batch_Detail__c batchDetailToAdd = new Batch_Detail__c(
                Name = batchesSOQL.get(0).Name,
                Interval_Mode__c = 'Minutes',
                Panel_Label__c = 'User' + batchesSOQL.get(0).Name,
                Relaunch_Interval__c = 1);
        BatchControlPanelRemote.addBatch(batchDetailToAdd);
        List <Batch_Detail__c> batchDetailsAfterAdd = [
                SELECT Id
                FROM Batch_Detail__c
        ];
        Integer batchDetailsBeforeAddSize = batchDetailsAfterDelete.size();
        System.assertEquals(batchDetailsBeforeAddSize + 1, batchDetailsAfterAdd.size());

        //runBatch
        jobWrapper.nextSchedule = Datetime.now().addMinutes(5);
        String wrapperJSON = JSON.serialize(jobWrapper);
        System.assertEquals(true, BatchControlPanelRemote.runBatch(wrapperJSON));
        jobWrapper = BatchControlPanelRemote.getState(batchName); //refresh the wrapper to update the state
        System.assertNotEquals('STOPPED', jobWrapper.state);

        //stopBatch
        try {
            BatchControlPanelRemote.stopBatch(batchName);
        } catch (Exception e) {}
    }

}
