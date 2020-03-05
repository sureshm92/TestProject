/**
 * Created by Alexey Moseev.
 */

({
    preparePathItems : function (component) {

        let statuses = this.getStatuses();
        let statusesMap = this.getStatusesMap();
        let currentTab = component.get('v.currentTab');
        let currentImansipationWizardState = statusesMap[statuses[(+currentTab - 1)]];

        component.set('v.showPath', true);

        let pathList = [];
        let iconMap = {
            success : 'icon-check',
            failure : '',
            neutral : '',
            in_progress : ''
        };
        for (var i = 0; i < statuses.length; i++) {
            //default values for path item:
            let pathItem = statusesMap[statuses[i]];
            pathItem.name = statuses[i];

            if (currentImansipationWizardState) {
                if (pathItem.order === currentImansipationWizardState.order) {
                    pathItem.left = 'success';
                    pathItem.state = currentImansipationWizardState.state;
                    pathItem.isCurrent = true;
                } else if (pathItem.order < currentImansipationWizardState.order) {
                    pathItem.left = 'success';
                    pathItem.state = 'success';
                } else {
                    pathItem.state = 'neutral';
                    pathItem.left = 'neutral';
                }
            }

            pathItem.iconName = iconMap[pathItem.state];
            pathList.push(pathItem);
            if (i > 0) {
                pathList[i - 1].right = pathItem.left;
                pathList[i - 1].nextState = pathItem.state;
            }
        }
        component.set('v.pathItems', pathList);
    },

    getStatuses : function () {
        return ["Participant", "Delegate(s)", "Provider Access", "Review and Confirm"];
    },

    getStatusesMap : function () {
        return {
            "Participant" : {
                order : 1,
                state : "neutral"
            },
            "Delegate(s)" : {
                order : 2,
                state : "neutral"
            },
            "Provider Access" : {
                order : 3,
                state : "neutral"
            },
            "Review and Confirm" : {
                order : 4,
                state : "neutral"
            }
        };
    },

    prepareDelegates : function (component) {
        let delegateParticipant = {
            sObjectType: 'Participant__c',
            selectedOption: '1'
        };
        let delegateItems = [];
        delegateItems.push(delegateParticipant);
        component.set('v.delegateItems', delegateItems);
    },

    updateParticipantAndDelegate : function (component) {
        component.find('spinner').show();

        let doNotContinueIds = [];
        let delegateItems = component.get('v.delegateItems');
        for (let ind = 0; ind < delegateItems.length; ind++) {
            if (delegateItems[ind].Contact__c != undefined && delegateItems[ind].selectedOption == '2') {
                doNotContinueIds.push(delegateItems[ind].Contact__c);
            }
            delete delegateItems[ind].selectedOption;
            delete delegateItems[ind].statesDelegateLVList;
            delete delegateItems[ind].continueDelegateMsg;
        }
        console.log(doNotContinueIds);

        communityService.executeAction(component, 'updateParticipantAndDelegates', {
            participantS: JSON.stringify(component.get('v.participant')),
            participantContactS: JSON.stringify(component.get('v.contact')),
            delegatesS: JSON.stringify(component.get('v.delegateItems')),
            doNotContinueIds: doNotContinueIds,
            needsInvite: (component.get('v.selectedOption') == '1'),
            studySiteId: component.get('v.pe.Study_Site__c')
        }, function () {
            console.log('Emancipation wizard completed!');
            component.set('v.pe.Participant__r', component.get('v.participant'));

            component.find('spinner').hide();
            component.find('dialog').hide();

            communityService.navigateToPage('my-referrals');
        }, function (returnValue) {
            console.log('Emancipation wizard ERROR!: ' + returnValue);
            component.find('spinner').hide();
            communityService.showErrorToast('',  "Emancipation process failed! Description: " + returnValue);
        });
    },

    checkFields: function (component, event, helper) {
        var participant = component.get('v.participant');
        var states = component.get('v.statesLVList');

        let isValid =
            (participant.First_Name__c && participant.First_Name__c.trim()) &&
            (participant.Last_Name__c && participant.Last_Name__c.trim()) &&
            participant.Date_of_Birth__c &&
            participant.Gender__c &&
            participant.Phone__c &&
            participant.Phone_Type__c &&
            participant.Email__c &&
            (participant.Mailing_Zip_Postal_Code__c && participant.Mailing_Zip_Postal_Code__c.trim()) &&
            (!component.find('emailInput') || (component.find('emailInput') &&
                component.find('emailInput').get('v.validity').valid)) &&
            (!component.find('phoneInput') || (component.find('phoneInput') &&
                component.find('phoneInput').get('v.validity').valid)) &&
            participant.Mailing_Country_Code__c &&
            ((states && states.length == 0) || participant.Mailing_State_Code__c);

        console.log('doCheckFields: ' + JSON.stringify(component.get('v.participant')));
        component.set('v.isValid', isValid);
    },

    checkDelegateFields: function (component, event, helper) {
        let delegateItems = component.get('v.delegateItems');
        let isDelegatesValid = true;

        for (let ind = 0; ind < delegateItems.length; ind++) {
            if (delegateItems[ind] && (delegateItems[ind].Id ||
                delegateItems[ind].First_Name__c && delegateItems[ind].First_Name__c.trim() &&
                delegateItems[ind].Last_Name__c && delegateItems[ind].Last_Name__c.trim())) {

                isDelegatesValid = (isDelegatesValid &&
                        (delegateItems[ind].Mailing_Zip_Postal_Code__c && delegateItems[ind].Mailing_Zip_Postal_Code__c.trim()) &&
                        delegateItems[ind].Email__c &&
                        delegateItems[ind].Phone_Type__c &&
                        delegateItems[ind].Phone__c &&
                        (!component.find('emailDInput' + ind) || (component.find('emailDInput' + ind) &&
                            component.find('emailDInput' + ind).get('v.validity').valid)) &&
                        (!component.find('phoneDInput' + ind) || (component.find('phoneDInput' + ind) &&
                            component.find('phoneDInput' + ind).get('v.validity').valid))));
            }
        }

        component.set('v.isDelegatesValid', isDelegatesValid);
    },

    initDelegates: function(component, event, helper) {
        communityService.executeAction(component, 'getParticipantDelegates', {
            participantId: component.get('v.pe.Participant__c')
        },  function (delegateItems) {
            let formData = component.get('v.formData');
            for (let ind = 0; ind < delegateItems.length; ind++) {
                delegateItems[ind].continueDelegateMsg = $A.get('$Label.c.PG_Ref_L_Delegate_continue_be_delegate').replace('##delegateName', delegateItems[ind].First_Name__c + ' ' + delegateItems[ind].Last_Name__c);
                delegateItems[ind].selectedOption = '1';
                var statesByCountryMap = component.get('v.formData.statesByCountryMap');
                let states = statesByCountryMap[delegateItems[ind].Mailing_Country_Code__c];
                delegateItems[ind].statesDelegateLVList = states;
                if (!delegateItems[ind].Phone_Type__c) {
                    delegateItems[ind].Phone_Type__c = 'Home';
                }
            }
            console.log(delegateItems);
            component.set('v.delegateItems', delegateItems);

            component.find('spinner').hide();
        }, function (returnValue) {
            component.find('spinner').hide();
            communityService.showErrorToast('',  "Error get Participant's Delegates! Description: " + returnValue);
        });
    },

});