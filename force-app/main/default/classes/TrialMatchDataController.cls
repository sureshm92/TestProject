public class TrialMatchDataController {
    public List<TrialMatchWrapper> tm_list {get; set;}
    Id participantid;
    TrialMatchPageRemote.TrialMatchContainer tmcontainer; 
    public TrialMatchDataController(){
       participantid = apexpages.currentpage().getparameters().get('id');
       tm_list =  new List<TrialMatchWrapper>();
       tmcontainer = TrialMatchPageRemote.getMatchCTPs(participantid); 
        for(TrialMatchPageRemote.TrialMatchCTP tmCTP : tmcontainer.trialmatchctps){
            TrialMatchWrapper tmWrapper = new TrialMatchWrapper();
            if(tmCTP.isEnrollingCTP)
            	tmWrapper.EnrollingCTP = System.Label.TrialSearch_Enrolling;
            else
                tmWrapper.EnrollingCTP = System.Label.TrialSearch_Not_Yet_Enrolling;
            tmWrapper.ctpid = tmCTP.ctpid;
            tmWrapper.isEnrollingCTP = tmCTP.isEnrollingCTP;
            tmWrapper.TherapeuticArea = tmCTP.TherapeuticArea;
            tmWrapper.StudyCodeName = tmCTP.StudyCodeName;
            tmWrapper.OfficialTitle = tmCTP.OfficialTitle;
            tmWrapper.matchDate = tmCTP.matchDate;
            tm_list.add(tmWrapper);
        }
    }
    
	public class TrialMatchWrapper {
        public String EnrollingCTP{get; set;}
        public Boolean isEnrollingCTP{get; set;}
        public String ctpid{get; set;}
        public String TherapeuticArea{get; set;}
        public String StudyCodeName{get; set;}
        public String OfficialTitle{get; set;}
        public String matchDate{get; set;}
    }
}