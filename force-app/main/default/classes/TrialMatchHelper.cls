/**
 * Created by Sravani Dasari
 */
public with sharing class TrialMatchHelper {

    static {
        ClassFactory.setCacheable(true);
    }

    private DatabaseProxy proxy {
        get {
            if (proxy == null) {
                proxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            }
            return proxy;
        }
        private set;
    }

    public TrialMatchPageRemote.TrialMatchContainer getInitTrialMatchContainer() {
        TrialMatchPageRemote.TrialMatchContainer trialMatchContainer = this.getTrialMatchContainer(null, true, true);
        return trialMatchContainer;
    }

    public TrialMatchPageRemote.TrialMatchContainer getTrialMatchContainer(List<Trial_Match__c> trms, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        TrialMatchPageRemote.TrialMatchContainer trialMatchContainer = new TrialMatchPageRemote.TrialMatchContainer();
        List<Trial_Match__c> trialMatchs = trms != null ? trms : this.getTrialMatches();
        Set<Id> ctpId = new Set<Id>();
        Map<Id, Trial_Match__c> trialmatchesforCTP = new Map<Id, Trial_Match__c>();
        if (!trialMatchs.isEmpty()) {
            for (Trial_Match__c trm : trialMatchs) {
                if (trm.Clinical_Trial_Profile__c != null) {
                    ctpId.add(trm.Clinical_Trial_Profile__c);
                    trialmatchesforCTP.put(trm.Clinical_Trial_Profile__c,trm);
                }
            }
        } 
        
        if (!isEnrolling && !isNotYetEnrolling || (!trialMatchs.isEmpty() && ctpId.isEmpty())) {
            return trialMatchContainer;
        }
        List<Clinical_Trial_Profile__c> ctps = this.getCtps(ctpId,'id',isEnrolling, isNotYetEnrolling);
        
        List<TrialMatchPageRemote.TrialMatchCTP> trialmatchctpS = this.getTrialmatchctps(ctps,trialmatchesforCTP);
        trialMatchContainer.trialmatchctps = trialmatchctpS;
        return trialMatchContainer;
    }


    public Boolean isCtpEnrolling(Clinical_Trial_Profile__c ctp) {
        return ctp.Override_Recruitment_Status__c == TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING ||
                (String.isBlank(ctp.Override_Recruitment_Status__c) &&
                        (ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.ENROLLING ||
                                ctp.Recruitment_Status__c == TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT)
                );
    }


    private List<TrialMatchPageRemote.TrialMatchCTP> getTrialmatchctps(List<Clinical_Trial_Profile__c> CTPs, Map<Id, Trial_Match__c> trialmatches) {
        List<TrialMatchPageRemote.TrialMatchCTP> trialmatchCTPS = new List<TrialMatchPageRemote.TrialMatchCTP>();
        for (Clinical_Trial_Profile__c ctp : CTPs) {
            TrialMatchPageRemote.TrialMatchCTP tmctp = new TrialMatchPageRemote.TrialMatchCTP();
            Date matdate = trialmatches.get(ctp.id).Matched_Date__c;
            tmctp.ctp = ctp;
            tmctp.trm = trialmatches.get(ctp.id);
            tmctp.isEnrollingCTP = isCtpEnrolling(ctp);
            tmctp.ctpid = ctp.id;
            tmctp.TherapeuticArea = trialmatches.get(ctp.id).Therapeutic_Area__c;
            tmctp.StudyCodeName = ctp.Study_Code_Name__c;
            tmctp.OfficialTitle = ctp.Official_Title__c;
            String day = String.valueOf(matdate.day()).length()==1?'0'+String.valueOf(matdate.day()):String.valueOf(matdate.day());
            tmctp.matchDate = day+'-'+getmonth(matdate.month())+'-'+matdate.year();
            trialmatchCTPS.add(tmctp);
        }
        return trialmatchCTPS;
    }

    @TestVisible
    private List<Clinical_Trial_Profile__c> getCtps(Set<Id> ctpIds, String objfield, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        TrialSearchWhereClauseFactory factory = (TrialSearchWhereClauseFactory) ClassFactory.newInstance(TrialSearchWhereClauseFactory.class);
        String whereClause = factory.getInstance(new List<Id>(ctpIds), objfield, isEnrolling, isNotYetEnrolling, null).getWhereClause();
        if(String.isEmpty(whereClause))
            whereClause = 'where CommunityTemplate__c=\'GSK\' AND Trial_Match_Is_Available__c = true';
        else
            whereClause+=' AND CommunityTemplate__c=\'GSK\' AND Trial_Match_Is_Available__c = true';
        String queryCTP = 'SELECT id, ' +
            	'Trial_Match_Is_Available__c, '+
                'Therapeutic_Area__c, ' +
                'Therapeutic_Area__r.Name, ' +
                'Study_Code_Name__c, ' +
                'Official_Title__c, ' +
                'Enrollment_Start_Date__c, ' +
                'Override_Recruitment_Status__c, ' +
                'Recruitment_Status__c, ' +
                'NCT_Number__c, ' +
                'Link_to_ePR_Campaign__c ' +
                'FROM Clinical_Trial_Profile__c ';

        queryCTP += whereClause;
        System.debug('>>getCtps query: ' + queryCTP);
        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(queryCTP, true);
        return ctps;
    }

	@TestVisible
    private List<Trial_Match__c> getTrialMatches() {
        CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
        String participantId = cService.getParticipantId();
        system.debug('participantId**'+participantId);
        String queryTAP = 'SELECT id, ' +
                'Matched_Date__c, ' +
                'Therapeutic_Area__c , ' +
                'Clinical_Trial_Profile__c, ' +
                'Passed__c, ' +
            	'Participant_Enrollment__c, ' +
                'Matching_Score__c ' +
                'FROM Trial_Match__c ' +
                'WHERE Is_Eligible__c=true ' +
                'And Participant_Enrollment__r.Participant__c = \'' + participantId + '\'';
        List<Trial_Match__c> trialMatches = (List<Trial_Match__c>) proxy.query(queryTAP, true);
        system.debug('trialMatches***'+trialMatches);
        return trialMatches;
    }
    String getmonth(Integer num){
        if(num==1)
            return 'Jan';
        else if(num==2)
            return 'Feb';
        else if(num==3)
            return 'Mar';
        else if(num==4)
            return 'Apr';
        else if(num==5)
            return 'May';
        else if(num==6)
            return 'Jun';
        else if(num==7)
            return 'Jul';
        else if(num==8)
            return 'Aug';
        else if(num==10)
            return 'Sep';
        else if(num==11)
            return 'Oct';
        else if(num==2)
            return 'Nov';
        else
            return 'Dec';
    }
    
}