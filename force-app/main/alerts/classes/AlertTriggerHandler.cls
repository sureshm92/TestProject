/**
 * Created by Leonid Bartenev
 */

public without sharing class AlertTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class ValidateFieldsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            validateFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            validateFields(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void validateFields(List<Alert__c> newList) {
        Set<String> catalogCodes = new Set<String>();
        for (Alert__c alert : newList)
            catalogCodes.add(alert.Alert_Code__c);
        List<Alert_Catalog__mdt> cards = [
            SELECT
                Id,
                DeveloperName,
                Body_label__c,
                Title_label__c,
                Parameters__c,
                Source_Object_Type__c
            FROM Alert_Catalog__mdt
            WHERE DeveloperName IN :catalogCodes
        ];
        Map<String, Alert_Catalog__mdt> cardsMap = new Map<String, Alert_Catalog__mdt>();
        for (Alert_Catalog__mdt card : cards)
            cardsMap.put(card.DeveloperName, card);

        for (Alert__c alert : newList) {
            if (alert.Alert_Code__c == null)
                alert.Alert_Code__c.addError('Alert code can not be empty');
            Alert_Catalog__mdt card = cardsMap.get(alert.Alert_Code__c);
            if (card == null) {
                alert.Alert_Code__c.addError(
                    'Alert Catalog Card : ' +
                    alert.Alert_Code__c +
                    ' not found in catalog'
                );
                break;
            }
            if (card.Source_Object_Type__c == null && card.Parameters__c != null) {
                alert.addError(
                    'Source Object Type can not be null in Alert Catalog: ' + card.DeveloperName
                );
                break;
            }
            SObjectType sourceObjectType = Schema.getGlobalDescribe()
                .get(card.Source_Object_Type__c);
            if (sourceObjectType == null && card.Parameters__c != null) {
                alert.addError(
                    'Wrong Source Object Type in Alert Catalog ' +
                    card.DeveloperName +
                    ': ' +
                    card.Source_Object_Type__c
                );
                break;
            }
            String errorsInParameters = CatalogParametersHelper.getErrorInParameters(
                sourceObjectType,
                card.Parameters__c
            );
            if (errorsInParameters != null) {
                alert.addError(
                    'Alert Catalog: ' +
                    card.DeveloperName +
                    '; Parameters error: ' +
                    errorsInParameters
                );
                break;
            }
            if (alert.Record_ID__c == null && card.Parameters__c != null && !alert.Is_Platform_Level__c) {
                alert.Record_ID__c.addError('Record Id can not be null');
                break;
            }
            Id recId;
            if (alert.Record_ID__c != null) {
                try {
                    recId = alert.Record_ID__c;
                    if (recId.getSobjectType() != sourceObjectType)
                        alert.Record_ID__c.addError('Wrong record SObject Type');
                } catch (Exception e) {
                    alert.Record_ID__c.addError('Wrong recordId: ' + alert.Record_ID__c);
                }
            }
        }
    }
}