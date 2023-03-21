/**
* Created by Leonid Bartenev
*testing Vijay
*/

public without sharing class Alert {
    public class AlertException extends Exception {
    }
    
    public static final String ALERT_CODE_WELCOME_PH = 'Welcome_To_The_PH';
    public static final String ALERT_CODE_WELCOME_PH_DELEGATE = 'Welcome_To_The_PH_Delegate';
    public static final String ALERT_CODE_WELCOME_STUDY = 'Welcome_to_the_Study';
    public static final String ALERT_CODE_WELCOME_STUDY_DELEGATE = 'Welcome_to_the_Study_Patient_Delegates';
    public static final String ALERT_CODE_WEEK_BEFORE_PRT_ADULT_DELEGATE = 'Participant_Become_Adult_to_Delegates';
    public static final String ALERT_CODE_PRT_BECOME_ADULT_DELEGATE = 'Participant_Adult_to_Delegates';
    public static final String ALERT_CODE_WELCOME_PH_PP = 'Welcome_To_The_PH_PP';
    public static final String ALERT_CODE_WELCOME_PH_DELEGATE_PP = 'Welcome_To_The_PH_Delegate_PP';
    public static final String ALERT_CODE_WELCOME_STUDY_PP = 'Welcome_to_the_Study_PP';
    public static final String ALERT_CODE_WELCOME_STUDY_DELEGATE_PP = 'Welcome_to_the_Study_Patient_Del_PP';
    
    public String title;
    public String body;
    public String code;
    public Map<String, String> params;
    public Id id;
    
    public Alert(String title, String body, Id alertId, String code, Map<String, String> params) {
        this.title = title;
        this.body = body.replaceAll('\n', '<br/>');
        this.id = alertId;
        this.code = code;
        this.params = params;
    }
    
    public static List<Alert> getContactPPAlerts(Id contactId,String userMode) {
        List<Alert> resultList = new List<Alert>();
        Contact myContact = AccountSettingsController.getCurrentContact(); 
        
        List<Alert__c> dbAlerts = new List<Alert__c>();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        
        /// For Delegate self view or Participant Alumini Case or Participant Pre Trail Case(REFERRAL)
        if(myContact.userCommunityDelegateId__c == null && participantState.value != ParticipantService.ParticipantStates.PARTICIPANT){
            dbAlerts = [
                SELECT Id, Record_ID__c, Alert_Code__c, Contact__r.Name,Viewed__c
                FROM Alert__c
                WHERE Contact__c = :contactId AND Viewed__c = FALSE AND Is_Platform_Level__c = true
                ORDER BY CreatedDate ASC
            ]; 
        }
        // For participant View
        else if(myContact.userCommunityDelegateId__c == null && participantState.value == ParticipantService.ParticipantStates.PARTICIPANT){
            dbAlerts = [
                SELECT Id, Record_ID__c, Alert_Code__c, Contact__r.Name,Viewed__c
                FROM Alert__c
                WHERE Contact__c = :contactId AND Viewed__c = FALSE AND  (Record_ID__c =: participantState.pe.Id or Is_Platform_Level__c = true)
                ORDER BY CreatedDate ASC
            ];
        }
        /// Delegate switching to Participant View // is delegate == true //&& participantState.value == ParticipantService.ParticipantStates.ALUMNI
        else if(myContact.userCommunityDelegateId__c != null ){
            dbAlerts = [
                SELECT Id, Record_ID__c, Alert_Code__c, Contact__r.Name,Viewed__c
                FROM Alert__c
                WHERE Contact__c = :contactId AND Viewed__c = FALSE AND  Record_ID__c =: myContact.Current_Participant_Enrollment__c
                ORDER BY CreatedDate ASC
            ];
        }
        resultList = getAlerts(dbAlerts,contactId,userMode);    
        
        return resultList;
    }        
    
    public static List<Alert> getAlerts(List<Alert__c> dbAlerts,Id contactId,String userMode) {
        List<Alert_Catalog__mdt> dbAlertCatalogs = [
            SELECT
            Id,
            DeveloperName,
            Title_label__c,
            Body_label__c,
            Parameters__c,
            Source_Object_Type__c
            FROM Alert_Catalog__mdt
        ];
        Map<String, Alert_Catalog__mdt> catalogMap = new Map<String, Alert_Catalog__mdt>();
        for (Alert_Catalog__mdt card : dbAlertCatalogs)
            catalogMap.put(card.DeveloperName, card);
        
        Map<String, Set<Id>> idsByObjectType = new Map<String, Set<Id>>();
        Map<String, Set<String>> fieldsByObjectType = new Map<String, Set<String>>();
        
        for (Alert__c dbAlert : dbAlerts) {
            Alert_Catalog__mdt card = catalogMap.get(dbAlert.Alert_Code__c);
            if (dbAlert.Record_ID__c != null) {
                String objectType = card.Source_Object_Type__c;
                Map<String, String> cardParametersMap = CatalogParametersHelper.getParamsMap(
                    card.Parameters__c
                );
                Set<Id> objectIds = idsByObjectType.get(objectType);
                if (objectIds == null)
                    objectIds = new Set<Id>();
                objectIds.add(dbAlert.Record_ID__c);
                idsByObjectType.put(objectType, objectIds);
                
                Set<String> objectFields = fieldsByObjectType.get(objectType);
                if (objectFields == null)
                    objectFields = new Set<String>();
                objectFields.addAll(cardParametersMap.values());
                fieldsByObjectType.put(objectType, objectFields);
            }
        }
        
        Map<Id, SObject> objectsMap = new Map<Id, SObject>();
        for (String objectType : idsByObjectType.keySet()) {
            List<SObject> objectsList = new List<SObject>();
            objectsList = CatalogParametersHelper.queryObjects(
                objectType,
                fieldsByObjectType.get(objectType),
                idsByObjectType.get(objectType)
            );
            for (SObject sobj : objectsList)
                objectsMap.put(sobj.Id, sobj);
        }
        
        String userName = [SELECT FirstName, LastName FROM Contact WHERE Id = :contactId].LastName; //REF-3110 Updated by Sumit Surve
        //if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
        List<Participant__c> participants = [
            SELECT Id, First_Name__c,Last_Name__c
            FROM Participant__c
            WHERE Contact__c = :contactId
        ];
        if (!participants.isEmpty()){
            if(userMode == CommunityService.USER_MODE_PARTICIPANT){
                userName = participants.get(0).First_Name__c;
            }else{
                userName = participants.get(0).Last_Name__c;
            }
        }
        
        //}
        List<Alert> resultList = new List<Alert>();
        for (Alert__c dbAlert : dbAlerts) {
            Map<String, String> cardParametersValueMap = new Map<String, String>();
            Alert_Catalog__mdt card = catalogMap.get(dbAlert.Alert_Code__c);
            if (dbAlert.Record_ID__c != null) {
                SObject alertObject = objectsMap.get(dbAlert.Record_ID__c);
                if (alertObject == null)
                    throw new AlertException(
                        'Alert ' +
                        dbAlert.Name +
                        ' has wrong Record Id field: ' +
                        dbAlert.Record_ID__c
                    );
                cardParametersValueMap = CatalogParametersHelper.getParamsValueMap(
                    alertObject,
                    card.Parameters__c
                );
            }
            
            cardParametersValueMap.put(
                'CommunityWelcome',
                TranslateHelper.getLabelValue(UserContext.getTemplateProperty('CommunityWelcome'))
            );
            cardParametersValueMap.put('UserName', userName);
            resultList.add(
                new Alert(
                    CatalogParametersHelper.prepareLabel(
                        card.Title_label__c,
                        cardParametersValueMap
                    ),
                    CatalogParametersHelper.prepareLabel(
                        card.Body_label__c,
                        cardParametersValueMap
                    ),
                    dbAlert.Id,
                    card.DeveloperName,
                    cardParametersValueMap
                )
            );
        }
        return resultList;
    }
    public static List<Alert> getContactAlerts(Id contactId, String userMode) {
        List<Alert> resultList = new List<Alert>();
        List<Alert__c> dbAlerts = [
            SELECT Id, Record_ID__c, Alert_Code__c, Contact__r.Name
            FROM Alert__c
            WHERE Contact__c = :contactId AND Viewed__c = FALSE
            ORDER BY CreatedDate ASC
        ];
         
        resultList = getAlerts(dbAlerts,contactId,userMode);    
        return resultList;
    }
}