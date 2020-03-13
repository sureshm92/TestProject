/**
 * Created by AlexKetch on 4/19/2019.
 */

public with sharing class DataHandler implements PostInstallDX {

    public void onInstall() {
        this.updateUserRole();
        this.updateTherapeuticAreasRecordTypes();
    }
    private void updateUserRole() {
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'View All'];
        User currentUser = new User(Id = UserInfo.getUserId(), UserRoleId = role.Id, Country = 'Ukraine');
        update currentUser;
    }
    private void updateTherapeuticAreasRecordTypes() {
        Id recordTypeCOIId = SchemaUtil.getRecordTypeIdByName(
                'Condition_of_Interests'
                , Therapeutic_Area__c.getSObjectType());
        Id recordTypeTAIId = SchemaUtil.getRecordTypeIdByName(
                'Therapeutic_Area'
                , Therapeutic_Area__c.getSObjectType());
        Id recordType3dParty = SchemaUtil.getRecordTypeIdByName(
                'Third_Party_Condition_of_Interests'
                , Therapeutic_Area__c.getSObjectType());
        List<Therapeutic_Area__c> tas = [SELECT Id, Type__c, RecordTypeId FROM Therapeutic_Area__c];
        for (Therapeutic_Area__c ta : tas) {
            if (ta.Type__c == 'COI') {
                ta.RecordTypeId = recordTypeCOIId;
            } else if (ta.Type__c == 'TA') {
                ta.RecordTypeId = recordTypeTAIId;
            } else if (ta.Type__c == '3dPartyCOI') {
                ta.RecordTypeId = recordType3dParty;
            }
        }
        if (!tas.isEmpty()) {
            update tas;
        }

    }

}