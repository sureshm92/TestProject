/**
 * Created by Slav on 10.02.2020.
 */

@IsTest(SeeAllData = false)
public class SO_DataFactoryController_Test {

    @IsTest
    static void runTest() {
        SO_FieldMeta fieldMeta = new SO_FieldMeta();
        fieldMeta.reset();
        
        SO_DataFactoryController controller = new SO_DataFactoryController();
        controller.selectedObject = 'Contact';
        controller.objectChange();

        controller.fieldIndex = 0;
        controller.fieldChange();
        
        controller.lookupField = 'AccountId';
        controller.showLookupDialog();
        
        controller.lookupId = '9989898989898';
        controller.assignLookupId();
        
        controller.closeLookupDialog();
        
        controller.fieldIndex = 0;
        controller.addField();
        controller.delField();
    
        controller.fieldIndex = 1;
        controller.addField();
        controller.fieldIndex = 0;
        controller.addField();

        controller.fieldIndex = null;
        controller.addField();
        controller.delField();
    
        controller.fieldIndex = 0;
        fieldMeta = controller.fieldMetas.get(0);
        fieldMeta.fieldName = 'LastName';
        fieldMeta.stringValue = 'Smith';
        fieldMeta.fieldType = 'INTEGER';
        controller.createRecord();
        fieldMeta.fieldType = 'PICKLIST';
        controller.createRecord();
        fieldMeta.fieldType = 'BOOLEAN';
        controller.createRecord();
        fieldMeta.fieldType = 'BASE64';
        controller.createRecord();
        fieldMeta.fieldType = 'DATE';
        controller.createRecord();
        fieldMeta.fieldType = 'DATETIME';
        controller.createRecord();
        fieldMeta.fieldType = 'TEXT';
        controller.createRecord();
    
        controller.selectedObject = null;
        controller.createRecord();
        controller.recentRecords();
        
        controller.selectedObject = 'Contact';
        controller.recentRecords();
        
        controller.deleteRecord();
        controller.recordIndex = null;
        controller.deleteRecord();
        
        controller.fieldMetas = null;
        controller.recentRecords();
        controller.fieldChange();
    }
}