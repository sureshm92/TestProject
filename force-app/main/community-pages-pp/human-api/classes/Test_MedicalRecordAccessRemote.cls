@IsTest
public class Test_MedicalRecordAccessRemote {
    
    
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testMethod1() {
        
        Test.startTest(); 
        TestData td = new TestData();
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
            MedicalRecordAccessRemote.getSessionToken('part1@email.com','refid','humanId','uniqueHumanId');
            
        }
        
        
        
    }
    
    @IsTest
    static void testMethod2() {
        
        Test.startTest(); 
        
        TestData td = new TestData();
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
           MedicalRecordAccessRemote.getAccessToken('refid','part1@email.com','uniqueHumanId');
            
        }
        
        
        
    }
    
    @IsTest
    static void testMethod3() {
        
        Test.startTest(); 
        
        TestData td = new TestData();
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
            MedicalRecordAccessRemote.getHumanSourcesList('refid','part1@email.com','uniqueHumanId');
            MedicalRecordAccessRemote.getHumanAPIPastPEList(td.participant.Contact__c);
        }
    }
    
    
    @IsTest
    static void testMethod4() {
        
        Test.startTest(); 
        
        TestData td = new TestData();
        
        
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
            
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.class
            );
            List<Clinical_Trial_Profile__c> ctpUpdates = new List<Clinical_Trial_Profile__c>();
            List<Participant_Enrollment__c> peList= [Select Id,Participant__r.Contact__c,Human_Id__c,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c from Participant_Enrollment__c where Participant__r.Contact__c =: td.participant.Contact__c];
            for(Participant_Enrollment__c peobj : peList)
            {
                peobj.Human_Id__c  ='humanid';
                peobj.Participant__r.Contact__c =td.participant.Contact__c;
            }
            Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
            ctp.Medical_Vendor_is_Available__c = true;
            ctp.Id= td.ctp.id;
            ctpUpdates.add(ctp);
            
            if(!ctpUpdates.isEmpty()){
                update ctpUpdates;
            } 
            peList[0].Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c  = false;
            update peList;
            MedicalRecordAccessRemote.getHumanAPIPastPEList(td.participant.Contact__c);
        }
    }
    
    @IsTest
    static void test_getStudyProviders() {
        
        TestData td = new TestData();
        List<Token__c> tokenList = new List<Token__c>();
        List<LabelValueItem> aluminiItems = new List<LabelValueItem>();
        List<Participant_Enrollment__c> newPRList = [select id,Participant__c,Name,Participant__r.Contact__c,Participant_Status__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Human_Id__c,Unique_HumanId__c,Participant__r.Email__c from Participant_Enrollment__c];
        for(Participant_Enrollment__c peobj : newPRList)
        {
            peobj.Human_Id__c  ='humanid123';
            peobj.Participant_Status__c = 'Failed Referral';
            
            Token__c token = new Token__c(
                Participant_Enrollment__c = peobj.id,
                Token_Type__c = 'access',
                Token_Value__c = 'testvalue',
                Expiration_Date__c = Date.today().addDays(5)
            );
            tokenList.add(token);   
        }
        insert tokenList;
        List<Provider> providers = new List<Provider>();
        MedicalRecordAccessRemote.StudyProviderDTO wrapper = new MedicalRecordAccessRemote.StudyProviderDTO();
        wrapper.label = 'medicalProvider';
        wrapper.value = 'testValue';
        wrapper.humanId= 'test123';
        wrapper.providers = providers;
        
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
            
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.class);
            
            Test.startTest();
            ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
            
            for(Participant_Enrollment__c peobj : newPRList)
            {
                LabelValueItem labelItem = new LabelValueItem(peobj.Clinical_Trial_Profile__r.Study_Code_Name__c,peobj.Unique_HumanId__c+':::'+peobj.Id);
                if(participantState.pe != null && participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
                    aluminiItems.add(labelItem);
                }
                if(!aluminiItems.contains(labelItem))
                {
                    aluminiItems.add(labelItem);
                }
            }
            String str = JSON.serialize(aluminiItems);
            String status ='PARTICIPANT';
            MedicalRecordAccessRemote.getStudyProviderList(str,newPRList[0].id,status);
            MedicalRecordAccessRemote.getStudyProvider(wrapper.value,wrapper.label,wrapper.providers);
            test.stopTest();
        }
    }
    
    @IsTest
    static void test_getHumanAPIAlunmiPastPEListRevamp() {
        
        TestData td = new TestData();
        List<LabelValueItem> aluminiItems = new List<LabelValueItem>();
        List<Clinical_Trial_Profile__c> ctpUpdates = new List<Clinical_Trial_Profile__c>();
        List<Participant_Enrollment__c> newPRList = [select id,Participant__c,Name,Participant__r.Contact__c,Participant_Status__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Human_Id__c,Unique_HumanId__c,Participant__r.Email__c from Participant_Enrollment__c];
        for(Participant_Enrollment__c peobj : newPRList)
        {
            peobj.Human_Id__c  ='humanid123';
            peobj.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c  = true;
            peobj.Participant__r.Contact__c =td.participant.Contact__c;
            peobj.Participant__c = td.participant.id;
            peobj.Study_Site__c = td.ss.id;
            peobj.Clinical_Trial_Profile__c = td.ctp.id;
            peobj.Participant_Status__c = 'Failed Referral';
            
        }
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp.Medical_Vendor_is_Available__c = true;
        ctp.Id= td.ctp.id;
        ctpUpdates.add(ctp);
        
        if(!ctpUpdates.isEmpty()){
            update ctpUpdates;
        }
        
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new Test_HumanAPIMultipleCallout()); 
            
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.class);
            
            Test.startTest();
            ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
            
            for(Participant_Enrollment__c peobj : newPRList)
            {
            if(participantState.pe != null && participantState.pe.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c && !participantState.medicalVendors.isEmpty()){
                for(Medical_Record_Vendor__c vendor: participantState.medicalVendors){
                    if(vendor.Medical_Vendor__c == 'HumanAPI'){
                        LabelValueItem labelItem = new LabelValueItem(participantState.pe.Clinical_Trial_Profile__r.Study_Code_Name__c,participantState.pe.Unique_HumanId__c+':::'+participantState.pe.Id);
                        aluminiItems.add(labelItem);
                    }
                }
            } 
            }
            update newPRList;
            MedicalRecordAccessRemote.getHumanAPIAlunmiPastPEListRevamp();
            test.stopTest();
        }
    }
}