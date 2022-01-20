public without sharing class HCPInviteControllerNew {
    
    
    @AuraEnabled
    public static String checkDuplicateLead	(String strLeadId){
        List<Lead> lstLead = [SELECT ID,isconverted from Lead where Id=:strLeadId];
        if(!lstLead.isEmpty() && lstLead[0].isConverted){
            Network myNetwork = [SELECT Id FROM Network WHERE Name ='IQVIA Referral Hub' ];
            return Network.getLoginUrl(myNetwork.id);
        }    
        else
            return 'false';
    }  
    
    @AuraEnabled
    public Static PortalDetails getPortalTermsDetail()
    {
        List<Terms_And_Conditions__c> lstTC = new List<Terms_And_Conditions__c> ();
        Terms_And_Conditions__c portalTC =  TermsAndConditions.getPortalTC(true);
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='IQVIA Referral Hub' ];
        PortalDetails objPortal = new PortalDetails();
        objPortal.strCommunityDetails = Network.getLoginUrl(myNetwork.id);
        objPortal.objTerms = portalTC;
        
        return objPortal; 
    } 
    
    
    @AuraEnabled
    public static void  acceptTerms(Id userId,Id objtermId){ 
        Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c();
        tca.Accepted_Date__c = Datetime.now();
        tca.Terms_And_Conditions__c = objtermId;
        tca.User__c = userId;
        insert tca;
    }
    
    @AuraEnabled
    public static String validateAndConvertLead(String strFirstName,String strLastName,
                                                String strPostalCode,String strLeadId)
    {
        List<Lead> lstLead = new List<Lead> ();
        Id id = null;
        String strUserName='';
        List<User> userList = new List<User> ();
        
        lstLead = [SELECT Accepts_Reimbursement_for_Referral__c,Address,AnnualRevenue,City,Company,Contact_Method_Preference__c,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,Converted_to_HCP__c,Country,CountryCode,CreatedById,CreatedDate,Days_since_last_activity__c,Degrees_of_Separation__c,Degree__c,Description,Distance_Type__c,Distance__c,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Facility_Classification__c,Facility_Type_Description__c,Facility_Type__c,Fax,FirstName,GeocodeAccuracy,HasOptedOutOfEmail,HasOptedOutOfFax,HCP_Referral_Source__c,Id,IndividualId,Industry,Invited_by_PI__c,IsConverted,IsDeleted,IsUnreadByOwner,Jigsaw,JigsawContactId,Language__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastTransferDate,LastViewedDate,Latitude,LeadSource,Longitude,MasterRecordId,MiddleName,MobilePhone,Name,NumberOfEmployees,OneKey_Code__c,OneKey_ID__c,Org_ID__c,Other_Address__c,Override_Email__c,Override_Phone__c,OwnerId,PartnerAccountId,Patient_Count__c,Phone,PhotoUrl,PI_Last_Name__c,POC_Email__c,POC_First_Name__c,POC_Last_Name__c,POC_Phone__c,POC_Type_Description__c,POC_Type__c,PostalCode,Preferred_Reimbursement_Currency__c,Previous_Trial_Experience__c,Pre_Screened_and_Did_Not_Qualify_Count__c,Pre_Screened_Count__c,Project_Code__c,Protocol_Number__c,Provider_ID__c,Rating,RecordTypeId,Salutation,Specialty__c,State,StateCode,Status,Street,Study_Code_Name__c,Study_Name__c,Study_Site_Number__c,Study_Site__c,Suffix,SystemModstamp,Tax_ID__c,Title,Trials_in_Last_12_Months__c,Trials_in_Last_36_Months__c,Unqualified_Description__c,Unqualified_Reason__c,Virtual_PI_Contact__c,Website 
                   FROM Lead 
                   Where FirstName=: strFirstName
                   AND  LastName =:strLastName 
                   AND PostalCode =: strPostalCode 
                   AND id =:strLeadId 
                   AND IsConverted = false 
                   AND Status = 'New' LIMIT 1]; 
        if(lstLead.isEmpty()){  
            return 'DataNotFound';
        }
        else{
            Id ExistingContactId = Null;
            Contact ExistingCon ;
            List<HCP_Enrollment__c> lstHCPEnrollmentExisting = new  List<HCP_Enrollment__c> ();
            List<User> lstExistingUser = new List<User> ();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lstLead[0].id);
            lc.setConvertedStatus('Qualified and Send Invitation');
            ReferHealthcareProviderRemote.HealthcareProvider objHealthCare = ReferHealthcareProviderRemote.checkDuplicate(null, lstLead[0].Email, null, null, null);
            if(objHealthCare.FirstName != Null ){
                
                ExistingContactId = objHealthCare.hcpContactId;
                ExistingCon = [SELECT ID,Accountid from Contact Where id=:ExistingContactId];
                lc.setAccountId(ExistingCon.AccountId);
                lc.setContactId(ExistingCon.Id);
                lstHCPEnrollmentExisting  = [SELECT ID FROM HCP_Enrollment__c Where Study_Site__c=:lstLead[0].Study_Site__c
                                             and HCP_Contact__c=:ExistingContactId];
                lstExistingUser = [SELECT ID FROM User Where ContactId =:ExistingContactId And isActive = True];
                
            }
            
            lc.setDoNotCreateOpportunity(true);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.debug('########## ' +lcr);
            if(lcr.isSuccess()){
                List<Lead> convertedLead = [SELECT Accepts_Reimbursement_for_Referral__c,Address,AnnualRevenue,City,Company,Contact_Method_Preference__c,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,Converted_to_HCP__c,Country,CountryCode,CreatedById,CreatedDate,Days_since_last_activity__c,Degrees_of_Separation__c,Degree__c,Description,Distance_Type__c,Distance__c,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Facility_Classification__c,Facility_Type_Description__c,Facility_Type__c,Fax,FirstName,GeocodeAccuracy,HasOptedOutOfEmail,HasOptedOutOfFax,HCP_Referral_Source__c,Id,IndividualId,Industry,Invited_by_PI__c,IsConverted,IsDeleted,IsUnreadByOwner,Jigsaw,JigsawContactId,Language__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastTransferDate,LastViewedDate,Latitude,LeadSource,Longitude,MasterRecordId,MiddleName,MobilePhone,Name,NumberOfEmployees,OneKey_Code__c,OneKey_ID__c,Org_ID__c,Other_Address__c,Override_Email__c,Override_Phone__c,OwnerId,PartnerAccountId,Patient_Count__c,Phone,PhotoUrl,PI_Last_Name__c,POC_Email__c,POC_First_Name__c,POC_Last_Name__c,POC_Phone__c,POC_Type_Description__c,POC_Type__c,PostalCode,Preferred_Reimbursement_Currency__c,Previous_Trial_Experience__c,Pre_Screened_and_Did_Not_Qualify_Count__c,Pre_Screened_Count__c,Project_Code__c,Protocol_Number__c,Provider_ID__c,Rating,RecordTypeId,Salutation,Specialty__c,State,StateCode,Status,Street,Study_Code_Name__c,Study_Name__c,Study_Site_Number__c,Study_Site__c,Suffix,SystemModstamp,Tax_ID__c,Title,Trials_in_Last_12_Months__c,Trials_in_Last_36_Months__c,Unqualified_Description__c,Unqualified_Reason__c,Virtual_PI_Contact__c,Website 
                                            FROM Lead 
                                            Where Id = : lstLead[0].id];
                
                // create HCP_Enrollment__c records on lead conversion
                if(lstHCPEnrollmentExisting.isEmpty()){
                    Map<Id, HCP_Enrollment__c> leadConvertedToEnrollmentMap = LeadConversionHelper.insertEnrollments(convertedLead);
                    
                    // create contacts
                    Map<Id, Map<String, Contact>> accountPOCMap = LeadConversionHelper.getAccountPOCMap(convertedLead);
                    Map<Id, Contact> leadPOCMap = LeadConversionHelper.createContacts(convertedLead, accountPOCMap);
                    
                    // insert new Point_of_Contact__c records
                    LeadConversionHelper.insertPointOfContacts(convertedLead, leadPOCMap); 
                    
                    // update Lead with Converted_to_HCP__c lookup
                    LeadConversionHelper.updateLeadsWithHCPEnrollments(leadConvertedToEnrollmentMap);
                    
                    // get portal users
                    Id conID = convertedLead[0].ConvertedContactId; 
                    
                    System.debug('####### conId: ' + conId);
                    
                    userList = [SELECT Id,username FROM User WHERE ContactId =: conID Limit 1];
                    system.debug('>>userList>>'+userList);
                    System.debug('####### id: ' + id); 
                }
            }
            return  lstExistingUser.isEmpty() ? JSON.serialize(userList[0]) : 'UserAlreadyThere';
            // return   JSON.serialize(userList[0]) ;
        }  
    }
    
    
    
    
    @AuraEnabled 
    public static Boolean checkPassword(Id UserId, String strPass,String strCnfrmPass){

        String errorMsg1 = 'The passwords do not match';
        String errorMsg2 = 'The password you entered is too easy to guess. Enter a different one';
        String errorMsg3 = 'Your password cannot be null';
        
        
        try {
            User userVal = [SELECT ID,username, FirstName,lastname FROM user where id=:UserId];
            if(!test.isRunningTest())
                Site.validatePassword(userVal, strPass, strCnfrmPass);
            return true;
        } catch (Exception ex) {
            system.debug('>>>exception is>'+ex.getMessage());
            if (
                ex.getMessage().contains(System.Label.Pswd_Val_strng1) ||
                ex.getMessage().contains(System.Label.Pswd_Val_strng2)
            ) {
                throw new AuraHandledException(
                    System.Label.Pswd_ValidationMsg3_1 +
                    ' ' +
                    System.Label.Pswd_ValidationMsg3_2
                );
            }
            if (ex.getMessage().contains(errorMsg1)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg5);
            } else if (ex.getMessage().contains(errorMsg2)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg7);
            } else if (ex.getMessage().contains(errorMsg3)) {
                throw new AuraHandledException(System.Label.Pswd_ValidationMsg8);
            } else {
                throw new AuraHandledException(ex.getMessage() + '\n' + ex.getStackTraceString());
            }
        }
    }
    
    
    @AuraEnabled 
    public static void saveUserData(String  strUserWrapper,Boolean boolShouldUpdatePass){
        GetContactUserWrapper objContactUserWrapper = (GetContactUserWrapper)system.JSON.deserializeStrict(strUserWrapper, GetContactUserWrapper.class);
        
        contact objCon = objContactUserWrapper.objCurrentContact;
        User objUser = objContactUserWrapper.ObjCurrentUser;
        String strPasswordtoSet = objContactUserWrapper.strPassword; 
        try{
            if(boolShouldUpdatePass){
                system.setPassword(objUser.id,strPasswordtoSet);
            }
            update objCon;
            if(!test.isRunningTest())
                update objUser;
        }
        catch(Exception ex){
            String strMessage = ex.getMessage();
            strMessage = strMessage.replaceFirst('UNKNOWN_EXCEPTION','Error');
            throw new AuraHandledException(strMessage);
        }
        
    } 
    
    @AuraEnabled
    public static GetContactUserWrapper getInitUserDetails(Id userId){ 
        system.debug('>>>getuserde>>'+userId);
        try {
        GetContactUserWrapper objWrapper = new GetContactUserWrapper();
        User objUser = [SELECT ID,ContactId,LocaleSidKey,LanguageLocaleKey,TimeZoneSidKey  FROM User WHERE Id=:UserId] ;  
        
        Contact objcurentCon = [SELECT ID,MailingCountryCode,Suffix,Salutation,FirstName,LastName,Account.Name,MailingStreet,MailingCity,MailingStateCode
                                ,MailingPostalCode,Phone,Fax,Language__c,Second_Choice_Language__c,Third_Choice_Language__c
                                from Contact Where Id=: objUser.ContactId];
        
        
        List<PicklistEntry> listPLE = Translation__c.Language__c.getDescribe().getPicklistValues();
        objWrapper.optionalLanguages.add(new LabelValueItem('--' + Label.None + '--', null));
        for (PicklistEntry ple : listPLE) {
            objWrapper.languages.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            objWrapper.optionalLanguages.add(new LabelValueItem(ple.getLabel(), ple.getValue())); 
        }
        listPLE = User.Timezonesidkey.getDescribe().getPicklistValues();
        for (PicklistEntry ple : listPLE) {
            objWrapper.timezones.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        listPLE = User.LocaleSidKey.getDescribe().getPicklistValues();
        for (PicklistEntry ple : listPLE) {
            objWrapper.locales.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        objWrapper.ObjCurrentContact = objcurentCon;
        objWrapper.ObjCurrentUser = objUser;
        return objWrapper; 
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
    }
    
    public class GetContactUserWrapper{
        
        @AuraEnabled
        public List<LabelValueItem> prefixList = ParticipantService.getPrefixList();
        @AuraEnabled
        public List<LabelValueItem> countriesLVList =  CountryStateUtil.getCountries();
        @AuraEnabled
        public Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
        @AuraEnabled
        public Contact objCurrentContact; 
        @AuraEnabled
        public List<LabelValueItem> languages = new List<LabelValueItem>();
        @AuraEnabled
        public List<LabelValueItem> optionalLanguages = new List<LabelValueItem>();
        @AuraEnabled
        public List<LabelValueItem> timezones = new List<LabelValueItem>();
        @AuraEnabled
        public List<LabelValueItem> locales = new List<LabelValueItem>();
        @AuraEnabled
        public User ObjCurrentUser;
        @AuraEnabled 
        public String strPassword;
        @AuraEnabled 
        Public String  strConfrmPassword;
        
    }
    
    Public Class PortalDetails{
        @AuraEnabled 
        public String strCommunityDetails;
        @AuraEnabled
        public Terms_And_Conditions__c objTerms;
    }
    
}