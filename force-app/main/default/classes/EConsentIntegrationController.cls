public without sharing class EConsentIntegrationController {
   public static final String E_Consent = 'E_Consent_Sharing';
   private static final String TYPE_DISABLED = 'Disabled';
   private static final String DISABLED_MODE = 'Disabled';
   private static final String EDIT_MODE = 'Edit';
   private static final String VIEW_MODE = 'View';
   public class InitData {
        @AuraEnabled
        public String userPermission = TYPE_DISABLED;
        @AuraEnabled
        public Boolean userProfilePermission = false;
        @AuraEnabled 
        public boolean econsentpermissioncheck = false;
        @AuraEnabled 
        public Integer ssListSize=0;
    }
    @AuraEnabled
    public static InitData getPermission(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.userPermission = getViewMode(E_Consent);
             String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ssList = [Select Id,Clinical_Trial_Profile__r.E_Consent_Configuration__c from Study_Site__c where Clinical_Trial_Profile__c=:ctpId];
        initData.ssListSize = ssList.size();
        if(!ssList.isempty()){
            initData.econsentpermissioncheck = ssList[0].Clinical_Trial_Profile__r.E_Consent_Configuration__c;
        }else{
            initData.econsentpermissioncheck = false;
        }     
        if(usrProfileName == 'Business Administrator' || usrProfileName == 'System Administrator'){
            initData.userProfilePermission = true;
        }else{
            initData.userProfilePermission = false;
        }            
             return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
         }
    }
    public static String getViewMode(String feature) {
        String ppFeature = feature + '%';
        List<PermissionSetAssignment> permissionSetAssignment = [
            SELECT Id, PermissionSet.Name, PermissionSetGroupId, PermissionSetGroup.MasterLabel
            FROM PermissionSetAssignment
            WHERE
                (PermissionSet.Name LIKE :ppFeature
                OR PermissionSetGroupId != NULL)
                AND AssigneeId = :UserInfo.getUserId()
        ];

        String viewMode = DISABLED_MODE;
        if (permissionSetAssignment.isEmpty())
            return viewMode;

        Set<String> namePermissionSet = new Set<String>();
        List<Id> groupIds = new List<Id>();
        for (PermissionSetAssignment per : permissionSetAssignment) {
            if (per.PermissionSetGroupId != null) {
                groupIds.add(per.PermissionSetGroupId);
            } else {
                namePermissionSet.add(per.PermissionSet.Name);
            }
        }

        List<PermissionSetGroupComponent> permissionSetInGroups = new List<PermissionSetGroupComponent>();
        if (!groupIds.isEmpty()) {
            permissionSetInGroups = [
                SELECT PermissionSet.Name
                FROM PermissionSetGroupComponent
                WHERE PermissionSetGroupId IN :groupIds AND PermissionSet.Name LIKE :ppFeature
            ];
            for (PermissionSetGroupComponent cmp : permissionSetInGroups) {
                String permName = cmp.PermissionSet.Name;
                if (permName.contains(feature))
                    namePermissionSet.add(permName);
            }
        }

        for (String ps : namePermissionSet) {
            if (ps.endsWith(EDIT_MODE)) {
                viewMode = EDIT_MODE;
                break;
            }
            if (ps.endsWith(VIEW_MODE))
                viewMode = VIEW_MODE;
        }
        return viewMode;
    }
    @AuraEnabled
    Public static WrapperResult getinitData(
        String ctpId, String[] countryList, String[] vendorList, String[] studyList,
        String sortingOrder, String stringType
    ){
        List<E_Consent_Vendor__c> eConsentVendorList = new List<E_Consent_Vendor__c>();
        if(!vendorList.isEmpty()){

            eConsentVendorList = [
                SELECT Id, Name, Vendor_URL__c FROM E_Consent_Vendor__c WHERE Id IN :vendorList
            ];
        } else {

            eConsentVendorList = [
                SELECT Id, Name,Vendor_URL__c FROM E_Consent_Vendor__c
            ];
        }
        
        String query = 'SELECT Id, Name, Study_Site_Number__c, Site__r.BillingCountry, Clinical_Trial_Profile__r.E_Consent_Configuration__c, '
            + 'E_Consent_Vendor__c, E_Consent_Vendor__r.Name, E_Consent_Vendor__r.Vendor_URL__c '
            + 'FROM Study_Site__c WHERE Clinical_Trial_Profile__c = :ctpId';

        if(!countryList.isEmpty()){
            query += ' AND Site__r.BillingCountry IN :countryList';
        }
        if(!studyList.isEmpty()){
            query += ' AND ID IN:studyList';
        }
        if(stringType != 'StudySite'){
            query += ' ORDER BY Site__r.BillingCountry ' + sortingOrder ;
        }else{
            query += ' ORDER BY Name ' + sortingOrder ;
        }
        List<Study_Site__c> studysiteList = database.query(query);

          
        
        List<ResponeWrapper> rw = new list<ResponeWrapper>();
        
        
        for(Study_Site__c ss : studysiteList){
            ResponeWrapper wrap = new ResponeWrapper();
            wrap.studysitecountry = ss.Site__r.BillingCountry;
            wrap.studysitename = ss.Name;
            wrap.studysitenumber = ss.Study_Site_Number__c;
            wrap.studysiteid = ss.id;
            wrap.studysiteurl = '/'+ss.id;
            wrap.econsentvendorid = ss.E_Consent_Vendor__c;
            wrap.econsentvendorname = ss.E_Consent_Vendor__r.Name;
            wrap.econsentvendorurl = ss.E_Consent_Vendor__r.Vendor_URL__c;
            
            List<vendorwrapper> vwlist = new List<vendorwrapper>();
            for(E_Consent_Vendor__c eConsent: eConsentVendorList){

                vendorwrapper vw = new vendorwrapper();
                vw.vendorId = eConsent.Id;
                //vw.uniquekey = ss.id+'-'+eConsent.Id;
                vw.isEnable = String.isNotBlank(ss.E_Consent_Vendor__c) && eConsent.Id == ss.E_Consent_Vendor__c;
                vwlist.add(vw);
            }
            wrap.vendorrapperlist = vwlist;
            rw.add(wrap);
        }
        WrapperResult wr = new WrapperResult();
        wr.eConsentVendors = eConsentVendorList;
        wr.ResponeWrapperList = rw;
        wr.studysiteList = studysiteList;

        if(!studysiteList.isempty()){
            wr.econsentpermissioncheck = studysiteList[0].Clinical_Trial_Profile__r.E_Consent_Configuration__c;
        }else{
            wr.econsentpermissioncheck = false;
        }
       
        return wr;
    }

    @AuraEnabled
    public static void updateSiteConsentVendor(
        String studyId, String vendorId
    ){
        try{

            byPassStudySiteTriggersMethods();
            update new Study_Site__c(Id = studyId, E_Consent_Vendor__c = vendorId);

        }catch(exception e){
            system.debug('==================>'+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string createconsentvendor(string name,String vendorURL, String vendorId){

        List<E_Consent_Vendor__c> consentVendorList = [
            SELECT Id, Name FROM E_Consent_Vendor__c WHERE Name = :name.trim() LIMIT 1
        ];
        if(consentVendorList.isempty() && String.isBlank(vendorId)) {
            try{
                insert new E_Consent_Vendor__c(Name = name.trim(), Vendor_URL__c = vendorURL.trim());
                return '';
            }catch(exception e){
                return e.getMessage();
            }

        } else if(String.isNotBlank(vendorId) && (consentVendorList.isEmpty() 
                || (!consentVendorList.isEmpty() //&& trvList[0].Description__c !=description.trim() 
                && vendorId == consentVendorList[0].Id) )){

            try{
                update new E_Consent_Vendor__c(Id = vendorId, Name = name.trim(), Vendor_URL__c = vendorURL.trim());
                return '';
            }catch(exception e){
                return e.getMessage();
            }
            
        } else if(!consentVendorList.isEmpty() && consentVendorList[0].Name == name.trim()){
            return 'Already exists the vendor which you are trying to add.';
        }
        return '';
    }
    
    
    @AuraEnabled
    public static void selectallstudysites(String vendorId, String ctpId, String respwrapper){
        
        List<Study_Site__c> studySiteToUpdate = new List<Study_Site__c>();
        List<ResponeWrapper> respWrapperList = (List<ResponeWrapper> )JSON.deserialize(respwrapper, List<ResponeWrapper>.class);
        Set<Id> studyIdSet = new Set<Id>();
        for(ResponeWrapper rw: respWrapperList){
            studyIdSet.add(rw.studysiteid);
        }
        
        for(Study_Site__c studySite : [
            SELECT Id FROM Study_Site__c WHERE Clinical_Trial_Profile__c =:ctpId AND Id IN :studyIdSet AND E_Consent_Vendor__c != :vendorId
        ]){
            studySiteToUpdate.add(new Study_Site__c(Id = studySite.Id, E_Consent_Vendor__c = vendorId));
        }
        
        try{

            byPassStudySiteTriggersMethods();
            update studySiteToUpdate;

        } catch(exception e){

            system.debug('==================>'+e.getMessage());
        }
        
        
        
    }
    @AuraEnabled
    public static void deselectallstudysites(Id vendorId, Id ctpId, String respwrapper){
        
        List<Study_Site__c> studySiteToUpdate = new List<Study_Site__c>();
        List<ResponeWrapper> respWrapperList = (List<ResponeWrapper> )JSON.deserialize(respwrapper, List<ResponeWrapper>.class);
        Set<Id> studyIdSet = new Set<Id>();
        for(ResponeWrapper rw: respWrapperList){
            studyIdSet.add(rw.studysiteid);
        }
        
        for(Study_Site__c studySite : [
            SELECT Id FROM Study_Site__c WHERE Clinical_Trial_Profile__c =:ctpId AND Id IN :studyIdSet AND E_Consent_Vendor__c = :vendorId
        ]){
            studySiteToUpdate.add(new Study_Site__c(Id = studySite.Id, E_Consent_Vendor__c = null));
        }
        
        try{

            byPassStudySiteTriggersMethods();
            update studySiteToUpdate;
        } catch(exception e){

            system.debug('==================>'+e.getMessage());
        }

    }
    @AuraEnabled
    public static void  deleteVendor( string vendorId ){
        list<E_Consent_Vendor__c> vendorList = [select id from E_Consent_Vendor__c where ID=:vendorId];
        if(!vendorList.isEmpty()){
            
            try{
                delete vendorList;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
        }
    }
    
    

    public static void byPassStudySiteTriggersMethods() {

        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.SwitchContactUserModeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreateStatusHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class
        );
    }
    
    public class ResponeWrapper {
        
        @AuraEnabled public string studysitecountry;
        @AuraEnabled public string studysitename;
        @AuraEnabled public string studysitenumber;
        @AuraEnabled public string studysiteid;
        @AuraEnabled public string studysiteurl;
        @AuraEnabled public string econsentvendorid;
        @AuraEnabled public string econsentvendorname;
        @AuraEnabled public string econsentvendorurl;
        @AuraEnabled public list<vendorwrapper> vendorrapperlist;
    }
    
    public class vendorwrapper{
        @AuraEnabled public string vendorId;
        @AuraEnabled public boolean isEnable;

    }
    
    public class WrapperResult{
        @AuraEnabled public List<E_Consent_Vendor__c> eConsentVendors;
        @AuraEnabled public List<ResponeWrapper> ResponeWrapperList;
        @AuraEnabled public List<Study_Site__c> studysiteList;   
        @AuraEnabled public List<String> picklistvalues;  
        @AuraEnabled public boolean televisitpermissioncheck = false;
        @AuraEnabled public boolean econsentpermissioncheck = false;
        @AuraEnabled public boolean econsentprofilepermissioncheck = false;
    }
    
}