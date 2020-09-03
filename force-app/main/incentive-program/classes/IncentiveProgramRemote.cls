/**
 * Created by Andrii Kryvolap.
 */

public without sharing class IncentiveProgramRemote {

    @AuraEnabled
    public static IncentiveProgramService.PointsResultWrapper getCurrentPoints(Datetime timeStamp ){
        try {
            return  IncentiveProgramService.getCurrentContactPoints(timeStamp);
        } catch (Exception e) {
            return (IncentiveProgramService.PointsResultWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static IncentiveProgramService.IncentiveHistoryWrapper getIncentiveHistory(){
        try {
            return  IncentiveProgramService.getCurrentContactIncentiveHistory();
        } catch (Exception e) {
            return (IncentiveProgramService.IncentiveHistoryWrapper) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static IncentiveProgramService.IncentivePlanResultWrapper getIncentivePlanResultWrapperForStudySite(Id ssId){
        try {
            return  IncentiveProgramService.getIncentivePlanResultWrapperForStudySite(ssId);
        } catch (Exception e) {
            return (IncentiveProgramService.IncentivePlanResultWrapper) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static IncentiveProgramService.IncentivePlanResultWrapper getInitialIncentivePlanResultWrapper(){
        try {
            return  IncentiveProgramService.getInitialIncentivePlanResultWrapper();
        } catch (Exception e) {
            return (IncentiveProgramService.IncentivePlanResultWrapper) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static Boolean getIncentivesPageEnabled(){
        return UserContext.getCurrentCommunityTemplate().templateName != CommunityTemplateService.TEMPLATE_JANSSEN;
    }
}