/**
 * Created by Igor Malyuta on 12.04.2019.
 */

public with sharing class VisitService {

    private static VisitService instance;

    private VisitService(){}

    public static VisitService getInstance() {
        if(instance == null) instance = new VisitService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (VisitService) Test.createStub(VisitService.class, mock);
    }

    public List<Visit__c> getAllVisits() {
        Participant_Study_Enrollment__c pse = ParticipantService.getParticipantState().pse;
        List<Visit__c> visits = [
                SELECT Name,
                       Timeplane__c,
                       Icons__c
                FROM Visit__c
                WHERE Visit_Plan__c =: pse.Clinical_Trial_Profile__r.Visit_Plan__c
                ORDER BY Order__c
        ];

        return visits;
    }

    public List<Visit__c> getPreviewVisits() {
        List<Visit__c> prevVisits = new List<Visit__c>();

        List<Visit__c> allVisits = getAllVisits();
        for(Integer i = 0; i < 3; i++) prevVisits.add(allVisits.get(i));

        return prevVisits;
    }
}