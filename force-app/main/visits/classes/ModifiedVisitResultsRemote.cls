public without sharing class ModifiedVisitResultsRemote {
    @AuraEnabled
    public static ModifiedVisitResultsService.ModifiedInitDataWrapper getInitDataModified(
        Integer ctpSharingTiming,
        String patientVisitId
    ) {
        try {
            return ((ModifiedVisitResultsService) ClassFactory.newInstance(
                    ModifiedVisitResultsService.class
                ))
                .getInitDataModified(ctpSharingTiming, patientVisitId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<ModifiedVisitResultsService.ModifiedVisitResultsContainer> getVisitResultsWrapperModified(
        String ctpId,
        String patientVisitId,
        String participantMailingCC,
        Map<String, Map<String, List<String>>> allVisResultCategories,
        String visitResultsMode
    ) {
        try {
            return ((ModifiedVisitResultsService) ClassFactory.newInstance(
                    ModifiedVisitResultsService.class
                ))
                .getVisitResultsWrapperModified(
                    ctpId,
                    patientVisitId,
                    participantMailingCC,
                    allVisResultCategories,
                    visitResultsMode
                );
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void modifiedSwitchToggleRemote(String visitResultsMode, Boolean isToggleOn) {
        Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
        String currentVisitResults = currentPE.Visit_Results_Opt_In__c == null
            ? ''
            : currentPE.Visit_Results_Opt_In__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            if (!currentVisitResults.contains(visitResultsMode)) {
                updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
            }
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode))
                    updatedVisitResults += str + ';';
            }
        }
        currentPE.Visit_Results_Opt_In__c = updatedVisitResults;
        try {
            update currentPE;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}
