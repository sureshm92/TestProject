public class preScreenerTriggerHandler {
    public class validatePreScreenerHandlerBeforeInsert extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            validateMrrData(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            validateMrrData(newList, (Map<Id, PreScreener_Survey__c>) oldMap);
        }
    }

    public static void validateMrrData(
        List<PreScreener_Survey__c> surveyData,
        Map<Id, PreScreener_Survey__c> oldMapPrescreener
    ) {
        Set<Id> studyId = new Set<Id>();
        set<Id> setExistingCTPwithMRR = new Set<Id>();
        Set<String> surveyName = new Set<String>();
        set<Id> setNameChange = new Set<Id>();
        set<Id> setMRRchangeId = new Set<Id>();
        set<Id> setPreScreenerchangeId = new Set<Id>();
        set<Id> setExistingCTPwithPreScreener = new Set<Id>();

        for (PreScreener_Survey__c surveyList : surveyData) {
            if (oldMapPrescreener != null && !oldMapPrescreener.isEmpty()) {
                if (
                    (surveyList.MRR__c == true &&
                    oldMapPrescreener.get(surveyList.Id).MRR__c == false) ||
                    (surveyList.Study__c != oldMapPrescreener.get(surveyList.Id).Study__c)
                ) {
                    setMRRchangeId.add(surveyList.Study__c);
                    studyId.add(surveyList.Study__c);
                }
                if (
                    (surveyList.Prescreener__c == true &&
                    oldMapPrescreener.get(surveyList.Id).Prescreener__c == false) ||
                    (surveyList.Study__c != oldMapPrescreener.get(surveyList.Id).Study__c)
                ) {
                    setPreScreenerchangeId.add(surveyList.Study__c);
                    studyId.add(surveyList.Study__c);
                }
                if (
                    (surveyList.Survey_Name__c !=
                    oldMapPrescreener.get(surveyList.Id).Survey_Name__c) ||
                    (surveyList.Study__c != oldMapPrescreener.get(surveyList.Id).Study__c)
                ) {
                    studyId.add(surveyList.Study__c);
                    setNameChange.add(surveyList.Study__c);
                }
            } else {
                studyId.add(surveyList.Study__c);
            }
        }
        for (PreScreener_Survey__c objPrescrener : [
            SELECT Id, Study__c, MRR__c, Primary__c, Survey_Name__c, Prescreener__c
            FROM PreScreener_Survey__c
            WHERE Study__c = :studyId
        ]) {
            if (objPrescrener.MRR__c == true)
                setExistingCTPwithMRR.add(objPrescrener.Study__c);
            if (objPrescrener.Prescreener__c == true)
                setExistingCTPwithPreScreener.add(objPrescrener.Study__c);

            if (objPrescrener.Survey_Name__c != null)
                surveyName.add(objPrescrener.Survey_Name__c);
        }
        List<PreScreener_Survey__c> prList = new List<PreScreener_Survey__c>();
        Map<Id, PreScreener_Survey__c> mapStudy = new Map<Id, PreScreener_Survey__c>();
        for (PreScreener_Survey__c preSurvey : surveyData) {
            if (oldMapPrescreener == null) {
                if (
                    setExistingCTPwithMRR.contains(preSurvey.Study__c) && preSurvey.MRR__c == true
                ) {
                    preSurvey.addError(System.Label.MRR_Error);
                }
                if (
                    setExistingCTPwithPreScreener.contains(preSurvey.Study__c) &&
                    preSurvey.Prescreener__c == true
                ) {
                    preSurvey.addError(System.Label.PreScreener_Error);
                }
                if (surveyName.contains(preSurvey.Survey_Name__c)) {
                    preSurvey.addError(System.Label.SurveyName_Error);
                }
            } else {
                if (
                    setExistingCTPwithMRR.contains(preSurvey.Study__c) &&
                    preSurvey.MRR__c == true &&
                    setMRRchangeId.contains(preSurvey.Study__c)
                ) {
                    preSurvey.addError(System.Label.MRR_Error);
                }
                if (
                    setExistingCTPwithPreScreener.contains(preSurvey.Study__c) &&
                    preSurvey.Prescreener__c == true &&
                    setPreScreenerchangeId.contains(preSurvey.Study__c)
                ) {
                    preSurvey.addError(System.Label.PreScreener_Error);
                }
                if (
                    surveyName.contains(preSurvey.Survey_Name__c) &&
                    setNameChange.contains(preSurvey.Study__c)
                ) {
                    preSurvey.addError(System.Label.SurveyName_Error);
                }
            }
        }
    }
}
