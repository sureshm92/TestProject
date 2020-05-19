/**
 * Created by Dmitry Ivakhnenko on 15-May-20.
 */

({
    doInit: function (component, event, helper) {
        let globalType = component.get('v.globalType');
        component.set('v.previousGlobalType', globalType);
    },

    doGlobalCountryChanged: function (component, event, hepler) {
        let showGroup = component.get('v.showGroup');
        let globalType = component.get('v.globalType');

        if (globalType === 'Disabled' || !showGroup) return;

        let visitResults = component.get('v.visitResults');
        let globalCountries = component.get('v.globalCountries');

        for (const visitResult of visitResults) {
            if (visitResult.type !== 'Disabled') {
                visitResult.countryCodes = globalCountries;
                visitResult.type = globalType;
            }
        }
        component.set('v.visitResults', visitResults);
    },

    doGlobalTypeChanged: function (component, event, helper) {
        let globalType = component.get('v.globalType');
        let previousGlobalType = component.get('v.previousGlobalType');

        if (globalType === previousGlobalType ||
            (previousGlobalType !== 'Disabled' && globalType !== 'Disabled')) return;

        let visitResults = component.get('v.visitResults');
        let globalCountries = component.get('v.globalCountries');

        for (const visitResult of visitResults) {
            if (previousGlobalType === 'Disabled') {
                visitResult.countryCodes = globalCountries;
                visitResult.type = globalType;
            } else if (globalType === 'Disabled') {
                visitResult.countryCodes = null;
                visitResult.type = 'Disabled';
            }
        }

        component.set('v.visitResults', visitResults);
        component.set('v.previousGlobalType', globalType);
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

    doUpdateGroupSharing: function (component, event, helper) {
        let showGroup = component.get('v.showGroup');
        let visitResults = component.get('v.visitResults');
        let globalCountries = component.get('v.globalCountries');
        let globalType = component.get('v.globalType');

        for (const visitResult of visitResults) {
            if (showGroup) {
                visitResult.countryCodes = globalCountries;
                visitResult.type = globalType;
            } else {
                visitResult.countryCodes = null;
                visitResult.type = 'Disabled';
            }
        }
        component.set('v.visitResults', visitResults);
    }
});