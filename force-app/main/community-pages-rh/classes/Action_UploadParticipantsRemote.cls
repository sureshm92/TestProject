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
        'PARTICIPANT MONTH OF BIRTH',
        'PARTICIPANT YEAR OF BIRTH',
        'PARTICIPANT AGE',
        'PARTICIPANT EMAIL ADDRESS',
        'PARTICIPANT PHONE',
        'PARTICIPANT PHONE TYPE',
        'PARTICIPANT ALTERNATIVE PHONE',
        'PARTICIPANT ALT. PHONE TYPE',
        //'STREET ADDRESS',
        //'CITY',
        'STATE',
        'POSTAL CODE',
        'INITIAL VISIT DATE',
        'INITIAL VISIT TIME',
        'INITIAL VISIT TIME AM/PM',
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
    public static ParticipantStatusesVisitPlans getParticipantsStatusesAndVisitPlans(Id studySiteId) {
        ParticipantStatusesVisitPlans result = new ParticipantStatusesVisitPlans();
        List<Study_Site__c> sites = [
            SELECT
                Id,
                Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                Clinical_Trial_Profile__r.Initial_Visit_Required__c,
                Clinical_Trial_Profile__r.Final_Consent_Required__c
            FROM Study_Site__c
            WHERE Id = :studySiteId
        ];
        if (sites.isEmpty()){
            result.participantStatuses = new List<LabelValueItem>();
            result.visitPlansLVList = new List<LabelValueItem>();
        }else{
            result.participantStatuses = PEStatusState.getParticipantImportStatusesLV(sites[0].Clinical_Trial_Profile__r);
        	result.visitPlansLVList =StudySiteService.getVisitPlansLVList(studySiteId);
        }
        return result;    
    }

    public Class ParticipantStatusesVisitPlans{
        @AuraEnabled
        public List<LabelValueItem> participantStatuses;
        @AuraEnabled
        public List<LabelValueItem> visitPlansLVList;
    }
    
    @AuraEnabled
    public static String uploadParticipants(
        List<String> csvFileLines,
        String fileName,
        String studySiteId,
        String selectedStatus,
        Boolean createUsers,
        Boolean doContact,
        Boolean allowEmail,
        Boolean allowPhone,
        Boolean allowSMS,
        Boolean outreachEmail,
        Boolean outreachPhone,
        Boolean outreachSMS,
        Boolean outreachDirectMail,
        Id visitPlanId
    ) {
        try {
            Map<String, Integer> headerIndexes = new Map<String, Integer>();
            List<String> csvHeaderData = csvFileLines[0].toUpperCase().split(',');
            list<String> lstHeader = csvFileLines[0].split(',');
            String strHeader = '';
            Boolean headerFailed = (csvHeaderData.size() != MANDATORY_HEADER_COLUMNS.size() &&
            csvHeaderData.size() < MANDATORY_HEADER_COLUMNS.size());
            if (!headerFailed) {
                for (Integer indx = 0; indx < csvHeaderData.size(); indx++) {
                    if (csvHeaderData[indx] != null && String.isNotBlank(csvHeaderData[indx])) {
                        String columnName = csvHeaderData[indx].trim();
                        
                        if (HEADER_COLUMNS.contains(columnName)) {
                            headerIndexes.put(columnName.toUpperCase(), indx);
                            strHeader += lstHeader[indx] + ',';
                        } 
                    }
                }
            }
            strHeader = strHeader.removeEnd(',');
            
            Integer totalRowCount = 0;
            Map<Integer, List<String>> finalCSVLines = new Map<Integer, List<String>>();
            if (csvFileLines.size() != 0 && !headerFailed) {
                for (Integer rowIndex = 2; rowIndex < csvFileLines.size(); rowIndex++) {
                    // List<String> line = csvFileLines.get(rowIndex).trim().removeEnd(',').trim().removeEnd(',').split(',');
                    List<String> line = convertPerLineToList(csvFileLines.get(rowIndex));
                    List<String> FinalLine = line;
                    if (line == null || line.isEmpty() || line.size() == 1) {
                        continue;
                    }
                    totalRowCount++;
                    if (line.size() < HEADER_COLUMNS.size()) {
                        for (
                            Integer index = line.size(); index < (HEADER_COLUMNS.size()); index++
                        ) {
                            FinalLine.add('');
                        }
                    }
                    else  if(line.size() > HEADER_COLUMNS.size()) {
                        
                        for(Integer intIndexnew = line.size()-1; intIndexnew >= HEADER_COLUMNS.size(); intIndexnew--)
                        {
                            FinalLine.remove(intIndexnew);
                        }

                    }
                    finalCSVLines.put(totalRowCount, FinalLine);
                }
            }
           
            
            if(finalCSVLines.values().size() <1 ){
                return 'FileEmpty';
            }
            else if(finalCSVLines.values().size() > 45005)
            {
                return  'MaxiumumSizeLimit';
            }
            else if(finalCSVLines.values().size() == 0 || headerFailed)
            {
                return 'FileFormatError';
            }
            else {
            
            //PI Bulk import history record creation
            Bulk_Import_History__c bulkHistory = new Bulk_Import_History__c(); 
            bulkHistory.File_Name__c = fileName;
            bulkHistory.Import_Status__c = 'In Progress';
            bulkHistory.Import_Type__c = 'PI Bulk Import';
            bulkHistory.Initial_Total_Records__c = String.valueOf(totalRowCount);
            bulkHistory.Study_Site__c = studySiteId;
            bulkHistory.Uploaded_By__c = UserContext.getUserContactId();
            
            insert bulkHistory; 
            //RH-6742 -- Extra parameters related to IQVIA outreach consenting has been added
           Database.executeBatch(
                new UploadParticipantsBatch(
                    finalCSVLines.values(),
                    strHeader,//csvFileLines.get(0),
                    csvFileLines.get(1),
                    studySiteId,
                    selectedStatus,
                    headerFailed,
                    headerIndexes,
                    createUsers,
                    doContact,
                    allowEmail,
                    allowPhone,
                    allowSMS,
                    outreachEmail,
                    outreachPhone,
                    outreachSMS,
                    outreachDirectMail,
                    visitPlanId,
                    fileName,
                    bulkHistory
                ),
                7
            );
            return 'Success';
          }
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
    
    @AuraEnabled
    public static List<LabelValueItemISO> getISOLanguage() {
        List<LabelValueItemISO> languageLVList = Action_UploadParticipantsRemote.getPicklistLabelValueList(
            Participant__c.Preferred_Language__c);
        return languageLVList;

    }
    
    public static List<LabelValueItemISO> getPicklistLabelValueList(SObjectField field) {
        List<LabelValueItemISO> items = new List<LabelValueItemISO>();
        for (PicklistEntry ple : field.getDescribe().getPicklistValues()) {
            items.add(new LabelValueItemISO(ple.getLabel(), ple.getValue()));
        }
        return items;
    }

    public class LabelValueItemISO {
        @AuraEnabled
        public String Language;
        @AuraEnabled
        public String LanguageISOcode;

        public LabelValueItemISO(String Language, String LanguageISOcode) {
            this.Language = Language;
            this.LanguageISOcode = LanguageISOcode;
        }
    }
}