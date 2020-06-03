/**
 * Created by Vitalii Aheienko on 9/27/2019.
 */

@IsTest(IsParallel=true)
private class Test_TrialSearchWhereClauseFactory {

    @IsTest
    static void getInstance_QCare_test() {
        List<Id> taIds = new List<Id>{
                TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>{
                TestDataFactory.getFakeId(Study_Site__c.getSObjectType())
        };
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(taIds, true, true, userQCareSSIds);

        System.assert(!String.isBlank(clause.getWhereClause()));
    }

    @IsTest
    static void getInstance_noQCare_test() {
        List<Id> taIds = new List<Id>{
                TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>();
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(taIds, true, true, userQCareSSIds);

        System.assert(!String.isBlank(clause.getWhereClause()));
    }
	
    @IsTest
    static void getInstance_QCareTM_test() {
        List<Id> ctpIds = new List<Id>{
                TestDataFactory.getFakeId(Trial_Match__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>{
                TestDataFactory.getFakeId(Study_Site__c.getSObjectType())
        };
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(ctpIds, 'Id', true, true, userQCareSSIds);
        System.assert(!String.isBlank(clause.getWhereClause()));
    }
    
    @IsTest
    static void getInstance_noQCareTM_test() {
        List<Id> ctpIds = new List<Id>{
                TestDataFactory.getFakeId(Trial_Match__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>();
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(ctpIds, 'Id', true, true, userQCareSSIds);
        System.assert(!String.isBlank(clause.getWhereClause()));
    }
    
    @IsTest
    static void getInstance_enrolling_test() {
        List<Id> taIds = new List<Id>{
                TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>();
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(taIds, true, false, userQCareSSIds);

        System.assert(!String.isBlank(clause.getWhereClause()));
    }

    @IsTest
    static void getInstance_notEnrolling_test() {
        List<Id> taIds = new List<Id>{
                TestDataFactory.getFakeId(Therapeutic_Area__c.getSObjectType())
        };
        Set<Id> userQCareSSIds = new Set<Id>();
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(taIds, false, true, userQCareSSIds);

        System.assert(!String.isBlank(clause.getWhereClause()));
    }

    @IsTest
    static void getInstance_empty_test() {
        List<Id> taIds = new List<Id>();
        Set<Id> userQCareSSIds = new Set<Id>();
        TrialSearchWhereClauseFactory.WhereClause clause = new TrialSearchWhereClauseFactory().getInstance(taIds, false, false, userQCareSSIds);

        System.assert(String.isBlank(clause.getWhereClause()));
    }

}