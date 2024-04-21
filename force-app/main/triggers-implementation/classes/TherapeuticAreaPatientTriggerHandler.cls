/**
* Created by Yehor Dobrovolskyi
*/
public without sharing class TherapeuticAreaPatientTriggerHandler extends TriggerHandler {
    public override void afterDelete(List<SObject> oldList) {
        removeUpdateNotifications(oldList);
    }
    
    public void removeUpdateNotifications(List<Therapeutic_Area_Patient__c> tapList) {
        List<Id> therapeuticAreaIds = new List<Id>();
        List<Id> resourceIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        Map<String, List<String>> contactLangMap = new Map<String, List<String>>();
        Map<String,String> ctResourceIdsMap = new Map<String,String>();
        for (Therapeutic_Area_Patient__c tap : [
            SELECT
            Id,
            Participant__r.Contact__c,
            Therapeutic_Area__c,
            Participant__r.Contact__r.Language__c,
            Participant__r.Contact__r.Second_Choice_Language__c,
            Participant__r.Contact__r.Third_Choice_Language__c,
            Participant__r.Contact__r.Resource_Notifications__c
            FROM Therapeutic_Area_Patient__c
            WHERE Id = :tapList
            ALL ROWS
        ]) {
            therapeuticAreaIds.add(tap.Therapeutic_Area__c);
            contactIds.add(tap.Participant__r.Contact__c);
            List<String> preferredLaguages = new List<String>();
            if (!contactLangMap.keySet().contains(tap.Participant__r.Contact__c)) {
                preferredLaguages.add(tap.Participant__r.Contact__r.Language__c);
                if (!String.isEmpty(tap.Participant__r.Contact__r.Second_Choice_Language__c))
                    preferredLaguages.add(tap.Participant__r.Contact__r.Second_Choice_Language__c);
                if (!String.isEmpty(tap.Participant__r.Contact__r.Third_Choice_Language__c))
                    preferredLaguages.add(tap.Participant__r.Contact__r.Third_Choice_Language__c);
                contactLangMap.put(
                    tap.Participant__r.Contact__c +
                    ':' +
                    tap.Therapeutic_Area__c,
                    preferredLaguages
                );
            }
            if(!ctResourceIdsMap.containsKey(tap.Participant__r.Contact__c)){
                ctResourceIdsMap.put(tap.Participant__r.Contact__c,tap.Participant__r.Contact__r.Resource_Notifications__c);
            }
        }
        
        for (Therapeutic_Area_Assignment__c taAssignment : [
            SELECT
            Resource__c,
            Resource__r.Language__c,
            Resource__r.Languages__c,
            Therapeutic_Area__c
            FROM Therapeutic_Area_Assignment__c
            WHERE Therapeutic_Area__c = :therapeuticAreaIds
        ]) {
            for (Id conId : contactIds) {
                List<String> langsList = contactLangMap.get(
                    conId +
                    ':' +
                    taAssignment.Therapeutic_Area__c
                );
                if(langsList != null && !langsList.isEmpty()){
                    if (
                        (!String.isEmpty(taAssignment.Resource__r?.Language__c) &&
                         langsList.contains(taAssignment.Resource__r?.Language__c)) ||
                        (!String.isEmpty(taAssignment.Resource__r?.Languages__c) &&
                         langsList.contains(taAssignment.Resource__r?.Languages__c))
                    ) {
                        resourceIds.add(taAssignment.Resource__c);
                    }
                }
            }
        }
        Map<Id,Id> stdResPtResMap = new Map<Id,Id>();
        for (Res_study__c resStudy : [
            SELECT Id,Resource__c
            FROM Res_study__c
            WHERE Resource__c = :resourceIds
        ]) {
            resourceIds.add(resStudy.Id);
            stdResPtResMap.put(resStudy.Id,resStudy.Resource__c); 
        }
        Map<String,Set<String>> ctIdRemovedResidsMap = new Map<String,Set<String>>();
        List<Notification__c> updateNotifications = new List<Notification__c>();
        for (Notification__c notification : [ 
            SELECT Status__c,Recipient__c,Target_Record_Ids__c
            FROM Notification__c
            WHERE
            Target_Record_Ids__c = :resourceIds
            AND Recipient__c = :contactIds
            AND Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
        ]) {
            String resId = stdResPtResMap.containsKey(notification.Target_Record_Ids__c)?stdResPtResMap.get(notification.Target_Record_Ids__c):notification.Target_Record_Ids__c;
            if(ctIdRemovedResidsMap.containsKey(notification.Recipient__c)){
                ctIdRemovedResidsMap.get(notification.Recipient__c).add(resId);
            }else{
                ctIdRemovedResidsMap.put(notification.Recipient__c,new Set<String>{resId});
            }
            notification.Status__c = 'Processed'; 
            updateNotifications.add(notification);
        }
        
        if (!updateNotifications.isEmpty()) {
            update updateNotifications;
        }
        List<Contact> ctToupdate = new List<Contact>();
        for(String ctId : ctResourceIdsMap.keyset()){
            Contact cnt = new Contact(Id = ctId);
            String resNotificationStr = ctResourceIdsMap.get(ctId);
            if(ctIdRemovedResidsMap.containsKey(ctId)){
                for(String sObjId : ctIdRemovedResidsMap.get(ctId)){
                    if(resNotificationStr != null && resNotificationStr.contains(sObjId)){
                        resNotificationStr = resNotificationStr.replace(sObjId + ';', '').replace('' + sObjId, '').removeEnd(';');   
                    }
                }
                cnt.Resource_Notifications__c = resNotificationStr;
                ctToupdate.add(cnt); 
            }
        }
        if(!ctToupdate.isEmpty()){
            update ctToupdate;
        }
    }
}