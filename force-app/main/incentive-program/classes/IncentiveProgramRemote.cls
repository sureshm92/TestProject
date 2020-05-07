/**
 * Created by Andrii Kryvolap.
 */

public without sharing class IncentiveProgramRemote {
    @AuraEnabled
    public static PointsResultWrapper getCurrentPoints(Datetime timeStamp ){
        try {
            PointsResultWrapper result = new PointsResultWrapper();
            result.totalPoints = 50;
            result.lastPoints = 33;
            return  result;
        } catch (Exception e) {
            return (PointsResultWrapper) AuraHelper.throwException(e);
        }
    }

    public class PointsResultWrapper{
        @AuraEnabled public Integer totalPoints;
        @AuraEnabled public Integer lastPoints;
    }

}