/**
 * This is the main controller class for PI Revamp
 */
public without sharing class PIR_HomepageController {
  public static boolean allowSH;
  public class ListViewWrapper { //implements Comparable {
    @AuraEnabled
    public string firstName;
    @AuraEnabled
    public string initialsName;
    @AuraEnabled
    public string lastName;
    @AuraEnabled
    public string refId;
    @AuraEnabled
    public string studyName;
    @AuraEnabled
    public string siteName;
    @AuraEnabled
    public string participantPhone;
    @AuraEnabled
    public string source;
    @AuraEnabled
    public Boolean highPriority;
    @AuraEnabled
    public Boolean highRisk;
    @AuraEnabled
    public Boolean actionReq;
    @AuraEnabled
    public Boolean actionReq_Reconsent;
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public Id siteId;
    @AuraEnabled
    public Id studyId;
    @AuraEnabled
    public Decimal perCounter;
    @AuraEnabled
    public String participantId;
    @AuraEnabled
    public string status;
    @AuraEnabled
    public boolean promotetoSH;
    @AuraEnabled
    public boolean adult;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String commTemplate;
    @AuraEnabled
    public Boolean clinicalParticipantEmail;
    @AuraEnabled
    public Boolean studySiteParticipantEmail;
    @AuraEnabled
    public Boolean patientUser;
    @AuraEnabled
    public Datetime invitetoPPDate;
    @AuraEnabled
    public Boolean clinicalPPEnable;
    @AuraEnabled
    public Boolean notEligibleEmail;
    @AuraEnabled
    public Boolean permitInfo;
    @AuraEnabled
    public string studysiteType;
    @AuraEnabled
    public boolean isAllowedForSH;
    @AuraEnabled
    public String screeningId;
    @AuraEnabled
    public Boolean allowScreeningPassed;
    @AuraEnabled
    public Boolean allowFinalSuccessStatus;
    @AuraEnabled
    public Participant_Enrollment__c per;
    @AuraEnabled
    public boolean dobValid;
    @AuraEnabled
    public boolean eligibilityInvalid;
    // Implement the compareTo() method
    // public Integer compareTo(Object compareTo) {
    //   ListViewWrapper compareToP = (ListViewWrapper) compareTo;
    //   if (firstName == compareToP.firstName) {
    //     if (lastName == compareToP.lastName)
    //       return 0 * sortOrder;
    //     if (lastName > compareToP.lastName)
    //       return 1 * sortOrder;
    //     return -1 * sortOrder;
    //   } else if (firstName > compareToP.firstName)
    //     return 1 * sortOrder;
    //   return -1 * sortOrder;
    // }
  }
  //public static integer sortOrder = 1;

  public class ListViewReturnWrapper {
    @AuraEnabled
    public Integer totalRecordCount;
    @AuraEnabled
    public List<ListViewWrapper> listViewWrapper;
    @AuraEnabled
    public List<Id> studyIdlist;
    @AuraEnabled
    public List<Id> siteIdlist;
    @AuraEnabled
    public Boolean isEnablePP;
    @AuraEnabled
    public Boolean isEnableDCT;
    @AuraEnabled
    public Boolean sortInitialVisit;
    @AuraEnabled
    public PresetWrapper filterWrapper;
  }

  public class PeGetInviteWrapper {
    @AuraEnabled
    public Participant_Enrollment__c per;
    @AuraEnabled
    public Boolean isAllowedForSH;
    @AuraEnabled
    public Datetime sendToSHDate;
    @AuraEnabled
    public Boolean preScreenAccess;
    @AuraEnabled
    public PreScreenerWrapper objScreenerWrapper;
  }

  public class PreScreenerWrapper{
    @AuraEnabled
    public List<PreScreener_Survey__c> lstPrescreenerSurveyPending;
    @AuraEnabled
    public List<PreScreener_Survey__c> lstTotalSurvey;
    @AuraEnabled
    public List<PreScreener_Survey__c> lstPreScreenerCompleted;

  }

  public class PresetWrapper {
    @AuraEnabled
    public String activeInactive;
    @AuraEnabled
    public List<String> studyList;
    @AuraEnabled
    public List<String> siteList;
    @AuraEnabled
    public List<String> status;
    @AuraEnabled
    public List<String> source;
    @AuraEnabled
    public String ageTo;
    @AuraEnabled
    public String ageFrom;
    @AuraEnabled
    public List<String> ethnicityList;
    @AuraEnabled
    public String sex;
    @AuraEnabled
    public String highRisk;
    @AuraEnabled
    public Boolean highPriority;
    @AuraEnabled
    public String comorbidities;
    @AuraEnabled
    public String initialVisit;
    @AuraEnabled
    public String initialVisitStartDate;
    @AuraEnabled
    public String initialVisitEndDate;
    @AuraEnabled
    public String presetId;
    @AuraEnabled
    public String presetName;
    @AuraEnabled
    public Boolean isDefault;
    @AuraEnabled
    public Boolean isFault;
  }

  @AuraEnabled
  public static ListViewReturnWrapper getListViewData(
    Integer pageNumber,
    Integer totalCount,
    String sponsorName,
    String filterWrapper,
    Boolean isPPFiltered,
    Boolean isDCTFiltered,
    String searchString,
    String sortOn,
    Integer sortType,
    Boolean isEnabled,
    List<String> listOfIds
  ) {
    try {
      ListViewReturnWrapper listViewReturnWrapper = new ListViewReturnWrapper();
      List<String> studyIdlist = new List<String>();
      List<String> siteIdlist = new List<String>();
      List<String> selectedStatusList = new List<String>();
      List<String> sourceTypeList = new List<String>();
      List<String> ethnicityList = new List<String>();
      String ageStart;
      String ageEnd;
      String sexAtBirth;
      String highRisk;
      Boolean highPriority = false;
      String comorbidities;
      Boolean ivScheduled = null;
      String ivStartDate;
      String ivEndDate;

      if (filterWrapper != null) {
        PresetWrapper response = (PresetWrapper) JSON.deserialize(
          filterWrapper,
          PresetWrapper.class
        );
        listViewReturnWrapper.filterWrapper = response;
        studyIdlist = response.studyList;
        siteIdlist = response.siteList;
        selectedStatusList = response.status;
        sourceTypeList = response.source;
        ethnicityList = response.ethnicityList;
        ageStart = response.ageTo;
        ageEnd = response.ageFrom;
        sexAtBirth = response.sex;
        highRisk = (response.highRisk == 'true' ? 'Yes' : '');
        highPriority = response.highPriority;
        comorbidities = (response.comorbidities == 'true' ? 'Yes' : '');
        if (response.initialVisit == 'Initial Visit Scheduled') {
          ivScheduled = true;
          if (!String.isBlank(response.initialVisitStartDate)) {
            ivStartDate = response.initialVisitStartDate;
          }
          if (!String.isBlank(response.initialVisitEndDate)) {
            ivEndDate = response.initialVisitEndDate;
          }
        } else if (response.initialVisit == 'Initial Visit Not Scheduled') {
          ivScheduled = false;
        }
      }

      searchString = searchString.trim();
      String qCountString = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE ';
      String qCountStringDCT = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE ';
      String queryString =
        'SELECT ' +
        'Id,' +
        'Name,' +
        'Participant__r.First_Name__c,' +
        'Participant__r.Middle_Name__c,' +
        'Participant__r.Last_Name__c,' +
        'Participant__r.Full_Name__c,' +
        'Participant__r.Phone__c,' +
        'Clinical_Trial_Profile__r.Study_Code_Name__c,' +
        'Clinical_Trial_Profile__r.Promote_to_SH__c,' +
        'Clinical_Trial_Profile__r.Tokenization_Support__c,' +
        'Study_Site__c,' +
        'Study_Site__r.name,' +
        'Study_Site__r.Study_Site_Type__c,' +
        'Clinical_Trial_Profile__c,' +
        'Referral_Source__c,' +
        'HighRisk_Indicator__c,' +
        'High_Priority__c,' +
        'PerCounter__c,' +
        'Participant__c,' +
        'Participant__r.Adult__c,' +
        'Participant__r.Email__c,' +
        'Participant__r.Gender__c,' +
        'Clinical_Trial_Profile__r.CommunityTemplate__c,' +
        'Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,' +
        'Study_Site__r.Suppress_Participant_Emails__c,' +
        'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
        'Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,' +
        'Participant_Contact__r.Is_Patient_User_Created__c,' +
        'Invited_To_PP_Date__c,' +
        'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
        'Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c,' +
        'Participant__r.IsCountry_NOT_Eligible_for_Emails__c,' +
        'Permit_IQVIA_to_contact_about_study__c,' +
        'Participant__r.Emancipation_in_progress__c,' +
        'Participant_Status__c,' +
        'HCP__c,' +
        'HCP__r.HCP_Contact__r.Name,' +
        'PI_Contact__c,' +
        'PI_Contact__r.Name,' +
        'Source_Type__c,' +
        'Study_Hub_Log__c,' +
        'Screening_ID__c,' +
        'Re_consent__c,' +
        'Study_Site__r.E_Consent_Vendor__r.Name,' +
        'IVRS_IWRS__c,' +
        'Visit_Plan__c,' +
        'Study_Hub_Log__r.Response_Status_Code__c,' +
        'Is_Participant_DOB_Valid__c ,' +
        '(' +
        '  SELECT Id, Date__c, Non_Enrollment_Reason__c ' +
        '  FROM Participant_Enrollment_Status_History__r' +
        '  WHERE Status__c = \'Eligibility Passed\'' +
        '  ORDER BY CreatedDate DESC' +
        '  LIMIT 1' +
        ' )' +
        'FROM Participant_Enrollment__c WHERE ';
      String janssenLabel = system.Label.Janssen_Community_Template_Name;
      String filterStringPP =
        ' AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !=\'Virtual\' AND Study_Site__r.Study_Site_Type__c !=\'Hybrid\' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE' +
        ' AND Clinical_Trial_Profile__r.CommunityTemplate__c !=: janssenLabel' +
        ' AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE';

      List<String> pshStatus = new List<String>();
      for (Promote_to_SH__mdt psl : [
        SELECT DeveloperName, status__c
        FROM Promote_to_SH__mdt
      ]) {
        pshStatus.add(psl.status__c);
      }

      String filterStringDCT = ' AND Clinical_Trial_Profile__r.Promote_to_SH__c = true AND Study_Site__r.Study_Site_Type__c != \'Traditional\' AND Participant_Status__c != \'Eligibility Passed\'' +
                               ' AND Participant_Status__c IN:pshStatus '+
                               ' AND (Study_Hub_Log__c = NULL OR (Study_Hub_Log__c != null AND Study_Hub_Log__r.Response_Status_Code__c != 201))';


      // if (String.isNotBlank(searchString)) {
      //   return getSearchRecords(
      //     sponsorName,
      //     queryString,
      //     searchString,
      //     filterStringPP,
      //     pageNumber,
      //     studyIdlist,
      //     siteIdlist,
      //     sortOn,
      //     sortType,
      //     filterWrapper
      //   );
      // }


      List<String> status = selectedStatusList;
      if (status == null || status.isEmpty()) {
        status = new List<String>();
        status.add('Received');
        status.add('Pre-review Passed');
        status.add('Contact Attempted');
        status.add('Successfully Contacted');
        status.add('Screening In Progress');
        status.add('Screening In Progress - Wash Out Period');
        status.add('Screening Passed');
        status.add('Eligibility Passed');
        status.add('Ready to Screen');
        status.add('Participant No Show');
        status.add('Successfully re-engaged');
        // status.add('Randomization Success');
        // status.add('Enrollment Success');

        ageStart = '0';
        ageEnd = '150';
        //For getting Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c when coming from My Studies

        if((studyIdlist != null) && (siteIdlist != null) && (studyIdlist.size() == 1 && siteIdlist.size() == 1)){
          List<Clinical_Trial_Profile__c> ctp = [SELECT Id, Participant_Workflow_Final_Step__c  FROM Clinical_Trial_Profile__c WHERE  Id = : studyIdlist[0]];
          if(ctp[0].Participant_Workflow_Final_Step__c == 'Enrollment'){
            status.add('Enrollment Success');
          }else if(ctp[0].Participant_Workflow_Final_Step__c == 'Randomization'){
            status.add('Randomization Success');
          }
        }
      }


      String filterString =
        ' Study_Site__c IN :siteIdlist' +
        ' AND Participant_Status__c IN :status';

      //For Send to DCT
      if (selectedStatusList != null) {
        if (
          selectedStatusList.contains('Sent to DCT') &&
          !selectedStatusList.contains('Eligibility Passed') && (selectedStatusList.size() < 2)
        ) {
          Integer indx = selectedStatusList.indexOf('Sent to DCT');
          selectedStatusList.remove(indx);
          selectedStatusList.add('Eligibility Passed');
          filterString =
          filterString +
          ' AND Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = true AND Study_Site__r.Study_Site_Type__c != \'Traditional\' ';
        } else if (
          !selectedStatusList.contains('Sent to DCT') &&
          selectedStatusList.contains('Eligibility Passed') && (selectedStatusList.size() < 2)
        ) {
          filterString =
            filterString +
            ' AND ((Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = false AND Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = false) OR (Study_Site__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c = false AND Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c = true AND  Study_Site__r.Study_Site_Type__c = \'Traditional\' ))  ';
        } else if (
          selectedStatusList.contains('Sent to DCT') &&
          selectedStatusList.contains('Eligibility Passed') && (selectedStatusList.size() > 2)
        ) {
          Integer indx = selectedStatusList.indexOf('Sent to DCT');
          selectedStatusList.remove(indx);
        }

      }

      //For Source
      if (sourceTypeList != null && !sourceTypeList.isEmpty()) {
        filterString =
          filterString + ' AND Source_Type__c IN: sourceTypeList  ';
      }

      //For Age
      if (!String.isBlank(ageStart)) {
        filterString =
          filterString +
          ' AND Participant__r.Present_Age__c >=  ' +
          ageStart +
          ' ';
      }

      if (!String.isBlank(ageEnd)) {
        filterString =
          filterString +
          ' AND Participant__r.Present_Age__c <=  ' +
          ageEnd +
          ' ';
      }

      //For ethnicity

      if (ethnicityList != null && !ethnicityList.isEmpty()) {
        filterString = filterString + ' AND ( ';
        String etString = '  ';
        for (Integer j = 0; j < ethnicityList.size(); j++) {
          etString =
            etString +
            ' Participant__r.Ethnicity__c INCLUDES (\'' +
            ethnicityList[j] +
            '\') ';
          if (j != ethnicityList.size() - 1) {
            etString = etString + ' OR ';
          }
        }
        filterString = filterString + etString + ' )';
      }

      //Sex at Birth
      if (!String.isBlank(sexAtBirth)) {
        filterString =
          filterString +
          ' AND Participant__r.Gender_Technical__c = : sexAtBirth ';
      }

      //For High Risk
      if (!String.isBlank(highRisk)) {
        filterString =
          filterString + ' AND HighRisk_Indicator__c = : highRisk ';
      }

      //For High Priority
      if (highPriority != null && highPriority == true) {
        filterString = filterString + ' AND High_Priority__c = : highPriority ';
      }

      //For High comorbidities
      if (!String.isBlank(comorbidities)) {
        filterString =
          filterString + ' AND Comorbidities__c = : comorbidities ';
      }

      //For Initial Visit
      if (ivScheduled != null && ivScheduled) {
        filterString =
          filterString +
          ' AND Initial_visit_scheduled_date__c != null  ';
      }else if(ivScheduled != null && !ivScheduled){
        filterString =
          filterString +
          ' AND Initial_visit_scheduled_date__c = null  ';
      }

      //For Initial Visit Date range
      if (ivStartDate != null) {
        filterString =
          filterString +
          ' AND Initial_visit_scheduled_date__c >=  ' +
          ivStartDate +
          ' ';
      }

      if (ivEndDate != null) {
        filterString =
          filterString +
          ' AND Initial_visit_scheduled_date__c <=   ' +
          ivEndDate +
          ' ';
      }


      string sortCountQry = '';
      if (sortOn.contains('AND')) {
        sortCountQry = sortOn.split('order by')[0];
      }
      if (totalCount == -1) {
        if (
          (studyIdlist == null || studyIdlist.isEmpty()) &&
          (siteIdlist == null || siteIdlist.isEmpty())
        ) {
          studyIdlist = new List<String>();
          siteIdlist = new List<String>();
          string janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
          List<Study_Site__c> studySiteList = getStudySite();
          String firstStudy = '';
          for (Study_Site__c s : studySiteList) {
            if (sponsorName == janssen) {
              if (
                s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName
              ) {
                if(firstStudy == ''){
                  firstStudy = s.Clinical_Trial_Profile__c;
                  studyIdlist.add(s.Clinical_Trial_Profile__c);
                  if(s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Enrollment'){
                    status.add('Enrollment Success');
                  }else if(s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Randomization'){
                    status.add('Randomization Success');
                  }
                }
                if(firstStudy == s.Clinical_Trial_Profile__c){
                  siteIdlist.add(s.Id);
                }
              }
            } else {
              if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
                if(firstStudy == ''){
                  firstStudy = s.Clinical_Trial_Profile__c;
                  studyIdlist.add(s.Clinical_Trial_Profile__c);
                  if(s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Enrollment'){
                    status.add('Enrollment Success');
                  }else if(s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Randomization'){
                    status.add('Randomization Success');
                  }
                }
                if(firstStudy == s.Clinical_Trial_Profile__c){
                  siteIdlist.add(s.Id);
                }
              }
            }
          }
        } else if (
          (studyIdlist != null || !studyIdlist.isEmpty()) &&
          (siteIdlist == null || siteIdlist.isEmpty())
        ) {
          //get the study site id's for selected study
          siteIdlist = getStudySiteForaStudy(studyIdlist);
        }

        String qcString = qCountString;
        if(isEnabled){

          qcString = qcString + ' Id IN :listOfIds' ;
        }
        else if (isPPFiltered == true) {
          qcString = qcString + filterString + filterStringPP + sortCountQry;
        }else if(isDCTFiltered == true){
           qcString = qcString + filterString + filterStringDCT+ sortCountQry;
        }else {
          qcString = qcString + filterString + sortCountQry;
        }

        totalCount = Database.countQuery(qcString);
      }

      qCountString =
        qCountString +
        filterString +
        filterStringPP +
        sortCountQry;
      Integer totalCountPP = Database.countQuery(qCountString);
       qCountStringDCT =
        qCountStringDCT +
        filterString +
        filterStringDCT +
        sortCountQry;
      Integer totalCountDCT = Database.countQuery(qCountStringDCT);

      List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();
      if (String.isNotBlank(searchString)) {
        return getSearchRecords(
          sponsorName,
          queryString,
          searchString,
          filterStringPP,
          pageNumber,
          studyIdlist,
          siteIdlist,
          sortOn,
          sortType,
          filterWrapper
        );
      }
      if (pageNumber > 200 & pageNumber <= 4500) {
        Integer limitOfRecords = (pageNumber * 10);
        List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        String orderByString = sortOn + ' LIMIT :limitOfRecords ';
        if(isEnabled){
          queryString = queryString + ' Id IN :listOfIds';
        }
        else if (isPPFiltered == true) {
          queryString =
            queryString +
            filterString +
            filterStringPP +
            orderByString;
        }else if(isDCTFiltered == true){
          queryString =
            queryString +
            filterString +
            filterStringDCT+
            orderByString;
        }else {
          queryString = queryString + filterString + orderByString;
        }

        perList = Database.query(queryString);
        List<Participant_Enrollment__c> perLimitList = new List<Participant_Enrollment__c>();
        for (Integer i = (limitOfRecords - 10); i < perList.size(); i++) {
          perLimitList.add(perList[i]);
        }
        listViewWrapper = createListViewWrapper(perLimitList, studyIdlist);
        //for pages more than 200 ends
      } else {
        Integer offsetLimit = (pageNumber - 1) * 10;
        List<Participant_Enrollment__c> perList = new List<Participant_Enrollment__c>();
        String orderByString =
          //' ORDER BY PerCounter__c DESC' +
          sortOn +
          ' LIMIT 10 ' +
          ' OFFSET :offsetLimit ';
        if(isEnabled){
          queryString = queryString + ' Id IN :listOfIds';
        }
        else if (isPPFiltered == true) {
          queryString =
            queryString +
            filterString +
            filterStringPP +
            orderByString;
        }else if(isDCTFiltered == true){
            queryString =
            queryString +
            filterString +
            filterStringDCT +
            orderByString;
        }else {
          queryString = queryString + filterString + orderByString;
        }

        perList = Database.query(queryString);
        listViewWrapper = createListViewWrapper(perList, studyIdlist);
      }
      if (totalCountPP == 0) {
        listViewReturnWrapper.isEnablePP = false;
      } else {
        listViewReturnWrapper.isEnablePP = true;
      }
      if (totalCountDCT == 0) {
        listViewReturnWrapper.isEnableDCT = false;
      } else {
        listViewReturnWrapper.isEnableDCT = true;
      }

      listViewReturnWrapper.listViewWrapper = listViewWrapper;
      listViewReturnWrapper.totalRecordCount = totalCount;
      listViewReturnWrapper.studyIdlist = studyIdlist;
      listViewReturnWrapper.siteIdlist = siteIdlist;
      Integer ivStudies = [
        SELECT COUNT()
        FROM Clinical_Trial_Profile__c
        WHERE Initial_Visit_Required__c = TRUE AND id IN :studyIdlist
      ];
      listViewReturnWrapper.sortInitialVisit = (ivStudies != 0);
      // if (sortType != 0) {
      //   sortOrder = sortType;
      //   listViewReturnWrapper.listViewWrapper.sort();
      // }
      return listViewReturnWrapper;
    } catch (Exception e) {
      System.debug('e.getMessage(): ' + e.getMessage());
      System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
      throw new AuraHandledException(
        e.getMessage() +
        ' ' +
        e.getStackTraceString()
      );
    }
  }

  public static ListViewReturnWrapper getSearchRecords(
    String sponsorName,
    String queryString,
    String searchString,
    String filterStringPP,
    Integer pageNumber,
    List<String> studyIdlistParam,
    List<String> siteIdlistParam,
    String sortOn,
    Integer sortType,
    String filterWrapper
  ) {
    List<String> studyIdlist = new List<String>();
    List<String> siteIdlist = new List<String>();
    string janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
    String janssenLabel = system.Label.Janssen_Community_Template_Name;
    List<Study_Site__c> studySiteList = getStudySite();
    for (Study_Site__c s : studySiteList) {
      if (sponsorName == janssen) {
        if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
          studyIdlist.add(s.Clinical_Trial_Profile__c);
          siteIdlist.add(s.Id);
        }
      } else {
        if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
          studyIdlist.add(s.Clinical_Trial_Profile__c);
          siteIdlist.add(s.Id);
        }
      }
    }

    String filterString = ' Study_Site__c IN :siteIdlist ';
    queryString = queryString + filterString + sortOn;

    List<Participant_Enrollment__c> peList = Database.query(queryString);

    List<String> lstFieldSearch = new List<String>{
      'Participant__r.First_Name__c',
      'Participant__r.Last_Name__c',
      'Participant__r.Full_Name__c',
      'Name'
    };

    Boolean isEnablePPlocal = false;

    List<Participant_Enrollment__c> filteredPEList = new List<Participant_Enrollment__c>();
    //Filter by search string:

    for (Participant_Enrollment__c pe : peList) {
      if (!isEnablePPlocal) {
        if (
          (pe.Participant_Contact__r.Is_Patient_User_Created__c == false ||
          pe.Invited_To_PP_Date__c == null) &&
          pe.Participant__r.Email__c != null &&
          pe.Participant__r.Adult__c == true &&
          pe.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
          pe.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
          pe.Participant__r.IsCountry_NOT_Eligible_for_Emails__c == false &&
          pe.Permit_IQVIA_to_contact_about_study__c == true &&
          pe.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' &&
          pe.Study_Site__r.Suppress_Participant_Emails__c == false &&
          pe.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ==
          false &&
          pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true
        ) {
          isEnablePPlocal = true;
        }
      }

      Boolean isFound = false;
      for (String searchField : lstFieldSearch) {
        String searchFieldValue =
          SObjectHelper.getSObjectFieldValue(pe, searchField) + '';
        // for (String searchWord : searchString.split(' ')) {
        if (searchFieldValue.containsIgnoreCase(searchString)) {
          isFound = true;
          break;
        }
        // }
      }
      if (isFound)
        filteredPEList.add(pe);
    }
    peList = filteredPEList;

    List<Participant_Enrollment__c> perLimitList = new List<Participant_Enrollment__c>();
    Integer listendindex;

    if (filteredPEList.size() > pageNumber * 10) {
      listendindex = pageNumber * 10 - 1;
    } else {
      listendindex = filteredPEList.size() - 1;
    }

    for (Integer i = (pageNumber * 10 - 10); i <= listendindex; i++) {
      perLimitList.add(filteredPEList[i]);
    }
    List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();

    listViewWrapper = createListViewWrapper(perLimitList, new List<String>());

    ListViewReturnWrapper listViewReturnWrapper = new ListViewReturnWrapper();

    listViewReturnWrapper.listViewWrapper = listViewWrapper;
    listViewReturnWrapper.totalRecordCount = filteredPEList.size();
    listViewReturnWrapper.studyIdlist = studyIdlistParam;
    listViewReturnWrapper.siteIdlist = siteIdlistParam;
    listViewReturnWrapper.isEnablePP = isEnablePPlocal;
    Integer ivStudies = [
      SELECT COUNT()
      FROM Clinical_Trial_Profile__c
      WHERE Initial_Visit_Required__c = TRUE AND id IN :studyIdlist
    ];
    listViewReturnWrapper.sortInitialVisit = (ivStudies != 0);

    // if (sortType != 0) {
    //   sortOrder = sortType;
    //   listViewReturnWrapper.listViewWrapper.sort();
    // }
    ListViewReturnWrapper.filterWrapper = (PresetWrapper) JSON.deserialize(
      filterWrapper,
      PresetWrapper.class
    );
    return ListViewReturnWrapper;
  }
  //presets
  @AuraEnabled
  public static list<presetwrapper> fetchPreset() {
    set<String> studies = new set<String>();
    set<String> sites = new set<String>();
    String sponsorName = UserContext.getCurrentUserMode().template.templateName;
    String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
    for(Study_Site__c ss: getStudySite()){
      if (sponsorName == janssen) {
        if (ss.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
          studies.add(ss.Clinical_Trial_Profile__c);
          sites.add(ss.id);
        }
      } else {
        if (ss.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
          studies.add(ss.Clinical_Trial_Profile__c);
          sites.add(ss.id);
        }
      }
    }
    list<presetwrapper> pwList = new List<presetwrapper>();
    for (Preset_Filter__c pf : [
      SELECT
        id,
        AgeFrom__c,
        AgeTo__c,
        Commrbidity__c,
        Default_Preset__c,
        HighRisk__c,
        HighPriortiy__c,
        InitialVisit__c,
        InitialVisit_Schedule_StartDate__c,
        InitialVisit_Schedule_EndDate__c,
        Preset_Name__c,
        Sex__c,
        StudyActive__c,
        Ethnicity__c,
        Source__c,
        Status__c,
        StudyId__c,
        Study_Site_Id__c
      FROM Preset_Filter__c
      WHERE
        User_Preset__c = :userinfo.getUserId()
        AND Community_Name__c = :UserContext.getCurrentUserMode()
          .template.templateName
    ]) {
      presetwrapper pw = new presetwrapper();
      pw.ageFrom = pf.AgeFrom__c;
      pw.ageTo = pf.AgeTo__c;
      pw.comorbidities = pf.Commrbidity__c;
      pw.highRisk = pf.HighRisk__c;
      pw.highPriority = pf.HighPriortiy__c;
      pw.initialVisit = pf.InitialVisit__c;
      pw.initialVisitStartDate = pf.InitialVisit_Schedule_StartDate__c;
      pw.initialVisitEndDate = pf.InitialVisit_Schedule_EndDate__c;
      pw.presetName = pf.Preset_Name__c;
      pw.sex = pf.Sex__c;
      pw.activeInactive = pf.StudyActive__c;
      if (!String.isEmpty(pf.Ethnicity__c))
        pw.ethnicityList = pf.Ethnicity__c.split(';');
      pw.source = pf.Source__c?.split(';');
      pw.status = pf.Status__c?.split(';');
      pw.isDefault = pf.Default_Preset__c;
      pw.presetId = pf.id;
      pw.studyList = new list<string>();
      pw.siteList = new list<string>();
      pw.isFault = false;
      for(string s : pf.StudyId__c.split(';')){
        if(studies.contains(s)){
          pw.studyList.add(s);
        }
        else if(pf.StudyId__c.split(';').size()>1){
          pw.studyList = new list<string>();
          pw.studyList.addAll(studies);
          break;
        }
        else{
          pw.isFault = true;
        }
      }
      for(string ss : pf.Study_Site_Id__c.split(';')){
        if(sites.contains(ss)){
          pw.siteList.add(ss);
        }
        else if(pf.Study_Site_Id__c.split(';').size()>1){
          pw.siteList = new list<string>();
          pw.siteList.addAll(sites);
          break;
        }
        else{
          pw.isFault = true;
        }
      }
      if(pw.status.size() > 1){
        pw.status = getUpdatedStatusForPreset(pw.activeInactive);
      }
      pwList.add(pw);
    }

    return pwlist;
  }

  public static List<String> getUpdatedStatusForPreset (String isActive) {
    List<String> ststusList = new List<String>();
    if(isActive == 'Active'){
      ststusList.add('Received');
      ststusList.add('Pre-review Passed');
      ststusList.add('Contact Attempted');
      ststusList.add('Successfully Contacted');
      ststusList.add('Successfully re-engaged');
      ststusList.add('Screening In Progress');
      ststusList.add('Screening In Progress - Wash Out Period');
      ststusList.add('Screening Passed');
      ststusList.add('Enrollment Success');
      ststusList.add('Randomization Success');
      ststusList.add('Eligibility Passed');
      ststusList.add('Participant No Show');
      ststusList.add('Ready to Screen');
      ststusList.add('Sent To DCT');

    }else if(isActive == 'Inactive'){
      ststusList.add('Pre-review Failed');
      ststusList.add('Unable to Reach');
      ststusList.add('Contacted - Not Suitable');
      ststusList.add('Eligibility Failed');
      ststusList.add('Declined Consent');
      ststusList.add('Withdrew Consent');
      ststusList.add('Screening Failed');
      ststusList.add('Unable To Screen');
      ststusList.add('Withdrew Consent After Screening');
      ststusList.add('Enrollment Failed');
      ststusList.add('Randomization Failed');
      ststusList.add('Declined Final Consent');
    }
    return ststusList;
  }

  @AuraEnabled
  public static String deletePreset(String strPresetwrapper) {
    presetwrapper objPresetWrapper = (presetwrapper) JSON.deserialize(
      strPresetwrapper,
      presetwrapper.class
    );
    delete [
      SELECT id
      FROM Preset_Filter__c
      WHERE id = :objPresetWrapper.presetId
    ];
    if (objPresetWrapper.isDefault) {
      List<Preset_Filter__c> lstPreset = [
        SELECT id, createddate
        FROM Preset_Filter__c
        WHERE
          Community_Name__c = :UserContext.getCurrentUserMode()
            .template.templateName
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];
      if (!lstPreset.isEmpty()) {
        Preset_Filter__c objPreset = new Preset_Filter__c(
          Id = lstPreset[0].id,
          Default_Preset__c = true
        );
        update objPreset;
      }
    }
    return 'deleted';
  }
  @AuraEnabled
  public static String createPreset(String strPresetwrapper, Boolean isUpdate) {
    presetwrapper objPresetWrapper = (presetwrapper) JSON.deserialize(
      strPresetwrapper,
      presetwrapper.class
    );

    List<Preset_Filter__c> lstPresetFilter = new List<Preset_Filter__c>();
    String strStudyId = '';
    String strSiteId = '';
    String strStatus = '';
    String strSource = '';
    String strEthnicity = '';
    String comName = UserContext.getCurrentUserMode().template.templateName;
    String strPresetName = objPresetWrapper.presetName;
    ID currentUserId = UserInfo.getUserId();
    if (!isUpdate) {
      Integer intcount = [
        SELECT COUNT()
        FROM Preset_Filter__c
        WHERE User_Preset__c = :currentUserId AND Community_Name__c = :comName
      ];
      if (intcount >= 5)
        return 'limitexced';
      list<Preset_Filter__c> lstExistingPreset = new List<Preset_Filter__c>();
      lstExistingPreset = [
        SELECT ID
        FROM Preset_Filter__c
        WHERE
          Preset_Name__c = :strPresetName
          AND User_Preset__c = :currentUserId
          AND Community_Name__c = :comName
      ];
      if (!lstExistingPreset.isEmpty()) {
        return 'duplicateName';
      }
    } else {
      list<Preset_Filter__c> lstExistingPreset = new List<Preset_Filter__c>();
      lstExistingPreset = [
        SELECT ID
        FROM Preset_Filter__c
        WHERE
          Preset_Name__c = :strPresetName
          AND User_Preset__c = :currentUserId
          AND id != :objPresetWrapper.presetId
          AND Community_Name__c = :comName
      ];
      if (!lstExistingPreset.isEmpty()) {
        return 'duplicateName';
      }
    }
    strStudyId = String.join(objPresetWrapper.studyList, ';');
    //Site id list

    strSiteId = String.join(objPresetWrapper.siteList, ';');
    //Status

    strStatus = String.join(objPresetWrapper.status, ';');
    //Source

    strSource = String.join(objPresetWrapper.source, ';');
    //Ethnicity
    if (objPresetWrapper.ethnicityList != null)
      strEthnicity = String.join(objPresetWrapper.ethnicityList, ';');

    Preset_Filter__c objPreset = new Preset_Filter__c();

    objPreset.AgeFrom__c = objPresetWrapper.ageFrom;
    objPreset.AgeTo__c = objPresetWrapper.ageTo;
    objPreset.Commrbidity__c = objPresetWrapper.comorbidities;
    objPreset.Ethnicity__c = strEthnicity;
    objPreset.HighRisk__c = objPresetWrapper.highRisk;
    objPreset.HighPriortiy__c = objPresetWrapper.highPriority;
    objPreset.InitialVisit__c = objPresetWrapper.initialVisit;
    objPreset.InitialVisit_Schedule_StartDate__c = objPresetWrapper.initialVisitStartDate;
    objPreset.InitialVisit_Schedule_EndDate__c = objPresetWrapper.initialVisitEndDate;
    objPreset.Preset_Name__c = objPresetWrapper.presetName;
    objPreset.Sex__c = objPresetWrapper.sex;
    objPreset.Source__c = strSource;
    objPreset.Status__c = strStatus;
    objPreset.StudyActive__c = objPresetWrapper.activeInactive;
    objPreset.StudyId__c = strStudyId;
    objPreset.Study_Site_Id__c = strSiteId;
    objPreset.User_Preset__c = currentUserId;
    // objPreset.Default_Preset__c = true;
    objPreset.Community_Name__c = comName;
    if (String.isNotBlank(objPresetWrapper.presetId))
      objPreset.Id = objPresetWrapper.presetId;

    lstPresetFilter.add(objPreset);
    // if (!isUpdate) {
    //   for (Preset_Filter__c objPresetExist : [
    //     SELECT ID, Default_Preset__c
    //     FROM Preset_Filter__c
    //     WHERE
    //       User_Preset__c = :currentUserId
    //       AND Default_Preset__c = TRUE
    //       AND Community_Name__c = :comName
    //   ]) {
    //     objPresetExist.Default_Preset__c = false;
    //     lstPresetFilter.add(objPresetExist);
    //   }
    // }

    upsert lstPresetFilter;
    return 'success';
  }

  @AuraEnabled
  public static void setselectedFilterasDefault(String selectedPresetId) {
    boolean setNoPresetDef = selectedPresetId == 'no preset';
    if (setNoPresetDef) {
      selectedPresetId = null;
    }
    List<Preset_Filter__c> lstPresetFilterToUpdate = new List<Preset_Filter__c>();
    Id currentUserId = userinfo.getUserId();
    for (Preset_Filter__c objPresetExist : [
      SELECT ID, Default_Preset__c
      FROM Preset_Filter__c
      WHERE
        User_Preset__c = :currentUserId
        AND Default_Preset__c = TRUE
        AND ID != :selectedPresetId
        AND Community_Name__c = :UserContext.getCurrentUserMode()
          .template.templateName
    ]) {
      objPresetExist.Default_Preset__c = false;
      lstPresetFilterToUpdate.add(objPresetExist);
    }
    if (!setNoPresetDef) {
      //!lstPresetFilterToUpdate.IsEmpty()&&
      Preset_Filter__c objPresetToUpdate = new Preset_Filter__c(
        Id = selectedPresetId,
        Default_Preset__c = true
      );
      lstPresetFilterToUpdate.add(objPresetToUpdate);
    }
    if (!lstPresetFilterToUpdate.IsEmpty()) {
      update lstPresetFilterToUpdate;
    }
  }

  private static List<ListViewWrapper> createListViewWrapper(
    List<Participant_Enrollment__c> perList, List<String> studyIdlist
  ) {
    List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();
    Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlanMap = new Map<Id, List<StudySiteVisitPlan__c>>();

    if(studyIdlist != null && studyIdlist.size() == 1){

        ssVisitPlanMap = getStudySiteVisitPlansMap(getStudySiteForaStudy(studyIdlist));
    }

    for (Participant_Enrollment__c lst : perList) {
      ListViewWrapper wrap = new ListViewWrapper();
      wrap.firstName = lst.Participant__r.First_Name__c;
      wrap.lastName = lst.Participant__r.Last_Name__c;
      String initialsName = '';
      initialsName = initialsName + (lst.Participant__r.First_Name__c != null ? lst.Participant__r.First_Name__c.substring(0, 1) : '') + ' ';
      initialsName = initialsName + (lst.Participant__r.Middle_Name__c != null ? lst.Participant__r.Middle_Name__c.substring(0, 1) : '') + ' ';
      initialsName = initialsName + (lst.Participant__r.Last_Name__c != null ? lst.Participant__r.Last_Name__c.substring(0, 1) : '') + ' ';
      wrap.initialsName = initialsName.toUpperCase();
      wrap.refId = lst.Name;
      wrap.studyName = lst.Clinical_Trial_Profile__r.Study_Code_Name__c;
      wrap.siteName = lst.Study_Site__r.name;
      if (lst.Participant__r.Phone__c != null) {
        wrap.participantPhone = lst.Participant__r.Phone__c;
      } else {
        List<Patient_Delegate__c> patientDelegate = new List<Patient_Delegate__c>();
        patientDelegate = [
          SELECT
            Id,
            Primary_Delegate__c,
            Contact__c,
            Contact__r.Phone,
            Participant__c
          FROM Patient_Delegate__c
          WHERE
            Participant__c = :lst.Participant__c
            AND Primary_Delegate__c = TRUE
          LIMIT 1
        ];
        if (patientDelegate != null && !patientDelegate.isEmpty()) {
          wrap.participantPhone = patientDelegate[0].Contact__r.Phone;
        } else {
          wrap.participantPhone = '';
        }
      }
      if (lst.Referral_Source__c == System.Label.RH_HCP && lst.HCP__c != null) {
        wrap.source = lst.HCP__r.HCP_Contact__r.Name;
      } else if (
        lst.Referral_Source__c == System.Label.RH_PI &&
        lst.PI_Contact__c != null
      ) {
        wrap.source = lst.PI_Contact__r.Name;
      } else {
        wrap.source = lst.Source_Type__c;
      }
      wrap.highPriority = lst.High_Priority__c;
      wrap.highRisk = (String.isNotBlank(lst.HighRisk_Indicator__c) &&
      (lst.HighRisk_Indicator__c.toLowerCase() == 'yes' ||
      lst.HighRisk_Indicator__c == '1'));
      wrap.id = lst.Id;
      wrap.siteId = lst.Study_Site__c;
      wrap.studyId = lst.Clinical_Trial_Profile__c;
      wrap.perCounter = lst.PerCounter__c;
      if(lst.Re_consent__c == true && lst.Study_Site__r.E_Consent_Vendor__r.Name !=null && lst.Study_Site__r.E_Consent_Vendor__r.Name !='' ){
        wrap.actionReq_Reconsent=true;
      }else{
        wrap.actionReq_Reconsent=false;
      }
      wrap.actionReq = lst.Participant__r.Emancipation_in_progress__c;
      wrap.status = lst.Participant_Status__c;
      wrap.participantId = lst.Participant__c;
      wrap.promotetoSH = lst.Clinical_Trial_Profile__r.Promote_to_SH__c;
      wrap.studysiteType = lst.Study_Site__r.Study_Site_Type__c;
      wrap.isAllowedForSH = ifAllowedForSH(lst, false);
      wrap.adult = lst.Participant__r.Adult__c;
      wrap.email = lst.Participant__r.Email__c;
      wrap.commTemplate = lst.Clinical_Trial_Profile__r.CommunityTemplate__c;
      wrap.clinicalParticipantEmail = lst.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c;
      wrap.studySiteParticipantEmail = lst.Study_Site__r.Suppress_Participant_Emails__c;
      wrap.patientUser = lst.Participant_Contact__r.Is_Patient_User_Created__c;
      wrap.invitetoPPDate = lst.Invited_To_PP_Date__c;
      wrap.clinicalPPEnable = lst.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
      wrap.notEligibleEmail = lst.Participant__r.IsCountry_NOT_Eligible_for_Emails__c;
      wrap.permitInfo = lst.Permit_IQVIA_to_contact_about_study__c;
      wrap.dobValid = lst.Is_Participant_DOB_Valid__c;
      wrap.screeningId = lst.Screening_ID__c;
      wrap.allowScreeningPassed = lst.Clinical_Trial_Profile__r.Tokenization_Support__c
        ? lst.IVRS_IWRS__c != null : true;
      wrap.allowFinalSuccessStatus = (lst.Screening_ID__c != null
          && (ssVisitPlanMap.containsKey(lst.Study_Site__c) ?
            (ssVisitPlanMap.get(lst.Study_Site__c).size() > 1 ? lst.Visit_Plan__c != null : true) :  true))
        ? (lst.Clinical_Trial_Profile__r.Tokenization_Support__c ?  lst.Participant__r.Gender__c != null : true)
        : false;
      wrap.eligibilityInvalid = lst.Clinical_Trial_Profile__r.Promote_to_SH__c  && (lst.Study_Site__r.Study_Site_Type__c =='Virtual'|| lst.Study_Site__r.Study_Site_Type__c =='Hybrid') && !lst.Is_Participant_DOB_Valid__c;
      listViewWrapper.add(wrap);
    }

    return listViewWrapper;
  }

  @AuraEnabled
  public static List<Study_Site__c> getStudySite() {
    Id piContactId = CommunityService.getUserContact().Id;
    List<Study_Site__c> studySiteList = [
      SELECT
        Id,
        Name,
        Site__c,
        Override_PI_Referral_Status__c,
        Site__r.Name,
        Clinical_Trial_Profile__c,
        Clinical_Trial_Profile__r.Study_Code_Name__c,
        Clinical_Trial_Profile__r.Promote_to_SH__c,
        Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
        Clinical_Trial_Profile__r.CommunityTemplate__c,
        Principal_Investigator__c
      FROM Study_Site__c
      WHERE
        Principal_Investigator__c = :piContactId
        OR ID IN :DelegateService.getDelegatedStudySiteIds()
    ];

    return studySiteList;
  }

  public static List<String> getStudySiteForaStudy(List<String> studyIdlist) {
    List<String> siteIdList = new List<String>();
    Id piContactId = CommunityService.getUserContact().Id;
    List<Study_Site__c> studySiteList = [
      SELECT Id
      FROM Study_Site__c
      WHERE
        (Principal_Investigator__c = :piContactId
        OR ID IN :DelegateService.getDelegatedStudySiteIds())
        AND Clinical_Trial_Profile__c IN :studyIdlist
    ];

    for (Study_Site__c ss : studySiteList) {
      siteIdList.add(ss.Id);
    }

    return siteIdList;
  }

  @AuraEnabled
  public static PeGetInviteWrapper getPEData(String peId) {
    try {
      Participant_Enrollment__c pe = [
        SELECT
          Id,
          Participant__c,
          Participant__r.Adult__c,
          Participant__r.Email__c,
          Study_Site__r.Study_Site_Type__c,
          Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
          Permit_IQVIA_to_contact_about_study__c,
          Clinical_Trial_Profile__c,
          Clinical_Trial_Profile__r.Promote_to_SH__c,
          Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
          Participant_Status__c,
          Study_Site__r.Suppress_Participant_Emails__c,
          Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
          Study_Hub_Log__c,
          Study_Hub_Log__r.Response_Status_Code__c,
          Participant_Contact__c,
          Participant_Contact__r.Is_Patient_User_Created__c,
          Invited_To_PP_Date__c,
          MRR_Survey_Results_URL__c,
          Pre_screening_Status__c,
          Clinical_Trial_Profile__r.Link_to_Pre_screening__c,
          Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
          Clinical_Trial_Profile__r.CommunityTemplate__c,
          Clinical_Trial_Profile__r.Initial_Visit_Required__c,
          Status_Order__c,
          Participant__r.Full_Name__c,
          Is_Participant_DOB_Valid__c,
          (
            SELECT Id, Date__c, Non_Enrollment_Reason__c
            FROM Participant_Enrollment_Status_History__r
            WHERE Status__c = 'Eligibility Passed'
            ORDER BY CreatedDate DESC
            LIMIT 1
          )
        FROM Participant_Enrollment__c
        WHERE Id = :peId
        // WITH SECURITY_ENFORCED
      ];
      List<Site_Staff__c> piStaffs = new List<Site_Staff__c>();
      piStaffs = [
        SELECT
          Id,
          Study_Site__c,
          Study_Site__r.Principal_Investigator__c,
          Study_Site__r.Clinical_Trial_Profile__c,
          Delegate_Level__c,
          Clinical_Trial_Profile__c,
          Site_Contact__c,
          is_Invited__c
        FROM Site_Staff__c
        WHERE
          Site_Contact__c = :CommunityService.getUserContact().Id
          AND Study_Site__c = :pe.Study_Site__c
          AND is_Invited__c = TRUE
      ];
      PeGetInviteWrapper pegetwrp = new PeGetInviteWrapper();
      pegetwrp.objScreenerWrapper = getPrescrennerSurvey(pe.Clinical_Trial_Profile__c,pe.id,pe.Participant__c);
      if (!piStaffs.isEmpty()) {
        for (Site_Staff__c siteStaff : piStaffs) {
          if (siteStaff.Delegate_Level__c == 'Level 3') {
            pegetwrp.preScreenAccess = false;
          } else {
            pegetwrp.preScreenAccess = true;
          }
        }
      } else {
        pegetwrp.preScreenAccess = true;
      }
      pegetwrp.per = pe;
      pegetwrp.isAllowedForSH = ifAllowedForSH(pe, false);
      allowSH = ifAllowedForSH(pe, false);
      if (
        pe.Participant_Enrollment_Status_History__r != null &&
        !pe.Participant_Enrollment_Status_History__r.isEmpty()
      ) {
        for (
          Participant_Enrollment_Status_History__c pesh : pe.Participant_Enrollment_Status_History__r
        ) {
          pegetwrp.sendToSHDate = pesh.Date__c;
        }
      }
      return pegetwrp;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static PreScreenerWrapper getPrescrennerSurvey(String strCtpId,String strPerId, String strParticipantId){
    Set<Id> setFilledPrescreenerSurvey = new Set<Id> ();
    PreScreenerWrapper objWrapper = new PreScreenerWrapper();
    Boolean boolisComingFromEPR = false;
    for(Participant_PrescreenerResponse__c objPreScreenerResponse : [SELECT ID,PreScreener_Survey__c,MRR_EPR__c FROM Participant_PrescreenerResponse__c
                                                                      wHERE Participant_enrollment__c =:strPerId OR  Participant__c=:strParticipantId])
    {
      if(objPreScreenerResponse.MRR_EPR__c)
        boolisComingFromEPR = true;

      setFilledPrescreenerSurvey.add(objPreScreenerResponse.PreScreener_Survey__c);
    }
    List<PreScreener_Survey__c> totalScreener = new List<PreScreener_Survey__c> ();
    if(!boolisComingFromEPR){
      totalScreener = [SELECT Id,Study__c,Link_to_Pre_screening__c,MRR__c,Prescreener__c FROM PreScreener_Survey__c
                                                 Where Study__c=:strCtpId];
    }
    else {
        totalScreener = [SELECT Id,Study__c,Link_to_Pre_screening__c,MRR__c,Prescreener__c FROM PreScreener_Survey__c
                         Where Study__c=:strCtpId and MRR__c = false];
    }
    List<PreScreener_Survey__c> lstPrescreenerSurveyCompleted = [SELECT ID,Link_to_Pre_screening__c,MRR__c,Primary__c,Prescreener__c,ProviderName__c,Study__c,Survey_Name__c
                                                                  FROM PreScreener_Survey__c Where ID IN:setFilledPrescreenerSurvey];

    List<PreScreener_Survey__c> lstPrescreenerSurvey = new List<PreScreener_Survey__c> ();
    if(!boolisComingFromEPR){
     lstPrescreenerSurvey = [SELECT ID,Link_to_Pre_screening__c,MRR__c,Primary__c,Prescreener__c,ProviderName__c,Study__c,Survey_Name__c
                                                        FROM PreScreener_Survey__c Where ID NOT IN:setFilledPrescreenerSurvey
                                                        AND  Study__c=:strCtpId  order by CreatedDate asc];
    }
    else{
        lstPrescreenerSurvey = [SELECT ID,Link_to_Pre_screening__c,MRR__c,Primary__c,Prescreener__c,ProviderName__c,Study__c,Survey_Name__c
                                                        FROM PreScreener_Survey__c Where ID NOT IN:setFilledPrescreenerSurvey AND MRR__c = false
                                                        AND  Study__c=:strCtpId   order by CreatedDate asc];
    }

    objWrapper.lstPreScreenerCompleted = lstPrescreenerSurveyCompleted;
    objWrapper.lstTotalSurvey = totalScreener;
    objWrapper.lstPrescreenerSurveyPending = lstPrescreenerSurvey;

    return objWrapper;

  }

  public static Boolean ifAllowedForSH(
    Participant_Enrollment__c pe,
    Boolean eligibilityStatusPresent
  ) {
    Boolean isAllowedForSH = false;
    if (pe != null) {
      List<String> pshStatus = new List<String>();
      for (Promote_to_SH__mdt psl : [
        SELECT DeveloperName, status__c
        FROM Promote_to_SH__mdt
      ]) {
        pshStatus.add(psl.status__c);
      }
      Boolean logNotPresentOrFailed = (pe.Study_Hub_Log__c == null ||
      (pe.Study_Hub_Log__c != null &&
      pe.Study_Hub_Log__r.Response_Status_Code__c != 201));
      Boolean eligibilyPassedStatusPresent = (eligibilityStatusPresent == true)
        ? true
        : pe.Participant_Enrollment_Status_History__r != null &&
          !pe.Participant_Enrollment_Status_History__r.isEmpty();

      if (
        pe.Clinical_Trial_Profile__r.Promote_to_SH__c == true &&
        (pe.Study_Site__r.Study_Site_Type__c == 'Hybrid' ||
        pe.Study_Site__r.Study_Site_Type__c == 'Virtual') &&
        pshStatus.contains(pe.Participant_Status__c) &&
        ((pe.Participant_Status__c != 'Eligibility Passed' &&
        !eligibilyPassedStatusPresent) ||
        (pe.Participant_Status__c != 'Eligibility Passed' &&
        eligibilyPassedStatusPresent &&
        logNotPresentOrFailed))
      ) {
        isAllowedForSH = true;
      }
    }
    return isAllowedForSH;
  }

  @AuraEnabled
  public static Datetime updateParticipantDataSH(string peId) {
    try {
      List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
      for (Participant_Enrollment__c pe : [
        SELECT
          Id,
          Participant_Status__c,
          High_Priority__c,
          Initial_visit_scheduled_date__c
        FROM Participant_Enrollment__c
        WHERE Id = :peId
      ]) {
        if (pe.Initial_visit_scheduled_date__c != null) {
          pe.High_Priority__c = true;
        } else {
          pe.High_Priority__c = false;
        }

        pe.Participant_Status__c = 'Eligibility Passed';
        pe.ParticipantNoShow__c= false;
        pe.Participant_Status_Last_Changed_Date__c = DateTime.now();
        PEUpdateList.add(pe);
      }
      if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
        update PEUpdateList;
      }
      return DateTime.now();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Datetime createUserForPatientProtal(String peId) {
    try {
      Participant_Enrollment__c pe = [
        SELECT
          Id,
          Participant_Contact__c,
          Participant_Contact__r.Is_Patient_User_Created__c,
          PI_Contact__c,
          Invited_To_PP_Date__c,
          HCP_Contact__c,
          HCP_Contact_HCPEnroll__c,
          Clinical_Trial_Profile__r.CommunityTemplate__c
        FROM Participant_Enrollment__c
        WHERE Id = :peId
      ];

      if (!pe.Participant_Contact__r.Is_Patient_User_Created__c) {
        update new Contact(
          Id = pe.Participant_Contact__c,
          Consent_To_Inform_About_Study__c = true,
          Is_Patient_User_Created__c = true
        );
      }

      List<User> returnUsers = new List<User>();
      if (!pe.Participant_Contact__r.Is_Patient_User_Created__c) {
        if (pe.HCP_Contact__c == null) {
          returnUsers = ((CommunityService) ClassFactory.newInstance(
              CommunityService.class
            ))
            .createParticipantUsers(
              new Map<Id, Id>{ pe.Participant_Contact__c => pe.PI_Contact__c }
            );
        } else {
          returnUsers = ((CommunityService) ClassFactory.newInstance(
              CommunityService.class
            ))
            .createParticipantUsers(
              new Map<Id, Id>{
                pe.Participant_Contact__c => pe.HCP_Contact_HCPEnroll__c
              }
            );
        }
      }
      pe.Invited_To_PP_Date__c = DateTime.now();
      update pe;

      Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
      String permissionSetName = CommunityTemplateService.getTemplate(
          pe.Clinical_Trial_Profile__r.CommunityTemplate__c
        )
        .permissionSet;
      actionAssignContactPermissions.addPermission(
        pe.Participant_Contact__c,
        permissionSetName
      );
      if (!actionAssignContactPermissions.isEmpty()) {
        ActionExecutor.executeAsync(
          actionAssignContactPermissions,
          Datetime.now()
        );
      }
      return DateTime.now();
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }

  @AuraEnabled
  public static Map<Id, String> getStudyAccessLevelInitParent() {
    try {
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
      return piStudiesAccessLevel;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<Id, String> getStudyAccessLevel() {
    try {
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
      return piStudiesAccessLevel;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void setMRRStatus(
    String peId,
    String status,
    String surveyGizmoData
  ) {
    try {
      Participant_Enrollment__c pe = [
        SELECT
          id,
          Medical_Record_Review_Completed_Date__c,
          Medical_Record_Review_Status__c,
          MRR_Survey_Results_URL__c,
          Medical_Record_Review_Completed_by__c,
          Pre_screening_Status__c,
          Study_Site__c,
          Name,
          Participant_Status__c
        FROM Participant_Enrollment__c
        WHERE id = :peId
      ];

      pe.Medical_Record_Review_Completed_Date__c = Datetime.now();
      pe.Medical_Record_Review_Status__c = status;
      if (!Test.isRunningTest()) {
        pe.MRR_Survey_Results_URL__c = surveyGizmoData;
        pe.Medical_Record_Review_Completed_by__c = CommunityService.getUserContact()
          .Id;
      }
      if (pe.Participant_Status__c == 'Received') {
        TriggerHandlerExecutor.bypassHandler(
          ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
      }
      update pe;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }

  @AuraEnabled
  public static void setPreScreenerStatus(
    String peId,
    String status,
    String surveyGizmoData
  ) {
    try {
      Participant_Enrollment__c pe = [
        SELECT
          id,
          Pre_screening_Status__c,
          Study_Site__c,
          Name,
          Participant_Status__c
        FROM Participant_Enrollment__c
        WHERE id = :peId
      ];

      pe.Pre_Screener_Completed_Date__c = Datetime.now();
      if (!Test.isRunningTest()) {
        pe.Pre_Screener_Survey_Response__c = surveyGizmoData;
        pe.Pre_Screener_Completed_by__c = CommunityService.getUserContact().Id;
      }
      if (status == 'Pass') {
        pe.Pre_screening_Status__c = 'Pass';
      } else {
        pe.Pre_screening_Status__c = 'Fail';
      }
      IncentiveProgramService.completeIncentiveTaskCurrentContact(
        IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING,
        pe.Study_Site__c,
        pe.Name
      );
      if (pe.Participant_Status__c == 'Received') {
        TriggerHandlerExecutor.bypassHandler(
          ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
      }
      update pe;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }

  @AuraEnabled
  public static void createScreenerResponse(
    String peId,
    String status,
    String surveyGizmoData,
    String strobjScreener
  ) {

    PreScreener_Survey__c objScreener = (PreScreener_Survey__c)JSON.deserialize(strobjScreener,PreScreener_Survey__c.class);

      Participant_Enrollment__c pe = [SELECT id, Participant__c, Study_Site__c,  Name,  Participant_Status__c FROM Participant_Enrollment__c
                                       WHERE id = :peId];
      Participant_PrescreenerResponse__c objScreenerResponse = new Participant_PrescreenerResponse__c();

      objScreenerResponse.PreScreener_Survey__c = objScreener.Id;
      objScreenerResponse.Participant__c = objScreener.Study__c != null ? null : pe.Participant__c;
      objScreenerResponse.Participant_enrollment__c = objScreener.Study__c != null ? pe.id :null;
      objScreenerResponse.MRR__c = objScreener.MRR__c == true ? true : false;
      objScreenerResponse.Prescreener__c = objScreener.Prescreener__c == true ? true : false;
      objScreenerResponse.Screener_Response__c = surveyGizmoData;
      objScreenerResponse.Completed_by__c = CommunityService.getUserContact().Id;
      objScreenerResponse.Completed_Date__c = Datetime.now();
      if (status == 'Pass') {
        objScreenerResponse.Status__c = 'Pass';
      } else {
        objScreenerResponse.Status__c = 'Fail';
      }
      insert objScreenerResponse;
      IncentiveProgramService.completeIncentiveTaskCurrentContact(
        IncentiveTaskCatalog.INCENTIVE_TASK_PRE_SCREENING,
        pe.Study_Site__c,
        pe.Name
      );

  }

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

  @AuraEnabled
  public static StudyStudySiteWrapper getStudyStudySite() {
    StudyStudySiteWrapper sswrap = new StudyStudySiteWrapper();
    try {
      String sponsorName = UserContext.getCurrentUserMode()
        .template.templateName;
      String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
      List<Study_Site__c> studySiteList = getStudySite();
      Map<String, Id> studyMap = new Map<String, Id>();
      Map<Id, Boolean> studyToPrmoteDCT = new Map<Id, Boolean>();
      Map<Id, String> studyToFinalStep = new Map<Id, String>();
      Map<Id, List<Study_Site__c>> studySiteMap = new Map<Id, List<Study_Site__c>>();
      for (Study_Site__c s : studySiteList) {
        if (sponsorName == janssen) {
          if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
            studyMap.put(
              s.Clinical_Trial_Profile__r.Study_Code_Name__c,
              s.Clinical_Trial_Profile__r.Id
            );
            studyToPrmoteDCT.put(
              s.Clinical_Trial_Profile__r.Id,
              s.Clinical_Trial_Profile__r.Promote_to_SH__c
            );
            studyToFinalStep.put(
              s.Clinical_Trial_Profile__r.Id,
              s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c
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
            studyToPrmoteDCT.put(
              s.Clinical_Trial_Profile__r.Id,
              s.Clinical_Trial_Profile__r.Promote_to_SH__c
            );
            studyToFinalStep.put(
              s.Clinical_Trial_Profile__r.Id,
              s.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c
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
      sswrap.ctpMap = studyMap;
      sswrap.studyToPrmoteDCT = studyToPrmoteDCT;
      sswrap.studyToFinalStep = studyToFinalStep;
      sswrap.studySiteMap = studySiteMap;
      return sswrap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
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
  public static List<LabelValueItem> getAvailableStatuses(
    String status,
    Id StudyId,
    List<Id> SiteId
  ) {
    List<String> availableStatusLists = Label.ListView_GroupStatuses.split(',');
    List<String> availableStatusList = new List<String>();
    List<LabelValueItem> StatusList = new List<LabelValueItem>();
    String availableStatus;

    Clinical_Trial_Profile__c ctp = [
      SELECT
        Promote_to_SH__c,
        Initial_Visit_Required__c,
        Participant_Workflow_Final_Step__c,
        Final_Consent_Required__c
      FROM Clinical_Trial_Profile__c
      WHERE Id = :StudyId
    ];

      //Added for RH-6979
      List<Study_Site__c> ssList = [SELECT
                          Study_Site_Type__c
                          FROM Study_Site__c
                          WHERE Id IN: SiteId
                         ];

      //

    Boolean isPromoteToSH = ctp.Promote_to_SH__c;
    Boolean isInitialVisit = ctp.Initial_Visit_Required__c;
    String finalStep = ctp.Participant_Workflow_Final_Step__c;
    Boolean finalConsent = ctp.Final_Consent_Required__c;

    if (availableStatusLists.contains(status)) {
      for (List_View_Status__mdt lvs : [
        SELECT Managed_in_SH__c, Initial_Visit__c, Available_Statuses__c
        FROM List_View_Status__mdt
        WHERE
          Managed_in_SH__c = :isPromoteToSH
          AND Initial_Visit__c = :isInitialVisit
          AND Participant_Status__c = :status
      ]) {
        availableStatusList = lvs.Available_Statuses__c.split(',');
      }
    } else {
      for (List_View_Status__mdt lvs : [
        SELECT
          Participant_Workflow_Final_Step__c,
          Available_Statuses__c,
          Final_Consent__c
        FROM List_View_Status__mdt
        WHERE
          Participant_Workflow_Final_Step__c = :finalStep
          AND Participant_Status__c = :status
          AND Final_Consent__c = :finalConsent
      ]) {
        availableStatusList = lvs.Available_Statuses__c.split(',');
      }
    }

      if(!isInitialVisit){
          if(availableStatusList.contains('Declined Consent')){
              integer x = availableStatusList.indexOf('Declined Consent');
              availableStatusList.remove(x);
          }
      }
      //

    //StatusList.add(new LabelValueItem(Label.ListView_Select_a_Status, 'null'));
    for (String st : availableStatusList) {
      String t = st.replaceAll('[\\s\\-()]', '_');
      if (t == 'Contacted___Not_Suitable') {
        t = 'Contacted_Not_Suitable';
      }
      StatusList.add(new LabelValueItem(TranslateHelper.getLabelValue(t), st));
    }


    return StatusList;
  }
  //Getting the Reason and Notes for popup
  @AuraEnabled
  public static bulkStatusReasonWrapper bulkstatusDetail(
    String newStatus,
    Id studyId
  ) {
    bulkStatusReasonWrapper stWrap = new bulkStatusReasonWrapper();
    PIR_Participant_Workflow_Outcome__mdt pwr = new PIR_Participant_Workflow_Outcome__mdt();
    if (newStatus != 'Ready to Screen' && newStatus != 'In Wash Out Period') {
      pwr = [
        SELECT Status_Value__c, Step__c, Reasons_List__c, Order__c
        FROM PIR_Participant_Workflow_Outcome__mdt
        WHERE Status_Value__c = :newStatus limit 1
      ];
      if(pwr != null){
      stWrap.reason = pwr.Reasons_List__c;
      stWrap.Step = pwr.Step__c;
      }
    }
    Clinical_Trial_Profile__c ctp = [
      SELECT Initial_Visit_Required__c, Final_Consent_Required__c
      FROM Clinical_Trial_Profile__c
      WHERE Id = :StudyId
    ];
    stWrap.finalConsent = ctp.Final_Consent_Required__c;
    stWrap.isInitialVisit = ctp.Initial_Visit_Required__c;
    return stWrap;
  }

  public class bulkStatusReasonWrapper {
    @AuraEnabled
    public String reason;
    @AuraEnabled
    public Map<String, List<LabelValueItem>> reasonMap;
    @AuraEnabled
    public Map<String, Boolean> notesRequiredMap;
    @AuraEnabled
    public String notes;
    @AuraEnabled
    public Boolean finalConsent;
    @AuraEnabled
    public Boolean isInitialVisit;
    @AuraEnabled
    public String Step;
  }
  //Added for Bulk Action- Status Update

  @AuraEnabled
  public static void updateParticipantStatus(
    List<string> peIdList,
    String StatusToUpdate,
    String Notes,
    String reason,
    String studyId,
    String oParticipantStatus,
    Boolean finalconsent,
    Boolean consentSigned,
    Date signedDate
  ) {
    Savepoint sp = Database.setSavepoint();
    try {
      Map<String, String> initReasonMap = new Map<String, String>{
        'PIR_Other' => 'Other',
        'PWS_Picklist_Value_Other' => 'Other',
        'PIR_Call_Back' => 'Call Back',
        'PWS_Picklist_Value_Transportation_Issues' => 'Transportation Issues',
        'PWS_Picklist_Value_Childcare_Issues' => 'Childcare Issues',
        'PIR_Left_a_Message' => 'Left a Message',
        'PIR_Inadequate_Documentation' => 'Inadequate Documentation',
        'PIR_Does_Not_Meet_Eligibility_Criteria' => 'Does Not Meet Eligibility Criteria',
        'PIR_Not_Ready_to_Schedule' => 'Not Ready to Schedule',
        'PIR_Call_Back' => 'Call Back',
        'PWS_Picklist_Value_Participant_Not_Interested' => 'Participant Not Interested',
        'PIR_Declined_Practitioner' => 'Declined Practitioner',
        'PIR_PI_Decision' => 'PI Decision',
        'PIR_Didnt_Meet_Pre_Screening_Eligibility' => 'Didn\'t Meet Pre-Screening Eligibility',
        'PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria' => 'Did Not Meet Inclusion/Exclusion Criteria',
        'PIR_Did_Not_Attend_Appointment' => 'Did Not Attend Appointment',
        'PWS_Picklist_Value_Protocol_Concerns' => 'Protocol Concerns',
        'PIR_Visit_Out_Of_Window' => 'Visit Out Of Window',
        'Didnt Show For Initial Visit' => 'Didn\'t Show For Initial Visit',
        '' => ''
      };
      if (
        StatusToUpdate == 'Sent to DCT' ||
        StatusToUpdate == 'Initial Visit'
      ) {
        StatusToUpdate = 'Eligibility Passed';
      }
      if (StatusToUpdate == 'In Wash Out Period') {
        StatusToUpdate = 'Screening In Progress - Wash Out Period';
      }
      Set<Id> SSId = new Set<Id>();
      Set<Id> planIds = new Set<Id>();
      Map<ID, ID> MapSitePlan = new Map<ID, ID>();
      Map<ID, Incentive_Plan_Task__c> MapPlanTask = new Map<Id, Incentive_Plan_Task__c>();
      List<Incentive_Plan_Task__c> incentiveTasks = new List<Incentive_Plan_Task__c>();
      List<Completed_Incentive_Task__c> lstIncentiveTsk = new List<Completed_Incentive_Task__c>();
      List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();

      List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
      List<Participant_Enrollment__c> PEIncentiveList = new List<Participant_Enrollment__c>();
      List<Id> PeId = new List<Id>();
      List<Participant_Enrollment_Status_History__c> historiestoUpdate = new List<Participant_Enrollment_Status_History__c>();
      List<Participant_Enrollment_Status_History__c> peshUpdate = new List<Participant_Enrollment_Status_History__c>();

      Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlanMap = getStudySiteVisitPlansMap(
        getStudySiteForaStudy(new List<String>{studyId})
      );

      for (Participant_Enrollment__c pe : [
        SELECT
          Id,
          Name,
          Participant_Status__c,
          Study_Site__c,
          Last_Status_Changed_Notes__c,
          Non_Enrollment_Reason__c,
          Participant_Status_Last_Changed_Date__c,
          Final_consent__c,
          Non_Referral_Notes__c,
          Non_Referral_Reason__c,
          Informed_Consent__c,
          Informed_Consent_Date__c,
          Initial_visit_scheduled_time__c,
          Initial_visit_scheduled_date__c,
          Initial_visit_occurred_date__c,
          Initial_visit_occurred_flag__c,
          isBulkUpdate__c,
          ParticipantNoShow__c,
          Visit_Plan__c,
          Re_consent__c
        FROM Participant_Enrollment__c
        WHERE Id IN :peIdList
      ]) {
        pe.Participant_Status__c = StatusToUpdate;
        pe.Non_Referral_Notes__c = Notes;
        pe.Last_Status_Changed_Notes__c = Notes;
        pe.Non_Enrollment_Reason__c = initReasonMap.get(reason);
        if(StatusToUpdate == 'Declined Consent' ||
        StatusToUpdate == 'Withdrew Consent' ||
        StatusToUpdate== 'Withdrew Consent After Screening' ||
        StatusToUpdate == 'Declined Final Consent' ||
        oParticipantStatus == 'Withdrew Consent' ||
        oParticipantStatus == 'Declined Consent'
        ){
        pe.Re_consent__c=false;
        }
        if (
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_DECLINED_FINAL_CONSENT
        ) {
          pe.Final_consent__c = false;
        } else {
          pe.Final_consent__c = finalconsent;
        }
          pe.Participant_Status_Last_Changed_Date__c = system.now();
          if (consentSigned != null && signedDate != null) {
              pe.Informed_Consent__c = consentSigned;
              pe.Informed_Consent_Date__c = signedDate;
          }
          if( oParticipantStatus ==PEStatusState.PE_STATUS_DECLINED_CONSENT ||
             oParticipantStatus ==PEStatusState.PE_STATUS_WITHDREW_CONSENT){
                 pe.isBulkUpdate__c=true;
             }
          else{
              pe.isBulkUpdate__c=false;
          }

        if (
          pe.Participant_Status__c == PEStatusState.PE_STATUS_UNABLE_TO_REACH ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
          pe.Participant_Status__c == PEStatusState.PE_STATUS_PRE_REVIEW_FAILED
        ) {
          pe.Initial_visit_scheduled_date__c = null;
          pe.Initial_visit_scheduled_time__c = null;
        }

        //Patch Release Fix June
        if (
          pe.Participant_Status__c == PEStatusState.PE_STATUS_UNABLE_TO_REACH
        ) {
          pe.Initial_visit_occurred_date__c= null;
          pe.Initial_visit_occurred_flag__c= false;
        }
        if(oParticipantStatus == 'Participant No Show')
        {
           pe.ParticipantNoShow__c=false;
        }
        if(oParticipantStatus==PEStatusState.PE_STATUS_SUCCESSFULLY_REENGAGED
          && pe.Participant_Status__c==PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED)
          {
            pe.ParticipantNoShow__c=false;
          }

        if ((pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            || pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS)
          && ssVisitPlanMap.containsKey(pe.Study_Site__c) && pe.Visit_Plan__c == null
          && ssVisitPlanMap.get(pe.Study_Site__c).size() == 1) {

            pe.Visit_Plan__c = ssVisitPlanMap.get(pe.Study_Site__c)[0].Visit_Plan__c;
        }

        PEUpdateList.add(pe);
        PeId.add(pe.Id);
        if (
          pe.Participant_Status_Last_Changed_Date__c.date()
            .daysBetween(Date.today()) <= 1
        ) {
          PEIncentiveList.add(pe);
        }

        SSId.add(pe.Study_Site__c);
        //logic for ready to screen start
          if (
              (oParticipantStatus == PEStatusState.PE_STATUS_DECLINED_CONSENT ||
               oParticipantStatus == PEStatusState.PE_STATUS_WITHDREW_CONSENT) &&
              (pe.Participant_Status__c != PEStatusState.PE_STATUS_READY_TO_SCREEN &&
               StatusToUpdate != PEStatusState.PE_STATUS_DECLINED_CONSENT &&
               StatusToUpdate != PEStatusState.PE_STATUS_WITHDREW_CONSENT)
          ) {
          histories.add(
            new Participant_Enrollment_Status_History__c(
              Date__c = pe.Participant_Status_Last_Changed_Date__c,
              Status__c = PEStatusState.PE_STATUS_READY_TO_SCREEN,
              ParticipantEnrollment__c = pe.Id
            )
          );
        }
        //logic for ready to screen end
        if (
          (oParticipantStatus == PEStatusState.PE_STATUS_READY_TO_SCREEN ||
          oParticipantStatus == PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS ||
          oParticipantStatus == PEStatusState.PE_STATUS_DECLINED_CONSENT ||
          oParticipantStatus == PEStatusState.PE_STATUS_UNABLE_TO_SCREEN ||
          oParticipantStatus == PEStatusState.PE_STATUS_WITHDREW_CONSENT ||
          oParticipantStatus == PEStatusState.PE_STATUS_SCREENING_FAILED ||
          oParticipantStatus ==
          PEStatusState.PE_STATUS_SCREENING_IN_PROGRESS_WASH_OUT_PERIOD) &&
          (pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_ENROLLMENT_FAILED ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_RANDOMIZATION_FAILED ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING ||
          pe.Participant_Status__c ==
          PEStatusState.PE_STATUS_DECLINED_FINAL_CONSENT)
        ) {
          histories.add(
            new Participant_Enrollment_Status_History__c(
              Date__c = pe.Participant_Status_Last_Changed_Date__c,
              Status__c = PEStatusState.PE_STATUS_SCREENING_PASSED,
              ParticipantEnrollment__c = pe.Id
            )
          );
        }
        //Eligibility Failed Logic - To be modified for new statuses in Group 1 and 2
        if(
            (oParticipantStatus == PEStatusState.PE_STATUS_RECEIVED ||
              oParticipantStatus == PEStatusState.PE_STATUS_PRE_REVIEW_PASSED ||
              oParticipantStatus == PEStatusState.PE_STATUS_PRE_REVIEW_FAILED ||
              oParticipantStatus == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
              oParticipantStatus == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
              oParticipantStatus == PEStatusState.PE_STATUS_SUCCESSFULLY_REENGAGED ||
              oParticipantStatus == PEStatusState.PE_STATUS_UNABLE_TO_REACH) &&
              pe.Participant_Status__c == PEStatusState.PE_STATUS_ELIGIBILITY_FAILED
          ) {
            histories.add(
              new Participant_Enrollment_Status_History__c(
                Date__c = pe.Participant_Status_Last_Changed_Date__c,
                Status__c = 'Successfully Contacted',
                ParticipantEnrollment__c = pe.Id
                )
              );
          }
        //

        if (
          (pe.Participant_Status__c != PEStatusState.PE_STATUS_RECEIVED &&
          pe.Participant_Status__c !=
          PEStatusState.PE_STATUS_ELIGIBILITY_PASSED) ||
          (oParticipantStatus == PEStatusState.PE_STATUS_RECEIVED &&
          pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED)
        ) {
          histories.add(
            new Participant_Enrollment_Status_History__c(
              Date__c = pe.Participant_Status_Last_Changed_Date__c,
              Status__c = pe.Participant_Status__c,
              Notes__c = Notes,
              ParticipantEnrollment__c = pe.Id,
              Non_Enrollment_Reason__c = initReasonMap.get(reason)
            )
          );
        }
      }
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.createPrimaryHistoryEntry.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
      );
      TriggerHandlerExecutor.bypassHandler(
        PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
      );

      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
      );
      TriggerHandlerExecutor.bypassHandler(
        PENotificationTriggerHandler.CreateNotificationHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
      );
      /* TriggerHandlerExecutor.bypassHandler(
                            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
                        );*/
      TriggerHandlerExecutor.bypassHandler(
        ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
      );

      if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
        update PEUpdateList;
      }

      if (histories != null && !histories.isEmpty()) {
        TriggerHandlerExecutor.bypassHandler(
          ParticipantEnrollmentSHTriggerHandler.updateEnrollmentStatus.class
        );
        insert histories;
      }
      if (PeId != null && !PeId.isEmpty()) {
        if (StatusToUpdate == 'Received') {
          historiestoUpdate = [
            SELECT
              id,
              Backward_Bulk_Update__c,
              Status__c,
              ParticipantEnrollment__c
            FROM Participant_Enrollment_Status_History__c
            WHERE
              ParticipantEnrollment__c IN :peId
              AND Status__c != :StatusToUpdate
          ];
          for (
            Participant_Enrollment_Status_History__c psh : historiestoUpdate
          ) {
            psh.Backward_Bulk_Update__c = true;
            peshUpdate.add(psh);
          }
        }
        if (peshUpdate != null && !peshUpdate.isEmpty()) {
          update peshUpdate;
        }
      }

      if (
        oParticipantStatus == PEStatusState.PE_STATUS_RECEIVED &&
        (StatusToUpdate == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
        StatusToUpdate == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED ||
        StatusToUpdate == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
        StatusToUpdate == PEStatusState.PE_STATUS_UNABLE_TO_REACH)
      ) {
        if (PEIncentiveList.size() > 0 || !PEIncentiveList.isEmpty()) {
          ID ContacId = UserContext.getUserContactId();
          for (Study_Incentive_Plan__c studyIncentivePlan : [
            SELECT
              Id,
              Incentive_Plan__c,
              Clinical_Trial_Profile__c,
              Study_Site__c
            FROM Study_Incentive_Plan__c
            WHERE
              Study_Site__c IN :SSId
              AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != :CommunityTemplateService.TEMPLATE_JANSSEN
          ]) {
            planIds.add(studyIncentivePlan.Incentive_Plan__c);
            MapSitePlan.put(
              studyIncentivePlan.Study_Site__c,
              studyIncentivePlan.Incentive_Plan__c
            );
          }
          if (!planIds.isEmpty()) {
            incentiveTasks = [
              SELECT
                Id,
                Points__c,
                Enabled__c,
                IQVIA_Supported__c,
                Incentive_Plan__c
              FROM Incentive_Plan_Task__c
              WHERE
                Incentive_Plan__c IN :planIds
                AND Enabled__c = TRUE
                AND Incentive_Task_Catalog__c = :IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY
            ];
            if (!incentiveTasks.isEmpty()) {
              for (Incentive_Plan_Task__c ipt : incentiveTasks) {
                MapPlanTask.put(ipt.Incentive_Plan__c, ipt);
              }
              for (Participant_Enrollment__c per : PEIncentiveList) {
                if (MapSitePlan.containsKey(per.Study_Site__c)) {
                  Incentive_Plan_Task__c pt = MapPlanTask.get(
                    MapSitePlan.get(per.Study_Site__c)
                  );
                  Completed_Incentive_Task__c completedIncentiveTask = new Completed_Incentive_Task__c();
                  completedIncentiveTask.Completed_By__c = ContacId;
                  completedIncentiveTask.Completed_Date__c = Datetime.now();
                  completedIncentiveTask.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY;
                  completedIncentiveTask.Points__c = pt.Points__c;
                  completedIncentiveTask.Completed_For__c = per.Name;
                  lstIncentiveTsk.add(completedIncentiveTask);
                }
              }
              insert lstIncentiveTsk;
            }
          }
        }
      }
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }

  @AuraEnabled
  public static Boolean saveTheChunkFile(String fileName, String base64Data, String contentType, String fileId){
    Id currentContactId = CommunityService.getInstance().getCurrentContactId();

     /*base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
      if ( String.isBlank(fileId) ) {
          fileId = saveFiles(currentContactId, fileName, base64Data );
      } else {
          appendToFile(fileId, base64Data);
      } */

      return true;
  }

  /*@AuraEnabled
    public static Id saveFiles(Id recordId, String fileName, String base64Data )  {

        ContentVersion contentToInsert =new ContentVersion();
        contentToInsert.Title =fileName;
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert;

        contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId;
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;

        return contentToInsert.id;

    } */

   /*@AuraEnabled
    public static void appendToFile(Id contentDocumentId, String base64Data) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];

        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);

        update versionData;
    } */

    @AuraEnabled
    public static void deleteFile(String fileId)  {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :fileId];
        contentdocument cd = new contentdocument(id = cv.contentDocumentId);
        delete cd;
    }

    public Class ParticipantStatusesVisitPlans{
      @AuraEnabled
      public List<LabelValueItem> participantStatuses;
      @AuraEnabled
      public List<LabelValueItem> visitPlansLVList;
      @AuraEnabled
      Public Study_Site__c objStudySite;
  }

  public class LabelValueItemISO {
    @AuraEnabled
    public String Language;
    @AuraEnabled
    public String LanguageISOcode;

    public LabelValueItemISO(String Language, String LanguageISOcode) {
      this.Language = Language;
      this.LanguageISOcode = LanguageISOcode;
     }
  }

  @AuraEnabled
  public static List<LabelValueItemISO> getISOLanguage() {
      List<LabelValueItemISO> languageLVList =getPicklistLabelValueList(Participant__c.Preferred_Language__c);
      return languageLVList;

  }

  public static List<LabelValueItemISO> getPicklistLabelValueList(SObjectField field) {
      List<LabelValueItemISO> items = new List<LabelValueItemISO>();
      for (PicklistEntry ple : field.getDescribe().getPicklistValues()) {
          items.add(new LabelValueItemISO(ple.getLabel(), ple.getValue()));
      }
      return items;
  }



    @AuraEnabled
    public static ParticipantStatusesVisitPlans getParticipantsStatusesAndVisitPlans(Id studySiteId) {
        ParticipantStatusesVisitPlans result = new ParticipantStatusesVisitPlans();
        List<Study_Site__c> sites = [
            SELECT
                Id,
                Study_Site_Type__c,Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                Clinical_Trial_Profile__r.Initial_Visit_Required__c,
                Clinical_Trial_Profile__r.Final_Consent_Required__c,
                Clinical_Trial_Profile__r.Tokenization_Support__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c
            FROM Study_Site__c
            WHERE Id = :studySiteId
        ];
        if (sites.isEmpty()){
            result.participantStatuses = new List<LabelValueItem>();
            result.visitPlansLVList = new List<LabelValueItem>();
            result.objStudySite = new Study_Site__c();
        }else{
          List<LabelValueItem> tempParticipantStatuses = PEStatusState.getParticipantImportStatusesLV(sites[0].Clinical_Trial_Profile__r);
          if(sites[0].Clinical_Trial_Profile__r.Promote_to_SH__c && !sites[0].Clinical_Trial_Profile__r.Initial_Visit_Required__c && (sites[0].Study_Site_Type__c =='Virtual' ||sites[0].Study_Site_Type__c =='Hybrid')){
            result.participantStatuses = new List<LabelValueItem>();
            for(LabelValueItem opt : tempParticipantStatuses){
              if(opt.value == 'Received' || opt.value == 'Successfully Contacted'){
                result.participantStatuses.add(opt);
              }
            }
          } else{
            result.participantStatuses = tempParticipantStatuses;
          }
          result.visitPlansLVList =StudySiteService.getVisitPlansLVList(studySiteId);
          result.objStudySite = sites[0];
        }
        return result;
    }




  @AuraEnabled
    public static String uploadParticipants(
        List<String> csvFileLines,
        String fileName,
        String studySiteId,
        String selectedStatus,
        Boolean createUsers,
        Boolean doContact,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean outreachEmail,
        Boolean outreachPhone,
        Boolean outreachSMS,
        Boolean outreachDirectMail,
        Id visitPlanId
    ){
      String getReturnValue = Action_UploadParticipantsRemote.uploadParticipants(csvFileLines,fileName,studySiteId,selectedStatus
                                                        ,createUsers,doContact,allowEmail,allowPhone,allowSMS,
                                                        outreachEmail,outreachPhone,outreachSMS,outreachDirectMail,visitPlanId);

      return getReturnValue;

    }

  @AuraEnabled(cacheable=true)
  public static string fetchCurrentUserLanguage() {
    return UserInfo.getLanguage();
  }
   @AuraEnabled
   public static String getSite(Id siteId) {
     return [Select Id,Name from Study_Site__c where id=:siteId].Name;
   }

    public static Map<Id, List<StudySiteVisitPlan__c>> getStudySiteVisitPlansMap(
        List<Id> ssIds
    ) {
        List<StudySiteVisitPlan__c> studySiteVisitPlans = [
            SELECT Id, Visit_Plan__c, Visit_Plan__r.Name, Study_Site__c
            FROM StudySiteVisitPlan__c
            WHERE Study_Site__c IN :ssIds
        ];

        Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlansBySSId = new Map<Id, List<StudySiteVisitPlan__c>>();
        for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
            if (!ssVisitPlansBySSId.containsKey(ssVP.Study_Site__c)) {
                ssVisitPlansBySSId.put(
                    ssVP.Study_Site__c,
                    new List<StudySiteVisitPlan__c>()
                );
            }
            ssVisitPlansBySSId.get(ssVP.Study_Site__c).add(ssVP);
        }

        return ssVisitPlansBySSId;
    }

    /*
    * @description: this method returns list of PER Ids for Bell notification scenario
                    where Status of PER is unchanged for more than X days
      @storyId:
      @param-contactId: current logged in Community user contactId
      @param-nType: Bell Notification Type Name
      @return: List of PER Ids
    */
    @AuraEnabled(cacheable=true)
    public static List<String> getParticipantEnrollmentForBell(String contactId, String nType){
      String communityType = UserContext.getCurrentUserMode().template.templateName;
      List<Study_Site__c> lstOfStudySite = new List<Study_Site__c>();
      List<Participant_Enrollment__c> lstOfPE = new List<Participant_Enrollment__c>();
      List<String> lstOfPEIds = new List<String>();
      List<String> listOfOverridePIReferralStatus = new List<String>{'Accepted', 'Accepted (Admin)', 'On Hold'};
      List<String> lstOfStatus = new List<String>{'Received', 'Contact Attempted', 'Pre-review Passed', 'Successfully Contacted', 'Successfully re-engaged'};

      lstOfStudySite = [SELECT Id FROM Study_Site__c
                          WHERE (Principal_Investigator__c = :contactId OR ID IN :DelegateService.getDelegatedStudySiteIds())];

      String queryString =
      'SELECT ' +
      'Id,' +
      'Name,' +
      'Participant__r.First_Name__c,' +
      'Participant__r.Middle_Name__c,' +
      'Participant__r.Last_Name__c,' +
      'Participant__r.Full_Name__c,' +
      'Participant__r.Phone__c,' +
      'Clinical_Trial_Profile__r.Study_Code_Name__c,' +
      'Clinical_Trial_Profile__r.Promote_to_SH__c,' +
      'Clinical_Trial_Profile__r.Tokenization_Support__c,' +
      'Study_Site__c,' +
      'Study_Site__r.name,' +
      'Study_Site__r.Study_Site_Type__c,' +
      'Clinical_Trial_Profile__c,' +
      'Referral_Source__c,' +
      'HighRisk_Indicator__c,' +
      'High_Priority__c,' +
      'PerCounter__c,' +
      'Participant__c,' +
      'Participant__r.Adult__c,' +
      'Participant__r.Email__c,' +
      'Participant__r.Gender__c,' +
      'Clinical_Trial_Profile__r.CommunityTemplate__c,' +
      'Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,' +
      'Study_Site__r.Suppress_Participant_Emails__c,' +
      'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
      'Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,' +
      'Clinical_Trial_Profile__r.Bell_Notification_Reminder__c,'+
      'Participant_Contact__r.Is_Patient_User_Created__c,' +
      'Invited_To_PP_Date__c,' +
      'Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
      'Study_Site__r.Clinical_Trial_Profile__r.Promote_to_SH__c,' +
      'Participant__r.IsCountry_NOT_Eligible_for_Emails__c,' +
      'Permit_IQVIA_to_contact_about_study__c,' +
      'Participant__r.Emancipation_in_progress__c,' +
      'Participant_Status__c,' +
      'HCP__c,' +
      'HCP__r.HCP_Contact__r.Name,' +
      'PI_Contact__c,' +
      'PI_Contact__r.Name,' +
      'Source_Type__c,' +
      'Study_Hub_Log__c,' +
      'Screening_ID__c,' +
      'Re_consent__c,' +
      'Study_Site__r.E_Consent_Vendor__r.Name,' +
      'IVRS_IWRS__c,' +
      'Visit_Plan__c,' +
      'Study_Hub_Log__r.Response_Status_Code__c,' +
      'Is_Participant_DOB_Valid__c ,' +
      '(' +
      '  SELECT Id, Name, Status__c, CreatedDate, Non_Enrollment_Reason__c ' +
      '  FROM Participant_Enrollment_Status_History__r' +
      '  ORDER BY Name DESC' +
      '  LIMIT 1' +
      ' )' +
      'FROM Participant_Enrollment__c WHERE ';

      String filterString = 'Participant_Status__c IN :lstOfStatus '+
                            'AND Study_Site__r.Override_PI_Referral_Status__c IN :listOfOverridePIReferralStatus '+
                            'AND Initial_visit_scheduled_flag__c = false '+
                            'AND Clinical_Trial_Profile__r.CommunityTemplate__c = :communityType '+
                            'AND Study_Site__c = :lstOfStudySite';
      filterString = nType == 'BELL_Message_on_Action_High_Priority' ?
                                  filterString+ ' AND High_Priority__c = true' :
                                  filterString;

      queryString = queryString + filterString;

      lstOfPE = (List<Participant_Enrollment__c>) Database.query(queryString);

      for(Participant_Enrollment__c eachRec : lstOfPE){
        for(Participant_Enrollment_Status_History__c eachStatus : eachRec.Participant_Enrollment_Status_History__r){
          if(lstOfStatus.contains(eachStatus.Status__c) && eachRec.Participant_Status__c == eachStatus.Status__c){
          Integer noOfDays = eachStatus.createdDate.Date().daysBetween(System.today());
            if(eachRec.Clinical_Trial_Profile__r.Bell_Notification_Reminder__c != null && noOfDays >= eachRec.Clinical_Trial_Profile__r.Bell_Notification_Reminder__c){
              lstOfPEIds.add(eachRec.Id);
            }
          }
        }
      }
      if(lstOfPEIds.size() > 0){
        return lstOfPEIds;
      }
      return null;
    }
}