/**
 * This is the main controller class for PI Revamp
 */
public without sharing class PIR_HomepageController {
  public static boolean allowSH;
  public class ListViewWrapper {
    @AuraEnabled
    public string firstName;
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
    public Participant_Enrollment__c per;
  }

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
  }

  @AuraEnabled
  public static ListViewReturnWrapper getListViewData(
    Integer pageNumber,
    Integer totalCount,
    List<Id> studyIdlist,
    List<Id> siteIdlist,
    String sponsorName,
    List<String> selectedStatusList,
    Boolean isPPFiltered
  ) {
    try {
      List<String> status = selectedStatusList;
     /* status.add('Received');
      status.add('Pre-review Passed');
      status.add('In Wash Out Period');
      status.add('Successfully Contacted');
      status.add('Contact Attempted');
      status.add('Eligibility Passed');
      status.add('Screening Passed');
      status.add('Screening In Progress');
      status.add('Screening Passed');
      status.add('Screening Failed');
      status.add('Screening In Progress - Wash Out Period');
      status.add('Ready to Screen');
      status.add('Enrollment Success');
      status.add('Randomization Success');
      status.add('Pre-review Failed');
      status.add('Unable to Reach');
      status.add('Contacted - Not Suitable');
      status.add('Eligibility Failed');
      status.add('Declined Consent');
      status.add('Unable to Screen');
      status.add('Withdrew Consent');
      status.add('Withdrew Consent After Screening');
      status.add('Enrollment Failed');
      status.add('Randomization Failed');
      status.add('Randomization Success');
      status.add('Treatment Period Started');
      status.add('Follow-Up Period Started');
      status.add('Participation Complete');
      status.add('Trial Complete');
      status.add('Declined Final Consent'); */
       Integer totalCountPP = [
                  SELECT COUNT()
                  FROM Participant_Enrollment__c
                  WHERE
                    Study_Site__c IN :siteIdlist
                    AND Participant_Status__c IN :status
                    AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !='Virtual' AND Study_Site__r.Study_Site_Type__c !='Hybrid' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE
                    AND Clinical_Trial_Profile__r.CommunityTemplate__c !=: system.Label.Janssen_Community_Template_Name
                    AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                ];
      if (totalCount == -1) {
        if(status.isEmpty()){
          status.add('Received');
        }
        
        if (
          (studyIdlist == null || studyIdlist.isEmpty()) &&
          (siteIdlist == null || siteIdlist.isEmpty())
        ) {
          studyIdlist = new List<Id>();
          siteIdlist = new List<Id>();
          string janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
          List<Study_Site__c> studySiteList = getStudySite();
          for (Study_Site__c s : studySiteList) {
            if (sponsorName == janssen) {
              if (
                s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName
              ) {
                studyIdlist.add(s.Clinical_Trial_Profile__c);
                siteIdlist.add(s.Id);
                break;
              }
            } else {
              if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
                studyIdlist.add(s.Clinical_Trial_Profile__c);
                siteIdlist.add(s.Id);
                break;
              }
            }
          }
        }else if (
          (studyIdlist != null || !studyIdlist.isEmpty()) &&
          (siteIdlist == null || siteIdlist.isEmpty())
        ) {
          //get the study site id's for selected study
          siteIdlist = getStudySiteForaStudy(studyIdlist);
        }
        System.debug('status: ' + status);
         if(isPPFiltered == true){
                totalCount = [
                  SELECT COUNT()
                  FROM Participant_Enrollment__c
                  WHERE
                    Study_Site__c IN :siteIdlist
                    AND Participant_Status__c IN :status
                    AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !='Virtual' AND Study_Site__r.Study_Site_Type__c !='Hybrid' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE
                    AND Clinical_Trial_Profile__r.CommunityTemplate__c !=: system.Label.Janssen_Community_Template_Name
                    AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                ];
          }else{
               totalCount = [
                  SELECT COUNT()
                  FROM Participant_Enrollment__c
                  WHERE
                    Study_Site__c IN :siteIdlist
                    AND Participant_Status__c IN :status];
                    System.debug('totalCount: ' + totalCount);
          }
      }
      ListViewReturnWrapper listViewReturnWrapper = new ListViewReturnWrapper();
      List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();

      if (pageNumber > 200 & pageNumber <= 4500) {
        listViewWrapper = createListViewWrapper(
          getAdditionalPages(pageNumber, totalCount, studyIdlist, siteIdlist, isPPFiltered)
        );
      } else {
        Integer offsetLimit = (pageNumber - 1) * 10;
         List<Participant_Enrollment__c> perList = new  List<Participant_Enrollment__c>();
          if(isPPFiltered == true){
              system.debug('withfilter');
              perList = [
              SELECT
                Id,
                Name,
                Participant__r.First_Name__c,
                Participant__r.Last_Name__c,
                Participant__r.Phone__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c,
                Study_Site__c,
                Study_Site__r.name,
                Study_Site__r.Study_Site_Type__c,
                Clinical_Trial_Profile__c,
                Referral_Source__c,
                HighRisk_Indicator__c,
                High_Priority__c,
                PerCounter__c,
                Participant__c,
                Participant__r.Adult__c,
                Participant__r.Email__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Participant_Contact__r.Is_Patient_User_Created__c,
                Invited_To_PP_Date__c,
                Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                Permit_IQVIA_to_contact_about_study__c,
                Participant__r.Emancipation_in_progress__c,
                Participant_Status__c,
                HCP__c,
                HCP__r.HCP_Contact__r.Name,
                PI_Contact__c,
                PI_Contact__r.Name,
                Source_Type__c,
                Study_Hub_Log__c,
                Study_Hub_Log__r.Response_Status_Code__c,
                (
                  SELECT Id, Date__c, Non_Enrollment_Reason__c
                  FROM Participant_Enrollment_Status_History__r
                  WHERE Status__c = 'Eligibility Passed'
                  ORDER BY CreatedDate DESC
                  LIMIT 1
                )
              FROM Participant_Enrollment__c
              WHERE
                Study_Site__c IN :siteIdlist
                AND Participant_Status__c IN :status 
                AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !='Virtual' AND Study_Site__r.Study_Site_Type__c !='Hybrid' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE
                AND Clinical_Trial_Profile__r.CommunityTemplate__c !=: system.Label.Janssen_Community_Template_Name
                AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
              ORDER BY PerCounter__c DESC
              LIMIT 10
              OFFSET :offsetLimit
            ];
          }else{
             system.debug('withoutfilter');
             System.debug('status: ' + status);
             System.debug('siteIdlist: ' + siteIdlist);
             System.debug('offsetLimit: ' + offsetLimit);
              perList = [
              SELECT
                Id,
                Name,
                Participant__r.First_Name__c,
                Participant__r.Last_Name__c,
                Participant__r.Phone__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c,
                Study_Site__c,
                Study_Site__r.name,
                Study_Site__r.Study_Site_Type__c,
                Clinical_Trial_Profile__c,
                Referral_Source__c,
                HighRisk_Indicator__c,
                High_Priority__c,
                PerCounter__c,
                Participant__c,
                Participant__r.Adult__c,
                Participant__r.Email__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Participant_Contact__r.Is_Patient_User_Created__c,
                Invited_To_PP_Date__c,
                Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                Permit_IQVIA_to_contact_about_study__c,
                Participant__r.Emancipation_in_progress__c,
                Participant_Status__c,
                HCP__c,
                HCP__r.HCP_Contact__r.Name,
                PI_Contact__c,
                PI_Contact__r.Name,
                Source_Type__c,
                Study_Hub_Log__c,
                Study_Hub_Log__r.Response_Status_Code__c,
                (
                  SELECT Id, Date__c, Non_Enrollment_Reason__c
                  FROM Participant_Enrollment_Status_History__r
                  WHERE Status__c = 'Eligibility Passed'
                  ORDER BY CreatedDate DESC
                  LIMIT 1
                )
              FROM Participant_Enrollment__c
              WHERE
                Study_Site__c IN :siteIdlist
                AND Participant_Status__c IN :status 
              ORDER BY PerCounter__c DESC
              LIMIT 10
              OFFSET :offsetLimit
            ];
          }
          System.debug('perList: ' + perList);
        listViewWrapper = createListViewWrapper(perList);
      }
      if(totalCountPP == 0){
          listViewReturnWrapper.isEnablePP= false;
      }else{
          listViewReturnWrapper.isEnablePP= true;
      }
      listViewReturnWrapper.listViewWrapper = listViewWrapper;
      listViewReturnWrapper.totalRecordCount = totalCount;
      listViewReturnWrapper.studyIdlist = studyIdlist;
      listViewReturnWrapper.siteIdlist = siteIdlist;
      
      return listViewReturnWrapper;
    } catch (Exception e) {
      system.debug(e.getStackTraceString());
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static List<ListViewWrapper> createListViewWrapper(
    List<Participant_Enrollment__c> perList
  ) {
    List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();
    for (Participant_Enrollment__c lst : perList) {
      ListViewWrapper wrap = new ListViewWrapper();
      wrap.firstName = lst.Participant__r.First_Name__c;
      wrap.lastName = lst.Participant__r.Last_Name__c;
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
      wrap.actionReq = lst.Participant__r.Emancipation_in_progress__c;
      wrap.status = lst.Participant_Status__c;
      wrap.participantId = lst.Participant__c;
      wrap.promotetoSH = lst.Clinical_Trial_Profile__r.Promote_to_SH__c;
      wrap.studysiteType = lst.Study_Site__r.Study_Site_Type__c;
      wrap.isAllowedForSH = ifAllowedForSH(lst, false);
      wrap.adult=lst.Participant__r.Adult__c;
      wrap.email=lst.Participant__r.Email__c;
      wrap.commTemplate=lst.Clinical_Trial_Profile__r.CommunityTemplate__c;
      wrap.clinicalParticipantEmail=lst.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c;
      wrap.studySiteParticipantEmail=lst.Study_Site__r.Suppress_Participant_Emails__c;
      wrap.patientUser=lst.Participant_Contact__r.Is_Patient_User_Created__c;
      wrap.invitetoPPDate=lst.Invited_To_PP_Date__c;
      wrap.clinicalPPEnable=lst.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c;
      wrap.notEligibleEmail=lst.Participant__r.IsCountry_NOT_Eligible_for_Emails__c;
      wrap.permitInfo=lst.Permit_IQVIA_to_contact_about_study__c;

      listViewWrapper.add(wrap);
    }

    return listViewWrapper;
  }

  private static List<Participant_Enrollment__c> getAdditionalPages(
    Integer pageNumber,
    Integer totalCount,
    List<Id> studyIdlist,
    List<Id> siteIdlist,
    Boolean isPPFiltered
  ) {
    Integer limitOfRecords = (pageNumber * 10);
    List<String> status = new List<String>();
    status.add('Received');
    status.add('Pre-review Passed');
    status.add('In Wash Out Period');
    status.add('Successfully Contacted');
    status.add('Contact Attempted');
    status.add('Eligibility Passed');
    status.add('Screening Passed');
    status.add('Screening In Progress');
    status.add('Screening Passed');
    status.add('Screening In Progress - Wash Out Period');
    status.add('Ready to Screen');
    status.add('Enrollment Success');
    status.add('Randomization Success');
    status.add('Pre-review Failed');
    status.add('Unable to Reach');
    status.add('Contacted - Not Suitable');
    status.add('Eligibility Failed');
    status.add('Declined Consent');
    status.add('Unable to Screen');
    status.add('Withdrew Consent');
    status.add('Withdrew Consent After Screening');
    status.add('Enrollment Failed');
    status.add('Randomization Failed');
    status.add('Declined Final Consent');
    
    List<Participant_Enrollment__c> perList = new  List<Participant_Enrollment__c>();
    if(isPPFiltered == true){
          perList = [
          SELECT
            Id,
            Name,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c,
            Participant__r.Phone__c,
            Clinical_Trial_Profile__r.Study_Code_Name__c,
            Study_Site__c,
            Study_Site__r.name,
            Clinical_Trial_Profile__c,
            Referral_Source__c,
            HighRisk_Indicator__c,
            High_Priority__c,
            PerCounter__c,
            Participant__c,
            Participant__r.Emancipation_in_progress__c,
            Participant_Status__c,
            HCP__c,
            HCP__r.HCP_Contact__r.Name,
            PI_Contact__c,
            PI_Contact__r.Name,
            Source_Type__c
          FROM Participant_Enrollment__c
          WHERE Study_Site__c IN :siteIdlist AND Participant_Status__c IN :status
          AND (Participant_Contact__r.Is_Patient_User_Created__c = FALSE OR Invited_To_PP_Date__c =NULL) AND Participant__r.Email__c!=NULL AND Participant__r.Adult__c = TRUE AND Study_Site__r.Study_Site_Type__c !='Virtual' AND Study_Site__r.Study_Site_Type__c !='Hybrid' AND Participant__r.IsCountry_NOT_Eligible_for_Emails__c = FALSE AND Permit_IQVIA_to_contact_about_study__c = TRUE
          AND Clinical_Trial_Profile__r.CommunityTemplate__c !=: system.Label.Janssen_Community_Template_Name
          AND Study_Site__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
          ORDER BY PerCounter__c DESC
          LIMIT :limitOfRecords
        ];
    }else{
            perList = [
          SELECT
            Id,
            Name,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c,
            Participant__r.Phone__c,
            Clinical_Trial_Profile__r.Study_Code_Name__c,
            Study_Site__c,
            Study_Site__r.name,
            Clinical_Trial_Profile__c,
            Referral_Source__c,
            HighRisk_Indicator__c,
            High_Priority__c,
            PerCounter__c,
            Participant__c,
            Participant__r.Emancipation_in_progress__c,
            Participant_Status__c,
            HCP__c,
            HCP__r.HCP_Contact__r.Name,
            PI_Contact__c,
            PI_Contact__r.Name,
            Source_Type__c
          FROM Participant_Enrollment__c
          WHERE Study_Site__c IN :siteIdlist AND Participant_Status__c IN :status
          ORDER BY PerCounter__c DESC
          LIMIT :limitOfRecords
        ];
    }
      

    List<Participant_Enrollment__c> perLimitList = new List<Participant_Enrollment__c>();
    for (Integer i = (limitOfRecords - 10); i < perList.size(); i++) {
      perLimitList.add(perList[i]);
    }

    return perLimitList;
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
        Clinical_Trial_Profile__r.CommunityTemplate__c,
        Principal_Investigator__c
      FROM Study_Site__c
      WHERE
        Principal_Investigator__c = :piContactId
        OR ID IN :DelegateService.getDelegatedStudySiteIds()
    ];

    return studySiteList;
  }

  public static List<Id> getStudySiteForaStudy(List<Id> studyIdlist) {
    List<Id> siteIdList = new List<Id>();
    Id piContactId = CommunityService.getUserContact().Id;
    List<Study_Site__c> studySiteList = [
      SELECT
        Id
      FROM Study_Site__c
      WHERE
        (Principal_Investigator__c = :piContactId
        OR ID IN :DelegateService.getDelegatedStudySiteIds())
        AND Clinical_Trial_Profile__c IN : studyIdlist
    ];

    for (Study_Site__c ss: studySiteList){
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
          Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
          Clinical_Trial_Profile__r.CommunityTemplate__c,
          Participant__r.Full_Name__c,
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
      system.debug('>>>pistaff>>' + piStaffs);
      for (Site_Staff__c siteStaff : piStaffs) {
        if (siteStaff.Site_Contact__c == CommunityService.getUserContact().Id) {
          piStudiesAccessLevel.put(
            siteStaff.Study_Site__c,
            siteStaff.Delegate_Level__c
          );
        }
      }
      system.debug(
        '>>>retrnvalue piStudiesAccessLevel>>' + piStudiesAccessLevel
      );
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

  public class StudyStudySiteWrapper {
    @AuraEnabled
    public Map<String, Id> ctpMap;
    @AuraEnabled
    public Map<Id, List<Study_Site__c>> studySiteMap;
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
      sswrap.ctpMap = studyMap;
      sswrap.studySiteMap = studySiteMap;
      return sswrap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static List<Id> getStudyAccess(List<Id> ctpIds){
     List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>();
     map<Id,Id> tc = New map<Id,Id>();
     List<Id> ctpNoAccess = New List<Id>();
     List<Terms_And_Conditions_Acceptance__c> termsConditions = New List<Terms_And_Conditions_Acceptance__c>();
     ctp = [Select Id,Terms_And_Conditions_ID__c from Clinical_Trial_Profile__c where Id IN:ctpIds];
     String UserId = UserInfo.getUserId();
     for(Clinical_Trial_Profile__c c:ctp){
         tc.put(c.Terms_And_Conditions_ID__c,c.Id);
     }
     termsConditions = [Select Id,Terms_And_Conditions__c,User__c from Terms_And_Conditions_Acceptance__c where User__c =:UserId limit 999];
     for(Terms_And_Conditions_Acceptance__c tca:termsConditions){
         if(!tc.containsKey(tca.Terms_And_Conditions__c)){
            ctpNoAccess.add(tc.get(tca.Terms_And_Conditions__c)); 
         }
     }
     return ctpNoAccess;
  }
}