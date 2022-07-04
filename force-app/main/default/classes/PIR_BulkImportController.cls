public without sharing class PIR_BulkImportController {
    public class StudyStudySiteWrapper {
      @AuraEnabled
      public Map<String, Id> ctpMap;
      @AuraEnabled
      public Map<Id, List<Study_Site__c>> studySiteMap;
      @AuraEnabled
      public List<Id> ctpNoAccess;
      @AuraEnabled
      public Map<Id, String> siteAccessLevels;
      @AuraEnabled
      public Map<Id, Boolean> studyToPrmoteDCT;
      @AuraEnabled
      public Map<Id, String> studyToFinalStep;
    } 
    @AuraEnabled(cacheable=true)
    public static StudyStudySiteWrapper getStudyStudySiteDetails() {
      StudyStudySiteWrapper sswrap = new StudyStudySiteWrapper();
      try {
        String sponsorName = UserContext.getCurrentUserMode()
          .template.templateName;
        String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
        List<Study_Site__c> studySiteList = getStudySiteDetails();
  
        Map<String, Id> studyMap = new Map<String, Id>();
        Map<Id, List<Study_Site__c>> studySiteMap = new Map<Id, List<Study_Site__c>>();
        for (Study_Site__c s : studySiteList) {
          if (sponsorName == janssen) {
            if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
              studyMap.put(
                s.Clinical_Trial_Profile__r.Study_Code_Name__c,
                s.Clinical_Trial_Profile__r.Id
              );
              if (!studySiteMap.containsKey(s.Clinical_Trial_Profile__r.Id)) {
                List<Study_Site__c> stList = new List<Study_Site__c>();
                stList.add(s);
                studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
              } else {
                List<Study_Site__c> stList = studySiteMap.get(
                  s.Clinical_Trial_Profile__r.Id
                );
                stList.add(s);
                studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
              }
            }
          } else {
            if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
              studyMap.put(
                s.Clinical_Trial_Profile__r.Study_Code_Name__c,
                s.Clinical_Trial_Profile__r.Id
              );
              if (!studySiteMap.containsKey(s.Clinical_Trial_Profile__r.Id)) {
                List<Study_Site__c> stList = new List<Study_Site__c>();
                stList.add(s);
                studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
              } else {
                List<Study_Site__c> stList = studySiteMap.get(
                  s.Clinical_Trial_Profile__r.Id
                );
                stList.add(s);
                studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
              }
            }
          }
        }
        Map<Id, String> piStudiesAccessLevel = new Map<Id, String>();
        List<Site_Staff__c> piStaffs = [
          SELECT
            Id,
            Study_Site__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Clinical_Trial_Profile__c,
            Delegate_Level__c,
            clinical_Trial_Profile__c,
            Site_Contact__c,
            is_Invited__c
          FROM Site_Staff__c
          WHERE
            (Site_Contact__c = :CommunityService.getUserContact().Id
            OR Study_Site__r.Principal_Investigator__c = :CommunityService.getUserContact()
              .Id)
            AND is_Invited__c = TRUE
        ];
        for (Site_Staff__c siteStaff : piStaffs) {
          if (siteStaff.Site_Contact__c == CommunityService.getUserContact().Id) {
            piStudiesAccessLevel.put(
              siteStaff.Study_Site__c,
              siteStaff.Delegate_Level__c
            );
          }
        }
        sswrap.siteAccessLevels = piStudiesAccessLevel;
        sswrap.ctpMap = studyMap;
        sswrap.studySiteMap = studySiteMap;
        sswrap.ctpNoAccess = getStudyAccess(studySiteMap.keyset());
        return sswrap;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  
    public static List<Id> getStudyAccess(Set<Id> ctpIds) {
      List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>();
      map<Id, Id> tc = new Map<Id, Id>();
      map<Id, Id> tcUsr = new Map<Id, Id>();
      List<Id> ctpNoAccess = new List<Id>();
      List<Terms_And_Conditions_Acceptance__c> termsConditions = new List<Terms_And_Conditions_Acceptance__c>();
      ctp = [
        SELECT Id, Terms_And_Conditions_ID__c
        FROM Clinical_Trial_Profile__c
        WHERE Id IN :ctpIds AND Terms_And_Conditions_ID__c != NULL
      ];
      String UserId = UserInfo.getUserId();
      //String UserId = UserContext.getUserId();
      for (Clinical_Trial_Profile__c c : ctp) {
        tc.put(c.Terms_And_Conditions_ID__c, c.Id);
      }
      termsConditions = [
        SELECT Id, Terms_And_Conditions__c, User__c
        FROM Terms_And_Conditions_Acceptance__c
        WHERE User__c = :UserId
      ];
      for (Terms_And_Conditions_Acceptance__c tca : termsConditions) {
        tcUsr.put(tca.Terms_And_Conditions__c, tca.User__c);
      }
      for (Clinical_Trial_Profile__c c : ctp) {
        if (!tcUsr.containsKey(c.Terms_And_Conditions_ID__c)) {
          ctpNoAccess.add(tc.get(c.Terms_And_Conditions_ID__c));
        }
      }
      return ctpNoAccess;
    }
    @AuraEnabled
    public static List<Study_Site__c> getStudySiteDetails() {
      Id piContactId = CommunityService.getUserContact().Id;
      List<String> acceptedSites = new List<String>();
      acceptedSites.add('Accepted');
      acceptedSites.add('Accepted (Admin)');
      List<Study_Site__c> studySiteList = [
        SELECT
          Id,
          Name,
          Site__c,
          Override_PI_Referral_Status__c,
          Site__r.Name,
          Clinical_Trial_Profile__c,
          Clinical_Trial_Profile__r.Study_Code_Name__c,
          Clinical_Trial_Profile__r.CommunityTemplate__c,
          Principal_Investigator__c
        FROM Study_Site__c
        WHERE
          Override_PI_Referral_Status__c IN :acceptedSites
          AND (Principal_Investigator__c = :piContactId
          OR ID IN :DelegateService.getDelegatedStudySiteIds())
      ];
  
      return studySiteList;
    }
  
  }