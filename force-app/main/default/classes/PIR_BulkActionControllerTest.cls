@isTest
public class PIR_BulkActionControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData(); 
    }

    @isTest
    static void testCreateUserForPatientProtal(){
        List<Participant_Enrollment__c> peList = [SELECT Id FROM Participant_Enrollment__c];
        List<String> peIds = new List<String>();
        for(Participant_Enrollment__c pe:peList){
            peIds.add(pe.Id);
        }
        
        Test.startTest();
        PIR_BulkActionController.createUserForPatientProtal(peIds,true);
        PIR_BulkActionController.updateParticipantData(peIds);
        PIR_BulkActionController.exportSelected(peIds);        
        Test.stopTest();
    }
    
    @isTest
    static void testExportAll(){
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<String> ctpIds = new List<String>();
        for(Clinical_Trial_Profile__c ctp:ctpList) {
            ctpIds.add(ctp.Id);
        }
        List<Study_Site__c> studySiteList = [SELECT Id FROM Study_Site__c];
        List<String> studyIds = new List<String>();
        for(Study_Site__c ss:studySiteList){
            studyIds.add(ss.Id);
        }
        Test.startTest();
        PIR_BulkActionController.exportAll(ctpIds,studyIds,0,45000,'Default');
        try{
            System.runAs(testData.participantUser) {
        		PIR_BulkActionController.exportAll(null,null,0,45000,null);
                
            }
        }catch (Exception ex){}
        try{
            System.runAs(testData.participantUser) {
                PIR_BulkActionController.exportAll(null,null,0,45000,'Default');
            }
        } catch (Exception ex){System.debug('Exception:'+ex.getLineNumber()+' '+ex.getMessage());}
        //PIR_BulkActionController.fetchData('Change Participant Status',ctpIds,'Enrollment Success');
        Test.stopTest();
    }

}