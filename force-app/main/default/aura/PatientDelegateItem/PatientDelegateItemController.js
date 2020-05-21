/**
 * Created by Igor Malyuta on 22.03.2019.
 */
({
    handleClick: function (component, event, helper) {
        let parent = component.get('v.parentComponent');

        let isActive = !component.get('v.isActive');
        let callback = function () {
            communityService.executeAction(component, 'changeDelegateStatus', {
                contactId: component.get('v.contact').Id,
                isActive: isActive
            }, function () {
                parent.find('mainSpinner').hide();
                parent.refresh();
            });

        };
        if(!isActive) {
            let contact = component.get('v.contact');
            let messText = $A.get('$Label.c.Patient_Delegate_Deactivate_Mess').replace('##Name', contact.FirstName + ' ' + contact.LastName);
            let titText = $A.get('$Label.c.PG_PST_L_Delegates_Remove_Delegate');
            let actionRemoveDelegate = component.get('v.parentComponent').find('actionRemoveDelegate');
            actionRemoveDelegate.execute(messText, titText, callback);
        } else {
            parent.find('mainSpinner').show();
            callback();
        }
    }
});