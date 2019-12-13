/**
 * Created by Nargiz Mamedova on 10/21/2019.
 */

public with sharing class EmptyPagePanelRemote {
    @AuraEnabled
    public static Boolean getPermission(Id ctpId, String feature){
        String viewMode = '';
        try {
            Clinical_Trial_Profile__c ctp = [
                    SELECT Id, Tasks_Are_Available__c FROM Clinical_Trial_Profile__c WHERE Id =: ctpId];
            viewMode = GetPermissions.getViewMode(feature);
            Boolean hasAccess = viewMode == 'Edit' || viewMode == 'View';
            if(feature == 'Trial_Surveys') hasAccess = hasAccess && ctp.Tasks_Are_Available__c;
            return hasAccess;
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }
}