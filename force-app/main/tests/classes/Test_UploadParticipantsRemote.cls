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

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,1980-11-11,tst1@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                false,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }
    @IsTest
    public static void testUpdateParticipantsRemote6() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;
		Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
		List<LabelValueItem> statuses = result.participantStatuses;
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,1980-11-11,tst1@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,1980-11-11,tst1@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                false,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

@IsTest
    public static void testUpdateParticipantsRemote7() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;
        
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,1980-11-11,tst1@tseststest.tstk,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                false,
                false,
                false,
                false,
                false,
                null
            );
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

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines2 = new List<String>();
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines2.add(
            'Test1,Tst,Test2,tst2Test,Male,1980/11/11,tst@tseststest.tst,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines2,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                true,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }
    @IsTest
    public static void testUpdateParticipantsRemote3() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Test3,Tests,Test24,tst3Test,Male,11.12.1980,+1123456879,Mobile,+1133556789,Home,Test str,New York,New York,,United States,en_U,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                false,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

    @IsTest
    public static void testUpdateParticipantsRemote4() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines2 = new List<String>();
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines2.add(
            ',,,,,1980/17/11,tst@tseststest.tst,,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,TestD,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines2,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                true,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

    @IsTest
    public static void testUpdateParticipantsRemote5() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines2 = new List<String>();
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines2.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines2,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                true,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

    @IsTest
    public static void testUpdateParticipantsRemote8() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type'
        );
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,2018-11-11,tst1@tseststest.tstk,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,DelegD,testd@qqqjjj.qqq,+1133456789,Work'
        );
        
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                false,
                false,
                false,
                false,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

}
