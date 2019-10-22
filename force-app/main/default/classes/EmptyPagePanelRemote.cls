/**
 * Created by Nargiz Mamedova on 10/21/2019.
 */

public with sharing class EmptyPagePanelRemote {
    @AuraEnabled
    public static Boolean getPermission(String feature){
        String viewMode = '';
        try {
            viewMode = GetPermissions.getViewMode(feature);
            return viewMode == 'Edit' || viewMode == 'View';
        } catch (Exception e) {
            return (Boolean) AuraHelper.throwException(e);
        }
    }
}