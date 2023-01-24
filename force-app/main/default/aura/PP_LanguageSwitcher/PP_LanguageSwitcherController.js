/**
 * Created by Sneha Shilpa Thuluri
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.userMode', communityService.getUserMode());
        console.log(communityService.getCurrentCommunityMode().currentDelegateId);
        if (communityService.getCurrentCommunityMode().currentDelegateId) {
            component.set('v.isDelegate', true);
        } else {
            component.set('v.isDelegate', false);
        }
        communityService.executeAction(
            component,
            'getInitData',
            null,
            function (returnValue) {
                let initData = JSON.parse(returnValue);
                let sectionData = component.get('v.contactSectionData');

                component.set('v.countriesLVList', sectionData.countriesLVList);
                component.set('v.statesByCountryMap', sectionData.statesByCountryMap);

                let personWrapper = component.get('v.personWrapper');
                helper.setPersonSnapshot(component);
                component.set('v.previousCC', personWrapper.mailingCC);
                component.set(
                    'v.statesLVList',
                    sectionData.statesByCountryMap[personWrapper.mailingCC]
                );

                setTimeout(
                    $A.getCallback(function () {
                        helper.setFieldsValidity(component);
                        component.showHelpMessageIfInvalid();
                    }),
                    50
                );

                component.set('v.languages', initData.languages);
                component.set('v.optionalLanguages', initData.optionalLanguages);
                component.set('v.locales', initData.locales);
                component.set('v.timezones', initData.timezones);
                component.set('v.isDisabled', true);

                console.log(initData.languages);
                setTimeout(
                    $A.getCallback(function () {
                        component.set('v.languageKey', initData.languageKey);
                        component.set('v.previousValue', initData.languageKey);
                        component.set('v.secondLangKey', initData.secondLangKey);
                        component.set('v.thirdLangKey', initData.thirdLangKey);
                        component.set('v.localeKey', initData.localeKey);
                        component.set('v.timezoneKey', initData.timezoneKey);
                        component.set('v.prevTimeZoneKey', initData.timezoneKey);
                        component.set('v.prevLocaleKey',initData.localeKey);                        
                        //alert('callBack'+component.find("pFieldCountry").get('v.value')+personWrapper.mailingCC);
                        //component.find("pFieldCountry").set('v.value',personWrapper.mailingCC);
                        component.set('v.personWrapper.mailingCC', personWrapper.mailingCC);
                        component.set('v.initialized', true);
                    }),
                    100
                );
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },
    doCheckFieldsValidity: function (component, event, helper) {
        let personWrapper = component.get('v.personWrapper');
        component.set('v.isDisabled', false);
        if (personWrapper.mailingCC !== component.get('v.previousCC')) {
            let statesByCountryMap = component.get('v.statesByCountryMap');
            let states = statesByCountryMap[personWrapper.mailingCC];
            component.set('v.statesLVList', states);
            component.set('v.previousCC', personWrapper.mailingCC);
            personWrapper.mailingSC = null;
            component.set('v.personWrapper', personWrapper);

            component.set('v.reRender', false);
            component.set('v.reRender', true);
        }

        helper.setFieldsValidity(component);
    },
    doChangeLanguage: function (component) {
        if (!component.get('v.initialized')) return;
        var languageKey = component.get('v.languageKey');
        var previousLangaugeKey = component.get('v.previousValue');
        var countryName, stateName, zipcode;
        var isUserModeParticipant = false;
        if (component.get('v.userMode') == 'Participant') {
            countryName = component.get('v.personWrapper.mailingCC');
            stateName = component.get('v.personWrapper.mailingSC');
            //if(component.get('v.personWrapper.zip')!=null)
            zipcode = component.get('v.personWrapper.zip');
            isUserModeParticipant = true;
        }

        var secondLangKey = component.get('v.secondLangKey');
        var thirdLangKey = component.get('v.thirdLangKey');
        var localeKey = component.get('v.localeKey');
        var timezoneKey = component.get('v.timezoneKey');
        //var zipcode = component.get('v.zipcodeKey');
        component.find('spinner').show();
        if (component.get('v.userMode') == 'Participant') {
            var tempcountries = component.get('v.countriesLVList'),
                value = component.find('pFieldCountry').get('v.value');
            //index = tempcountries.findIndex(item => item.value == value);
            var index;
            if(tempcountries !=null && tempcountries !=undefined){
                for (var i = 0; i < tempcountries.length; ++i) {
                    if (tempcountries[i].value == value) {
                        index = i;
                        break;
                    }
                }
                console.log(index);
                countryName = index >= 0 ? tempcountries[index].label : null;
            }
            var tempstates = component.get('v.statesLVList'),
                statevalue = component.find('pFieldState').get('v.value');
            //stateindex = tempstates.findIndex(item => item.value == statevalue);
            var stateindex;
            if(tempstates!=null && tempstates!=undefined){
                for (var i = 0; i < tempstates.length; ++i) {
                    if (tempstates[i].value == statevalue) {
                        stateindex = i;
                        break;
                    }
                }
                stateName = stateindex >= 0 ? tempstates[stateindex].label : null;
            }
        }

        communityService.executeAction(
            component,
            'changeLanguage',
            {
                languageKey: languageKey,
                secondLangKey: secondLangKey,
                thirdLangKey: thirdLangKey,
                localeKey: localeKey,
                timezoneKey: timezoneKey,
                countryName: countryName,
                stateName: stateName,
                zipcode: zipcode,
                isUserModeParticipant: isUserModeParticipant
            },
            function () {
                component.find('spinner').hide();
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.PP_Profile_Update_Success'),
                    100
                );
                communityService.navigateToPage('account-settings?langloc');
                if (
                    previousLangaugeKey != languageKey ||
                    localeKey != component.get('v.prevLocaleKey') ||
                    timezoneKey != component.get('v.prevTimeZoneKey')
                )
                    communityService.reloadPage();
            }
        );
    },
    doStateChanged: function (component, event, helper) {
        let snapShot = component.get('v.personSnapshot');
        let personWrapper = component.get('v.personWrapper');
        let currentState = JSON.stringify(personWrapper);
        let isStateChanged = snapShot !== currentState;
        component.set('v.isStateChanged', isStateChanged);

        if (isStateChanged && personWrapper.mailingCC !== component.get('v.previousCC')) {
            setTimeout(function () {
                component.getEvent('onEdit').fire();
            }, 50);
        }
    }
});