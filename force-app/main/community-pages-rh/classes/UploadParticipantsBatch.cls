/**
 * Created by alekseymoseev on 12/10/19.
 */

global class UploadParticipantsBatch implements Database.Batchable<List<String>>, Database.Stateful {

    @TestVisible
    private static Boolean isTestRunning = false;

    private List<List<String>> csvLines = new List<List<String>>();
    private Map<String, Integer> headerIndexes = new Map<String, Integer>();
    private String selectedStatus;
    private String studySiteId;
    private Boolean headerFailed;
    private Integer totalRecordCount = 0;

    private String emailError = '';
    Boolean valid = true;

    private Set<String> listOfFailedRecords = new Set<String>();
    private Set<String> listOfFailedRecordsWithMsg = new Set<String>();

    public UploadParticipantsBatch(List<List<String>> csvFileLines, String header, String studySiteId, String selectedStatus, Boolean headerFailed, Map<String, Integer> headerIndexes) {
        Integer totalRowCount = csvFileLines.size() - 1;
        this.headerIndexes = headerIndexes;
        this.selectedStatus = selectedStatus;
        this.studySiteId = studySiteId;

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
                    insert participantContact;
                    Database.SaveResult saveRes = Database.insert(participantContact);
                    if (!saveRes.isSuccess()) {
                        Database.Error error = saveRes.getErrors().get(0);
                        listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant record insert: ' + error.getFields() + ' ' + error.getMessage());
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
                                    Study_Site__c = studySiteId,
                                    Participant_Contact__c = participantContact.Id);

                    contactsById.put(participantContact.Id, participantContact);
                    participantsByContact.put(participantContact.Id, participant);
                    participantEnrollmentsByContact.put(participantContact.Id, participantEnrollment);
                } else {
                    listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                }
            }

            if (!contactsById.isEmpty()) {
                if (!participantsByContact.isEmpty()) {
                    insert participantsByContact.values();
                }

                for (Contact participantContact : contactsById.values()) {
                    Participant_Enrollment__c participantEnrollment = participantEnrollmentsByContact.get(participantContact.Id);
                    if (participantsByContact.get(participantContact.Id) != null) {
                        participantEnrollment.Participant__c = participantsByContact.get(participantContact.Id).Id;
                    }
                }

                if (!participantEnrollmentsByContact.isEmpty()) {
                    insert participantEnrollmentsByContact.values();
                }
            }

            system.debug('HEAP SIZE IS: ' + limits.getHeapSize() + ' enforced is: ' + limits.getLimitHeapSize() + 'on totalRecordCount: ' + totalRecordCount);
        } catch (Exception exp) {
            system.debug('ERROR during CSV parsing: ' + exp.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            List<String> finalEmails = null;

            system.debug('HEAP SIZE IS: ' + limits.getHeapSize() + ' enforced is: ' + limits.getLimitHeapSize() + 'on totalRecordCount: ' + totalRecordCount);
            /*sendNotificationEmail(listOfFailedRecords,
                                  listOfFailedRecordsWithMsg);*/
        } catch (Exception exp) {
            system.debug('ERROR during sending file with failed records: ' + exp.getMessage());
        }
    }

    /*private static void sendNotificationEmail(List<String> listOfFailedRecords, List<String> listOfFailedRecordsWithMsg) {

    }*/

}