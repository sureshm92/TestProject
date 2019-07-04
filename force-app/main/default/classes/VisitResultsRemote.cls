/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class VisitResultsRemote {

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
}