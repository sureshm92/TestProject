/**
 * Created by alekseymoseev on 12/10/19.
 */

public without sharing class Action_UploadParticipantsRemote {
    public static final List<String> HEADER_COLUMNS = new List<String>{
        'PARTICIPANT FIRST NAME',
        'PARTICIPANT MIDDLE NAME',
        'PARTICIPANT LAST NAME',
        'PARTICIPANT NICKNAME',
        'PARTICIPANT SEX',
        'PARTICIPANT DATE OF BIRTH',
        'PARTICIPANT EMAIL ADDRESS',
        'PARTICIPANT PHONE',
        'PARTICIPANT PHONE TYPE',
        'PARTICIPANT ALTERNATIVE PHONE',
        'PARTICIPANT ALT. PHONE TYPE',
        //'STREET ADDRESS',
        //'CITY',
        'STATE',
        'POSTAL CODE',
        'COUNTRY',
        'LANGUAGE',
        'PRIMARY DELEGATE FIRST NAME',
        'PRIMARY DELEGATE LAST NAME',
        'PRIMARY DELEGATE EMAIL',            
        'PRIMARY DELEGATE PHONE NUMBER',
        'PRIMARY DELEGATE PHONE TYPE',
        'PRIMARY DELEGATE YOB',
        'CONFIRM PRIMARY DELEGATE IS AN ADULT'
    };
    public static final List<String> MANDATORY_HEADER_COLUMNS = new List<String>{
        'PARTICIPANT FIRST NAME',
        'PARTICIPANT LAST NAME',
        'PARTICIPANT PHONE',
        'COUNTRY',
        'STATE',
        'POSTAL CODE'
    };

    @AuraEnabled
    public static List<LabelValueItem> getParticipantsStatuses(Id studySiteId) {
        List<LabelValueItem> participantStatuses = new List<LabelValueItem>();
        List<Study_Site__c> sites = [
            SELECT
                Id,
                Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                Clinical_Trial_Profile__r.Initial_Visit_Required__c,
                Clinical_Trial_Profile__r.Final_Consent_Required__c
            FROM Study_Site__c
            WHERE Id = :studySiteId
        ];
        if (sites.isEmpty())
            return participantStatuses;
        return PEStatusState.getParticipantImportStatusesLV(sites[0].Clinical_Trial_Profile__r);
    }

    @AuraEnabled
    public static void uploadParticipants(
        List<String> csvFileLines,
        String fileName,
        String studySiteId,
        String selectedStatus,
        Boolean createUsers,
        Boolean doContact,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS
    ) {
        try {
            Map<String, Integer> headerIndexes = new Map<String, Integer>();
            List<String> csvHeaderData = csvFileLines[0].toUpperCase().split(',');
            Boolean headerFailed = (csvHeaderData.size() != MANDATORY_HEADER_COLUMNS.size() &&
            csvHeaderData.size() < MANDATORY_HEADER_COLUMNS.size());
            if (!headerFailed) {
                for (Integer indx = 0; indx < csvHeaderData.size(); indx++) {
                    if (csvHeaderData[indx] != null && String.isNotBlank(csvHeaderData[indx])) {
                        String columnName = csvHeaderData[indx].trim();
                        system.debug('Header: ' + columnName);
                        if (HEADER_COLUMNS.contains(columnName)) {
                            headerIndexes.put(columnName.toUpperCase(), indx);
                        }
                    }
                }
            }

            Integer totalRowCount = 0;
            Map<Integer, List<String>> finalCSVLines = new Map<Integer, List<String>>();
            if (csvFileLines.size() != 0 && !headerFailed) {
                for (Integer rowIndex = 2; rowIndex < csvFileLines.size(); rowIndex++) {
                    // List<String> line = csvFileLines.get(rowIndex).trim().removeEnd(',').trim().removeEnd(',').split(',');
                    List<String> line = convertPerLineToList(csvFileLines.get(rowIndex));
                    if (line == null || line.isEmpty() || line.size() == 1) {
                        continue;
                    }
                    totalRowCount++;
                    if (line.size() < HEADER_COLUMNS.size()) {
                        for (
                            Integer index = line.size(); index < (HEADER_COLUMNS.size()); index++
                        ) {
                            line.add('');
                        }
                    }

                    finalCSVLines.put(totalRowCount, line);
                }
            }
			system.debug('>>finalCSVLines>>'+finalCSVLines);
            system.debug('>>csvFileLines>>'+csvFileLines);
            Database.executeBatch(
                new UploadParticipantsBatch(
                    finalCSVLines.values(),
                    csvFileLines.get(0),
                    studySiteId,
                    selectedStatus,
                    headerFailed,
                    headerIndexes,
                    createUsers,
                    doContact,
                    allowEmail,
                    allowPhone,
                    allowSMS
                ),
                7
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static List<String> convertPerLineToList(String str) {
        List<String> perLineList = new List<String>();
        String csvLine = str;
        String prevLine = csvLine;
        Integer startIndex;
        Integer endIndex;

        while (csvLine.indexOf('"') > -1) {
            if (startIndex == null) {
                startIndex = csvLine.indexOf('"');
                csvLine =
                    csvLine.substring(0, startIndex) +
                    ':quotes:' +
                    csvLine.substring(startIndex + 1, csvLine.length());
            } else {
                if (endIndex == null) {
                    endIndex = csvLine.indexOf('"');
                    csvLine =
                        csvLine.substring(0, endIndex) +
                        ':quotes:' +
                        csvLine.substring(endIndex + 1, csvLine.length());
                }
            }

            if (startIndex != null && endIndex != null) {
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine =
                    csvLine.substring(0, startIndex) +
                    sub +
                    csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }

        for (String column : csvLine.split(',')) {
            column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            perLineList.add(column.trim());
        }
        return perLineList;
    }
}