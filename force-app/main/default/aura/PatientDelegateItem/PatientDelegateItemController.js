/**
 * Created by Igor Malyuta on 22.03.2019.
 */
({
    doEdit : function (component, event, helper) {
        var delegateId = component.get('v.delegate').delegateContact.Id;
        communityService.navigateToPage('edit-delegate' + '?id=' + delegateId);
    },

    doRemove : function (component, event, helper) {
        var delegateWrapper = component.get('v.delegate');
        component.get('v.parentComponent').find('actionRemoveDelegate').execute(delegateWrapper.delegateContact, function () {
            component.get('v.parentComponent').refresh();
        });
    }
})