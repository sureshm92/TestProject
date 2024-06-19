@isTest
public class Test_Batch_UpdateECOARetryFlag {
     @TestSetup
    static void setup() {
        TestData.loadTestData();
    }
@isTest
    public static void test1(){
        try{
        List<String> csvRowValues = new List<String>();
        List<Participant_Enrollment__c> pe = [SELECT Id FROM participant_Enrollment__c LIMIT 1];
        String rowStr = pe[0].Id;
        Participant_Enrollment__c peup = new Participant_Enrollment__c();
        peup.Id = pe[0].Id;
        //peup.ECOA_Retry_Disabled__c = true;
        update peup;
        csvRowValues.add(rowStr);
            String documentName = 'Update PE ECOA Retry';
            String csvColumnHeader = 'Id' + '\n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            //Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), Type = 'csv',FolderId = UserInfo.getUserId(), ContentType='application/vnd.ms-excel');
            //insert doc;
              ContentVersion contentVersionInsert = new ContentVersion(
            Title = documentName,
            PathOnClient = documentName + '.csv',
            VersionData = Blob.valueOf(csvFile),
            IsMajorVersion = true      
        );
        insert contentVersionInsert;
        
        
        Test.startTest();
        DataBase.executeBatch(new Batch_UpdateECOARetryFlag());
        Test.stopTest();
        }catch(Exception ex){
         System.debug('>>ex<<'+ex.getMessage());
        }
    }
}