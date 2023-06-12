@IsTest
public class Test_PatientDelegateEnrollmentService {
     // Define test objects: --------------------------------------------------------------------------------------------

     private static Account accountPartic;

     private static Contact firstParticipantContact;
     private static Contact secondParticipantContact;
     private static Contact firstDelegateContact;
     private static Contact secondDelegateContact;
 
     private static Participant__c firstParticipant;
     private static Participant__c secondParticipant;
 
     private static Patient_Delegate__c patientDelegate;
 
     // Define mocks: ---------------------------------------------------------------------------------------------------
 
     public class DatabaseServiceMock implements StubProvider {
         public Object handleMethodCall(
             Object stubbedObject,
             String stubbedMethodName,
             Type returnType,
             List<Type> listOfParamTypes,
             List<String> listOfParamNames,
             List<Object> listOfArgs
         ) {
             if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                 SObjectType sObjectType = (SObjectType) listOfArgs[1];
                 if (sObjectType == Patient_Delegate__c.getSObjectType()) {
                     return new List<Patient_Delegate__c>{ patientDelegate };
                 } else if (sObjectType == Participant__c.getSObjectType()) {
                     return new List<Participant__c>{ firstParticipant };
                 } else if (sObjectType == Account.getSObjectType()) {
                     return new List<Account>{ accountPartic };
                 }
             }
             if (stubbedMethodName == 'queryImpl' && listOfArgs.size() == 1) {
                 String queryString = (String) listOfArgs[0];
                 if (queryString.contains('FROM User')) {
                     return new List<User>{
                         new User(Id = TestDataFactory.getFakeId(User.getSObjectType()))
                     };
                 }
             }
             return null;
         }
     }
 
     public class CommunityServiceMock implements StubProvider {
         public Object handleMethodCall(
             Object stubbedObject,
             String stubbedMethodName,
             Type returnType,
             List<Type> listOfParamTypes,
             List<String> listOfParamNames,
             List<Object> listOfArgs
         ) {
             if (stubbedMethodName == 'getCurrentContactId') {
                 return TestDataFactory.getFakeId(Contact.getSObjectType());
             }
             if (stubbedMethodName == 'getContactById') {
                 return firstParticipantContact;
             }
             if (stubbedMethodName == 'getUserContactImpl') {
                 return firstParticipantContact;
             }
             return null;
         }
     }
 
     class PatientDelegateServiceMock implements StubProvider {
         public Object handleMethodCall(
             Object stubbedObject,
             String stubbedMethodName,
             Type returnType,
             List<Type> listOfParamTypes,
             List<String> listOfParamNames,
             List<Object> listOfArgs
         ) {
             switch on stubbedMethodName {
                 when 'getParticipant' {
                     return firstParticipant;
                 }
                 when 'getDelegateContact' {
                     return firstDelegateContact;
                 }
                 when 'getDelegatedContactIds' {
                     return new List<Id>{ firstDelegateContact.Id };
                 }
                 when 'resetDelegate' {
                     Id contactId = firstDelegateContact.Id;
                     Contact delegateContact = new Contact(
                         Id = contactId,
                         userCommunityMode__c = null
                     );
                     update delegateContact;
 
                     List<Patient_Delegate__c> patientDelegate = [
                         SELECT Id
                         FROM Patient_Delegate__c
                         WHERE Contact__c = :contactId
                     ];
                     delete patientDelegate;
                 }
             }
             return null;
         }
     }
     // Tests: ----------------------------------------------------------------------------------------------------------
 
     @TestSetup
     static void setup() {
         Test.startTest();
         TestData.loadTestData();
         Test.stopTest();
     }
     @IsTest
    static void patientDelegateServiceTest() {
        //refreshTestData();
        TestData testData = new TestData();
        List<Contact> delegateContacts;
        Participant__c participant;
        Boolean isDelegate;
        Boolean delegateAlreadyExisting;
        Id userId;
        List<Id> delUserIds;
        List<Id> delConIds;
        List<Id> delConIds2;
        List<Patient_Delegate__c> patientDelegates;
        Contact delCon;
        List<Contact> delCons;
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
        List<Contact> conDel = [SELECT Id, userCommunityDelegateId__c FROM Contact];
        Test.startTest();
        System.runAs(testData.participantUser) {
            delegateContacts = PatientDelegateService.getInstance().getDelegates();
            participant = PatientDelegateService.getInstance().getParticipant();
            patientDelegates = PatientDelegateService.getInstance().getPDelegates();
            patientDelegates[0].Attestation_TimeStamp__c = String.ValueOf(system.now());
            //update patientDelegates; 
            //patientDelegates = PatientDelegateService.getInstance().getPDelegates();
            List<Patient_Delegate_Enrollment__c> pdeList = New List<Patient_Delegate_Enrollment__c>();
            Patient_Delegate_Enrollment__c pde1 = new Patient_Delegate_Enrollment__c(
                Patient_Delegate__c = patientDelegates[0].Id,
                Status__c='Active',
                Participant_Enrollment__c =testData.pe.id
            );
            pdeList.Add(pde1);
            
            
            Insert pdeList;
            PatientDelegateEnrollmentService.getPatientDelegateEnrollments(patientDelegates[0].Participant__r.Contact__c, patientDelegates[0].Contact__c);
            PatientDelegateEnrollmentService.getPEList(patientDelegates[0].Participant__r.Contact__c, patientDelegates[0].Contact__c);
            PatientDelegateEnrollmentService.getInstance();
            PatientDelegateEnrollmentService.getParAndStdAssociatedList();
            PatientDelegateEnrollmentService.getPDForMinorOrAdultWithoutEmailPar(patientDelegates[0].Contact__c);
            PatientDelegateEnrollmentService.getPDEnrollmentforDelContact(patientDelegates[0].Contact__c,patientDelegates[0].Participant__r.Contact__c);
            PatientDelegateEnrollmentService.getAllPDEnrollmentforDelContact(patientDelegates[0].Contact__c);
            Patient_Delegate__c pdWrapper = New Patient_Delegate__c(
                Id = patientDelegates[0].Id,
                Attested_by__c = patientDelegates[0].Participant__c,
                Attestation_TimeStamp__c = String.valueOf(system.now())
  
            ); 
            MyTeamRemote.SelectedStudiesData studyWrapper = new MyTeamRemote.SelectedStudiesData();
            studyWrapper.label = 'Test';
            studyWrapper.value = testData.pe.id;
            studyWrapper.assigned = false;
            studyWrapper.active = true;
            studyWrapper.pdEnrollmentId = pdeList[0].id;
            try{
                 PatientDelegateEnrollmentService.doAddAssignment(JSON.serialize(pdWrapper),JSON.serialize(studyWrapper));
            }catch(Exception e){
                system.debug('exception');
            }
           //PatientDelegateEnrollmentService.createPDEObject(patientDelegates[0],testData.pe.id);
            List<String> idList = new List<String>();
            for (Patient_Delegate_Enrollment__c pde : pdeList) {
                idList.add(String.valueOf(pde.Id));
            }
           PatientDelegateEnrollmentService.getPEIdSet(patientDelegates[0].Participant__r.Contact__c, patientDelegates[0].Contact__c);
           PatientDelegateEnrollmentService.reActivateAssignment(idList);
           PatientDelegateEnrollmentService.reActivateAssignmentForDeletedOrWithDrawnDel(patientDelegates[0],new List<Id>{testData.pe.id});
           PatientDelegateEnrollmentService.removeAssignment(pdeList[0].Id);
           PatientDelegateEnrollmentService.WithdrawAssignment(pdeList[0].Id);
           PatientDelegateEnrollmentService.deleteDelegates(patientDelegates[0].Id);

        }
       Test.stopTest();
            
        }
    @IsTest
     static void patientDelegateServiceTest1() {
         //refreshTestData();
         TestData testData = new TestData();
         List<Contact> delegateContacts;
         Participant__c participant;
         Boolean isDelegate;
         Boolean delegateAlreadyExisting;
         Id userId;
         List<Id> delUserIds;
         List<Id> delConIds;
         List<Id> delConIds2;
         List<Patient_Delegate__c> patientDelegates;
         Contact delCon;
         List<Contact> delCons;
         User delegateUser = testData.createPatientDelegate();
         insert delegateUser;
         List<Contact> conDel = [SELECT Id, userCommunityDelegateId__c FROM Contact];
         Test.startTest();
         System.runAs(testData.participantUser) {
            delegateContacts = PatientDelegateService.getInstance().getDelegates();
            participant = PatientDelegateService.getInstance().getParticipant();
            patientDelegates = PatientDelegateService.getInstance().getPDelegates();
            patientDelegates = PatientDelegateService.getInstance().getPDelegates();
            List<Patient_Delegate_Enrollment__c> pdeList = New List<Patient_Delegate_Enrollment__c>();
   
            Patient_Delegate_Enrollment__c pde2 = new Patient_Delegate_Enrollment__c(
                    Patient_Delegate__c = patientDelegates[0].Id,
                    Status__c='Deleted',
                    Participant_Enrollment__c =testData.pe.id
            );
            Patient_Delegate_Enrollment__c pde3 = new Patient_Delegate_Enrollment__c(
                    Patient_Delegate__c = patientDelegates[0].Id,
                    Status__c='Disconnected',
                    Participant_Enrollment__c =testData.pe.id
            );
            Patient_Delegate_Enrollment__c pde4 = new Patient_Delegate_Enrollment__c(
                    Patient_Delegate__c = patientDelegates[0].Id,
                    Status__c='Withdrawn',
                    Participant_Enrollment__c =testData.pe.id
            );
             Patient_Delegate_Enrollment__c pde5 = new Patient_Delegate_Enrollment__c(
                    Patient_Delegate__c = patientDelegates[0].Id,
                    Status__c='On Hold',
                    Participant_Enrollment__c =testData.pe.id
            );
            //pdeList.Add(pde1);
            pdeList.Add(pde2);
            pdeList.Add(pde3);
            pdeList.Add(pde4);
            pdeList.Add(pde5);
            
            Insert pdeList;
            PatientDelegateEnrollmentService.getPatientDelegateEnrollments(patientDelegates[0].Participant__r.Contact__c, patientDelegates[0].Contact__c);
                 PatientDelegateEnrollmentService.getPEList(patientDelegates[0].Participant__r.Contact__c, patientDelegates[0].Contact__c);
                 PatientDelegateEnrollmentService.getInstance();
             }
            Test.stopTest();
         
     }
 
}