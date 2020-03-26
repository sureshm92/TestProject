/**
 * Created by user on 25.02.2020.
 */

@IsTest(SeeAllData = false)
public class Test_SO_DatasetManagerController {

    @IsTest
    static void runTest() {
        Contact contact = new Contact();
        contact.FirstName = 'John';
        contact.LastName  = 'Hanson';
        insert contact;

        String configString = generateConfig(false);
        String invalidConfigString = generateConfig(true);

        SO_DatasetManagerController controller = new SO_DatasetManagerController();
        controller.selectedObject = null;
        controller.objectChange();

        controller.selectedObject = 'Contact';
        controller.objectChange();

        controller.selectedObject = null;
        controller.queryObject();

        controller.selectedObject = 'Contact';
        controller.queryObject();

        controller.index = 0;
        controller.selectedObject = null;
        controller.includeEmptyRecord();

        controller.selectedObject = 'Contact';
        controller.includeEmptyRecord();

        controller.queryObject();


        controller.index = null;
        controller.includeRecord();

        controller.index = 0;
        controller.includeRecord();

        controller.index = null;
        controller.removeRecord();

        controller.index = 0;
        controller.removeRecord();

        controller.configFile.Body = Blob.valueOf('{ wrong config }');
        controller.loadConfig();

        controller.configFile.Body = Blob.valueOf(invalidConfigString);
        controller.loadConfig();

        controller.configFile.Body = Blob.valueOf(configString);
        controller.loadConfig();

        controller.editConfig();
        controller.index = null;
        controller.cancelEdit();
        controller.index = 0;
        controller.cancelEdit();

        controller.includeEmptyRecord();
        controller.index = null;
        controller.moveUp();
        controller.moveDown();

        controller.index = 1;
        controller.moveUp();
        controller.index = 0;
        controller.moveDown();

        controller.index = 0;
        controller.editConfig();
        controller.applyChanges();
        controller.index = 9;
        controller.applyChanges();

        controller.loadConfig();
        controller.testRun();

        controller.startCreate();
        controller.startDelete();
    }

    /**
     * generateConfig()
     *
     * @param injectError
     *
     * @return
     */
    private static String generateConfig (Boolean injectError) {
        SO_DatasetManagerController.ObjectWrap study = new SO_DatasetManagerController.ObjectWrap();
        if (injectError) {
            study.objectName = 'Clinical_Trial_Profile';
        } else {
            study.objectName = 'Clinical_Trial_Profile__c';
        }
        study.fields      = new List<SO_DatasetManagerController.Field>();

        SO_DatasetManagerController.Field field = new SO_DatasetManagerController.Field();
        field.name = 'Protocol_ID__c';
        field.value = 'Prot-933';
        study.fields.add(field);

        List<SO_DatasetManagerController.ObjectWrap> objectWraps = new List<SO_DatasetManagerController.ObjectWrap>();
        objectWraps.add(study);
        // ------------------------------------
        SO_DatasetManagerController.ObjectWrap resource = new SO_DatasetManagerController.ObjectWrap();
        resource.objectName = 'Resource__c';
        resource.fields      = new List<SO_DatasetManagerController.Field>();

        field = new SO_DatasetManagerController.Field();
        field.name = 'RecordTypeId';
        field.value = '0121j000000tUS4AAM';
        resource.fields.add(field);

        objectWraps.add(resource);
        // ------------------------------------
        SO_DatasetManagerController.ObjectWrap resStudy = new SO_DatasetManagerController.ObjectWrap();
        resStudy.objectName = 'Res_study__c';
        resStudy.fields      = new List<SO_DatasetManagerController.Field>();

        field = new SO_DatasetManagerController.Field();
        field.name = 'Resource__c';
        field.value = 'Resource__c';
        resStudy.fields.add(field);

        field = new SO_DatasetManagerController.Field();
        field.name = 'Clinical_Trial_Profile__c';
        field.value = 'Clinical_Trial_Profile__c';
        resStudy.fields.add(field);

        objectWraps.add(resStudy);

        SO_DatasetManagerController.Config config = new SO_DatasetManagerController.Config();
        config.objectList = objectWraps;

        String configString = JSON.serializePretty(config);

        System.debug('=========================================');
        System.debug(configString);
        System.debug('=========================================');

        return configString;
    }

}