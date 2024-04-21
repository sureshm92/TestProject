@IsTest
public class Test_MyReferringClinicsController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @isTest
    public static void testHCPEnrollmentWrapper() {
        TestData testData = new TestData();
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        //tcList.add(portalTC);

        Test.startTest();
        System.runAs(testdata.piUser) {
            List<String> fields = new List<String>();
            fields.addAll(ReferringClinicsFilter.REFERRING_CLINICS_COMMON_FIELDS);
            fields.add('Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c');
            fields.add('Clinical_Trial_Profile__c');
            List<HCP_Enrollment__c> hcpEnrollments = DataBaseService.query(
                fields,
                HCP_Enrollment__c.getSObjectType(),
                ' Id =\'' + testData.hcpEnrollment.Id + '\''
            );
            HCP_Enrollment__c hcpEnrollment = hcpEnrollments[0];

            Participant__c participant = new Participant__c();
            MyReferringClinicsController.ClinicWrapper clinicWrapper = new MyReferringClinicsController.ClinicWrapper(
                new List<HCP_Enrollment__c>{ hcpEnrollment },
                new Map<Id, Participant__c>{
                    hcpEnrollment.Study_Site__r.Principal_Investigator__c => testdata.participant
                },
                testdata.participant
            );
            MyReferringClinicsController.HCPEnrollmentWrapper wrapper = clinicWrapper.enrollments[0];
            MyReferringClinicsController.ClinicWrapper clinicWrapper2 = new MyReferringClinicsController.ClinicWrapper(
                new List<HCP_Enrollment__c>{ hcpEnrollment }
            );

            Test.stopTest();
        }
    }
    @IsTest
    static void baseHCPTest5() {
        TestData testData = new TestData();
        Test.startTest();
        User hcpu = [SELECT ContactId FROM User WHERE Id = :testData.hcpUser.Id];
        Contact hcpc = new Contact();
        hcpc.Id = hcpu.ContactId;
        hcpc.UserCommunityIsDelegate__c = true;
        update hcpc;
        System.runAs(testData.hcpUser) {
            String initDataString = MyReferringClinicsController.getInitData(
                testData.ctp.Id,
                testData.ss.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            MyReferringClinicsController.InitData initData = (MyReferringClinicsController.InitData) JSON.deserializeStrict(
                initDataString,
                MyReferringClinicsController.InitData.class
            );
            MyReferringClinicsController.searchReferringClinics(
                JSON.serialize(initData.referringClinicsFilter.filterValues),
                JSON.serialize(initData.referringClinicsFilter.sortData),
                JSON.serialize(initData.paginationData),
                false
            );
            MyReferringClinicsController.searchReferringClinics(
                JSON.serialize(initData.referringClinicsFilter.filterValues),
                JSON.serialize(initData.referringClinicsFilter.sortData),
                JSON.serialize(initData.paginationData),
                true
            );
        }
        Test.stopTest();
    }
}
