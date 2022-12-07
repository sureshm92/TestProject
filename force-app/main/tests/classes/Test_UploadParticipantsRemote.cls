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
    public static void testUpdateParticipantsRemote_dataSuccess() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;
        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        update new Clinical_Trial_Profile__c(
            ID = tstData.ss.Clinical_Trial_Profile__c,
            IQVIA_Outreach__c = true
        );
        List<LabelValueItem> statuses = result.participantStatuses;
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            ' testp1,m1,L1,,Male,12,12,2018,03,test@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,01;10,aM,en_us,testD1,testLD1,TESTDEL@gmail.co,9879879871,Home,1991,Yes,'
        );
        csvFileLines.add(
            ' testp1,m1,L1,,Male,12,12,2018,03,test@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,02;10,aM,en_us,testD1,testLD1,TESTDEL@gmail.co,9879879871,Home,1991,Yes,'
        );
        csvFileLines.add(
            ' testp11,m1,L11,,Male,12,12,2018,03,test1@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,09/09/1992,03:10,AM,en_us,testD1,testL1,TESTDEL@gmail.co,9879879871,Home,1991,No,'
        );
        csvFileLines.add(
            ' testp21,m2,L21,,Male,12,02,1990,32,test2@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,09/09/1992,04:10,PM,en_us,,DL1,TESTDEL@gmail.co,9879879871,Home,,Yes,'
        );
        csvFileLines.add(
            ' testp31,m1,L31,,Male,12,,2018,03,test3@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,09/09/1992,05:10,,en_us,testD1,DL1,TESTDEL¥@gmail.co,9879879871,Home,1991,Yes,'
        );
        csvFileLines.add(
            ' testp41,m1,L41,,Male,12,12,2018,03,test14@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,09/09/1992,06:10,amp,en_us,,DL1,TESTDEL@gmail.co,9879879871,Home,19921,Yes,'
        );

        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile_errors.csv',
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
    public static void testUpdateParticipantsBatch_Duplicate() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;

        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        Contact objCon = new Contact(
            FirstName = 'testp1',
            LastName = 'L1',
            Birthdate = Date.newInstance(2018, 12, 12),
            Email = 'test@gmmail.comm',
            Phone = '9879991919',
            Phone_Type__c = 'Home',
            MailingCountry = 'United States'
        );
        insert objCon;

        List<LabelValueItem> statuses = result.participantStatuses;
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            ' testp1,m1,L1,,Male,12,12,2018,03,test@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,01:10,aM,en_us,testD1,testLD1,TESTDEL@gmail.co,9879879871,Home,1991,Yes,'
        );

        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile.csv',
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
    public static void testUpdateParticipantBatch_DelegateError() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;
        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );
        update new Clinical_Trial_Profile__c(
            ID = tstData.ss.Clinical_Trial_Profile__c,
            IQVIA_Outreach__c = true
        );
        List<LabelValueItem> statuses = result.participantStatuses;
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            ' testp1,m1,L1,,Male,12,12,2018,03,test@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,07;10,aM,en_us,testD1,,TESTDEL@gmail.co,9879879871,Home,1991,Yes,'
        );
        csvFileLines.add(
            ' testp2,m1,L2,,Male,12,12,2018,03,test2@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,08;10,aM,en_us,testD2,testDlast2,TESTDEL@gmail.@co,9879879871,Home,1991,No,'
        );
        csvFileLines.add(
            ' testp3,m1,L3,,Male,12,12,2018,03,test3@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,09;10,aM,en_us,testD3,testDlast3,TESTDEL@gmail.co,9879879871,Home,YYYY,Yes,'
        );
        csvFileLines.add(
            ' testp4,m1,L4,,Male,12,12,2018,03,test4@gmmail.comm,9879991919,Home,9812981298,Work,United States,New York,65001,09/09/1992,10;10,aM,en_us,testD4,testDlast4,TESTDEL@gmail.co,2018,Home,2018,Yes,'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile.xlsx',
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
    public static void testUpdateParticipantsBatch_Errors() {
        TestData tstData = new TestData();
        List<String> headerColumns = Action_UploadParticipantsRemote.HEADER_COLUMNS;
        List<String> mandatoryHeaders = Action_UploadParticipantsRemote.MANDATORY_HEADER_COLUMNS;
        Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans result = new Action_UploadParticipantsRemote.ParticipantStatusesVisitPlans();
        result = Action_UploadParticipantsRemote.getParticipantsStatusesAndVisitPlans(
            tstData.ss.Id
        );

        // update new user(ID=tstData.piUser.ContactId,Language__c = NULL);

        List<LabelValueItem> statuses = result.participantStatuses;
        List<String> csvFileLines = new List<String>();
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        //firstName Missing
        csvFileLines.add(
            ',m1,L1,,Male,12,12,2018,08,test¥@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,,,,,testD1,DL1,TESTDEL¥@gmail.co,9879879871,Home,1991,Yes,'
        );
        //Last Name and country Missing and wrong age
        csvFileLines.add(
            ' testp11,m1,,,Male,12,12,yyyy,6y,test+1-011@gmmail.comm,9879991919,Home,9812981298,Work,,,65001,09/09/1992,01:10,am,,testD1,DL1,TESTDEL@gmail.co@,9879879871,Home,1991,Yes,'
        );
        //Postal Code Missing and worng Email Id
        csvFileLines.add(
            ' testp11,m1,L11,,Male,,12,2018,03,test1gmmail.comm@,9879991919,Home,9812981298,Work,India,,,09-09-1992,12:10,pm,en_us,testD1,DL1,TESTDEL@gmail.co1@,9879879871,Home,1991,Yes,'
        );
        //Missing Year and missing age,sex wrong,phonetype wrong
        csvFileLines.add(
            ' testp11,m1,L11,,Male1,12,19,2018,,test1[][]@gmmail.comm,,Home1,,Work,United States,,65001,09/09/1992,11;10,Am,en_us,testD1,DL1,TESTDELgmail.co,9879879871,Home,1991,No,'
        );
        csvFileLines.add(
            ' testp11,m1,L11,,Male,12,,2018yy,,test1@gmmail.comm,9879991919,Home,9812981298,Work,United States,,65001,09/09/1992,01:10,Pm,en_us,testD1,DL1,TESTDEL[]gmail.co,9879879871,Home,1991,No,'
        );
        Test.startTest();
        System.runAs(tstData.piUser) {
            Action_UploadParticipantsRemote.uploadParticipants(
                csvFileLines,
                'TestFile.xls',
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
    public static void testUpdatefileEmpty() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
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
    public static void testUpdatefileHeaderFailed() {
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
            'Participant First Name,Participant Middle Name,Participant Nickname, Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Nickname, Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
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
    public static void testUpdateParticipantsBatch_Duplicate2() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        List<Participant__c> part = [
            SELECT
                Id,
                First_Name__c,
                Date_Of_Birth__c,
                Last_Name__c,
                email__c,
                phone__c,
                phone_type__c,
                Mailing_Zip_Postal_Code__c
            FROM Participant__c
            WHERE email__c = 'part6@email.com'
        ];
        List<Participant_Enrollment__c> lstPER = [
            SELECT ID, Study_Site__c, Study_Site__r.Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :part[0].id
            LIMIT 1
        ];
        if (!lstPER.isEmpty()) {
            update new Clinical_Trial_Profile__c(
                ID = lstPER[0].Study_Site__r.Clinical_Trial_Profile__c,
                IQVIA_Outreach__c = true
            );
        }
        part[0].Date_Of_Birth__c = '1991-12-12';
        part[0].Mailing_Zip_Postal_Code__c = '65001';
        update part[0];
        system.debug('????part>>' + part[0]);
        String strCsvLine = part[0].First_Name__c + ',' + ',' + part[0].Last_Name__c + ',';
        strCsvLine =
            strCsvLine +
            ',' +
            'Male' +
            ',' +
            '12' +
            ',' +
            '12' +
            ',' +
            '1991' +
            ',' +
            '30' +
            ',' +
            part[0].email__c;
        strCsvLine = strCsvLine + ',' + part[0].phone__c + ',' + 'Home' + ',';
        strCsvLine =
            strCsvLine +
            '98989899' +
            ',' +
            'Work' +
            ',' +
            'United States' +
            ',' +
            'New York' +
            ',' +
            part[0].Mailing_Zip_Postal_Code__c +
            ',' +
            '09/09/1992' +
            ',' +
            '1;10' +
            ',' +
            'AM' +
            ',';
        strCsvLine =
            strCsvLine +
            'en_us' +
            ',' +
            'PD1' +
            ',' +
            'PDL' +
            ',' +
            'test@gmail.com' +
            ',' +
            '988989898' +
            ',' +
            'Home' +
            ',' +
            '1990' +
            ',' +
            'Yes';
        system.debug('>>>>strCsvLine>>>' + strCsvLine);
        csvFileLines.add(strCsvLine);
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
                true,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }

    @IsTest
    public static void testUpdateParticipantsBatch_Duplicate3() {
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
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        csvFileLines.add(
            'Participant First Name,Participant Middle Name,Participant Last Name,Participant Nickname,Participant Sex,Participant Date of Birth,Participant Month of Birth,Participant Year of Birth,Participant Age,Participant Email Address,Participant Phone,Participant Phone Type,Participant Alternative Phone,Participant Alt. Phone Type,Country,State ,Postal Code,Initial Visit Date,Initial Visit Time,Initial Visit Time AM/PM,Language,Primary Delegate First Name,Primary Delegate Last Name,Primary Delegate Email,Primary Delegate Phone Number,Primary Delegate Phone Type,Primary Delegate YOB,Confirm Primary Delegate is an adult'
        );
        List<Participant__c> part = [
            SELECT
                Id,
                First_Name__c,
                Date_Of_Birth__c,
                Last_Name__c,
                email__c,
                phone__c,
                phone_type__c,
                Mailing_Zip_Postal_Code__c
            FROM Participant__c
            WHERE email__c = 'part6@email.com'
        ];
        List<Participant_Enrollment__c> lstPER = [
            SELECT ID, Study_Site__c, Study_Site__r.Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :part[0].id
            LIMIT 1
        ];
        if (!lstPER.isEmpty()) {
            update new Clinical_Trial_Profile__c(
                ID = lstPER[0].Study_Site__r.Clinical_Trial_Profile__c,
                IQVIA_Outreach__c = true
            );
        }
        Contact objCon = [
            SELECT Id, firstName, LastName, Email
            FROM Contact
            WHERE Email = 'pi@emil.com'
        ];

        part[0].Date_Of_Birth__c = '1991-12-12';
        part[0].Mailing_Zip_Postal_Code__c = '65001';
        update part[0];
        system.debug('????part>>' + part[0]);
        String strCsvLine = objCon.firstName + ',' + ',' + objCon.LastName + ',';
        strCsvLine =
            strCsvLine +
            ',' +
            'Male' +
            ',' +
            '12' +
            ',' +
            '12' +
            ',' +
            '1991' +
            ',' +
            '30' +
            ',' +
            objCon.Email;
        strCsvLine = strCsvLine + ',' + part[0].phone__c + ',' + 'Home' + ',';
        strCsvLine =
            strCsvLine +
            '98989899' +
            ',' +
            'Work' +
            ',' +
            'United States' +
            ',' +
            'New York' +
            ',' +
            part[0].Mailing_Zip_Postal_Code__c +
            ',' +
            '09/09/1992' +
            ',' +
            '1:10' +
            ',' +
            'AM' +
            ',';
        strCsvLine =
            strCsvLine +
            'en_us' +
            ',' +
            'PD1' +
            ',' +
            'PDL' +
            ',' +
            'test@gmail.com' +
            ',' +
            '988989898' +
            ',' +
            'Home' +
            ',' +
            '1990' +
            ',' +
            'Yes';
        system.debug('>>>>strCsvLine>>>' + strCsvLine);
        csvFileLines.add(strCsvLine);
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
                true,
                null
            );
        }
        Test.stopTest();
        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assert(!participants.isEmpty());
    }
}
