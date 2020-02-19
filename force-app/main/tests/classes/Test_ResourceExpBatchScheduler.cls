/**
 * Created by Yehor Dobrovolskyi
 */
@IsTest(IsParallel=false)
public with sharing class Test_ResourceExpBatchScheduler {

    public static String CRON_EXP = '0 0 0 10 2 ? 2025';
    static List<Resource__c> resources;
    static Map<Id, Resource__c> resourceMap;
    static List<Id> resIds;
    static  String query = 'SELECT ' +
            'Id,' +
            'Expiration_Date__c, ' +
            'Content_Class__c ' +
            'FROM Resource__c ' +
            'WHERE Expiration_Date__c <= today  AND Remove_sharing__c = false';

    static void init() {
        resources = new List<Resource__c>();
        Date expDate = Date.today().addDays(-2);
        Date publish = expDate.addYears(-1);
        for (Integer i = 0; i < 10; i++) {
            Resource__c res = new Resource__c(
                    Expiration_Date__c = expDate,
                    Posting_Date__c = publish,
                    Content_Type__c = ResourceService.RESOURCE_TYPE_ARTICLE,
                    Content_Class__c = 'Study-Specific'
            );
            resources.add(res);
        }
        resources.add(
                new Resource__c(
                Expiration_Date__c = expDate,
                Posting_Date__c = publish,
                Content_Type__c = ResourceService.RESOURCE_TYPE_ARTICLE,
                Content_Class__c = ResourceService.RESOURCE_SOURCE_PLATFORM
                )
        );
        insert resources;
        resourceMap = new Map<Id, Resource__c>(resources);
        resIds = new List<Id>(resourceMap.keySet());
    }

    @IsTest
    static void testScheduledJob() {
        Test.startTest();
        String jobId = System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new ResourceExpBatchScheduler()
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }

    @IsTest
    static void testBatchClass() {
        init();
        List<Resource__c> rl = [
                SELECT Id
                FROM Resource__c
                WHERE Id IN :resIds
        ];
        System.assertEquals(11, rl.size(), 'Resources delete before job has run');
        Test.startTest();
        Database.executeBatch(new BatchProcess(query, new ResourceExpirationBatchHandlerImpl()), 1000);
        Test.stopTest();
        rl = [
                SELECT Id
                FROM Resource__c
                WHERE Id IN :resIds
        ];
        System.assertEquals(1, rl.size(), 'Resources not delete');
    }
}