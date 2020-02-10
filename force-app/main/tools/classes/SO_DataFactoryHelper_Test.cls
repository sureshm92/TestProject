/**
 * Created by Slav on 10.02.2020.
 */

@IsTest(SeeAllData = false)
public class SO_DataFactoryHelper_Test {
    
    @IsTest
    static void runTest() {
        SO_DataFactoryHelper.getAllObjects();
        List<SObjectField> accountFields = SO_DataFactoryHelper.getFields('Account');
        SO_DataFactoryHelper.getFieldNames('Account');

        for (SObjectField sObjectField : accountFields) {
            String type = SO_DataFactoryHelper.getFieldType('Account', sObjectField.getDescribe().name);
        }
        
        SO_DataFactoryHelper.getReferenceTo('Contact', 'AccountId');
        SO_DataFactoryHelper.getPicklistEntries('Account', 'Type');
        SO_DataFactoryHelper.getPicklistValues('Account', 'Type', true);
        SO_DataFactoryHelper.createSelectOptions(new List<String>{'YES', 'NO'}, '--select--');
        SO_DataFactoryHelper.listToCSV(new List<String>{'YES', 'NO'});
        SO_DataFactoryHelper.setToCSV(new Set<String>{'YES', 'NO'});
    }
}