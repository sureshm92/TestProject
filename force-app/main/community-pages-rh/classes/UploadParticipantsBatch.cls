global without sharing class UploadParticipantsBatch implements Database.Batchable<List<String>>, Database.Stateful {
  @TestVisible
  private static Boolean isTestRunning = false;
  private static final String PARTICIPANT_USER_MODE = 'Participant';
  private static final String READY_TO_SCREEN_PARTICIPANT_STATUS = 'Ready to Screen';
  private static final String SCREENING_IN_PROGRESS_PARTICIPANT_STATUS = 'Screening In Progress';

  private List<List<String>> csvLines = new List<List<String>>();
  private Map<String, Integer> headerIndexes = new Map<String, Integer>();
  private String selectedStatus;
  private Study_Site__c studySiteDetails;
  private Integer totalRecordCount = 0;
  private Integer errorRecordCount = 0;
  private Account participantAccount;
  private Account tempAccount;
  private Id uploaderContactId;
  private Boolean createUsers;
  private Boolean doContact;
  private Boolean allowEmail;
  private Boolean allowPhone;
  private Boolean allowSMS;
  //RH-6742 -- Extra parameters related to IQVIA outreach consenting has been added
  private Boolean outreachEmail;
  private Boolean outreachPhone;
  private Boolean outreachSMS;
  private Boolean outreachDirectMail;
  private User uploadUser;
  private Id visitPlanId;

  private String emailError = '';
  private Boolean valid = true;
  private DateTime uploadTime;

  private Set<String> listOfFailedRecords = new Set<String>();
  private Set<String> listOfFailedRecordsWithMsg = new Set<String>();

  private Set<String> genderLVSet = new Set<String>{ 'Female', 'Male' };
  private Set<String> phoneTypeLVSet = new Set<String>();
  private Set<String> laguageLVSet = new Set<String>();
  public static boolean isCalloutFromUploadParticipantsBatch = true;
  global List<Id> PERecIds = new List<Id>();
  private Set<String> uniqueConcatenateSet = new Set<String>();
  public String fileName;
  public Bulk_Import_History__c bulkHistory;
  //RH-6742 -- Extra parameters related to IQVIA outreach consenting has been added
  public UploadParticipantsBatch(
    List<List<String>> csvFileLines,
    String header,
    String headerInfo,
    String studySiteId,
    String selectedStatus,
    Boolean headerFailed,
    Map<String, Integer> headerIndexes,
    Boolean createUsers,
    Boolean doContact,
    Boolean allowEmail,
    Boolean allowPhone,
    Boolean allowSMS,
    Boolean outreachEmail,
    Boolean outreachPhone,
    Boolean outreachSMS,
    Boolean outreachDirectMail,
    Id visitPlanId,
    String fileName,
    Bulk_Import_History__c bulkHistory
  ) {
    uploadTime = DateTime.now();
    Integer totalRowCount = csvFileLines.size();
    this.headerIndexes = headerIndexes;
    this.selectedStatus = selectedStatus;
    this.createUsers = createUsers;
    this.doContact = doContact;
    this.allowEmail = allowEmail;
    this.allowPhone = allowPhone;
    this.allowSMS = allowSMS;
    this.visitPlanId = visitPlanId;
    this.outreachEmail = outreachEmail;
    this.outreachPhone = outreachPhone;
    this.outreachSMS = outreachSMS;
    this.outreachDirectMail = outreachDirectMail;
    this.fileName = fileName;
    this.bulkHistory = bulkHistory;

    studySiteDetails = [
      SELECT
        Id,
        Site__c,
        Name,
        Principal_Investigator__c,
        Clinical_Trial_Profile__c,
        Clinical_Trial_Profile__r.CommunityTemplate__c,
        Study_Site_Type__c,
        Suppress_Participant_Emails__c,
        Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
        Clinical_Trial_Profile__r.IQVIA_Outreach__c,
        Participant_DOB_format__c
      FROM Study_Site__c
      WHERE Id = :studySiteId
    ];

    listOfFailedRecordsWithMsg.add('Row Index, Failed Reason');
    String line = header.trim().removeEnd(',').trim().removeEnd(',');
    String line2 = headerInfo.trim().removeEnd(',').trim().removeEnd(',');
    if (line.endsWith(',')) {
      listOfFailedRecords.add(line + ' Validation Errors');
      listOfFailedRecords.add(line2);
    } else {
      listOfFailedRecords.add(line + ', Validation Errors');
      listOfFailedRecords.add(line2);
    }

    if (totalRowCount < 1) {
      listOfFailedRecordsWithMsg.add(
        '0, VALIDATION ERROR: File is empty. Please correct the problem and try again.'
      );
      valid = false;
    }
    if (totalRowCount > 45005) {
      listOfFailedRecordsWithMsg.add(
        '0, VALIDATION ERROR: File contains more than 45,000 records; you may split the file. Please correct the problem and try again.'
      );
      valid = false;
    }
    if (totalRowCount == 0 || headerFailed) {
      listOfFailedRecordsWithMsg.add(
        '0, VALIDATION ERROR: File format must be .CSV, .XLS or .XLSX; also, the fields must match the ones provided in the Sample Template. Please correct the problem and try again.'
      );
      emailError = 'File format must be .CSV, .XLS or .XLSX; also, the fields must match the ones provided in the Sample Template. Please correct the problem and try again.';
      valid = false;
    }

    if (valid) {
      uploadUser = [
        SELECT
          ContactId,
          Contact.MailingCountry,
          Contact.MailingCountryCode,
          Contact.Language__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
      if (uploadUser != null) {
        uploaderContactId = uploadUser.ContactId;
      }
      participantAccount = [
        SELECT Id
        FROM Account
        WHERE Id = :studySiteDetails.Site__c
        LIMIT 1
        FOR UPDATE
      ];
      //create a temporary account
      Account acc = new Account();
      Blob b = Crypto.GenerateAESKey(128);
      String h = EncodingUtil.ConvertTohex(b);
      String guid = h.SubString(0, 8);
      acc.Name = guid;
      insert acc;
      tempAccount = acc;
      List<List<String>> stringList1 = new List<List<String>>();
      for (List<String> ss : csvFileLines) {
        List<String> tem = new List<String>();
        for (String sg : ss) {
          if (sg.contains(',')) {
            tem.add('"' + sg + '"');
          } else {
            tem.add(sg);
          }
        }
        stringList1.add(tem);
      }
      csvLines = stringList1;

      List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(
        Participant__c.Phone_Type__c
      );
      for (LabelValueItem lb : phoneTypeLVList) {
        phoneTypeLVSet.add(lb.value);
      }
      List<LabelValueItem> languageLVList = SObjectHelper.getPicklistLabelValueList(
        Participant__c.Preferred_Language__c
      );
      for (LabelValueItem lb : languageLVList) {
        laguageLVSet.add(lb.value);
      }
    }
  }

  global Iterable<List<String>> start(Database.BatchableContext bc) {
    return csvLines;
  }

  global void execute(
    Database.BatchableContext BC,
    List<List<String>> csvChunkLines
  ) {
    TriggerHandlerExecutor.bypassHandler(
      ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
    );
    TriggerHandlerExecutor.bypassHandler(
      ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
    );
    isCalloutFromUploadParticipantsBatch = true;
    if (!valid) {
      return;
    }

    try {
      Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
      String permissionSetName = CommunityTemplateService.getTemplate(
          studySiteDetails.Clinical_Trial_Profile__r.CommunityTemplate__c
        )
        .permissionSet;

      Map<Id, Contact> contactsById = new Map<Id, Contact>();
      Set<Id> contactsToCreateUsersWith = new Set<Id>();
      Map<Id, Participant__c> participantsByContact = new Map<Id, Participant__c>();
      Map<Id, Participant_Enrollment__c> participantEnrollmentsByContact = new Map<Id, Participant_Enrollment__c>();
      Map<Id, Id> createUsersMap = new Map<Id, Id>();
      Set<Id> insertedContacts = new Set<Id>();
      Map<Id, Id> duplicateContactUsersMap = new Map<Id, Id>();
      Set<Id> insertUsersWithDefaultSettings = new Set<Id>();

      //Variables for Optimization
      Integer trackingNumberSuccess = 0;
      Map<Integer, Contact> mapContact = new Map<Integer, Contact>();
      Map<Integer, Integer> mapContactTrack = new Map<Integer, Integer>();
      Map<Integer, Participant__c> mapParticipant = new Map<Integer, Participant__c>();
      Map<Integer, String> mapParticipantFov = new Map<Integer, String>();
      Map<Integer, String> mapParticipantFovTime = new Map<Integer, String>();
      Map<Integer, String> mapParticipantFovampm = new Map<Integer, String>();
      Map<Integer, Contact> mapDuplicateContact = new Map<Integer, Contact>();
      Map<Integer, Participant__c> mapDuplicateParticipant = new Map<Integer, Participant__c>();

      List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> delegateWrapList = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();
      List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> delegateWithpartList = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();
      Map<Id, Integer> trackIndex = new Map<Id, Integer>();

      List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> patientdelegateUpdateList = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();
      List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper> sendpatientdelegate = new List<UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper>();
      //Variable to update the contact and participant records which were identified as duplicates.
      Map<Id, Participant__c> participantUpdateMap = new Map<Id, Participant__c>();
      //List created to handle REF-3951
      List<Participant__c> participantPatient = new List<Participant__c>();

      Set<String> duplicateRowCheckSet = new Set<String>();

      for (List<String> csvRecordData : csvChunkLines) {
        if (csvRecordData == null || csvRecordData.isEmpty()) {
          continue;
        }

        Boolean hasErrors = false;
        totalRecordCount++;
        String temp = getConcatenateString(csvRecordData);
        if (!uniqueConcatenateSet.contains(temp)) {
          uniqueConcatenateSet.add(temp);
        } else {
          hasErrors = true;
          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Duplicate row found'
          );
        }

        Set<Id> dupclicateParticipantstIds = new Set<Id>();

        String FirstName = '';
        String MiddleName = '';
        String LastName = '';
        String Nickname = '';
        String Sex = '';
        String YearofBirth = '';
        String MonthofBirth = '';
        String Age = '';
        String strDate = '';
        String DateofBirthError = '';
        Date DateofBirthTemp;
        String EmailAddress = '';
        String Phone = '';
        String PhoneType = '';
        String Phone2 = '';
        String PhoneType2 = '';
        String State = '';
        String PostalCode = '';
        String FOV = '';
        String FOVTime = '';
        String FOVampm = '';
        String Language = '';
        //Delegate Information
        String DelegateFirstName = '';
        String DelegateLastName = '';
        String DelegateEmail = '';
        String DelegatePhoneNo = '';
        String DelegatePhoneType = '';
        String DelegateAlternatePhone = '';
        String DelegateAlternatePhoneType = '';
        String ParticipantPhoneNo = '';
        String ParticipantPhoneType = '';
        String ParticipantCountry = '';
        String DelegateAgeOfMajority = '';
        String DelegateYOB = '';
        String lowercasePartCountry = '';
        String lowerCaseContactCountry = '';

        FirstName = headerIndexes.get('PARTICIPANT FIRST NAME') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT FIRST NAME')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT FIRST NAME')].trim()
          : '';
        MiddleName = headerIndexes.get('PARTICIPANT MIDDLE NAME') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT MIDDLE NAME')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT MIDDLE NAME')].trim()
          : '';
        LastName = headerIndexes.get('PARTICIPANT LAST NAME') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT LAST NAME')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT LAST NAME')].trim()
          : '';
        Nickname = headerIndexes.get('PARTICIPANT NICKNAME') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT NICKNAME')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT NICKNAME')].trim()
          : '';
        Sex = headerIndexes.get('PARTICIPANT SEX') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT SEX')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT SEX')].trim()
          : null;
        YearofBirth = headerIndexes.get('PARTICIPANT YEAR OF BIRTH') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT YEAR OF BIRTH')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT YEAR OF BIRTH')].trim()
          : null;
        YearofBirth = headerIndexes.get('PARTICIPANT YEAR OF BIRTH') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT YEAR OF BIRTH')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT YEAR OF BIRTH')].trim()
          : null;
        MonthofBirth = headerIndexes.get('PARTICIPANT MONTH OF BIRTH') !=
          null &&
          csvRecordData[headerIndexes.get('PARTICIPANT MONTH OF BIRTH')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT MONTH OF BIRTH')]
              .trim()
          : null;
        Age = headerIndexes.get('PARTICIPANT AGE') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT AGE')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT AGE')].trim()
          : null;
        strDate = headerIndexes.get('PARTICIPANT DATE OF BIRTH') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT DATE OF BIRTH')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT DATE OF BIRTH')].trim()
          : null;
        if (String.isNotBlank(YearofBirth)) {
          DateofBirthError = YearofBirth.length() != 4
            ? 'yearError'
            : (String.isNotBlank(MonthofBirth) && MonthofBirth.length() > 2)
                ? 'MonthError'
                : (String.isNotBlank(strDate) && strDate.length() > 2)
                    ? 'DateError'
                    : 'NoError';
          if (DateofBirthError == 'NoError') {
            //in csv format, 0 is not considered before any number so making the month and date as two digit (RH-8056)
            if (String.isNotBlank(MonthofBirth)) {
              MonthofBirth = MonthofBirth.length() == 2
                ? MonthofBirth
                : '0' + MonthofBirth;
            }

            if (String.isNotBlank(strDate)) {
              strDate = strDate.length() == 2 ? strDate : '0' + strDate;
            }
          }
        }

        EmailAddress = headerIndexes.get('PARTICIPANT EMAIL ADDRESS') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT EMAIL ADDRESS')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT EMAIL ADDRESS')].trim()
          : null;
        Phone = headerIndexes.get('PARTICIPANT PHONE') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT PHONE')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT PHONE')].trim()
          : null;
        PhoneType = headerIndexes.get('PARTICIPANT PHONE TYPE') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT PHONE TYPE')] != null
          ? csvRecordData[headerIndexes.get('PARTICIPANT PHONE TYPE')].trim()
          : null;
        Phone2 = headerIndexes.get('PARTICIPANT ALTERNATIVE PHONE') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT ALTERNATIVE PHONE')] !=
          null
          ? csvRecordData[headerIndexes.get('PARTICIPANT ALTERNATIVE PHONE')]
              .trim()
          : null;
        PhoneType2 = headerIndexes.get('PARTICIPANT ALT. PHONE TYPE') != null &&
          csvRecordData[headerIndexes.get('PARTICIPANT ALT. PHONE TYPE')] !=
          null
          ? csvRecordData[headerIndexes.get('PARTICIPANT ALT. PHONE TYPE')]
              .trim()
          : null;
        State = headerIndexes.get('STATE') != null &&
          csvRecordData[headerIndexes.get('STATE')] != null
          ? csvRecordData[headerIndexes.get('STATE')].trim()
          : null;
        PostalCode = headerIndexes.get('POSTAL CODE') != null &&
          csvRecordData[headerIndexes.get('POSTAL CODE')] != null
          ? csvRecordData[headerIndexes.get('POSTAL CODE')].trim()
          : null;
        FOV = headerIndexes.get('INITIAL VISIT DATE') != null &&
          csvRecordData[headerIndexes.get('INITIAL VISIT DATE')] != null
          ? csvRecordData[headerIndexes.get('INITIAL VISIT DATE')].trim()
          : null;
        FOVTime = headerIndexes.get('INITIAL VISIT TIME') != null &&
          csvRecordData[headerIndexes.get('INITIAL VISIT TIME')] != null
          ? csvRecordData[headerIndexes.get('INITIAL VISIT TIME')].trim()
          : null;
        FOVampm = headerIndexes.get('INITIAL VISIT TIME AM/PM') != null &&
          csvRecordData[headerIndexes.get('INITIAL VISIT TIME AM/PM')] != null
          ? csvRecordData[headerIndexes.get('INITIAL VISIT TIME AM/PM')].trim()
          : null;
        Language = headerIndexes.get('LANGUAGE') != null &&
          csvRecordData[headerIndexes.get('LANGUAGE')] != null
          ? csvRecordData[headerIndexes.get('LANGUAGE')].trim()
          : null;
        ParticipantCountry = headerIndexes.get('COUNTRY') != null &&
          csvRecordData[headerIndexes.get('COUNTRY')] != null
          ? csvRecordData[headerIndexes.get('COUNTRY')].trim()
          : null;
        //Picking Delegate information
        DelegateFirstName = headerIndexes.get('PRIMARY DELEGATE FIRST NAME') !=
          null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE FIRST NAME')] !=
          null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE FIRST NAME')]
              .trim()
          : null;
        DelegateLastName = headerIndexes.get('PRIMARY DELEGATE LAST NAME') !=
          null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE LAST NAME')] != null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE LAST NAME')]
              .trim()
          : null;
        DelegateEmail = headerIndexes.get('PRIMARY DELEGATE EMAIL') != null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE EMAIL')] != null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE EMAIL')].trim()
          : null;
        DelegatePhoneNo = headerIndexes.get('PRIMARY DELEGATE PHONE NUMBER') !=
          null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE PHONE NUMBER')] !=
          null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE PHONE NUMBER')]
              .trim()
          : null;
        DelegatePhoneType = headerIndexes.get('PRIMARY DELEGATE PHONE TYPE') !=
          null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE PHONE TYPE')] !=
          null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE PHONE TYPE')]
              .trim()
          : null;
        DelegateAgeOfMajority = headerIndexes.get(
            'CONFIRM PRIMARY DELEGATE IS AN ADULT'
          ) != null &&
          csvRecordData[
            headerIndexes.get('CONFIRM PRIMARY DELEGATE IS AN ADULT')
          ] != null
          ? csvRecordData[
                headerIndexes.get('CONFIRM PRIMARY DELEGATE IS AN ADULT')
              ]
              .trim()
          : null;
        DelegateYOB = headerIndexes.get('PRIMARY DELEGATE YOB') != null &&
          csvRecordData[headerIndexes.get('PRIMARY DELEGATE YOB')] != null
          ? csvRecordData[headerIndexes.get('PRIMARY DELEGATE YOB')].trim()
          : null;

        //Participant row check in same sheet
        //String duplicateKey = FirstName+LastName+DateOfBirth+EmailAddress+Phone+PostalCode;
        String duplicateKey =
          FirstName +
          LastName +
          YearofBirth +
          MonthofBirth +
          strDate +
          Phone +
          PostalCode;
        if (!duplicateRowCheckSet.contains(duplicateKey)) {
          duplicateRowCheckSet.add(duplicateKey);
        } else {
          hasErrors = true;
          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Participant Duplicate row found in the Sheet'
          );
        }

        if (!String.isEmpty(EmailAddress)) {
          String regexExclude = System.Label.RH_Email_Invalid_Characters;
          String regexInclude = System.Label.RH_Email_Validation_Pattern;
          Boolean isValidEmail;
          Pattern regexExcludePattern = Pattern.compile(regexExclude);
          Pattern regexIncludePattern = Pattern.compile(regexInclude);
          Matcher regexExcludeMatcher = regexExcludePattern.matcher(
            EmailAddress
          );
          Matcher regexIncludeMatcher = regexIncludePattern.matcher(
            EmailAddress
          );
          if (regexExcludeMatcher.find()) {
            hasErrors = true;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: invalid field - Email'
            );
          } else if (!regexIncludeMatcher.find()) {
            hasErrors = true;

            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: invalid field - Email'
            );
          }
        }

        if (String.isEmpty(FirstName)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field missing: First Name'
          );
        }
        if (String.isEmpty(LastName)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field missing: Last Name'
          );
        }
        if (String.isEmpty(ParticipantCountry)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field missing: Country'
          );
        }

        lowercasePartCountry = ParticipantCountry.toLowerCase().trim();
        if (uploadUser.Contact.MailingCountry != null) {
          lowerCaseContactCountry = uploadUser.Contact.MailingCountry.toLowerCase()
            .trim();
        }

        if (
          !String.isEmpty(ParticipantCountry) &&
          lowercasePartCountry != lowerCaseContactCountry
        ) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field is incorrect: Country'
          );
        }
        if (String.isEmpty(Phone)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field missing: Phone'
          );
        }
        if (!String.isEmpty(PhoneType) && !phoneTypeLVSet.contains(PhoneType)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'value is not correct - Phone Type'
          );
        }
        if (!String.isEmpty(Sex) && !genderLVSet.contains(Sex)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'value is not correct - Gender'
          );
        }
        //State is not mandatory
        /* Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
                if (
                    statesByCountryMap.get(uploadUser.Contact.MailingCountryCode) != null &&
                    !statesByCountryMap.get(uploadUser.Contact.MailingCountryCode).isEmpty() &&
                    String.isEmpty(State)
                ) {
                    hasErrors = true;

                    listOfFailedRecordsWithMsg.add(
                        '' +
                        totalRecordCount +
                        ', ' +
                        'mandatory field is empty - State'
                    );
                }*/
        if (String.isEmpty(PostalCode)) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Required field missing: Postal Code'
          );
        }
        try {
          boolean resultDate = true;
          if (!String.isBlank(YearofBirth)) {
            try {
              Integer year;
              Integer month;
              Integer day;
              Integer lastDay = 31;
              list<String> minDayMonths = new List<String>{
                '04',
                '06',
                '09',
                '11'
              };

              year = Integer.valueOf(YearofBirth);
              //month valid
              if (String.isNotBlank(MonthofBirth)) {
                month = Integer.valueOf(MonthofBirth);
                if (month > 12) {
                  resultDate = false;
                } else if (minDayMonths.contains(MonthofBirth)) {
                  lastDay = 30;
                } else if (MonthofBirth == '02') {
                  lastDay = 28;
                  if (Date.isLeapYear(year)) {
                    lastDay = 29;
                  }
                }
              }
              //day valid
              if (String.isNotBlank(strDate)) {
                day = Integer.valueOf(strDate);
                if (day > lastDay) {
                  resultDate = false;
                }
              }

              //possible age values
              boolean ageErr = false;
              list<integer> possibleAges = new List<integer>();
              integer higherAge = System.Today().year() - year;
              integer lowerAge = higherAge - 1;
              if (String.isBlank(Age)) {
                hasErrors = true;
                ageErr = true;
                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'Age value is missing'
                );
              }
              if (resultDate) {
                if (String.isNotBlank(strDate)) {
                  if (String.isNotBlank(MonthofBirth)) {
                    Integer participantAge = Date.newInstance(
                        2000,
                        month,
                        day
                      ) <=
                      Date.newInstance(
                        2000,
                        Date.today().month(),
                        Date.today().day()
                      )
                      ? higherAge
                      : lowerAge;
                    possibleAges.add(participantAge);
                  } else {
                    possibleAges.add(lowerAge);
                    possibleAges.add(higherAge);
                  }
                } else if (String.isNotBlank(MonthofBirth)) {
                  if (month < Date.today().month()) {
                    possibleAges.add(higherAge);
                  } else if (month > Date.today().month()) {
                    possibleAges.add(lowerAge);
                  } else {
                    possibleAges.add(lowerAge);
                    possibleAges.add(higherAge);
                  }
                } else {
                  possibleAges.add(lowerAge);
                  possibleAges.add(higherAge);
                }
                if (!String.isBlank(Age)) {
                  if (Age.isNumeric()) {
                    if (!possibleAges.contains(Integer.valueOf(Age))) {
                      ageErr = true;
                      hasErrors = true;
                      listOfFailedRecordsWithMsg.add(
                        '' +
                        totalRecordCount +
                        ', ' +
                        'Age value is invalid'
                      );
                    }
                  } else {
                    ageErr = true;
                    hasErrors = true;
                    listOfFailedRecordsWithMsg.add(
                      '' +
                      totalRecordCount +
                      ', ' +
                      'Age value is invalid'
                    );
                  }
                }
              }
              //future date check
              date dobCheck;
              if (resultDate) {
                if (month == null) {
                  month = 1;
                  if (!ageErr) {
                    if (lowerAge == Integer.valueOf(Age)) {
                      month = 12;
                    }
                  }
                }
                if (day == null) {
                  day = 1;
                  if (month == Date.today().month() && !ageErr) {
                    if (lowerAge == Integer.valueOf(Age)) {
                      day = Date.daysInMonth(year, month);
                    }
                  }
                }

                dobCheck = Date.newInstance(year, month, day);
                if (!(dobCheck <= system.today())) {
                  resultDate = false;
                } else {
                  DateofBirthTemp = dobCheck;
                }
              }
            } catch (Exception exp) {
              resultDate = false;
            }
          } else {
            resultDate = false;
          }
          if (!resultDate) {
            hasErrors = true;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'Date of Birth value is missing or invalid'
            );
          }
        } catch (Exception exp) {
          hasErrors = true;
          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Date of Birth, Incorrect value'
          );
        }

        /*if (
                    !String.isBlank(Language) &&
                    String.isBlank(uploadUser.Contact.Language__c) &&
                    !laguageLVSet.contains(Language)
                ) {
                    hasErrors = true;

                    listOfFailedRecordsWithMsg.add(
                        '' +
                        totalRecordCount +
                        ', ' +
                        'Language, Incorrect value'
                    );
                }*/
        if (
          (String.isBlank(Language) || !laguageLVSet.contains(Language)) &&
          String.isBlank(uploadUser.Contact.Language__c)
        ) {
          hasErrors = true;

          listOfFailedRecordsWithMsg.add(
            '' +
            totalRecordCount +
            ', ' +
            'Deafult value, PI Language is missing '
          );
        }
        /** FOV update code changes -velu REF-3302**/
        if (
          !String.isEmpty(FOV) ||
          !String.isEmpty(FOVTime) ||
          !String.isEmpty(FOVampm)
        ) {
          String resultFovDate = null;
          String resultFovtime = null;
          String resultFOVampm = null;

          if (!String.isEmpty(FOV)) {
            try {
              Integer year;
              Integer month;
              Integer day;
              Date daysInMonth;
              if (FOV.contains('/')) {
                List<String> vals = FOV.split('/');
                if (vals.size() == 3) {
                  year = Integer.valueOf(vals[2]);
                  month = Integer.valueOf(vals[0]);
                  day = Integer.valueOf(vals[1]);
                  String yr = String.ValueOf(year);

                  if (
                    day >= 1 &&
                    day <= 31 &&
                    month >= 1 &&
                    month <= 12 &&
                    yr.length() == 4
                  ) {
                    daysInMonth = Date.newInstance(year, month + 1, 1);
                    daysInMonth = daysInMonth.addDays(-1);
                    if (daysInMonth.day() < day) {
                      resultFovDate = null;
                    } else {
                      resultFovDate = FOV;
                    }
                  } else {
                    resultFovDate = null;
                  }
                } else {
                  resultFovDate = null;
                }
              } else if (FOV.contains('-')) {
                List<String> vals = FOV.split('-');
                if (vals.size() == 3) {
                  year = Integer.valueOf(vals[2]);
                  month = Integer.valueOf(vals[0]);
                  day = Integer.valueOf(vals[1]);
                  String yr = String.ValueOf(year);

                  if (
                    day >= 1 &&
                    day <= 31 &&
                    month >= 1 &&
                    month <= 12 &&
                    yr.length() == 4
                  ) {
                    daysInMonth = Date.newInstance(year, month + 1, 1);
                    daysInMonth = daysInMonth.addDays(-1);
                    if (daysInMonth.day() < day) {
                      resultFovDate = null;
                    } else {
                      resultFovDate = FOV;
                    }
                  } else {
                    resultFovDate = null;
                  }
                } else {
                  resultFovDate = null;
                }
              } else {
                resultFovDate = null;
              }
            } catch (Exception exp) {
              resultFovDate = null;
            }
          } else {
            resultFovDate = null;
          }

          if (!String.isEmpty(FOVTime) && !String.isEmpty(FOVampm)) {
            if (FOVTime.contains(':')) {
              List<String> valstime = new List<String>();
              valstime = FOVTime.split(':');
              if (valstime.size() == 2) {
                if (
                  Integer.ValueOf(valstime[0]) >= 1 &&
                  Integer.ValueOf(valstime[0]) <= 12 &&
                  Integer.ValueOf(valstime[1]) >= 0 &&
                  Integer.ValueOf(valstime[1]) <= 59
                ) {
                  resultFovtime = FOVTime;
                } else {
                  resultFovtime = null;
                }
              } else {
                resultFovtime = null;
              }
            } else if (FOVTime.contains(';')) {
              List<String> valstime = new List<String>();
              valstime = FOVTime.split(';');
              if (valstime.size() == 2) {
                if (
                  Integer.ValueOf(valstime[0]) >= 1 &&
                  Integer.ValueOf(valstime[0]) <= 12 &&
                  Integer.ValueOf(valstime[1]) >= 0 &&
                  Integer.ValueOf(valstime[1]) <= 59
                ) {
                  resultFovtime = FOVTime;
                } else {
                  resultFovtime = null;
                }
              } else {
                resultFovtime = null;
              }
            } else {
              resultFovtime = null;
            }
          } else {
            resultFovtime = null;
          }

          if (!String.isEmpty(FOVTime) && !String.isEmpty(FOVampm)) {
            if (
              FOVampm == 'AM' ||
              FOVampm == 'am' ||
              FOVampm == 'PM' ||
              FOVampm == 'pm' ||
              FOVampm == 'Am' ||
              FOVampm == 'Pm' ||
              FOVampm == 'aM' ||
              FOVampm == 'pM'
            ) {
              resultFOVampm = FOVampm;
            } else {
              resultFOVampm = null;
            }
          } else {
            resultFOVampm = null;
          }

          if (
            (!String.isEmpty(FOV) && resultFovDate == null) ||
            ((!String.isEmpty(FOVTime) || !String.isEmpty(FOVampm)) &&
            (resultFOVampm == null ||
            resultFovtime == null))
          ) {
            hasErrors = true;

            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'FOV, Date/Time Incorrect value'
            );
          }
        }
        if (!String.isEmpty(DelegateEmail)) {
          String regexExclude = System.Label.RH_Email_Invalid_Characters;
          String regexInclude = System.Label.RH_Email_Validation_Pattern;
          Boolean isValidEmail;
          Pattern regexExcludePattern = Pattern.compile(regexExclude);
          Pattern regexIncludePattern = Pattern.compile(regexInclude);
          Matcher regexExcludeMatcher = regexExcludePattern.matcher(
            DelegateEmail
          );
          Matcher regexIncludeMatcher = regexIncludePattern.matcher(
            DelegateEmail
          );
          if (regexExcludeMatcher.find()) {
            hasErrors = true;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Delegate invalid field - Email'
            );
          } else if (!regexIncludeMatcher.find()) {
            hasErrors = true;

            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Delegate invalid field - Email'
            );
          }
        }

        if (!hasErrors) {
          //code block to fetch mailing state and country code

          //String countryName = uploadUser.Contact.MailingCountry;
          String countryName = ParticipantCountry;
          String stateName = State;
          String cc;
          String sc;

          if (
            CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(
              countryName
            )
          ) {
            cc = CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(countryName);
          }

          if (
            CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.containsKey(cc) &&
            CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(cc)
              .containsKey(stateName)
          ) {
            sc = CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(cc)
              .get(stateName);
          }

          Contact participantContact = new Contact(
            FirstName = FirstName,
            LastName = LastName,
            AccountId = tempAccount.Id,
            MiddleName = MiddleName,
            Email = EmailAddress,
            Phone = Phone,
            MobilePhone = Phone2,
            MailingState = State,
            MailingCountry = countryName,
            MailingCountryCode = cc,
            MailingPostalCode = PostalCode,
            userCommunityMode__c = PARTICIPANT_USER_MODE,
            Consent_To_Inform_About_Study__c = createUsers,
            Language__c = (String.isBlank(Language) ||
              !laguageLVSet.contains(Language)
              ? uploadUser.Contact.Language__c
              : Language)
          );
          if (studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c) {
            if (this.outreachEmail) {
              participantContact.Participant_Opt_In_Status_Emails__c = true;
            }
            if (this.outreachPhone) {
              participantContact.IQVIA_Artificial_Voice_Consent__c = true;
              participantContact.IQVIA_Assisted_Dialing_Consent__c = true;
              participantContact.IQVIA_Pre_recorded_Voice_Consent__c = true;
              participantContact.Participant_Phone_Opt_In_Permit_Phone__c = true;
            }
            if (this.outreachDirectMail) {
              participantContact.IQVIA_Direct_Mail_Consent__c = true;
            }
            if (this.outreachSMS) {
              participantContact.Participant_Opt_In_Status_SMS__c = true;
            }
          }

          Participant__c participant = new Participant__c(
            First_Name__c = FirstName,
            Last_Name__c = LastName,
            Middle_Name__c = MiddleName,
            Nickname__c = Nickname,
            Gender__c = Sex,
            Birth_Year__c = YearofBirth,
            Age__c = Integer.valueOf(age),
            Email__c = EmailAddress,
            Phone__c = Phone,
            Phone_Type__c = (!String.isEmpty(Phone) && String.isEmpty(PhoneType)) ? 'Home' : PhoneType,
            Alternative_Phone_Number__c = Phone2,
            Alternative_Phone_Type__c = PhoneType2,
            Preferred_Language__c = (String.isBlank(Language) ||
              !laguageLVSet.contains(Language)
              ? uploadUser.Contact.Language__c
              : Language),
            Mailing_State__c = State,
            //Mailing_Country__c = uploadUser.Contact.MailingCountry,
            Mailing_Country__c = countryName,
            Mailing_Zip_Postal_Code__c = PostalCode,
            Mailing_Country_Code__c = cc,
            Mailing_State_Code__c = sc
          );
          if (studySiteDetails.Participant_DOB_format__c.contains('DD')) {
            participant.Birth_Day__c = strDate;
          }
          if (studySiteDetails.Participant_DOB_format__c.contains('MM')) {
            participant.Birth_Month__c = MonthofBirth;
          }
          participant.Date_of_Birth__c = String.valueOf(DateofBirthTemp);
          participant.Adult__c =
            ReferringRemote.checkNeedsGuardian(JSON.serialize(participant)) ==
            'false';
          //This intiation done for delegate age Check
          participant.Date_of_Birth__c = null;
          Participant__c participantDelegate = new Participant__c(
            First_Name__c = DelegateFirstName,
            Last_Name__c = DelegateLastName,
            Phone__c = ParticipantPhoneNo,
            Email__c = DelegateEmail,
            Birth_Year__c = DelegateYOB
          );
          String isAdultDelegate = 'false';
          if (
            !String.isEmpty(DelegateYOB) &&
            (DelegateYOB.isNumeric() && DelegateYOB.length() == 4)
          ) {
            isAdultDelegate = ReferringRemote.checkDelegateAge(
              JSON.serialize(participant),
              JSON.serialize(participantDelegate)
            );
          }
          //START : Delegate wrapper creation
          //This boolean will first check if participant is minor then delegate info is mandatory.
          Boolean createParticipant = false;
          if (
            !participant.Adult__c &&
            (String.isEmpty(DelegateEmail) ||
            String.isEmpty(DelegateFirstName) ||
            String.isEmpty(DelegateLastName))
          ) {
            errorRecordCount++;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Delegate information is mandatory in case of minor Participant'
            );
            listOfFailedRecords.add(
              getCleanMessage(csvLines, totalRecordCount)
            );
          } else if (
            !participant.Adult__c &&
            DelegateAgeOfMajority != 'Yes' &&
            (!String.isEmpty(DelegateEmail) &&
            !String.isEmpty(DelegateFirstName) &&
            !String.isEmpty(DelegateLastName))
          ) {
            errorRecordCount++;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Participant and Delegate were not brought in as Delegate Attestation  is incorrect or Missing'
            );
            listOfFailedRecords.add(
              getCleanMessage(csvLines, totalRecordCount)
            );
          } else if (
            !String.isEmpty(DelegateYOB) &&
            (!DelegateYOB.isNumeric() || DelegateYOB.length() != 4) &&
            !participant.Adult__c &&
            isAdultDelegate == 'false'
          ) {
            errorRecordCount++;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Participant and Delegate were not brought as delegate Year of birth is not correct'
            );
            listOfFailedRecords.add(
              getCleanMessage(csvLines, totalRecordCount)
            );
          } else if (
            !String.isEmpty(DelegateYOB) &&
            (!DelegateYOB.isNumeric() || DelegateYOB.length() != 4) &&
            !participant.Adult__c &&
            isAdultDelegate != 'false'
          ) {
            errorRecordCount++;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Participant and Delegate were not brought as delegate Year of birth is not correct'
            );
            listOfFailedRecords.add(
              getCleanMessage(csvLines, totalRecordCount)
            );
          } else if (
            !String.isEmpty(DelegateYOB) &&
            !participant.Adult__c &&
            isAdultDelegate == 'false'
          ) {
            errorRecordCount++;
            listOfFailedRecordsWithMsg.add(
              '' +
              totalRecordCount +
              ', ' +
              'ERROR: Participant and Delegate were not brought as Minor delegate cannot be inserted'
            );
            listOfFailedRecords.add(
              getCleanMessage(csvLines, totalRecordCount)
            );
          } else {
            createParticipant = true;
          }

          //In Case of Minor participant REF-3070
          if (!participant.Adult__c) {
            ParticipantPhoneNo = participant.Phone__c;
            ParticipantPhoneType = participant.Phone_Type__c;
            participantContact.Email = '';
            participantContact.Phone = '';
            participant.Phone__c = '';
            participant.Phone_Type__c = '';
            participant.Email__c = '';
            participant.Alternative_Phone_Number__c = '';
            participant.Alternative_Phone_Type__c = '';
          }

          if (createParticipant) {
            Boolean hasDelegateErrors = false;
            Boolean isDelegateAvailable = false;
            if (
              !String.isEmpty(DelegateEmail) &&
              !String.isEmpty(DelegateFirstName) &&
              !String.isEmpty(DelegateLastName)
            ) {
              isDelegateAvailable = true;
              String regexExclude = System.Label.RH_Email_Invalid_Characters;
              String regexInclude = System.Label.RH_Email_Validation_Pattern;
              Boolean isValidEmail;
              Pattern regexExcludePattern = Pattern.compile(regexExclude);
              Pattern regexIncludePattern = Pattern.compile(regexInclude);
              Matcher regexExcludeMatcher = regexExcludePattern.matcher(
                DelegateEmail
              );
              Matcher regexIncludeMatcher = regexIncludePattern.matcher(
                DelegateEmail
              );
              if (regexExcludeMatcher.find()) {
                hasDelegateErrors = true;
                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'ERROR: invalid field - Delegate Email'
                );
              } else if (!regexIncludeMatcher.find()) {
                hasDelegateErrors = true;

                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'ERROR: invalid field - Delegate Email'
                );
              } else if (
                !String.isEmpty(DelegateYOB) &&
                (!DelegateYOB.isNumeric() || DelegateYOB.length() != 4)
              ) {
                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'ERROR: Delegate Year of birth is not correct'
                );
                isDelegateAvailable = false;
              } else if (
                !String.isEmpty(DelegateYOB) &&
                participant.Adult__c &&
                isAdultDelegate == 'false'
              ) {
                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'ERROR: Delegate not inserted as it is minor'
                );
                isDelegateAvailable = false;
              } else if (
                participant.Adult__c &&
                DelegateAgeOfMajority != 'Yes' &&
                !String.isEmpty(DelegateEmail) &&
                !String.isEmpty(DelegateFirstName) &&
                !String.isEmpty(DelegateLastName)
              ) {
                listOfFailedRecordsWithMsg.add(
                  '' +
                  totalRecordCount +
                  ', ' +
                  'ERROR: Delegate was not brought in as Attestation is incorrect or Missing'
                );
                isDelegateAvailable = false;
              }
            }
            if (!hasDelegateErrors && isDelegateAvailable) {
              UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper delegateWrap = new UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper();
              delegateWrap.DelegateFirstName = DelegateFirstName;
              delegateWrap.DelegateLastName = DelegateLastName;
              delegateWrap.DelegateEmail = DelegateEmail;
              delegateWrap.ParticipantPhoneNo = ParticipantPhoneNo;
              delegateWrap.ParticipantPhoneType = ParticipantPhoneType;
              if (!String.isBlank(DelegatePhoneNo)) {
                delegateWrap.DelegatePhoneNo = DelegatePhoneNo;
                delegateWrap.DelegatePhoneType = DelegatePhoneType;
              } else {
                delegateWrap.DelegatePhoneNo = '';
                delegateWrap.DelegatePhoneType = '';
              }

              delegateWrap.totalRecordCount = totalRecordCount;
              delegateWrap.DelegateAgeOfMajority = DelegateAgeOfMajority;
              delegateWrap.DelegateYOB = DelegateYOB;
              delegateWrap.isParticipantAdult = participant.Adult__c;
              delegateWrapList.add(delegateWrap);
              patientdelegateUpdateList.add(delegateWrap);
            }
            //Ends : Delegate wrapper creation
            ParticipantDuplicateService.ParticipantWithDelegate partWithDelegate = new ParticipantDuplicateService.ParticipantWithDelegate();
            partWithDelegate.participant = participant;
            partWithDelegate.delegate = participantDelegate;

            //Duplicates check
            Boolean isDuplicate = false;
            ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(
              partWithDelegate
            );
            Participant__c participantDuplicate = duplicateService.findDuplicate(
              participant
            );

            isDuplicate = participantDuplicate != null;
            Contact contactDuplicate = duplicateService.findDuplicateContact(
              participant
            );
            isDuplicate = isDuplicate || contactDuplicate != null;
            trackingNumberSuccess++;
            if (!isDuplicate) {
              mapContact.put(totalRecordCount, participantContact);
              mapContactTrack.put(trackingNumberSuccess, totalRecordCount);
              mapParticipant.put(totalRecordCount, participant);
              if (FOV != null && FOV != '' && FOV != 'null') {
                if (FOV.contains('/')) {
                  List<String> valdate = FOV.split('/');
                  string FOVDate = '';
                  FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                  mapParticipantFov.put(totalRecordCount, FOVDate);
                } else {
                  List<String> valdate = FOV.split('-');
                  string FOVDate = '';
                  FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                  mapParticipantFov.put(totalRecordCount, FOVDate);
                }
              } else {
                mapParticipantFov.put(totalRecordCount, null);
              }
              if (FOVTime != null && FOVTime != '' && FOVTime != 'null') {
                mapParticipantFovTime.put(totalRecordCount, FOVTime);
              } else {
                mapParticipantFovTime.put(totalRecordCount, null);
              }
              if (FOVampm != null && FOVampm != '' && FOVampm != 'null') {
                mapParticipantFovampm.put(totalRecordCount, FOVampm);
              } else {
                mapParticipantFovampm.put(totalRecordCount, null);
              }
            } else {
              if (contactDuplicate != null) {
                mapDuplicateContact.put(totalRecordCount, contactDuplicate);
                trackIndex.put(contactDuplicate.Id, totalRecordCount);
                if (FOV != null && FOV != '' && FOV != 'null') {
                  if (FOV.contains('/')) {
                    List<String> valdate = FOV.split('/');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  } else {
                    List<String> valdate = FOV.split('-');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  }
                } else {
                  mapParticipantFov.put(totalRecordCount, null);
                }
                if (FOVTime != null && FOVTime != '' && FOVTime != 'null') {
                  mapParticipantFovTime.put(totalRecordCount, FOVTime);
                } else {
                  mapParticipantFovTime.put(totalRecordCount, null);
                }
                if (FOVampm != null && FOVampm != '' && FOVampm != 'null') {
                  mapParticipantFovampm.put(totalRecordCount, FOVampm);
                } else {
                  mapParticipantFovampm.put(totalRecordCount, null);
                }
              }
              if (participantDuplicate != null) {
                if (!String.isEmpty(PostalCode)) {
                  participantDuplicate.Mailing_Zip_Postal_Code__c = PostalCode;
                }
                //Added for REF-3951
                /*if(participantDuplicate.Email__c != NULL ||
                                   participantDuplicate.Phone__c != NULL){
                                       participantDuplicate.Email__c = EmailAddress;
                                       participantDuplicate.Phone__c = Phone;
                                       participantPatient.add(participantDuplicate);
                                   }*/
                if (
                  String.isNotBlank(EmailAddress) &&
                  participantDuplicate.Adult__c
                ) {
                  participantDuplicate.Email__c = EmailAddress;
                }
                if (String.isNotBlank(Phone) && participantDuplicate.Adult__c) {
                  participantDuplicate.Phone__c = Phone;
                }
                if (String.isNotBlank(MiddleName)) {
                  participantDuplicate.Middle_Name__c = MiddleName;
                }
                if (String.isNotBlank(Nickname)) {
                  participantDuplicate.Nickname__c = Nickname;
                }
                if (String.isNotBlank(Sex)) {
                  participantDuplicate.Gender__c = Sex;
                }
                if (String.isNotBlank(YearofBirth)) {
                  participantDuplicate.Birth_Year__c = YearofBirth;
                }
                if (String.isNotBlank(MonthofBirth)) {
                  participantDuplicate.Birth_Month__c = MonthofBirth;
                }
                if (String.isNotBlank(strDate)) {
                  participantDuplicate.Birth_Day__c = strDate;
                }
                if (
                  String.isNotBlank(PhoneType) && participantDuplicate.Adult__c
                ) {
                  participantDuplicate.Phone_Type__c = PhoneType;
                }
                if (!String.isEmpty(Phone) && String.isEmpty(PhoneType) && participantDuplicate.Adult__c) {
                  participantDuplicate.Phone_Type__c = 'Home';
                }
                if (
                  String.isNotBlank(Phone2) && participantDuplicate.Adult__c
                ) {
                  participantDuplicate.Alternative_Phone_Number__c = Phone2;
                }
                if (
                  String.isNotBlank(PhoneType2) && participantDuplicate.Adult__c
                ) {
                  participantDuplicate.Alternative_Phone_Type__c = PhoneType2;
                }
                participantDuplicate.Preferred_Language__c = (String.isBlank(
                    Language
                  ) || !laguageLVSet.contains(Language)
                  ? uploadUser.Contact.Language__c
                  : Language);
                if (String.isNotBlank(State)) {
                  participantDuplicate.Mailing_State__c = State;
                }
                if (String.isNotBlank(countryName)) {
                  participantDuplicate.Mailing_Country__c = countryName;
                }
                if (String.isNotBlank(cc)) {
                  participantDuplicate.Mailing_Country_Code__c = cc;
                }
                if (String.isNotBlank(sc)) {
                  participantDuplicate.Mailing_State_Code__c = sc;
                }
                if (String.isNotBlank(Language)) {
                  participantDuplicate.Preferred_Language__c = (String.isBlank(
                      Language
                    ) || !laguageLVSet.contains(Language)
                    ? uploadUser.Contact.Language__c
                    : Language);
                }
                //
                participantUpdateMap.put(
                  participantDuplicate.Id,
                  participantDuplicate
                );
                mapDuplicateParticipant.put(
                  totalRecordCount,
                  participantDuplicate
                );
                trackIndex.put(
                  participantDuplicate.Contact__c,
                  totalRecordCount
                );
                if (FOV != null && FOV != '' && FOV != 'null') {
                  if (FOV.contains('/')) {
                    List<String> valdate = FOV.split('/');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  } else {
                    List<String> valdate = FOV.split('-');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  }
                } else {
                  mapParticipantFov.put(totalRecordCount, null);
                }
                if (FOVTime != null && FOVTime != '' && FOVTime != 'null') {
                  mapParticipantFovTime.put(totalRecordCount, FOVTime);
                } else {
                  mapParticipantFovTime.put(totalRecordCount, null);
                }
                if (FOVampm != null && FOVampm != '' && FOVampm != 'null') {
                  mapParticipantFovampm.put(totalRecordCount, FOVampm);
                } else {
                  mapParticipantFovampm.put(totalRecordCount, null);
                }
              } else {
                //This block is for the records whose contact exists but there is no Participant and PER record.
                participant.Contact__c = contactDuplicate.Id;
                mapParticipant.put(totalRecordCount, participant);
                if (FOV != null && FOV != '' && FOV != 'null') {
                  if (FOV.contains('/')) {
                    List<String> valdate = FOV.split('/');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  } else {
                    List<String> valdate = FOV.split('-');
                    string FOVDate = '';
                    FOVDate = valdate[2] + '-' + valdate[0] + '-' + valdate[1];
                    mapParticipantFov.put(totalRecordCount, FOVDate);
                  }
                } else {
                  mapParticipantFov.put(totalRecordCount, null);
                }
                if (FOVTime != null && FOVTime != '' && FOVTime != 'null') {
                  mapParticipantFovTime.put(totalRecordCount, FOVTime);
                } else {
                  mapParticipantFovTime.put(totalRecordCount, null);
                }
                if (FOVampm != null && FOVampm != '' && FOVampm != 'null') {
                  mapParticipantFovampm.put(totalRecordCount, FOVampm);
                } else {
                  mapParticipantFovampm.put(totalRecordCount, null);
                }
              }
            }
          }
        } else {
          errorRecordCount++;
          listOfFailedRecords.add(getCleanMessage(csvLines, totalRecordCount));
        }
      }
      //Insert the non-duplicate contact and assign the contact ID's to Participant list.
      List<Contact> contactToBeInserted = mapContact.values();
      Set<Id> successfullyInsertedContactSet = new Set<Id>();
      Set<Id> contactsToBeDeleted = new Set<Id>();
      Integer countIndex;
      Database.SaveResult[] saveRes = Database.insert(
        contactToBeInserted,
        false
      );
      for (Integer i = 0; i < saveRes.size(); i++) {
        List<Integer> setToListCon = new List<Integer>(
          mapContactTrack.values()
        );
        countIndex = setToListCon[i];
        if (saveRes[i].isSuccess()) {
          mapParticipant.get(countIndex).Contact__c = saveRes[i].getId();
          successfullyInsertedContactSet.add(saveRes[i].getId());
        } else {
          errorRecordCount++;
          mapParticipant.remove(countIndex);
          Database.Error error = saveRes[i].getErrors().get(0);
          listOfFailedRecordsWithMsg.add(
            '' +
            countIndex +
            ', ERROR on Participant Contact record insert: ' +
            error.getFields() +
            ' ' +
            error.getMessage()
          );
          listOfFailedRecords.add(getCleanMessage(csvLines, countIndex));
        }
      }
      //Contact insertion ends
      //Insert participants.
      // Create a map of index to totalRecordCount which can be used while creating PER
      Map<Integer, Integer> mapParticipantTrack = new Map<Integer, Integer>();
      Integer j = 0;
      for (Integer i : mapParticipant.keySet()) {
        mapParticipantTrack.put(j, i);
        j++;
        if (mapParticipant.get(i).Adult__c) {
          contactsToCreateUsersWith.add(mapParticipant.get(i).Contact__c);
        }
      }
      Integer countIndexParticipant;
      Database.SaveResult[] partiSR = Database.insert(
        mapParticipant.values(),
        false
      );

      for (Integer k = 0; k < partiSR.size(); k++) {
        List<Integer> setToListPart = new List<Integer>(
          mapParticipantTrack.keySet()
        );
        countIndexParticipant = mapParticipantTrack.get(setToListPart[k]);
        if (!partiSR[k].isSuccess()) {
          errorRecordCount++;
          contactsToBeDeleted.add(
            mapParticipant.get(countIndexParticipant).Contact__c
          );
          contactsToCreateUsersWith.remove(
            mapParticipant.get(countIndexParticipant).Contact__c
          );
          mapParticipant.remove(countIndexParticipant);
          Database.Error error = partiSR[k].getErrors().get(0);
          listOfFailedRecordsWithMsg.add(
            '' +
            countIndexParticipant +
            ', ERROR on Participant record insert: ' +
            error.getFields() +
            ' ' +
            error.getMessage()
          );
          listOfFailedRecords.add(
            getCleanMessage(csvLines, countIndexParticipant)
          );
        } else {
          //Add participant information to Delegate wrapper

          for (
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper d : delegateWrapList
          ) {
            if (countIndexParticipant == d.totalRecordCount) {
              d.mainparticipant = mapParticipant.get(countIndexParticipant);
              delegateWithpartList.add(d);
            }
          }
        }
      }

      //Participant Insertion ends
      //Create Participant Enrollment record map
      Map<Integer, Participant_Enrollment__c> mapPER = new Map<Integer, Participant_Enrollment__c>();
      for (Integer i : mapParticipant.keySet()) {
        /** FOV update code changes -velu **/
        String fovTime = mapParticipantFovTime.get(i);
        string fovAMPM = mapParticipantFovampm.get(i);
        string fovhr = '';
        string fovmin = '';

        List<String> valstime = new List<String>();
        if (fovTime != null && fovAMPM != null) {
          if (fovTime.contains(':')) {
            valstime = fovTime.split(':');
            fovhr = valstime[0];
            fovmin = valstime[1];
          } else if (fovTime.contains(';')) {
            valstime = fovTime.split(';');
            fovhr = valstime[0];
            fovmin = valstime[1];
          }

          if (
            fovAMPM == 'am' ||
            fovAMPM == 'AM' ||
            fovAMPM == 'Am' ||
            fovAMPM == 'aM'
          ) {
            if (fovhr == '12')
              fovhr = '0';
          } else {
            if (fovhr == '1' || fovhr == '01') {
              fovhr = '13';
            } else if (fovhr == '2' || fovhr == '02') {
              fovhr = '14';
            } else if (fovhr == '3' || fovhr == '03') {
              fovhr = '15';
            } else if (fovhr == '4' || fovhr == '04') {
              fovhr = '16';
            } else if (fovhr == '5' || fovhr == '05') {
              fovhr = '17';
            } else if (fovhr == '6' || fovhr == '06') {
              fovhr = '18';
            } else if (fovhr == '7' || fovhr == '07') {
              fovhr = '19';
            } else if (fovhr == '8' || fovhr == '08') {
              fovhr = '20';
            } else if (fovhr == '9' || fovhr == '09') {
              fovhr = '21';
            } else if (fovhr == '10' || fovhr == '010') {
              fovhr = '22';
            } else if (fovhr == '11' || fovhr == '011') {
              fovhr = '23';
            }
          }
        }
        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
          Participant_Status__c = selectedStatus,
          Study_Site__c = studySiteDetails.Id,
          Referred_Date__c = System.today(),
          Participant_Contact__c = mapParticipant.get(i).Contact__c,
          Referral_Completed_by__c = uploaderContactId,
          Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI,
          PI_Contact__c = studySiteDetails.Principal_Investigator__c,
          Participant__c = mapParticipant.get(i).Id,
          Permit_Mail_Email_contact_for_this_study__c = allowEmail,
          Study_Direct_Mail_Consent__c = allowEmail,
          Permit_Voice_Text_contact_for_this_study__c = allowPhone,
          Study_Artificial_Voice_Consent__c = allowPhone,
          Study_Assisted_Dialing_Consent__c = allowPhone,
          Study_Pre_recorded_Voice_Consent__c = allowPhone,
          Permit_SMS_Text_for_this_study__c = allowSMS,
          Permit_IQVIA_to_contact_about_study__c = doContact,
          Is_Created_by_Bulk_Import__c = true,
          Visit_Plan__c = visitPlanId,
          Initial_visit_scheduled_date__c = String.ValueOf(
              mapParticipantFov.get(i)
            ) != null
            ? Date.ValueOf(mapParticipantFov.get(i))
            : null,
          Initial_visit_scheduled_time__c = String.ValueOf(
              mapParticipantFovTime.get(i)
            ) != null
            ? Time.newInstance(
                Integer.ValueOf(fovhr),
                Integer.ValueOf(fovmin),
                0,
                0
              )
            : null,
          High_Priority__c = String.ValueOf(mapParticipantFov.get(i)) != null
            ? true
            : false
        );
        if (
          createUsers == true &&
          mapParticipant.get(i).Adult__c &&
          String.isNotBlank(mapParticipant.get(i).Email__c)
        ) {
          //EMail condition RH-5163
          participantEnrollment.Invited_To_PP_Date__c = DateTime.now();
        }
        mapPER.put(i, participantEnrollment);
      }
      //PER record creation ends.

      //In case of duplicate record Iterate over trackIndex to get set of duplicate contact Id's
      Set<Id> duplicateContactIds = new Set<Id>();
      Map<Id, Id> contactEnrollmentMap = new Map<Id, Id>();
      Map<Id, Participant__c> contactParticipantMap = new Map<Id, Participant__c>();
      for (Id i : trackIndex.keySet()) {
        duplicateContactIds.add(i);
      }

      //update consent on existing contacts
      List<Contact> existingContact = new List<Contact>();
      for (String conId : duplicateContactIds) {
        Contact con = new Contact();
        con.Id = conId;
        if (studySiteDetails.Clinical_Trial_Profile__r.IQVIA_Outreach__c) {
          con.IQVIA_Direct_Mail_Consent__c = outreachDirectMail;
          con.Participant_Phone_Opt_In_Permit_Phone__c = outreachPhone;
          con.IQVIA_Artificial_Voice_Consent__c = outreachPhone;
          con.IQVIA_Assisted_Dialing_Consent__c = outreachPhone;
          con.IQVIA_Pre_recorded_Voice_Consent__c = outreachPhone;
          con.Participant_Opt_In_Status_SMS__c = outreachSMS;
          con.Participant_Opt_In_Status_Emails__c = outreachEmail;
        }
        existingContact.add(con);
      }
      TriggerHandlerExecutor.bypassHandler(
        ContactTriggerHandler.CreateUserForDelegateContactHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ContactTriggerHandler.PopulateOverrideFields.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ContactTriggerHandler.CreateUserForCCContactHandler.class
      );
      TriggerHandlerExecutor.bypassHandler(
        ContactTriggerHandler.UpdateParticipantDetailsHandler.class
      );
      update existingContact;

      for (User u : [
        SELECT Id, ContactId
        FROM User
        WHERE ContactId IN :duplicateContactIds
      ]) {
        duplicateContactUsersMap.put(u.ContactId, u.Id);
      }

      for (Participant_Enrollment__c pEnrollment : [
        SELECT Id, Participant_Contact__c
        FROM Participant_Enrollment__c
        WHERE
          Participant_Contact__c IN :duplicateContactIds
          AND (Study_Site__c = :studySiteDetails.Id
          OR Study_Site__r.Clinical_Trial_Profile__c = :studySiteDetails.Clinical_Trial_Profile__c)
      ]) {
        contactEnrollmentMap.put(
          pEnrollment.Participant_Contact__c,
          pEnrollment.Id
        );
      }
      for (
        Participant__c part : [
          SELECT Id, Contact__c, Adult__c, Email__c // RH_5163 Included Email__c field
          FROM Participant__c
          WHERE Contact__c IN :duplicateContactIds
        ]
      ) {
        contactParticipantMap.put(part.Contact__c, part);
        if (part.Adult__c) {
          contactsToCreateUsersWith.add(part.Contact__c);
        }
      }

      for (Id i : duplicateContactIds) {
        if (
          contactEnrollmentMap.get(i) == null &&
          contactParticipantMap.get(i) != null
        ) {
          Integer totalrecorcountindx = trackIndex.get(i);
          String fovTime = mapParticipantFovTime.get(totalrecorcountindx);
          string fovAMPM = mapParticipantFovampm.get(totalrecorcountindx);
          string fovhr = '';
          string fovmin = '';

          List<String> valstime = new List<String>();
          if (fovTime != null && fovAMPM != null) {
            if (fovTime.contains(':')) {
              valstime = fovTime.split(':');
              fovhr = valstime[0];
              fovmin = valstime[1];
            } else if (fovTime.contains(';')) {
              valstime = fovTime.split(';');
              fovhr = valstime[0];
              fovmin = valstime[1];
            }

            if (
              fovAMPM == 'am' ||
              fovAMPM == 'AM' ||
              fovAMPM == 'Am' ||
              fovAMPM == 'aM'
            ) {
              if (fovhr == '12')
                fovhr = '0';
            } else {
              if (fovhr == '1' || fovhr == '01') {
                fovhr = '13';
              } else if (fovhr == '2' || fovhr == '02') {
                fovhr = '14';
              } else if (fovhr == '3' || fovhr == '03') {
                fovhr = '15';
              } else if (fovhr == '4' || fovhr == '04') {
                fovhr = '16';
              } else if (fovhr == '5' || fovhr == '05') {
                fovhr = '17';
              } else if (fovhr == '6' || fovhr == '06') {
                fovhr = '18';
              } else if (fovhr == '7' || fovhr == '07') {
                fovhr = '19';
              } else if (fovhr == '8' || fovhr == '08') {
                fovhr = '20';
              } else if (fovhr == '9' || fovhr == '09') {
                fovhr = '21';
              } else if (fovhr == '10' || fovhr == '010') {
                fovhr = '22';
              } else if (fovhr == '11' || fovhr == '011') {
                fovhr = '23';
              }
            }
          }

          Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
            Participant_Status__c = selectedStatus,
            Study_Site__c = studySiteDetails.Id,
            Referred_Date__c = System.today(),
            Participant_Contact__c = i,
            Referral_Completed_by__c = uploaderContactId,
            Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI,
            PI_Contact__c = studySiteDetails.Principal_Investigator__c,
            Participant__c = contactParticipantMap.get(i).Id,
            Permit_Mail_Email_contact_for_this_study__c = allowEmail,
            Permit_Voice_Text_contact_for_this_study__c = allowPhone,
            Permit_SMS_Text_for_this_study__c = allowSMS,
            Permit_IQVIA_to_contact_about_study__c = doContact,
            Study_Direct_Mail_Consent__c = allowEmail,
            Study_Artificial_Voice_Consent__c = allowPhone,
            Study_Assisted_Dialing_Consent__c = allowPhone,
            Study_Pre_recorded_Voice_Consent__c = allowPhone,
            Is_Created_by_Bulk_Import__c = true,
            Visit_Plan__c = visitPlanId,
            Initial_visit_scheduled_date__c = String.ValueOf(
                mapParticipantFov.get(totalrecorcountindx)
              ) != null
              ? Date.ValueOf(mapParticipantFov.get(totalrecorcountindx))
              : null,
            Initial_visit_scheduled_time__c = String.ValueOf(
                mapParticipantFovTime.get(totalrecorcountindx)
              ) != null
              ? Time.newInstance(
                  Integer.ValueOf(fovhr),
                  Integer.ValueOf(fovmin),
                  0,
                  0
                )
              : null,
            High_Priority__c = String.ValueOf(
                mapParticipantFov.get(totalrecorcountindx)
              ) != null
              ? true
              : false
          );

          if (
            createUsers == true &&
            contactParticipantMap.get(i).Adult__c &&
            String.isNotBlank(contactParticipantMap.get(i).Email__c)
          ) {
            //RH-5163 Email condition
            participantEnrollment.Invited_To_PP_Date__c = DateTime.now();
          }

          mapPER.put(trackIndex.get(i), participantEnrollment);
          for (
            UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper d : delegateWrapList
          ) {
            if (trackIndex.get(i) == d.totalRecordCount) {
              d.mainparticipant = mapDuplicateParticipant.get(
                trackIndex.get(i)
              );
              delegateWithpartList.add(d);
            }
          }
        } else {
          participantUpdateMap.remove(contactParticipantMap.get(i).Id);
          errorRecordCount++;
          Integer errorIndex = trackIndex.get(i);
          listOfFailedRecordsWithMsg.add(
            '' +
            errorIndex +
            ', ' +
            'Duplicate Participant record'
          );
          listOfFailedRecords.add(getCleanMessage(csvLines, errorIndex));
        }
      }

      //Insert all Participant enrollment records.
      Integer countIndexPER;
      Set<Id> newlyCreatedPER = new Set<Id>();
      Database.SaveResult[] perSR = Database.insert(mapPER.values(), false);

      for (Integer k = 0; k < perSR.size(); k++) {
        List<Integer> setToList = new List<Integer>(mapPER.keySet());
        countIndexPER = setToList[k];
        if (!perSR[k].isSuccess()) {
          errorRecordCount++;
          contactsToBeDeleted.add(
            mapPER.get(countIndexPER).Participant_Contact__c
          );
          contactsToCreateUsersWith.remove(
            mapPER.get(countIndexPER).Participant_Contact__c
          );
          mapParticipant.remove(countIndexParticipant);
          Database.Error error = perSR[k].getErrors().get(0);
          listOfFailedRecordsWithMsg.add(
            '' +
            countIndexParticipant +
            ', ERROR on Participant record insert: ' +
            error.getFields() +
            ' ' +
            error.getMessage()
          );
          listOfFailedRecords.add(
            getCleanMessage(csvLines, countIndexParticipant)
          );
        } else {
          newlyCreatedPER.add(perSR[k].getId());
          PERecIds.add(perSR[k].getId());
          if (
            duplicateContactUsersMap.get(
              mapPER.get(countIndexPER).Participant_Contact__c
            ) == null
          ) {
            createUsersMap.put(
              mapPER.get(countIndexPER).Participant_Contact__c,
              mapPER.get(countIndexPER).PI_Contact__c
            );
          }
          actionAssignContactPermissions.addPermission(
            mapPER.get(countIndexPER).Participant_Contact__c,
            permissionSetName
          );
        }
      }
      //Participant Enrollment insertion ends.
      //Delete the contacts which were newly created but their participant/enrollment were not created.
      List<Contact> conDelete = new List<Contact>();
      for (Id i : contactsToBeDeleted) {
        if (successfullyInsertedContactSet.contains(i)) {
          successfullyInsertedContactSet.remove(i);
          Contact c = new Contact(Id = i);
          conDelete.add(c);
        }
      }
      try {
        delete conDelete;
      } catch (Exception e) {
        system.debug(e);
      }
      //deletion of contacts ends.

      //Update the contact with Participant Name and correct account Id
      Map<Id, Participant__c> contactToPart = new Map<Id, Participant__c>();
      for (Participant__c p : [
        SELECT Id, Name, Contact__c
        FROM Participant__c
        WHERE Contact__c IN :successfullyInsertedContactSet
      ]) {
        contactToPart.put(p.Contact__c, p);
      }
      List<Contact> conListtoBeUpdated = new List<Contact>();
      for (Id c : successfullyInsertedContactSet) {
        Contact cc = new Contact();
        cc.Id = c;
        cc.FirstName = null;
        cc.LastName = contactToPart.get(c).Name;
        cc.AccountId = participantAccount.Id;
        conListtoBeUpdated.add(cc);
      }

      if (!conListtoBeUpdated.isEmpty()) {
        update conListtoBeUpdated;
      }

      //REF-3951
      /*if(!participantPatient.isEmpty()){
                update participantPatient;
            }*/

      if (!participantUpdateMap.isEmpty()) {
        update participantUpdateMap.values();
      }

      //Create user for newly created contacts
      if (createUsers) {
        if (!createUsersMap.isEmpty()) {
          ((CommunityService) ClassFactory.newInstance(CommunityService.class))
            .createParticipantUsers(createUsersMap);
        }

        if (!actionAssignContactPermissions.isEmpty()) {
          ActionExecutor.executeAsync(
            actionAssignContactPermissions,
            Datetime.now()
          );
        }
      }
      //user creation ends

      if (!patientdelegateUpdateList.isEmpty()) {
        for (
          UploadParticipantsDelegateHelper.ParticipantsDelegateWrapper d : patientdelegateUpdateList
        ) {
          sendpatientdelegate.add(d);
        }
      }

      //call UploadParticipantsDelegateHelper class to create delegates
      if (!delegateWithpartList.isEmpty()) {
        UploadParticipantsDelegateHelper.ErrorPatientDelegateWrapper wrap = UploadParticipantsDelegateHelper.createDelegateRecords(
          delegateWithpartList,
          studySiteDetails,
          csvLines,
          this.outreachEmail,
          this.outreachPhone,
          this.outreachSMS,
          this.outreachDirectMail
        );
        listOfFailedRecordsWithMsg.addALL(wrap.listOfFailedRecordsWithMsg);
        listOfFailedRecords.addALL(wrap.listOfFailedRecords);
        errorRecordCount = errorRecordCount + wrap.errorRecordCount;
      }
      if (!sendpatientdelegate.isEmpty()) {
        UploadParticipantsDelegateHelper.updateDelegateRecords(
          sendpatientdelegate
        );
      } else if (
        delegateWithpartList.isEmpty() || delegateWithpartList == null
      ) {
        //for Adult participants which have delegates for one study but not for other REF-3566
        Set<Id> existingParticipantId = new Set<Id>();
        for (Participant__c p : mapDuplicateParticipant.values()) {
          existingParticipantId.add(p.id);
        }
        List<Patient_Delegate__c> pdList = new List<Patient_Delegate__c>();
        if (
          !existingParticipantId.isEmpty() && !duplicateContactIds.isEmpty()
        ) {
          for (Patient_Delegate__c pd : [
            SELECT Id, Primary_Delegate__c
            FROM Patient_Delegate__c
            WHERE Participant__c IN :existingParticipantId
          ]) {
            if (pd.Primary_Delegate__c == true) {
              pd.Primary_Delegate__c = false;
              pdList.add(pd);
            }
          }
          update pdList;
        }
      }
      //
    } catch (Exception exp) {
      system.debug(
        'ERROR during CSV parsing: ' +
        exp.getMessage() +
        ' ' +
        exp.getStackTraceString()
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    //delete the temporary account
    try {
      delete tempAccount;
    } catch (Exception exp) {
      system.debug('ERROR during deleting records: ' + exp.getMessage());
    }

    
    try {
      List<String> finalEmails = null;
      sendNotificationEmail(
        listOfFailedRecords,
        listOfFailedRecordsWithMsg,
        studySiteDetails.Principal_Investigator__c,
        uploadTime,
        studySiteDetails,
        totalRecordCount,
        errorRecordCount,
        fileName,
        bulkHistory
      );
      sendBellNotifications(bulkHistory,studySiteDetails, selectedStatus);
    } catch (Exception exp) {
      system.debug(
        'ERROR during sending file with failed records: ' + exp.getMessage()
      );
    }
    // Added By Krishna For REF-2183 -Start
    if (PERecIds != null && !PERecIds.IsEmpty()) {
      UploadParticipantsBatchHelper obj = new UploadParticipantsBatchHelper(
        PERecIds
      );
      Database.executeBatch(obj, 5);
    }
    // Added By Krishna For REF-2183 -End
  }

  private static void sendNotificationEmail(
    Set<String> listOfFailedRecords,
    Set<String> listOfFailedRecordsWithMsg,
    String piContactId,
    DateTime uploadTime,
    Study_Site__c studySiteDetails,
    Integer totalRecordCount,
    Integer errorRecordCount,
    String fileName,
    Bulk_Import_History__c bulkHistory
  ) {
    String formattedDate = uploadTime.format(
      'MM/dd/yyyy hh:mm a',
      UserInfo.getTimeZone().toString()
    );
    Id contextUserId = UserInfo.getUserId();
    User contextUser = [
      SELECT Id, Email, Contact.Email, contactId, Username
      FROM User
      WHERE id = :contextUserId
    ];
    OrgWideEmailAddress owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE DisplayName LIKE '%IQVIA Referral Hub'
      LIMIT 1
    ];
    Id importParticipantsTemplateId = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :SendEmailTemplate.EMAIL_TEMPLATE_PATIENT_IMPORT
      LIMIT 1
    ]
    .Id;

    Map<Integer, String> mapRowIndexToErrorMessage = new Map<Integer, String>();
    Messaging.SingleEmailMessage adminEmailToSend = new Messaging.SingleEmailMessage();
    adminEmailToSend.setTemplateId(importParticipantsTemplateId);
    adminEmailToSend.setTargetObjectId(contextUser.contactId);
    adminEmailToSend.setSaveAsActivity(false);
    adminEmailToSend.setOrgWideEmailAddressId(owea.Id);
    adminEmailToSend.setWhatId(studySiteDetails.Id);

    String failedRecordsCSV = '';

    String failedRecordsCSVMsgs = '';
    for (String failedRecordMsg : listOfFailedRecordsWithMsg) {
      String strRowIndex = failedRecordMsg.substringBefore(',').trim();

      if (strRowIndex.isNumeric()) {
        Integer intRowIndex = Integer.valueOf(strRowIndex);
        String strMessage = failedRecordMsg.substringAfter(',').trim();
        if (!mapRowIndexToErrorMessage.containsKey(intRowIndex))
          mapRowIndexToErrorMessage.put(intRowIndex, strMessage);
        else {
          String strTempMessage = mapRowIndexToErrorMessage.get(intRowIndex);
          strTempMessage = strTempMessage + '-' + strMessage;
          mapRowIndexToErrorMessage.put(intRowIndex, strTempMessage);
        }
      }

      failedRecordsCSVMsgs = failedRecordsCSVMsgs + failedRecordMsg + '\n';
    }

    for (String failedRecord : listOfFailedRecords) {
      String strRowIndex = failedRecord.substringAfterLast(',').trim();
      if (strRowIndex.isNumeric()) {
        Integer intIndex = Integer.valueOf(strRowIndex);
        String strBefore = failedRecord.substringBeforeLast(',');
        failedRecordsCSV =
          failedRecordsCSV +
          strBefore +
          ', ' +
          mapRowIndexToErrorMessage.get(intIndex) +
          '\n';
      } else {
        failedRecordsCSV = failedRecordsCSV + failedRecord + '\n';
      }
    }
    Messaging.EmailFileAttachment failedRecordsEfa = new Messaging.EmailFileAttachment();
    failedRecordsEfa.setFileName(
      'ProcessOutput_Records_' +
      formattedDate +
      '.csv'
    );
    failedRecordsEfa.setBody(Blob.valueOf(failedRecordsCSV));

    Messaging.EmailFileAttachment failedMsgsEfa = new Messaging.EmailFileAttachment();
    failedMsgsEfa.setFileName(
      'ProcessOutput_Details_' +
      formattedDate +
      '.csv'
    );
    failedMsgsEfa.setBody(Blob.valueOf(failedRecordsCSVMsgs));

    
    TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class, TriggerOperation.AFTER_INSERT
        );
        TriggerHandlerExecutor.bypassHandler(
          ContentDocumentLinkTriggerHandler.class, TriggerOperation.BEFORE_INSERT
      );
        

    string errFileName = 'error.csv';
    if (fileName.contains('.csv')) {
      if (fileName.contains('_errors.csv')) {
        errFileName = fileName;
      } else {
        errFileName = fileName.split('.csv')[0] + '_errors.csv';
      }
    } else if (fileName.contains('.xlsx'))
      errFileName = fileName.split('.xlsx')[0] + '_errors.csv';
    else if (fileName.contains('.xls'))
      errFileName = fileName.split('.xls')[0] + '_errors.csv';
    Id conDocId = null;
    if (errorRecordCount != 0) {
      NetworkMember getnetwork = [
        SELECT id, NetworkId, Network.id, Network.Name
        FROM NetworkMember
        WHERE MemberId = :UserInfo.getUserId()
        LIMIT 1
      ];
      Id networkId = getnetwork.NetworkId;
      ContentVersion cv = new ContentVersion();
      cv.Title = errFileName;
      cv.PathOnClient = '/' + errFileName;
      cv.VersionData = Blob.valueOf(failedRecordsCSV);
      cv.IsMajorVersion = true;
      cv.NetworkId = networkId;
      insert cv;

      conDocId = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
      ]
      .ContentDocumentId;

      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.LinkedEntityId = bulkHistory.Id;
      cdl.ContentDocumentId = conDocId;
      cdl.shareType = 'I';
      //cdl.Visibility = 'SharedUsers';
      insert cdl;
    }
    Bulk_Import_History__c bulkHistory1 = new Bulk_Import_History__c();
    bulkHistory1.Id = bulkHistory.Id;
    bulkHistory1.Import_Status__c = 'Completed';
    bulkHistory1.Initial_Total_Records__c = String.valueOf(totalRecordCount);
    bulkHistory1.Rejected_Records__c = String.valueOf(errorRecordCount);
    if (bulkHistory1.Rejected_Records__c != '0') {
      bulkHistory1.File_Name__c = errFileName;
    }
    bulkHistory1.Accepted_Records__c = String.valueOf(
      totalRecordCount - errorRecordCount
    );
    if (conDocId != null) {
      bulkHistory1.Download_URL__c =
        '../sfc/servlet.shepherd/document/download/' + conDocId;
    }
    update bulkHistory1;
    

    Savepoint sp = Database.setSavepoint();
    if (!Test.isRunningTest()) {
      Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ adminEmailToSend }
      );
    }
    Database.rollback(sp);
    
    String htmlBody = (!Test.isRunningTest()
      ? adminEmailToSend.getHtmlBody()
      : 'test');
     
    htmlBody = htmlBody.replace(
      '##SucRecCount',
      '' + (totalRecordCount - errorRecordCount)
    );
    
    htmlBody = htmlBody.replace('##TotalRecCount', '' + totalRecordCount);
    
    htmlBody = htmlBody.replace('##userName', '' + contextUser.userName);
    String plainBody = (!Test.isRunningTest()
      ? adminEmailToSend.getPlainTextBody()
      : 'test');
    plainBody = plainBody.replace(
      '##SucRecCount',
      '' + (totalRecordCount - errorRecordCount)
    );
    plainBody = plainBody.replace('##TotalRecCount', '' + totalRecordCount);
    plainBody = plainBody.replace('##userName', '' + contextUser.userName);
    
    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
    emailToSend.setToAddresses(
      new List<String>{
        (contextUser.Email != null
          ? contextUser.Email
          : contextUser.Contact.Email)
      }
    ); //Added by Krisha for REF-2536 to send email to the logged in User
    
    emailToSend.setPlainTextBody(plainBody);
    emailToSend.setHtmlBody(htmlBody);
    emailToSend.setSubject(adminEmailToSend.getSubject());
    emailToSend.setOrgWideEmailAddressId(owea.Id);
    
    /*emailToSend.setFileAttachments(
            new List<Messaging.EmailFileAttachment>{ failedRecordsEfa, failedMsgsEfa }
        );*/

    if (!Test.isRunningTest()) {
      Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ emailToSend }
      );
    }  
  }

  //This is a genric method which will be used to resolve data truncation issue in output file.
  public static String getCleanMessage(
    List<List<String>> csvString,
    Integer count
  ) {
    String cleanMessage;
    String strValue = '';
    for (String str : csvString.get(count - 1)) {
      strValue = String.isNotBlank(strValue)
        ? strValue + ',' + str
        : '"' + str + '"';
    }
    cleanMessage =
      ('' + strValue).removeStart('(').removeEnd(')') +
      ', ' +
      count;
    return cleanMessage;
  }

  //This method will concatenate all the fields of the list.

  public static String getConcatenateString(List<String> rowString) {
    String uniqueString = '';
    for (String s : rowString) {
      uniqueString = uniqueString + s.trim();
    }
    return uniqueString.toLowerCase();
  }
  /*
   * @description: this method will be used to send bell notification on completion of Bulk Import of participants
   * @created Date: 26 Oct 2022
   * 
   * @param: bulkImpHistory - instance of Bulk Import History record; used to get the context user details
   * @param: studySiteDetails -  instance of Study Site record; used to get study site details
   */
  public static void sendBellNotifications(Bulk_Import_History__c bulkImpHistory, Study_Site__c studySiteDetails, String selectedStatus){
    
    List<Notification_Target__mdt> notificationMdt = BellNotificationsHelper.getTarget('BELL_Message_on_Bulk_Import_Success');
    List<String> userGroupList = new List<String>();
    for(Notification_target__mdt mdt : notificationMdt){
        usergroupList.add(mdt.Target_User_Group__c);
    }
    Map<String,List<Contact> > resultMap = BellNotificationsHelper.getRecipientVsContact(userGroupList, studySiteDetails.Id, bulkImpHistory.Uploaded_By__c);
    
    List<Notification__c> notificationList = BellNotificationsHelper.createNotification('BELL_Message_on_Bulk_Import_Success', resultMap, true);
    
    Id jobId = System.enqueueJob(new BellNotificationQueueable(notificationList, studySiteDetails, selectedStatus, BellNotificationsHelper.userRole));

    
  }
}