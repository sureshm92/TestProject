public class preScreenerTriggerHandler {
    
    public class validatePreScreenerHandlerBeforeInsert extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList){
            validateMrrData(newList,null);
        }
        public override void afterInsert(List<SObject> newList){
            updatePrescrennerAfterInsert(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap)
        {
            
            validateMrrData(newList,(Map<Id, PreScreener_Survey__c>) oldMap);
        }
        /*  public override void beforeDelete(List<SObject> oldList){
validatePrimaryRecordDeletion(oldList);
} */
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { 
            if(RecursiveTriggerHandler.isFirstTime){
                RecursiveTriggerHandler.isFirstTime = false;
                updatePrescrennerAfterInsert(newList);
            }
        }  
    }
    
    public static void validateMrrData(List<PreScreener_Survey__c> surveyData,Map<Id,PreScreener_Survey__c> oldMapPrescreener)
    {
        Set<Id> studyId = new Set<Id>();
        set<Id> setExistingCTPwithMRR = new Set<Id> ();
        Set<String> surveyName = new Set<String>();
        set<Id> setNameChange = new Set<Id> ();
        
        
        
        for(PreScreener_Survey__c surveyList : surveyData)
        {
            if(oldMapPrescreener != null && !oldMapPrescreener.isEmpty())
            {
                if((surveyList.MRR__c == true && oldMapPrescreener.get(surveyList.Id).MRR__c == false)
                   || (surveyList.Study__c != oldMapPrescreener.get(surveyList.Id).Study__c))
                {
                    studyId.add(surveyList.Study__c); 
                }
                if((surveyList.Survey_Name__c != oldMapPrescreener.get(surveyList.Id).Survey_Name__c)
                   || (surveyList.Study__c != oldMapPrescreener.get(surveyList.Id).Study__c))
                {
                    studyId.add(surveyList.Study__c); 
                    setNameChange.add(surveyList.Study__c);
                    
                }
                
            }
            else{
                studyId.add(surveyList.Study__c);
            }
            
        }
        for(PreScreener_Survey__c objPrescrener : [Select Id,Study__c,MRR__c,Primary__c,Survey_Name__c from PreScreener_Survey__c 
                                                   where Study__c =:studyId ]) 
            
        {
            if(objPrescrener.MRR__c == True)
                setExistingCTPwithMRR.add(objPrescrener.Study__c);
            
            if(objPrescrener.Survey_Name__c != Null)
                surveyName.add(objPrescrener.Survey_Name__c);
        }
        List<PreScreener_Survey__c> prList = new List<PreScreener_Survey__c>();
        Map<Id,PreScreener_Survey__c> mapStudy = new Map<Id,PreScreener_Survey__c>();
        for(PreScreener_Survey__c preSurvey : surveyData)
        {
            If(setExistingCTPwithMRR.contains(preSurvey.Study__c) && preSurvey.MRR__c == true)
            {
                preSurvey.addError(System.Label.MRR_Error);
            }
            if(oldMapPrescreener == null)
            {
                if(surveyName.contains(preSurvey.Survey_Name__c))
                {
                    preSurvey.addError(System.Label.SurveyName_Error);
                }
            }
            else{
                if(surveyName.contains(preSurvey.Survey_Name__c) && setNameChange.contains(preSurvey.Study__c))
                {
                    preSurvey.addError(System.Label.SurveyName_Error);
                }
                
            }
        }
    }
    
  /*  public static void validatePrimaryRecordDeletion(List<PreScreener_Survey__c> surveyData)
    {
        Set<Id> studyId = new Set<Id>();
        Set<Id> setExistingCTPwithPrimary = new Set<Id>();
        for(PreScreener_Survey__c surveyList : surveyData)
        {
            studyId.add(surveyList.Study__c);
        }
        for(PreScreener_Survey__c objPrescrener1 : [Select Id,Study__c,MRR__c,Primary__c from PreScreener_Survey__c where Study__c =:studyId 
                                                    AND  Primary__c = True])
        {
            setExistingCTPwithPrimary.add(objPrescrener1.Study__c); 
        }
        for(PreScreener_Survey__c preSurvey : surveyData)
        {
            If(setExistingCTPwithPrimary.contains(preSurvey.Study__c) && preSurvey.Primary__c == true)
            {
                preSurvey.addError('Primary record cannot be deleted please make other record as primary and delete this record');
            }
        }
    } */
    
    private static void updatePrescrennerAfterInsert(List<PreScreener_Survey__c> surveyData)
    {
        Set<Id> studyId = new Set<Id>();
        Set<Id> setExistingCTPwithPrimary = new Set<Id>();
        List<PreScreener_Survey__c> preList = new List<PreScreener_Survey__c>();
        List<PreScreener_Survey__c> preListNew = new  List<PreScreener_Survey__c>();
        for(PreScreener_Survey__c sy : surveyData)
        {
            if(sy.Prescreener__c == true)
            {
                studyId.add(sy.Study__c);
            }
        }
        for(PreScreener_Survey__c objPrescrener1 : [Select Id,Study__c,MRR__c,Prescreener__c from PreScreener_Survey__c where Study__c =:studyId 
                                                    AND  Prescreener__c = True])
        {
            objPrescrener1.Prescreener__c = false;
            preList.add(objPrescrener1); 
        }
        if(preList.size() > 0)
        {
            update preList;
            
            for(PreScreener_Survey__c preSurvey : surveyData)
            {
                PreScreener_Survey__c sry = new PreScreener_Survey__c();
                sry.id = preSurvey.id;
                sry.Prescreener__c = preSurvey.Prescreener__c;
                preListNew.add(sry);
            }
            if(preListNew.size()>0)
            {
                update preListNew;
            }
        }
    }  
}