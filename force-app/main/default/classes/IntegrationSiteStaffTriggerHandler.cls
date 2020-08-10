/* 
IntegrationSiteStaffTriggerHandler
Created by Sumit Surve 
*/

public without sharing class IntegrationSiteStaffTriggerHandler {
        
    private static final List<String> SS_STATUSES_ACCEPT_REFERRALS = new List<String>{
            StudySiteService.PI_S_ACCEPTED,
            StudySiteService.PI_S_ACCEPTED_A,
            StudySiteService.PI_S_INVITATION_SENT
    };
        
    public class CheckRequiredFieldsAndUpsertSiteStaff extends TriggerHandler {
        
        public override void beforeInsert(List<SObject> newList) {
            setNewList(newList);
            checkFields();
            upsertSiteStaff();
        }
        
        private Map<String, Study_Site__c> ssByPrimaryKeyEPRMap = new Map<String, Study_Site__c>();
        private Map<String, Clinical_Trial_Profile__c> ctpByProtocolIdMap = new Map<String, Clinical_Trial_Profile__c>();
        List<Integration_Site_Staff__c> newList;
        private Map<String, Integration_Site_Staff__c> newMap = new Map<String, Integration_Site_Staff__c>();
        private Map<String, Site_Staff__c> newSiteMap = new Map<String, Site_Staff__c>();
        private List<Site_Staff__c> newLevelSiteStaffList = new List<Site_Staff__c>();
    

        private void setNewList(List<Integration_Site_Staff__c> newList){
            this.newList = newList;
            List<String> protocolIds = new List<String>();
            List<String> ssNumbersList = new List<String>();
            String studySiteNumber;
            String StudyNumber;
            String ctpAndSiteNumber;
            for (Integration_Site_Staff__c iss : newList) {
                ctpAndSiteNumber = iss.protocolId__c;
                StudyNumber =  ctpAndSiteNumber.substringBefore('_');
                studySiteNumber =  ctpAndSiteNumber.substringAfter('_');
                protocolIds.add(StudyNumber);
                ssNumbersList.add(studySiteNumber);
                newMap.put(iss.Site_Email_Key__c, iss);
            }
            //SS Map
            
            List<Study_Site__c> ssList = [
                    SELECT Id, Protocol_ID__c, Primary_Key_ePR__c, Study_Site_Number__c,
                            Override_PI_Referral_Status__c
                    FROM Study_Site__c
                    WHERE Study_Site_Number__c IN: ssNumbersList
            ];
            for (Study_Site__c ss : ssList) ssByPrimaryKeyEPRMap.put(ss.Primary_Key_ePR__c, ss);
            
            
            //CTP Map
            List<Clinical_Trial_Profile__c> ctpList = [
                    SELECT Id, Override_Recruitment_Status__c, Protocol_ID__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Protocol_ID__c IN: protocolIds
            ];
            for (Clinical_Trial_Profile__c ctp : ctpList) ctpByProtocolIdMap.put(ctp.Protocol_ID__c, ctp);
            
        }

        private void checkFields() {
            //process items:
            for (Integration_Site_Staff__c iss : newList) {
                List<String> errorsLog = new List<String>();
                //Required fields check:
                if (String.isEmpty(iss.protocolId__c)) errorsLog.add('Required field is missing: protocolId;');
                if (String.isEmpty(iss.First_Name__c)) errorsLog.add('Required field is missing: firstName__c;');
                if (String.isEmpty(iss.Last_Name__c)) errorsLog.add('Required field is missing: lastName__c;');
                if (String.isEmpty(iss.Email__c) &&
                    String.isEmpty(iss.Phone__c)) errorsLog.add('Either email or phone number must be provided;');
            
                //Check SS
                String studySiteNumber = iss.protocolId__c;
                Study_Site__c ss = ssByPrimaryKeyEPRMap.get(studySiteNumber);
                if (ss == null) {
                    errorsLog.add('Study Site: ' + studySiteNumber + ' not found;');
                } 
            }
        }
        
        private void upsertSiteStaff() {
            Map<String, Site_Staff__c> newSiteStaffMap = new Map<String, Site_Staff__c>();
            Set<String> siteNumbers = new set<String>();
            Set<String> emails = new set<String>();
            set<String> phones = new set<String>();
            for(Integration_Site_Staff__c iss : newList)
            {
                siteNumbers.add(iss.Study_Site_Number__c);
                emails.add(iss.Email__c);
                phones.add(iss.Phone__c);
            }
            
            Map<String, Study_Site__c> siteMap = new Map<String, Study_Site__c>();
            
            List<Study_Site__c> siteList = [SELECT Id, Study_Site_Number__c, Principal_Investigator__r.AccountId 
                                            FROM Study_Site__c 
                                            WHERE Study_Site_Number__c IN :siteNumbers];
            
            for(Integration_Site_Staff__c iss : newList){
                for( Study_Site__c site : siteList){
                    if(iss.Study_Site_Number__c == site.Study_Site_Number__c){
                        siteMap.put(site.Study_Site_Number__c, site);
                    }    
                }
            }
            
            List<Contact> cntList = new List<Contact>([SELECT Id, Email, Phone
                                                        FROM Contact
                                                        WHERE Email IN :emails OR Phone IN :phones]);
            
            for (Integration_Site_Staff__c iss : newList) {
                Study_Site__c ss = siteMap.get(iss.Study_Site_Number__c);
                newSiteStaffMap.put(iss.Site_Email_Key__c, convertToSiteStaff(iss, ss, cntList));
            }
                        
            //Duplicates check and upsert site staff
            SiteStaffDuplicateService duplicateService = new SiteStaffDuplicateService(newSiteStaffMap.values());
            for (Integration_Site_Staff__c iss : newList) {
                Site_Staff__c site_Staff = newSiteStaffMap.get(iss.Site_Email_Key__c);
                Site_Staff__c siteStaffDuplicate = duplicateService.findDuplicate(site_Staff);               
                if(siteStaffDuplicate != null)
                {
                    if(siteStaffDuplicate.Site_Number2__c == iss.Study_Site_Number__c)
                    {
                        String rolesStr = siteStaffDuplicate.Roles__c;
                        Set<String> roles = new Set<String>(rolesStr.split(';'));
                        String rolesStr2 = iss.Roles__c;
                        Set<String> roles2 = new Set<String>(rolesStr2.split(';'));
                        roles.addAll(roles2);
                        if(roles != null){
                            siteStaffDuplicate.Roles__c = String.join(new List<String>(roles), ';');
                            if(siteStaffDuplicate.Roles__c.contains('STUDY COORDINATOR, PRIMARY') ||
                                siteStaffDuplicate.Roles__c.contains('SUB-INVESTIGATOR') ||
                                siteStaffDuplicate.Roles__c.contains('STUDY COORDINATOR') ||
                                siteStaffDuplicate.Roles__c.contains('RECRUITMENT AND RETENTION')){
                                    siteStaffDuplicate.Delegate_Level__c = 'Level 1';
                            }else if(
                                siteStaffDuplicate.Roles__c.contains('STUDY COORDINATOR (BACK-UP)') ||
                                siteStaffDuplicate.Roles__c.contains('STUDY NURSE') ||
                                siteStaffDuplicate.Roles__c.contains('RESEARCH NURSE') ||
                                siteStaffDuplicate.Roles__c.contains('SITE ADMINISTRATOR') ||
                                siteStaffDuplicate.Roles__c.contains('RESEARCH DIRECTOR')){
                                    siteStaffDuplicate.Delegate_Level__c = 'Level 2';
                                }else{
                                    siteStaffDuplicate.Delegate_Level__c = 'Level 3';
                                } 
                            newSiteStaffMap.put(iss.Site_Email_Key__c, siteStaffDuplicate);
                        }                            
                    }
                }else if(siteStaffDuplicate == null){
                    Contact contactDuplicate = duplicateService.findDuplicateContact(site_Staff);
                    if (contactDuplicate != null) {
                            site_Staff.Site_Contact__c = contactDuplicate.Id;
                        	newSiteStaffMap.put(iss.Site_Email_Key__c, site_Staff);
                    }
                }     
            }
            upsert newSiteStaffMap.values();
        }
    }
        
    @testVisible
    private static Site_Staff__c convertToSiteStaff(Integration_Site_Staff__c iss, Study_Site__c ss, List<Contact> cList) {
       
        Contact cnt;
        List<Contact> cntList = new  List<Contact>();
        for(Contact c : cList)
        {
            cntList.add(c);
        }
        
        if(cntList.size() == 0 || cntList == Null){
            cnt = new Contact(FirstName = iss.First_Name__c,
                              LastName = iss.Last_Name__c,
                              Email = iss.Email__c,
                              Phone = iss.Phone__c,
                              AccountId = ss.Principal_Investigator__r.AccountId,
                              MailingCountryCode = iss.Address_Country__c,
                              MailingState = iss.Mailing_State__c,
                              MailingCity = iss.Mailing_City__c,
                              MailingPostalCode = iss.Zip_Postal_Code__c,
            				  userCommunityMode__c = CommunityService.USER_MODE_PI,
							  userCommunityIsDelegate__c = true);
            insert cnt;                                    
            
            //User usr = CommunityService.createUser(cnt, null, null, null);
            //insert usr;
        }
        
        Site_Staff__c newSiteStaff =  new Site_Staff__c();
        newSiteStaff.Study_Site__c =  ss.Id;
        if(cntList!= Null && cntList.size() > 0){
            newSiteStaff.Site_Contact__c = cntList[0].Id;
        }else{
            newSiteStaff.Site_Contact__c = cnt.Id;
        }    
        
        newSiteStaff.Roles__c = iss.Roles__c;
        if(newSiteStaff.Roles__c.contains('STUDY COORDINATOR, PRIMARY') ||
           newSiteStaff.Roles__c.contains('SUB-INVESTIGATOR') ||
           newSiteStaff.Roles__c.contains('STUDY COORDINATOR') ||
           newSiteStaff.Roles__c.contains('RECRUITMENT AND RETENTION')){
               newSiteStaff.Delegate_Level__c = 'Level 1';
           }else if(
               newSiteStaff.Roles__c.contains('STUDY COORDINATOR (BACK-UP)') ||
               newSiteStaff.Roles__c.contains('STUDY NURSE') ||
               newSiteStaff.Roles__c.contains('RESEARCH NURSE') ||
               newSiteStaff.Roles__c.contains('SITE ADMINISTRATOR') ||
               newSiteStaff.Roles__c.contains('RESEARCH DIRECTOR')){
               newSiteStaff.Delegate_Level__c = 'Level 2';
               }else{
                   newSiteStaff.Delegate_Level__c = 'Level 3';
               }     
        newSiteStaff.Phone__c = iss.Phone__c;
        newSiteStaff.Email__c = iss.Email__c;
        newSiteStaff.Site_Number2__c = iss.Study_Site_Number__c;        
        return newSiteStaff;
    }
    
    @testVisible
    private static Site_Staff__c createSiteStaff(Integration_Site_Staff__c iss, Site_Staff__c siteStaffDuplicate, Study_Site__c site) {
        Site_Staff__c newSiteStaff =  new Site_Staff__c();
        newSiteStaff.Study_Site__c =  site.Id;
        newSiteStaff.Site_Contact__c = siteStaffDuplicate.Site_Contact__c;
        newSiteStaff.Roles__c = iss.Roles__c;
        if(newSiteStaff.Roles__c.contains('STUDY COORDINATOR, PRIMARY') ||
           newSiteStaff.Roles__c.contains('SUB-INVESTIGATOR') ||
           newSiteStaff.Roles__c.contains('STUDY COORDINATOR') ||
           newSiteStaff.Roles__c.contains('RECRUITMENT AND RETENTION')){
               newSiteStaff.Delegate_Level__c = 'Level 1';
           }else if(
               newSiteStaff.Roles__c.contains('STUDY COORDINATOR (BACK-UP)') ||
               newSiteStaff.Roles__c.contains('STUDY NURSE') ||
               newSiteStaff.Roles__c.contains('RESEARCH NURSE') ||
               newSiteStaff.Roles__c.contains('SITE ADMINISTRATOR') ||
               newSiteStaff.Roles__c.contains('RESEARCH DIRECTOR')){
               newSiteStaff.Delegate_Level__c = 'Level 2';
               }else{
                   newSiteStaff.Delegate_Level__c = 'Level 3';
               }     
        newSiteStaff.Phone__c = iss.Phone__c;
        newSiteStaff.Email__c = iss.Email__c;
        
        return newSiteStaff;
    }    
    
    @testVisible
    private static void sendEmailNotification(Id cnt) {
        Notification__c notification = new Notification__c(
            Recipient__c = cnt,
            WhatId__c = cnt,
            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_ACCESS_LEVEL_CHANGED_TYPE
        );
        
        if (notification != null) {
            insert notification;
        }
    }
}