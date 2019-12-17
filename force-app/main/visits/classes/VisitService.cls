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

    public static Patient_Visit__c createPatientVisit(Visit__c visit, Id peId){
        return new Patient_Visit__c(
                Name = visit.Name,
                Visit__c = visit.Id,
                Visit_Schedule__c = visit.Visit_Schedule__c,
                Visit_Number__c = visit.Visit_Number__c,
                Participant_Enrollment__c = peId,
                Portal_Name__c = visit.Patient_Portal_Name__c
        );
    }
    private List<Visit__c> getVisits(String filter, Integer limitNumber) {
        ParticipantService.ParticipantState pState = ParticipantService.getInstance().getState();

        if (pState == null || pState.ctp == null || !pState.showVisits) {
            return null;
        }

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Visit_Schedule__c, ' +
                'Icons__c, ' +
                'Status__c ' +
                'FROM Visit__c ';
        if (filter != null) {
            visitsQuery += filter;
        }
        visitsQuery += ' ORDER BY Order__c';
        if(limitNumber != null) {
            visitsQuery += ' LIMIT ' + limitNumber;
        }

        List<Visit__c> visits = DatabaseService.getInstance().queryImpl(visitsQuery);
        TranslateHelper.translate(visits);
        return visits;
    }
}
