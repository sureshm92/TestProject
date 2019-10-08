/**
 * Created by Vitalii Aheienko on 9/27/2019.
 */

@IsTest(IsParallel=true)
private class Test_ConditionsOfInterestViewRemote {

    @IsTest
    static void searchForConditionOfInterest_test() {
        List<Therapeutic_Area__c> tas = new List<Therapeutic_Area__c>{
                (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType())
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('searchFilteredTherapeuticAreas')
                .then(tas)
                .build()
        );
        List<Therapeutic_Area__c> result = ConditionsOfInterestViewRemote.searchForConditionOfInterest('', null);

        System.assertEquals(1, result.size());
    }

    @IsTest
    static void searchForConditionOfInterest_Exception_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(TrialSearchHelper.class, StubBuilder.newInstance(TrialSearchHelper.class)
                .when('getFilteredTherapeuticAreas')
                .then(new AuraHandledException(''))
                .build()
        );
        try{
            ConditionsOfInterestViewRemote.searchForConditionOfInterest('', null);
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }
}