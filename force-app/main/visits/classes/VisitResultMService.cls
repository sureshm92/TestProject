/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class VisitResultMService {

    public List<Visit_Result_GroupM__mdt> getVisitResultGroups(Boolean withTypes, String visitResultsMode) {

        String visitResultGroupsQuery =
                'SELECT Id, ' +
                        'Label, ' +
                        'Display_Order__c, ' +
                        'DeveloperName, ' +
                        'Visit_Results_Mode__c ' +
                        (withTypes ? ', (SELECT Id, Label, DeveloperName, Description_Label_Api_Name__c, Display_Order__c FROM Visit_Result_Types__r) ' : '') +
                        ' FROM Visit_Result_GroupM__mdt ' +
                        (visitResultsMode != null ? ' WHERE Visit_Results_Mode__c = \'' + visitResultsMode + '\'' : '') +
                        ' ORDER BY Visit_Results_Mode__c ASC, ' +
                        'Display_Order__c  ASC';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitResultGroupsQuery, true);
    }

    public List<Visit_Result_TypeM__mdt> getVisitResultTypes(String visitResultGroupName) {

        String visitResultTypesQuery =
                'SELECT Id, ' +
                        'Label, ' +
                        'DeveloperName, ' +
                        'Description_Label_Api_Name__c, ' +
                        'Display_Order__c ' +
                ' FROM Visit_Result_TypeM__mdt ' +
                (visitResultGroupName != null ? ' WHERE Visit_Result_Group__r.Label = \'' + visitResultGroupName + '\'' : '') +
                ' ORDER BY Display_Order__c';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitResultTypesQuery, true);
    }

    public List<Visit_Result_TypeM_Dashboard_Config__mdt> getVisitResultTypeDashboardConfigs() {

        String query = 'SELECT Id, ' +
                'Visit_Result_Type__r.DeveloperName, ' +
                'Display_Order__c, ' +
                'Dashboard_Name__c ' +
                'FROM Visit_Result_TypeM_Dashboard_Config__mdt ' +
        'WHERE Dashboard_Type__c = \'' + VisitResultsService.DASHBOARD_TYPE_HOME_PAGE + '\'' +
        'ORDER BY Display_Order__c';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(query, true);
    }

    public List<Visit_Result_Measurement_Name__mdt> getVisitResultMeasurementNames() {

        String query = 'SELECT Id, ' +
                'Display_Name__c,' +
                'Alternate_Names__c ' +
                'FROM Visit_Result_Measurement_Name__mdt ';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(query, true);
    }

    public List<String> getVisitResultGroupNames(String visitResultMode) {

        List<Visit_Result_GroupM__mdt> visitResultGroups = this.getVisitResultGroups(false, visitResultMode);
        List<String> visitResultGroupNames = new List<String>();
        for(Visit_Result_GroupM__mdt singleVisitResultGroup : visitResultGroups) {
            visitResultGroupNames.add(singleVisitResultGroup.Label);
        }
        return visitResultGroupNames;
    }
    public Map<String, String> getVisitResultsMeasurementNamesMap(){
        List<Visit_Result_Measurement_Name__mdt> visitResultMeasurementNames = this.getVisitResultMeasurementNames();
        Map<String, String> visitResultsMeasurementNamesMap = new Map<String, String>();
        for(Visit_Result_Measurement_Name__mdt vrmnSetting : visitResultMeasurementNames){
            visitResultsMeasurementNamesMap.put(vrmnSetting.Display_Name__c.toLowerCase(),vrmnSetting.Display_Name__c);
            if(vrmnSetting.Alternate_Names__c != null){
                for( String alternateName : vrmnSetting.Alternate_Names__c.split(';')){
                    visitResultsMeasurementNamesMap.put(alternateName.toLowerCase(),vrmnSetting.Display_Name__c);
                }
            }
        }
        return visitResultsMeasurementNamesMap;
    }
    public String getVisitResultModeByGroupName(String visitResultsGroupName) {
        List<Visit_Result_GroupM__mdt> visitResultGroups = [SELECT Id, Visit_Results_Mode__c FROM Visit_Result_GroupM__mdt WHERE Label=:visitResultsGroupName];
        return visitResultGroups.get(0).Visit_Results_Mode__c;
    }
}