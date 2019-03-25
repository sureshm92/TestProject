/**
 * Created by AlexKetch on 3/21/2019.
 */

public with sharing class ConditionOfInterestRemote {


    public class CAWrapper {
        @auraEnabled
        public Integer order;
        @auraEnabled
        public Boolean isSelected;
        @auraEnabled
        public Therapeutic_Area__c therArea;
    }

}