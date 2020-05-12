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
}