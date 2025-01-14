/**
 * Created by Dmitry Ivakhnenko on 15-May-20.
 */

({
    doInit: function (component, event, helper) {
        let globalType = component.get('v.globalType');
        component.set('v.previousGlobalType', globalType);
    },

    doGlobalCountryChanged: function (component, event, helper) {
        let globalType = component.get('v.globalType');
        let globalCountries = component.get('v.globalCountries');

        let visitResults = component.get('v.visitResults');
        for (const visitResult of visitResults) {
            visitResult.countryCodes = globalCountries;
            visitResult.type = globalType;
        }
        component.set('v.visitResults', visitResults);
    },

    doGlobalTypeChanged: function (component, event, helper) {
        let globalType = component.get('v.globalType');
        let previousGlobalType = component.get('v.previousGlobalType');

        if (globalType === previousGlobalType) return;

        let visitResults = component.get('v.visitResults');
        let globalCountries = component.get('v.globalCountries');

        for (const visitResult of visitResults) {
            if (globalType === 'Disabled') {
                visitResult.countryCodes = '';
                visitResult.type = 'Disabled';
            } else {
                visitResult.countryCodes = globalCountries;
                visitResult.type = globalType;
            }
        }

        component.set('v.visitResults', visitResults);
        component.set('v.previousGlobalType', globalType);
    },

    doShowGroupChanged: function (component, event, helper) {
        if (!component.get('v.showGroup')) {
            component.set('v.showOnMyResultCard', false);
        }
        component.getEvent('onChange').fire();
    },

    doUpdateGroupDisplay: function (component, event, helper) {
        let visitResults = component.get('v.visitResults');
        for (const visitResult of visitResults) {
            if (visitResult.type !== 'Disabled') {
                component.set('v.showGroup', true);
                return;
            }
        }
        component.set('v.showGroup', false);
    },

    doUpdateGroupItems: function (component, event, helper) {
        let showGroup = component.get('v.showGroup');
        let visitResults = component.get('v.visitResults');
        let globalCountries = component.get('v.globalCountries');
        let globalType = component.get('v.globalType');

        for (const visitResult of visitResults) {
            if (showGroup) {
                visitResult.countryCodes = globalCountries;
                visitResult.type = globalType;
            } else {
                visitResult.countryCodes = '';
                visitResult.type = 'Disabled';
            }
        }
        component.set('v.visitResults', visitResults);
    },

    doUpdateGroupSelection: function (component, event, helper) {
        let changeShowOnMyResultCard = component.getEvent('onChangeShowOnMyResultCard');
        changeShowOnMyResultCard.setParams({
            visitResultGroupLabel: component.get('v.groupLabel'),
            showOnMyResultCard: component.get('v.showOnMyResultCard')
        });
        changeShowOnMyResultCard.fire();
    }
});
