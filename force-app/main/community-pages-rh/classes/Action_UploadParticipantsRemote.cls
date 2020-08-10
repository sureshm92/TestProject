/**
 * Created by alekseymoseev on 12/10/19.
 */

public without sharing class Action_UploadParticipantsRemote {

    public static final List<String> HEADER_COLUMNS = new List<String> { 'FIRST NAME', 'MIDDLE NAME', 'LAST NAME', 'NICKNAME', 'SEX', 'DATE OF BIRTH', 'EMAIL ADDRESS', 'PHONE', 'PHONE TYPE', 'ALTERNATIVE PHONE', 'ALT. PHONE TYPE', 'STREET ADDRESS', 'CITY', 'STATE', 'POSTAL CODE', 'COUNTRY', 'LANGUAGE' };
    public static final List<String> MANDATORY_HEADER_COLUMNS = new List<String> { 'FIRST NAME', 'LAST NAME', 'PHONE', 'COUNTRY', 'STATE', 'POSTAL CODE' };


    @AuraEnabled
    public static List<LabelValueItem> getParticipantsStatuses(Id studySiteId) {
        List<LabelValueItem> participantStatuses = new List<LabelValueItem>();
        List<Study_Site__c> sites = [SELECT Id, Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c, Clinical_Trial_Profile__r.Initial_Visit_Required__c, Clinical_Trial_Profile__r.Final_Consent_Required__c FROM Study_Site__c WHERE Id = :studySiteId];
        if(sites.isEmpty())
            return participantStatuses;
        return PEStatusState.getParticipantImportStatusesLV(sites[0].Clinical_Trial_Profile__r);
    }

    @AuraEnabled
        public static void uploadParticipants(List<String> csvFileLines, String fileName, String studySiteId, String selectedStatus, Boolean createUsers,Boolean doContact,Boolean allowEmail,Boolean allowPhone,Boolean allowSMS) {
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
                            headerIndexes.put(columnName.toUpperCase(), indx);
                        }
                    }
                }
            }

            Integer totalRowCount = 0;
            Map<Integer, List<String>> finalCSVLines = new Map<Integer, List<String>>();
            if (csvFileLines.size() != 0 && !headerFailed) {
                for (Integer rowIndex = 2; rowIndex < csvFileLines.size(); rowIndex++) {
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

                    finalCSVLines.put(totalRowCount, line);
                }
            }

            Database.executeBatch(new UploadParticipantsBatch(finalCSVLines.values(), csvFileLines.get(0), studySiteId, selectedStatus, headerFailed, headerIndexes, createUsers,doContact,allowEmail,allowPhone,allowSMS), 5);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}