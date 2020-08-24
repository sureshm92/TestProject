/**
* Created by alekseymoseev on 12/10/19.
*/

global without sharing class UploadParticipantsBatch implements Database.Batchable<List<String>>, Database.Stateful {
    
    @TestVisible
    private static Boolean isTestRunning = false;
    private static final String PARTICIPANT_USER_MODE = 'Participant';
    
    private List<List<String>> csvLines = new List<List<String>>();
    private Map<String, Integer> headerIndexes = new Map<String, Integer>();
    private String selectedStatus;
    private Study_Site__c studySiteDetails;
    private Integer totalRecordCount = 0;
    private Integer errorRecordCount = 0;
    private Account participantAccount;
    private Id uploaderContactId;
    private Boolean createUsers;
    private Boolean doContact;
    private Boolean allowEmail;
    private Boolean allowPhone;
    private Boolean allowSMS;    
    private User uploadUser;
    
    private String emailError = '';
    private Boolean valid = true;
    private DateTime uploadTime;
    
    private Set<String> listOfFailedRecords = new Set<String>();
    private Set<String> listOfFailedRecordsWithMsg = new Set<String>();
    
    private Set<String> genderLVSet = new Set<String> { 'Female', 'Male' };
        private Set<String> phoneTypeLVSet = new Set<String>();
    private Set<String> laguageLVSet = new Set<String>();
    
    
    public UploadParticipantsBatch(List<List<String>> csvFileLines, String header, String studySiteId, String selectedStatus, Boolean headerFailed, Map<String, Integer> headerIndexes, Boolean createUsers,Boolean doContact,Boolean allowEmail,Boolean allowPhone,Boolean allowSMS) {
        uploadTime = DateTime.now();
        Integer totalRowCount = csvFileLines.size();
        this.headerIndexes = headerIndexes;
        this.selectedStatus = selectedStatus;
        this.createUsers = createUsers;
        //this.doNotContactParticipants = doNotContactParticipants;
        this.doContact = doContact;
        this.allowEmail = allowEmail;
        this.allowPhone = allowPhone;
        this.allowSMS = allowSMS;
        
        studySiteDetails = [SELECT Id, Name, Principal_Investigator__c, Clinical_Trial_Profile__c, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE Id = :studySiteId];
        
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
            uploadUser = [SELECT ContactId, Contact.MailingCountry, Contact.MailingCountryCode, Contact.Language__c FROM User WHERE Id = :UserInfo.getUserId()];
            if (uploadUser != null) {
                uploaderContactId = uploadUser.ContactId;
            }
            participantAccount = [SELECT Id FROM Account WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME LIMIT 1 FOR UPDATE];
            csvLines = csvFileLines;
            
            List<LabelValueItem> phoneTypeLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Phone_Type__c);
            for (LabelValueItem lb : phoneTypeLVList) {
                phoneTypeLVSet.add(lb.value);
            }
            List<LabelValueItem> languageLVList = SObjectHelper.getPicklistLabelValueList(Participant__c.Language_Preference_Code__c);
            for (LabelValueItem lb : languageLVList) {
                laguageLVSet.add(lb.value);
            }
        }
    }
    
    global Iterable<List<String>> start(Database.BatchableContext bc) {
        return csvLines;
    }
    
    global void execute(Database.BatchableContext BC, List<List<String>> csvChunkLines) {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        
        if (!valid) {
            return;
        }
        
        try {
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(studySiteDetails.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
            
            Map<Id, Contact> contactsById = new Map<Id, Contact>();
            Map<Id, Participant__c> participantsByContact = new Map<Id, Participant__c>();
            Map<Id, Participant_Enrollment__c> participantEnrollmentsByContact = new Map<Id, Participant_Enrollment__c>();
            Map<Id, Id> createUsersMap = new Map<Id, Id>();
            Set<Id> insertedContacts = new Set<Id>();
            Set<Id> dupclicateContactIds = new Set<Id>();
            Map<Id,Id> duplicateContactUsersMap = new Map<Id,Id>();
            Set<Id> insertUsersWithDefaultSettings = new Set<Id>();
            
            for (List<String> csvRecordData : csvChunkLines) {
                if (csvRecordData == null || csvRecordData.isEmpty()) {
                    continue;
                }
                
                Set<Id> dupclicateParticipantstIds = new Set<Id>();
                
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
                String State = '';
                String PostalCode = '';
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
                Phone2 = headerIndexes.get('ALTERNATIVE PHONE') != null && csvRecordData[headerIndexes.get('ALTERNATIVE PHONE')] != null ? csvRecordData[headerIndexes.get('ALTERNATIVE PHONE')].trim() : null;
                PhoneType2 = headerIndexes.get('ALT. PHONE TYPE') != null && csvRecordData[headerIndexes.get('ALT. PHONE TYPE')] != null ? csvRecordData[headerIndexes.get('ALT. PHONE TYPE')].trim() : null;
                State = headerIndexes.get('STATE') != null && csvRecordData[headerIndexes.get('STATE')] != null ? csvRecordData[headerIndexes.get('STATE')].trim() : null;
                PostalCode = headerIndexes.get('POSTAL CODE') != null && csvRecordData[headerIndexes.get('POSTAL CODE')] != null ? csvRecordData[headerIndexes.get('POSTAL CODE')].trim() : null;
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
                if (!String.isEmpty(PhoneType) && !phoneTypeLVSet.contains(PhoneType)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Phone Type, value is not correct');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'value is not correct - Phone Type');
                }
                if (!String.isEmpty(Sex) && !genderLVSet.contains(Sex)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Gender, value is not correct');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'value is not correct - Gender');
                }
                
                Map<String, List<LabelValueItem>> statesByCountryMap = CountryStateUtil.getStatesByCountryMap();
                if (statesByCountryMap.get(uploadUser.Contact.MailingCountryCode) != null && !statesByCountryMap.get(uploadUser.Contact.MailingCountryCode).isEmpty() && String.isEmpty(State)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'State, mandatory field is empty');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - State');
                }
                if (String.isEmpty(PostalCode)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Postal Code, mandatory field is empty');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'mandatory field is empty - Postal Code');
                }
                try {
                    Date resultDate = null;
                    if (!String.isBlank(DateOfBirth)) {
                        try {
                            Integer year;
                            Integer month;
                            Integer day;
                            if (DateOfBirth.contains('.')) {
                                List<String> vals = DateOfBirth.split('.');
                                DateOfBirth = vals[2] + '-' + vals[1] + '-' + vals[0];
                                year = Integer.valueOf(vals[2]);
                                month = Integer.valueOf(vals[1]);
                                day = Integer.valueOf(vals[0]);
                            } else if (DateOfBirth.contains('/')) {
                                List<String> vals = DateOfBirth.split('/');
                                year = Integer.valueOf(vals[0]);
                                if (vals[1] > '12') {
                                    DateOfBirth = vals[0] + '-' + vals[2] + '-' + vals[1];
                                    month = Integer.valueOf(vals[2]);
                                    day = Integer.valueOf(vals[1]);
                                } else {
                                    DateOfBirth = vals[0] + '-' + vals[1] + '-' + vals[2];
                                    month = Integer.valueOf(vals[1]);
                                    day = Integer.valueOf(vals[2]);
                                }
                            } else if (DateOfBirth.contains('-')) {
                                List<String> vals = DateOfBirth.split('-');
                                year = Integer.valueOf(vals[0]);
                                month = Integer.valueOf(vals[1]);
                                day = Integer.valueOf(vals[2]);
                            }
                            Date daysInMonth = Date.newInstance(year, month + 1, 1);
                            daysInMonth = daysInMonth.addDays(-1);
                            if (daysInMonth.day() < day) {
                                resultDate = null;
                                DateOfBirth = null;
                            } else {
                                resultDate = Date.valueOf(DateOfBirth);
                            }
                        } catch (Exception exp) {
                            System.debug('ERROR: ' + totalRecordCount + ', ' + 'Date of Birth, Incorrect value');
                            resultDate = null;
                            DateOfBirth = null;
                        }
                    }
                    if (resultDate == null || String.isBlank(DateOfBirth) || resultDate > System.today()) {
                        hasErrors = true;
                        system.debug('ERROR: ' + totalRecordCount + ', ' + 'Date of Birth, incorrect, can\'t be empty or in the future');
                        
                        listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'Date of Birth, incorrect, can\'t be empty or in the future');
                    }
                } catch (Exception exp) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Date of Birth, Incorrect value');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'Date of Birth, Incorrect value');
                }
                if (!String.isBlank(Language) && String.isBlank(uploadUser.Contact.Language__c) && !laguageLVSet.contains(Language)) {
                    hasErrors = true;
                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Language, Incorrect value');
                    
                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'Language, Incorrect value');
                }
                
                if (!hasErrors) {
                    Contact participantContact =
                        new Contact(FirstName = FirstName,
                                    LastName = LastName,
                                    AccountId = participantAccount.Id,
                                    MiddleName = MiddleName,
                                    Birthdate = Date.valueOf(DateOfBirth),
                                    Email = EmailAddress,
                                    Phone = Phone,
                                    MobilePhone = Phone2,
                                    MailingState = State,
                                    MailingCountry = uploadUser.Contact.MailingCountry,
                                    MailingCountryCode = uploadUser.Contact.MailingCountryCode,
                                    MailingPostalCode = PostalCode,
                                    userCommunityMode__c = PARTICIPANT_USER_MODE,
                                    Consent_To_Inform_About_Study__c = createUsers,
                                    Language__c = (String.isBlank(Language) ? uploadUser.Contact.Language__c : Language));
                    
                    Participant__c participant =
                        new Participant__c(First_Name__c = FirstName,
                                           Last_Name__c = LastName,
                                           Middle_Name__c = MiddleName,
                                           Nickname__c = Nickname,
                                           Gender__c = Sex,
                                           Date_of_Birth__c = DateOfBirth,
                                           Email__c = EmailAddress,
                                           Phone__c = Phone,
                                           Phone_Type__c = PhoneType,
                                           Alternative_Phone_Number__c = Phone2,
                                           Alternative_Phone_Type__c = PhoneType2,
                                           Language_Preference_Code__c = (String.isBlank(Language) ? uploadUser.Contact.Language__c : Language),
                                           Mailing_State__c = State,
                                           Mailing_Country__c = uploadUser.Contact.MailingCountry,
                                           Mailing_Zip_Postal_Code__c = PostalCode);
                    participant.Adult__c = ReferringRemote.checkNeedsGuardian(JSON.serialize(participant)) == 'false';
                    
                    //Duplicates check
                    Boolean isDuplicate = false;
                    ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(participant);
                    Participant__c participantDuplicate = duplicateService.findDuplicate(participant);
                    isDuplicate = participantDuplicate != null;
                    Contact contactDuplicate = duplicateService.findDuplicateContact(participant);
                    System.debug('contact duplicate>>>>'+contactDuplicate);
                    isDuplicate = isDuplicate || contactDuplicate != null;
                    
                    if (!isDuplicate) {
                        try {
                            Database.SaveResult saveRes = Database.insert(participantContact, false);
                            if (!saveRes.isSuccess()) {
                                errorRecordCount++;
                                Database.Error error = saveRes.getErrors().get(0);
                                listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + error.getFields() + ' ' + error.getMessage());
                                listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                                system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + error.getFields() + ' ' + error.getMessage());
                                
                                continue;
                            }
                        } catch (Exception exp) {
                            errorRecordCount++;
                            listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + exp.getMessage());
                            listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                            system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Contact record insert: ' + exp.getMessage());
                            
                            continue;
                        }
                    } else {
                        if (contactDuplicate != null) {
                            dupclicateContactIds.add(contactDuplicate.Id);
                        } else {
                            dupclicateParticipantstIds.add(participantDuplicate.Id);
                        }
                        
                        if (!dupclicateParticipantstIds.isEmpty()) {
                            for (Participant__c p : [
                                SELECT Id,
                                Contact__c
                                FROM Participant__c
                                WHERE Id IN :dupclicateParticipantstIds
                            ]) {
                                dupclicateContactIds.add(p.Contact__c);
                            }
                        }
                        
                        System.debug('dupclicateContactIds>>>>'+dupclicateContactIds);
                        if (!dupclicateContactIds.isEmpty()) {
                            Set<Id> duplicateParticipantEnrollments = new Set<Id>();
                            Map<Id,Participant__c> contactParticipantMap = new Map<Id,Participant__c>();
                            
                            for (User u : [
                                SELECT Id,
                                ContactId
                                FROM User
                                WHERE ContactId IN :dupclicateContactIds
                            ]) {
                                duplicateContactUsersMap.put(u.ContactId, u.Id);
                            }
                            for (Participant_Enrollment__c pEnrollment : [
                                SELECT Id,
                                Participant_Contact__c
                                FROM Participant_Enrollment__c
                                WHERE Participant_Contact__c IN :dupclicateContactIds AND
                                (Study_Site__c = :studySiteDetails.Id OR
                                 Study_Site__r.Clinical_Trial_Profile__c = :studySiteDetails.Clinical_Trial_Profile__c)
                            ]) {
                                duplicateParticipantEnrollments.add(pEnrollment.Participant_Contact__c);
                            }
                            System.debug('duplicateParticipantEnrollments>>>>>>'+duplicateParticipantEnrollments);
                            for (Participant__c part : [
                                SELECT Id,
                                Contact__c
                                FROM Participant__c
                                WHERE Contact__c IN :dupclicateContactIds
                            ]) {
                                contactParticipantMap.put(part.Contact__c, part);
                            }
                            System.debug('contactParticipantMap>>>>>>>>'+contactParticipantMap);
                            System.debug('dupclicateContactIds>>>>>>>>'+dupclicateContactIds);
                            for (Id cId : dupclicateContactIds) {
                                if (!duplicateParticipantEnrollments.contains(cId) && contactParticipantMap.get(cId) != null) {
                                    participantContact.Id = cId;
                                    participant.Id = contactParticipantMap.get(cId).Id;
                                } else {
                                    errorRecordCount++;
                                    system.debug('ERROR: ' + totalRecordCount + ', ' + 'Duplicate Participant record');
                                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ' + 'Duplicate Participant record');
                                    listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                                    
                                    continue;
                                }
                            }
                        }
                    }
                    
                    if (participantContact.Id != null) {
                        participant.Contact__c = participantContact.Id;
                        Participant_Enrollment__c participantEnrollment =
                            new Participant_Enrollment__c(Participant_Status__c = selectedStatus,
                                                          Study_Site__c = studySiteDetails.Id,
                                                          Referred_Date__c = System.today(),
                                                          Participant_Contact__c = participantContact != null ? participantContact.Id : null,
                                                          Referral_Completed_by__c = uploaderContactId,
                                                          Referral_Source__c = ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI,
                                                          PI_Contact__c = studySiteDetails.Principal_Investigator__c);
                        
                        contactsById.put(participantContact.Id, participantContact);
                        
                        try {
                            if (participant.Id == null) {
                                Database.SaveResult saveRes = Database.insert(participant, false);
                                if (!saveRes.isSuccess()) {
                                    Database.Error error = saveRes.getErrors().get(0);
                                    listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant record insert: ' + error.getFields() + ' ' + error.getMessage());
                                    system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant record insert: ' + error.getFields() + ' ' + error.getMessage());
                                } else {
                                    insertedContacts.add(saveRes.getId());
                                    participantsByContact.put(participantContact.Id, participant);
                                }
                            }
                        } catch (Exception exp) {
                            listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant record insert: ' + exp.getMessage());
                            system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant record insert: ' + exp.getMessage());
                        }
                        
                        if (participant.Id != null) {
                            participantEnrollment.Participant__c = participant.Id;
                            //participantEnrollment.Permit_IQVIA_to_contact_about_study__c = !doNotContactParticipants;
                            //Added for 1936
                            participantEnrollment.Permit_Mail_Email_contact_for_this_study__c = allowEmail;
                            participantEnrollment.Permit_Voice_Text_contact_for_this_study__c = allowPhone;
                            participantEnrollment.Permit_SMS_Text_for_this_study__c = allowSMS;
                            participantEnrollment.Permit_IQVIA_to_contact_about_study__c = doContact;
                            //
                            
                            Database.SaveResult saveRes = Database.insert(participantEnrollment, false);
                            participantEnrollmentsByContact.put(participantEnrollment.Participant_Contact__c, participantEnrollment);
                            if (!saveRes.isSuccess()) {
                                Database.Error error = saveRes.getErrors().get(0);
                                listOfFailedRecordsWithMsg.add('' + totalRecordCount + ', ERROR on Participant Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                                system.debug('ERROR: ' + totalRecordCount + ', ERROR on Participant Enrollment record insert: ' + error.getFields() + ' ' + error.getMessage());
                            }
                            
                            actionAssignContactPermissions.addPermission(participantContact.Id, permissionSetName);
                        } else {
                            contactsById.remove(participantContact.Id);
                            delete participantContact;
                            listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                        }
                    } else {
                        continue;
                    }
                } else {
                    errorRecordCount++;
                    listOfFailedRecords.add(('' + csvLines.get(totalRecordCount - 1)).removeStart('(').removeEnd(')') + ', ' + totalRecordCount);
                }
            }
            
            if (createUsers) {
                system.debug('CREATE_USERS: ' + insertedContacts);
                if (!insertedContacts.isEmpty()) {
                    for (Contact c : contactsById.values()) {
                        if (insertedContacts.contains(participantsByContact.get(c.Id).Id)) {
                            if (participantEnrollmentsByContact.get(c.Id) != null) {
                                createUsersMap.put(participantEnrollmentsByContact.get(c.Id).Participant_Contact__c, participantEnrollmentsByContact.get(c.Id).PI_Contact__c);
                            } else {
                                insertUsersWithDefaultSettings.add(c.Id);
                            }
                        }
                    }
                }
                if (!dupclicateContactIds.isEmpty()) {
                    for (Id contId : dupclicateContactIds) {
                        if (!duplicateContactUsersMap.keySet().contains(contId)) {
                            if (participantEnrollmentsByContact.get(contId) != null) {
                                createUsersMap.put(participantEnrollmentsByContact.get(contId).Participant_Contact__c, participantEnrollmentsByContact.get(contId).PI_Contact__c);
                            } else {
                                insertUsersWithDefaultSettings.add(contId);
                            }
                        }
                    }
                }
                if (!createUsersMap.isEmpty()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(createUsersMap);
                }
                if (!insertUsersWithDefaultSettings.isEmpty()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(insertUsersWithDefaultSettings);
                }
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
                
                if (listOfFailedRecords.size() > 1 && errorRecordCount != (listOfFailedRecords.size() - 1)) {
                    errorRecordCount = listOfFailedRecords.size() - 1;
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
                                  uploadTime,
                                  studySiteDetails,
                                  totalRecordCount,
                                  errorRecordCount);
        } catch (Exception exp) {
            system.debug('ERROR during sending file with failed records: ' + exp.getMessage());
        }
    }
    
    private static void sendNotificationEmail(Set<String> listOfFailedRecords, Set<String> listOfFailedRecordsWithMsg, String piContactId, DateTime uploadTime, Study_Site__c studySiteDetails, Integer totalRecordCount, Integer errorRecordCount) {
        String formattedDate = uploadTime.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().toString());
        System.debug('ErrorRecordsCount>>>>'+errorRecordCount);
        User piUser = [SELECT Id, Email, Contact.Email FROM User WHERE ContactId = :piContactId LIMIT 1];
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName LIKE '%IQVIA Referral Hub' LIMIT 1];
        Id importParticipantsTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :SendEmailTemplate.EMAIL_TEMPLATE_PATIENT_IMPORT LIMIT 1].Id;
        
        Messaging.SingleEmailMessage adminEmailToSend = new Messaging.SingleEmailMessage();
        adminEmailToSend.setTemplateId(importParticipantsTemplateId);
        adminEmailToSend.setTargetObjectId(piContactId);
        adminEmailToSend.setSaveAsActivity(false);
        adminEmailToSend.setOrgWideEmailAddressId(owea.Id);
        adminEmailToSend.setWhatId(studySiteDetails.Id);
        
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
        
        Savepoint sp = Database.setSavepoint();
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { adminEmailToSend });
        }
        Database.rollback(sp);
        
        String htmlBody = (!Test.isRunningTest() ? adminEmailToSend.getHtmlBody() : 'test');
        htmlBody = htmlBody.replace('##SucRecCount', '' + (totalRecordCount - errorRecordCount));
        htmlBody = htmlBody.replace('##TotalRecCount', '' + totalRecordCount);
        String plainBody = (!Test.isRunningTest() ? adminEmailToSend.getPlainTextBody() : 'test');
        plainBody = plainBody.replace('##SucRecCount', '' + (totalRecordCount - errorRecordCount));
        plainBody = plainBody.replace('##TotalRecCount', '' + totalRecordCount);
        
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(new List<String> { (piUser.Email != null ? piUser.Email : piUser.Contact.Email) });
        emailToSend.setPlainTextBody(plainBody);
        emailToSend.setHtmlBody(htmlBody);
        emailToSend.setSubject(adminEmailToSend.getSubject());
        emailToSend.setOrgWideEmailAddressId(owea.Id);
        
        emailToSend.setFileAttachments(new List<Messaging.EmailFileAttachment> { failedRecordsEfa, failedMsgsEfa });
        
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailToSend });
        }
    }
    
}