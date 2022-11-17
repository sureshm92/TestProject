/**
 * Created by Kryvolap on 21.09.2019.
 * Updated by Sumit Surve on 13.07.2020
 */

 ({
    doInit: function (component, event, helper) {
        var communityTemplate=communityService.getCurrentCommunityTemplateName();
        communityService.executeAction(
            component,
            'getHelpInitData',
            
            {
                userMode: component.get('v.userMode'),
                communityName:communityTemplate
            },
            function (response) {
                var initData = JSON.parse(response);
                component.set('v.userContact', initData.userContact.currentContact);
                component.set('v.helpTopicOptions', initData.helpTopicOptions);
                component.set('v.helpTopicSettings', initData.helpTopicSettings);
                component.set('v.participantPicklistvalues', initData.participantEnrollOptions);
                component.set('v.sitePicklistvalues', initData.siteOptions);
                helper.initRGOptions(component);
                component.set('v.isInitialized', true);
                var spinner = component.find('spinner');
                spinner.hide();
            }
        );
    },

    submitRequest: function (component, event, helper) {
        var participant,
            buttonId = event.target.id,
            isValid = false;

        if (buttonId == 'sitetransfer') {
            participant = component.find('participant');
            isValid = participant.get('v.validity').valid;
        } else if (buttonId == 'needhelp') {
            isValid = true;
        }

        if (isValid) {
            var text;
            var type;
            var subject;
            var priority;
            var reason;
            var escalated;
            var newSite = component.get('v.currentSite');
            var currentParticipant = component.get('v.currentParticipant');
            var textRequired = component.get('v.userDescriptionRequired');
            var helpTopicSettings = component.get('v.helpTopicSettings');
            var selectedTopic = component.get('v.selectedTopic');
            type = helpTopicSettings[selectedTopic].type;
            subject = helpTopicSettings[selectedTopic].subject;
            if (subject == $A.get('$Label.c.Case_sub_transfer_to_new_site')) {
                text = 'Please transfer ' + currentParticipant + ' to ' + newSite;
            } else {
                text = helpTopicSettings[selectedTopic].userDescriptionRequired
                    ? component.get('v.textValueProblem')
                    : helpTopicSettings[selectedTopic].description;
            }
            priority = helpTopicSettings[selectedTopic].priority;
            reason = helpTopicSettings[selectedTopic].reason;
            escalated = helpTopicSettings[selectedTopic].escalated;
            helper.clearFieldAfterSubmit('textValueProblem', component);

            if (textRequired && !text) {
                communityService.showWarningToast(
                    null,
                    $A.get('$Label.c.TST_Complete_description')
                );
                return;
            }
            helper.createNewCase(
                component,
                subject,
                text,
                type,
                priority,
                reason,
                false,
                escalated
            );
        }
    },

    onFileSelect: function (component, event, helper) {
        var files = event.target.files;
        helper.handleFileSelection(component, files);
    },

    onDragOver: function (component, event, helper) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';

        var files = event.dataTransfer.files;
        helper.handleFileSelection(component, files);
    },

    handleRemoveFile: function (component, event, helper) {
        event.preventDefault();
        var tmpId = event.getSource().get('v.name');
        console.log('tmpId= ' + tmpId);
        var fileList = component.get('v.fileList');
        var newList = [];

        for (var i = 0; i < fileList.length; i++) {
            if (fileList[i].tmpId === tmpId) continue;
            newList.push(fileList[i]);
        }
        component.set('v.fileList', newList);
    },
    helpTopicChanged: function (component, event, helper) {
        var helpTopicSettings = component.get('v.helpTopicSettings');
        
        var selectedTopic = event.target.value;
        component.set('v.selectedTopic',selectedTopic);

        var selectedTopicSettings;
        if (selectedTopic !== '') {
            selectedTopicSettings = helpTopicSettings[selectedTopic];
        } else {
            selectedTopicSettings = {
                userDescriptionRequired: false,
                knowledgeArticleLink: '',
                solutionText: '',
                descriptionPlaceholder: '',
                submitRequired: false
            };
        }
        if ($A.get('$Browser.formFactor') !== 'DESKTOP') {
            let selection = component.get('v.helpTopicOptions')[selectedTopic].label;
            component.set('v.placeholderText', selection);
        }
        component.set('v.selectedTopicSettings', selectedTopicSettings);
        component.set('v.didThisHelp', '');
        component.set('v.textValueProblem', '');
        component.set('v.fileList', []);
    },
    helpTopicChangedDeskTop: function(component,event,helper) {
        var helpTopicSettings = component.get('v.helpTopicSettings');
        var selectedTopic = component.get('v.selectedTopic');
        var selectedTopicSettings;
        if (selectedTopic !== '') {
            selectedTopicSettings = helpTopicSettings[selectedTopic];
            //component.set('v.selectedTopic',event.target.value);
        } else {
            selectedTopicSettings = {
                userDescriptionRequired: false,
                knowledgeArticleLink: '',
                solutionText: '',
                descriptionPlaceholder: '',
                submitRequired: false
            };
        }
        component.set('v.selectedTopicSettings', selectedTopicSettings);
        component.set('v.didThisHelp', '');
        component.set('v.textValueProblem', '');
        component.set('v.fileList', []);
    },
    doResponseReceived: function (component, event, helper) {
        var didThisHelp = component.get('v.didThisHelp');
        if (didThisHelp === 'Yes') {
            var text;
            var type;
            var subject;
            var priority;
            var reason;
            var escalated;
            var textRequired = component.get('v.userDescriptionRequired');
            var helpTopicSettings = component.get('v.helpTopicSettings');
            var selectedTopic = component.get('v.selectedTopic');
            type = helpTopicSettings[selectedTopic].type;
            text = helpTopicSettings[selectedTopic].userDescriptionRequired
                ? component.get('v.textValueProblem')
                : helpTopicSettings[selectedTopic].description;
            subject = helpTopicSettings[selectedTopic].subject;
            priority = helpTopicSettings[selectedTopic].priority;
            reason = helpTopicSettings[selectedTopic].reason;
            escalated = helpTopicSettings[selectedTopic].escalated;
            helper.clearFieldAfterSubmit('textValueProblem', component);

            if (textRequired && !text) {
                communityService.showWarningToast(
                    null,
                    $A.get('$Label.c.TST_Complete_description')
                );
                return;
            }
            helper.createNewCase(component, subject, text, type, priority, reason, true, escalated);
        }
    },

    toggleElement: function (component, event, helper) {
        let element = helper.getToggleElement(component);
        element[0].classList.toggle('active');
    },
    removeElementFocus: function (component, event, helper) {
        let element = helper.getToggleElement(component);
        element[0].classList.remove('active');
    }
});