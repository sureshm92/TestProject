/**
 * Created by Kryvolap on 16.09.2018.
 */
({
    doInit: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set("v.showSpinner", true);

        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        component.set('v.changedLevels',[]);
        component.set('v.changedLevelsAll',[]);
        component.set("v.currentTab",'by-study');
        // component.set('v.currentTab','all-same');
        communityService.executeAction(component, 'getContactData', {
            userMode: component.get('v.userMode'),
            contactEmail: ''
        }, function (returnValue) {
            var contactData = JSON.parse(returnValue);
            component.set("v.delegate", contactData.delegates[0]);
            component.set("v.delegateOptions", contactData.delegateOptions);
            component.set("v.currentUserContactId",contactData.currentUserContactId);
            var allTrialLevel = {
                delegateLevel : '',
                trialName : $A.get("$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies")
            } ;
            component.set('v.allTrialLevel',allTrialLevel);
            var studyDelegateLavelItems = component.find('study-level');
            if(studyDelegateLavelItems){
                for(var i=0; i< studyDelegateLavelItems.length; i++){
                    studyDelegateLavelItems[i].refresh();
                }
            }

            if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
            component.set('v.isInitialized', true);
            component.set("v.showSpinner", false);

        })
    },

    doSearchContact: function (component, event, helper) {
        var isCorrectEmail = component.get('v.isCorrectEmail');
        if(!isCorrectEmail){
            var delegate = component.get('v.delegate');
            delegate.delegateContact.Id=null;
            component.set('v.delegate',delegate);
            return;
        }

        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set("v.showSpinner", true);

        communityService.executeAction(component, 'getContactData', {
            userMode: component.get('v.userMode'),
            contactEmail: component.get('v.delegate').delegateContact.Email
        }, function (returnValue) {
            debugger;
            var contactData = JSON.parse(returnValue);
            component.set("v.delegate", contactData.delegates[0]);
            component.set("v.currentTab",'by-study');

            if(contactData.delegates[0].delegateContact.Id === contactData.currentUserContactId){
                communityService.showToast("error","error",$A.get("$Label.c.TST_You_cannot_add_yourself_as_a_delegate"));
            }
            else if(contactData.delegates[0].delegateContact.Id===undefined){
                // component.set("v.currentTab",'all-same');
            }
            else{
                var email = contactData.delegates[0].delegateContact.Email;
                // component.set("v.currentTab",'by-study');
                // communityService.showToast("warning","warning",email + " found! Current study permissions for "+ email+ " are being displayed.");
            }
            var allTrialLevel = {
                delegateLevel : '',
                trialName : $A.get("$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies")
            } ;
            component.set('v.allTrialLevel',allTrialLevel);
            var studyDelegateLavelItems = component.find('study-level');
            if(studyDelegateLavelItems){
                for(var i=0; i< studyDelegateLavelItems.length; i++){
                    studyDelegateLavelItems[i].refresh();
                }
            }
            component.set('v.changedLevels',[]);
            component.set('v.changedLevelsAll',[]);
            component.set("v.showSpinner", false);

        })
    },

    doSaveChanges: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        var allTrialLevel = component.get('v.allTrialLevel');
        var currentTab = component.get('v.currentTab');
        if(currentTab === 'all-same'){
            for(var i= 0; i< delegate.trialLevels.length; i++){
                delegate.trialLevels[i].delegateLevel = allTrialLevel.delegateLevel;
            }
        }
        component.find('saveDelegateLevelChanges').execute(delegate, component,delegate.delegateContact.Id === undefined);
    },

    doCheckEmail: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        component.set('v.isCorrectEmail',communityService.isValidEmail(delegate.delegateContact.Email));
    },
})