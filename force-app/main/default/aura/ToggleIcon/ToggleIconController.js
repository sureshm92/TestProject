/**
 * Created by Igor Malyuta on 23.09.2019.
 */

({
    onClick: function (component, event, helper) {
        component.set('v.iconDetail.isSelected', !component.get('v.iconDetail.isSelected'));
        component.getEvent('onchange').fire();
    }
});