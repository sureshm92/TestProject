@IsTest
public class Test_NoteSection {
    @IsTest
    public static void runTest() {
        Media_Outreach__c MO_inprogress = New Media_Outreach__c();
        MO_inprogress.Requested_Start_Date__c = Date.parse('5/22/2020');
        MO_inprogress.Requested_End_Date__c = Date.parse('5/29/2020');
        MO_inprogress.Status__c = 'In Progress';
        MO_inprogress.Preferred_contact_method__c = 'test@test.com';
        Insert MO_inprogress;

        ContentNote nts = new ContentNote();
        nts.Title = 'Good';
        insert nts;

        ContentDocumentLink clnk = new ContentDocumentLink();
        clnk.LinkedEntityId = MO_inprogress.ID;
        clnk.ContentDocumentId = nts.Id;
        clnk.ShareType = 'V';
        insert clnk;
        string MediaoutreachNotes = 'good';
        Test.startTest();
        try {
            GetNotes.UpdateNotes(MO_inprogress.ID, MediaoutreachNotes);
        } catch (exception e) {}
        try {
            GetNotes.getNotesdata(MO_inprogress.ID);
        } catch (exception e) {}
        Test.stopTest();


    }
}