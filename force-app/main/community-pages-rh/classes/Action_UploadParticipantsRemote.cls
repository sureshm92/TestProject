/**
 * Created by alekseymoseev on 12/10/19.
 */

public with sharing class Action_UploadParticipantsRemote {

    public static final String TOTAL_RECORDS = 'TOTAL RECORDS COUNT';
    public static final String FAILED_COUNT = 'FAILED COUNT';

    public static final List<String> HEADER_COLUMNS = new List<String> { 'FirstName', 'LastName', 'MiddleName', 'Initials', 'Gender', 'DateOfBirth', 'Email', 'Phone', 'Country', 'State', 'City', 'Street', 'PostalCode', 'Language' };

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
            Boolean headerFailed = (csvHeaderData.size() != HEADER_COLUMNS.size() && csvHeaderData.size() < (HEADER_COLUMNS.size() - 1));
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

            //Database.executeBatch(new UploadParticipantsBatch(csvFileLines, csvFileLines.get(0), studySiteId, headerFailed, headerIndexes), 100);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}