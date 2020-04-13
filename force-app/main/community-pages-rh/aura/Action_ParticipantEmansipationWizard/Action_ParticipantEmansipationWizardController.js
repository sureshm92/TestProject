/**
 * Created by Alexey Moseev.
 */

({

    doInit: function (component, event, helper) {
        helper.preparePathItems(component);
    },

    doExecute: function (component, event, helper) {
        try {
            component.find('spinner').show();
            component.set('v.initialized', false);
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            component.set('v.pe', pe);
            component.set('v.rootComponent', params.rootComponent);
            if (params.callback) component.set('v.callback', params.callback);

            communityService.executeAction(component, 'getInitData', null, function (formData) {
                component.set('v.formData', formData);
                let states = formData.statesByCountryMap[pe.Participant__r.Mailing_Country_Code__c];
                component.set('v.statesLVList', states);
                component.set('v.currentTab', '1');
                pe.Participant__r.Emancipation_in_progress__c = false;
                if (!pe.Participant__r.Alternative_Phone_Type__c || !pe.Participant__r.Alternative_Phone_Number__c) {
                    pe.Participant__r.Alternative_Phone_Type__c = 'Home';
                }
                component.set('v.participant', pe.Participant__r);

                let contact = { sObjectType: 'Contact',
                                Id: pe.Participant__r.Contact__c,
                                Consent_To_Inform_About_Study__c: false };
                component.set('v.contact', contact);

                helper.initDelegates(component, event, helper);

                helper.checkFields(component, event, helper);

                component.set('v.initialized', true);
                component.find('spinner').hide();
                console.log('doExecute: ' + JSON.stringify(component.get('v.participant')));
            }, function (returnValue) {
                component.find('spinner').hide();
            });

            component.set('v.participantMsgWithName', $A.get("$Label.c.PG_Ref_L_Participant_require_invitation").replace('##participantName', pe.Participant__r.First_Name__c + ' ' + pe.Participant__r.Last_Name__c));
            helper.prepareDelegates(component);

            component.find('dialog').show();
        } catch (e) {
            console.error(e);
        }
    },

    doCallback: function (component, event, helper) {
        var pe = component.get('v.pe');
        component.get('v.callback')(pe);
    },

    doCancel: function (component, event, helper) {
        var comp = component.find('dialog');
        comp.hide();
    },

    doHandleRadioClick : function(component, event, hepler) {
        component.set('v.selectedOption', event.getSource().get('v.value'));
    },

    doHandleDelegateRadioClick : function(component, event, hepler) {
        let ind = event.getSource().get('v.id');
        let delegateItems = component.get('v.delegateItems');
        delegateItems[ind].selectedOption = event.getSource().get('v.value');
        component.set('v.delegateItems', delegateItems);
    },

    doCheckFields: function (component, event, helper) {
        helper.checkFields(component, event, helper);
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var countryMap =  component.get('v.formData.countriesLVList');
        var participant = component.get('v.participant');
        for (let i = 0; i < countryMap.length; i++) {
            if (countryMap[i].value == participant.Mailing_Country_Code__c) {
                component.set('v.participant.Mailing_Country__c', countryMap[i].label);
                break;
            }
        }
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.set('v.participant.Mailing_State__c', null);

        helper.checkFields(component, event, helper);
    },

    doStateChange: function(component, event, helper) {
        var states = component.get('v.statesLVList');
        if (states) {
            var participant = component.get('v.participant');
            for (let i = 0; i < states.length ; i++) {
                if (states[i].value == participant.Mailing_State_Code__c) {
                    component.set('v.participant.Mailing_State__c', states[i].label);
                    break;
                }
            }
        }

        helper.checkFields(component, event, helper);
    },

    doCheckDelegateFields: function (component, event, helper) {
        helper.checkDelegateFields(component, event, helper);
    },

    doDelegateCountryCodeChanged: function (component, event, helper) {
        let delegateItems = component.get('v.delegateItems');

        let statesByCountryMap = component.get('v.formData.statesByCountryMap');
        let countryMap =  component.get('v.formData.countriesLVList');

        for (let i = 0; i < countryMap.length; i++) {
            for (let ind = 0; ind < delegateItems.length; ind++) {
                if (countryMap[i].value == delegateItems[ind].Mailing_Country_Code__c) {
                    delegateItems[ind].Mailing_Country__c = countryMap[i].label;
                    let states = statesByCountryMap[delegateItems[ind].Mailing_Country_Code__c];
                    delegateItems[ind].statesDelegateLVList = states;
                    delegateItems[ind].Mailing_State_Code__c = null;
                    delegateItems[ind].Mailing_State__c = null;
                }
            }
        }
        component.set('v.delegateItems', delegateItems);

        helper.checkDelegateFields(component, event, helper);
    },

    doDelegateStateChange: function(component, event, helper) {
        let delegateItems = component.get('v.delegateItems');

        for (let ind = 0; ind < delegateItems.length; ind++) {
            let states = delegateItems[ind].statesDelegateLVList;
            if (states) {
                for (let i = 0; i < states.length; i++) {
                    if (states[i].value == delegateItems[ind].Mailing_State_Code__c) {
                        delegateItems[ind].Mailing_State__c = states[i].label;
                        break;
                    }
                }
            }
        }
        component.set('v.delegateItems', delegateItems);

        helper.checkDelegateFields(component, event, helper);
    },

    doNext: function(component, event, helper) {
        let currentTab = component.get('v.currentTab');
        if (currentTab != '4') {
            currentTab = '' + (+currentTab + 1);
            component.set('v.currentTab', currentTab);
            helper.preparePathItems(component);

            if (currentTab == '2') {
                helper.checkDelegateFields(component, event, helper);
                console.log(component.get('v.delegateItems'));
            }
        } else {
            helper.updateParticipantAndDelegate(component);
        }
    },

    doBack: function(component, event, helper) {
        let currentTab = component.get('v.currentTab');
        if (currentTab != '1') {
            currentTab = '' + (+currentTab - 1);
            component.set('v.currentTab', currentTab);
            helper.preparePathItems(component);

            if (currentTab == '2') {
                helper.checkDelegateFields(component, event, helper);
            }
        } else {
            component.set('v.isDelegatesValid', true);

            helper.checkFields(component, event, helper);
        }
    },

    doAddDelegate: function (component, event, helper) {
        let delegateItems = component.get('v.delegateItems');
        let statesByCountryMap = component.get('v.formData.statesByCountryMap');
        let states = statesByCountryMap[component.get('v.participant.Mailing_Country_Code__c')];

        delegateItems.push(
            { sObjectType: 'Participant__c',
              selectedOption: '1',
              Mailing_State_Code__c: component.get('v.participant.Mailing_State_Code__c'),
              Mailing_State__c: component.get('v.participant.Mailing_State__c'),
              Mailing_Country_Code__c: component.get('v.participant.Mailing_Country_Code__c'),
              Mailing_Country__c: component.get('v.participant.Mailing_Country__c'),
              statesDelegateLVList: states,
              Adult__c: true,
              Phone_Type__c: 'Home',
              isConnected: false,
              fromStart: false
            });
        component.set('v.delegateItems', delegateItems);
    }

});