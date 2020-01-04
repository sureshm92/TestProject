/**
 * Created by Slav on 29.12.2019.
 */

@IsTest(SeeAllData=false)
public class Test_ResourceOverrideRemote {
    
    @IsTest
    public static void runTest() {
        RecordType recTypeArticle   = [SELECT DeveloperName, Name FROM RecordType WHERE SobjectType = 'Resource__c' AND DeveloperName = 'Article' LIMIT 1];
        RecordType recTypeDocument  = [SELECT DeveloperName, Name FROM RecordType WHERE SobjectType = 'Resource__c' AND DeveloperName = 'Study_Document' LIMIT 1];
        RecordType recTypeVideo     = [SELECT DeveloperName, Name FROM RecordType WHERE SobjectType = 'Resource__c' AND DeveloperName = 'Video' LIMIT 1];
        
        ResourceOverrideRemote.getMetadata(recTypeArticle.Id);

        Resource__c resource        = new Resource__c();
        resource.Title__c           = 'Test Document';
        resource.document_type__c   = 'Document';
        resource.Description__c     = 'Test Description';
        resource.Language__c        = 'en_US';
        resource.Version_Date__c    = Date.today();
    
        Map<String, Object> response = ResourceOverrideRemote.saveResource(recTypeVideo.Id, null, resource);
        System.assertEquals(response.get('isError'), true);
    
        response = ResourceOverrideRemote.saveResource(recTypeDocument.Id, null, resource);
        System.assertNotEquals(response.get('isError'), true);

        String recordId = (String) response.get('recordId');
        response = ResourceOverrideRemote.saveResource(recTypeDocument.Id, recordId, resource);
        System.assertNotEquals(response.get('isError'), true);
    
        resource.Language__c                = null;

        resource.Subtitle__c                = 'Subtitle';
        resource.Image__c                   = 'Image Link';
        resource.Image_Title__c             = 'Image Title';
        resource.Content_Class__c           = 'Platform-TA';
        resource.Posting_Date__c            = Date.today();
        resource.Expiration_Date__c         = Date.today();
        resource.Updated_Date__c            = Date.today();
        resource.Body__c                    = 'Body';
        resource.Author_s_Name__c           = 'Author\'s Name';
        resource.Source__c                  = 'Source';
        resource.Copyright__c               = 'Copyright';
        resource.X3rd_Party_Source__c       = 'IQVIA';
        resource.Therapeutic_Areas__c       = 'SiteCore Conditions';
        resource.Image_Subtitle__c          = 'Image Subtitle';
        resource.Byline__c                  = 'Byline';
        resource.URL_Part__c                = 'URL Part';
        resource.article_external_link__c   = 'Article External Link';
        resource.Remove_sharing__c          = true;
    
        response = ResourceOverrideRemote.saveResource(recTypeArticle.Id, null, resource);
        System.assertEquals(response.get('isError'), true);
    
        ResourceOverrideRemote.updateContentDocument(null, 'Test file', resource.Id, 'en_US');
    
        resource.Id                         = null;
        resource.Language__c                = 'en_US';
        response = ResourceOverrideRemote.saveResource(recTypeArticle.Id, null, resource);
        System.assertNotEquals(response.get('isError'), true);
    
    }

}