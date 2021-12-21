/**
 * This is the main controller class for PI Revamp
 */
public without sharing class PIR_HomepageController {
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
    String sponsorName 
  ) {
    try {
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
      if (totalCount == -1) {
        if (
          (studyIdlist == null || studyIdlist.isEmpty()) &&
          (siteIdlist == null || siteIdlist.isEmpty())
        ) {
          studyIdlist = new List<Id>();
          siteIdlist = new List<Id>();
          string janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
          List<Study_Site__c> studySiteList = getStudySite();
          for (Study_Site__c s : studySiteList) {
               if(sponsorName == janssen){
                   if(s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName){
                      studyIdlist.add(s.Clinical_Trial_Profile__c);
                      siteIdlist.add(s.Id);
                   }
               }else{
                    if(s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen ){
                      studyIdlist.add(s.Clinical_Trial_Profile__c);
                      siteIdlist.add(s.Id);
                    }
               }
            }
        }
        totalCount = [
          SELECT COUNT()
          FROM Participant_Enrollment__c
          WHERE Study_Site__c IN :siteIdlist AND Participant_Status__c IN:status 
        ];
      }
      ListViewReturnWrapper listViewReturnWrapper = new ListViewReturnWrapper();
      List<ListViewWrapper> listViewWrapper = new List<ListViewWrapper>();
      
      

      if (pageNumber > 200 & pageNumber <= 4500) {
        listViewWrapper = createListViewWrapper(
          getAdditionalPages(pageNumber, totalCount, studyIdlist, siteIdlist)
        );
      } else {
        Integer offsetLimit = (pageNumber - 1) * 10;
      
        List<Participant_Enrollment__c> perList = [
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
          WHERE Study_Site__c IN :siteIdlist AND Participant_Status__c IN:status 
          ORDER BY PerCounter__c DESC
          LIMIT 10
          OFFSET :offsetLimit
        ];

        listViewWrapper = createListViewWrapper(perList);
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
      wrap.participantPhone = lst.Participant__r.Phone__c;

      if(lst.Referral_Source__c == System.Label.RH_HCP && lst.HCP__c != null)
      {
           wrap.source = lst.HCP__r.HCP_Contact__r.Name;
      }else if(lst.Referral_Source__c == System.Label.RH_PI && lst.PI_Contact__c != null){
            wrap.source = lst.PI_Contact__r.Name;
      }else{
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

      listViewWrapper.add(wrap);
    }

    return listViewWrapper;
  }

  private static List<Participant_Enrollment__c> getAdditionalPages(
    Integer pageNumber,
    Integer totalCount,
    List<Id> studyIdlist,
    List<Id> siteIdlist
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
      
    List<Participant_Enrollment__c> perList = [
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
      WHERE Study_Site__c IN :siteIdlist AND  Participant_Status__c IN:status
      ORDER BY PerCounter__c DESC
      LIMIT :limitOfRecords
    ];

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
      List<Site_Staff__c> piStaffs = new   List<Site_Staff__c>();
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
                    AND Study_Site__c =: pe.Study_Site__c
                    AND is_Invited__c = TRUE
                ];  
      PeGetInviteWrapper pegetwrp = new PeGetInviteWrapper();
      if(!piStaffs.isEmpty()){
          for (Site_Staff__c siteStaff : piStaffs) {    
               if(siteStaff.Delegate_Level__c == 'Level 3'){
                  pegetwrp.preScreenAccess = false;
               }else{
                  pegetwrp.preScreenAccess = true;
               }
          }
      }else{
           pegetwrp.preScreenAccess = true;
      }    
      pegetwrp.per = pe;
      pegetwrp.isAllowedForSH = ifAllowedForSH(pe, false);
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
              new Map<Id, Id>{ pe.Participant_Contact__c => pe.HCP_Contact_HCPEnroll__c}
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
      throw new AuraHandledException(e.getMessage() +
        '\n' +
        e.getStackTraceString());
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
}