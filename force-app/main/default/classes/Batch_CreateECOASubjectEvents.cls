public class Batch_CreateECOASubjectEvents implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Set<Id> peId = new Set<Id>();
    list<String> PEStatusForECOA = new List<String>{
        PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS,
        PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
        PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
        PEStatusState.PE_STATUS_FOLLOW_UP_PERIOD_STARTED
    }; 
    public Batch_CreateECOASubjectEvents(Set<Id> peId) {
        this.peId = peId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = ' SELECT Id,Subject_GUID__c, Clinical_Trial_Profile__r.Study_GUID__c,Participant_Status__c FROM Participant_Enrollment__c where Subject_GUID__c != NULL ';
        if (peId != null) {
            query = query + ' AND Id IN :peId ';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> pelist) {
        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
        for (Participant_Enrollment__c objPE : pelist) {
            if (
                objPE.Clinical_Trial_Profile__r.Study_GUID__c != null &&
                ECOAService.apiParamsMap.get(ECOAService.ORG_GUID).ParamValue__c != null
            ) {
                string dateKey = '';
                if (PEStatusForECOA.contains(objPE.Participant_Status__c)) {
                    String statusInLowerCase = objPE.Participant_Status__c.toLowercase();
                    statusInLowerCase = statusInLowerCase.replaceAll('[^a-zA-Z0-9\\s+]', ' ');
                    List<String> statusStrList = statusInLowerCase.split(' ');
                    dateKey = String.join(statusStrList, '_');
                    String cMonth = String.valueof(date.Today().month());
                    String cDay = String.valueof(date.Today().day());
                    if (cMonth.length() == 1) {
                        cMonth = '0' + cMonth;
                    }
                    if (cDay.length() == 1) {
                        cDay = '0' + cDay;
                    }
                    String dateValue =
                        String.valueof(date.Today().year()) +
                        '-' +
                        cMonth +
                        '-' +
                        cDay;
                    Map<String, String> ecoaEventMap = new Map<String, String>{
                        'studyGuid' => objPE.Clinical_Trial_Profile__r.Study_GUID__c,
                        'orgGuid' => ECOAService.apiParamsMap.get(ECOAService.ORG_GUID)
                            .ParamValue__c,
                        'subjectGuid' => objPE.Subject_GUID__c,
                        'date' => dateValue,
                        'dateKey' => dateKey
                    };
                    requestMapList.add(ecoaEventMap);
                }
            }
        }
        if (requestMapList != null && !requestMapList.isEmpty()) {
            try {
                ECOAService.createEcoaEvent(requestMapList);
            } catch (Exception e) {
                System.debug('Error--->' + e.getmessage());
            }
        }
    }

    public void finish(Database.BatchableContext param1) {
        system.debug('The job is finished');
    }
}
