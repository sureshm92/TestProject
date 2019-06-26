/**
 * Created by Igor Malyuta on 12.04.2019.
 */

public inherited sharing class VisitService {

    private static VisitService instance;

    public static VisitService getInstance() {
        if (instance == null) instance = new VisitService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (VisitService) Test.createStub(VisitService.class, mock);
    }

    public List<Visit__c> getVisits(String filter) {
        return getVisits(filter, null);
    }

    public List<Visit__c> getPreviewVisits() {
        return getVisits(null, 3);
    }

    private List<Visit__c> getVisits(String filter, Integer limitNumber) {

        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.ctp == null || pState.ctp.Visit_Plan__c == null || !pState.showVisits) {
            return null;
        }

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Visit_Schedule__c, ' +
                'Icons__c, ' +
                'Status__c ' +
                'FROM Visit__c ';
        visitsQuery += 'WHERE Visit_Plan__c = \'' + pState.ctp.Visit_Plan__c + '\'';
        if (filter != null) {
            visitsQuery += filter;
        }
        visitsQuery += ' ORDER BY Order__c';
        if(limitNumber != null) {
            visitsQuery += ' LIMIT ' + limitNumber;
        }

        List<Visit__c> visits = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
        TranslateHelper.translate(visits);
        return visits;
    }
}
