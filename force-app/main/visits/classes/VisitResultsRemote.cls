/**
 * Created by Dmytro Pokutnii
 */
public without sharing class VisitResultsRemote {

    @AuraEnabled
    public static InitDataWrapper getInitData(String visitResultsMode, Map<String,Map<String,List<String>>> visitResultSharings) {
        try {
            InitDataWrapper wrapper = (InitDataWrapper) ClassFactory.newInstance(InitDataWrapper.class);
            wrapper.isVisitResultsAvailable = VisitResultSharingService.isVisitResultAvailable();
            wrapper.contact = ParticipantContext.getCurrentContact();
            wrapper.isResultsExist = !VisitResultSharingService.processResults(visitResultsMode, null).isEmpty();
            wrapper.visitResultsGroupNames = notEmptyVisitResultsGroupName(visitResultsMode ,visitResultSharings);
            wrapper.visitResultsShares = visitResultSharings.get(visitResultsMode);
            wrapper.isDelegate = ParticipantContext.isCurrentDelegate();
            wrapper.toggleState = toggleState(visitResultsMode);
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
    public static VisitResultsService.VisitResultsContainer getVisitResultsContainer(String visitResultGroupName, Map<String,List<String>> visitResultSharings) {

        try {
            return ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class)).getVisitResultsContainer(visitResultGroupName, visitResultSharings);
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

    @AuraEnabled
    public static Boolean toggleState(String visitResultsMode) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null ? '' : currentContact.Visit_Results_OptIn__c;
        return currentVisitResults.contains(visitResultsMode);
    }

    @AuraEnabled
    public static void switchToggleRemote(String visitResultsMode, Boolean isToggleOn) {
        Contact currentContact = ParticipantContext.getCurrentContact();
        String currentVisitResults = currentContact.Visit_Results_OptIn__c == null ? '' : currentContact.Visit_Results_OptIn__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode)) updatedVisitResults += str + ';';
            }
        }
        currentContact.Visit_Results_OptIn__c = updatedVisitResults;
        update currentContact;
    }

    public static List<String> notEmptyVisitResultsGroupName (String visitResultsMode, Map<String,Map<String,List<String>>> visitResultSharingByGroupAndMode) {
        Map<String, List<String>> visitResultGroupNamesWithTypes = visitResultSharingByGroupAndMode.get(visitResultsMode);
        List<String> notEmptyVisitResultsGroupName = new List<String>();
        for (String groupName : visitResultGroupNamesWithTypes.keySet()) {
            notEmptyVisitResultsGroupName.add(groupName);
        }
        return notEmptyVisitResultsGroupName;
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
        public Map<String,List<String>> visitResultsShares;
        @AuraEnabled
        public Boolean toggleState;
    }
}