/**
 * Created by Igor Malyuta on 12.04.2019.
 */

public with sharing class VisitService {

    private static VisitService instance;

    public static VisitService getInstance() {
        if (instance == null) instance = new VisitService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (VisitService) Test.createStub(VisitService.class, mock);
    }

    public List<Visit__c> getVisits(String filter) {
        if(!ParticipantService.getInstance().getState().showVisits) return null;

        List<String> fields = new List<String>{
                'Name',
                'Timeplane__c',
                'Icons__c'
        };
        String visitPlan = ParticipantService.getInstance().getState().pse.Clinical_Trial_Profile__r.Visit_Plan__c;

        String fullFilter = 'Visit_Plan__c = \'' + visitPlan + '\' ORDER BY Order__c';
        if (filter != null) fullFilter += filter;
        List<Visit__c> visits = DatabaseService.getInstance().queryImpl(fields, Visit__c.getSObjectType(), fullFilter);
        TranslateHelper.translate(visits);
        return (visits);
    }

    public List<Visit__c> getPreviewVisits() {
        return getVisits(' LIMIT 3');
    }
}