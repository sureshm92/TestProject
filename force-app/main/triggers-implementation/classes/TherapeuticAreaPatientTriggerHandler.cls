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

        for (Therapeutic_Area_Patient__c tap : [
            SELECT
                Id,
                Participant__r.Contact__c,
                Therapeutic_Area__c,
                Participant__r.Contact__r.Language__c,
                Participant__r.Contact__r.Second_Choice_Language__c,
                Participant__r.Contact__r.Third_Choice_Language__c
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
                for (String langCode : langsList) {
                    if (
                        (!String.isEmpty(taAssignment.Resource__r?.Language__c) &&
                        taAssignment.Resource__r?.Language__c == langCode) ||
                        (!String.isEmpty(taAssignment.Resource__r?.Languages__c) &&
                        taAssignment.Resource__r?.Languages__c.contains(langCode))
                    ) {
                        resourceIds.add(taAssignment.Resource__c);
                    }
                }
            }
        }
        for (Res_study__c resStudy : [
            SELECT Id
            FROM Res_study__c
            WHERE Resource__c = :resourceIds
        ]) {
            resourceIds.add(resStudy.Id);
        }
        List<Notification__c> updateNotifications = new List<Notification__c>();
        for (Notification__c notification : [
            SELECT Status__c
            FROM Notification__c
            WHERE
                Target_Record_Ids__c = :resourceIds
                AND Recipient__c = :contactIds
                AND Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
        ]) {
            notification.Status__c = 'Processed';
            updateNotifications.add(notification);
        }

        if (!updateNotifications.isEmpty()) {
            update updateNotifications;
        }
    }
}
