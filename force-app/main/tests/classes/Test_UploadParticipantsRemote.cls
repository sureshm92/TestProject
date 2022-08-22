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
    public static void testUpdateParticipantsRemote9() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,INITIAL VISIT DATE,INITIAL VISIT TIME'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Phone Type,PARTICIPANT ALTERNATIVE PHONE,Alt.Phone Type,Street Address,City,State,Postal Code,Country,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,INITIAL VISIT DATE,INITIAL VISIT TIME'
    	);
        csvFileLines.add(
            'Test1,Tst,Test2,tst1Test,Male,2018-11-11,tst1@tseststest.tstk,+1123456789,Mobile,+1133456789,Home,Test str,New York,New York,12121,United States,en_US,DelegD,testd@qqqjjj.qqq,+1133456789,Work,2020-06-06,12:30'
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
    public static void testUpdateParticipantsRemote10() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        csvFileLines.add(
            'dummyname,dummymname,ldummyname,niknamedummy,Male,1980-08-01,dummy@dummy.testcom,911-2233-22,Work,22332-2323,Home,United States,New York,34348,09-09-1992,12:30,AM,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
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
    public static void testUpdateParticipantsRemote11() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;
		String minorYear = String.valueOf(System.Today().year()-3);
        
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        csvFileLines.add(
            'dummyname,dummymname,ldummyname,niknamedummy,Male,'+minorYear+'-08-01,dummy@dummy.testcom,911-2233-22,Work,22332-2323,Home,United States,New York,34348,09/09/1992,12:30,AM,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
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
    public static void testUpdateParticipantsRemote12() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        String minorYear = String.valueOf(System.Today().year()-3);
        csvFileLines.add(
            'dummyname,dummymname,ldummyname,niknamedummy,Male,'+minorYear+'-08-01,dummy@dummy.testcom,911-2233-22,Work,22332-2323,Home,United States,New York,34348,09/09/1992,2;10,AM,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
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
    public static void testUpdateParticipantsRemote13() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;
	    List<Contact> picon = [SELECT Id, FirstName, Birthdate, LastName , email, phone, MailingPostalCode from Contact where Id In (SELECT ContactId FROM User where Id =:tstData.piUser.Id)];
		system.debug('%$%$'+picon);	
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        csvFileLines.add(
            picon[0].FirstName==null?'':picon[0].FirstName+',,'+picon[0].LastName==null?'':picon[0].LastName+',,Male,'+picon[0].Birthdate==null?'':picon[0].Birthdate+','+picon[0].email==null?'':picon[0].email+','+picon[0].phone==null?'':picon[0].phone+',Work,22332-2323,Home,United States,New York,' + picon[0].MailingPostalCode==null?'':picon[0].MailingPostalCode+',09/09/1992,13:10,,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
        );
        
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }      

    @IsTest
    public static void  testUpdateParticipantsRemote14() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        List<LabelValueItem> statuses = result.participantStatuses;

        List<String> csvFileLines = new List<String>();
        
        Test.startTest();

        System.runAs(tstData.piUser) {

        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
            List<Participant__c> part = [SELECT Id, First_Name__c, Date_Of_Birth__c, Last_Name__c , email__c, phone__c,phone_type__c, Mailing_Zip_Postal_Code__c from Participant__c WHERE email__c ='part6@email.com'];
            csvFileLines.add(
                part[0].First_Name__c==null?'':part[0].First_Name__c+',,'+part[0].Last_Name__c==null?'':part[0].Last_Name__c+',,Male,'+part[0].Date_Of_Birth__c==null?'':part[0].Date_Of_Birth__c+','+part[0].email__c==null?'':part[0].email__c+','+part[0].phone__c==null?'':part[0].phone__c+','+part[0].phone_type__c==null?'':part[0].phone_type__c+',22332-2323,Home,United States,New York,' + part[0].Mailing_Zip_Postal_Code__c==null?'':part[0].Mailing_Zip_Postal_Code__c+',09/09/1992,01:10,,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
            );
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile',
                tstData.ss.Id,
                statuses[2].value,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }      
  @IsTest
    public static void testUpdateParticipantsRemote15() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        csvFileLines.add(
            'ParticipantTD6,,ParticipantTD6,,Male,1988-08-01,part6@email.com,911-2233-22,Work,55313536,Home,United States,Alabama,334,09/09/1992,2;10,AM,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
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
                true,
                true,
                true,
                true,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }      

  @IsTest
    public static void testUpdateParticipantsRemote16() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
    	);
        csvFileLines.add(
            'PITD,,PITD,,Male,1988-08-01,pi@emil.com,911-2233-22,Work,55313536,Home,United States,Alabama,334,09/09/1992,2;10,AM,en_US,Deldummyfname,deldummylname,deldumm@mail.fake,4343443,Home,1988,Yes'
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
                true,
                true,
                true,
                true,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }    
    
}