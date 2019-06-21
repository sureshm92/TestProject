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

    public List<Patient_Visit__c> getVisits(String filter) {
        return getVisits(filter, null);
    }

    public List<Patient_Visit__c> getPreviewVisits() {
        return getVisits(null, 3);
    }

    private List<Patient_Visit__c> getVisits(String filter, Integer limitNumber) {

        if(!ParticipantService.getInstance().getState().showVisits) return null;

        List<String> fields = new List<String>{
                'Name',
                'Timeplane__c',
                'Visit__r.Icons__c',
                'Status__c',
                'Completed_Date__c',
                'Is_Adhoc__c'
        };
        String visitPlan = ParticipantService.getInstance().getState().pse.Clinical_Trial_Profile__r.Visit_Plan__c;

        String fullFilter = 'Visit__r.Visit_Plan__c = \'' + visitPlan + '\'';
        if (filter != null) fullFilter += filter;
        String orderBy = 'Order__c';

        List<Patient_Visit__c> visits = DatabaseService.getInstance().queryImpl(fields, Patient_Visit__c.getSObjectType(), fullFilter, orderBy, limitNumber);
	    TranslateHelper.translate(visits);
        return visits;
    }
}
