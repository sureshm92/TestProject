/*
Test Class for CustomLookupController
*/
@IsTest
public class Test_CustomLookupController {

    @isTest
    private static void test(){ 
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States'
        );
        insert partContact;
        
        Test.startTest();
        List<CustomLookupController.RecordsData> conList = CustomLookupController.fetchRecords('Contact','FirstName','PITD',Id.valueOf(partContact.Id));
        System.assert(!conList.IsEmpty());
        try {
        	List<CustomLookupController.RecordsData> conList1 = CustomLookupController.fetchRecords('Contact','FirstName','PITD','');
        } catch(Exception e){
            System.debug('Exception Occured ' +e.getMessage());
        }
        Test.stopTest();
    }
}