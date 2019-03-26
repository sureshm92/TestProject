/**
 * Created by Igor Malyuta on 22.03.2019.
 */
({
    doEdit : function (component, event, helper) {
        var delegateId = component.get('v.delegate').delegateContact.Id;
        communityService.navigateToPage('edit-delegate' + '?id=' + delegateId);
    },

    showModale : function(component, event, helper) {
        var parent = component.get('v.parentComponent');
        parent.set('v.childComponent', component);
        parent.showRemoveModal();
    },

    doRemove : function (component, event, helper) {
        communityService.executeAction(component, 'removePatientDelegate',
            { delegate : JSON.stringify(component.get('v.delegate')) }, null);

        var parent = component.get('v.parentComponent');
        parent.set('v.childComponent', null);
        parent.refresh();
    }
})