public with sharing class PreferenceManagementController {
    
    public class Study{
        public string study_name { get; set; }
        public string study_id { get; set; }
        public string sponsor_id { get; set; }
        public boolean phone { get; set; }
        public boolean email { get; set; }
        public boolean sms { get; set; }
        public boolean dmail { get; set; }
        public boolean all { get; set; }
    }
    public class Outreach{
        public string name { get; set; }
        public string iqvia_id { get; set; }
        public boolean phone { get; set; }
        public boolean email { get; set; }
        public boolean sms { get; set; }
        public boolean dmail { get; set; }
        public boolean all { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static String getStudiesConsent(){
        List<Study> studies = new List<Study>();

        Study study = new Study();
        study.study_name = 'Test Study Name';
        study.study_id = 'bldjaf173683a';
        study.sponsor_id = '2';
        study.phone = false;
        study.email =  false;
        study.sms = true;
        study.dmail = false;
        study.all =  false;

        Study study1 = new Study();
        study1.study_name = 'Janson Study';
        study1.study_id = 'a03809438025b';
        study1.sponsor_id = '2';
        study1.phone = true;
        study1.email =  false;
        study1.sms = false;
        study1.dmail = true;
        study1.all =  false;

        Study study2 = new Study();
        study2.study_name = 'GSK Study';
        study2.study_id = 'a0380943sdf8025c';
        study2.sponsor_id = '3';
        study2.phone = true;
        study2.email =  false;
        study2.sms = false;
        study2.dmail = false;
        study2.all =  false;

        studies.add(study);
        studies.add(study1);
        studies.add(study2);

        String studyData = JSON.serialize(studies);

        Integer start = System.Now().millisecond();
        while(System.Now().millisecond()< start+3000){ 
            return studyData; 
        }
        return '';
          
    }

    @AuraEnabled(cacheable=true)
    public static String getOutreachConsent(){
        List<Outreach> outreach = new List<Outreach>();

        Outreach outreachObj = new Outreach();
        outreachObj.name = 'General Communication';
        outreachObj.iqvia_id = 'bldgsdfjaf173683A';
        outreachObj.phone = true;
        outreachObj.email =  true;
        outreachObj.sms = true;
        outreachObj.dmail = true;
        outreachObj.all =  true;
        
        outreach.add(outreachObj);
        String outreachData = JSON.serialize(outreach);
        return outreachData;   
    }

    @AuraEnabled
    public static void saveConsent(Object studyData, Object outReachData){
      System.debug('Data to Update');
      System.debug(studyData);
      System.debug(outReachData);
    }

    @AuraEnabled
    public static Boolean getIsRTL() {
        try {
            return (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

}