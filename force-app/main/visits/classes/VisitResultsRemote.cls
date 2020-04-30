/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class VisitResultsRemote {

    @AuraEnabled
    public static InitDataWrapper getInitData(String visitResultsMode) {
        try {
            InitDataWrapper wrapper = (InitDataWrapper) ClassFactory.newInstance(InitDataWrapper.class);
            wrapper.isVisitResultsAvailable = VisitResultSharingService.isVisitResultAvailable();
            wrapper.contact = ParticipantContext.getCurrentContact();
            wrapper.isResultsExist = !VisitResultSharingService.processResults().isEmpty();
            wrapper.visitResultsGroupNames = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsGroupNames(visitResultsMode);
            wrapper.isDelegate = ParticipantContext.isCurrentDelegate();
            wrapper.toggleState = togglesState(visitResultsMode);
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
    public static Boolean changeOptInOnTrue(Id contactId) {
        try {
            if(!ParticipantContext.isCurrentDelegate()) {
                ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                        .updateRecord(new Contact(Id = contactId, Visit_Results_Opt_In__c = true), true);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<VisitResultsService.VisitResultWrapper> getVisitResultWrappersForDashboard() {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultWrappersForDashboard();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    public static Boolean togglesState(String visitResultsMode) {
        return ParticipantContext.getCurrentContact().Visit_Results_OptIn__c.contains(visitResultsMode);
    }
    
    @AuraEnabled
    public static void switchToggleRemote(String visitResultsMode, Boolean isToggleOn) {
        System.debug('>>>>>>visitResultsMode ' + visitResultsMode + ' >>>>>>>isToggleOn ' + isToggleOn);
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults =currentContact.Visit_Results_OptIn__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            updatedVisitResults = currentVisitResults+ ';' + visitResultsMode;
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode)) updatedVisitResults = updatedVisitResults + str + ';';
            }
        }
//        currentContact.Visit_Results_OptIn__c = updatedVisitResults;
//        update (currentContact);
        ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                .updateRecord(new Contact(Id = currentContact.Id, Visit_Results_OptIn__c = updatedVisitResults), true);
    }



        public class InitDataWrapper {

        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean isVisitResultsAvailable;
        @AuraEnabled
        public Boolean isResultsExist;
        @AuraEnabled
        public List<String> visitResultsGroupNames;
        @AuraEnabled
        public Boolean toggleState;
    }
}