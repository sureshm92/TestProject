/**
 * Created by Yulia Yakushenkova on 19.03.2020.
 */

@IsTest
private class Test_TranslationExportImportRemote {

    public static Id getVisitPlanId() {
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
        return vp.Id;
    }

    @IsTest
    static void test_exportTranslationForStudy() {
        TestData.loadTestData();
        TestData td = new TestData();

        Test.startTest();
        TranslationExportImportRemote.export(td.ctp.Id, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        Test.stopTest();
    }

    @IsTest
    static void test_exportPlatformData() {
        Test.startTest();
        TranslationExportImportRemote.exportPlatformData('RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        Test.stopTest();
    }

    @IsTest
    static void test_exportTranslationForVisitPlan() {
        Test.startTest();
        TranslationExportImportRemote.exportTranslationForVisitPlan(
                getVisitPlanId(), 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL
        );
        Test.stopTest();
    }

    @IsTest
    static void test_exportTranslationForVisitPlanIconDetails() {
        Id visitPlanId = getVisitPlanId();
        insert new List<Icon_Details__c>{
                new Icon_Details__c(
                        Name = 'pregnant',
                        Label__c = 'pregnant',
                        Visit_Plan__c = visitPlanId),
                new Icon_Details__c(
                        Name = 'Hand-X-Ray',
                        Visit_Plan__c = visitPlanId)
        };

        String result;

        Test.startTest();
        String exportXML = TranslationExportImportRemote.exportVisitPlan(visitPlanId, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        result = exportXML.substring(0, 306) + '/n' + '<target>Посещение 1</target>' +
                exportXML.substring(306, 465) + '/n' + '<target>Посещение 1</target>' +
                exportXML.substring(465, 629) + '/n' + '<target>Посещение 2</target>' +
                exportXML.substring(629, 788) + '/n' + '<target>Посещение 2</target>' +
                exportXML.substring(788, 946) + '/n' + '<target>Беременная</target>' +
                exportXML.substring(1104);
        TranslationExportImportRemote.ImportResult ir = (TranslationExportImportRemote.ImportResult)JSON.deserialize(
                TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(result))),  TranslationExportImportRemote.ImportResult.class
        );
        Test.stopTest();
        System.assertEquals(5, ir.importedCount);
    }

    @IsTest
    static void test_getPlatformLevelTranslatableObjects() {
        TranslationExportImportRemote.getPlatformLevelTranslatableObjects();
    }

    @IsTest
    static void test_importTranslation_getError() {
        Id visitPlanId = getVisitPlanId();
        insert new List<Icon_Details__c>{
                new Icon_Details__c(
                        Name = 'pregnant',
                        Label__c = 'pregnant',
                        Visit_Plan__c = visitPlanId),
                new Icon_Details__c(
                        Name = 'Hand-X-Ray',
                        Visit_Plan__c = visitPlanId)
        };

        String result;

        Test.startTest();
        String exportXML = TranslationExportImportRemote.exportVisitPlan(visitPlanId, 'RU', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        result = exportXML.substring(0, 216) + 'patient_portal_n' + exportXML.substring(238, 306) + '/n' + '<target>Посещение 1</target>' +
                exportXML.substring(306, 465) + '/n' + '<target>Посещение 1</target>' +
                exportXML.substring(465, 629) + '/n' + '<target>Посещение 2</target>' +
                exportXML.substring(629, 788) + '/n' + '<target>Посещение 2</target>' +
                exportXML.substring(788, 946) + '/n' + '<target>ТестТестТест</target>' +
                exportXML.substring(1104);
        TranslationExportImportRemote.ImportResult ir = (TranslationExportImportRemote.ImportResult)JSON.deserialize(
                TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(result))),  TranslationExportImportRemote.ImportResult.class
        );
        Test.stopTest();

        System.assertEquals(1, ir.unimportedCount);
        System.assertEquals(4, ir.importedCount);
    }
}