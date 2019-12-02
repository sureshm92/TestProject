/**
 * Created by Kryvolap on 21.09.2019.
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getHelpInitData', {
            userMode: component.get('v.userMode')
        }, function (response) {
            var initData = JSON.parse(response);
            component.set('v.userContact', initData.userContact.currentContact);
            component.set('v.helpTopicOptions', initData.helpTopicOptions);
            component.set('v.helpTopicSettings', initData.helpTopicSettings);
            helper.initRGOptions(component);
            component.set('v.isInitialized', true);
            var spinner = component.find('spinner');
            spinner.hide();
        });
    },

    submitRequest: function (component, event, helper) {
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
        text = helpTopicSettings[selectedTopic].userDescriptionRequired ? component.get('v.textValueProblem') : helpTopicSettings[selectedTopic].description;
        subject = helpTopicSettings[selectedTopic].subject;
        priority = helpTopicSettings[selectedTopic].priority;
        reason = helpTopicSettings[selectedTopic].reason;
        escalated = helpTopicSettings[selectedTopic].escalated;
        helper.clearFieldAfterSubmit('textValueProblem', component);

        if (textRequired && !text) {
            communityService.showWarningToast(null, $A.get('$Label.c.TST_Complete_description'));
            return;
        }
        helper.createNewCase(component, subject, text, type, priority, reason, false, escalated);
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
        var selectedTopic = component.get('v.selectedTopic');
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
            text = helpTopicSettings[selectedTopic].userDescriptionRequired ? component.get('v.textValueProblem') : helpTopicSettings[selectedTopic].description;
            subject = helpTopicSettings[selectedTopic].subject;
            priority = helpTopicSettings[selectedTopic].priority;
            reason = helpTopicSettings[selectedTopic].reason;
            escalated = helpTopicSettings[selectedTopic].escalated;
            helper.clearFieldAfterSubmit('textValueProblem', component);

            if (textRequired && !text) {
                communityService.showWarningToast(null, $A.get('$Label.c.TST_Complete_description'));
                return;
            }
            helper.createNewCase(component, subject, text, type, priority, reason, true, escalated);
        }
    },
})