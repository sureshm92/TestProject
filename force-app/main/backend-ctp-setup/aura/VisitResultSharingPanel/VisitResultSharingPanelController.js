/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {
            'ctpId': component.get('v.recordId')
        }, function (initData) {
            component.set('v.userPermission', initData.userPermission);
            component.set('v.initData', initData);
            component.set('v.groups', initData.groups);
            component.set('v.options', initData.options);
            component.set('v.dataSnapshot', helper.takeSnapshot(component));
            component.find('spinner').hide();
        })
    },

    doSSSelectionChange: function (component, event, helper) {
        var options = component.get('v.options');
        if (!options.selectedSSIds) {
            options.ssSelectionType = 'All';
            component.set('v.options', options);
        }
    },

    doSelectedStatusesChanged: function (component, event, helper) {
        var options = component.get('v.options');
        if (!options.selectedStatuses) {
            options.statusBasedType = '';
            component.set('v.options', options);
        }
    },

    doSSSelectionTypeChanged: function (component, event, helper) {
        var options = component.get('v.options');
        if (options.ssSelectionType !== 'All' && options.ssSelectionType !== 'Disabled') {
            component.find('ssSelectLookup').focus();
            options.selectedSSIds = '';
        } else {
            options.selectedSSIds = '';
        }
        component.set('v.options', options);
    },

    doCountrySelectionTypeChange: function (component, event, helper) {
        var options = component.get('v.options');
        if (options.countrySelectionType !== 'All' && options.countrySelectionType !== 'Disabled') {
            component.find('shareBackCountryLookup').focus();
            if (options.countrySelectionType === 'Countries') options.ssSelectionType = 'All';
        }
        else {
            options.ssSelectionType = options.countrySelectionType;
            options.selectedSSIds = '';
            options.selectedCountries = '';
        }
        component.set('v.options', options);
    },

    doCountrySelectionChange: function (component, event, helper) {
        var options = component.get('v.options');
        if (!options.selectedCountries) {
            options.countrySelectionType = 'All';
            component.set('v.options', options);
        }
    },

    doAfterDaysBlur: function (component, event, helper) {
        var options = component.get('v.options');
        if (!options.showAfterDays || options.showAfterDays < 1) {
            options.showAfterDays = 1;
            component.set('v.options', options);
        }
    },

    doWhenToShowChanged: function (component, event, helper) {
        var options = component.get('v.options');
        if (options.whenToShow === 'After') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('whenToShowDaysInput').focus();
                }), 100
            );
        } else {
            options.showAfterDays = 0;
        }

        component.set('v.options', options);
    },

    onChangeGlobal: function (component, event, helper) {
        if (!component.get('v.options.globalShareBck')) {
            communityService.showInfoToast('', 'For the changes to take effect, do not forget to click Save!');
        } else {
            var options = component.get('v.options');
            options.countrySelectionType = 'Disabled';
            component.set('v.options', options);
        }
    },

    saveOptions: function (component, event, helper) {
        if (helper.compareSnapshots(component, helper)) {
            communityService.showWarningToast('', 'Not found changes!');
            return;
        }

        component.find('spinner').show();
        communityService.executeAction(component, 'saveSharingRules', {
            'options': JSON.stringify(component.get('v.options')),
            'groups': JSON.stringify(component.get('v.groups')),
            'ctpId': component.get('v.recordId')
        }, function () {
            component.find('spinner').hide();
            communityService.showSuccessToast('Success', 'Visit Result Sharing setting saved!');
            if (!component.get('v.options.globalShareBck')) component.refresh();
        });
    }
});