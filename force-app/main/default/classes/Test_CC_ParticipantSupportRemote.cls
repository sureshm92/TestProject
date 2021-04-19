@IsTest
public class Test_CC_ParticipantSupportRemote {
    
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void testfetch() {
        TestData testData = new TestData();
        String str = CC_ParticipantSupportRemote.fetchParticipantEnrollment('55313538');
        System.assert(!String.isBlank(str));
        String str1 = CC_ParticipantSupportRemote.fetchParticipantEnrollment('55313538000');
        System.assert(!String.isBlank(str1));
    }
    
    
    @IsTest
    static void testfetchParticipantEnrollment() {
        contact cont = new contact();
        cont.Email = 'test@iqvia.com';
        cont.LastName = 'NewContact';
        insert cont;

        Test.startTest();
        try {
            CC_ParticipantSupportRemote.getInvitedDetails(cont.id);
        } catch (exception e) {
        }

        Test.stopTest();
    }
}