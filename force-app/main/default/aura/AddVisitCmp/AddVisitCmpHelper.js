/**
 * Created by AlexKetch on 7/26/2019.
 */
({
    shiftRight: function (component, event, helper) {
        debugger;
        const elements = component.find('leftIcons');
        let selectedNames = [];
        let newLeft = [];
        if (elements instanceof Array) {
            for (let i = 0; i < elements.length; i++) {
                if (elements[i].get('v.selected')) {
                    selectedNames.push(elements[i].get('v.name'));
                } else {
                    newLeft.push(elements[i].get('v.name'));
                }
            }
        } else {
            if (elements.get('v.selected')) {
                selectedNames.push(elements.get('v.name'));
            } else {
                newLeft.push(elements.get('v.name'));
            }
        }
        let selectedIcons = component.get('v.selectedIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            selectedIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons', selectedIcons);
        component.set('v.availableIcons', newLeft);
    },
    shiftLeft: function (component, event, helper) {
        debugger;
        const elements = component.find('rightIcons');
        let selectedNames = [];
        let newRight = [];
        if (elements instanceof Array) {
            for (let i = 0; i < elements.length; i++) {
                if (elements[i].get('v.selected')) {
                    selectedNames.push(elements[i].get('v.name'));
                } else {
                    newRight.push(elements[i].get('v.name'));
                }
            }

        } else {
            if (elements.get('v.selected')) {
                selectedNames.push(elements.get('v.name'));
            } else {
                newRight.push(elements.get('v.name'));
            }
        }

        let availableIcons = component.get('v.availableIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            availableIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons', newRight);
        component.set('v.availableIcons', availableIcons);
    },
    addCallback: function (callback) {
        this.callback = callback;
    },
    getCallback: function () {
        return this.callback;
    },
})