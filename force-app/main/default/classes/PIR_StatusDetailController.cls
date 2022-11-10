public without sharing class PIR_StatusDetailController {
  private static final String SUCCESS = 'success';
  private static final String INPROGRESS = 'inProgress';
  private static final String FAILURE = 'failure';

  public class StatusDetailGroup {
    @AuraEnabled
    public Id perId;
    @AuraEnabled
    public String groupName;
    @AuraEnabled
    public String groupStatus;
    @AuraEnabled
    public String groupReason;
    @AuraEnabled
    public String groupIcon;
    @AuraEnabled
    public Datetime groupDate;
  }

  public class PerDetailsWrap {
    @AuraEnabled
    public Participant_Enrollment__c per;
    @AuraEnabled
    public List<LabelValueItem> visitPlansList;
  }

  public class ReceivedHistoryWrap {
    @AuraEnabled
    public String historyTitle;
    @AuraEnabled
    public Datetime detailDate;
    @AuraEnabled
    public String createdBy;
  }

  public class ContactHistoryWrap {
    @AuraEnabled
    public String historyTitle;
    @AuraEnabled
    public String detailDate;
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public Boolean isAdditionalNote;
    @AuraEnabled
    public String noteDetailsdt;
    @AuraEnabled
    public Boolean isFovHistory;
    @AuraEnabled
    public String noteDetails;
    @AuraEnabled
    public Integer noteKey;
    @AuraEnabled
    public Boolean isAdditionalNoteOld;

  }

  public class InitialVistHistoryWrap {
    @AuraEnabled
    public String notes;
    @AuraEnabled
    public String notesDetails;
  }

  public class EligibilityHistoryWrap {
    @AuraEnabled
    public String historyTitle;
    @AuraEnabled
    public Datetime detailDate;
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public Boolean isAdditionalNote;
    @AuraEnabled
    public String noteDetails;
  }
  public class ScreeningHistoryWrap {
    @AuraEnabled
    public String historyTitle;
    @AuraEnabled
    public String  detailDate;
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public Boolean isAdditionalNote;
    @AuraEnabled
    public Integer noteKey;
    @AuraEnabled
    public String noteDetails;
  }
  public class EnrollmentHistoryWrap {
    @AuraEnabled
    public String historyTitle;
    @AuraEnabled
    public Datetime detailDate;
    @AuraEnabled
    public String createdBy;
    @AuraEnabled
    public Boolean isAdditionalNote;
    @AuraEnabled
    public String noteDetails;
  }

  public class BubbleMapWrap {
    @AuraEnabled
    public Boolean isBubbleMapRequired;
    @AuraEnabled
    public List<BubbleMapDetails> BubbleMaps;
    @AuraEnabled
    public Date userDt;
    @AuraEnabled
    public String contSuccessReason;
  }

  public class BubbleMapDetails {
    @AuraEnabled
    public Boolean isStatusPassed;
    @AuraEnabled
    public String pathName;
    @AuraEnabled
    public String styleName;
    @AuraEnabled
    public String styleName_1;
  }
  
  public class OutcomeReasonMap {
    @AuraEnabled
    public Map<String, List<String>> outcomeWithReason;
    @AuraEnabled
    public Map<String, String> outcomeWithValue;
  }

  @AuraEnabled
  public static List<StatusDetailGroup> getStatusDetail(Id perId) {
    List<StatusDetailGroup> wrapperList = new List<StatusDetailGroup>();

    List<Participant_Enrollment__c> per = [
      SELECT
        Id,
        Name,
        Participant_Status__c,
        Initial_visit_scheduled_date__c,
        Initial_visit_scheduled_time__c,
        Initial_visit_occurred_flag__c,
        Initial_visit_occurred_date__c,
        Informed_Consent__c,
        Site__c,
        Study_ID__c,
        Clinical_Trial_Profile__c,
        Clinical_Trial_Profile__r.Initial_Visit_Required__c,
        Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
        Visit_Plan__c,
        Study_Name__c,
        (
          SELECT
            CreatedDate,
            Date__c,
            Name,
            NewStatus__c,
            Reason__c,
            Status_Order__c,
            Status__c,
            Status_Label__c,
            Disabled_PESH__c
          FROM Participant_Enrollment_Status_History__r
          WHERE Disabled_PESH__c = FALSE
          AND Backward_Bulk_Update__c = FALSE
          ORDER BY Name DESC
        ) 
      FROM Participant_Enrollment__c
      WHERE Id = :perId
    ];

    Boolean isInitialVisitDetailsAvailable = (per[0]
      .Initial_visit_scheduled_date__c != null &&
    per[0].Initial_visit_scheduled_time__c != null);
    Boolean isInitialVisitAttended = (per[0].Initial_visit_occurred_flag__c &&
    per[0].Informed_Consent__c );
    Boolean isConsentFalse = (per[0].Participant_Status__c == 'Declined Consent' || 
    per[0].Participant_Status__c == 'Withdrew Consent');

    Decimal nxtOrder = null;

    Map<Decimal, Participant_Enrollment_Status_History__c> orderToPeshMap = new Map<Decimal, Participant_Enrollment_Status_History__c>();
    for (
      Participant_Enrollment_Status_History__c pesh : per[0]
        .Participant_Enrollment_Status_History__r
    ) {
      if (!orderToPeshMap.containsKey(pesh.Status_Order__c)) {
        orderToPeshMap.put(pesh.Status_Order__c, pesh);
      }
      if (nxtOrder == null) {
        nxtOrder = pesh.Status_Order__c + 1;
      }
    }

    String notInFinalStep = ((per[0]
        .Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c ==
      'Enrollment')
      ? 'PWS_Randomization_Card_Name'
      : 'PWS_Enrolled_Card_Name');

    String query = 'SELECT Additional_Notes_for_Satuses__c, DeveloperName, Failure_Criteria__c, History_Label__c, Id, In_progress_criteria__c, Label, Language, List_of_Statuses__c, MasterLabel, NamespacePrefix, Name__c, Order__c, QualifiedApiName, Success_Criteria__c, Default_Description__c FROM PIR_ParticipantStatusWorflowStep__mdt ';
    String filter = ' Where Label != \'' + notInFinalStep + '\' ';
    String order = ' ORDER BY Order__c ASC ';
    if (!per[0].Clinical_Trial_Profile__r.Initial_Visit_Required__c) {
      filter = filter + ' AND Label != \'PWS_Initial_Visit_Card_Name\' AND InitialVisit__c = FALSE';
    } else {
      filter = filter + ' AND Label != \'PWS_Eligibility_Card_Name\' AND InitialVisit__c = TRUE';
    }

    query = query + filter + order;
    List<PIR_ParticipantStatusWorflowStep__mdt> pirMetadata = Database.query(
      query
    );
    for (PIR_ParticipantStatusWorflowStep__mdt mdt : pirMetadata) {
      Integer mdtOrder = Integer.valueof(mdt.Order__c);
      StatusDetailGroup wrap = new StatusDetailGroup();
      wrap.perId = per[0].Id;
      wrap.groupName = mdt.Name__c;
      wrap.groupStatus = mdt.Default_Description__c;
      if (orderToPeshMap.containsKey(mdtOrder)) {
        wrap.groupStatus = orderToPeshMap.get(mdtOrder).Status_Label__c;
        wrap.groupReason = orderToPeshMap.get(mdtOrder).Reason__c;
        wrap.groupDate = orderToPeshMap.get(mdtOrder).CreatedDate;
        wrap.groupIcon = getGroupIcon(
          mdt,
          orderToPeshMap.get(mdtOrder).Status__c
        );
      }

      if (wrapperList.size() > 1) {
        if (
          wrapperList[1].groupIcon == SUCCESS &&
          mdt.Label == 'PWS_Initial_Visit_Card_Name' &&
          ((isInitialVisitDetailsAvailable && !isInitialVisitAttended ||
          isConsentFalse)
          )
        ) {
          wrap.groupIcon = INPROGRESS;
        } else if (
          wrapperList[1].groupIcon == SUCCESS &&
          mdt.Label == 'PWS_Initial_Visit_Card_Name' &&
          isInitialVisitAttended && !isConsentFalse
        ) {
          wrap.groupIcon = SUCCESS;
          if(per[0].Initial_visit_occurred_date__c != Null){
             wrap.groupDate = per[0].Initial_visit_occurred_date__c;
          }else{
              wrap.groupDate = Null;
          }
        }
      }

      if (
        mdtOrder == nxtOrder &&
        mdt.Label != 'PWS_Initial_Visit_Card_Name'
      ) {
        wrap.groupIcon = getGroupIcon(
          mdt,
          orderToPeshMap.get(mdtOrder - 1).Status__c
        );
      }

      wrapperList.add(wrap);
    }
    return wrapperList;
  }

  public static String getGroupIcon(
    PIR_ParticipantStatusWorflowStep__mdt mdt,
    String perStatus
  ) {
    String iconName = '';
    List<String> sucessList = new List<String>();
    List<String> inProgressList = new List<String>();
    List<String> failureList = new List<String>();

    if (mdt.Success_Criteria__c != null) {
      sucessList = mdt.Success_Criteria__c.split(';');
    }

    if (mdt.In_progress_criteria__c != null) {
      inProgressList = mdt.In_progress_criteria__c.split(';');
    }

    if (mdt.Failure_Criteria__c != null) {
      failureList = mdt.Failure_Criteria__c.split(';');
    }

    if (sucessList.contains(perStatus)) {
      iconName = SUCCESS;
    } else if (inProgressList.contains(perStatus)) {
      iconName = INPROGRESS;
    } else if (failureList.contains(perStatus)) {
      iconName = FAILURE;
    }

    return iconName;
  }

  @AuraEnabled
  public static OutcomeReasonMap getoutcomeToReasonMap(
    String stepName
  ) {
    List<PIR_Participant_Workflow_Outcome__mdt> outcomeReasonList = [
      SELECT
        DeveloperName,
        Id,
        Label,
        Order__c,
        Reasons_List__c,
        Status_Name__c,Status_Value__c,
        Step__c
      FROM PIR_Participant_Workflow_Outcome__mdt
      WHERE Step__c = :stepName
      ORDER BY Order__c ASC
    ];

    Map<String, List<String>> outcomeToReasonMap = new Map<String, List<String>>();
    Map<String, String> outcomeValues = new Map<String, String>();
    OutcomeReasonMap wrap_reasonmap = new OutcomeReasonMap();
    
    for (PIR_Participant_Workflow_Outcome__mdt orl : outcomeReasonList) {
      List<String> reasonList = new List<String>();
      //reasonList = orl.Reasons_List__c.split(',');
      if (orl.Reasons_List__c != null && orl.Reasons_List__c.trim() != '') {
        reasonList = orl.Reasons_List__c.split(';');
        set<string> reasonSet = new Set<string>(reasonList);
        reasonSet.remove('');
        reasonSet.remove(null);
        reasonList = new List<string>(reasonSet);
      }
      outcomeToReasonMap.put(orl.Status_Name__c, reasonList);
      outcomeValues.put(orl.Status_Name__c,orl.Status_Value__c);
    }
    wrap_reasonmap.outcomeWithReason = outcomeToReasonMap;
    wrap_reasonmap.outcomeWithValue = outcomeValues;

    return wrap_reasonmap;
  }

  @AuraEnabled
  public static PerDetailsWrap getPERdetails(Id perId) {
    Participant_Enrollment__c perList = [
      SELECT
        Id,
        Initial_visit_scheduled_date__c,
        Initial_visit_scheduled_time__c,
        Site_Communication_Preference__c,
        Initial_visit_occurred_flag__c,
        Initial_visit_occurred_date__c,
        Informed_Consent__c,
        Informed_Consent_Date__c,
        Non_Enrollment_Reason__c,
        Washout_Run_In_Applies__c,
        Revisit_Date__c,
        IVRS_IWRS__c,
        Visit_Plan__c,
        Final_consent__c,
        Screening_ID__c,
        Participant_Status__c,
        Study_Site__c,
        ParticipantNoShow__c,
        isBulkUpdate__c,
        Clinical_Trial_Profile__r.Initial_Visit_Required__c,
        Clinical_Trial_Profile__r.Final_Consent_Required__c,
        Clinical_Trial_Profile__r.Tokenization_Support__c,
        Participant__r.Gender__c,
        Add_televisit_for_Initial_Visit__c,
        Initial_Visit_Televisit_Created__c,
        Succesfully_Re_Engaged__c,
        Re_consent__c,
        Participant__r.First_Name__c,
        Participant__r.Last_Name__c,
        Participant_Contact__c,
        Participant__c,
        Participant__r.Adult__c,
        Participant__r.Email__c,
        PI_Contact__r.FirstName,
        PI_Contact__r.LastName,
        PI_Contact__c,
        Is_Participant_DOB_Valid__c,
        Clinical_Trial_Profile__r.Promote_to_SH__c,
        Study_Site__r.Study_Site_Type__c,
        Study_Site__r.E_Consent_Vendor__r.Vendor_URL__c,
        Study_Site__r.Clinical_Trial_Profile__r.E_Consent_Configuration__c,
        Study_Site__r.E_Consent_Vendor__c,
        Study_Site__r.E_Consent_Vendor__r.Name
      FROM Participant_Enrollment__c
      WHERE Id = :perId
    ];
    PerDetailsWrap perDetails = new PerDetailsWrap();
    perDetails.per = perList;
    perDetails.visitPlansList = getVisitPlansLVList(perList.Study_Site__c);
    return perDetails;
  }

  @AuraEnabled
  public static List<ReceivedHistoryWrap> getRecievedHistory(Id pe) {
    try {
      String title = '';
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<ReceivedHistoryWrap> wrapperList = new List<ReceivedHistoryWrap>();
      pehistory = [
        SELECT
          Id,
          Date__c,Name,
          Status__c,
          CreatedBy.Name,
          Additional_Notes__c, 
          Notes__c,
          CreatedBy.IsPortalEnabled,
          Status_Order__c,
          CreatedBy.contact.userCommunityMode__c
        FROM Participant_Enrollment_Status_History__c
        WHERE ParticipantEnrollment__c = :pe AND Status_Order__c = 1
        ORDER BY Name DESC
      ];
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
            ReceivedHistoryWrap wrap = new ReceivedHistoryWrap();
            title=System.Label.PWS_Received_History_Title;
            if (pesh.Notes__c != null) {
              title = title + ', ' + pesh.Notes__c;
            }
            wrap.historyTitle = title;
            wrap.detailDate = getUTCDateTime(pesh.Date__c);
            wrap.createdBy = PIR_StatusDetailController.getMasked(
              pesh.CreatedBy.IsPortalEnabled,
              pesh.CreatedBy.contact.userCommunityMode__c,
              pesh.CreatedBy.Name
            );
            wrapperList.add(wrap);
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  @AuraEnabled
  public static List<ContactHistoryWrap> getContactHistory(Id pe,String groupName) {
    try {
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<ContactHistoryWrap> wrapperList = new List<ContactHistoryWrap>();

      List<Participant_Enrollment__History> peh = new List<Participant_Enrollment__History>();
      List<Participant_Enrollment__History> pehstinitial = new List<Participant_Enrollment__History>();
      List<String> lstFOVhistory = new List<String>();
      lstFOVhistory.add('Initial_visit_scheduled_date__c');
      lstFOVhistory.add('Initial_visit_scheduled_time__c');
      List<Participant_Enrollment__c> partenroll = new List<Participant_Enrollment__c>();
      peh = [
        SELECT
          CreatedById,
          CreatedDate,
          CreatedBy.Name,
          Field,
          NewValue,
          OldValue,
          ParentId
        FROM Participant_Enrollment__History
        WHERE ParentId = :pe AND Field IN :lstFOVhistory
      ];
      List<String> cby = new List<String>();
      List<Datetime> cd = new List<Datetime>();

      List<User> ValidUserList = new List<User>();
      List<Id> ApiUsrList = new List<Id>();
      ValidUserList = [SELECT Id FROM User WHERE Profile.Name = 'API Only'];
      if (
        ValidUserList.size() != 0 &&
        !ValidUserList.isEmpty() &&
        ValidUserList != null
      ) {
        for (User us : ValidUserList) {
          ApiUsrList.add(us.id);
        }
      }

      if (peh.size() != 0 && !peh.isEmpty() && peh != null) {
        List<Datetime> lstDuphistory = new List<Datetime>();
        Set<Id> lstusr = new Set<Id>();
        List<User> lstusrRecord = new List<User>();
        Map<Id, String> mapUsrmsk = new Map<Id, String>();
        for (Participant_Enrollment__History phusrid : peh) {
          lstusr.add(phusrid.CreatedById);
        }
        lstusrRecord = [
          SELECT
            id,
            Name,
            IsPortalEnabled,
            ContactId,
            Contact.userCommunityMode__c
          FROM User
          WHERE id IN :lstusr
        ];
        for (User u : lstusrRecord) {
          if (
            ApiUsrList.size() != 0 &&
            !ApiUsrList.isEmpty() &&
            ApiUsrList != null
          ) {
            if (ApiUsrList.contains(u.id)) {
              mapUsrmsk.put(u.id, System.Label.chatbot);
            } else if (u.IsPortalEnabled) {
              if (
                u.ContactId != null &&
                u.Contact.userCommunityMode__c == 'CC'
              ) {
                mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
              } else {
                mapUsrmsk.put(u.id, u.Name);
              }
            } else {
              mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
            }
          } else {
            if (u.IsPortalEnabled) {
              if (
                u.ContactId != null &&
                u.Contact.userCommunityMode__c == 'CC'
              ) {
                mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
              } else {
                mapUsrmsk.put(u.id, u.Name);
              }
            } else {
              mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
            }
          }
        }
        for (Participant_Enrollment__History ph : peh) {
          if (!lstDuphistory.contains(ph.CreatedDate)) {
            cby.add(mapUsrmsk.get(ph.CreatedById));
            cd.add(ph.CreatedDate);
            lstDuphistory.add(ph.CreatedDate);
          }
        }
        Boolean onRecordcreation = false;
        pehstinitial = [
          SELECT
            CreatedById,
            CreatedDate,
            CreatedBy.Name,
            Field,
            NewValue,
            OldValue,
            ParentId
          FROM Participant_Enrollment__History
          WHERE ParentId = :pe AND Field IN :lstFOVhistory
          ORDER BY CreatedDate ASC
          LIMIT 1
        ];
        for (Participant_Enrollment__History phOld : pehstinitial) {
          if (phOld.OldValue != null) {
            onRecordcreation = true;
          }
        }
        if (onRecordcreation) {
          Participant_Enrollment__c penrollmnt = [
            SELECT
              id,
              Initial_visit_scheduled_date__c,
              Initial_visit_scheduled_time__c,
              CreatedDate,
              CreatedById,
              CreatedBy.IsPortalEnabled,
              CreatedBy.contact.userCommunityMode__c,
              CreatedBy.Name,
              CreatedBy.ContactId
            FROM Participant_Enrollment__c
            WHERE id = :pe
          ];

          if (
            ApiUsrList.size() != 0 &&
            !ApiUsrList.isEmpty() &&
            ApiUsrList != null
          ) {
            if (ApiUsrList.contains(penrollmnt.CreatedById)) {
              cby.add(System.Label.chatbot);
              cd.add(penrollmnt.CreatedDate);
            } else if (penrollmnt.CreatedBy.IsPortalEnabled) {
              if (
                penrollmnt.CreatedBy.contact != null &&
                penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'
              ) {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(penrollmnt.CreatedDate);
              } else {
                cby.add(penrollmnt.CreatedBy.Name);
                cd.add(penrollmnt.CreatedDate);
              }
            } else {
              cby.add(System.Label.RH_Masked_IQVIA_User);
              cd.add(penrollmnt.CreatedDate);
            }
          } else {
            if (penrollmnt.CreatedBy.IsPortalEnabled) {
              if (
                penrollmnt.CreatedBy.contact != null &&
                penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'
              ) {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(penrollmnt.CreatedDate);
              } else {
                cby.add(penrollmnt.CreatedBy.Name);
                cd.add(penrollmnt.CreatedDate);
              }
            } else {
              cby.add(System.Label.RH_Masked_IQVIA_User);
              cd.add(penrollmnt.CreatedDate);
            }
          }
        }
        for (Integer i = 0; i < cby.size(); i++) {
          ContactHistoryWrap wrapfov = new ContactHistoryWrap();
          wrapfov.historyTitle = Label.Initial_Visit_modified;
          wrapfov.detailDate = cd[i].format('YYYY-MM-dd hh:mm:ss a');
          wrapfov.CreatedBy = cby[i];
          wrapfov.isFovHistory = true;
          wrapfov.isAdditionalNote = false;
          wrapfov.isAdditionalNoteOld = false;
          wrapperList.add(wrapfov);
        }
      } else {
        partenroll = [
          SELECT
            id,
            Initial_visit_scheduled_date__c,
            Initial_visit_scheduled_time__c,
            CreatedDate,
            CreatedById,
            CreatedBy.IsPortalEnabled,
            CreatedBy.contact.userCommunityMode__c,
            CreatedBy.Name,
            CreatedBy.ContactId
          FROM Participant_Enrollment__c
          WHERE
            id = :pe
            AND (Initial_visit_scheduled_date__c != NULL
            OR Initial_visit_scheduled_time__c != NULL)
        ];
        if (
          partenroll.size() != 0 &&
          !partenroll.isEmpty() &&
          partenroll != null
        ) {
          for (Participant_Enrollment__c per : partenroll) {
            if (
              ApiUsrList.size() != 0 &&
              !ApiUsrList.isEmpty() &&
              ApiUsrList != null
            ) {
              if (ApiUsrList.contains(per.CreatedById)) {
                cby.add(System.Label.chatbot);
                cd.add(per.CreatedDate);
              } else if (per.CreatedBy.IsPortalEnabled) {
                if (
                  per.CreatedBy.contact != null &&
                  per.CreatedBy.Contact.userCommunityMode__c == 'CC'
                ) {
                  cby.add(System.Label.RH_Masked_IQVIA_User);
                  cd.add(per.CreatedDate);
                } else {
                  cby.add(per.CreatedBy.Name);
                  cd.add(per.CreatedDate);
                }
              } else {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(per.CreatedDate);
              }
            } else {
              if (per.CreatedBy.IsPortalEnabled) {
                if (
                  per.CreatedBy.contact != null &&
                  per.CreatedBy.Contact.userCommunityMode__c == 'CC'
                ) {
                  cby.add(System.Label.RH_Masked_IQVIA_User);
                  cd.add(per.CreatedDate);
                } else {
                  cby.add(per.CreatedBy.Name);
                  cd.add(per.CreatedDate);
                }
              } else {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(per.CreatedDate);
              }
            }
          }
          for (Integer i = 0; i < cby.size(); i++) {
            ContactHistoryWrap wrapfov = new ContactHistoryWrap();
            wrapfov.historyTitle = Label.Initial_Visit_modified;
            wrapfov.detailDate = cd[i].format('YYYY-MM-dd hh:mm:ss a');
            wrapfov.CreatedBy = cby[i];
            wrapfov.isFovHistory = true;
            wrapfov.isAdditionalNote = false;
            wrapfov.isAdditionalNoteOld = false;
            wrapperList.add(wrapfov);
          }
        }
      }

      Participant_Enrollment__c per = new Participant_Enrollment__c();
      per = [select Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Initial_Visit_Required__c,Clinical_Trial_Profile__r.Promote_to_SH__c
              from Participant_Enrollment__c where Id=:pe];
      if(per.Clinical_Trial_Profile__r.Initial_Visit_Required__c &&
         per.Clinical_Trial_Profile__r.Promote_to_SH__c){
                     pehistory = [
                SELECT
                  Id,
                  Date__c,Name,
                  Status_Order__c,
                  toLabel(Status__c),
                  toLabel(Non_Enrollment_Reason__c),
                  Notes__c,
                  CreatedBy.Name,
                  Additional_Notes__c,
                  CreatedBy.IsPortalEnabled,
                  CreatedBy.contact.userCommunityMode__c,
                  Status_Label__c,
                  ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c,
                  ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_To_SH__c
                FROM Participant_Enrollment_Status_History__c
                WHERE
                  ParticipantEnrollment__c = :pe
                  AND (Status_Order__c = 2 OR Status_Order__c = 3
                  OR Status_Order__c = 1)
                ORDER BY Name DESC
              ];
       }else{
       
      pehistory = [
        SELECT
          Id,
          Date__c,Name,
          Status_Order__c,
          toLabel(Status__c),
          toLabel(Non_Enrollment_Reason__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c,
          CreatedBy.IsPortalEnabled,
          CreatedBy.contact.userCommunityMode__c,
          Status_Label__c,
          ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c,
          ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_To_SH__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :pe
          AND (Status_Order__c = 2 
          OR Status_Order__c = 1)
        ORDER BY Name DESC
      ];
      }
      Integer K = 0;
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
        
        if (pesh.Status_Order__c != 1) {
         if (groupName == 'PWS_Contact_Name' ? (pesh.Additional_Notes__c != null && pesh.Additional_Notes__c != '') : (pesh.Additional_Notes__c != null &&    pesh.Additional_Notes__c != '' &&
             pesh.Status_Label__c != 'Successfully_Contacted')
          ){
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              ContactHistoryWrap wrapp = new ContactHistoryWrap();
              Integer startOfOnLabel = note.lastIndexOfIgnoreCase(' ' + Label.PE_Status_History_On_Date + ' ');
              string singlenote='';
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              if(startOfOnLabel>0){
                  singlenote = note.substring(0, startOfOnLabel);
                  wrapp.historyTitle = singlenote;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                   }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                  }
              }else{
                   //wrapp.historyTitle = note;
                   if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                   }else{
                       wrapp.historyTitle = note;
                   }
              }
              wrapp.isAdditionalNote = true;
              wrapp.isAdditionalNoteOld = false;
              wrapp.noteKey= K;
              wrapp.isFovHistory = false;
              wrapperList.add(wrapp);
            }

            /**  ---- 
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              ContactHistoryWrap wrapp = new ContactHistoryWrap();
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              Integer startOfOnLabeltxt = note.lastIndexOfIgnoreCase(
                ' ' +
                Label.PE_Status_History_On_Date +
                ' '
              );
               if(startOfOnLabeltxt>0){
                  string title = note.substring(0, startOfOnLabeltxt);
                  wrapp.historyTitle = title;
                  string notedetails = note.substring(
                    startOfOnLabeltxt,
                    note.length()
                  );
                  Integer startOfOnLabelcby = notedetails.lastIndexOfIgnoreCase(
                    ' ' +
                    Label.PG_IMI_L_by_user +
                    ' '
                  );
                  string createdby='';
                  if(startOfIQVIA>0){
                       createdby = Label.RH_Masked_Display_IQVIA_User;
                  }else{
                       createdby = notedetails.substring(
                        startOfOnLabelcby + 4,
                        notedetails.length()
                      );
                  }
                  wrapp.createdBy = createdby;
                  string notedetailsdt = notedetails.substring(
                    4,
                    startOfOnLabelcby
                  );
                  wrapp.noteDetailsdt = notedetailsdt;
              }else{
                  wrapp.historyTitle = note;
              }
              wrapp.isAdditionalNote = true;
              wrapp.isFovHistory = false;
              wrapperList.add(wrapp);
            }
            ----  **/
            
          }
          String title = '';
          ContactHistoryWrap wrap = new ContactHistoryWrap();
          if(pesh.Status__c == 'Successfully re-engaged'){
              String sc = 'Successfully Re-Engaged';
              title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,sc);
          }else if(pesh.Status__c == 'Eligibility Passed') {
              if(pesh.ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_To_SH__c && pesh.ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c!='Traditional'){ 
                title = Label.Sent_to_Study_Hub;
              }else{
                 title = TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
              }
         }else{
            title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
        }
            if (pesh.Non_Enrollment_Reason__c != null) {
            //title = title + ' - ' + pesh.Non_Enrollment_Reason__c;
            title = title + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Non_Enrollment_Reason__c.trim());
          }
          if (pesh.Notes__c != null) {
            title = title + ', ' + pesh.Notes__c;
          }
          wrap.historyTitle = title;
          wrap.detailDate = pesh.Date__c.format('YYYY-MM-dd hh:mm:ss a');
          wrap.createdBy = PIR_StatusDetailController.getMasked(
            pesh.CreatedBy.IsPortalEnabled,
            pesh.CreatedBy.contact.userCommunityMode__c,
            pesh.CreatedBy.Name
          );
          wrap.isAdditionalNote = false;
          wrap.isAdditionalNoteOld = false;
          wrap.noteKey= K;
          wrap.isFovHistory = false;
          wrapperList.add(wrap);
        } else {
          if (
            pesh.Additional_Notes__c != null &&
            pesh.Additional_Notes__c != ''
          ) {
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              ContactHistoryWrap wrapp = new ContactHistoryWrap();
              Integer startOfOnLabel = note.lastIndexOfIgnoreCase(' ' + Label.PE_Status_History_On_Date + ' ');
              string singlenote='';
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              if(startOfOnLabel>0){
                  singlenote = note.substring(0, startOfOnLabel);
                  wrapp.historyTitle = singlenote;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                   }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                  }
              }else{
                   //wrapp.historyTitle = note;
                   if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                   }else{
                       wrapp.historyTitle = note;
                   }
              }
              wrapp.isAdditionalNote = true;
              wrapp.isAdditionalNoteOld = true;
              wrapp.noteKey= K;
              wrapp.isFovHistory = false;
              wrapperList.add(wrapp);
            }

            /**  -----
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              ContactHistoryWrap wrapp = new ContactHistoryWrap();
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              Integer startOfOnLabeltxt = note.lastIndexOfIgnoreCase(
                ' ' +
                Label.PE_Status_History_On_Date +
                ' '
              );
              if(startOfOnLabeltxt>0){
                  string title = note.substring(0, startOfOnLabeltxt);
                  wrapp.historyTitle = title;
                  string notedetails = note.substring(
                    startOfOnLabeltxt,
                    note.length()
                  );
                  Integer startOfOnLabelcby = notedetails.lastIndexOfIgnoreCase(
                    ' ' +
                    Label.PG_IMI_L_by_user +
                    ' '
                  );
                   string  createdby ='';
                   if(startOfIQVIA>0){
                       createdby = Label.RH_Masked_Display_IQVIA_User;
                  }else{
                       createdby = notedetails.substring(
                        startOfOnLabelcby + 4,
                        notedetails.length()
                      );
                  }
                  wrapp.createdBy = createdby;
                  string notedetailsdt = notedetails.substring(
                    4,
                    startOfOnLabelcby
                  );
                  wrapp.noteDetailsdt = notedetailsdt;
              }else{
                  wrapp.historyTitle = note;
              }
              
              wrapp.isAdditionalNote = true;
              wrapp.isFovHistory = false;
              wrapperList.add(wrapp);
            }
            ----  **/
            
          }
        }
        K++;
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  @AuraEnabled
  public static List<EligibilityHistoryWrap> getEligibilityHistory(Id pe) {
    try {
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<EligibilityHistoryWrap> wrapperList = new List<EligibilityHistoryWrap>();
      pehistory = [
        SELECT
          Id,
          Date__c,Name,
          Status_Order__c,
          toLabel(Status__c),
          toLabel(Non_Enrollment_Reason__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c,
          CreatedBy.IsPortalEnabled,
          CreatedBy.contact.userCommunityMode__c,
          Status_Label__c,
          ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c,
          ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_To_SH__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :pe
          AND (Status_Order__c = 2
          OR Status_Order__c = 3)
        ORDER BY Name DESC
      ];
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
        if (pesh.Status_Order__c != 2) {
          if (
            pesh.Additional_Notes__c != null &&
            pesh.Additional_Notes__c != '' &&
            pesh.Status_Label__c != 'Eligibility_Passed'
          ) {
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              EligibilityHistoryWrap wrapp = new EligibilityHistoryWrap();
              
              Integer startOfOnLabel = note.lastIndexOfIgnoreCase(' ' + Label.PE_Status_History_On_Date + ' ');
              string singlenote='';
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              if(startOfOnLabel>0){
                  singlenote = note.substring(0, startOfOnLabel);
                  wrapp.historyTitle = singlenote;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                   }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                  }
              }else{
                  //wrapp.historyTitle = note;
                  if(startOfIQVIA>0){
                    wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                 }else{
                     wrapp.historyTitle = note;
                 }
              }
              wrapp.isAdditionalNote = true;
              wrapperList.add(wrapp);
            }
          }
          String title = '';
          EligibilityHistoryWrap wrap = new EligibilityHistoryWrap();
          if (pesh.Status__c == 'Eligibility Passed') {
              if(pesh.ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_To_SH__c && pesh.ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c!='Traditional'){ 
                  title = Label.Sent_to_Study_Hub;
              }else{
                  title = Label.Eligibility_Passed_Status_Value;
              }
          } else {
            //title = pesh.Status__c;
            title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
          }
          if (pesh.Non_Enrollment_Reason__c != null) {
            title = title + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Non_Enrollment_Reason__c.trim());
          }
          if (pesh.Notes__c != null) {
            title = title + ', ' + pesh.Notes__c;
          }
          wrap.historyTitle = title;
          wrap.detailDate = getUTCDateTime(pesh.Date__c);
          wrap.createdBy = PIR_StatusDetailController.getMasked(
            pesh.CreatedBy.IsPortalEnabled,
            pesh.CreatedBy.contact.userCommunityMode__c,
            pesh.CreatedBy.Name
          );
          wrap.isAdditionalNote = false;
          wrapperList.add(wrap);
        } else {
          if (pesh.Status_Label__c == 'Successfully_Contacted') {
            if (
              pesh.Additional_Notes__c != null &&
              pesh.Additional_Notes__c != ''
            ) {
              List<String> lstnotes = new List<String>();
              lstnotes = pesh.Additional_Notes__c.split('#');
              for (String note : lstnotes) {
                EligibilityHistoryWrap wrapp = new EligibilityHistoryWrap();
                Integer startOfOnLabel = note.lastIndexOfIgnoreCase(' ' + Label.PE_Status_History_On_Date + ' ');
                string singlenote='';
                Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
                if(startOfOnLabel>0){
                    singlenote = note.substring(0, startOfOnLabel);
                    wrapp.historyTitle = singlenote;
                    if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                     }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                     }
                 }else{
                  //wrapp.historyTitle = note;
                  if(startOfIQVIA>0){
                     wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                  }else{
                      wrapp.historyTitle = note;
                  }
            }
                wrapp.isAdditionalNote = true;
                wrapperList.add(wrapp);
              }
            }
          }
        }
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  @AuraEnabled
  public static List<InitialVistHistoryWrap> getInitialVisitHistory(Id pe) {
    try {
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<InitialVistHistoryWrap> wrapperList = new List<InitialVistHistoryWrap>();
      pehistory = [
        SELECT
          Id,Name,
          Status_Order__c,
          toLabel(Status__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :pe
          AND Status_Order__c = 2
          AND Status_Label__c = 'Successfully_Contacted'
        ORDER BY Name DESC
      ];
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
        if (
          pesh.Additional_Notes__c != null &&
          pesh.Additional_Notes__c != ''
        ) {
          List<String> lstnotes = new List<String>();
          lstnotes = pesh.Additional_Notes__c.split('#');
          for (String note : lstnotes) {
            InitialVistHistoryWrap wrapp = new InitialVistHistoryWrap();
            Integer startOfOnLabel = note.lastIndexOfIgnoreCase(
              ' ' +
              Label.PE_Status_History_On_Date +
              ' '
            );
            Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
            if(startOfOnLabel>0){
                string singlenote = note.substring(0, startOfOnLabel);
                wrapp.notes = singlenote;
                if(startOfIQVIA>0){
                      wrapp.notesDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                 }else{
                       wrapp.notesDetails = note.substring(startOfOnLabel, note.length());
                }
              }else{
                  //wrapp.notes = note;
                  if(startOfIQVIA>0){
                    wrapp.notesDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                 }else{
                    wrapp.notes = note;
                 }
              }
            wrapperList.add(wrapp);
          }
        }
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  @AuraEnabled
  public static List<ScreeningHistoryWrap> getScreeningHistory(Id pe) {
    try {
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<ScreeningHistoryWrap> wrapperList = new List<ScreeningHistoryWrap>();
      
      /** consent yes history start **/
      
      List<Participant_Enrollment__History> pehList = new List<Participant_Enrollment__History>();
      List<Participant_Enrollment__History> peh = new List<Participant_Enrollment__History>();
      List<Participant_Enrollment__History> pehstinitial = new List<Participant_Enrollment__History>();
      List<String> lstFOVhistory = new List<String>();
      lstFOVhistory.add('Informed_Consent__c');
      List<Participant_Enrollment__c> partenroll = new List<Participant_Enrollment__c>();
      pehList = [
        SELECT
          CreatedById,
          CreatedDate,
          CreatedBy.Name,
          Field,
          NewValue,
          OldValue,
          ParentId
        FROM Participant_Enrollment__History
        WHERE ParentId = :pe AND Field IN :lstFOVhistory
      ];
      for (Participant_Enrollment__History phs : pehList) {
          if (phs.NewValue == true) {
            peh.add(phs);
          }
       }
      
      List<String> cby = new List<String>();
      List<Datetime> cd = new List<Datetime>();

      List<User> ValidUserList = new List<User>();
      List<Id> ApiUsrList = new List<Id>();
      ValidUserList = [SELECT Id FROM User WHERE Profile.Name = 'API Only'];
      if (
        ValidUserList.size() != 0 &&
        !ValidUserList.isEmpty() &&
        ValidUserList != null
      ) {
        for (User us : ValidUserList) {
          ApiUsrList.add(us.id);
        }
      }
       
      if (peh.size() != 0 && !peh.isEmpty() && peh != null) {
        List<Datetime> lstDuphistory = new List<Datetime>();
        Set<Id> lstusr = new Set<Id>();
        List<User> lstusrRecord = new List<User>();
        Map<Id, String> mapUsrmsk = new Map<Id, String>();
        for (Participant_Enrollment__History phusrid : peh) {
          lstusr.add(phusrid.CreatedById);
        }
        lstusrRecord = [
          SELECT
            id,
            Name,
            IsPortalEnabled,
            ContactId,
            Contact.userCommunityMode__c
          FROM User
          WHERE id IN :lstusr
        ];
        for (User u : lstusrRecord) {
          if (
            ApiUsrList.size() != 0 &&
            !ApiUsrList.isEmpty() &&
            ApiUsrList != null
          ) {
            if (ApiUsrList.contains(u.id)) {
              mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
            } else if (u.IsPortalEnabled) {
              if (
                u.ContactId != null &&
                u.Contact.userCommunityMode__c == 'CC'
              ) {
                mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
              } else {
                mapUsrmsk.put(u.id, u.Name);
              }
            } else {
              mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
            }
          } else {
            if (u.IsPortalEnabled) {
              if (
                u.ContactId != null &&
                u.Contact.userCommunityMode__c == 'CC'
              ) {
                mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
              } else {
                mapUsrmsk.put(u.id, u.Name);
              }
            } else {
              mapUsrmsk.put(u.id, System.Label.RH_Masked_IQVIA_User);
            }
          }
        }
        for (Participant_Enrollment__History ph : peh) {
          if (!lstDuphistory.contains(ph.CreatedDate)) {
            cby.add(mapUsrmsk.get(ph.CreatedById));
            cd.add(ph.CreatedDate);
            lstDuphistory.add(ph.CreatedDate);
          }
        }
        Boolean onRecordcreation = false;
        pehstinitial = [
          SELECT
            CreatedById,
            CreatedDate,
            CreatedBy.Name,
            Field,
            NewValue,
            OldValue,
            ParentId
          FROM Participant_Enrollment__History
          WHERE ParentId = :pe AND Field IN :lstFOVhistory 
          ORDER BY CreatedDate ASC
          LIMIT 1
        ];
        for (Participant_Enrollment__History phOld : pehstinitial) {
          if (phOld.OldValue == true) {
            onRecordcreation = true;
          }
        }
        if (onRecordcreation) {
          Participant_Enrollment__c penrollmnt = [
            SELECT
              id,
              Informed_Consent__c,
              CreatedDate,
              CreatedById,
              CreatedBy.IsPortalEnabled,
              CreatedBy.contact.userCommunityMode__c,
              CreatedBy.Name,
              CreatedBy.ContactId
            FROM Participant_Enrollment__c
            WHERE id = :pe
          ];

          if (
            ApiUsrList.size() != 0 &&
            !ApiUsrList.isEmpty() &&
            ApiUsrList != null
          ) {
            if (ApiUsrList.contains(penrollmnt.CreatedById)) {
              cby.add(System.Label.RH_Masked_IQVIA_User);
              cd.add(penrollmnt.CreatedDate);
            } else if (penrollmnt.CreatedBy.IsPortalEnabled) {
              if (
                penrollmnt.CreatedBy.contact != null &&
                penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'
              ) {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(penrollmnt.CreatedDate);
              } else {
                cby.add(penrollmnt.CreatedBy.Name);
                cd.add(penrollmnt.CreatedDate);
              }
            } else {
              cby.add(System.Label.RH_Masked_IQVIA_User);
              cd.add(penrollmnt.CreatedDate);
            }
          } else {
            if (penrollmnt.CreatedBy.IsPortalEnabled) {
              if (
                penrollmnt.CreatedBy.contact != null &&
                penrollmnt.CreatedBy.Contact.userCommunityMode__c == 'CC'
              ) {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(penrollmnt.CreatedDate);
              } else {
                cby.add(penrollmnt.CreatedBy.Name);
                cd.add(penrollmnt.CreatedDate);
              }
            } else {
              cby.add(System.Label.RH_Masked_IQVIA_User);
              cd.add(penrollmnt.CreatedDate);
            }
          }
        }
        for (Integer i = 0; i < cby.size(); i++) {
          ScreeningHistoryWrap wraphistory = new ScreeningHistoryWrap();
          wraphistory.historyTitle = System.Label.Consent_Signed;
          wraphistory.detailDate = cd[i].format('YYYY-MM-dd hh:mm:ss a');
          wraphistory.CreatedBy = cby[i];
          wraphistory.isAdditionalNote = false;
          wrapperList.add(wraphistory);
        }
      } else {
        partenroll = [
          SELECT
            id,
            Informed_Consent__c,
            CreatedDate,
            CreatedById,
            CreatedBy.IsPortalEnabled,
            CreatedBy.contact.userCommunityMode__c,
            CreatedBy.Name,
            CreatedBy.ContactId
          FROM Participant_Enrollment__c
          WHERE
            id = :pe
            AND Informed_Consent__c = true
        ];
        if (
          partenroll.size() != 0 &&
          !partenroll.isEmpty() &&
          partenroll != null
        ) {
          for (Participant_Enrollment__c per : partenroll) {
            if (
              ApiUsrList.size() != 0 &&
              !ApiUsrList.isEmpty() &&
              ApiUsrList != null
            ) {
              if (ApiUsrList.contains(per.CreatedById)) {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(per.CreatedDate);
              } else if (per.CreatedBy.IsPortalEnabled) {
                if (
                  per.CreatedBy.contact != null &&
                  per.CreatedBy.Contact.userCommunityMode__c == 'CC'
                ) {
                  cby.add(System.Label.RH_Masked_IQVIA_User);
                  cd.add(per.CreatedDate);
                } else {
                  cby.add(per.CreatedBy.Name);
                  cd.add(per.CreatedDate);
                }
              } else {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(per.CreatedDate);
              }
            } else {
              if (per.CreatedBy.IsPortalEnabled) {
                if (
                  per.CreatedBy.contact != null &&
                  per.CreatedBy.Contact.userCommunityMode__c == 'CC'
                ) {
                  cby.add(System.Label.RH_Masked_IQVIA_User);
                  cd.add(per.CreatedDate);
                } else {
                  cby.add(per.CreatedBy.Name);
                  cd.add(per.CreatedDate);
                }
              } else {
                cby.add(System.Label.RH_Masked_IQVIA_User);
                cd.add(per.CreatedDate);
              }
            }
          }
          for (Integer i = 0; i < cby.size(); i++) {
            ScreeningHistoryWrap wraphistory = new ScreeningHistoryWrap();
            wraphistory.historyTitle = System.Label.Consent_Signed;
            wraphistory.detailDate = cd[i].format('YYYY-MM-dd hh:mm:ss a');
            wraphistory.CreatedBy = cby[i];
            wraphistory.isAdditionalNote = false;
            wrapperList.add(wraphistory);
          }
        }
      }
      
      /** consent yes history end **/
      
      pehistory = [
        SELECT
          Id,Name,
          Date__c,
          Status_Order__c,
          toLabel(Status__c),
          toLabel(Non_Enrollment_Reason__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c,
          CreatedBy.IsPortalEnabled,
          CreatedBy.contact.userCommunityMode__c,
          Status_Label__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :pe
          AND (Status_Order__c = 4
          OR Status_Order__c = 3)
        ORDER BY Name DESC
      ];
       Integer K = 0;
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
        if (pesh.Status_Order__c != 3) {
          if (
            pesh.Additional_Notes__c != null &&
            pesh.Additional_Notes__c != '' &&
            pesh.Status_Label__c != 'Screening_Passed'
          ) {
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              ScreeningHistoryWrap wrapp = new ScreeningHistoryWrap();
              Integer startOfOnLabel = note.lastIndexOfIgnoreCase(
                ' ' +
                Label.PE_Status_History_On_Date +
                ' '
              );
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              if(startOfOnLabel>0){
                  string singlenote = note.substring(0, startOfOnLabel);
                  wrapp.historyTitle = singlenote;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                  }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                  }    
                }else{
                  //wrapp.historyTitle = note;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                  }else{
                      wrapp.historyTitle = note;
                  }
                }      
              wrapp.isAdditionalNote = true;
              wrapp.noteKey= K;
              wrapperList.add(wrapp);
            }
          }
          String title = '';
          ScreeningHistoryWrap wrap = new ScreeningHistoryWrap();
          //title = pesh.Status__c;
          title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
          if (pesh.Non_Enrollment_Reason__c != null) {
            title = title + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Non_Enrollment_Reason__c.trim());
          }
          if (pesh.Notes__c != null) {
            title = title + ', ' + pesh.Notes__c;
          }
          wrap.historyTitle = title;
          wrap.detailDate = pesh.Date__c.format('YYYY-MM-dd hh:mm:ss a');
          wrap.createdBy = PIR_StatusDetailController.getMasked(
            pesh.CreatedBy.IsPortalEnabled,
            pesh.CreatedBy.contact.userCommunityMode__c,
            pesh.CreatedBy.Name
          );
          wrap.isAdditionalNote = false;
          wrap.noteKey= K;
          wrapperList.add(wrap);
        } else { 
          if (pesh.Status_Label__c == 'Eligibility_Passed') {
            if (
              pesh.Additional_Notes__c != null &&
              pesh.Additional_Notes__c != ''
            ) {
              List<String> lstnotes = new List<String>();
              lstnotes = pesh.Additional_Notes__c.split('#');
              for (String note : lstnotes) {
                ScreeningHistoryWrap wrapp = new ScreeningHistoryWrap();
                Integer startOfOnLabel = note.lastIndexOfIgnoreCase(
                  ' ' +
                  Label.PE_Status_History_On_Date +
                  ' '
                );
                Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
                if(startOfOnLabel>0){
                    string singlenote = note.substring(0, startOfOnLabel);
                    wrapp.historyTitle = singlenote;
                    if(startOfIQVIA>0){
                         wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                     }else{
                         wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                    }  
                  }else{
                      //wrapp.historyTitle = note;
                      if(startOfIQVIA>0){
                        wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                    }else{
                        wrapp.historyTitle = note;
                    }
                  }
                wrapp.isAdditionalNote = true;
                 wrapp.noteKey= K;
                wrapperList.add(wrapp);
              }
            }
          }
        }
         K++;
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  @AuraEnabled
  public static List<EnrollmentHistoryWrap> getEnrollmentHistory(Id pe) {
    try {
      List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
      List<EnrollmentHistoryWrap> wrapperList = new List<EnrollmentHistoryWrap>();
      pehistory = [
        SELECT
          Id,Name,
          Date__c,
          Status_Order__c,
          toLabel(Status__c),
          toLabel(Non_Enrollment_Reason__c),
          Notes__c,
          CreatedBy.Name,
          Additional_Notes__c,
          CreatedBy.IsPortalEnabled,
          CreatedBy.contact.userCommunityMode__c,
          Status_Label__c
        FROM Participant_Enrollment_Status_History__c
        WHERE
          ParticipantEnrollment__c = :pe
          AND (Status_Order__c = 4
          OR Status_Order__c = 5)
        ORDER BY Name DESC
      ];
      for (Participant_Enrollment_Status_History__c pesh : pehistory) {
        if (pesh.Status_Order__c != 4) {
          if (
            pesh.Additional_Notes__c != null &&
            pesh.Additional_Notes__c != ''
          ) {
            List<String> lstnotes = new List<String>();
            lstnotes = pesh.Additional_Notes__c.split('#');
            for (String note : lstnotes) {
              EnrollmentHistoryWrap wrapp = new EnrollmentHistoryWrap();
              Integer startOfOnLabel = note.lastIndexOfIgnoreCase(
                ' ' +
                Label.PE_Status_History_On_Date +
                ' '
              );
              Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
              if(startOfOnLabel>0){
                  string singlenote = note.substring(0, startOfOnLabel);
                  wrapp.historyTitle = singlenote;
                  if(startOfIQVIA>0){
                      wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                  }else{
                       wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                  }
                }else{
                  //wrapp.historyTitle = note;
                  if(startOfIQVIA>0){
                    wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                  }else{
                        wrapp.historyTitle = note;
                  } 
                }  
              wrapp.isAdditionalNote = true;
              wrapperList.add(wrapp);
            }
          }
          String title = '';
          EnrollmentHistoryWrap wrap = new EnrollmentHistoryWrap();
          //title = pesh.Status__c;
          title =TranslateHelper.getPickListLabel(Participant_Enrollment__c.Participant_Status__c,pesh.Status__c);
          if (pesh.Non_Enrollment_Reason__c != null) {
            title = title + ' - ' + TranslateHelper.getPickListLabel(Participant_Enrollment__c.Non_Enrollment_Reason__c,pesh.Non_Enrollment_Reason__c.trim());
          }
          if (pesh.Notes__c != null) {
            title = title + ', ' + pesh.Notes__c;
          }
          wrap.historyTitle = title;
          wrap.detailDate = getUTCDateTime(pesh.Date__c);
          wrap.createdBy = PIR_StatusDetailController.getMasked(
            pesh.CreatedBy.IsPortalEnabled,
            pesh.CreatedBy.contact.userCommunityMode__c,
            pesh.CreatedBy.Name
          );
          wrap.isAdditionalNote = false;
          wrapperList.add(wrap);
        } else {
          if (pesh.Status_Label__c == 'Screening_Passed') {
            if (
              pesh.Additional_Notes__c != null &&
              pesh.Additional_Notes__c != ''
            ) {
              List<String> lstnotes = new List<String>();
              lstnotes = pesh.Additional_Notes__c.split('#');
              for (String note : lstnotes) {
                EnrollmentHistoryWrap wrapp = new EnrollmentHistoryWrap();
                Integer startOfOnLabel = note.lastIndexOfIgnoreCase(
                  ' ' +
                  Label.PE_Status_History_On_Date +
                  ' '
                );
                Integer startOfIQVIA = note.lastIndexOfIgnoreCase('('+Label.RH_Masked_IQVIA_User+')');
                if(startOfOnLabel>0){
                    string singlenote = note.substring(0, startOfOnLabel);
                    wrapp.historyTitle = singlenote;
                    if(startOfIQVIA>0){
                         wrapp.noteDetails = note.substring(startOfOnLabel,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                     }else{
                        wrapp.noteDetails = note.substring(startOfOnLabel, note.length());
                    } 
                 }else{
                      //wrapp.historyTitle = note;
                      if(startOfIQVIA>0){
                        wrapp.noteDetails = note.substring(0,startOfIQVIA) + ' ' + Label.RH_Masked_Display_IQVIA_User;
                      }else{
                            wrapp.historyTitle = note;
                      } 
                 }
                wrapp.isAdditionalNote = true;
                wrapperList.add(wrapp);
              }
            }
          }
        }
      }
      return wrapperList;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  public static String getMasked(
    Boolean IsPortalEnabled,
    String userCommunityMode,
    String Name
  ) {
    if (IsPortalEnabled == true) {
      if (userCommunityMode == 'CC') {
        return System.Label.RH_Masked_IQVIA_User;
      } else {
        return Name;
      }
    } else {
      return System.Label.RH_Masked_IQVIA_User;
    }
  }
  public static DateTime getUTCDateTime(DateTime dt) {
    Datetime GMTDate = Datetime.newInstanceGmt(
      dt.year(),
      dt.month(),
      dt.day(),
      dt.hour(),
      dt.minute(),
      dt.second()
    );
    return GMTDate;
  }
  @AuraEnabled
  public static BubbleMapWrap getBubbleStatus(Id perId) {
    try {
      List<BubbleMapDetails> bubbledetails = new List<BubbleMapDetails>();
      List<Participant_Enrollment_Status_History__c> pesh = new List<Participant_Enrollment_Status_History__c>();
      Participant_Enrollment__c sobjPER = [
        SELECT Id, Participant_Status__c,Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c
        FROM Participant_Enrollment__c
        WHERE id = :perId
      ];
      List<String> lstofStatus = new List<String>();
      if(sobjPER.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Randomization'){
          lstofStatus.add('Randomization Success');
          lstofStatus.add('Treatment Period Started');
          lstofStatus.add('Follow-Up Period Started');
          lstofStatus.add('Participation Complete');
          lstofStatus.add('Trial Complete'); 
      }else{
          lstofStatus.add('Enrollment Success');
          lstofStatus.add('Treatment Period Started');
          lstofStatus.add('Follow-Up Period Started');
          lstofStatus.add('Participation Complete');
          lstofStatus.add('Trial Complete'); 
      }
      String perStatus = sobjPER.Participant_Status__c;
      BubbleMapWrap bubblewrp = new BubbleMapWrap();
      bubblewrp.isBubbleMapRequired = lstofStatus.contains(perStatus);
      if (lstofStatus.contains(perStatus)) {
        Integer J = lstofStatus.indexOf(perStatus);
        Integer K = 0;
        for (Integer i = 0; i < 5; i++) {
          BubbleMapDetails bmd = new BubbleMapDetails();
          if (i <= J) {
            bmd.isStatusPassed = true;
            if (i == 0) {
                if(sobjPER.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Randomization'){
                     bmd.pathName = Label.Randomization_Success;
                }else{
                     bmd.pathName = Label.Enrollment_Success;
                }
            } else if (i == 1) {
              bmd.pathName = Label.PE_STATUS_TREATMENT_PERIOD_STARTED;
            } else if (i == 2) {
              bmd.pathName = Label.PE_STATUS_FOLLOW_UP_PERIOD_STARTED;
            } else if (i == 3) {
              bmd.pathName = Label.PIR_Participation_Complete;
            } else {
              bmd.pathName = Label.PIR_Trial_Complete;
            }
            bmd.styleName = 'slds-col width-basis vpi-line-div neutral';
            if(i == j){
                bmd.styleName_1 = 'slds-col width-basis vpi-state success current';
            }else{
                bmd.styleName_1 = 'slds-col width-basis vpi-state success';
            }
            bubbledetails.add(bmd);
          } else {
            bmd.isStatusPassed = false;
            if (K == 0) {
              K = i;
            }
            if (i == 0) {
                if(sobjPER.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c == 'Randomization'){
                     bmd.pathName = Label.Randomization_Success;
                }else{
                     bmd.pathName = Label.Enrollment_Success;
                }
            } else if (i == 1) {
              bmd.pathName = Label.PE_STATUS_TREATMENT_PERIOD_STARTED;
            } else if (i == 2) {
              bmd.pathName = Label.PE_STATUS_FOLLOW_UP_PERIOD_STARTED;
            } else if (i == 3) {
              bmd.pathName = Label.PIR_Participation_Complete;
            } else {
              bmd.pathName = Label.PIR_Trial_Complete;
            }
            bmd.styleName = 'slds-col width-basis vpi-line-div neutral';
            bmd.styleName_1 = 'slds-col width-basis vpi-state neutral';
            bubbledetails.add(bmd);
          }
        }
        for (Integer L = 0; L < 5; L++) {
          if (K != 0) {
            if (L < K - 1) {
              bubbledetails[L]
                .styleName = 'slds-col width-basis vpi-line-div success';
            } else {
              bubbledetails[L]
                .styleName = 'slds-col width-basis vpi-line-div neutral';
            }
          } else {
            bubbledetails[L]
              .styleName = 'slds-col width-basis vpi-line-div success';
          }
        }
        bubblewrp.BubbleMaps = bubbledetails;
      }
      bubblewrp.userDt = system.today();
      pesh = [Select Id,Status_Label__c,ParticipantEnrollment__c,Non_Enrollment_Reason__c from Participant_Enrollment_Status_History__c WHERE ParticipantEnrollment__c =:perId AND Status_Label__c =: 'Successfully_Contacted' Order By LastModifiedDate Desc Limit 1];
      if(pesh!=null && !pesh.isEmpty()) {
          bubblewrp.contSuccessReason = pesh[0].Non_Enrollment_Reason__c;
      }else{
          bubblewrp.contSuccessReason = '';
      }
      return bubblewrp;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() +
        '\n' +
        e.getStackTraceString()
      );
    }
  }
  public static Map<Id, List<StudySiteVisitPlan__c>> getStudySiteVisitPlansMap(
    List<Id> ssIds
  ) {
    List<StudySiteVisitPlan__c> studySiteVisitPlans = [
      SELECT Id, Visit_Plan__r.Name, Study_Site__c
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
  public static List<LabelValueItem> getVisitPlansLVList(Id ssId) {
    Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlanMap = getStudySiteVisitPlansMap(
      new List<Id>{ ssId }
    );
    List<StudySiteVisitPlan__c> ssVisitPlans = ssVisitPlanMap.get(ssId);
    List<LabelValueItem> resList = new List<LabelValueItem>();
    if (ssVisitPlans != null) {
      for (StudySiteVisitPlan__c ssVisitPlan : ssVisitPlans) {
        resList.add(
          new LabelValueItem(
            ssVisitPlan.Visit_Plan__r.Name,
            ssVisitPlan.Visit_Plan__c
          )
        );
      }
    }
    return resList;
  }
  @AuraEnabled
  public static Boolean doSaveStatusDetails(
    Participant_Enrollment__c perRecord,Participant__c perRec, String visitPlan, Boolean isDeclinedAndConsentAsYes
  ) {
    Map<String,String> initReasonMap = new Map<String,String>{
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
    
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
    );

    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
    );

    Boolean bol = true;
    List<String> statusList = new List<string>{
      'Ready to Contact',
      'Pre-review Passed',
      'Pre-review Failed',
      'Contact Attempted',
      'Contacted - Not Suitable',
      'Unable to Reach',
      'Successfully Contacted',
      'Successfully re-engaged'
    };
     try {
        
      if(perRecord.Add_televisit_for_Initial_Visit__c && !perRecord.Initial_Visit_Televisit_Created__c){
        Televisit__c televisitRecord = new Televisit__c();
        televisitRecord.Duration__c = System.Label.RH_TV_InitialVisitDefaultDuration +' minutes';
        televisitRecord.Start_Time__c = perRecord.Initial_visit_scheduled_time__c;
        televisitRecord.Status__c = 'Scheduled';
        televisitRecord.Title__c = 'Initial Visit';
        televisitRecord.Visit_Date__c = perRecord.Initial_visit_scheduled_date__c;
        televisitRecord.Participant_Enrollment__c = perRecord.Id;
        Datetime visitDateTime = Datetime.newInstance(perRecord.Initial_visit_scheduled_date__c, perRecord.Initial_visit_scheduled_time__c);
        televisitRecord.Visit_End_Date_Time__c = visitDateTime.addMinutes(Integer.valueOf(System.Label.RH_TV_InitialVisitDefaultDuration));
        televisitRecord.Visit_Date_Time__c = visitDateTime;
		    CommunityMode mode = UserContext.getCurrentUserMode();
		    televisitRecord.Source_Community__c = mode.template.communityName;
        insert televisitRecord;
        
        List<Televisit__c> lstTelevisit = new List<Televisit__c>([SELECT Id, CreatedBy.ContactId FROM Televisit__c WHERE Id =: televisitRecord.Id]);
        
        String televisitCreatedUserContactId = lstTelevisit[0].CreatedBy.ContactId;
        
        List<String> contactIds = new List<String>();
        contactIds.add(perRecord.PI_Contact__c);
        contactIds.add(perRecord.Participant_Contact__c);
        contactIds.add(televisitCreatedUserContactId);
        
        for(Patient_Delegate__c participantDelegate : [SELECT Id,Participant__c,Participant__r.Adult__c,Participant__r.Email__c, Primary_Delegate__c,Participant_Delegate__c,Participant_Delegate__r.First_Name__c, 
                                              Participant_Delegate__r.Last_Name__c, Contact__c,Contact__r.FirstName, contact__r.LastName FROM Patient_Delegate__c WHERE 
                                              Participant__c =: perRecord.Participant__c AND Primary_Delegate__c = true]){
              contactIds.add(participantDelegate.Contact__c);                                    
        }
        
        
        Map<String,User> mapUser = new Map<String,User>();
        for(User usr :[SELECT Id,FirstName,LastName,contactId FROM User WHERE contactId IN:contactIds]){
            mapUser.put(usr.contactId, usr);
        }
        
        List<Televisit_Attendee__c> lstAttendees = new List<Televisit_Attendee__c>();
        Televisit_Attendee__c televisitAttendee = new Televisit_Attendee__c();
        televisitAttendee.Televisit__c = televisitRecord.id;
        televisitAttendee.Participant_First_Name__c = perRecord.Participant__r.First_Name__c;
        televisitAttendee.Participant_Last_Name__c = perRecord.Participant__r.Last_Name__c;
        
        if(televisitCreatedUserContactId == perRecord.PI_Contact__c){
            televisitAttendee.Contact__c = perRecord.PI_Contact__c;
            //televisitAttendee.User__c = (mapUser.get(perRecord.PI_Contact__c)!= null)? mapUser.get(perRecord.PI_Contact__c).Id:null;
            if(mapUser.get(perRecord.PI_Contact__c) != null){
                televisitAttendee.User__c =(String) mapUser.get(perRecord.PI_Contact__c).Id;
            }
            televisitAttendee.Attendee_Type__c = 'PI';
            televisitAttendee.Firstname__c =perRecord.PI_Contact__r.FirstName;
            televisitAttendee.Lastname__c =perRecord.PI_Contact__r.LastName;
            if(televisitAttendee.Firstname__c == null && televisitAttendee.Lastname__c.startsWith('P-') && mapUser.get(perRecord.PI_Contact__c) != null){
                televisitAttendee.Firstname__c = mapUser.get(perRecord.PI_Contact__c).FirstName;
                televisitAttendee.Lastname__c = mapUser.get(perRecord.PI_Contact__c).LastName;
            }
        }
        else{
            televisitAttendee.Contact__c = televisitCreatedUserContactId;
            //televisitAttendee.User__c = (mapUser.get(televisitCreatedUserContactId)!= null)? mapUser.get(televisitCreatedUserContactId).Id:null;
            if(mapUser.get(televisitCreatedUserContactId) != null){
                televisitAttendee.User__c =(String) mapUser.get(televisitCreatedUserContactId).Id;
            }
            televisitAttendee.Attendee_Type__c = 'Site Staff';
            televisitAttendee.Firstname__c =mapUser.get(televisitCreatedUserContactId).FirstName;
            televisitAttendee.Lastname__c =mapUser.get(televisitCreatedUserContactId).LastName;
        }
        
        
        //lstAttendees.add(televisitAttendee);
        
        Televisit_Attendee__c televisitAttendee1 = new Televisit_Attendee__c();
        //televisitAttendee1.User__c = (mapUser.get(perRecord.Participant_Contact__c)!= null)? mapUser.get(perRecord.Participant_Contact__c).Id:null;
        if(perRecord.Participant__r.Adult__c && perRecord.Participant__r.Email__c != null){
            televisitAttendee1.Televisit__c = televisitRecord.id;
            televisitAttendee1.Contact__c = perRecord.Participant_Contact__c;
            if(mapUser.get(perRecord.Participant_Contact__c) != null){
                televisitAttendee1.User__c = (String) mapUser.get(perRecord.Participant_Contact__c).Id;
            }
            televisitAttendee1.Firstname__c =perRecord.Participant__r.First_Name__c;
            televisitAttendee1.Lastname__c =perRecord.Participant__r.Last_Name__c;
            televisitAttendee1.Attendee_Type__c = 'Participant';
            if(televisitAttendee1.Firstname__c == null && televisitAttendee1.Lastname__c.startsWith('P-') && mapUser.get(perRecord.Participant_Contact__c) != null){
                televisitAttendee1.Firstname__c = mapUser.get(perRecord.Participant_Contact__c).FirstName;
                televisitAttendee1.Lastname__c = mapUser.get(perRecord.Participant_Contact__c).LastName;
            }
            lstAttendees.add(televisitAttendee1);
        }
        Televisit_Attendee__c televisitAttendee2 = new Televisit_Attendee__c();
        for(Patient_Delegate__c participantDelegate : [SELECT Id,Participant__c,Participant__r.Adult__c,Participant__r.Email__c, Primary_Delegate__c,Participant_Delegate__c,Participant_Delegate__r.First_Name__c, 
                                              Participant_Delegate__r.Last_Name__c, Contact__c,Contact__r.FirstName, contact__r.LastName FROM Patient_Delegate__c WHERE 
                                              Participant__c =: perRecord.Participant__c AND Primary_Delegate__c = true]){
                                                 
            televisitAttendee2.Televisit__c = televisitRecord.id;
            televisitAttendee2.Contact__c = participantDelegate.Contact__c;
            if(mapUser.get(participantDelegate.Contact__c) != null){
                televisitAttendee2.User__c = (String) mapUser.get(participantDelegate.Contact__c).Id;
            }
            if(participantDelegate.Participant_Delegate__c != null){
                televisitAttendee2.Firstname__c= participantDelegate.Participant_Delegate__r.First_Name__c;
                televisitAttendee2.Lastname__c= participantDelegate.Participant_Delegate__r.Last_Name__c;
            }else{
                televisitAttendee2.Firstname__c= participantDelegate.Contact__r.FirstName;
                televisitAttendee2.Lastname__c= participantDelegate.contact__r.LastName;
            }
            televisitAttendee2.Attendee_Type__c = 'Participant Delegate';
            
            //if(televisitAttendee2.Firstname__c == null && televisitAttendee1.Lastname__c.startsWith('P-') && mapUser.get(participantDelegate.Contact__c) != null){
            //    televisitAttendee2.Firstname__c = mapUser.get(participantDelegate.Contact__c).FirstName;
            //    televisitAttendee2.Lastname__c = mapUser.get(participantDelegate.Contact__c).LastName;
            //}
            lstAttendees.add(televisitAttendee2);
        }
        lstAttendees.add(televisitAttendee);
        if(!lstAttendees.isEmpty()){
            insert lstAttendees;
        }
    }   
      if(perRecord.Non_Enrollment_Reason__c !=null && perRecord.Non_Enrollment_Reason__c!='')
      {
        perRecord.Non_Enrollment_Reason__c = initReasonMap.get(perRecord.Non_Enrollment_Reason__c);
      }
      if(visitPlan != null && visitPlan != '' && visitPlan != 'null' && !String.isBlank(visitPlan)){
        perRecord.Visit_Plan__c = visitPlan;
      }
      if(perRecord.Add_televisit_for_Initial_Visit__c && !perRecord.Initial_Visit_Televisit_Created__c){
          perRecord.Initial_Visit_Televisit_Created__c = true;
      }
      if(perRecord.Initial_visit_scheduled_date__c != null){
        perRecord.High_Priority__c = true;
      }else{
        perRecord.High_Priority__c = false;
      }
      if(perRecord.Participant_Status__c == 'Declined Consent' ||
      perRecord.Participant_Status__c == 'Withdrew Consent' ||
      perRecord.Participant_Status__c == 'Withdrew Consent After Screening' ||
      perRecord.Participant_Status__c == 'Declined Final Consent'
      ){
      perRecord.Re_consent__c=false;
      }
      update perRecord;
      if(perRecord.Participant__r.Gender__c!=perRec.Gender__c){
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.CheckBecomesAdultHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
          ParticipantTriggerHandler.UpdateNameOnPE.class
        );
        update perRec;
      }
      /*if(perRecord.Participant_Status__c == 'Successfully re-engaged'){
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Successfully re-engaged'; //re-engaged
        pesh.Notes__c = perRecord.Last_Status_Changed_Notes__c;
        pesh.ParticipantEnrollment__c = perRecord.Id;
        pesh.Non_Enrollment_Reason__c = perRecord.Non_Enrollment_Reason__c;
        insert pesh;
      } 
      else */
      if (perRecord.ParticipantNoShow__c) {
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Participant No Show'; //Participant No Show
        pesh.Notes__c = perRecord.Last_Status_Changed_Notes__c;
        pesh.ParticipantEnrollment__c = perRecord.Id;
        //pesh.Non_Enrollment_Reason__c = 'Didn\'t Show For Initial Visit';
        insert pesh;
      } else if (perRecord.Participant_Status__c != null) {
        if(!isDeclinedAndConsentAsYes){ 
          Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
          pesh.Date__c = Datetime.now();
          pesh.Status__c = perRecord.Participant_Status__c;
          pesh.Notes__c = perRecord.Last_Status_Changed_Notes__c;
          pesh.ParticipantEnrollment__c = perRecord.Id;
          pesh.Non_Enrollment_Reason__c = perRecord.Non_Enrollment_Reason__c;
          if (
            perRecord.Clinical_Trial_Profile__r.Initial_Visit_Required__c &&
            !statusList.contains(perRecord.Participant_Status__c)
          ) {
            if(perRecord.Initial_visit_occurred_flag__c==false){
               if(perRecord.Participant_Status__c != 'Declined Consent'){
                pesh.Disabled_PESH__c =true;
                }
            }
            else{
            pesh.Disabled_PESH__c = isPESHnotDisabled(
              perRecord.Initial_visit_scheduled_date__c,
              perRecord.Initial_visit_scheduled_time__c,
              perRecord.Initial_visit_occurred_flag__c
            );
            }
          }
          insert pesh;
      }else{
          Participant_Enrollment_Status_History__c ph = new Participant_Enrollment_Status_History__c();
          ph = [Select Id,Status__c,Name,ParticipantEnrollment__c,Disabled_PESH__c from Participant_Enrollment_Status_History__c where ParticipantEnrollment__c =:perRecord.Id AND Status__c= 'Declined Consent' ORDER By Name DESC limit 1];
          if(ph != null){
              ph.Id = ph.Id;
              ph.Disabled_PESH__c=true;
              ph.Notes__c=perRecord.Last_Status_Changed_Notes__c;
              update ph;
          }
      }
      } else if (perRecord.Last_Status_Changed_Additional_Notes__c != null && perRecord.Last_Status_Changed_Additional_Notes__c != '') {
        Participant_Enrollment_Status_History__c peshOld = [
          SELECT Additional_Notes__c, Notes__c, ParticipantEnrollment__c
          FROM Participant_Enrollment_Status_History__c
          WHERE ParticipantEnrollment__c = :perRecord.Id
          ORDER BY Name DESC
          LIMIT 1
        ];

        if (peshOld != null) {
          String str = '';
          str = str + perRecord.Last_Status_Changed_Additional_Notes__c;
          str =
            str +
            ' ' +
            Label.PE_Status_History_On_Date +
            ' ' +
            DateTime.now().format('MMM dd yyyy, hh:mm a');
          str =
            str +
            ' ' +
            Label.PG_IMI_L_by_user +
            ' ' +
            UserInfo.getName() +
            '#';
          if (peshOld.Additional_Notes__c == null) {
            peshOld.Additional_Notes__c = str;
          } else {
            peshOld.Additional_Notes__c = str + peshOld.Additional_Notes__c;
          }

          update peshOld;
        }
      }
    } catch (Exception e) {
      bol = false;
      throw new AuraHandledException(e.getMessage());
    }
    return bol;
  }

  public static Boolean isPESHnotDisabled(
    Date initialVisitScheduledDate,
    Time initialVisitScheduledTime,
    Boolean initialVisitOccurredFlag
  ) {
    Boolean bol = false;
    if (
      initialVisitScheduledDate == null &&
      initialVisitScheduledTime == null &&
      !initialVisitOccurredFlag
    ) {
      bol = true;
    }
    return bol;
  }
  @AuraEnabled
    public static Boolean isSuccessfullyReEngaged(Id pe){
    List<Participant_Enrollment_Status_History__c> pehistory = new List<Participant_Enrollment_Status_History__c>();
    pehistory = [
        SELECT
          Id,
          Date__c,Name,
          Status__c,
          CreatedBy.Name,
          Additional_Notes__c, 
          CreatedBy.IsPortalEnabled,
          Status_Order__c,Status_Label__c,
          CreatedBy.contact.userCommunityMode__c
        FROM Participant_Enrollment_Status_History__c
        WHERE ParticipantEnrollment__c = :pe AND Status_Label__c = 'Successfully_Re_Engaged'
        ORDER BY Name DESC
      ];
      if(!pehistory.isEmpty()){
        return true;
      }
      else{
        return false;
      }
  }
}
