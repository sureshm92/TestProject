({
    doInit: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set('v.showSpinner', true);

        if (!communityService.isInitialized()) return;
        var userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);

        if (userMode === 'PI' || userMode === 'HCP') component.set('v.isStaff', true);
        else component.set('v.isStaff', false);

        component.set('v.changedLevels', []);
        component.set('v.changedLevelsAll', []);
        if (userMode !== 'HCP'){
            component.set('v.currentTab', 'by-study');
        }
        else{
            component.set('v.currentTab', 'all-same');
        }


        communityService.executeAction(component, 'getContactData', {
            userMode: component.get('v.userMode'),
            contactEmail: ''
        }, function (returnValue) {
            var contactData = JSON.parse(returnValue);
            component.set('v.delegate', contactData.delegates[0]);
            component.set('v.delegateOptions', contactData.delegateOptions);
            component.set('v.currentUserContactId', contactData.currentUserContactId);
            var allTrialLevel = {
                delegateLevel: '',
                trialName: $A.get('$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies')
            };
            component.set('v.allTrialLevel', allTrialLevel);
            var studyDelegateLavelItems = component.find('study-level');
            if (studyDelegateLavelItems) {
                for (var i = 0; i < studyDelegateLavelItems.length; i++) {
                    studyDelegateLavelItems[i].refresh();
                }
            }

            if (!component.get('v.isInitialized')) communityService.setStickyBarPosition();
            component.set('v.isInitialized', true);

            component.set('v.showSpinner', false);
        })
    },

    doSearchContact: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        if (!communityService.isValidEmail(delegate.delegateContact.Email)) {
            component.set('v.isCorrectEmail', false);
            delegate.delegateContact.Id = null;
            component.set('v.delegate', delegate);
            return;
        } else
            component.set('v.isCorrectEmail', true);

        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set('v.showSpinner', true);

        communityService.executeAction(component, 'getContactData', {
            userMode: component.get('v.userMode'),
            contactEmail: delegate.delegateContact.Email
        }, function (returnValue) {
            debugger;
            var contactData = JSON.parse(returnValue);
            component.set('v.delegate', contactData.delegates[0]);
            if (component.get('v.userMode') !== 'HCP'){
                component.set('v.currentTab', 'by-study');
            }
            else{
                component.set('v.currentTab', 'all-same');
            }
            debugger;
            component.set('v.alreadyExists',contactData.alreadyExists);
            component.set('v.alreadyExistsTitle','Team member ' + contactData.delegates[0].delegateContact.Name
                + ' already exists. Name populated from existing database values.');
            if (contactData.delegates[0].delegateContact.Id === contactData.currentUserContactId) {
                communityService.showToast('error', 'error', $A.get('$Label.c.TST_You_cannot_add_yourself_as_a_delegate'));
            } else if (contactData.delegates[0].delegateContact.Id === undefined) {
                // component.set('v.currentTab','all-same');
                console.log('delegateContact.Id===undefined');
            }

            var allTrialLevel = {
                delegateLevel: '',
                trialName: $A.get('$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies'),
                readOnly: contactData.alreadyExists
            };
            component.set('v.allTrialLevel', allTrialLevel);
            var studyDelegateLavelItems = component.find('study-level');
            if (studyDelegateLavelItems) {
                for (var i = 0; i < studyDelegateLavelItems.length; i++) {
                    studyDelegateLavelItems[i].refresh();
                }
            }
            component.set('v.changedLevels', []);
            component.set('v.changedLevelsAll', []);

            component.set('v.showSpinner', false);
        })
    },

    doSaveChanges: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        var allTrialLevel = component.get('v.allTrialLevel');
        var currentTab = component.get('v.currentTab');
        if (currentTab === 'all-same') {
            for (var i = 0; i < delegate.trialLevels.length; i++) {
                delegate.trialLevels[i].delegateLevel = allTrialLevel.delegateLevel;
            }
        }

        component.find('mainSpinner').show();
        if (component.get('v.userMode') === 'Participant') {
            communityService.executeAction(component, 'savePatientDelegate', {
                delegate: JSON.stringify(delegate.delegateContact)
            }, function () {
                communityService.showToast(
                    'Success', 'success', $A.get('$Label.c.TST_You_have_successfully_created_permissions_for') + ' ' +
                    delegate.delegateContact.FirstName + ' ' + delegate.delegateContact.LastName + '.');
                component.refresh();
            }, function () {
                component.find('emailInput').set('v.value', '');
                component.find('firstNameInput').set('v.value', '');
                component.find('lastNameInput').set('v.value', '');
                component.find('mainSpinner').hide();
            });
        } else
            component.find('saveDelegateLevelChanges').execute(delegate, component, delegate.delegateContact.Id === undefined);
    },

    doCheckEmail: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        component.set('v.isCorrectEmail', communityService.isValidEmail(delegate.delegateContact.Email));
    },
    doCheckContactData: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        component.set('v.isCorrectContactData', delegate.delegateContact.FirstName.trim()!==''
            && delegate.delegateContact.LastName.trim()!=='');
    }

})
