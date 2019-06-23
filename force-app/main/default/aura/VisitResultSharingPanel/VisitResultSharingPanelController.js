/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (initData) {
            component.set('v.groups', initData.groups);
            component.set('v.typeSelectLVList', initData.typeSelectLVList);
            component.set('v.options', initData.options);
            component.find('spinner').hide();
        })
    },

    doSSSelectionChange: function (component, event, helper) {
        var options = component.get('v.options');
        if(!options.selectedSSIds){
            options.ssSelectionType = 'All';
            component.set('v.options', options);
        }
    },

    doSelectedStatusesChanged: function (component, event, helper) {
        var options = component.get('v.options');
        if(!options.selectedStatuses){
            options.statusBasedType = 'All statuses';
            component.set('v.options', options);
        }
    },

    doSSSelectionTypeChanged: function (component, event, helper){
        var options = component.get('v.options');
        if(options.ssSelectionType != 'All'){
            component.find('ssSelectLookup').focus();
        }else{
            options.selectedSSIds = '';
            component.set('v.options', options);
        }
    },

    doAfterDaysBlur: function (component, event, helper) {
        var options = component.get('v.options');
        if(!options.showAfterDays || options.showAfterDays < 1){
            options.showAfterDays = 1;
            component.set('v.options', options);
        }
    },

    doWhenToShowChanged: function(component, event, helper){
        var options = component.get('v.options');
        if(options.whenToShow == 'After'){
            setTimeout(
                $A.getCallback(function () {
                    component.find('whenToShowDaysInput').focus();
                }), 100
            );
        }
    },

    doChangeStatusBaseType: function (component, event, helper) {
        var options = component.get('v.options');
        if(options.statusBasedType === 'Selected statuses'){
            component.find('statusSelectLookup').focus();
        }
    },

})