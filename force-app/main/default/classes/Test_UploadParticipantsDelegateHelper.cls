@isTest public class Test_UploadParticipantsDelegateHelper {
    @IsTest
    private static void testWrapperCreartion() {
        UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper pWrapper = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
        pWrapper.DelegateEmail = 'DelegateEmail@testmail.com';
        pWrapper.DelegateFirstName ='DelegateFirstName';
        pWrapper.DelegateLastName ='DelegateLastName';
        pWrapper.DelegatePhoneType ='Home';
        pWrapper.mainparticipant = new Participant__c();
         List<List<String>> csvLines = new  List<List<String>>();
        List<String> csvFileLines = new List<String>();
        csvFileLines.add('a');
        csvFileLines.add('b');
        csvFileLines.add('c');
        List<String> csvFileLines2 = new List<String>();
        csvFileLines2.add('a');
        csvFileLines2.add('b');
        csvFileLines2.add('c');
        List<String> csvFileLines3 = new List<String>();
        csvFileLines3.add('a');
        csvFileLines3.add('b');
        csvFileLines3.add('c');
        csvLines.add(csvFileLines);
        csvLines.add(csvFileLines2);
        csvLines.add(csvFileLines3);
        try{
            UploadParticipantsDelegateHelper.getCleanMessage(csvLines,1);
            UploadParticipantsDelegateHelper.createPatientDelegate(null,null);
            UploadParticipantsDelegateHelper.updateDelegateRecords(new list<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>{pWrapper});
            UploadParticipantsDelegateHelper.createDelegateRecords(new list<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>{pWrapper},new Study_Site__c(),csvLines);
        }
        catch(exception e){
            system.assertEquals(e.getMessage(), 'Attempt to de-reference a null object');
        }
    }
}