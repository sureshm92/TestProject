public without sharing class SiteCalendarController {
  private static final String CANCELLED = 'Cancelled';
  @AuraEnabled
  public static List<visitDataWrapper> recordsOfTeleAndInitialVisit(
    String filterData
  ) {
    try {
      List<visitDataWrapper> visitRecords = new List<visitDataWrapper>();
      Datetime currentDateTime = Datetime.now();
      Datetime next24HoursDateTime = Datetime.now().addHours(24);
      String boxVisitCSS = '';
      //Parse filter data
      filterWrapper filterDetails = (filterWrapper) JSON.deserialize(
        filterData,
        filterWrapper.class
      );
      //Fetch Televisit data
      List<Televisit__c> televisitData = [
        SELECT
          Id,
          Title__c,
          Visit_Date__c,
          Visit_Date_Time__c,
          Start_Time__c,
          Visit_Link_Activation_Start_Time__c,
          Visit_Link_Activation_End_Time__c,
          Status__c,
          Meeting_URL__c,
          Participant_Enrollment__r.Participant_Name__c,
          Duration__c,
          Participant_Enrollment__r.Participant__r.First_Name__c,
          Participant_Enrollment__r.Participant__r.Last_Name__c,
          Participant_Enrollment__r.Participant_Surname__c,
          Participant_Enrollment__r.Name,
          Participant_Enrollment__r.study_Site__r.Clinical_Trial_Profile__c,
          Participant_Enrollment__r.study_Site__r.Banner_Display_Offset_Time__c,
          Participant_Enrollment__r.study_Site__r.Banner_Dispose_Offset_Time__c,
          (SELECT Id, User__c FROM Televisit_Attendee__r)
        FROM Televisit__c
        WHERE
          Visit_Date__c = :filterDetails.calendarDate
          AND Status__c != :CANCELLED
          AND Participant_Enrollment__r.Study_Site__c IN :filterDetails.studySite
          AND Participant_Enrollment__r.Clinical_Trial_Profile__c IN :filterDetails.study          
        ORDER BY Visit_Date_Time__c DESC
      ];

      for (Televisit__c visitData : televisitData) {
        string visitTime = timeFormatForVisits(visitData.Start_Time__c);
        Boolean isJoin = isJoinEnabled(visitData);
        if (isJoin) {
          boxVisitCSS = 'box-visit-screen join-btn-bg';
        } else {
          boxVisitCSS = 'box-visit-screen';
        }
        String participantName = visitData.Participant_Enrollment__r.Participant__r.Last_Name__c;
        if (
          String.isNotBlank(
            visitData.Participant_Enrollment__r.Participant__r.First_Name__c
          )
        ) {
          participantName +=
            ', ' +
            visitData.Participant_Enrollment__r.Participant__r.First_Name__c;
        }
        string completeName =
          visitData.Participant_Enrollment__r.Participant_Name__c +
          ' ' +
          visitData.Participant_Enrollment__r.Participant_Surname__c;
        visitRecords.add(
          new visitDataWrapper(
            boxVisitCSS,
            visitData.Id,
            visitData.Title__c,
            participantName,
            visitTime,
            visitData.Duration__c,
            visitData.Participant_Enrollment__r.Name,
            completeName,
            isJoin,
            visitData.Meeting_URL__c,
            visitData.Visit_Date_Time__c
          )
        );
      }
      //Fetch Initial Visit data
      List<Participant_Enrollment__c> initialVisitData = [
        SELECT
          Id,
          Name,
          Participant_Surname__c,
          Participant_Name__c,
          Initial_visit_scheduled_date__c,
          Initial_visit_scheduled_flag__c,
          Initial_visit_scheduled_time__c,
          Participant__r.First_Name__c,
          Participant__r.Last_Name__c
        FROM Participant_Enrollment__c
        WHERE
          Study_Site__c IN :filterDetails.studySite
          AND Study_Site__r.Clinical_Trial_Profile__c IN :filterDetails.study
          AND Initial_visit_scheduled_date__c = :filterDetails.calendarDate
        ORDER BY Initial_visit_scheduled_date__c DESC
      ];

      for (Participant_Enrollment__c visitData : initialVisitData) {
        string visitTime = timeFormatForVisits(
          visitData.Initial_visit_scheduled_time__c
        );
        boxVisitCSS = 'box-visit-screen';
        string completeName =
          visitData.Participant_Name__c +
          ' ' +
          visitData.Participant_Surname__c;
        String participantName = visitData.Participant__r.Last_Name__c;
        if (String.isNotBlank(visitData.Participant__r.First_Name__c)) {
          participantName += ', ' + visitData.Participant__r.First_Name__c;
        }
        visitRecords.add(
          new visitDataWrapper(
            boxVisitCSS,
            visitData.Id,
            System.Label.Pre_Enrollment_Visit_Plan,
            participantName,
            visitTime,
            null,
            visitData.Name,
            completeName,
            false,
            '',
            visitData.Initial_visit_scheduled_date__c
          )
        );
      }
      return visitRecords;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  public static string timeFormatForVisits(time visitTime) {
    string visitTimeFormat;
    if (visitTime != null) {
      string timestring = string.valueOf(visitTime);
      List<string> timeList = new List<string>();
      for (string s : timestring.split(':')) {
        timeList.add(s);
      }
      String formattedTime = '';
      if (integer.valueOf(timeList[0]) <= 12) {
        formattedTime = timeList[0];
      } else {
        formattedTime = (String.valueOf(integer.valueOf(timeList[0]) - 12))
          .leftPad(2, '0');
      }
      formattedTime = formattedTime + ':' + timeList[1];
      if (integer.valueOf(timeList[0]) < 12) {
        formattedTime = formattedTime + ' AM';
      } else {
        formattedTime = formattedTime + ' PM';
      }
      visitTimeFormat = formattedTime;
    }
    return visitTimeFormat;
  }

  public static Boolean isJoinEnabled(Televisit__c tvisit) {
    Id userId = UserInfo.getUserId();
    Boolean isJoin = false;
    Map<Id, Televisit__c> televistMap = new Map<Id, Televisit__c>();
    for (Televisit_Attendee__c tattendee : tvisit.Televisit_Attendee__r) {
      if (tattendee.User__c == userId) {
        if (
          system.now() >= tvisit.Visit_Link_Activation_Start_Time__c &&
          system.now() < tvisit.Visit_Link_Activation_End_Time__c
        ) {
          isJoin = true;
        }
      }
    }
    return isJoin;
  }

  public class visitDataWrapper {
    @AuraEnabled
    public string boxVisitCSS { get; set; }
    @AuraEnabled
    public string visitId { get; set; }
    @AuraEnabled
    public string visitTitle { get; set; }
    @AuraEnabled
    public string participantName { get; set; }
    @AuraEnabled
    public string visitTime { get; set; }
    @AuraEnabled
    public string durationTime { get; set; }
    @AuraEnabled
    public string refIdName { get; set; }
    @AuraEnabled
    public string fullName { get; set; }
    @AuraEnabled
    public Boolean isJoin { get; set; }
    @AuraEnabled
    public String meetingURL { get; set; }
    @AuraEnabled
    public Datetime visitDateTime {get; set;}

    public visitDataWrapper(
      String boxVisitCSS,
      String visitId,
      String visitTitle,
      String participantName,
      String visitTime,
      String durationTime,
      String refIdName,
      String fullName,
      Boolean isJoin,
      String meetingURL,
      DateTime visitDateTime
    ) {
      this.boxVisitCSS = boxVisitCSS;
      this.visitId = visitId;
      this.visitTitle = visitTitle;
      this.participantName = participantName;
      this.visitTime = visitTime;
      this.durationTime = durationTime;
      this.refIdName = refIdName;
      this.fullName = fullName;
      this.isJoin = isJoin;
      this.meetingURL = meetingURL;
      this.visitDateTime = visitDateTime;
    }
  }

  public class filterWrapper {
    @AuraEnabled
    public Date calendarDate;
    @AuraEnabled
    public List<String> study;
    @AuraEnabled
    public List<String> studySite;
  }
}