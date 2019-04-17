/**
 * Created by AlexKetch on 4/17/2019.
 */
@IsTest
public with sharing class Test_ClinicalTrialProfileTriggerHandler {

    @IsTest
    public static void deleteRelatedToStudyDocuments_Test_ResInDiffStudies() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        //t1.Status__c = 'Completed';
        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        //t2.Status__c = 'Completed';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';

        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;

        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy4 = new Res_study__c();
        resStudy4.Resource__c = r2StudyDoc.Id;
        resStudy4.Clinical_Trial_Profile__c = t3.Id;

        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;

        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy4);
        resStudies.add(resStudy5);
        insert resStudies;
        ResourceService ser = new ResourceService();
        //ser.deleterelatedTostudyDocuments(profiles);
        t1.Status__c = 'Completed';
        t2.Status__c = 'Completed';
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(3, res.size());
        for (Resource__c r : res) {
            System.assert(r.Title__c != 'testStudy');
        }
        List<Res_study__c> resStudeis = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(5,resStudeis.size());


    }
    @IsTest
    public static void deleteRelatedToStudyDocuments_TestAllResInStudies() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';

        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';
        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;

        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;



        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;

        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy5);
        insert resStudies;
        ResourceService ser = new ResourceService();
        t1.Status__c = 'Completed';
        t2.Status__c = 'Completed';
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(2, res.size());
        for (Resource__c r : res) {
            System.assert(r.Title__c != 'testStudy');
        }
        List<Res_study__c> resStudeis2 = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(3,resStudeis2.size());


    }
    @IsTest
    public static void deleteRelatedToStudyDocuments_Test_NotCompletedStudy() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        Clinical_Trial_Profile__c t2 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t2.NCT_Number__c = 'NCT00000001';
        t2.Protocol_ID__c = 'NCT00000001';
        Clinical_Trial_Profile__c t3 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        t3.NCT_Number__c = 'NCT00000002';
        t3.Protocol_ID__c = 'NCT00000002';
        List<Clinical_Trial_Profile__c> profiles = new List<Clinical_Trial_Profile__c>();
        List<Resource__c> resources = new List<Resource__c>();
        profiles.add(t1);
        profiles.add(t2);
        profiles.add(t3);
        insert profiles;
        Resource__c r1StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.Title__c = 'testStudy';
        Resource__c r2StudyDoc = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r2StudyDoc.Title__c = 'testStudy2';
        Resource__c r3 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        Resource__c r4 = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        r1StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        r2StudyDoc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :ResourceService.STADY_DOCUMENT_RECORD_TYPE].Id;
        resources.add(r1StudyDoc);
        resources.add(r2StudyDoc);
        resources.add(r3);
        resources.add(r4);
        insert resources;
        List<Res_study__c> resStudies = new List<Res_study__c>();

        Res_study__c resStudy = new Res_study__c();
        resStudy.Resource__c = r1StudyDoc.Id;
        resStudy.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy1 = new Res_study__c();
        resStudy1.Resource__c = r2StudyDoc.Id;
        resStudy1.Clinical_Trial_Profile__c = t1.Id;

        Res_study__c resStudy2 = new Res_study__c();
        resStudy2.Clinical_Trial_Profile__c = t1.Id;
        resStudy2.Resource__c = r3.Id;

        Res_study__c resStudy3 = new Res_study__c();
        resStudy3.Resource__c = r4.Id;
        resStudy3.Clinical_Trial_Profile__c = t1.Id;



        Res_study__c resStudy5 = new Res_study__c();
        resStudy5.Resource__c = r4.Id;
        resStudy5.Clinical_Trial_Profile__c = t1.Id;

        resStudies.add(resStudy);
        resStudies.add(resStudy1);
        resStudies.add(resStudy2);
        resStudies.add(resStudy3);
        resStudies.add(resStudy5);
        insert resStudies;
        ResourceService ser = new ResourceService();
        update profiles;
        List<Resource__c> res = [SELECT Id,Name,Title__c FROM Resource__c];
        System.assertEquals(4, res.size());
        List<Res_study__c> resStudeis = [SELECT Id,Name,Clinical_Trial_Profile__c,Resource__c FROM Res_study__c];
        System.assertEquals(5,resStudeis.size());


    }

}