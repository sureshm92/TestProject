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
            if (delegateItems[ind].Id != undefined && delegateItems[ind].selectedOption == '2') {
                doNotContinueIds.push(delegateItems[ind].Id);
            }
            delete delegateItems[ind].selectedOption;
            delete delegateItems[ind].statesDelegateLVList;
            delete delegateItems[ind].continueDelegateMsg;
        }
        console.log(doNotContinueIds);
        console.log(JSON.stringify(component.get('v.contact')));

        communityService.executeAction(component, 'updateParticipantAndDelegates', {
            participantS: JSON.stringify(component.get('v.participant')),
            participantContactS: JSON.stringify(component.get('v.contact')),
            delegatesS: JSON.stringify(component.get('v.delegateItems')),
            doNotContinueIds: doNotContinueIds,
            needsInvite: (component.get('v.selectedOption') == '1')
        }, function () {
            console.log('Emancipation wizard completed!');
            component.set('v.currentTab', '1');
            component.set('v.pe.Participant__r', component.get('v.participant'));

            component.find('spinner').hide();
            component.find('dialog').hide();
            communityService.navigateToPage('my-referrals');
        }, function (returnValue) {
            console.log('Emancipation wizard ERROR!: ' + returnValue);
            component.find('spinner').hide();
            communityService.showErrorToast('',  "Emancipation process failed! Description: " + returnValue);
        });
    }

});