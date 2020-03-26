/**
 * Created by Olga Skrynnikova on 1/29/2020.
 */

public with sharing class ResourceForStudyResFlowRemote {
    public class InitData {
        @AuraEnabled public List<Resource__c> resourceList;
    }

    @AuraEnabled
    public static InitData getResourceList() {
        try {
            InitData initData = new InitData();
            InitData.resourceList = [SELECT Id, Name, Title__c FROM Resource__c];
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSelectedResourceTitle(Id resourceId) {
        try {
            List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c WHERE Id =: resourceId];
            return resources[0].Title__c;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}