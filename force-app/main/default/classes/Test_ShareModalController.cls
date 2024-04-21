@isTest
public class Test_ShareModalController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void test1(){
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            try{
                TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
                Contact ct = (Contact) TestDataFactory.getSObject( 
                    Contact.getSObjectType(),
                    new Map<String, Object>{
                        'email' => 'test@testgmail.com'
                            }
                );
                insert new List<SObject>{ct};
                    Resource__c vedioPtRes = new Resource__c(
                        Content_Type__c = 'Video',
                        Description__c = 'testBehavior',
                        Title__c = 'TestRes',
                        Content_Class__c = 'Study-Specific',
                        Resource_Type__c = 'Study Document'
                    );
                insert vedioPtRes;
                ShareModalController.sendEmail(testData.pe.Id, null, 'test@testgmail.com', 'emailType');
                ShareModalController.sendEmail(testData.pe.Id, null, 'test@t1estgmail.com', 'emailType');
                ShareModalController.sendEmail(testData.hcpEnrollment.Id, null, 'test@testgmail.com', 'emailType');
                ShareModalController.sendEmail(testData.hcpEnrollment.Id, null, 'test@t1estgmail.com', 'emailType');
                ShareModalController.sendEmail(testData.ctp.Id, null, 'test@testgmail.com', 'emailType');
                ShareModalController.sendEmail(testData.ctp.Id, null, 'test@t1estgmail.com', 'emailType');
                ShareModalController.sendEmail(vedioPtRes.Id, null, 'test@testgmail.com', 'emailType');
                ShareModalController.sendEmail(vedioPtRes.Id, null, 'test@t1estgmail.com', 'emailType');
                ShareModalController.sendEmail(vedioPtRes.Id, null, '', 'emailType'); 
            }catch(Exception e){
                
            }
        }
    }
}