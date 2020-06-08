/**
 * Created by Olga Skrynnikova on 6/8/2020.
 */

public with sharing class Batch_UpdateCTPShortCommNameField implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        CommunityTemplate__c,
                        ShortCommunityName__c
                FROM Clinical_Trial_Profile__c
                WHERE ShortCommunityName__c = NULL
                AND CommunityTemplate__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Clinical_Trial_Profile__c> ctpList) {
        for (Clinical_Trial_Profile__c ctp : ctpList) {
            CommunityTemplate template = CommunityTemplateService.getTemplate(ctp.CommunityTemplate__c);
            ctp.ShortCommunityName__c = template.properties.get(TemplatePropertiesCatalog.TEMPLATE_PROP_PUSH_COMM_NAME_SHORT);
        }
        TriggerHandlerExecutor.bypassHandler(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
        update ctpList;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void run() {
        Database.executeBatch(new Batch_UpdateCTPShortCommNameField(), 200);
    }
}