public with sharing class LofiLoginController {

    @AuraEnabled
    public static CPRA_DoNotSell__mdt getCPRALink(String strCommunityType){
        list<CPRA_DoNotSell__mdt> lstMd = new list<CPRA_DoNotSell__mdt> ();
        if(string.isBlank(strCommunityType) || strCommunityType == 'null')
        {
              lstMd = [SELECT id,Active__c,Community_Name__c,Link_to_redirect__c,CPRA_Label__c from CPRA_DoNotSell__mdt
                                                where Active__c = true and Link_to_redirect__c != Null and Community_Name__c = 'Default' LIMIT 1];
        }
        else if(strCommunityType == 'Janssen')
        {
            lstMd = [SELECT id,Active__c,Community_Name__c,Link_to_redirect__c,CPRA_Label__c from CPRA_DoNotSell__mdt
                        where Active__c = true and Link_to_redirect__c != Null and Community_Name__c = 'Janssen Community' LIMIT 1];
        }
        else if(strCommunityType == 'GSK')
        {
            lstMd = [SELECT id,Active__c,Community_Name__c,Link_to_redirect__c,CPRA_Label__c from CPRA_DoNotSell__mdt
                        where Active__c = true and Link_to_redirect__c != Null and Community_Name__c = 'GSK Community' LIMIT 1];
        }
        return lstMd.isEmpty() ? Null : lstMd[0];
    }
   
}