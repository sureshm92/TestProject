@IsTest
public class PicklistCMPwithRTAndMSPTestCls {
    static String objectApiName = 'Account';
    static String controllingField = 'Industry';
    static String dependentField = 'Type';

    testMethod static void getfieldDepedencyMapTest() {
        //Object Postive test
        DependntPicklistCMPwithRecTypeAndMspCtrl.getFieldDependencyMap(
            objectApiName,
            controllingField,
            dependentField
        );

        //Object Negative Test
        DependntPicklistCMPwithRecTypeAndMspCtrl.getFieldDependencyMap(
            null,
            'controllingField',
            dependentField
        );

        //Field Negative
        DependntPicklistCMPwithRecTypeAndMspCtrl.getFieldDependencyMap(
            objectApiName,
            'NonExistentField',
            dependentField
        );
    }

    testMethod static void wrapperClassesTest() {
        //PicklistEntryWrapper
        DependntPicklistCMPwithRecTypeAndMspCtrl.PicklistEntryWrapper obj1 = new DependntPicklistCMPwithRecTypeAndMspCtrl.PicklistEntryWrapper();
        obj1.active = 'Yes';
        obj1.defaultValue = '';
        obj1.value = '';

        //recordTypeWrapper
        DependntPicklistCMPwithRecTypeAndMspCtrl.recordTypeWrapper obj3 = new DependntPicklistCMPwithRecTypeAndMspCtrl.recordTypeWrapper(
            null,
            null,
            null,
            true
        );
        //obj3.incorrectApiName=true;
        //obj3.rtId='';
        //obj3.rtIsMaster=false;
        //obj3.rtName='';

        //picklistValues
        DependntPicklistCMPwithRecTypeAndMspCtrl.piclistValues obj4 = new DependntPicklistCMPwithRecTypeAndMspCtrl.piclistValues();
        obj4.label = '';
        obj4.value = '';
        DependntPicklistCMPwithRecTypeAndMspCtrl.piclistValues[] picklistvalueList = new List<DependntPicklistCMPwithRecTypeAndMspCtrl.piclistValues>{};
        picklistvalueList.add(obj4);

        //picklistWrapper
        DependntPicklistCMPwithRecTypeAndMspCtrl.picklistWrapper obj2 = new DependntPicklistCMPwithRecTypeAndMspCtrl.picklistWrapper();
        obj2.values = picklistvalueList;
    }

    testMethod static void getRecordtypesTest() {
        //Postive Test
        DependntPicklistCMPwithRecTypeAndMspCtrl.getRecordTypes(objectApiName);

        //Negative Test: No object
        DependntPicklistCMPwithRecTypeAndMspCtrl.getRecordTypes('');

        //Negative Test: No record type
        DependntPicklistCMPwithRecTypeAndMspCtrl.getRecordTypes('AccountTeamMember');
    }

    testMethod static void isfieldMSPtypeTest() {
        DependntPicklistCMPwithRecTypeAndMspCtrl.isfieldMSPtype('Account', 'Industry');
    }

    testMethod static void getPicklistValuesTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DPicklistCMPwithRTAndMSPCalloutMock());
        DependntPicklistCMPwithRecTypeAndMspCtrl.getPicklistValues('', '', '');
        Test.stopTest();
    }
}
