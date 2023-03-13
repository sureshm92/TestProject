({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            component.find('mainSpinner').show();
            let userMode = communityService.getUserMode();
            if (userMode === 'Participant' && communityService.getCurrentCommunityMode().isDelegate)
                communityService.navigateToHome();

            component.set('v.userMode', userMode);
            var fields = ['FirstName', 'LastName'];
            var sObj = { sobjectType: 'Contact' };
            communityService.executeAction(
                component,
                'getMaxLength',
                {
                    so: JSON.stringify(sObj),
                    fieldNames: fields
                },
                function (returnValue) {
                    component.set('v.maxLengthData', returnValue);
                }
            );

            if (userMode === 'PI' || userMode === 'HCP') component.set('v.isStaff', true);
            else component.set('v.isStaff', false);

            component.set('v.changedLevels', []);
            component.set('v.changedLevelsAll', []);
            if (userMode !== 'HCP') {
                component.set('v.currentTab', 'by-study');
            } else {
                component.set('v.currentTab', 'all-same');
            }
            let parentId = communityService.getUrlParameter('id');
            if (parentId) {
                component.set('v.parentId', parentId);
            }
            communityService.executeAction(
                component,
                'getContactData',
                {
                    userMode: component.get('v.userMode'),
                    contactEmail: '',
                    parentId: parentId ? parentId : communityService.getDelegateId()
                },
                function (returnValue) {
                    let contactData = JSON.parse(returnValue);
                    component.set('v.delegate', contactData.delegates[0]);
                    component.set('v.delegateOptions', contactData.delegateOptions);
                    component.set('v.currentUserContactId', contactData.currentUserContactId);
                    component.set('v.parentFullName', contactData.parentFullName);
                    let allTrialLevel = {
                        delegateLevel: '',
                        trialName: $A.get(
                            '$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies'
                        )
                    };
                    component.set('v.allTrialLevel', allTrialLevel);
                    let studyDelegateLavelItems = component.find('study-level');
                    if (studyDelegateLavelItems) {
                        for (let i = 0; i < studyDelegateLavelItems.length; i++) {
                            studyDelegateLavelItems[i].refresh();
                        }
                    }

                    if (!component.get('v.isInitialized')) communityService.setStickyBarPosition();
                    component.set('v.isInitialized', true);

                    component.find('mainSpinner').hide();
                }
            );
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doSearchContact: function (component, event, helper) {
        let delegate = component.get('v.delegate');
        if (!communityService.isValidEmail(delegate.delegateContact.Email.trim())) {
            component.set('v.isCorrectEmail', false);
            delegate.delegateContact.Id = null;
            component.set('v.delegate', delegate);
            return;
        } else component.set('v.isCorrectEmail', true);

        let spinner = component.find('mainSpinner');
        spinner.show();

        let oldFirstName = delegate.delegateContact.FirstName;
        let oldLastName = delegate.delegateContact.LastName;

        communityService.executeAction(
            component,
            'getContactData',
            {
                userMode: component.get('v.userMode'),
                contactEmail: delegate.delegateContact.Email.toLowerCase().trim(),
                parentId: communityService.getUrlParameter('id')
                    ? communityService.getUrlParameter('id')
                    : communityService.getDelegateId()
            },
            function (returnValue) {
                let contactData = JSON.parse(returnValue);
                console.log('contactData', contactData);
                let userMode = component.get('v.userMode');
                let parentId = component.get('v.parentId');
                component.set('v.delegate', contactData.delegates[0]);
                console.log('isActive--->' + component.get('v.delegate.isActive'));
                component.set('v.isDelegateActive', component.get('v.delegate.isActive'));
                if (userMode !== 'HCP') {
                    component.set('v.currentTab', 'by-study');
                } else {
                    component.set('v.currentTab', 'all-same');
                }
                if (
                    contactData.delegates[0].delegateContact.Id === contactData.currentUserContactId
                ) {
                    communityService.showToast(
                        'error',
                        'error',
                        $A.get('$Label.c.TST_You_cannot_add_yourself_as_a_delegate')
                    );
                } else if (
                    userMode === 'HCP' &&
                    parentId !== undefined &&
                    contactData.delegates[0].delegateContact.Id === parentId
                ) {
                    communityService.showToast(
                        'error',
                        'error',
                        $A.get('$Label.c.TST_You_cannot_add_referring_provider_as_a_delegate')
                    );
                } else if (
                    userMode === 'PI' &&
                    parentId !== undefined &&
                    contactData.delegates[0].delegateContact.Id === parentId
                ) {
                    communityService.showToast(
                        'error',
                        'error',
                        $A.get('$Label.c.TST_You_cannot_add_primary_investigator_as_a_delegate')
                    );
                } else if (
                    contactData.delegates[0].delegateContact.Id === undefined &&
                    delegate.delegateContact.Id === undefined
                ) {
                    // component.set('v.currentTab','all-same');
                    console.log('delegateContact.Id===undefined');
                    component.find('firstNameInput').set('v.value', oldFirstName);
                    component.find('lastNameInput').set('v.value', oldLastName);
                }

                let allTrialLevel = {
                    delegateLevel: '',
                    trialName: $A.get(
                        '$Label.c.PG_NTM_L_Permission_level_will_apply_to_all_studies'
                    )
                };
                if (userMode === 'HCP') {
                    allTrialLevel.delegateLevel = contactData.delegates[0].trialLevel.delegateLevel;
                }
                component.set('v.allTrialLevel', allTrialLevel);
                let studyDelegateLavelItems = component.find('study-level');
                if (studyDelegateLavelItems) {
                    for (let i = 0; i < studyDelegateLavelItems.length; i++) {
                        studyDelegateLavelItems[i].refresh();
                    }
                }
                component.set('v.changedLevels', []);
                component.set('v.changedLevelsAll', []);

                component.find('mainSpinner').hide();
            }
        );
    },

    doSaveChanges: function (component, event, helper) {
        let delegate = component.get('v.delegate');
        let allTrialLevel = component.get('v.allTrialLevel');
        let currentTab = component.get('v.currentTab');

        if (currentTab === 'all-same' && component.get('v.userMode') === 'HCP') {
            delegate.trialLevel.delegateLevel = allTrialLevel.delegateLevel;
        } else if (currentTab === 'all-same' && component.get('v.userMode') === 'PI') {
            for (let i = 0; i < delegate.delegateTrials.length; i++) {
                for (let j = 0; j < delegate.delegateTrials[i].siteLevels.length; j++)
                    delegate.delegateTrials[i].siteLevels[j].delegateLevel =
                        allTrialLevel.delegateLevel;
            }
        }

        component.find('mainSpinner').show();
        if(delegate.delegateContact.FirstName){
        delegate.delegateContact.FirstName = delegate.delegateContact.FirstName.trim();
        } 
        if(delegate.delegateContact.LastName){
        delegate.delegateContact.LastName = delegate.delegateContact.LastName.trim();
        }

        if (component.get('v.userMode') === 'Participant') {
            console.log(
                'JSON.stringify(delegate.delegateContact)' +
                    JSON.stringify(delegate.delegateContact)
            );
            communityService.executeAction(
                component,
                'isExistingDelegate',
                {
                    delegate: JSON.stringify(delegate.delegateContact)
                },
                function (returnValue) {
                    component.set('v.isDelegateExisting', returnValue);
                    console.log('inside save-->' + component.get('v.delegate.isActive'));
                    if (component.get('v.isDelegateExisting')) {
                        if (component.get('v.delegate.isActive') == false) {
                            communityService.showToast(
                                'error',
                                'error',
                                $A.get('$Label.c.PP_DelegateAlreadyExists')
                            );
                        } else {
                            communityService.showToast(
                                'error',
                                'error',
                                $A.get('$Label.c.PP_ActiveDelegateError')
                            );
                        }
                        component.find('mainSpinner').hide();
                        return;
                    } else {
                        communityService.executeAction(
                            component,
                            'savePatientDelegate',
                            {
                                delegate: JSON.stringify(delegate.delegateContact)
                            },
                            function () {
                                communityService.showToast(
                                    'Success',
                                    'success',
                                    $A.get(
                                        '$Label.c.TST_You_have_successfully_created_permissions_for'
                                    ) +
                                        ' ' +
                                        delegate.delegateContact.FirstName +
                                        ' ' +
                                        delegate.delegateContact.LastName +
                                        '.'
                                );
                                component.set('v.isAttested', false);
                                component.set('v.isEmailConsentChecked', false);
                                component.refresh();
                            },
                            function () {
                                component.find('emailInput').set('v.value', '');
                                component.find('firstNameInput').set('v.value', '');
                                component.find('lastNameInput').set('v.value', '');
                                component.set('v.isAttested', false);
                                component.set('v.isEmailConsentChecked', false);
                                component.find('mainSpinner').hide();
                            }
                        );
                    }
                },
                function () {}
            );
        } else
            component
                .find('saveDelegateLevelChanges')
                .execute(delegate, component, delegate.delegateContact.Id === undefined);
    },

    doCheckEmail: function (component, event, helper) {
        let delegate = component.get('v.delegate');
        component.set(
            'v.isCorrectEmail',
            communityService.isValidEmail(delegate.delegateContact.Email)
        );
    },

    doCheckContactData: function (component, event, helper) {
        let delegate = component.get('v.delegate');
        component.set(
            'v.isCorrectContactData',
            ((delegate.delegateContact.FirstName  &&  delegate.delegateContact.FirstName.trim() !== '') &&
           ( delegate.delegateContact.LastName  &&   delegate.delegateContact.LastName.trim() !== ''))
        );
    }
});
