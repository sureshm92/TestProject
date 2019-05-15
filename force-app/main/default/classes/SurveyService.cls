/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class SurveyService {

    public class SurveyException extends Exception {}

    private static SurveyService instance;

    public static SurveyService getInstance() {
        if(instance == null) instance = new SurveyService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (SurveyService) Test.createStub(SurveyService.class, mock);
    }

    public String getSurveyLink(Id surveyId) {
        List<SurveyInvitation> surveyInvitations = [
                SELECT Id, InvitationLink
                FROM SurveyInvitation
                WHERE SurveyId = :surveyId
        ];
        if(surveyInvitations.isEmpty()) throw new SurveyService.SurveyException('SurveyInvitation not available');

        String link;
        for(SurveyInvitation inv : surveyInvitations) {
            if(inv.InvitationLink.contains('.force.com')) {
                link = inv.InvitationLink;
                break;
            }
        }
        if(link == null) throw new SurveyService.SurveyException('Invitation link not found');

        return link;
    }
}