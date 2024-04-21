@isTest
public class Test_DateTimeConverterUtil {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void test1(){
        TestData testData = new TestData();
        DateTimeConverterUtil.getUsersTimezoneMap(new Set<Id>{testData.piContact.Id});
        DateTimeConverterUtil.getContactsTimezoneMap(new Set<Id>{testData.piContact.Id});
        DateTimeConverterUtil.getUserTimeZone(testData.piContact.Id);
        DateTimeConverterUtil.convertUserDatetimeToGMT(DateTime.now(), UserInfo.getTimeZone());
        DateTimeConverterUtil.addDaysInUserTimeZone(DateTime.now(), UserInfo.getTimeZone(), 5);
        DateTimeConverterUtil.addDays(DateTime.now(), 4);
        DateTimeConverterUtil.addDaysInUserTimeZone(DateTime.now(), testData.piContact.Id, 4);
        DateTimeConverterUtil.isSameMoment(DateTime.now(), UserInfo.getTimeZone(),DateTime.now(), UserInfo.getTimeZone());
        Contact ct = (Contact) TestDataFactory.getSObject(
            Contact.getSObjectType()
        );
        	insert new List<SObject>{ct};
            try{
        	DateTimeConverterUtil.getUserTimeZone(ct.Id);
            }catch(Exception e){
            }
    }
}