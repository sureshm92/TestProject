public with sharing class communityFooterController {

    @AuraEnabled
    public static CPRA_DoNotSell__mdt getCPRALink(String strCommunityType){
        list<CPRA_DoNotSell__mdt> lstMd = new list<CPRA_DoNotSell__mdt> ();
        list<CPRA_Active_Community__mdt> lstCpraActiveCommunity = new list<CPRA_Active_Community__mdt> ();
        user objuser = [SELECT ID,ContactId from user where id=:userinfo.getuserid()];
        Contact Objcon = [SELECT ID,userCommunityMode__c FROM CONTACT WHERE id=:objuser.contactid];
        if( strCommunityType == 'IQVIA Referral Hub' || strCommunityType == 'null')
        {
              lstMd = [SELECT id,Active__c,Community_Name__c,Link_to_redirect__c,CPRA_Label__c from CPRA_DoNotSell__mdt
                                                where Active__c = true and Link_to_redirect__c != Null and Community_Name__c = 'Default' LIMIT 1];
        }
        else  
        {
            lstMd = [SELECT id,Active__c,Community_Name__c,Link_to_redirect__c,CPRA_Label__c from CPRA_DoNotSell__mdt
                        where Active__c = true and Link_to_redirect__c != Null and Community_Name__c =:strCommunityType LIMIT 1];
        }
        if(Objcon.userCommunityMode__c == 'Participant')
        {
            lstCpraActiveCommunity = [ SELECT id, Active__c, Community_Name__c 
                                    FROM CPRA_Active_Community__mdt WHERE
                                    Active__c = TRUE and Community_Name__c='IQVIA PatientPortal1.0'];
            if(!lstCpraActiveCommunity.isEmpty())
            {
                return lstMd.isEmpty() ? Null : lstMd[0];

            }
            else {
            return null;
            }
        }
        else { 
        return lstMd.isEmpty() ? Null : lstMd[0];
        }
    }
     
}