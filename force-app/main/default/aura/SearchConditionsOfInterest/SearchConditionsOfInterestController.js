/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
    },

    show: function (component) {
        component.find('searchModal').show();
    },

    hide: function(component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        var bypass = component.get('v.bypass');
        if (bypass) {
            return;
        } else {
            component.set('v.bypass', true);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.valueChange(component, event, helper);
                }), 500
            );
        }
    },

    handleChange: function (component, event) {
        let taWrapper = event.getSource().get('v.value');
        let taList = component.get('v.therapeuticAreas');
        if (event.getParam('checked')) {
            if (taList.length < 5) {
                taList.push(taWrapper.therArea);
            } else {
                event.getSource().set('v.checked', false);
            }
        } else {
            taList = taList.filter(e => e.Id !== taWrapper.therArea.Id);
        }
        component.set('v.therapeuticAreas', taList);
    },

})