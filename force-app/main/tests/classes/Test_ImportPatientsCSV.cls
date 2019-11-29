/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_ImportPatientsCSV {
    
    @IsTest
    public static void runTest() {
        String goodString = 'protocolId,siteNumber,screeningId\nSally~aa~Whittaker,20~18~99,McCarren~bb~House';
        String badString  = 'bad_string\naaaaa,';

        Test.StartTest();
    
        ImportPatientsCSV.Patient patient = new ImportPatientsCSV.Patient('Sally Whittaker~2018~McCarren House');
        
        ImportPatientsCSV csv = new ImportPatientsCSV();
        csv.csvFileBody = Blob.valueOf(goodString);
        csv.readFromFile();
    
        csv.csvFileBody = Blob.valueOf(badString);
        csv.readFromFile();
    
        csv.readFromFile(goodString);
        csv.readFromFile(badString);
    
        csv.readCSVFile(goodString);
        
        Test.StopTest();
    }

}