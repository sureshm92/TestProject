/**
 * Created by alekseymoseev on 12/10/19.
 */

global class UploadParticipantsBatch implements Database.Batchable<List<String>>, Database.Stateful {

    @TestVisible
    private static Boolean isTestRunning = false;

    private List<List<String>> csvLines = new List<List<String>>();
    private Map<String, Integer> headerIndexes = new Map<String, Integer>();
    private String selectedStatus;
    private Study_Site__c studySiteDetails;
    private Boolean headerFailed;
    private Integer totalRecordCount = 0;

    private String emailError = '';
    Boolean valid = true;
    private DateTime uploadTime;

    private Set<String> listOfFailedRecords = new Set<String>();
    private Set<String> listOfFailedRecordsWithMsg = new Set<String>();

    public UploadParticipantsBatch(List<List<String>> csvFileLines, String header, String studySiteId, String selectedStatus, Boolean headerFailed, Map<String, Integer> headerIndexes) {
        uploadTime = DateTime.now();
        Integer totalRowCount = csvFileLines.size();
        this.headerIndexes = headerIndexes;
        this.selectedStatus = selectedStatus;

        studySiteDetails = [SELECT Id, Principal_Investigator__c, Clinical_Trial_Profile__c FROM Study_Site__c WHERE Id = :studySiteId];

        listOfFailedRecordsWithMsg.add('Row Index, Failed Reason');
        String line = header.trim().removeEnd(',').trim().removeEnd(',');
        if (line.endsWith(',')) {
            listOfFailedRecords.add(line + ' Row Index');
        } else {
            listOfFailedRecords.add(line + ', Row Index');
        }

        if (totalRowCount < 1) {
            listOfFailedRecordsWithMsg.add('0, VALIDATION ERROR: File is empty. Please correct the problem and try again.');
            system.debug('ERROR, File is empty. Please correct the problem and try again.');
            valid = false;
        }
        if (totalRowCount > 45005) {
            listOfFailedRecordsWithMsg.add('0, VALIDATION ERROR: File contains more than 45,000 records; you may split the file. Please correct the problem and try again.');
            system.debug('ERROR, File contains more than 45,000 records; you may split the file. Please correct the problem and try again.');
            valid = false;
        }
        if (totalRowCount == 0 || headerFailed) {
            listOfFailedRecordsWithMsg.add('0, VALIDATION ERROR: File format must be .CSV, .XLS or .XLSX; also, the fields must match the ones provided in the Sample Template. Please correct the problem and try again.');
            system.debug('ERROR, File format must be .CSV, .XLS or .XLSX; also, the fields must match the ones provided in the Sample Template. Please correct the problem and try again.');
            emailError = 'File format must be .CSV, .XLS or .XLSX; also, the fields must match the ones provided in the Sample Template. Please correct the problem and try again.';
            valid = false;
        }

        if (valid) {
            csvLines = csvFileLines;
        }
    }

    global Iterable<List<String>> start(Database.BatchableContext bc) {
        return csvLines;
    }

    global void execute(Database.BatchableContext BC, List<List<String>> csvChunkLines) {
        if (!valid) {
            return;
        }

        try {
            Map<Id, Contact> contactsById = new Map<Id, Contact>();
            Map<Id, Participant__c> participantsByContact = new Map<Id, Participant__c>();
            Map<Id, Participant_Enrollment__c> participantEnrollmentsByContact = new Map<Id, Participant_Enrollment__c>();

            for (List<String> csvRecordData : csvChunkLines) {
                if (csvRecordData == null || csvRecordData.isEmpty()) {
                    continue;
                }

                Boolean hasErrors = false;

                String FirstName = '';
                String MiddleName = '';
                String LastName = '';
                String Nickname = '';
                String Sex = '';
                String DateOfBirth = '';
                String EmailAddress = '';
                String Phone = '';
                String PhoneType = '';
                String Phone2 = '';
                String PhoneType2 = '';
                String StreetAddress = '';
                String City = '';
                String State = '';
                String PostalCode = '';
                String Country = '';
                String Language = '';

                totalRecordCount++;
                system.debug('ITERATION #: ' + totalRecordCount);
                system.debug(csvRecordData);

                FirstName = headerIndexes.get('FIRST NAME') != null && csvRecordData[headerIndexes.get('FIRST NAME')] != null ? csvRecordData[headerIndexes.get('FIRST NAME')].trim() : '';
                MiddleName = headerIndexes.get('MIDDLE NAME') != null && csvRecordData[headerIndexes.get('MIDDLE NAME')] != null ? csvRecordData[headerIndexes.get('MIDDLE NAME')].trim() : '';
                LastName = headerIndexes.get('LAST NAME') != null && csvRecordData[headerIndexes.get('LAST NAME')] != null ? csvRecordData[headerIndexes.get('LAST NAME')].trim() : '';
                Nickname = headerIndexes.get('NICKNAME') != null && csvRecordData[headerIndexes.get('NICKNAME')] != null ? csvRecordData[headerIndexes.get('NICKNAME')].trim() : '';
                Sex = headerIndexes.get('SEX') != null && csvRecordData[headerIndexes.get('SEX')] != null ? csvRecordData[headerIndexes.get('SEX')].trim() : null;
                DateOfBirth = headerIndexes.get('DATE OF BIRTH') != null && csvRecordData[headerIndexes.get('DATE OF BIRTH')] != null ? csvRecordData[headerIndexes.get('DATE OF BIRTH')].trim() : null;
                EmailAddress = headerIndexes.get('EMAIL ADDRESS') != null && csvRecordData[headerIndexes.get('EMAIL ADDRESS')] != null ? csvRecordData[headerIndexes.get('EMAIL ADDRESS')].trim() : null;
                Phone = headerIndexes.get('PHONE') != null && csvRecordData[headerIndexes.get('PHONE')] != null ? csvRecordData[headerIndexes.get('PHONE')].trim() : null;
                PhoneType = headerIndexes.get('PHONE TYPE') != null && csvRecordData[headerIndexes.get('PHONE TYPE')] != null ? csvRecordData[headerIndexes.get('PHONE TYPE')].trim() : null;
                Phone2 = headerIndexes.get('PHONE2') != null && csvRecordData[headerIndexes.get('PHONE2')] != null ? csvRecordData[headerIndexes.get('PHONE2')].trim() : null;
                PhoneType2 = headerIndexes.get('PHONE TYPE2') != null && csvRecordData[headerIndexes.get('PHONE TYPE2')] != null ? csvRecordData[headerIndexes.get('PHONE TYPE2')].trim() : null;
                StreetAddress = headerIndexes.get('STREET ADDRESS') != null && csvRecordData[headerIndexes.get('STREET ADDRESS')] != null ? csvRecordData[headerIndexes.get('STREET ADDRESS')].trim() : null;
                City = headerIndexes.get('CITY') != null && csvRecordData[headerIndexes.get('CITY')] != null ? csvRecordData[headerIndexes.get('CITY')].trim() : null;
                State = headerIndexes.get('STATE') != null && csvRecordData[headerIndexes.get('STATE')] != null ? csvRecordData[headerIndexes.get('STATE')].trim() : null;
                PostalCode = headerIndexes.get('POSTAL CODE') != null && csvRecordData[headerIndexes.get('POSTAL CODE')] != null ? csvRecordData[headerIndexes.get('POSTAL CODE')].trim() : null;
                Country = headerIndexes.get('COUNTRY') != null && csvRecordData[headerIndexes.get('COUNTRY')] != null ? csvRecordData[headerIndexes.get('COUNTRY')].trim() : null;
                Language = headerIndexes.get('LANGUAGE') != null && csvRecordData[headerIndexes.get('LANGUAGE')] != null ? csvRecordData[headerIndexes.get('LANGUAGE')].trim() : null;


                if (String.isEmpty(FirstName)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'First Name, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - First Name');
                }
                if (String.isEmpty(LastName)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Last Name, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - Last Name');
                }
                if (String.isEmpty(Phone)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Phone, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - Phone');
                }
                if (String.isEmpty(State)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'State, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - State');
                }
                if (String.isEmpty(Country)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Country, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - Country');
                }
                if (String.isEmpty(PostalCode)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Postal Code, mandatory field is empty');

                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - Postal Code');
                }

                if (!hasErrors) {
                    Contact participantContact =
                            new Contact(FirstName = FirstName,
                                    LastName = LastName,
                                    MiddleName = MiddleName,
                                    Birthdate = Date.valueOf(DateOfBirth),
                                    Email = EmailAddress,
                                    Phone = Phone,
                                    MobilePhone = Phone2,
                                    MailingStreet = StreetAddress,
                                    MailingCity = City,
                                    MailingState = State,
                                    MailingCountry = Country,
                                    MailingPostalCode = PostalCode);
                    Database.SaveResult saveRes = Database.insert(participantContact);
                    if (!saveRes.isSuccess()) {
                        Database.Error error = saveRes.getErrors().get(0);
                        listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + error.getFields() + ' ' + error.getMessage());
                        system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + error.getFields() + ' ' + error.getMessage());
                    }

                    Participant__c participant =
                            new Participant__c(First_Name__c = FirstName,
                                    Last_Name__c = LastName,
                                    Middle_Name__c = MiddleName,
                                    Gender__c = Sex,
                                    Date_of_Birth__c = DateOfBirth,
                                    Email__c = EmailAddress,
                                    Phone__c = Phone,
                                    Phone_Type__c = PhoneType,
                                    Contact__c = participantContact.Id,
                                    Language_Preference__c  = Language,
                                    Mailing_Street__c = StreetAddress,
                                    Mailing_City__c = City,
                                    Mailing_State__c = State,
                                    Mailing_Country__c = Country,
                                    Mailing_Zip_Postal_Code__c = PostalCode);

                    Participant_Enrollment__c participantEnrollment =
                            new Participant_Enrollment__c(Participant_Status__c = selectedStatus,
                                    Study_Site__c = studySiteDetails.Id,
                                    Participant_Contact__c = participantContact.Id,
                                    PI_Contact__c = studySiteDetails.Principal_Investigator__c);

                    contactsById.put(participantContact.Id, participantContact);
                    participantsByContact.put(participantContact.Id, participant);
                    participantEnrollmentsByContact.put(participantContact.Id, participantEnrollment);
                } else {
                    listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                }
            }

            if (!contactsById.isEmpty()) {
                system.debug('!contactsById.isEmpty()');
                if (!participantsByContact.isEmpty()) {
                    system.debug('!participantsByContact.isEmpty()');
                    List<Database.SaveResult> saveReses = Database.insert(participantsByContact.values());
                    for (Database.SaveResult saveRes : saveReses) {
                        if (!saveRes.isSuccess()) {
                            Database.Error error = saveRes.getErrors().get(0);
                            listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant record insert: ' + error.getFields() + ' ' + error.getMessage());
                            system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant record insert: ' + error.getFields() + ' ' + error.getMessage());
                        }
                    }
                }

                for (Contact participantContact : contactsById.values()) {
                    Participant_Enrollment__c participantEnrollment = participantEnrollmentsByContact.get(participantContact.Id);
                    if (participantsByContact.get(participantContact.Id) != null) {
                        participantEnrollment.Participant__c = participantsByContact.get(participantContact.Id).Id;
                    }

                }

                if (!participantEnrollmentsByContact.isEmpty()) {
                    system.debug('!participantEnrollmentsByContact.isEmpty()');
                    List<Database.SaveResult> saveReses = Database.insert(participantEnrollmentsByContact.values());
                    for (Database.SaveResult saveRes : saveReses) {
                        if (!saveRes.isSuccess()) {
                            Database.Error error = saveRes.getErrors().get(0);
                            listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                            system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                        }
                    }
                }

                List<Participant_Study_Enrollment__c> partStdEnrolls = new List<Participant_Study_Enrollment__c>();
                for (Contact participantContact : contactsById.values()) {
                    Participant_Enrollment__c participantEnrollment = participantEnrollmentsByContact.get(participantContact.Id);
                    partStdEnrolls.add(new Participant_Study_Enrollment__c(Clinical_Trial_Profile__c = studySiteDetails.Clinical_Trial_Profile__c,
                            Participant__c = participantEnrollment.Participant__c,
                            Participant_Contact__c = participantContact.Id,
                            Participant_Enrollment__c = participantEnrollment.Id,
                            PI_Contact__c = studySiteDetails.Principal_Investigator__c,
                            Study_Site__c = studySiteDetails.Id));
                }

                if (!partStdEnrolls.isEmpty()) {
                    system.debug('!partStdEnrolls.isEmpty()');
                    List<Database.SaveResult> saveReses = Database.insert(partStdEnrolls);
                    for (Database.SaveResult saveRes : saveReses) {
                        if (!saveRes.isSuccess()) {
                            Database.Error error = saveRes.getErrors().get(0);
                            listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Study Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                            system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                        }
                    }
                }
            }

            system.debug('HEAP SIZE IS: ' + limits.getHeapSize() + ' enforced is: ' + limits.getLimitHeapSize() + 'on totalRecordCount: ' + totalRecordCount);
        } catch (Exception exp) {
            system.debug('ERROR during CSV parsing: ' + exp.getMessage() + ' ' + exp.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            List<String> finalEmails = null;

            system.debug('HEAP SIZE IS: ' + limits.getHeapSize() + ' enforced is: ' + limits.getLimitHeapSize() + 'on totalRecordCount: ' + totalRecordCount);
            sendNotificationEmail(listOfFailedRecords,
                    listOfFailedRecordsWithMsg,
                    studySiteDetails.Principal_Investigator__c,
                    uploadTime);
        } catch (Exception exp) {
            system.debug('ERROR during sending file with failed records: ' + exp.getMessage());
        }
    }

    private static void sendNotificationEmail(Set<String> listOfFailedRecords, Set<String> listOfFailedRecordsWithMsg, String piContactId, DateTime uploadTime) {
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'IQVIA Referral Hub' LIMIT 1];
        String formattedDate = uploadTime.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().toString());

        User usr = [SELECT Id, Email FROM User WHERE ContactId = :piContactId LIMIT 1];

        Messaging.SingleEmailMessage adminEmailToSend = new Messaging.SingleEmailMessage();
        adminEmailToSend.setToAddresses(new List<String> { usr.Email });
        adminEmailToSend.setOrgWideEmailAddressId(owea.id);
        adminEmailToSend.setSubject('Upload participants completed - ' + formattedDate);

        String failedRecordsCSV = '';
        for (String failedRecord : listOfFailedRecords) {
            failedRecordsCSV = failedRecordsCSV + failedRecord + '\n';
        }

        String failedRecordsCSVMsgs = '';
        for (String failedRecordMsg : listOfFailedRecordsWithMsg) {
            failedRecordsCSVMsgs = failedRecordsCSVMsgs + failedRecordMsg + '\n';
        }

        Messaging.EmailFileAttachment failedRecordsEfa = new Messaging.EmailFileAttachment();
        failedRecordsEfa.setFileName('ProcessOutput_Records_' + formattedDate + '.csv');
        failedRecordsEfa.setBody(Blob.valueOf(failedRecordsCSV));

        Messaging.EmailFileAttachment failedMsgsEfa = new Messaging.EmailFileAttachment();
        failedMsgsEfa.setFileName('ProcessOutput_Details_' + formattedDate + '.csv');
        failedMsgsEfa.setBody(Blob.valueOf(failedRecordsCSVMsgs));

        adminEmailToSend.setHtmlBody('');
        adminEmailToSend.setPlainTextBody('');

        adminEmailToSend.setFileAttachments(new List<Messaging.EmailFileAttachment> { failedRecordsEfa, failedMsgsEfa });

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { adminEmailToSend });
        }
    }

}