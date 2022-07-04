public without sharing class ProgramOverviewRemote {
    private CTPOverview ctpoverview;
    private static ProgramOverviewRemote instance;

    public class CTPOverview {
        
        @AuraEnabled
        public Clinical_Trial_Profile__c ctp;
        @AuraEnabled
        public Overview overview;
        @AuraEnabled
        public ParticipationCriteria parcrt ;
    }
    public class Overview{

    }
    public class ParticipationCriteria{

    }
    public static ProgramOverviewRemote getInstance() {
        if (instance == null) {
            instance = new ProgramOverviewRemote();
        }
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (ProgramOverviewRemote) Test.createStub(ProgramOverviewRemote.class, stubProvider);
    }
    public CTPOverview() {
        ctpoverview = new CTPOverview();
    }

    @AuraEnabled(cacheable=true)
    public static CTPOverview getCTPData() {


    }
    @AuraEnabled(cacheable=true)
    public static String getInitData() {
        system.debug('test');
        try{
           return JSON.serialize(ParticipantService.getInstance().getState());
        }
        catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}
