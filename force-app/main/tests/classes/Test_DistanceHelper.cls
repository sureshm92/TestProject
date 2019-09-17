/**
 * Created by Slav on 21.08.2019.
 */

@IsTest(SeeAllData=false)
public class Test_DistanceHelper {
    
    @IsTest
    public static void runTest1() {
        TestData.loadTestData();
        Test.startTest();
        
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            DistanceHelper.getUnitsOfMeasurement();
            DistanceHelper.alreadyInit = false;
            DistanceHelper.getUnitsOfMeasurementLabel();
            DistanceHelper.MILE_LOCALES.clear();
            DistanceHelper.getUnitsOfMeasurementLabel();
            DistanceHelper.alreadyInit = false;
            DistanceHelper.getUserLocation();
            DistanceHelper.roundDouble(Double.valueOf('1.234'));
            
            Account account = new Account();
            account.BillingLatitude  = 111.11;
            account.BillingLongitude = 222.22;
            
            DistanceHelper.calculateDistanceTo(account);
        }
        
        Test.stopTest();
    }

}
