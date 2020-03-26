/**
 * Created by Igor Malyuta on 23.09.2019.
 */

({
    doInit: function (component, event, helper) {
        let icons = component.get('v.icons');
        for (let i = 0; i < icons.length; i++) icons[i].isSelected = false;

        let iconsValue = component.get('v.visit').Icons__c;
        if(iconsValue) {
            let selectedIcons = iconsValue.split(';');
            for(let i = 0; i < icons.length; i++) {
                if(selectedIcons.indexOf(icons[i].id) > -1) icons[i].isSelected = true;
            }
        }

        component.set('v.icons', icons);
    },

    valueChange: function (component, event, helper) {
        let icons = component.get('v.icons');
        let selectedIcons = [];
        for(let i = 0; i < icons.length; i++) if(icons[i].isSelected) selectedIcons.push(icons[i].id);

        let visit = component.get('v.visit');
        visit.Icons__c = selectedIcons.join(';');
        component.set('v.visit', visit);
    }
});