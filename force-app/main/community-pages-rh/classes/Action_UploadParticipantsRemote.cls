/**
 * Created by alekseymoseev on 12/10/19.
 */

public with sharing class Action_UploadParticipantsRemote {

    public static final List<String> HEADER_COLUMNS = new List<String> { 'First Name', 'Middle Name', 'Last Name', 'Nickname', 'Sex', 'Date of Birth', 'Email Address', 'Phone', 'Phone Type', 'Phone2', 'Phone Type2', 'Street Address', 'City', 'State', 'Postal Code', 'Country', 'Language' };
    public static final List<String> MANDATORY_HEADER_COLUMNS = new List<String> { 'First Name', 'Last Name', 'Phone', 'Country', 'State', 'Postal Code' };

    @AuraEnabled
    public static List<LabelValueItem> getParticipantsStatuses() {
        List<LabelValueItem> participantStatuses = new List<LabelValueItem>();

        for (Schema.PicklistEntry field :  Participant_Enrollment__c.Participant_Status__c.getDescribe().getPicklistValues()){
            participantStatuses.add(new LabelValueItem(field.getLabel(), field.getValue()));
        }

        return participantStatuses;
    }

    @AuraEnabled
    public static void uploadParticipants(List<String> csvFileLines, String fileName, String studySiteId, String selectedStatus) {
        try {
            Map<String, Integer> headerIndexes = new Map<String, Integer>();
            List<String> csvHeaderData = csvFileLines[0].toUpperCase().split(',');
            Boolean headerFailed = (csvHeaderData.size() != MANDATORY_HEADER_COLUMNS.size() && csvHeaderData.size() < MANDATORY_HEADER_COLUMNS.size());
            if (!headerFailed) {
                for (Integer indx = 0; indx < csvHeaderData.size(); indx++) {
                    if (csvHeaderData[indx] != null && String.isNotBlank(csvHeaderData[indx])) {
                        String columnName = csvHeaderData[indx].trim();
                        system.debug('Header: ' + columnName);
                        if (HEADER_COLUMNS.contains(columnName)) {
                            headerIndexes.put(columnName, indx);
                        }
                    }
                }
            }

            Integer totalRowCount = 0;
            Map<Integer, List<String>> groupedCSVLines = new Map<Integer, List<String>>();
            if (csvFileLines.size() != 0 && !headerFailed) {
                for (Integer rowIndex = 1; rowIndex < csvFileLines.size(); rowIndex++) {
                    List<String> line = csvFileLines.get(rowIndex).trim().removeEnd(',').trim().removeEnd(',').split(',');
                    if (line == null || line.isEmpty() || line.size() == 1) {
                        continue;
                    }
                    totalRowCount++;
                    if (line.size() < HEADER_COLUMNS.size()) {
                        for (Integer index = line.size(); index < (HEADER_COLUMNS.size()); index++) {
                            line.add('');
                        }
                    }

                    groupedCSVLines.put(totalRowCount, line);
                }
            }

            Database.executeBatch(new UploadParticipantsBatch(groupedCSVLines.values(), csvFileLines.get(0), studySiteId, selectedStatus, headerFailed, headerIndexes), 25);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}