/**
 * Created by Igor Malyuta on 22.03.2019.
 */
({
    handleClick: function (component, event, helper) {
        let parent = component.get('v.parentComponent');
        parent.find('mainSpinner').show();

        communityService.executeAction(component, 'changeDelegateStatus', {
            contactId: component.get('v.contact').Id,
            isActive: !component.get('v.isActive')
        }, function () {
            parent.find('mainSpinner').hide();
            parent.refresh();
        });
    }
});