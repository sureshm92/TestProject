/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class VisitResultsRemote {

    @AuraEnabled
    public static InitDataWrapper getInitData(String visitResultsMode) {

        try {
            InitDataWrapper wrapper = new InitDataWrapper();
            VisitResultsService service = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class));
            ParticipantService.ParticipantState state = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();            wrapper.visitResultsGroupNames = service.getVisitResultsGroupNames(visitResultsMode);
            List<Patient_Visit__c> visits = service.getPatientVisits();
            if (state.participant != null && state.participant.Contact__c != null) {
                wrapper.contact = state.participant.Contact__r;
            }
            if(visits != null & !visits.isEmpty()) {
                List<Visit_Result__c> visitResults = service.getVisitResults(visits[0].Id, null);
                if (visitResults != null) {
                    wrapper.isDataMissed = visitResults.isEmpty();
                }
            } else {
                wrapper.isDataMissed = true;
            }
            return wrapper;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<String> getVisitResultsGroupNames(String visitResultsMode) {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsGroupNames(visitResultsMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static VisitResultsService.VisitResultsContainer getVisitResultsContainer(String visitResultGroupName) {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsContainer(visitResultGroupName);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static String getLinkForModalWindow() {

        try {
            String message = '<p class="white-space visit-assessment-inf">' + Label.Visit_Results_Tab_If_Is_Not_Opt_In + '</p>';
            String goToModal = '<span class="to-modal-link">' + Label.Visit_Results_Tab_Linked_Text + '</span>';
            message = String.format(message, new List<String>{
                    goToModal
            });
            return message;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void changeOptInOnTrue(Id contactId) {

        try {
            ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .updateRecord(new Contact(Id = contactId, Visit_Results_Opt_In__c = true), true);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    public class InitDataWrapper {

        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean isDataMissed;
        @AuraEnabled
        public List<String> visitResultsGroupNames;
    }
}