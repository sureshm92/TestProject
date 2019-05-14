/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
public class Test_MyTemRemote {
    
    @IsTest
    static void testCreatePatientDelegate(){
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            Contact delegateContact = new Contact(
                    FirstName = 'Del',
                    LastName = 'Del',
                    Email = 'del@del.com'
            );
            MyTeamRemote.savePatientDelegate(JSON.serialize(delegateContact));
        }
        Test.stopTest();
    
    }
    
}