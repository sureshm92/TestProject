public  without sharing  class BioMarkerRecordController {

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
        
        for(RH_Biomarker__c objBioMarker : [SELECT Assessed_on_datetime__c,Participant_Enrollment__c,Assessed_On__c 
                                            FROM RH_Biomarker__c Where Participant_Enrollment__c =: perId order by Assessed_on_datetime__c desc]) {
            lstAssesedDateTime.add(new LabelValueItem(String.ValueOf(objBioMarker.Assessed_On__c.format('YYYY-MM-dd hh:mm:ss a')) ,objBioMarker.Assessed_on_datetime__c));
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
        Map<String,string> mapColumnKeyToLabel_mdt = new Map<String,String> ();
        for(RH_BioMarker_ColumnLabel__mdt objMdt : [SELECT ID,BioMarkerColumnLabel__c,BioMarkerColumnName__c FROM RH_BioMarker_ColumnLabel__mdt])
        {
            mapColumnKeyToLabel_mdt.put(objMdt.BioMarkerColumnName__c,objMdt.BioMarkerColumnLabel__c);
        }
        
        bioMarkerWrapper objBioMark = new bioMarkerWrapper();
        list<RH_Biomarker__c> lstRHBioMarker = [SELECT ID FROM RH_Biomarker__c
                                                Where  Assessed_on_datetime__c =:strAssesedDateTime and Participant_Enrollment__c =: perId];

        List<bioMarkerResultWrapper> mapBiomarkerKeyValue = new List<bioMarkerResultWrapper>();
       
        for(Biomarker_Result__c objBiomarkerResult : [SELECT Key__c,Value__c FROM Biomarker_Result__c 
                                                      WHERE Biomarker__c IN: lstRHBioMarker]) {
            if(mapColumnKeyToLabel_mdt.containsKey(objBiomarkerResult.Key__c))                                             
                mapBiomarkerKeyValue.add(new bioMarkerResultWrapper(mapColumnKeyToLabel_mdt.get(objBiomarkerResult.Key__c),objBiomarkerResult.Value__c));
        }

        return mapBiomarkerKeyValue;
    }

    public class MediaFileWrapper{
        @AuraEnabled public string name;
        @AuraEnabled public string url;
        @AuraEnabled public string type;
    }
    static Map<String,String> fileExtensionToTypeMap = new Map<String,String>{
        'MP4' => 'Video',
        'MP3' => 'Audio',
        'WAV' => 'Audio'
    }; 
    
    @AuraEnabled
    public static mediaFileWrapper[] getRelatedMediaFiles(string perId){
        list<RH_Biomarker__c> lstRHBioMarker = [SELECT ID FROM RH_Biomarker__c  Where Participant_Enrollment__c =: perId];
        Set<Id> Ids= new Set<Id>();
        for(RH_Biomarker__c ip: lstRHBioMarker){
            Ids.add(ip.id);
        }
        
        String BASE_URL =  System.Url.getOrgDomainUrl().toExternalForm()  +'/sfc/servlet.shepherd/document/download/';
        mediaFileWrapper[] mediaFileList = new mediaFileWrapper[]{};
        Set<id> ContentDocumentIds = new Set<id>();
        for(ContentDocumentLink cdl :  [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: Ids]){
            ContentDocumentIds.add(cdl.contentdocumentId);
        }    
        ContentDocument[] contentDocList = [
            SELECT Id,Title,FileType,FileExtension 
            FROM ContentDocument 
            WHERE Id IN :ContentDocumentIds
              AND FileType IN :fileExtensionToTypeMap.keySet()
        ];
        
        for(ContentDocument cd : contentDocList){
            mediaFileWrapper file = new mediaFileWrapper();
            file.name=cd.Title;
            file.url=BASE_URL+cd.Id;
            file.type = fileExtensionToTypeMap.get(cd.FileType);
            mediaFileList.add(file);
        }
        return mediaFileList;
    }
}