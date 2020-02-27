/**
 * Created by Igor Malyuta on 22.03.2019.
 */
({
    doEdit : function (component, event, helper) {
        var Id = component.get('v.contact').Id;
        communityService.navigateToPage('edit-delegate' + '?id=' + Id);
    },

    doRemove : function (component, event, helper) {
        var parent = component.get('v.parentComponent');
        parent.find('mainSpinner').show();

        var contact = component.get('v.contact');
        var messText = $A.get('$Label.c.PG_PST_L_Delegates_Remove_Mess').replace('##Name', contact.Name);

        var actionRemoveDelegate = component.get('v.parentComponent').find('actionRemoveDelegate');
        actionRemoveDelegate.execute(messText, function () {
            communityService.executeAction(component, 'withdrawDelegate', {
                contactId: contact.Id,
                removeHimself: false
            }, function () {
                parent.find('mainSpinner').hide();
                parent.refresh();
            });
        });
    }
})