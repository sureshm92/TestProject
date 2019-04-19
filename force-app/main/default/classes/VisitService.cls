/**
 * Created by Igor Malyuta on 12.04.2019.
 */

public with sharing class VisitService {

    private static VisitService instance;

    private VisitService() {
    }

    public static VisitService getInstance() {
        if (instance == null) instance = new VisitService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (VisitService) Test.createStub(VisitService.class, mock);
    }

    public List<Visit__c> getVisits(String filter) {
        List<String> fields = new List<String>{
                'Name',
                'Timeplane__c',
                'Icons__c'
        };
        String visitPlan = ParticipantService.getParticipantState().pse.Clinical_Trial_Profile__r.Visit_Plan__c;

        String fullFilter = 'Visit_Plan__c = \'' + visitPlan + '\' ORDER BY Order__c';
        if (filter != null) fullFilter += filter;

        return DatabaseService.getInstance().queryImpl(fields, Visit__c.getSObjectType(), fullFilter);
    }

    public List<Visit__c> getPreviewVisits() {
        return getVisits(' LIMIT 3');
    }
}