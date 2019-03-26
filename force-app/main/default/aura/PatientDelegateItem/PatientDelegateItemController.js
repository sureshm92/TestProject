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
        var messText =
            $A.get('$Label.c.PG_PST_L_Delegates_Remove_Mess_P1') + ' ' + delegateWrapper.delegateContact.Name
            + ' ' + $A.get('$Label.c.PG_PST_L_Delegates_Remove_Mess_P2');

        var actionRemoveDelegate = component.get('v.parentComponent').find('actionRemoveDelegate');
        actionRemoveDelegate.set('v.messageText', messText);
        actionRemoveDelegate.execute(delegateWrapper.delegateContact, function () {
            component.get('v.parentComponent').refresh();
        });
    }
})