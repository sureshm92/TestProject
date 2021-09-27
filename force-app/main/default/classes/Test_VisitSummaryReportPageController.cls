@IsTest
private without sharing class Test_VisitSummaryReportPageController {
    
    
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    } 
    
    
    @IsTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        System.runAs(tstData.participantUser) {
            PageReference pageRef =  Page.VisitSummaryReportPage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('peId', tstData.pe.Id);
            pageRef.getParameters().put('isRTL', 'false'); 
            VisitSummaryReportPageController controller=new VisitSummaryReportPageController();        
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void runTes() {
        
        
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;
        
        Visit_Result_Type_Sharing__c vrts = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Calcium',
            Sharing_Countries__c = 'US'
        );
        insert vrts;
        
        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;
        
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
            )
        );
        insert patientVisits;
        
        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'Calcium'
            )
        );
        insert visitResults;
        
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update testData.pe;
        
        Test.startTest();
        
        
        System.runAs(testData.participantUser) {
            
            VisitSummaryReportPageController.ReportDataWrapper obj= new VisitSummaryReportPageController.ReportDataWrapper();
            obj.notAvailableMessage='notAvailableMessage';
            obj.studyCodeName='studyCodeName';
            obj.communityTemplate='communityTemplate';
            obj.studyTitle='studyTitle';
            obj.profilePicture='profilePicture';
            obj.participantFullName='participantFullName';
            obj.enrollmentDate=null;
            obj.participantLastName='participantLastName';
            obj.studySiteName='studySiteName';
            obj.participantStatus='participantStatus';
            VisitSummaryReportPageController.ReportDataTableWrapper obj1= new VisitSummaryReportPageController.ReportDataTableWrapper();
            obj1.labsDescription=null;
            obj1.tableApiName='tableApiName';
            obj1.tableName='tableName';
            obj1.tHead=null;
            obj1.visitResultsWrapper=null;
            
            VisitSummaryReportPageController.LabsNameDescriptionWrapper obj2= new VisitSummaryReportPageController.LabsNameDescriptionWrapper();
            obj2.descriptionLab = 'descriptionLab';
            obj2.nameLabs='nameLabs';

            VisitSummaryReportPageController.VisitHeaderWrapper obj3= new VisitSummaryReportPageController.VisitHeaderWrapper();
            obj3.isShowRange=null;
            obj3.maxValue=null;
            obj3.measurement=null;
            obj3.minValue=null;
            obj3.value=null;
            PageReference pageRef =  Page.VisitSummaryReportPage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('peId', testData.pe.Id);
            pageRef.getParameters().put('isRTL', 'true'); 
            VisitSummaryReportPageController controller=new VisitSummaryReportPageController();     
            VisitSummaryReportPageController.addBreakLines('Dummy TextDummy TextDummy TextDummy TextDummy ',10);
            VisitSummaryReportPageController.addBreakLines('Dummy Te',10);

        }
        Test.stopTest();
    }
    
   
    
    
    
    
}