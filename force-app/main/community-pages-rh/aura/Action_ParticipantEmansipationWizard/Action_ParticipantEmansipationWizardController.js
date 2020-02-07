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
                let states = formData.statesByCountryMap['US'];
                component.set('v.statesLVList', states);
                component.set('v.currentTab', '1');
                component.set('v.initialized', true);
                pe.Participant__r.Emancipation_in_progress__c = false;
                component.set('v.participant', pe.Participant__r);
                let contact = { sObjectType: 'Contact',
                                Id: pe.Participant__r.Contact__c,
                                Consent_To_Inform_About_Study__c: false };
                component.set('v.contact', contact);
                var action = component.get('c.doCheckFields');
                $A.enqueueAction(action);

                action = component.get('c.doInitDelegates');
                $A.enqueueAction(action);

                component.find('spinner').hide();
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

    doInitDelegates: function(component, event, helper) {
        communityService.executeAction(component, 'getParticipantDelegates', {
            participantId: component.get('v.pe.Participant__c')
        },  function (delegateItems) {
            for (let ind = 0; ind < delegateItems.length; ind++) {
                delegateItems[ind].continueDelegateMsg = $A.get('$Label.c.PG_Ref_L_Delegate_continue_be_delegate').replace('##delegateName', delegateItems[ind].First_Name__c + ' ' + delegateItems[ind].Last_Name__c);
                delegateItems[ind].selectedOption = '1';
            }
            component.set('v.delegateItems', delegateItems);
            let formData = component.get('v.formData');
            let states = formData.statesByCountryMap[delegateItems[ind].Mailing_Country_Code__c];
            delegateItems[ind].statesDelegateLVList = states;

            component.find('spinner').hide();
        }, function (returnValue) {
            component.find('spinner').hide();
            communityService.showErrorToast('',  "Error get Participant's Delegates! Description: " + returnValue);
        });
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

    doCheckFields: function (component, event) {
        var participant = component.get('v.participant');
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        var stateRequired = component.get('v.statesLVList')[0];
        var stateCmp = component.find('stateField');
        var stateVaild = stateRequired && stateCmp && stateCmp.get('v.validity') && stateCmp.get('v.validity').valid;

        let isValid =
            participant.First_Name__c &&
            participant.Last_Name__c &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            participant.Mailing_Zip_Postal_Code__c &&
            component.find('emailInput').get('v.validity').valid &&
            component.find('phoneInput').get('v.validity').valid &&
            stateVaild;

        component.set('v.isValid', isValid);
        return isValid;
    },

    doCountryCodeChanged: function (component, event, helper) {
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var countryMap =  component.get('v.formData.countriesLVList');
        var participant = component.get('v.participant');
        for (let i = 0; i <countryMap.length ; i++) {
            if (countryMap[i].value == participant.Mailing_Country_Code__c) {
                component.set('v.participant.Mailing_Country__c', countryMap[i].label);
                break;
            }
        }
        var states = statesByCountryMap[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        component.set('v.participant.Mailing_State_Code__c', null);
        component.set('v.participant.Mailing_State__c', null);

        var action = component.get('c.doCheckFields');
        $A.enqueueAction(action);
        //this.doCheckFields(component, event);
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

        var action = component.get('c.doCheckFields');
        $A.enqueueAction(action);
        //this.doCheckFields(component, event);
    },

    doCheckDelegateFields: function (component, event) {
        let delegateItems = component.get('v.delegateItems');

        let isDelegatesValid = component.get('v.isDelegatesValid');
        isDelegatesValid = true;

        for (let ind = 0; ind < delegateItems.length; ind++) {
            if (delegateItems[ind] && delegateItems[ind].Id) {
                let states = delegateItems[ind].statesDelegateLVList;
                isDelegatesValid = (isDelegatesValid &&
                    (delegateItems[ind].Mailing_Country_Code__c &&
                    (!states || delegateItems[ind].Mailing_State__c) &&
                    delegateItems[ind].Mailing_Zip_Postal_Code__c &&
                    delegateItems[ind].Email__c &&
                    delegateItems[ind].Phone_Type__c &&
                    delegateItems[ind].Phone__c));
            }
        }

        component.set('v.isDelegatesValid', isDelegatesValid);
    },

    doDelegateCountryCodeChanged: function (component, event) {
        let delegateItems = component.get('v.delegateItems');

        let statesByCountryMap = component.get('v.formData.statesByCountryMap');
        let countryMap =  component.get('v.formData.countriesLVList');

        for (let i = 0; i <countryMap.length ; i++) {
            for (let ind = 0; ind < delegateItems.length; ind++) {
                if (countryMap[i].value == delegateItems[ind].Mailing_Country_Code__c) {
                    delegateItems[ind].Mailing_Country__c = countryMap[i].label;
                    let states = statesByCountryMap[delegateItems[ind].Mailing_Country_Code__c];
                    delegateItems[ind].statesDelegateLVList = states;
                    delegateItems[ind].Mailing_State_Code__c = null;
                    delegateItems[ind].Mailing_State__c = null;
                    break;
                }
            }
        }
        component.set('v.delegateItems', delegateItems);

        var action = component.get('c.doCheckDelegateFields');
        $A.enqueueAction(action);
        //this.doCheckDelegateFields(component, event);
    },

    doDelegateStateChange: function(component, event) {
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

        var action = component.get('c.doCheckDelegateFields');
        $A.enqueueAction(action);
        //this.doCheckDelegateFields(component, event);
    },

    doNext: function(component, event, helper) {
        let currentTab = component.get('v.currentTab');
        if (currentTab != '4') {
            currentTab = '' + (+currentTab + 1);
            component.set('v.currentTab', currentTab);
            helper.preparePathItems(component);
            if (currentTab == '2') {
                var action = component.get('c.doCheckDelegateFields');
                $A.enqueueAction(action);
                //this.doCheckDelegateFields(component, event)
            }
        } else {
            if (component.get('v.isValid')) {
                helper.updateParticipantAndDelegate(component);
            }
        }
    },

    doBack: function(component, event, helper) {
        let currentTab = component.get('v.currentTab');
        if (currentTab != '1') {
            currentTab = '' + (+currentTab - 1);
            component.set('v.currentTab', currentTab);
            helper.preparePathItems(component);
            if (currentTab == '2') {
                var action = component.get('c.doCheckDelegateFields');
                $A.enqueueAction(action);
                //this.doCheckDelegateFields(component, event);
            }
        } else {
            component.set('v.isDelegatesValid', true);
            var action = component.get('c.doCheckFields');
            $A.enqueueAction(action);
            //this.doCheckFields(component, event);
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
              Adult__c: true
            });
        component.set('v.delegateItems', delegateItems);
    }

});
