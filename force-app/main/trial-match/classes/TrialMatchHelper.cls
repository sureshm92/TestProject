/**
 * Created by Sravani Dasari
 */
public without sharing class TrialMatchHelper {

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

    public TrialMatchPageRemote.TrialMatchContainer getInitTrialMatchContainer(Id participantid) {
        TrialMatchPageRemote.TrialMatchContainer trialMatchContainer = this.getTrialMatchContainer(participantid, null, true, true);
        return trialMatchContainer;
    }

    public TrialMatchPageRemote.TrialMatchContainer getTrialMatchContainer(Id participantid, List<Trial_Match__c> trms, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        TrialMatchPageRemote.TrialMatchContainer trialMatchContainer = new TrialMatchPageRemote.TrialMatchContainer();
        List<Trial_Match__c> trialMatchs = trms != null ? trms : this.getTrialMatches(participantid);
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
        
        if (!isEnrolling && !isNotYetEnrolling || (trialMatchs.isEmpty() || ctpId.isEmpty())) {
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
            tmctp.matchDate = day+'-'+ getMonth(matdate)+'-'+matdate.year();
            trialmatchCTPS.add(tmctp);
        }
        return trialmatchCTPS;
    }

    @TestVisible
    private List<Clinical_Trial_Profile__c> getCtps(Set<Id> ctpIds, String objfield, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        TrialSearchWhereClauseFactory factory = (TrialSearchWhereClauseFactory) ClassFactory.newInstance(TrialSearchWhereClauseFactory.class);
        String whereClause = factory.getInstance(new List<Id>(ctpIds), objfield, isEnrolling, isNotYetEnrolling, null).getWhereClause();
        String orderBy = ' ORDER BY Override_Recruitment_Status__c';
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
        queryCTP += orderBy;
        List<Clinical_Trial_Profile__c> ctps = (List<Clinical_Trial_Profile__c>) proxy.query(queryCTP, true);
        return ctps;
    }

	@TestVisible
    private List<Trial_Match__c> getTrialMatches(Id participantid) {
        String filter = 'Is_Eligible__c = TRUE AND' +
                DatabaseService.fieldEqual('Participant_Enrollment__r.Participant__c', participantid);

        return (List<Trial_Match__c>) DatabaseService.query(
                new List<String>{
                        'Id', 'Clinical_Trial_Profile__c', 'Matched_Date__c', 'Matching_Score__c',
                        'Passed__c', 'Participant_Enrollment__c', 'Therapeutic_Area__c'
                }, Trial_Match__c.getSObjectType(), filter
        );
    }

    @TestVisible
    private String getMonth(Date matchDate){
        Datetime dt = Datetime.newInstanceGmt(matchDate.year(), matchDate.month(), matchDate.day());
        return dt.format('MMM');
    }
}