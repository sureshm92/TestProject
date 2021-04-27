/**
 * Created by Sandeep
 */

@IsTest(IsParallel=true)
private class Test_XLF_TweakerHelper {
    @IsTest
    static void setup() {
        List<XLF_White_List__mdt> records = new List<XLF_White_List__mdt>();
        XLF_White_List__mdt xlfwhitemdt = new XLF_White_List__mdt();
        xlfwhitemdt.Pattern__c = 'PicklistValue.*';
        xlfwhitemdt.Active__c = true;
        // xlfwhitemdt.Id='row-1';
        records.add(xlfwhitemdt);
        //   XLF_PatternListRemote.saveRecords(records,'WHITE');
        String st =
            '<?xml version="1.0" encoding="UTF-8"?><xliff version="1.2"><file original="Salesforce" source-language="en_US" target-language="en_US" datatype="xml"><body>' +
            '<trans-unit id="PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral" maxwidth="255" size-unit="char"><source>Failed Referral</source><target>PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral</target>' +
            '</trans-unit></body></file></xliff>';
        String st1 =
            '<?xml version="1.0" encoding="UTF-8"?><xliff version="1.2"><file original="Salesforce"="Salesforce" source-language="en_US" target-language="en_US" datatype="xml">' +
            '<trans id="PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral" maxwidth="255" size-unit="char"><source>Failed Referral</source><target>PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral</target>' +
            '</xl>';
        Document updatedDoc = new Document();
        updatedDoc.Body = Blob.valueof(st);
        updatedDoc.Name = 'xyz';
        updatedDoc.Type = 'xlf'; 
        updatedDoc.FolderId = UserInfo.getUserId();
        insert updatedDoc;
        //XLF_TweakerRemote obj=new XLF_TweakerRemote();
        XLF_TweakerRemote.startTweaking('xyz');
        XLF_TweakerRemote.startTweaking('xyz1');
        XLF_TweakerRemote.getDocuments();

        XLF_TweakerRemote.getDocId('xyz');
        XLF_TweakerRemote.getDocId('xyz1');
        XLF_TweakerRemote.startTweaking('xyz.tweaked.xlf');
        XLF_TweakerRemote.startTweaking('xyz.tweaked.xlf');
        XLF_TweakerRemote.startTweaking('xyz.tweaked.tweaked.xlf');
        XLF_TweakerRemote.startZipTweaking('xyzwe', st);
        XLF_TweakerRemote.startZipTweaking('xyzwe', st1);
    }

    @IsTest
    static void test1() {
        String st =
            '<?xml version="1.0" encoding="UTF-8"?><xliff version="1.2"><file original="Salesforce" source-language="en_US" target-language="en_US" datatype="xml"><body>' +
            '<trans-unit id="PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral" maxwidth="255" size-unit="char"><source>Failed Referral</source><target>PicklistValue.Participant_Enrollment__c.Participant_Status.Failed Referral</target>' +
            '</trans-unit></body></file></xliff>';

        XLF_TweakerHelper tweakerHelper = new XLF_TweakerHelper();
        tweakerHelper.whitePatterns.add('PicklistValue.*');
        Blob blobData = Blob.valueof(st);
        tweakerHelper.tweakData(blobData);
    }
}
