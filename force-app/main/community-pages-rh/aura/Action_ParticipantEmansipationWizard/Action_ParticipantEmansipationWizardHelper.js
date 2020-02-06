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
            Id: 'a0a0R000003iPoMQAU',
            selectedOption: '1'
        };
        let delegateItems = [];
        delegateItems.push(delegateParticipant);
        component.set('v.delegateItems', delegateItems);
    },

    updateParticipantAndDelegates : function (component) {
        component.find('spinner').show();

        let doNotContinueIds = [];
        let delegateItems = component.get('v.participant');
        for (let delegateItem in delegateItems) {
            if (delegateItem.Id && delegateItem.selectedOption == '2') {
                doNotContinueIds.push(delegateItem.Id);
            }
        }

        communityService.executeAction(component, 'updateParticipantAndDelegates', {
            participant: component.get('v.participant'),
            participantContact: component.get('v.contact'),
            delegates: component.get('v.participant'),
            doNotContinueIds: doNotContinueIds
        }, function (returnValue) {
            component.set('v.currentTab', '1');

            component.find('spinner').hide();
            component.find('dialog').hide();
        }, function (returnValue) {
            component.find('spinner').hide();
            communityService.showErrorToast('',  "Emancipation process failed! Description: " + returnValue);
        });
    }

});