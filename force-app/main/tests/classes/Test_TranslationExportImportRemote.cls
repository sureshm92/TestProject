/**
 * Created by Yulia Yakushenkova on 19.03.2020.
 */

@IsTest
private class Test_TranslationExportImportRemote {
    @IsTest
    static void test_exportTranslationForStudy() {
        TestData.loadTestData();
        TestData td = new TestData();
        TranslationExportImportRemote.export(td.ctp.Id, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
    }

    @IsTest
    static void test_exportPlatformData() {
        TranslationExportImportRemote.exportPlatformData('RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
    }

    @IsTest
    static void test_exportTranslationForVisitPlan() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test VP');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>{
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 1,
                        Visit_Number__c = 1
                ),
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 2,
                        Visit_Number__c = 2
                )
        };
        insert visits;
        TranslationExportImportRemote.exportTranslationForVisitPlan(vp.Id, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
    }

    @IsTest
    static void test_exportTranslationForVisitPlanIconDetails() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test VP');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>{
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 1,
                        Visit_Number__c = 1
                ),
                new Visit__c(
                        Visit_Plan__c = vp.Id,
                        Order__c = 2,
                        Visit_Number__c = 2
                )
        };
        insert visits;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>{
                new Icon_Details__c(
                        Name = 'pregnant',
                        Label__c = 'pregnant',
                        Visit_Plan__c = vp.Id),
                new Icon_Details__c(
                        Name = 'Hand-X-Ray',
                        Visit_Plan__c = vp.Id)
        };
        insert iconDetails;

        String result;

        Test.startTest();
        TranslationExportImportRemote.exportVisitPlan(vp.Id, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        String exportXML = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<xliff version="1.2">' + '<file original="Salesforce" source-language="en_US" target-language="RU" datatype="xml">' + '<body>' +
        '<trans-unit id="a1E3O000000LvQyUAK-patient_portal_name__c" maxwidth="255" size-unit="char">' +
        '<source>Visit 1</source>' + '<target>Посещение 1</target>' + '</trans-unit>'+
        '<trans-unit id="a1E3O000000LvQyUAK-visit_schedule__c" maxwidth="255" size-unit="char">'+
        '<source>Visit 1</source>'+ '<target>Посещение 1</target>'+ '</trans-unit>'+
        '<trans-unit id="a1E3O000000LvQzUAK-patient_portal_name__c" maxwidth="255" size-unit="char">'+
        '<source>Visit 2</source>'+ '<target>Посещение 2</target>'+ '</trans-unit>'+
        '<trans-unit id="a1E3O000000LvQzUAK-visit_schedule__c" maxwidth="255" size-unit="char">'+
        '<source>Visit 2</source>'+ '<target>Посещение 2</target>'+
        '</trans-unit>'+ '<trans-unit id="a0I3O000000XWW7UAO-label__c" maxwidth="255" size-unit="char">'+
        '<source>pregnant</source>'+ '<target>Беременная</target>'+
        '</trans-unit>'+ '<trans-unit id="a0I3O000000XWW7UAO-description__c" maxwidth="20000" size-unit="char">' +
        '<source></source>' +'</trans-unit>' +'</body>' +'</file>' + '</xliff>';
        result = TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(exportXML)));
        Test.stopTest();

        System.assertEquals('{"unimportedData":null,"unimportedCount":0,"importedCount":5,"deletedCount":0}', result);
    }

    @IsTest
    static void test_getPlatformLevelTranslatableObjects() {
        TranslationExportImportRemote.getPlatformLevelTranslatableObjects();
    }

    @IsTest
    static void test_importTranslation_getError() {
        Test.startTest();
        String exportXML = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<xliff version="1.2">' + '<file original="Salesforce" source-language="en_US" target-language="RU" datatype="xml">' + '<body>' +
                '<trans-unit id="a1E3O000000LvQyUAK-patient_portal_nam__c" maxwidth="255" size-unit="char">' +
                '<source>Visit 1</source>' + '<target>Посещение 1</target>' + '</trans-unit>'+
                '<trans-unit id="a1E3O000000LvQyUAK-visit_schedule__c" maxwidth="255" size-unit="char">'+
                '<source>Visit 1</source>'+ '<target>Посещение 1</target>'+ '</trans-unit>'+
                '<trans-unit id="a1E3O000000LvQzUAK-patient_portal_name__c" maxwidth="255" size-unit="char">'+
                '<source>Visit 2</source>'+ '<target>Посещение 2</target>'+ '</trans-unit>'+
                '<trans-unit id="a1E3O000000LvQzUAK-visit_schedule__c" maxwidth="255" size-unit="char">'+
                '<source>Visit 2</source>'+ '<target></target>'+
                '</trans-unit>'+ '<trans-unit id="a0I3O000000XWW7UAO-label__c" maxwidth="255" size-unit="char">'+
                '<source>pregnant</source>'+ '<target>Беременная</target>'+
                '</trans-unit>'+ '<trans-unit id="a0I3O000000XWW7UAO-description__c" maxwidth="20000" size-unit="char">' +
                '<source></source>' +'</trans-unit>' +'</body>' +'</file>' + '</xliff>';
        TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(exportXML)));
        Test.stopTest();
    }
}