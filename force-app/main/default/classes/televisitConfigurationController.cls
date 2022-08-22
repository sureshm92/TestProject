public without sharing class  televisitConfigurationController {
    
    @AuraEnabled
    Public static WrapperResult getinitData(String ctpId,String[] countryList,String[] vendorList,String[] studyList,String sortingOrder,string stringType){
        List<Televisit_Record_Vendor__c> trvList ;
        if(!vendorList.isEmpty()){
            trvList = [Select id,Name,Description__c,Televisit_Vendor__c from Televisit_Record_Vendor__c where ID IN:vendorList];
        }else{
            trvList = [Select id,Name,Description__c,Televisit_Vendor__c from Televisit_Record_Vendor__c];
        }
        
        String query = 'select id,First_Reminder__c,Second_Reminder__c,Banner_Display_Offset_Time__c,Banner_Dispose_Offset_Time__c,name,Study_Site_Number__c,Site__r.BillingCountry,(select id,Study_Site__c,name,By_Country__c,isEnable__c,Televisit_Record_Vendor__r.name,Televisit_Record_Vendor__r.Televisit_Vendor__c from TelevisitVendorSettings__r),Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c from Study_Site__c where Clinical_Trial_Profile__c =:ctpId';
        if(!countryList.isEmpty()){
            query += ' and Site__r.BillingCountry IN:countryList';
        }
        if(!studyList.isEmpty()){
            query += ' and ID IN:studyList';
        }
        if(stringType != 'StudySite'){
            query += ' order by Site__r.BillingCountry ' + sortingOrder ;
        }else{
            query += ' order by Name ' + sortingOrder ;
        }
        List<Study_Site__c> studysiteList = database.query(query);
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Study_Site__c.Banner_Display_Offset_Time__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        
        List<ResponeWrapper> rw = new list<ResponeWrapper>();
        Map<id,map<id,boolean>> mapwithstudysiteandtvs = new Map<id,map<id,boolean>>();
        List<TelevisitVendorSettings__c> tvslist = new list<TelevisitVendorSettings__c>();
        for(Study_Site__c site:studysiteList){
            tvslist.addall(site.TelevisitVendorSettings__r);
        }
        
        for(TelevisitVendorSettings__c tvs:tvslist){            
            if(mapwithstudysiteandtvs.containsKey(tvs.Study_Site__c)) {
                mapwithstudysiteandtvs.get(tvs.Study_Site__c).putall(new map<id,boolean> {tvs.Televisit_Record_Vendor__c => tvs.isEnable__c});
            } else {
                mapwithstudysiteandtvs.put(tvs.Study_Site__c,new map<id,boolean> {tvs.Televisit_Record_Vendor__c => tvs.isEnable__c});
            }
        }
        
        for(Study_Site__c ss:studysiteList){
            ResponeWrapper wrap = new ResponeWrapper();
            wrap.studysitecountry = ss.Site__r.BillingCountry;
            wrap.studysitename = ss.Name;
            wrap.studysitenumber = ss.Study_Site_Number__c;
            wrap.studysiteid = ss.id;
            wrap.studysiteurl = '/'+ss.id;
            wrap.bannerdisplayoffsettime = ss.Banner_Display_Offset_Time__c;
            wrap.bannerdisposeoffsettime = ss.Banner_Dispose_Offset_Time__c;
            wrap.FirstReminder = String.valueof(ss.First_Reminder__c);
            wrap.SecondReminder = String.valueof(ss.Second_Reminder__c);
            wrap.FirstKey = 'First'+ss.id;
            wrap.SecondKey = 'Second'+ss.id;
            List<vendorwrapper> vwlist = new List<vendorwrapper>();
            for(Televisit_Record_Vendor__c trv:trvList){
                vendorwrapper vw = new vendorwrapper();
                vw.vendorId = trv.Id;
                vw.uniquekey = ss.id+'-'+trv.Id;
                if(mapwithstudysiteandtvs != null && mapwithstudysiteandtvs.get(ss.id) != null){
                    set<Id> venderset = mapwithstudysiteandtvs.get(ss.id).keyset();
                    List<Id> idLIst = new  List<Id>(venderset);
                    vw.isEnable = idLIst.contains(trv.id) ? mapwithstudysiteandtvs.get(ss.id).get(trv.id) : false;
                }else{
                    vw.isEnable = false;
                }
                vwlist.add(vw);
            }
            wrap.vendorrapperlist = vwlist;
            rw.add(wrap);
        }
        WrapperResult wr = new WrapperResult();
        wr.trvList = trvList;
        wr.ResponeWrapperList = rw;
        wr.studysiteList = studysiteList;
        wr.picklistvalues = pickListValuesList;
        if(!studysiteList.isempty()){
            wr.televisitpermissioncheck = studysiteList[0].Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c;
        }else{
            wr.televisitpermissioncheck = false;
        }
        return wr;
    }
    
    @AuraEnabled
    public static string createtelevisitvendorrecord(string name , String description,String vendorId){
        Televisit_Record_Vendor__c Televisit = new Televisit_Record_Vendor__c();
        Televisit.name = name;
        Televisit.Description__c = description;
        List<Televisit_Record_Vendor__c> trvList = [select id,Description__c,name from Televisit_Record_Vendor__c where name=:name.trim()];
        if(trvList.isempty() && (vendorId == null || vendorId == '')){
            try{
                    insert Televisit;
                    return '';
                }catch(exception e){
                    return e.getMessage();
                }

        }else if( vendorId != null  && vendorId != '' && (trvList.isEmpty() || 
                (!trvList.isEmpty() &&  trvList[0].Description__c !=description.trim() && vendorId == trvList[0].Id) )){
            Televisit.Id = vendorId;
            try{
                update Televisit;
                return '';
            }catch(exception e){
                return e.getMessage();
            }
            
        }else if(!trvList.isEmpty() && trvList[0].name == name.trim()){
            return 'Already exists the vendor which you are trying to add.';
        }
        return '';
    }
    @AuraEnabled
    public static void createorupdatetvsrecord(Id studyId , Id vendorId,Boolean isEnable){
        List<TelevisitVendorSettings__c> tvsList = [Select id,Study_Site__c,Televisit_Record_Vendor__c from TelevisitVendorSettings__c where
                                                    Study_Site__c =:studyId and Televisit_Record_Vendor__c =:vendorId];
        if(tvsList != null && tvsList.size() > 0){
            tvsList[0].isEnable__c = isEnable;
            try{
                update tvsList;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
            
        }else if(isEnable){
            TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c();
            tvs.Study_Site__c = studyId;
            tvs.Televisit_Record_Vendor__c = vendorId;
            tvs.isEnable__c = true;
            try{
                insert tvs;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
            
        }
        
    }
    
    @AuraEnabled
    public static void selectallstudysites(String vendorId,String ctpId,string respwrapper){
        list<ResponeWrapper> respwrapperlist = (List<ResponeWrapper> )JSON.deserialize(respwrapper, List<ResponeWrapper>.class);
        Set<Id> studyidSet = new Set<Id>();
        List<Id> existstudyidSet = new List<Id>();
        Set<Id> toselectstudyIds = new Set<Id>();
        for(ResponeWrapper rw:respwrapperlist){
            toselectstudyIds.add(rw.studysiteid);
        }
        List<TelevisitVendorSettings__c> toupsert = new List<TelevisitVendorSettings__c>();
        Map<Id,List<TelevisitVendorSettings__c>> tvsmap = new Map<Id,List<TelevisitVendorSettings__c>>();
        List<Study_Site__c> studysiteList = [select id,name,Study_Site_Number__c,Site__r.BillingCountry,(select id,name,By_Country__c,Study_Site__c,isEnable__c,Televisit_Record_Vendor__r.name,Televisit_Record_Vendor__r.Televisit_Vendor__c from TelevisitVendorSettings__r where Televisit_Record_Vendor__c =:vendorId) from Study_Site__c where Clinical_Trial_Profile__c =:ctpId and Id IN:toselectstudyIds];
        for(Study_Site__c s:studysiteList){
            studyidSet.add(s.id);
            tvsmap.put(s.Id,s.TelevisitVendorSettings__r);
        }
        for(List<TelevisitVendorSettings__c> lst:tvsmap.values()){
            if(lst != null && lst.size()>0 && lst[0].isEnable__c){
                existstudyidSet.add(lst[0].Study_Site__c);
            }else if(lst != null && lst.size()>0){
                existstudyidSet.add(lst[0].Study_Site__c);
                TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c();
                tvs.id =  lst[0].Id;
                tvs.isEnable__c = true;
                toupsert.add(tvs);
            }
            
        }
        for(Id i:studyidSet){
            if(!existstudyidSet.contains(i)){
                TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c();
                tvs.isEnable__c = true;
                tvs.Study_Site__c = i;
                tvs.Televisit_Record_Vendor__c = vendorId;
                toupsert.add(tvs);
            }
            
        }
        
        if(toupsert != null && toupsert.size()>0){
            
            try{
                upsert toupsert;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
        }
        
    }
    @AuraEnabled
    public static void deselectallstudysites(Id vendorId,Id ctpId,string respwrapper){
        list<ResponeWrapper> respwrapperlist = (List<ResponeWrapper> )JSON.deserialize(respwrapper, List<ResponeWrapper>.class);
        Set<Id> toselectstudyIds = new Set<Id>();
        for(ResponeWrapper rw:respwrapperlist){
            toselectstudyIds.add(rw.studysiteid);
        }
        List<TelevisitVendorSettings__c> toupsert = new List<TelevisitVendorSettings__c>();
        Map<Id,List<TelevisitVendorSettings__c>> tvsmap = new Map<Id,List<TelevisitVendorSettings__c>>();
        List<Study_Site__c> studysiteList = [select id,name,Study_Site_Number__c,Site__r.BillingCountry,(select id,name,By_Country__c,Study_Site__c,isEnable__c,Televisit_Record_Vendor__r.name,Televisit_Record_Vendor__r.Televisit_Vendor__c from TelevisitVendorSettings__r where Televisit_Record_Vendor__c =:vendorId) from Study_Site__c where Clinical_Trial_Profile__c =:ctpId and Id IN:toselectstudyIds];
        for(Study_Site__c s:studysiteList){
            tvsmap.put(s.Id,s.TelevisitVendorSettings__r);
        }
        for(List<TelevisitVendorSettings__c> lst:tvsmap.values()){
            if(lst != null && lst.size()>0 ){
                TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c();
                tvs.id =  lst[0].Id;
                tvs.isEnable__c = false;
                toupsert.add(tvs);
            }
            
        }
        if(toupsert != null && toupsert.size()>0){
            
            try{
                upsert toupsert;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
        }
    }
    @AuraEnabled
    public static void  deleteVendor( string vendorId ){
        list<Televisit_Record_Vendor__c> vendorList = [select id from Televisit_Record_Vendor__c where ID=:vendorId];
        if(!vendorList.isEmpty()){
            
            try{
                delete vendorList;
            }catch(exception e){
                system.debug('==================>'+e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static void updatestudysite(string studysiteId,string comboboxname,string selValue){
        Study_Site__c ss = new Study_Site__c();
        ss.Id = studysiteId;
        if(comboboxname == 'displyoffsettime'){
            ss.Banner_Display_Offset_Time__c = selValue;
            
        }else{
            ss.Banner_Dispose_Offset_Time__c = selValue;
            
        }
        
        try{
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
            update ss;
        }catch(exception e){
            system.debug('==================>'+e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateremindervalues(string studysiteId,string remindername,string selValue){
        Study_Site__c ss = new Study_Site__c();
        ss.Id = studysiteId;
        if(remindername == 'FirstReminder'){
            if(string.isBlank(selValue)){
                ss.First_Reminder__c = null;
            }else{
                ss.First_Reminder__c = integer.valueof(selValue);
            }
        }else{
            if(string.isBlank(selValue)){
                ss.Second_Reminder__c = null;
            }else{
                ss.Second_Reminder__c = integer.valueof(selValue);
            }
            
        }
        
        try{
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
            update ss;
        }catch(exception e){
            system.debug('==================>'+e.getMessage());
        }

    }
    public static List<Televisit_Record_Vendor__c> getVendors(String studySiteId) {
        String filter =
            'Study_Site__c =  \'' +
            studySiteId +
            '\' AND isEnable__c = TRUE' +
            ' ORDER BY Televisit_Record_Vendor__r.Name';
        List<TelevisitVendorSettings__c> vendorSettings = (List<TelevisitVendorSettings__c>) DatabaseService.query(
            new List<String>{
                'Televisit_Record_Vendor__c',
                'Televisit_Record_Vendor__r.Name',
                'Televisit_Record_Vendor__r.Televisit_Vendor__c'
            },
            TelevisitVendorSettings__c.getSObjectType(),
            filter
        );
        Set<Televisit_Record_Vendor__c> vendorsUniq = new Set<Televisit_Record_Vendor__c>();
        for (TelevisitVendorSettings__c vendorSetting : vendorSettings)
            vendorsUniq.add(vendorSetting.Televisit_Record_Vendor__r);

        List<Televisit_Record_Vendor__c> vendors = new List<Televisit_Record_Vendor__c>();
        if (!vendorsUniq.isEmpty())
            vendors.addAll(vendorsUniq);

        return vendors;
    }
    @AuraEnabled
    public static Boolean vendoravailability(String studySiteId) {
        List<TelevisitVendorSettings__c> tvsList = [Select id,Study_Site__c,isEnable__c from TelevisitVendorSettings__c where isEnable__c = true and 
        Study_Site__c =:studySiteId and Televisit_Record_Vendor__c IN (Select id from Televisit_Record_Vendor__c)];
        if(tvsList != null && !tvsList.isEmpty()){
           return true;
        }
        return false;
    }
    
    public class ResponeWrapper {
        
        @AuraEnabled public string studysitecountry;
        @AuraEnabled public string studysitename;
        @AuraEnabled public string studysitenumber;
        @AuraEnabled public string studysiteid;
        @AuraEnabled public string studysiteurl;
        @AuraEnabled public string bannerdisplayoffsettime;
        @AuraEnabled public string bannerdisposeoffsettime;
        @AuraEnabled public string FirstReminder;
        @AuraEnabled public string SecondReminder;
        @AuraEnabled public string FirstKey;
        @AuraEnabled public string SecondKey;
        @AuraEnabled public list<vendorwrapper> vendorrapperlist;
    }
    
    public class vendorwrapper{
        @AuraEnabled public string vendorId;
        @AuraEnabled public boolean isEnable;
        @AuraEnabled public string uniquekey;
    }
    
    public class WrapperResult{
        @AuraEnabled public List<Televisit_Record_Vendor__c> trvList;
        @AuraEnabled public List<ResponeWrapper> ResponeWrapperList;
        @AuraEnabled public List<Study_Site__c> studysiteList;   
        @AuraEnabled public List<String> picklistvalues;  
        @AuraEnabled public boolean televisitpermissioncheck = false;
    }
    
}