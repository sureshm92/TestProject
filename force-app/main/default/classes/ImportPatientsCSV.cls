/**
 * Created by Denis Z on 16-Jul-19.
 */

public without sharing class ImportPatientsCSV {

    public String documentName {get;set;}
    public Blob csvFileBody {get;set;}
    public Boolean readSuccess {get;set;}
    public Integer size {get;set;}

    public ImportPatientsCSV() {
        documentName = '';
        readSuccess = false;
    }

    public void readFromFile(String patientString){
        try{
            readCSVFile(patientString);
        }
        catch(exception e){
            readSuccess = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            ApexPages.addMessage(errorMessage);
        }
    }

    public void readFromFile(){
        try{
            String patientString = csvFileBody.toString();
            readCSVFile(patientString);
        }
        catch(exception e){
            readSuccess = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            ApexPages.addMessage(errorMessage);
        }
    }

    public void readCSVFile(String patientString) {
        List<Patient> patients = new List<Patient>();
        List<String> dataLines = new List<String>();
        dataLines = patientString.split('\n');
        for (Integer i = 1; i < dataLines.size(); i++) {
            Patient patient = new Patient(dataLines[i].split(',')[1]);
            patients.add(patient);
        }
        if(patients.size() > 0){
            readSuccess = true;
            size = patients.size();
        }
        if (!Test.isRunningTest()) {
            Batch_CreateParticipants.run(5);
        }
    }

    public class Patient {
        public String protocolId    {get;set;}
        public String siteNumber    {get;set;}
        public String screeningId   {get;set;}

        public Patient(String externalKey){
            List<String> keys = new List<String>();
            keys = externalKey.split('~');
            protocolId = keys[0];
            siteNumber = keys[1];
            screeningId = keys[2];
        }
    }
}