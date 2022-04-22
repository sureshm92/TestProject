public class Batch_CreateECOAEventOnPVUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public String statusCompleted = 'Completed';
    public boolean ECOAEventProcessed = false;
    public Set<Id> pvId = new Set<Id>();
    public Batch_CreateECOAEventOnPVUpdate(Set<Id> pvId) {
        this.pvId = pvId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            ' Select Id, Completed_Date__c, Ecoa_Key__c, ECOA_Event_Processed__c Participant_Enrollment__r.Subject_GUID__c, Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_GUID__c from Patient_Visit__c where ECOA_Event_Processed__c = ' +
            ECOAEventProcessed +
            ' AND Status__c = : statusCompleted';
        if (pvId != null) {
            query = query + ' AND Id IN :pvId ';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Patient_Visit__c> pvlist) {
        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
        List<Patient_Visit__c> pvlistTobeUpdated = new List<Patient_Visit__c>();
        for (Patient_Visit__c pv : pvlist) {
            Date dateToday = pv.Completed_Date__c;
            String sMonth = String.valueof(dateToday.month());
            String sDay = String.valueof(dateToday.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            String dateVal = String.valueof(dateToday.year()) + '-' + sMonth + '-' + sDay;

            Map<String, String> ecoaEventMap = new Map<String, String>{
                'studyGuid' => pv.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_GUID__c,
                'orgGuid' => ECOAService.apiParamsMap.get(ECOAService.ORG_GUID).ParamValue__c,
                'subjectGuid' => pv.Participant_Enrollment__r.Subject_GUID__c,
                'date' => dateVal,
                'dateKey' => pv.Ecoa_Key__c
            };
            requestMapList.add(ecoaEventMap);

            pv.ECOA_Event_Processed__c = true;
            pvlistTobeUpdated.add(pv);
        }
        if (requestMapList != null && !requestMapList.isEmpty()) {
            try {
                ECOAService.createEcoaEvent(requestMapList);
            } catch (Exception e) {
                System.debug('Err');
            }
        }
        update pvlistTobeUpdated;
    }

    public void finish(Database.BatchableContext param1) {
        system.debug('Finished job');
    }
}
