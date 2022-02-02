public class BioMarkerRecordController {

    public class bioMarkerWrapper{
        @AuraEnabled
        public List<bioMarkerResultWrapper> mapBiomarkerKeyValue;
        @AuraEnabled
        public List<LabelValueItem> dateTimeLabelValue;        
    }

    public class bioMarkerResultWrapper {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String value;
        
        public bioMarkerResultWrapper(String key, String value){
            this.key = key;
            this.value =value;
        }
    }

    @AuraEnabled
    public static bioMarkerWrapper getAssessedDateForPE(Id perId){ 
        List<LabelValueItem> lstAssesedDateTime = new List<LabelValueItem>();

        for(RH_Biomarker__c objBioMarker : [SELECT Assessed_on_datetime__c,Participant_Enrollment__c 
                                            FROM RH_Biomarker__c Where Participant_Enrollment__c =: perId order by Assessed_on_datetime__c desc]) {
            lstAssesedDateTime.add(new LabelValueItem(objBioMarker.Assessed_on_datetime__c,objBioMarker.Assessed_on_datetime__c));
        }
        bioMarkerWrapper objBioMark = new bioMarkerWrapper();

        if(!lstAssesedDateTime.isEmpty()){
            objBioMark.mapBiomarkerKeyValue=  getFilterbiomarker(lstAssesedDateTime[0].value, perId);
            objBioMark.dateTimeLabelValue = lstAssesedDateTime;
        }
        return objBioMark;
    }

    @AuraEnabled
    public static List<bioMarkerResultWrapper> getFilterbiomarker(String strAssesedDateTime, Id perId)
    {
        bioMarkerWrapper objBioMark = new bioMarkerWrapper();
        list<RH_Biomarker__c> lstRHBioMarker = [SELECT ID FROM RH_Biomarker__c
                                                Where  Assessed_on_datetime__c =:strAssesedDateTime and Participant_Enrollment__c =: perId];

        List<bioMarkerResultWrapper> mapBiomarkerKeyValue = new List<bioMarkerResultWrapper>();
       
        for(Biomarker_Result__c objBiomarkerResult : [SELECT Key__c,Value__c FROM Biomarker_Result__c 
                                                      WHERE Biomarker__c IN: lstRHBioMarker]) {
            mapBiomarkerKeyValue.add(new bioMarkerResultWrapper(objBiomarkerResult.Key__c,objBiomarkerResult.Value__c));
        }
        return mapBiomarkerKeyValue;
    }
}