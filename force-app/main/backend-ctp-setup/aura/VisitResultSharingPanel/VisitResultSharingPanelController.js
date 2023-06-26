/**
 * Created by Leonid Bartenev
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getInitData',
            {
                ctpId: component.get('v.recordId')
            },
            function (initData) {
                component.set('v.userPermission', initData.userPermission);
                component.set('v.initData', initData);
                component.set('v.groups', initData.groups);
                component.set('v.communityTemplate', initData.communityTemplate);
                component.set('v.options', initData.options);
                component.set('v.dataSnapshot', helper.takeSnapshot(component));
                component.find('spinner').hide();
            }
        );
    },

    doSSSelectionChange: function (component, event, helper) {
        let options = component.get('v.options');
        if (!options.selectedSSIds) {
            options.ssSelectionType = 'All';
            component.set('v.options', options);
        }
    },

    doSelectedStatusesChanged: function (component, event, helper) {
        let options = component.get('v.options');
        if (!options.selectedStatuses) {
            options.statusBasedType = '';
            component.set('v.options', options);
        }
    },

    doSSSelectionTypeChanged: function (component, event, helper) {
        let options = component.get('v.options');
        if (options.ssSelectionType !== 'All' && options.ssSelectionType !== 'Disabled') {
            component.find('ssSelectLookup').focus();
            options.selectedSSIds = '';
        } else {
            options.selectedSSIds = '';
        }
        component.set('v.options', options);
    },

    doCountrySelectionTypeChange: function (component, event, helper) {
        let options = component.get('v.options');
        if (options.countrySelectionType !== 'All' && options.countrySelectionType !== 'Disabled') {
            component.find('shareBackCountryLookup').focus();
            if (options.countrySelectionType === 'Countries') options.ssSelectionType = 'All';
        } else {
            options.ssSelectionType = options.countrySelectionType;
            options.selectedSSIds = '';
            options.selectedCountries = '';
        }
        component.set('v.options', options);
    },

    doCountrySelectionChange: function (component, event, helper) {
        let options = component.get('v.options');
        if (!options.selectedCountries) {
            options.countrySelectionType = 'All';
            component.set('v.options', options);
        }
    },

    doAfterDaysBlur: function (component, event, helper) {
        let options = component.get('v.options');
        if (!options.showAfterDays || options.showAfterDays < 1) {
            options.showAfterDays = 1;
            component.set('v.options', options);
        }
    },

    doWhenToShowChanged: function (component, event, helper) {
        let options = component.get('v.options');
        if (options.whenToShow === 'After') {
            setTimeout(
                $A.getCallback(function () {
                    component.find('whenToShowDaysInput').focus();
                }),
                100
            );
        } else {
            options.showAfterDays = 0;
        }

        component.set('v.options', options);
    },

    doGroupChanged: function (component, event, helper) {
        let groups = component.get('v.groups');
        for (const group of groups) {
            if (group.show) return;
        }

        let options = component.get('v.options');
        options.countrySelectionType = 'Disabled';
        options.ssSelectionType = options.countrySelectionType;
        options.selectedSSIds = '';
        options.selectedCountries = '';
        component.set('v.options', options);
    },

    onChangeGlobal: function (component, event, helper) {
        if (!component.get('v.options.globalShareBck')) {
            communityService.showInfoToast(
                '',
                'For the changes to take effect, do not forget to click Save!'
            );
        } else {
            let options = component.get('v.options');
            options.countrySelectionType = 'Disabled';
            component.set('v.options', options);
        }
    },

    saveOptions: function (component, event, helper) {
        if (helper.compareSnapshots(component, helper)) {
            communityService.showWarningToast('', 'Not found changes!');
            return;
        }
        let groups = component.get('v.groups');
        let options = component.get('v.options');
        let displayOnMyResultCardFlag = false;
        let showCustomTooltipErrorMessage = false;
        if (options.countrySelectionType !== 'Disabled') {
            for (let group of groups) {
                if (group.displayOnMyResultCard) {
                    displayOnMyResultCardFlag = true;
                    break;
                }
            }
        }
        for (let group of groups) {
            if (group.visitResults) {
                for (let visitResult of group.visitResults) {
                    if (
                        visitResult.isCustomToolTipEnabled &&
                        (!visitResult.customTooltip ||
                            (visitResult.customTooltip && visitResult.customTooltip.trim() === ''))
                    ) {
                        showCustomTooltipErrorMessage = true;
                        break;
                    }
                }
            }
        }

        if (
            component.get('v.communityTemplate') != 'PatientPortal' &&
            ((!displayOnMyResultCardFlag && options.countrySelectionType !== 'Disabled') ||
                showCustomTooltipErrorMessage)
        ) {
            if (!displayOnMyResultCardFlag && options.countrySelectionType !== 'Disabled') {
                communityService.showErrorToast(
                    '',
                    $A.get('$Label.c.Visit_Results_Group_If_Is_Not_Selected_For_My_Results')
                );
            }
            if (showCustomTooltipErrorMessage) {
                communityService.showErrorToast(
                    '',
                    $A.get('$Label.c.Empty_Custom_Tooltip_Error_Message')
                );
            }
        } else {
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'saveSharingRules',
                {
                    options: JSON.stringify(options),
                    groups: JSON.stringify(groups),
                    ctpId: component.get('v.recordId')
                },
                function () {
                    component.find('spinner').hide();
                    communityService.showSuccessToast(
                        'Success',
                        'Visit Result Sharing setting saved!'
                    );
                    if (!component.get('v.options.globalShareBck')) component.refresh();
                }
            );
        }
    },

    doGroupSelectionChanged: function (component, event, helper) {
        let selectGroupName = event.getParam('visitResultGroupLabel');
        let showOnMyResultCard = event.getParam('showOnMyResultCard');
        let groups = component.get('v.groups');
        for (let group of groups) {
            group.displayOnMyResultCard = group.label === selectGroupName && showOnMyResultCard;
        }
        component.set('v.groups', groups);
    }
});
