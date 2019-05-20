@isTest(IsParallel=false)
public class UpdateDelegatesBatchTest {
	
     public static void methodName() {
		Contact newDelegate = new Contact(
        	LastName = 'TestDelegate'
        );
        insert newDelegate;
        
        List<HCP_Enrollment__c> enrollments = new List<HCP_Enrollment__c>();
        enrollments = [SELECT id FROM HCP_Enrollment__c];
        List <Referring_HCP_Staff__c> listOfStaff = new List<Referring_HCP_Staff__c>();
        for(Integer i = 0; i < 10; i++){
            Referring_HCP_Staff__c staffItem = new Referring_HCP_Staff__c(
            	Contact__c = newDelegate.id,
                HCP_Enrollment__c = enrollments[0].id,
                Delegate_Level__c = i == 6 ? 'Level 1' : 'Level 2'
            );
            listOfStaff.add(staffItem);
        }
         insert listOfStaff;
	}
    
    @isTest
    public static void testDelegatesUpdates(){
        String query = 'SELECT id, userCommunytyType__c, (SELECT id, Delegate_Level__c FROM Referring_HCP_Staffs__r), LastName FROM Contact';
        TestData.loadTestData();
        methodName();
        Test.startTest();
	 	UpdateDelegatesBatch bt = new UpdateDelegatesBatch(query);
		Database.executeBatch(bt, 10);  
        Test.stopTest();
        Contact delegateRecord = [SELECT id FROM Contact WHERE LastName = 'TestDelegate'];
        List<Referring_HCP_Staff__c> listOfStaff = [SELECT id, Delegate_Level__c FROM Referring_HCP_Staff__c WHERE Contact__c =:delegateRecord.id];
        System.assertEquals('Level 1', listOfStaff[3].Delegate_Level__c);
    }
}