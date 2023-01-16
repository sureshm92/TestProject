({
    doInit: function (component, event, helper) {
        //console.log('inside init pp account');
        component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId) {
            component.set('v.isDelegate', true);
        } else {
            component.set('v.isDelegate', false);
        }
        component.set(
            'v.participantState',
            communityService.getCurrentCommunityMode().participantState
        );
        var device = $A.get('$Browser.formFactor');
        if (device == 'PHONE') {
            component.set('v.isDesktop', false);
        }
        communityService.executeAction(
            component,
            'getInitData',
            {
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                let initData = JSON.parse(returnValue);
                initData.password = {
                    old: '',
                    new: '',
                    reNew: ''
                };
                //var compId = component.get('v.compId');
                //console.log('compId-->' + compId);
                const queryString = window.location.href;
                if (queryString.includes('changePref')) {
                    component.set('v.compId', '5');
                } else if (queryString.includes('langloc')) {
                    component.set('v.compId', '4');
                } else if (queryString.includes('profileInformation')) {
                    component.set('v.compId', '1');
                } else if (queryString.includes('communication-preferences')) {
                    component.set('v.compId', '3');
                } else if (queryString.includes('passwordchange')) {
                    component.set('v.compId', '2');
                } else if (queryString.includes('cookiesSettings')) {
                    component.set('v.compId', '6');
                } else if (queryString.includes('notify')) {
                    component.set('v.compId', '7');
                } else if (queryString.includes('manage-delegates')) {
                    component.set('v.compId', '8');
                } else {
                    console.log('URL param not found!');
                }
                //console.log('initData: '+initData);
                //console.log('contactChanged: '+initData.contactChanged);
                component.set('v.initData', initData);
                component.set('v.contactChanged', initData.contactChanged);
                component.set('v.personWrapper', initData.contactSectionData.personWrapper);
                component.set('v.contactSectionData', initData.contactSectionData);
                component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
                component.set('v.optInSMS', initData.contactSectionData.personWrapper.optInSMS);
                component.set('v.userType', initData.myContact.UserCommunytyType__c);
                component.set('v.consentPreferenceData', initData.consentPreferenceData);
                var userType = initData.myContact.userCommunytyType__c;
                if (userType)
                    if (userType.includes('HCP') && component.get('v.userMode') == 'PI')
                        component.set('v.userTypeHCP_PI', true);

                component.set('v.contact', initData.myContact);
                component.set('v.currentEmail', initData.myContact.Email);

                component.set('v.isInitialized', true);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },

    removeFocus: function (component, event, helper) {
        var y = document.getElementById('selectOption');
        y.style.boxShadow = 'none';
        component.set('v.toglNavg', false);
    },
    // Added for REF-2736 bug fixing
    onClick: function (component, event, helper) {
        var y = document.getElementById('selectOption');
        var toglNavg = component.get('v.toglNavg');
        toglNavg = !toglNavg;
        component.set('v.toglNavg', toglNavg);
        var device = $A.get('$Browser.formFactor');
        var id = event.target.dataset.menuItemId;
        component.set('v.compId', id);
        var compId = component.get('v.compId');

        if (device == 'PHONE' || device == 'TABLET') {
            for (var i = 1; i < 7; i++) {
                var x = document.getElementById(i);
                if (id != i && !toglNavg) {
                    // x.style.visibility = 'hidden';
                    x.style.display = 'none';
                    y.style.boxShadow = 'none';
                    y.style.background = 'Transparent';
                } else if (toglNavg) {
                   // x.style.visibility = 'visible';
                    x.style.display = 'block';
                    y.style.boxShadow = '0 4px 24px 0 rgba(0, 0, 0, 0.16)';
                    y.style.background = '#fff';
                }
            }
        }

        if (compId == '1') {
            window.history.replaceState(null, null, '?profileInformation');
            //communityService.navigateToPage('account-settings?profileInformation');
        } else if (compId == '4') {
            window.history.replaceState(null, null, '?langloc');
            //communityService.navigateToPage('account-settings?langloc');
        } else if (compId == '5') {
            window.history.replaceState(null, null, '?changePref');
            //communityService.navigateToPage('account-settings?changePref');
        } else if (compId == '2') {
            window.history.replaceState(null, null, '?passwordchange');
            //communityService.navigateToPage('account-settings?passwordchange');
        } else if (compId == '6') {
            window.history.replaceState(null, null, '?cookiesSettings');
            //communityService.navigateToPage('account-settings?cookiesSettings');
        } else if (compId == '7') {
            window.history.replaceState(null, null, '?notify');
            //communityService.navigateToPage('account-settings?notify');
        } else if (compId == '3') {
            window.history.replaceState(null, null, '?communication-preferences');
        } else if (compId == '8') {
            window.history.replaceState(null, null, '?manage-delegates');
        } else {
            communityService.navigateToPage('account-settings');
        }
    },

    /*onClick: function (component, event, helper) {
        var y = document.getElementById('selectOption');
        var toglNavg = component.get('v.toglNavg');
        toglNavg = !toglNavg;
        component.set('v.toglNavg', toglNavg);
        //var isOpen = false;
        var device = $A.get('$Browser.formFactor');
        var id = event.target.dataset.menuItemId;
        component.set('v.compId', id);
        var compId = component.get('v.compId');
        //var queryString = window.location.href;
        if (device == 'PHONE' || device == 'TABLET') {
            for (var i = 1; i < 7; i++) {
                var x = document.getElementById(i);
                if (id != i && !toglNavg) {
                    x.style.visibility = 'hidden';
                    y.style.boxShadow = 'none';
                    y.style.background = 'Transparent';
                } else if (toglNavg) {
                    x.style.visibility = 'visible';
                    y.style.boxShadow = '0 4px 24px 0 rgba(0, 0, 0, 0.16)';
                    y.style.background = '#fff';
                }
            }
        }
        if (compId == '1') {
            communityService.navigateToPage('account-settings?profileInformation');
        } else if (compId == '3') {
            communityService.navigateToPage('account-settings?langloc');
        } else if (compId == '4') {
            communityService.navigateToPage('account-settings?changePref');
        } else if (compId == '2') {
            communityService.navigateToPage('account-settings?passwordchange');
        } else if (compId == '5') {
            communityService.navigateToPage('account-settings?cookiesSettings');
        } else if (compId == '6') {
            communityService.navigateToPage('account-settings?notify');
        } else {
            communityService.navigateToPage('account-settings');
        }
    },*/

    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');
        component.set('v.personWrapper', personWrapper);
    },
    selectPassword: function (component, event, helper) {}
});