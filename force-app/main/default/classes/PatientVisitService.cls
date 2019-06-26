public inherited sharing class PatientVisitService {


    public List<Patient_Visit__c> getVisits(String filter) {

        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (pState == null || pState.ctp == null || pState.ctp.Visit_Plan__c == null || !pState.showVisits) {
            return null;
        }

        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Visit_Schedule__c, ' +
                'Visit__r.Icons__c, ' +
                'Status__c, ' +
                'Completed_Date__c, ' +
                'Is_Adhoc__c ' +
                'FROM Patient_Visit__c ';
        visitsQuery += 'WHERE Visit__r.Visit_Plan__c = \'' + pState.ctp.Visit_Plan__c + '\'';
        if (filter != null) {
            visitsQuery += filter;
        }
        visitsQuery += ' ORDER BY Order__c';

        List<Patient_Visit__c> visits = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
        TranslateHelper.translate(visits);
        return visits;
    }
}