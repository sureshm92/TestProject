/**
 * Created by alekseymoseev on 12/10/19.
 */
@IsTest
public class Test_UploadParticipantsRemote {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateParticipantsRemote1() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        List<LabelValueItem> statuses = Action_UploadParticipantsRemote.getParticipantsStatuses(tstData.ss.Id);

        List<String> csvFileLines = new List<String>();
        csvFileLines.add('First Name,Middle Name,Last Name,Nickname,Sex,Date of Birth,Email Address,Phone,Phone Type,Phone2,Phone Type2,Street Address,City,State,Postal Code,Country,Language');
        csvFileLines.add('First Name,Middle Name,Last Name,Nickname,Sex,Date of Birth,Email Address,Phone,Phone Type,Phone2,Phone Type2,Street Address,City,State,Postal Code,Country,Language');
        csvFileLines.add('Test1,Tst,Test2,tst1Test,Male,1980-11-11,tst1@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US');
        csvFileLines.add('Test2,Tst,Test2,tst2Test,Male,1981-11-11,tst2@tseststest.tst,+1123456779,Mobile,+1133457789,Home,Test str,New York,New York,12121,United States,en_US');
        csvFileLines.add('Test2,Tst,Test2,tst2Test,Male,1981-11-11,tst2@tseststest.tst,+1123456779,Mobile,+1133457789,Home,Test str,New York,New York,12121,United States,en_US');
        csvFileLines.add('Test3,Tst,Test2,tst3Test,Male,1982-11-11,tst3@tseststest.tst,,,,,Test str,New York,New York,12121,United States,en_US');
        csvFileLines.add(',Tst,,tst4Test,Male,,tst4@tseststest.tst,+1123456689,Mobile,+1133456769,Home,Test str,,,12121,,');
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(csvFileLines, 'TestFile', tstData.ss.Id, statuses[2].value, false, false);
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

    @IsTest
    public static void testUpdateParticipantsRemote2() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        List<LabelValueItem> statuses = Action_UploadParticipantsRemote.getParticipantsStatuses(tstData.ss.Id);

        List<String> csvFileLines2 = new List<String>();
        csvFileLines2.add('First Name,Middle Name,Last Name,Nickname,Sex,Date of Birth,Email Address,Phone,Phone Type,Phone2,Phone Type2,Street Address,City,State,Postal Code,Country,Language');
        csvFileLines2.add('First Name,Middle Name,Last Name,Nickname,Sex,Date of Birth,Email Address,Phone,Phone Type,Phone2,Phone Type2,Street Address,City,State,Postal Code,Country,Language');
        csvFileLines2.add('Test1,Tst,Test2,tst2Test,Male,1980-11-11,tst@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US');
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(csvFileLines2, 'TestFile', tstData.ss.Id, statuses[2].value, true, false);
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

}
